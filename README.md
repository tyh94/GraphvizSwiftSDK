> 🇷🇺 [Read in Russian](README.ru.md)

# GraphvizSDK

**GraphvizSDK** is a Swift wrapper for the popular [Graphviz](https://graphviz.gitlab.io/) C/C++ library.
This package allows you to build, configure, and visualize graphs in Swift projects (iOS, macOS, etc.) using the power of the original Graphviz.

---

## Features

- Create and configure graphs, nodes, edges, and subgraphs in Swift
- Visualize graphs with SwiftUI (`GraphCanvasView`)
- Flexible Graphviz parameter configuration via Swift API
- Snapshot testing and preview support

---

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/YOUR-USERNAME/GraphvizSDK.git", from: "1.0.0"),
```

or via Xcode:
**File → Add Packages...** and paste the repository URL.

---

## Usage

```swift
import GraphvizSDK

let graph = Graph(name: "MyGraph", type: .nonStrictDirected)
let nodeA = Node(parent: graph.graph, name: "A")
let nodeB = Node(parent: graph.graph, name: "B")
graph.append(nodeA)
graph.append(nodeB)
let edge = Edge(parent: graph.graph, from: nodeA, to: nodeB)
graph.append(edge)
```

For SwiftUI visualization:

```swift
let renderer = RendererSwiftUI(layout: .dot)
let graphUI = try renderer.layout(graph: graph)
GraphCanvasView(graph: graphUI)
```

---

## Requirements

- Swift 5.9+
- iOS 18.0+ / macOS 14.0+
- [Graphviz](https://graphviz.gitlab.io/) (C/C++ library, included in the package)

---

## Testing

The repository includes unit and snapshot tests for core components.
For snapshot testing, [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) is used.

---

## Links

- Original Graphviz: [https://graphviz.gitlab.io/](https://graphviz.gitlab.io/)
- SnapshotTesting repo: [https://github.com/pointfreeco/swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing)

---

## License

MIT

---

## Graphviz C/C++ version

This package uses Graphviz sources at commit [ee78e077ce5fcc7ec6f3b2a81a002333e3453ef2](https://gitlab.com/graphviz/graphviz/-/commit/ee78e077ce5fcc7ec6f3b2a81a002333e3453ef2).

---
