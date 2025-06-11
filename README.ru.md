> 🇬🇧 [Read in English](README.md)

# GraphvizSDK

**GraphvizSDK** — это Swift-обёртка для популярной библиотеки визуализации графов [Graphviz](https://graphviz.gitlab.io/) (реализованной на C/C++).
Данный пакет позволяет удобно строить, настраивать и визуализировать графы в Swift-проектах (iOS, macOS и др.), используя мощь оригинального Graphviz.

---

## Возможности

- Создание и настройка графов, узлов, рёбер и подграфов на Swift
- Визуализация графов с помощью SwiftUI (например, через `GraphCanvasView`)
- Гибкая настройка параметров Graphviz через Swift API
- Поддержка снепшот-тестирования и превью

---

## Установка

### Swift Package Manager

Добавьте зависимость в ваш `Package.swift`:

```swift
.package(url: "https://github.com/ВАШ-ЮЗЕРНЕЙМ/GraphvizSDK.git", from: "1.0.0"),
```

или через Xcode:
**File → Add Packages...** и вставьте ссылку на репозиторий.

---

## Использование

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

Для визуализации в SwiftUI:

```swift
let renderer = RendererSwiftUI(layout: .dot)
let graphUI = try renderer.layout(graph: graph)
GraphCanvasView(graph: graphUI)
```

---

## Требования

- Swift 5.9+
- iOS 18.0+ / macOS 14.0+
- [Graphviz](https://graphviz.gitlab.io/) (C/C++ библиотека, включена в пакет)

---

## Версия Graphviz C/C++

В этом пакете используются исходники Graphviz на коммите [ee78e077ce5fcc7ec6f3b2a81a002333e3453ef2](https://gitlab.com/graphviz/graphviz/-/commit/ee78e077ce5fcc7ec6f3b2a81a002333e3453ef2).

---

## Тестирование

В репозитории есть юнит- и снепшот-тесты для основных компонентов.
Для снепшот-тестирования используется [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing).

---

## Ссылки

- Оригинальный Graphviz: [https://graphviz.gitlab.io/](https://graphviz.gitlab.io/)
- Репозиторий SnapshotTesting: [https://github.com/pointfreeco/swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing)

---

## Лицензия

MIT 