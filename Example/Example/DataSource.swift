//
//  DataSource.swift
//  GraphLayout
//
//  Copyright © 2018 bakhtiyor.com. MIT License
//

import GraphvizSDK
import Foundation

class DataSource {
    static func createGraphFromString() -> Graph {
        Graph(str: """
            digraph G {
              edge [dir=none];
              node [shape=box];
              graph [splines=ortho];

              "Herb"      [shape=box, regular=0, color="blue", style="filled" fillcolor="lightblue"] ;
              "Homer"     [shape=box, regular=0, color="blue", style="bold, filled" fillcolor="lightblue"] ;
              "Abraham"   [shape=box, regular=0, color="blue", style="filled" fillcolor="lightblue"] ;
              "Mona"      [shape=oval, regular=0, color="red", style="filled" fillcolor="pink"] ;
              
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
            """)
    }
    
    static func createGraph() -> Graph {
        let graph: Graph = Graph()
        graph.splines = .spline
        let persons = personsPreview
        persons.forEach {
            let node = graph.addNode($0.name)
            node.shape = .box
            node.style = .rounded
        }
        var partnersEdded: Set<PersonId> = []
        
        persons.forEach { person in
            person.children.forEach { childId in
                guard let child = persons.first(where: { $0.id == childId }),
                      let from = graph.nodes.first(where: { $0.label == person.name }),
                      let to = graph.nodes.first(where: { $0.label == child.name }) else {
                    return
                }
                let edge = graph.addEdge(from: from, to: to)
                edge.setNoDirection()
            }
            
            person.partners.forEach { partnerId in
                guard !partnersEdded.contains(partnerId) else { return }
                partnersEdded.insert(partnerId)
                partnersEdded.insert(person.id)
                let partner = persons.first(where: { $0.id == partnerId })!
//                let from = graph.nodes.first(where: { $0.label == person.name })!
//                let to = graph.nodes.first(where: { $0.label == partner.name })!
                
                let diamondName = "diamond_\(arc4random())"
                let diamond = graph.addNode(diamondName)
                diamond.label = ""
                diamond.shape = .diamond
//                diamond.width = 0.25
//                diamond.height = 0.25
                
//                let edgeFrom = graph.addEdge(from: from, to: diamond)
//                edgeFrom.color = .red
//                
//                let edgeTo = graph.addEdge(from: diamond, to: to)
//                edgeTo.color = .red
                graph.setSameRank(nodes: [person.name, partner.name])
                
                let subgraph = graph//.createSubgraph()
                let from = subgraph.addNode(person.name)
                let diamondNode = subgraph.addNode(diamondName)
                diamondNode.label = ""
                diamondNode.shape = .diamond
                diamondNode.width = 0.25
                diamondNode.height = 0.25
                let to = subgraph.addNode(partner.name)
                subgraph.addEdge(from: from, to: diamondNode).setNoDirection()
                subgraph.addEdge(from: diamondNode, to: to).setNoDirection()
            }
        }
//        let node1 = graph.addNode("The quick\nbrown fox jumps\nover the lazy\ndog")
//        let node2 = graph.addNode("node 2")
//        let node3 = graph.addNode("node 3")
//        let node4 = graph.addNode("node\n4")
//        let node5 = graph.addNode("A picture\nis worth\na thousand\nwords")
//        let node6 = graph.addNode("node 6")
//        let node7 = graph.addNode("node \n 7")
//        let node8 = graph.addNode("node 8")
//        let node9 = graph.addNode("node 9")
//        let node10 = graph.addNode("node \n 10")
//        let node11 = graph.addNode("node 11")
//        let node12 = graph.addNode("node \n 12")
//        let node13 = graph.addNode("node 13")
//        let node14 = graph.addNode("node \n 14")
//        let node15 = graph.addNode("node 15")
//        _ = graph.addEdge(from: node1, to: node2)
//        _ = graph.addEdge(from: node1, to: node5)
//        _ = graph.addEdge(from: node3, to: node4)
//        _ = graph.addEdge(from: node2, to: node3)
//        _ = graph.addEdge(from: node4, to: node5)
//        _ = graph.addEdge(from: node3, to: node5)
//        _ = graph.addEdge(from: node6, to: node7)
//        _ = graph.addEdge(from: node7, to: node8)
//        _ = graph.addEdge(from: node8, to: node9)
//        _ = graph.addEdge(from: node9, to: node10)
//        _ = graph.addEdge(from: node1, to: node10)
//        _ = graph.addEdge(from: node5, to: node10)
//        _ = graph.addEdge(from: node5, to: node6)
//        _ = graph.addEdge(from: node6, to: node5)
//        let e1_8 = graph.addEdge(from: node1, to: node8)
//
//        _ = graph.addEdge(from: node8, to: node1)
//        let e3_10 = graph.addEdge(from: node3, to: node10)
//        _ = graph.addEdge(from: node4, to: node9)
//        _ = graph.addEdge(from: node3, to: node7)
//        _ = graph.addEdge(from: node2, to: node8)
//        _ = graph.addEdge(from: node4, to: node8)
//        _ = graph.addEdge(from: node5, to: node7)
//        _ = graph.addEdge(from: node5, to: node5)
//
//        _ = graph.addEdge(from: node11, to: node12)
//        _ = graph.addEdge(from: node12, to: node15)
//        _ = graph.addEdge(from: node11, to: node13)
//        _ = graph.addEdge(from: node15, to: node14)
//        _ = graph.addEdge(from: node15, to: node11)
//        _ = graph.addEdge(from: node11, to: node1)
//        _ = graph.addEdge(from: node12, to: node1)
//        _ = graph.addEdge(from: node10, to: node15)
//        _ = graph.addEdge(from: node13, to: node6)
//        let e9_1 = graph.addEdge(from: node9, to: node1)
//        _ = graph.addEdge(from: node9, to: node11)
//        _ = graph.addEdge(from: node13, to: node3)
//        node2.shape = .box
//        node4.shape = .hexagon
//        node1.color = UIColor.yellow
//        node3.fontSize = 24
//        node3.textColor = UIColor.blue
//
//        e9_1.color = UIColor.red
//        e3_10.color = UIColor.green
//        e1_8.weight = 10
//        e1_8.width = 2
//        e3_10.weight = 50
//        e3_10.width = 3
//        e9_1.weight = 100
//        e9_1.width = 4

        return graph
    }
}

