# NetTrace

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.10+-orange.svg" />
  <img src="https://img.shields.io/badge/iOS-15.0+-blue.svg" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" />
</p>

iOS network debugging framework with real-time monitoring, JSON tree viewer, and request inspection.

## Features

- Real-time network monitoring - automatically intercepts all `URLSession` requests
- Detailed request/response inspection - headers, body, status codes, timing
- Interactive JSON tree viewer with expand/collapse
-  Search and filter by URL, method, or status code
- Copy JSON responses to clipboard
- Color-coded status indicators
- Non-intrusive floating button overlay
- HAR files export functionality to save the list and a single viewed request.

## Installation

### Swift Package Manager

In Xcode, go to **File** → **Add Package Dependencies** and enter:
```
https://github.com/theCodingDJ/NetTrace.git
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/theCodingDJ/NetTrace.git", from: "1.1.0")
]
```

Then add to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["NetTrace"]
)
```

## Quick Start
Add the following into your *AppDelegate*:
```swift
import NetTrace

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

#if DEBUG
	NetTrace.shared.start()
#endif

	/// Other initialization code here.
	return true
}
```

## HAR Export
NetTrace has the capability to export [HAR files](https://en.wikipedia.org/wiki/HAR_(file_format)) to share with backend developers, or view with Charles Proxy/Postman/Proxyman.
> [!TIP]
> When working with iPhone Simulator, to find your stored `.har` files open your Terminal,
> run `cd ~/Library/Developer/CoreSimulator/Devices/<Simulator UDID>` (you can find your Simulator's UDID in **Xcode** → **Window menu** → **Devices & Simulators**), then run the following command in your Terminal: `find . -name '*.har'`.

## Available Functions

### `NetTrace.shared.start()`
Initializes NetTrace and displays the floating overlay button.

```swift
#if DEBUG
NetTrace.shared.start()
#endif
```

---

### `NetTrace.shared.show()`
Shows the overlay button if previously hidden.

```swift
NetTrace.shared.show()
```

---

### `NetTrace.shared.hide()`
Hides the overlay button.

```swift
NetTrace.shared.hide()
```

---

### `NetRecorder.shared.clear()`
Clears all logged requests.

```swift
NetRecorder.shared.clear()
```

---

### `NetRecorder.shared.findRequests(where:)`
Filters requests using complex logic.

```swift
let apiRequests = NetRecorder.shared.findRequests { request in
	request.response?.statusCode == 404 && request.method == "POST"
}
```

---

### `NetRecorder.shared.findRequests(byPath:)`
Filters requests by URL path.

```swift
let apiRequests = NetRecorder.shared.findRequests(byPath: "/api")
```

---

### `NetRecorder.shared.findRequests(byStatusCode:)`
Filters requests by HTTP status code.

```swift
let errors = NetRecorder.shared.findRequests(byStatusCode: 404)
```

---

### `NetRecorder.shared.findRequests(byMethod:)`
Filters requests by HTTP method.

```swift
let postRequests = NetRecorder.shared.findRequests(byMethod: "POST")
```

## License

MIT License
