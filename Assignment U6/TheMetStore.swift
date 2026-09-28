import Foundation
import WidgetKit

class TheMetStore: ObservableObject {
    @Published var objects: [Object] = []
    let service = TheMetService()
    let maxIndex: Int
    
    init(maxIndex: Int = 30) {
        self.maxIndex = maxIndex
    }
    
    func fetchObjects(for queryTerm: String) {
        service.getObjectIDs(from: queryTerm) { [weak self] objectIDs in
            guard let self = self, let objectIDs = objectIDs else { return }
            
            var fetchedObjects: [Object] = []
            let group = DispatchGroup()
            
            for (index, objectID) in objectIDs.objectIDs.enumerated() where index < self.maxIndex {
                group.enter()
                self.service.getObject(from: objectID) { object in
                    if let object = object {
                        fetchedObjects.append(object)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.objects = fetchedObjects
                self.writeObjects()
                WidgetCenter.shared.reloadTimelines(ofKind: "TheMetWidget")
            }
        }
    }
    
    private func writeObjects() {
        // Replace with your actual App Group Identifier
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourdomain.TheMet.objects") else { return }
        let archiveURL = containerURL.appendingPathComponent("objects.json")
        
        if let dataToSave = try? JSONEncoder().encode(objects) {
            try? dataToSave.write(to: archiveURL)
        }
    }
}
