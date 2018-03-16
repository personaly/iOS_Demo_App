//
//  PersonalyMoPubMediationSettings.swift
//  PersonalyDemo
//
//  Created by Mobexs on 11/30/17.
//  Copyright © 2017 Personaly. All rights reserved.
//

import Personaly
import MoPub

@objc(PersonalyMoPubMediationSettings)
public class PersonalyMoPubMediationSettings: NSObject, MPMediationSettingsProtocol {

    @objc public var serverParameter: PersonalyServerParameter?
}
