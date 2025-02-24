//
//  PlayerStatus.swift
//  SonerimTestTask
//
//  Created by Ivan_Tests on 24.02.2025.
//

import Foundation
import Observation

@Observable final class PlayerStatus {
    var isPlayerVisible:Bool = false
    var playerProgress:CGFloat = 0.0
    var isPlayerPlaying:Bool = false
}
