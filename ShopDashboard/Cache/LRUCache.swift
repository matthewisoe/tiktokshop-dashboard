// LRUCache.swift
// Generic thread-safe LRU cache using doubly-linked list + hash map.
// O(1) get and set. NSLock for concurrent access.

import Foundation

final class LRUCache<Key: Hashable, Value> {

    // MARK: - Private node
    private class Node {
        let key: Key
        var value: Value
        var prev: Node?
        var next: Node?
        init(key: Key, value: Value) {
            self.key   = key
            self.value = value
        }
    }

    // MARK: - Properties
    private let capacity: Int
    private var cache: [Key: Node] = [:]
    private let lock = NSLock()

    // Use Optional sentinel nodes instead of force-cast sentinels
    private var head: Node?   // most recently used end
    private var tail: Node?   // least recently used end

    // MARK: - Init
    init(capacity: Int) {
        precondition(capacity > 0, "LRUCache capacity must be > 0")
        self.capacity = capacity
    }

    // MARK: - Public API

    func get(_ key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        guard let node = cache[key] else { return nil }
        moveToHead(node)
        return node.value
    }

    func set(_ key: Key, value: Value) {
        lock.lock()
        defer { lock.unlock() }
        if let node = cache[key] {
            node.value = value
            moveToHead(node)
        } else {
            let node = Node(key: key, value: value)
            cache[key] = node
            addToHead(node)
            if cache.count > capacity {
                if let lru = removeTail() {
                    cache.removeValue(forKey: lru.key)
                }
            }
        }
    }

    func remove(_ key: Key) {
        lock.lock()
        defer { lock.unlock() }
        guard let node = cache[key] else { return }
        removeNode(node)
        cache.removeValue(forKey: key)
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
        head = nil
        tail = nil
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return cache.count
    }

    // MARK: - Private linked list helpers

    private func addToHead(_ node: Node) {
        node.prev = nil
        node.next = head
        head?.prev = node
        head = node
        if tail == nil { tail = node }
    }

    private func removeNode(_ node: Node) {
        node.prev?.next = node.next
        node.next?.prev = node.prev
        if head === node { head = node.next }
        if tail === node { tail = node.prev }
        node.prev = nil
        node.next = nil
    }

    private func moveToHead(_ node: Node) {
        guard head !== node else { return }
        removeNode(node)
        addToHead(node)
    }

    private func removeTail() -> Node? {
        guard let lru = tail else { return nil }
        removeNode(lru)
        return lru
    }
}
