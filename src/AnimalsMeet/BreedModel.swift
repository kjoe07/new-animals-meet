import SwiftyJSON
import Foundation
import PromiseKit

class BreedModel {
    
    var id: Int!
    var dog: Bool!
    var nameEn: String!
    var nameFr: String!
    
    public init() {
    }
    
    public init(fromJSON JSON: JSON) {
        
        id = JSON["id"].intValue
        dog = JSON["dog"].boolValue
        nameEn = JSON["breed_en"].stringValue
        nameFr = JSON["breed_fr"].stringValue
    }
}
