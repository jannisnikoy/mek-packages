import Foundation
import StripeTerminal
import Flutter

class DiscoveryDelegatePlugin: DiscoverReadersStreamHandler {
    private var _sink: PigeonEventSink<[ReaderApi]>? = nil
    private var _delegate: DiscoveryDelegateHandler? = nil
    private var _cancelable: Cancelable? = nil
    private var _readers: [Reader] = []
    var configuration: DiscoveryConfiguration? = nil

    var readers: [Reader] { get {
        return _readers
    } }
    
    func clear() {
        self._cancel()
        self._readers = []
    }
    
    @objc func terminal(_ terminal: Terminal, didUpdateDiscoveredReaders readers: [Reader]) {
        DispatchQueue.main.async {
            self._readers = readers
            self._sink?.success(readers.map { $0.toApi() })
        }
    }
    
    override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<[ReaderApi]>) {
        self._cancel()
        
        guard let configuration else {
            sink.addError(
                createApiException(
                    TerminalExceptionCodeApi.unknown,
                    "DiscoveryConfiguration not supported"
                ).toPlatformError()
            )
            self._sink?.endOfStream()
            self._sink = nil
            return;
        }
        
        _delegate = DiscoveryDelegateHandler(delegate: self)
         
        self._cancelable = Terminal.shared.discoverReaders(
            configuration,
            delegate: _delegate!
        ) { error in
            self._cancelable = nil
            DispatchQueue.main.async {
                if let error = error as? NSError {
                    let exception = error.toApi()
                    if (exception.code == TerminalExceptionCodeApi.canceled) {
                        self._cancel()
                        return;
                    }
                    self._sink?.addError(exception.toPlatformError())
                }
                
                self._sink?.endOfStream()
                self._sink = nil
            }
        }
        self._sink = sink
    }
    
    override func onCancel(withArguments arguments: Any?) {
        self._cancel()
    }
    
    private func _cancel() {
        self._sink?.endOfStream()
        self._sink = nil
        self._delegate = nil
        // Ignore error, the previous stream can no longer receive events
        self._cancelable?.cancel { error in }
        self._cancelable = nil
    }
}

private class DiscoveryDelegateHandler : NSObject, DiscoveryDelegate {
    let _delegate: DiscoveryDelegatePlugin

    init(delegate: DiscoveryDelegatePlugin) {
        self._delegate = delegate
    }
    
    func terminal(_ terminal: Terminal, didUpdateDiscoveredReaders readers: [Reader]) {
        _delegate.terminal(terminal, didUpdateDiscoveredReaders: readers)
    }
}
