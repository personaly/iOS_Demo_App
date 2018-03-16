//
//  PersonalyRouter.swift
//  PersonalyMopubAdapter
//
//  Created by Mobexs on 11/10/17.
//  Copyright © 2017 Persona.ly. All rights reserved.
//

import Personaly

protocol PersonalyRouterDelegate: class {

    func didPrecache(forPlacement placementID: String)
    func didFailPrecache(forPlacement placementID: String, error: Error?)
    func didReceiveReward(forPlacement placementID: String, amount: Int)
    func didReceiveClick(forPlacement placementID: String)
    func didConfigure()
    func didFailConfigure(with error: Error?)
}

public class PersonalyRouter: PersonalyDelegate {

    static let shared = PersonalyRouter()

    private var delegates:[NSObject] = []

    init() {

        Personaly.delegate = self
    }

    func addDelegate(_ delegate: PersonalyRouterDelegate) {

        if let object = delegate as? NSObject {

            if self.delegates.contains(object) {

                return
            }

            self.delegates.append(object)
        }
    }

    func removeDelegate(_ delegate: PersonalyRouterDelegate) {

        if let object = delegate as? NSObject {

            if let index = self.delegates.index(of: object) {

                self.delegates.remove(at: index)
            }
        }
    }

    //MARK:- PersonalyDelegate {

    public func didPrecache(forPlacement placementID: String) {

        for object in delegates {

            if let delegate = object as? PersonalyRouterDelegate {

                delegate.didPrecache(forPlacement: placementID)
            }
        }
    }

    public func didFailPrecache(forPlacement placementID: String, error: Error?) {

        for object in delegates {

            if let delegate = object as? PersonalyRouterDelegate {

                delegate.didFailPrecache(forPlacement: placementID, error: error)
            }
        }
    }

    public func didReceiveReward(forPlacement placementID: String, amount: Int) {

        for object in delegates {

            if let delegate = object as? PersonalyRouterDelegate {

                delegate.didReceiveReward(forPlacement: placementID, amount: amount)
            }
        }
    }

    public func didReceiveClick(forPlacement placementID: String) {

        for object in delegates {

            if let delegate = object as? PersonalyRouterDelegate {

                delegate.didReceiveClick(forPlacement: placementID)
            }
        }
    }

    public func didConfigure() {

        for object in delegates {

            if let delegate = object as? PersonalyRouterDelegate {

                delegate.didConfigure()
            }
        }
    }

    public func didFailConfigure(with error: Error?) {

        for object in delegates {

            if let delegate = object as? PersonalyRouterDelegate {

                delegate.didFailConfigure(with: error)
            }
        }
    }
}
