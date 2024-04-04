//
//  TodoistColorDTO.swift
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

enum TodoistColorHex: String {
    case berryRed = "berry_red"
    case red = "red"
    case orange = "orange"
    case yellow = "yellow"
    case oliveGreen = "olive_green"
    case limeGreen = "lime_green"
    case green = "green"
    case mintGreen = "mint_green"
    case teal = "teal"
    case skyBlue = "sky_blue"
    case lightBlue = "light_blue"
    case blue = "blue"
    case grape = "grape"
    case violet = "violet"
    case lavender = "lavender"
    case magenta = "magenta"
    case salmon = "salmon"
    case charcoal = "charcoal"
    case grey = "grey"
    case taupe = "taupe"
    
    var hex: String {
        switch self {
        case .berryRed:
            return "b8256f"
        case .red:
            return "db4035"
        case .orange:
            return "ff9933"
        case .yellow:
            return "fad000"
        case .oliveGreen:
            return "afb83b"
        case .limeGreen:
            return "7ecc49"
        case .green:
            return "299438"
        case .mintGreen:
            return "6accbc"
        case .teal:
            return "158fad"
        case .skyBlue:
            return "14aaf5"
        case .lightBlue:
            return "96c3eb"
        case .blue:
            return "4073ff"
        case .grape:
            return "884dff"
        case .violet:
            return "af38eb"
        case .lavender:
            return "eb96eb"
        case .magenta:
            return "e05194"
        case .salmon:
            return "ff8d85"
        case .charcoal:
            return "808080"
        case .grey:
            return "b8b8b8"
        case .taupe:
            return "ccac93"
        }
    }
}
