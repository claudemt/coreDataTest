
import Foundation
import CoreData


@objc(MasterItem) class MasterItem : NSManagedObject {
    
    @NSManaged var container: Container
    @NSManaged var item: Item
    
    class func create(ctx: NSManagedObjectContext, container: Container, item: Item) -> MasterItem {
        if let existingMaster = item.container.master {
            println("--- Deleting \(existingMaster)")
            ctx.deleteObject(existingMaster)
        }
        var m = NSEntityDescription.insertNewObjectForEntityForName("MasterItem", inManagedObjectContext:ctx) as MasterItem
        m.item = item
        m.container = container
        println("+++ Created \(m)")
        return m
    }
}