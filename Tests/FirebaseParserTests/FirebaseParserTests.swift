import XCTest
@testable import FirebaseParser

final class FirebaseParserTests: XCTestCase {
    struct Chat: Codable {
        let title: String
        let lastMessage: String
        let timestamp: Date
    }

    struct Message: Codable {
        let name: String
        let message: String
        let timestamp: Date
    }

    struct Root: Codable {
        let chats: DynamicChildrenArray<Chat>
        let members: DynamicChildrenArray<DynamicChildrenArray<Bool>>
        let messages: DynamicChildrenArray<DynamicChildrenArray<Message>>
    }
    
    func testDecodeDatabaseWithFixedRootKeys() throws {
        let newJson = """
        {
          "chats": {
            "one": {
              "title": "Historical Tech Pioneers",
              "lastMessage": "ghopper: Relay malfunction found. Cause: moth.",
              "timestamp": 1459361875666
            },
            "two": {
              "title": "Historical Tech Pioneers",
              "lastMessage": "ghopper: Relay malfunction found. Cause: moth.",
              "timestamp": 1459361875666
            }
          },
          "members": {
            "one": {
              "ghopper": true,
              "alovelace": true,
              "eclarke": true
            }
          },
          "messages": {
            "one": {
              "m1": {
                "name": "eclarke",
                "message": "The relay seems to be malfunctioning.",
                "timestamp": 1459361875337
              }
            }
          }
        }
        """

        let data = Data(newJson.utf8)

        // Define DecodedArray type using the angle brackets (<>)
        let result = try JSONDecoder().decode(Root.self, from: data)

        XCTAssertEqual(result.members["one"]?[0].value, true)
        XCTAssertEqual(result.members[0].key, "one")
        
        XCTAssertEqual(result.members["one"]?["ghopper"], true)
        XCTAssertFalse(result.members[0].value[0].key.isEmpty)
    }
    
    func testDecodeDatabaseWithDynamicRootKeys() throws {
        let newJson = """
        {
            "one": {
              "title": "Historical Tech Pioneers",
              "lastMessage": "ghopper: Relay malfunction found. Cause: moth.",
              "timestamp": 1459361875666
            },
            "two": {
              "title": "Historical Tech Pioneers",
              "lastMessage": "ghopper: Relay malfunction found. Cause: moth.",
              "timestamp": 1459361875666
            }
        }
        """

        let data = Data(newJson.utf8)

        let result = try JSONDecoder().decode(FirebaseDynamicRoot<Chat>.self, from: data)

        XCTAssertEqual(result["one"]?.title, "Historical Tech Pioneers")
        XCTAssertFalse(result[0].key.isEmpty)
        
        print(result[0].value)
    }
}
