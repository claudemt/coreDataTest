//
//  ITunesBridge.swift
//  RemotagAppMac
//
//  Created by Claude Montpetit on 2014-06-11.
//  Copyright (c) 2014 com.remotag. All rights reserved.
//

import Foundation
import Cocoa

class Loader {
    
    
    init(){
        var cdsm = CoreDataStackManager.sharedInstance
        let ctx = cdsm.mainQueueCtx
        var container = Container.create(ctx)
        var item = Item.create(ctx, name: "hello", container: container)
        var master = MasterItem.create(ctx, container: container, item: item)
        var anyError: NSError?
        if !ctx.save(&anyError) {
            println("Cannot save dataSet: \(anyError!.localizedDescription)")
        }
    }
}

