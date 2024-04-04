//
//  TodoistTaskBodyDTO.swift
//  SyncTion (macOS)
//
//  Created by Rubén on 29/1/23.
//

/*
This file is part of SyncTion and is licensed under the GNU General Public License version 3.
SyncTion is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import Foundation
import SyncTionCore

struct TodoistTaskBodyDTO: Encodable {
    let content: String
    let project_id, section_id, description: String?
    let priority: Int?
    let labels: [String]?
    
    init?(form: FormModel) {
        guard
            let contentInput: TextTemplate = form.inputs.first(tag: Tag.Todoist.ContentField),
            let noteInput: TextTemplate = form.inputs.first(tag: Tag.Todoist.NoteField),
            let priorityInput: OptionsTemplate = form.inputs.first(tag: Tag.Todoist.PriorityField)
        else {
            return nil
        }
        let projectsInput: OptionsTemplate? = form.inputs.first(tag: Tag.Todoist.ProjectField)
        let labelsInput: OptionsTemplate? = form.inputs.first(tag: Tag.Todoist.LabelsField)
        let sectionInput: OptionsTemplate? = form.inputs.first(tag: Tag.Todoist.SectionsField)

        self.content = contentInput.value
        self.description = noteInput.value
        self.project_id = projectsInput?.value.selected.first?.optionId
        self.section_id = sectionInput?.value.selected.first?.optionId
        self.priority = Int(priorityInput.value.selected.first?.optionId ?? "")
        self.labels = labelsInput?.value.selected.map{
            $0.description
        }
    }
}
