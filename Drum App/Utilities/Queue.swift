//
//  Queue.swift
//  Drum App
//
//  Created by Oliver Li on 5/16/24.
//

import DequeModule

class Node<T> {
    var value: T
    var next: Node?

    init(value: T) {
        self.value = value
    }
}

struct Queue<T> {
    var head: Node<T>?
    var tail: Node<T>?

    mutating func enqueue(_ value: T) {
        let newNode = Node(value: value)
        if let tailNode = tail {
            tailNode.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
    }

    mutating func dequeue() -> T? {
        if let headNode = head {
            head = headNode.next
            if head == nil {
                tail = nil
            }
            return headNode.value
        } else {
            return nil
        }
    }

    func peek() -> T? {
        return head?.value
    }

    func peekBack() -> T? {
        return tail?.value
    }

    var isEmpty: Bool {
        return head == nil
    }
}
