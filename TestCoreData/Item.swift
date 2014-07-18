
import Foundation
import CoreData


@objc(Item) class Item : NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var container: Container
    @NSManaged var master: MasterItem?
    
    class func create(ctx: NSManagedObjectContext, name: String, container: Container) -> Item {
        var item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext:ctx) as Item
        item.name = name
        item.container = container
        println("+++ Created Item \(name)")
        return item
    }
    
    func isMaster() -> Bool {
        if let master = master {
            return true
        }
        return false
    }
    
    func description() -> String {
        return "Item { \n name: \(name)}"
    }

}