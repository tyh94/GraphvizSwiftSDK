import Foundation

public func graphBuilder() -> Graph {
    let builder = GraphBuilder()
    let node1 = builder.node { node in
        node.with(shape: .box)
            .with(label: "test")
    }
    let node2 = builder.node { nodeBuilder in
        nodeBuilder.with(shape: .egg)
            .with(label: "test2")
    }
    builder.edge(source: node1, targer: node2) { edgeBuilder in
        edgeBuilder
    }
    let subgraphBuilder = builder.subgraph { subgraphBuilder in
        subgraphBuilder
            .with(name: "sub")
            .with(rank: .same)
    }
    let nodeAbraharm = subgraphBuilder.node { nodeBuilder in
        nodeBuilder.with(label: "Abraham")
    }
    let nodeMona = subgraphBuilder.node { nodeBuilder in
        nodeBuilder.with(label: "Mona")
    }
    let nodeDiamond = subgraphBuilder.node { nodeBuilder in
        nodeBuilder.with(label: "")
            .with(shape: .diamond)
    }
    subgraphBuilder
        .edge(
            source: nodeAbraharm,
            targer: nodeDiamond) { edgeBuilder in
                edgeBuilder
            }
    subgraphBuilder
        .edge(
            source: nodeDiamond,
            targer: nodeMona) { edgeBuilder in
                edgeBuilder
            }
    builder.edge(source: node2, targer: nodeDiamond) { $0 }
    return builder.build()
}

public func rankStrGraph() -> Graph {
    GraphBuilderFromString.build(str:
        """
        digraph G {
                  edge [dir=none];
                  node [shape=box];
                  graph [splines=ortho];
        
                  "Herb"      [shape=parallelogram, regular=0, color="blue", style="filled" fillcolor="lightblue"] ;
                  "Homer"     [shape=parallelogram, regular=0, color="blue", style="bold, filled" fillcolor="lightblue"] ;
                  "Abraham"   [shape=parallelogram, regular=0, color="blue", style="filled" fillcolor="lightblue"] ;
                  "Mona"      [shape=egg, regular=0, color="red", style="filled" fillcolor="pink"] ;
                  
                  a1 [shape=diamond,label="",height=0.25,width=0.25];
                  b1 [shape=circle,label="",height=0.01,width=0.01];
                  b2 [shape=circle,label="",height=0.01,width=0.01];
                  b3 [shape=circle,label="",height=0.01,width=0.01];
                  a1 -> b2
                  b1 -> Herb
                  b3 -> Homer
                  {rank=same; Abraham -> a1 -> Mona};
                  {rank=same; b1 -> b2 -> b3}
                  {rank=same; Herb; Homer};
                }
        """
    )
}

public func rankGraph() -> Graph {
    let graph = GraphBuilder()
    let subgraph = graph.subgraph { $0.with(name: "sub").with(rank: .same) }
    let abraham = subgraph.node {
        $0.with(label: "Abraham")
    }
    let mona = subgraph.node {
        $0.with(label: "Mona")
    }
    let diamond = subgraph.node {
        $0.with(label: "")
            .with(shape: .diamond)
    }
    subgraph.edge(source: abraham, targer: diamond, { $0 })
    subgraph.edge(source: diamond, targer: mona, { $0 })
    return graph.build()
}

public func demoGraph() -> Graph {
    let graph = GraphBuilder()
    let node1 = graph.node {
        $0.with(label: "The quick\nbrown fox jumps\nover the lazy\ndog")
            .with(shape: .egg)
    }
    let node2 = graph.node {
        $0.with(label: "node 2")
            .with(shape: .egg)
    }
    let node3 = graph.node {
        $0.with(label: "node 3")
    }
    let node4 = graph.node {
        $0.with(label: "node\n4")
            .with(shape: .hexagon)
    }
    let node5 = graph.node {
        $0.with(label: "A picture\nis worth\na thousand\nwords")
    }
    let node6 = graph.node {
        $0.with(label: "node 6")
    }
    let node7 = graph.node {
        $0.with(label: "node \n 7")
    }
    let node8 = graph.node {
        $0.with(label: "node 8")
    }
    let node9 = graph.node {
        $0.with(label: "node 9")
    }
    let node10 = graph.node {
        $0.with(label: "node \n 10")
    }
    let node11 = graph.node {
        $0.with(label: "node 11")
    }
    let node12 = graph.node {
        $0.with(label: "node \n 12")
    }
    let node13 = graph.node {
        $0.with(label: "node 13")
    }
    let node14 = graph.node {
        $0.with(label: "node \n 14")
    }
    let node15 = graph.node {
        $0.with(label: "node 15")
    }
    graph.edge(source: node1, targer: node2, { $0 })
    graph.edge(source: node1, targer: node2, { $0 })
    graph.edge(source: node1, targer: node5, { $0 })
    graph.edge(source: node3, targer: node4, { $0 })
    graph.edge(source: node2, targer: node3, { $0 })
    graph.edge(source: node4, targer: node5, { $0 })
    graph.edge(source: node3, targer: node5, { $0 })
    graph.edge(source: node6, targer: node7, { $0 })
    graph.edge(source: node7, targer: node8, { $0 })
    graph.edge(source: node8, targer: node9, { $0 })
    graph.edge(source: node9, targer: node10, { $0 })
    graph.edge(source: node1, targer: node10, { $0 })
    graph.edge(source: node5, targer: node10, { $0 })
    graph.edge(source: node5, targer: node6, { $0 })
    graph.edge(source: node6, targer: node5, { $0 })
    graph.edge(source: node1, targer: node8, {
        $0
    })
    graph.edge(source: node8, targer: node1, { $0 })
    graph.edge(source: node3, targer: node10, {
        $0
    })
    graph.edge(source: node4, targer: node9, { $0 })
    graph.edge(source: node3, targer: node7, { $0 })
    graph.edge(source: node2, targer: node8, { $0 })
    graph.edge(source: node4, targer: node8, { $0 })
    graph.edge(source: node5, targer: node7, { $0 })
    graph.edge(source: node5, targer: node5, { $0 })
    graph.edge(source: node11, targer: node12, { $0 })
    graph.edge(source: node12, targer: node15, { $0 })
    graph.edge(source: node11, targer: node13, { $0 })
    graph.edge(source: node15, targer: node14, { $0 })
    graph.edge(source: node15, targer: node11, { $0 })
    graph.edge(source: node11, targer: node1, { $0 })
    graph.edge(source: node12, targer: node1, { $0 })
    graph.edge(source: node10, targer: node15, { $0 })
    graph.edge(source: node13, targer: node6, { $0 })
    graph.edge(source: node9, targer: node1, {
        $0
    })
    graph.edge(source: node9, targer: node11, { $0 })
    graph.edge(source: node13, targer: node3, { $0 })
    return graph.build()
}