public typealias PersonId = Int
public typealias PersonLevel = Int

public struct Person: Identifiable, Sendable, Hashable, Codable {
    public let id: PersonId
    public let name: String
    public var parents: [PersonId]
    public var partners: [PersonId]
    public var children: [PersonId]
    public var position: CGPoint = .zero // Для позиции на канвасе
    public let gender: Gender
    
    public enum Gender: String, Codable, Sendable {
        case male, female
    }
    
    public init(
        id: PersonId,
        name: String,
        parents: [PersonId],
        partners: [PersonId],
        children: [PersonId],
        gender: Gender
    ) {
        self.id = id
        self.name = name
        self.parents = parents
        self.partners = partners
        self.children = children
        self.gender = gender
    }
}

let personsPreview: [Person] = [
    Person(id:  1, name: "Me", parents: [8,9], partners:[2,3], children: [4, 5], gender: .male),
    Person(id:  2, name: "Mistress", parents: [], partners: [1], children: [4], gender: .female),
    Person(id:  3, name: "Wife", parents: [], partners: [1], children: [5], gender: .female),
    Person(id:  4, name: "Son", parents: [1,2], partners: [], children: [], gender: .male),
    Person(id:  5, name: "Daughter", parents: [1,3], partners:[6], children: [7], gender: .female),
    Person(id:  6, name: "Boyfriend", parents: [], partners:[5], children: [7], gender: .male),
    Person(id:  7, name: "Son Lat", parents: [5,6], partners:[], children: [], gender: .male),
    Person(id:  8, name: "Jeff", parents: [10,11], partners:[9], children: [], gender: .male),
    Person(id:  9, name: "Maggie", parents: [13,14], partners:[8], children: [1], gender: .female),
    Person(id: 10, name: "Bob", parents: [12], partners:[11], children: [8], gender: .male),
    Person(id: 11, name: "Mary", parents: [], partners:[10,14], children: [8], gender: .female),
    Person(id: 12, name: "John", parents: [], partners:[], children: [10], gender: .male),
    Person(id: 13, name: "Robert", parents: [], partners:[14,10], children: [9], gender: .male),
    Person(id: 14, name: "Jessie", parents: [15,16], partners:[13], children: [9], gender: .female),
    Person(id: 15, name: "Raymond", parents: [], partners:[16], children: [14], gender: .male),
    Person(id: 16, name: "Betty", parents: [], partners:[15], children: [14], gender: .female),
]
