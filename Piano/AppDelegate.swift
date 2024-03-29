//
//  AppDelegate.swift
//  Piano
//
//  Created by Kevin Kim on 12/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import UIKit
import CloudKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        application.registerForRemoteNotifications()
        _ = CloudManager.shared
        _ = LocalDatabase.shared
        _ = PianoNoteSizeInspector.shared
        performMigration()
        
        
        return true
    }

    func checkForTags() {
        guard let realm = try? Realm() else {return}
        if realm.objects(RealmTagsModel.self).count == 0 {
            
            class FlagReference {
                var flag = false
            }
            
            let tagFlag = FlagReference()
            
            CloudManager.shared.privateDatabase.query(for: RealmTagsModel.recordTypeString, recordFetchedBlock: { (record) in
                if tagFlag.flag == false {
                    CloudManager.shared.privateDatabase.syncChanged(record: record, isShared: false)
                }
                tagFlag.flag = true
            }) { (_, _) in
                if !tagFlag.flag {
                    ModelManager.saveNew(model: RealmTagsModel.getNewModel())
                }
            }
        }
    }
    
    func performMigration() {
        let url = Realm.Configuration.defaultConfiguration.fileURL
        let config = Realm.Configuration(
            fileURL: url,
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 0,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
                
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        let _ = try! Realm()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    //This only happens whenever the change has occured from other environment!!
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("got noti!")
        guard let dict = userInfo as? [String: NSObject],
            application.applicationState != .inactive else {return}
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        
        guard let subscriptionID = notification.subscriptionID else {return}
        
        
        if subscriptionID.hasSuffix(CKDatabaseScope.private.string) {
            CloudManager.shared.privateDatabase.handleNotification()
            completionHandler(.newData)
        } else if subscriptionID.hasSuffix(CKDatabaseScope.shared.string) {
            CloudManager.shared.sharedDatabase.handleNotification()
            completionHandler(.newData)
        } else if subscriptionID.hasPrefix(CKDatabaseScope.public.string) {
            CloudManager.shared.publicDatabase.handleNotification()
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
        
    }
    
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShareMetadata) {
        let acceptShareOperation: CKAcceptSharesOperation =
            CKAcceptSharesOperation(shareMetadatas:
                [cloudKitShareMetadata])
        
        acceptShareOperation.qualityOfService = .userInteractive
        acceptShareOperation.perShareCompletionBlock = {meta, share,
            error in
            print(error ?? "good")
            print("share was accepted")
            //            CloudManager.shared.privateDatabase.syncChanged(record: share, isShared: true)
        }
        acceptShareOperation.acceptSharesCompletionBlock = {
            error in
            /// Send your user to where they need to go in your app
        }
        CKContainer(identifier:
            cloudKitShareMetadata.containerIdentifier).add(acceptShareOperation)
    }
    
}

