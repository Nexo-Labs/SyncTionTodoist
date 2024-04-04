//
//  TodoistProjectDTO.swift
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

struct TodoistProjectDTO: Equatable, Decodable {
    let id: String
    let parentId: String?
    let order: Int
    let color, name: String
    let isShared, isFavorite, isInboxProject, isTeamInbox: Bool
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case parent_id = "parent_id"
        case order = "order"
        case color = "color"
        case name = "name"
        case is_shared = "is_shared"
        case is_favorite = "is_favorite"
        case is_inbox_project = "is_inbox_project"
        case is_team_inbox = "is_team_inbox"
        case url = "url"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard
            let id = try values.decodeIfPresent(String.self, forKey: .id),
            let order = try values.decodeIfPresent(Int.self, forKey: .order),
            let color = try values.decodeIfPresent(String.self, forKey: .color),
            let name = try values.decodeIfPresent(String.self, forKey: .name),
            let is_shared = try values.decodeIfPresent(Bool.self, forKey: .is_shared),
            let is_favorite = try values.decodeIfPresent(Bool.self, forKey: .is_favorite),
            let is_inbox_project = try values.decodeIfPresent(Bool.self, forKey: .is_inbox_project),
            let is_team_inbox = try values.decodeIfPresent(Bool.self, forKey: .is_team_inbox),
            let url = try values.decodeIfPresent(String.self, forKey: .url)
        else {
            throw SyncTionError.DecodingError(.TodoistJSONDecodingError)
        }
        self.parentId = try values.decodeIfPresent(String.self, forKey: .parent_id)
        self.id = id
        self.order = order
        self.color = color
        self.name = name
        self.isShared = is_shared
        self.isFavorite = is_favorite
        self.isInboxProject = is_inbox_project
        self.isTeamInbox = is_team_inbox
        self.url = url
    }
}
