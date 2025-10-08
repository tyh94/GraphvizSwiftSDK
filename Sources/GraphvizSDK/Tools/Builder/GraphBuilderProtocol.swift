//
//  GraphBuilderProtocol.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 13.05.2025.
//

public protocol GraphBuilderProtocol {
    @discardableResult
    func node(_ builder: (NodeBuilder) -> NodeBuilder) -> NodeBuilder
    
    @discardableResult
    func edge(
        source: NodeBuilder,
        targer: NodeBuilder,
        _ builder: (EdgeBuilder) -> EdgeBuilder
    ) -> EdgeBuilder
    
    @discardableResult
    func subgraph(_ builder: (SubgraphBuilder) -> SubgraphBuilder) -> SubgraphBuilder 
}
