//
//  TodoistFormService.swift
//  SyncTion (macOS)
//
//  Created by Rubén on 27/1/23.
//

/*
This file is part of SyncTion and is licensed under the GNU General Public License version 3.
SyncTion is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import SyncTionCore
import Combine
import Foundation
import PreludePackage

public final class TodoistFormService: FormService {
    public static let shared = TodoistFormService()
    
    public var id = FormServiceId(hash: UUID(uuidString: "c7421ad1-f24f-4740-8688-ef5e007bf24d")!)
    public let description = String(localized: "Todoist")
    public let icon = "TodoistLogo"

    let repository = TodoistRepository.shared

    public var scratchTemplate: FormTemplate {
        TodoistRepository.scratchTemplate
    }

    public let onChangeEvents: [any TemplateEvent] = [
        ProjectFieldOnChangeHandler.shared
    ]
    
    public func load(form: FormModel) async throws -> FormDomainEvent {
        let inputs = try await (projects: loadProjectList(form: form), labels: loadLabelsList(form: form))
        
        return { form in
            form.inputs.append(template: AnyInputTemplate(inputs.projects))
            form.inputs.append(template: AnyInputTemplate(inputs.labels))
        }
    }
    
    func onChangingSelectedList(
        form: FormModel, oldInput: OptionsTemplate, input: OptionsTemplate
    ) async throws -> FormDomainEvent {
        guard oldInput.value != input.value else { throw FormError.event(.skip) }
        return try await loadSectionList(form: form, input: input)
    }
    
    public func send(form: FormModel) async throws {
        try await repository.post(form: form)
    }

    private final class ProjectFieldOnChangeHandler: TemplateEvent {
        typealias Template = OptionsTemplate
        
        static var shared = ProjectFieldOnChangeHandler()
        
        func assess(old: OptionsTemplate, input: OptionsTemplate) -> Bool {
            input.header.tags.contains(.Todoist.ProjectField) && old.value != input.value
        }
        
        func execute(form: FormModel, old: OptionsTemplate, input: OptionsTemplate) async throws -> Success {
            try await TodoistFormService.shared.onChangingSelectedList(form: form, oldInput: old, input: input)
        }
    }
    
    private func loadProjectList(form: FormModel) async throws -> OptionsTemplate {
        logger.info("LoadProjectList: Init")
        guard var input: OptionsTemplate = form.inputs.first(tag: .Todoist.ProjectField) else {
            throw FormError.nonLocatedInput(.Todoist.ProjectField)
        }
        let projects = try await repository.loadProjects()
        let inboxProjectId = projects.first {
            $0.1
        }?.0.optionId

        let sortingByInboxId: (Option, Option) -> Bool = {
            $0.optionId == inboxProjectId && $1.optionId != inboxProjectId
        }
        
        input.load(
            options: projects.map{$0.0},
            keepSelected: false,
            sorting: [OptionsTemplate.defaultSorting, sortingByInboxId]
        )
        return input
    }

    private func loadSectionList (form: FormModel, input: OptionsTemplate) async throws -> FormDomainEvent {
        logger.info("LoadSectionList: Init")
        guard let projectId = input.value.selected.first?.optionId else {
            throw FormError.event(.skip)
        }

        let newOptions = try await repository.loadSections(projectId: projectId)
        guard !newOptions.isEmpty else {
            return { form in
                form.inputs.removeAll {
                    $0.template.header.tags.contains(Tag.Todoist.SectionsField)
                }
            }
        }

        var inputCopy = repository.defaultSectionInputList
        inputCopy.load(options: newOptions, keepSelected: false)

        return { [inputCopy] form in
            form.inputs.removeAll {
                $0.template.header.tags.contains(Tag.Todoist.SectionsField)
            }
            let index = form.inputs
                .map(\.id)
                .firstIndex(of: input.id) ?? form.inputs.count - 2
            form.inputs.insert(AnyInputTemplate(inputCopy), at: index + 1)
            logger.info("LoadSectionList: Success")
        }
    }

    private func loadLabelsList(form: FormModel) async throws -> OptionsTemplate {
        logger.info("LoadLabelsList: Init")
        guard var input: OptionsTemplate = form.inputs.first(tag: Tag.Todoist.LabelsField) else {
            throw FormError.nonLocatedInput(.Todoist.LabelsField)
        }
        
        let result = try await repository.loadLabels()
        input.load(options: result, keepSelected: false)
        return input
    }
}

