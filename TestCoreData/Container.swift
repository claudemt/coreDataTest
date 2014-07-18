
import Foundation
import CoreData


@objc(Container) class Container : NSManagedObject {
    @NSManaged var items: NSSet
    @NSManaged var master: MasterItem?
    
    class func create(ctx: NSManagedObjectContext) -> Container {
        var c = NSEntityDescription.insertNewObjectForEntityForName("Container", inManagedObjectContext:ctx) as Container
        println("+++ Created \(c)")
        return c
    }
    
}