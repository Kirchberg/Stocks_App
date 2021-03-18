//
//  AppDelegate.swift
//  stocks
//
//  Created by Kirill Kostarev on 17.02.2021.
//

import RealmSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let schemaVersion: UInt64 = 1
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: schemaVersion,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { _, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < schemaVersion {}
            }
        )
        Realm.Configuration.defaultConfiguration = config
        return true
    }
}
