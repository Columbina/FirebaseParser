# Columbina's FirebaseParser

## Easy parsing for Firebase Realtime Database or Firestore.

Dealing with Firebase documents might be tricky. Since it doesn't support arrays, 
we usually have to run through keys and values and manually extract them into our models.

`FirebaseParser` allows you to parse a Firebase json without hustle, only by using your own models.

### How to use it

#### Parsing root composed of an array of objects

From a given Firebase document in which each root key is "dynamic", 
meaning that they vary instead of being fixed strings, you can use the `FirebaseDynamicRoot` object.

For instance, for the following json, which represents an array of Chats:

```json
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
```
You can parse it like this:

```swift
struct Chat: Codable {
    let title: String
    let lastMessage: String
    let timestamp: Date
}
...
messagesReference.observe(DataEventType.value, with: { [weak self] snapshot in
    guard let dictionary = snapshot.value as? NSDictionary else { return }
    
    let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
    
    if let decoded = try? JSONDecoder().decode(FirebaseDynamicRoot<Chat>.self, from: data) {
        let chats = decoded.map {
            let key = $0.key
            let value = $0.value
            
            return Chat(title: value.title,
                        lastMessage: value.lastMessage,
                        timestamp: value.timestamp)
        }
    }
})
```

You can access `FirebaseDynamicRoot`'s items in two ways: like an **array** or like a **dictionary**.

If you access the dynamic root as an **array**, you will have access to two properties, `key` and `value`:

```swift
let decoded = try! JSONDecoder().decode(FirebaseDynamicRoot<Chat>.self, from: data)

print(decoded[0].key)
// one

print(decoded[0].value)
// Chat(title: "Historical Tech Pioneers", lastMessage: "ghopper: Relay malfunction found. Cause: moth.", timestamp: 48246-05-04 10:47:46 +0000)

```

When you access the dynamic root as a **dictionary**, you get the value right away:
```swift
let decoded = try! JSONDecoder().decode(FirebaseDynamicRoot<Chat>.self, from: data)

print(decoded["one"])
// Chat(title: "Historical Tech Pioneers", lastMessage: "ghopper: Relay malfunction found. Cause: moth.", timestamp: 48246-05-04 10:47:46 +0000)

```
Be mindful that the access time of using it as a dictionary is O(n), since it's internally stored as an array. 
Accessing the dynamic root is more performant if accessed like an array, which is O(1).

#### Parsing root with fixed keys, composed of an array of objects

Take this json example from Firebase:

```json
{
  "chats": {
    "one": {
      "title": "Historical Tech Pioneers",
      "lastMessage": "ghopper: Relay malfunction found. Cause: moth.",
      "timestamp": 1459361875666
    },
    "two": {
      "title": "...",
      "lastMessage": "...",
      "timestamp": ...
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
    },
    "two": {
      "m2": {
        "name": "...",
        "message": "...",
        "timestamp": ...
      }
    }
  }
}
```

The main difference in this example, is that its root has **fixed** keys, instead of **dynamic** ones.
In addition to that, each fixed key has **dynamic** children. In other words, each key has what we would
consider an array of objects in a tipical json.

Take Chats for instance. The root key is a fixed **chats**, which holds **dynamic keys** 
that could be interpreted as an array of chat objects, where each key is a chat identifier.
In this situation, we can define our chat object as a `DynamicChildrenArray`.

That's how we can parse it:

```swift
struct Chat: Codable {
    let title: String
    let lastMessage: String
    let timestamp: Date
}

struct Root: Codable {
    let chats: DynamicChildrenArray<Chat>
}
```

```swift
chatsReference.observe(DataEventType.value, with: { [weak self] snapshot in
    guard let dictionary = snapshot.value as? NSDictionary else { return }
    
    let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
    
    let decoded = try! JSONDecoder().decode(Root<Chat>.self, from: data)

    let chatOne = decoded.chats[0]
    
    print(chatOne.key)
    // one
    
    print(chatOne.value)
    // Chat(title: "Historical Tech Pioneers", lastMessage: "ghopper: Relay malfunction found. Cause: moth.", timestamp: 48246-05-04 10:47:46 +0000)
})
```

Alternatively, you can directly access the value by using the key:

```swift
let decoded = try! JSONDecoder().decode(Root<Chat>.self, from: data)

let chatOneValue = decoded.chats["one"]

print(chatOneValue)
// Chat(title: "Historical Tech Pioneers", lastMessage: "ghopper: Relay malfunction found. Cause: moth.", timestamp: 48246-05-04 10:47:46 +0000)
```

#### Parsing nested objects

Following the same principle, we can parse **nested dynamic keys** like the **messages** object as simple as that:

```swift
struct Message: Codable {
    let name: String
    let message: String
    let timestamp: Date
}

struct Root: Codable {
    ...
    let messages: DynamicChildrenArray<DynamicChildrenArray<Message>>
}

```

Then:
```swift
let decoded = try! JSONDecoder().decode(Root<Chat>.self, from: data)

let m1 = decoded.messages[0].value[0]

print(m1.key)
// m1

print(m1.value)
// Message(name: "eclarke", message: "The relay seems to be malfunctioning.", timestamp: 48246-05-04 10:42:17 +0000)
```

Or accessing the keys:
```swift
let decoded = try! JSONDecoder().decode(Root<Chat>.self, from: data)

let m1Value = result.messages["one"]!["m1"]!

print(m1Value)
// Message(name: "eclarke", message: "The relay seems to be malfunctioning.", timestamp: 48246-05-04 10:42:17 +0000)
```
