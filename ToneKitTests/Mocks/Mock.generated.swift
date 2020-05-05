// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT



// Generated with SwiftyMocky 3.5.0

import SwiftyMocky
#if !MockyCustom
import XCTest
#endif
import Metal
@testable import ToneKit


// MARK: - UniformBufferable
open class UniformBufferableMock: UniformBufferable, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }

    public var label: String? {
		get {	invocations.append(.p_label_get); return __p_label ?? optionalGivenGetterValue(.p_label_get, "UniformBufferableMock - stub value for label was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_label = newValue }
	}
	private var __p_label: (String)?

    public var bufferCount: Int {
		get {	invocations.append(.p_bufferCount_get); return __p_bufferCount ?? givenGetterValue(.p_bufferCount_get, "UniformBufferableMock - stub value for bufferCount was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_bufferCount = newValue }
	}
	private var __p_bufferCount: (Int)?

    public var bufferSize: Int {
		get {	invocations.append(.p_bufferSize_get); return __p_bufferSize ?? givenGetterValue(.p_bufferSize_get, "UniformBufferableMock - stub value for bufferSize was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_bufferSize = newValue }
	}
	private var __p_bufferSize: (Int)?

    public var nextAvailableBuffer: MTLBuffer {
		get {	invocations.append(.p_nextAvailableBuffer_get); return __p_nextAvailableBuffer ?? givenGetterValue(.p_nextAvailableBuffer_get, "UniformBufferableMock - stub value for nextAvailableBuffer was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_nextAvailableBuffer = newValue }
	}
	private var __p_nextAvailableBuffer: (MTLBuffer)?






    fileprivate enum MethodType {
        case p_label_get
        case p_bufferCount_get
        case p_bufferSize_get
        case p_nextAvailableBuffer_get

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.p_label_get,.p_label_get): return true
            case (.p_bufferCount_get,.p_bufferCount_get): return true
            case (.p_bufferSize_get,.p_bufferSize_get): return true
            case (.p_nextAvailableBuffer_get,.p_nextAvailableBuffer_get): return true
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case .p_label_get: return 0
            case .p_bufferCount_get: return 0
            case .p_bufferSize_get: return 0
            case .p_nextAvailableBuffer_get: return 0
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }

        public static func label(getter defaultValue: String?...) -> PropertyStub {
            return Given(method: .p_label_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func bufferCount(getter defaultValue: Int...) -> PropertyStub {
            return Given(method: .p_bufferCount_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func bufferSize(getter defaultValue: Int...) -> PropertyStub {
            return Given(method: .p_bufferSize_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func nextAvailableBuffer(getter defaultValue: MTLBuffer...) -> PropertyStub {
            return Given(method: .p_nextAvailableBuffer_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }

    }

    public struct Verify {
        fileprivate var method: MethodType

        public static var label: Verify { return Verify(method: .p_label_get) }
        public static var bufferCount: Verify { return Verify(method: .p_bufferCount_get) }
        public static var bufferSize: Verify { return Verify(method: .p_bufferSize_get) }
        public static var nextAvailableBuffer: Verify { return Verify(method: .p_nextAvailableBuffer_get) }
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

