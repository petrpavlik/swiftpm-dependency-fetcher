import Node
import JSON

extension DependencyGraph {
    
    func asD3Deps() throws -> String {
        
        struct Link: NodeRepresentable {
            let source: String
            let dest: String
            
            fileprivate func makeNode() throws -> Node {
                return [
                    "source": source.makeNode(),
                    "dest": dest.makeNode()
                ]
            }
        }
        
        var links: [Link] = []
        for (name, pkg) in relationships {
            for dep in pkg.dependencies {
                links.append(Link(source: name, dest: dep))
            }
        }
        
        let node: Node = [
            "links": try links.makeNode()
        ]
        let jsonString = try node.jsonString()
        let out = "var dependencies = " + jsonString
        return out
    }
    
    func asD3Tree() throws -> String {
        
        struct TreeNode: NodeRepresentable {
            let name: String
            let children: [TreeNode]
            
            fileprivate func makeNode() throws -> Node {
                var node: Node = [
                    "name": name.makeNode()
                ]
                if !children.isEmpty {
                    node["children"] = .array(try children.converted())
                }
                return node
            }
        }
        
        func nodify(name: String) -> TreeNode {
            let pkg = relationships[name]!
            let deps = pkg.dependencies.map { return nodify(name: $0) }
            return TreeNode(name: name, children: deps)
        }
        
        let node = try nodify(name: root).makeNode()
        return try node.jsonString()
    }

}

