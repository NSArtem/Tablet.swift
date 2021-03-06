//
//    Copyright (c) 2015 Max Sokolov https://twitter.com/max_sokolov
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import Foundation

public typealias ReturnValue = AnyObject?

enum ActionHandler<DataType, CellType> {

    case Handler((data: ActionData<DataType, CellType>) -> Void)
    case ValueHandler((data: ActionData<DataType, CellType>) -> AnyObject?)

    func invoke(data: ActionData<DataType, CellType>) -> ReturnValue {

        switch (self) {
        case .Handler(let handler):
            handler(data: data)
            return nil
        case .ValueHandler(let handler):
            return handler(data: data)
        }
    }
}

public protocol RowBuilder {
    
    var reusableIdentifier: String { get }
    var numberOfRows: Int { get }
    var estimatedRowHeight: Float { get }
    
    func invoke(action action: ActionType, cell: UITableViewCell?, indexPath: NSIndexPath, itemIndex: Int, userInfo: [NSObject: AnyObject]?) -> AnyObject?
    func registerCell(inTableView tableView: UITableView)
}

/**
 Responsible for building cells of given type and passing items to them.
 */
public class TableBaseRowBuilder<DataType, CellType where CellType: UITableViewCell> : RowBuilder {
    
    private var actions = [String: ActionHandler<DataType, CellType>]()
    private var items = [DataType]()
    
    public let reusableIdentifier: String
    
    public var numberOfRows: Int {
        return items.count
    }
    
    public var estimatedRowHeight: Float {
        return 44
    }
    
    public init(item: DataType, id: String? = nil) {

        reusableIdentifier = id ?? String(CellType)
        items.append(item)
    }
    
    public init(items: [DataType]? = nil, id: String? = nil) {

        reusableIdentifier = id ?? String(CellType)

        if let items = items {
            self.items.appendContentsOf(items)
        }
    }
    
    // MARK: - Chaining actions -
    
    public func action(key: String, handler: (data: ActionData<DataType, CellType>) -> Void) -> Self {
        
        actions[key] = .Handler(handler)
        return self
    }
    
    public func action(type: ActionType, handler: (data: ActionData<DataType, CellType>) -> Void) -> Self {

        actions[type.key] = .Handler(handler)
        return self
    }
    
    public func valueAction(type: ActionType, handler: (data: ActionData<DataType, CellType>) -> ReturnValue) -> Self {
        
        actions[type.key] = .ValueHandler(handler)
        return self
    }

    public func invoke(action action: ActionType, cell: UITableViewCell?, indexPath: NSIndexPath, itemIndex: Int, userInfo: [NSObject: AnyObject]?) -> AnyObject? {
        
        if let action = actions[action.key] {
            return action.invoke(ActionData(cell: cell as? CellType, indexPath: indexPath, item: items[itemIndex], itemIndex: itemIndex, userInfo: userInfo))
        }
        return nil
    }
    
    public func registerCell(inTableView tableView: UITableView) {
        
        if tableView.dequeueReusableCellWithIdentifier(reusableIdentifier) != nil {
            return
        }
        
        let resource = String(CellType)
        let bundle = NSBundle(forClass: CellType.self)
        
        if let _ = bundle.pathForResource(resource, ofType: "nib") { // existing cell
            tableView.registerNib(UINib(nibName: resource, bundle: bundle), forCellReuseIdentifier: reusableIdentifier)
        } else {
            tableView.registerClass(CellType.self, forCellReuseIdentifier: reusableIdentifier)
        }
    }
    
    // MARK: - Items manipulation -
    
    public func append(items items: [DataType]) {
        self.items.appendContentsOf(items)
    }
    
    public func clear() {
        items.removeAll()
    }
}

/**
 Responsible for building configurable cells of given type and passing items to them.
 */
public class TableRowBuilder<DataType, CellType: ConfigurableCell where CellType.T == DataType, CellType: UITableViewCell> : TableBaseRowBuilder<DataType, CellType> {
    
    public override var estimatedRowHeight: Float {
        return CellType.estimatedHeight()
    }

    public init(item: DataType) {
        super.init(item: item, id: CellType.reusableIdentifier())
    }

    public init(items: [DataType]? = nil) {
        super.init(items: items, id: CellType.reusableIdentifier())
    }

    public override func invoke(action action: ActionType, cell: UITableViewCell?, indexPath: NSIndexPath, itemIndex: Int, userInfo: [NSObject: AnyObject]?) -> AnyObject? {
        
        if case .configure = action {
            (cell as? CellType)?.configure(items[itemIndex])
        }
        return super.invoke(action: action, cell: cell, indexPath: indexPath, itemIndex: itemIndex, userInfo: userInfo)
    }
}

public func +=<DataType, CellType>(left: TableBaseRowBuilder<DataType, CellType>, right: DataType) {
    left.append(items: [right])
}

public func +=<DataType, CellType>(left: TableBaseRowBuilder<DataType, CellType>, right: [DataType]) {
    left.append(items: right)
}