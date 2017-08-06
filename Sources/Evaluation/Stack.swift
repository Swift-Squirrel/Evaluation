//
//  Stack.swift
//  Evaluation
//
//  Created by Filip Klembara on 8/5/17.
//
//

class Stack<T> {
    private var items: Array<T>
    
    init() {
        items = [T]()
    }
    
    func push(item: T) {
        items.append(item)
    }

    @discardableResult
    func pop() -> T? {
        if !isEmpty() {
            return items.removeLast()
        }
        return nil
    }
    
    func top() -> T? {
        if !isEmpty() {
            return items.last
        }
        return nil
    }

    var count: Int {
        return items.count
    }
    
    func isEmpty() -> Bool {
        return items.isEmpty
    }
}
