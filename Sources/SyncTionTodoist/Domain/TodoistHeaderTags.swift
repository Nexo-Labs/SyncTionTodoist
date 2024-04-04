//
//  TodoistHeaderTags.swift
//  SyncTion (macOS)
//
//  Created by Rubén on 28/1/23.
//

/*
This file is part of SyncTion and is licensed under the GNU General Public License version 3.
SyncTion is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import SyncTionCore

extension Tag {
    struct Todoist {
        private init() { fatalError() }

        static let ProjectField = Tag("78baeabd-e1bc-494c-bd57-79d9f395f0a1")!
        static let SectionsField = Tag("cca702a7-43ba-43b5-8938-f413ba6e353c")!
        static let LabelsField = Tag("3ec0f336-0855-41d9-b434-19e82409d69f")!
        static let ContentField = Tag("5a81b6cd-b698-4a0d-b10d-fc069243f267")!
        static let NoteField = Tag("42d5e73d-c8b0-4b4c-ab8c-d698120f4ea0")!
        static let PriorityField = Tag("40d3f130-72f6-4a16-925b-f60a68efd5c1")!
    }
}
