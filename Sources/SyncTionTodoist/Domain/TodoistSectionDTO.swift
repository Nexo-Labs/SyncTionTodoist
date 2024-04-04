//
//  TodoistSectionDTO.swift
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

struct TodoistSectionDTO: Equatable, Decodable {
    let id: String
    let projectId: String
    let order: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case order = "order"
        case projectId = "project_id"
        case name = "name"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard
            let id = try values.decodeIfPresent(String.self, forKey: .id),
            let order = try values.decodeIfPresent(Int.self, forKey: .order),
            let name = try values.decodeIfPresent(String.self, forKey: .name),
            let projectId = try values.decodeIfPresent(String.self, forKey: .projectId)
        else {
            throw SyncTionError.DecodingError(.TodoistJSONDecodingError)
        }
        self.id = id
        self.order = order
        self.projectId = projectId
        self.name = name
    }
}
