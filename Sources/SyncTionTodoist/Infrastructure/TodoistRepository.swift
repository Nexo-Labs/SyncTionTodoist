//
//  TodoistRepository.swift
//  SyncTion (macOS)
//
//  Created by Rubén on 26/1/23.
//

/*
This file is part of SyncTion and is licensed under the GNU General Public License version 3.
SyncTion is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import Foundation
import SyncTionCore
import Combine
import PreludePackage

fileprivate extension URLRequest {
    func todoistHeaders(secrets: TodoistSecrets) -> URLRequest {
        self.header(.contentType, value: "application/json")
            .header(.authorization, value: "Bearer \(secrets.secret)")
    }
}

fileprivate extension URL {
    static let todoistAPI = URL(string: "https://api.todoist.com")!
    static let todoistSections: URL = .todoistAPI.appendingPathComponent("rest/v2/sections")
    static let todoistLabels: URL = .todoistAPI.appendingPathComponent("rest/v2/labels")
    static let todoistProjects: URL = .todoistAPI.appendingPathComponent("rest/v2/projects")
    static let todoistTasks: URL = .todoistAPI.appendingPathComponent("rest/v2/tasks")
}

final class TodoistRepository: FormRepository {
    static let shared = TodoistRepository()

    @KeychainWrapper(Constants.todoistSecretLabel) var todoistSecrets: TodoistSecrets?
    
    var sectionsCache: [TodoistSectionDTO]? = nil
            
    var defaultSectionInputList: OptionsTemplate {
        OptionsTemplate(
            header: Header(
                name: String(localized: "Section"),
                icon: "square.leftthird.inset.filled",
                tags: [Tag.Todoist.SectionsField]
            ),
            config: OptionsTemplateConfig(singleSelection: Editable(true, constant: true))
        )
    }
    
    static var scratchTemplate: FormTemplate {
        let style = FormModel.Style(
            formName: TodoistFormService.shared.description,
            icon: .static(TodoistFormService.shared.icon),
            color: "E44431",
            theme: .PlainGrey
        )
        let task = TextTemplate(
            header: Header(
                name: String(localized: "Task name"),
                icon: "textformat.abc",
                tags: [Tag.Todoist.ContentField]
            ),
            config: InputTemplateConfig()
        )
        let note = TextTemplate(
            header: Header(
                name: String(localized: "Description"),
                icon: "text.justify.leading",
                tags: [Tag.Todoist.NoteField]
            ),
            config: InputTemplateConfig()
        )
        
        let labelsList = OptionsTemplate(
            header: Header(
                name: String(localized: "Labels"),
                icon: "tag",
                tags: [Tag.Todoist.LabelsField]
            ),
            config: OptionsTemplateConfig(
                singleSelection: Editable(false, constant: true),
                typingSearch: Editable(true, constant: false)
            )
        )
        let priorityList = OptionsTemplate(
            header: Header(
                name: String(localized: "Priority"),
                icon: "flag.square",
                tags: [Tag.Todoist.PriorityField]
            ),
            config: OptionsTemplateConfig(
                singleSelection: Editable(true, constant: true),
                typingSearch: Editable(false, constant: false)
            ),
            value: Options(
                options: [
                    Option(optionId: "1", icon: .sfsymbols("flag", nil), description: ""),
                    Option(optionId: "2", icon: .sfsymbols("flag.fill", "1D56D9"), description: ""),
                    Option(optionId: "3", icon: .sfsymbols("flag.fill", "E4760C"), description: ""),
                    Option(optionId: "4", icon: .sfsymbols("flag.fill", "C42F2D"), description: ""),
                ],
                singleSelection: true
            )
        )
        
        let projectList = OptionsTemplate(
            header: Header(
                name: String(localized: "Project"),
                icon: "list.bullet.rectangle",
                tags: [Tag.Todoist.ProjectField]
            ),
            config: OptionsTemplateConfig(
                singleSelection: Editable(true, constant: true),
                typingSearch: Editable(true, constant: false)
            )
        )
        return FormTemplate(
            FormHeader(
                id: FormTemplateId(),
                style: style,
                integration: TodoistFormService.shared.id
            ),
            inputs: [task, note, projectList, labelsList, priorityList]
        )
    }
    
    func post(form: FormModel) async throws -> Void {
        guard let body = TodoistTaskBodyDTO(form: form) else {
            throw FormError.transformation
        }
        guard let todoistSecrets else { throw FormError.auth(TodoistFormService.shared.id) }

        let request = URLRequest(url: .todoistTasks)
            .todoistHeaders(secrets: todoistSecrets)
            .method(.post(body))
        guard request.httpBody != nil else { throw FormError.transformation }

        let _ = try await transformAuthError(TodoistFormService.shared.id) {
            try await self.request(request, TodoistTaskDTO.self)
        }
    }
    
    func loadProjects() async throws -> [(Option, Bool)] {
        guard let todoistSecrets else { throw FormError.auth(TodoistFormService.shared.id) }
        let request = URLRequest(url: .todoistProjects)
            .todoistHeaders(secrets: todoistSecrets)
            .method(.get)

        return try await transformAuthError(TodoistFormService.shared.id) {
            let result = try await self.request(request, [TodoistProjectDTO].self)
            sectionsCache = nil
            return result.map {(
                Option(
                    optionId: $0.id,
                    icon: .sfsymbols("circle.fill", TodoistColorHex(rawValue: $0.color)?.hex),
                    description: $0.name
                ),
                $0.isInboxProject
            )}
        }
    }
    
    func loadLabels() async throws -> [Option] {
        guard let todoistSecrets else { throw FormError.auth(TodoistFormService.shared.id) }
        let request = URLRequest(url: .todoistLabels)
            .todoistHeaders(secrets: todoistSecrets)
            .method(.get)

        return try await transformAuthError(TodoistFormService.shared.id) {
            let result: [TodoistLabelsDTO] = try await self.request(request, [TodoistLabelsDTO].self)
            return result.map {
                Option(
                    optionId: $0.id,
                    icon: .sfsymbols("tag.fill", TodoistColorHex(rawValue: $0.color)?.hex),
                    description: $0.name
                )
            }
        }
    }
    
    func loadSections(projectId: String) async throws -> [Option] {
        guard let todoistSecrets else { throw FormError.auth(TodoistFormService.shared.id) }
        let request = URLRequest(url: .todoistSections)
            .todoistHeaders(secrets: todoistSecrets)
            .method(.get)

        let result: [TodoistSectionDTO]
        if let sectionsCache {
            result = sectionsCache
        } else {
            result = try await transformAuthError(TodoistFormService.shared.id) {
                try await self.request(request, [TodoistSectionDTO].self)
            }
            sectionsCache = result
        }
        
        return result.filter{
            $0.projectId == projectId
        }.map {
            Option(optionId: $0.id, description: $0.name)
        }
    }
}
