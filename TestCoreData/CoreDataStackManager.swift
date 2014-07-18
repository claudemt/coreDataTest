
/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

Singleton controller to manage the main Core Data stack for the application. It vends a persistent store coordinator, and for convenience the managed object model and URL for the persistent store.

*/


import Cocoa

var _sharedInstance: CoreDataStackManager?

class CoreDataStackManager {


    class var sharedInstance: CoreDataStackManager {

        if _sharedInstance {
            return _sharedInstance!
        }
        _sharedInstance = CoreDataStackManager()
        return _sharedInstance!
    }

    
    /**
    Returns the managed object model for the application.
    */
    @lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension:"momd")
        return NSManagedObjectModel(contentsOfURL:modelURL)
    }()


    /**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    */
    var persistentStoreCoordinator: NSPersistentStoreCoordinator! {

        if _persistentStoreCoordinator {
            return _persistentStoreCoordinator
        }

        let url = self.storeURL
        if !url {
            return nil
        }

        let psc = NSPersistentStoreCoordinator(managedObjectModel:self.managedObjectModel)
        let options = [NSMigratePersistentStoresAutomaticallyOption : 1, NSInferMappingModelAutomaticallyOption : 1]
        var error: NSError?

        if !psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:url, options:options, error:&error) {
            NSApplication.sharedApplication().presentError(error)
            //fatalError("Could not add the persistent store")
            return nil
        }

        _persistentStoreCoordinator = psc
        return _persistentStoreCoordinator
    }
    var _persistentStoreCoordinator: NSPersistentStoreCoordinator?


    /**
    Returns the URL for the Core Data store file.
    */
    var storeURL: NSURL! {

        if _storeURL {
            return _storeURL!
        }

        let fileManager = NSFileManager.defaultManager()
        let URLs = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains:.UserDomainMask)

        var applicationSupportDirectory = URLs[0] as NSURL
        applicationSupportDirectory = applicationSupportDirectory.URLByAppendingPathComponent("com.example.testCoreData")

        var error: NSError?
            if let properties = applicationSupportDirectory.resourceValuesForKeys([NSURLIsDirectoryKey!], error:&error) {
                
                if let isDirectory = properties[NSURLIsDirectoryKey] as? NSNumber {
                    if !isDirectory.boolValue {
                        let description = NSLocalizedString("Could not access the application data folder.", comment: "Failed to initialize the PSC")
                        let reason = NSLocalizedString("Found a file in its place.", comment: "Failed to initialize the PSC")
                        let dict = [NSLocalizedDescriptionKey : description, NSLocalizedFailureReasonErrorKey : reason]
                        error = NSError.errorWithDomain("EARTHQUAKES_ERROR_DOMAIN", code:101, userInfo:dict)
                        //fatalError("Could not access the application data folder")
                        
                        NSApplication.sharedApplication().presentError(error)
                        return nil
                    }
                }
            } else {
                if error!.code == NSFileReadNoSuchFileError {
                    let ok = fileManager.createDirectoryAtPath(applicationSupportDirectory.path, withIntermediateDirectories:true, attributes:nil, error:&error)
                    if !ok {
                        NSApplication.sharedApplication().presentError(error)
                        //fatalError("Could not create the application data folder")
                        return nil
                    }
                }
            }

        _storeURL = applicationSupportDirectory.URLByAppendingPathComponent("com.example.storedata")
        println("Store URL: \(_storeURL)")
        return _storeURL
    }
    var _storeURL: NSURL?
    
    @lazy var mainQueueCtx: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = CoreDataStackManager.sharedInstance.persistentStoreCoordinator
        moc.undoManager = nil
        NSNotificationCenter.defaultCenter().addObserver(
            moc,
            selector: "mergeChangesFromContextDidSaveNotification:",
            name: NSManagedObjectContextDidSaveNotification,
            object: self.localQueueCtx)

        return moc
        }()

    @lazy var localQueueCtx: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        moc.persistentStoreCoordinator = CoreDataStackManager.sharedInstance.persistentStoreCoordinator
        moc.undoManager = nil
        return moc
        }()
    
}