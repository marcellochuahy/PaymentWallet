//
//  UserInfoDTO.swift
//  WalletFeatureSampleApp
//
//  Created by Marcello Chuahy on 27/11/25.
//

import Foundation

public struct UserInfoDTO: Equatable, Sendable {
    
    public let name: String
    public let email: String

    public init(name: String, email: String) {
        self.name = name
        self.email = email
    }
    
}
