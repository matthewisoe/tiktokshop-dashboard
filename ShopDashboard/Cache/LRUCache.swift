// LRUCache.swift
// Generic thread-safe LRU (Least Recently Used) cache.
// Same concept as Redis/Memcache — frequently accessed data stays
// in memory, reducing repeated expensive operations (DB reads, API calls).
//
// How it works:
//   - Backed by a doubly-linked list + dictionary (O(1) get and set)
//   - Most recently used item stays at the HEAD
//   - Least recently used item sits at the TAIL — evicted when capacity hit
//   - NSLock makes it safe for concurrent access from multiple threads
//
// Interview talking point:
//   "I implemented an LRU cache using a doubly-linked list and hash map
//    to get O(1) reads and writes, wrapped with NSLock for thread safety.
//    Cache hits skip the CoreData fetch entirely."

import Foundation

final class LRUCache<Key: Hashable, Value> {

    // MARK: - Private node (doubly-linked list)
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
    private let lock  = NSLock()

    // Sentinel head and tail nodes — simplify edge-case handling
    private let head = Node(key: "" as! Key, value: "" as! Value)
    private let tail = Node(key: "" as! Key, value: "" as! Value)

    // MARK: - Init
    init(capacity: Int) {
        precondition(capacity > 0, "LRUCache capacity must be > 0")
        self.capacity = capacity
        head.next = tail
        tail.prev = head
    }

    // MARK: - Public API

    /// Retrieve a value. Moves the node to head (most recently used).
    func get(_ key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }

        guard let node = cache[key] else { return nil }
        moveToHead(node)
        return node.value
    }

    /// Insert or update a value. Evicts LRU item if at capacity.
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

    /// Remove a specific key from cache (e.g. after data mutation)
    func remove(_ key: Key) {
        lock.lock()
        defer { lock.unlock() }

        guard let node = cache[key] else { return }
        removeNode(node)
        cache.removeValue(forKey: key)
    }

    /// Wipe entire cache — call after a full data refresh
    func clear() {
        lock.lock()
        defer { lock.unlock() }

        cache.removeAll()
        head.next = tail
        tail.prev = head
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return cache.count
    }

    // MARK: - Private linked list helpers

    private func addToHead(_ node: Node) {
        node.prev       = head
        node.next       = head.next
        head.next?.prev = node
        head.next       = node
    }

    private func removeNode(_ node: Node) {
        node.prev?.next = node.next
        node.next?.prev = node.prev
    }

    private func moveToHead(_ node: Node) {
        removeNode(node)
        addToHead(node)
    }

    private func removeTail() -> Node? {
        guard let lru = tail.prev, lru !== head else { return nil }
        removeNode(lru)
        return lru
    }
}
