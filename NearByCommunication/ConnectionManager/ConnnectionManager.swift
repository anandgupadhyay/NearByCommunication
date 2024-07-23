//
//  ConnnectionManager.swift
//  NearByCommunication
//
//  Created by Anand Upadhyay on 19/07/24.
//

import Foundation
import NearbyConnections

//extension String {
//    func toData() -> Data {
//        return Data(self.utf8)
//    }
//}
//
//extension Data {
//      func toString() -> String {
//          return String(decoding: self, as: UTF8.self)
//      }
//   }

//protocol TrackNearByConnectionDelegate {
//    func receivedMessage(message: String)
//    func connected(endppoint: EndpointID)
//}

class Example {
    static var shared = Example()
    let connectionManager: ConnectionManager!
    let advertiser: Advertiser?
    let discoverer: Discoverer?
//    var delegate:TrackNearByConnectionDelegate?
    init() {
        connectionManager = ConnectionManager(serviceID: ServiceId, strategy: .cluster)
        
        //advertiser
        advertiser = Advertiser(connectionManager: connectionManager)

        //Discoverer
        discoverer = Discoverer(connectionManager: connectionManager)
    }
    
    func setDelegate(){
        connectionManager.delegate = self
    }
    func stopAdvertising(){
        advertiser!.stopAdvertising()
    }
    
    func startAdvertising(){
        advertiser!.delegate = self

        // The endpoint info can be used to provide arbitrary information to the
        // discovering device (e.g. device name or type).
        advertiser!.startAdvertising(using: "My Device".data(using: .utf8)!)
    }
    
    func startDiscovering(){
        discoverer!.delegate = self
        discoverer!.startDiscovery()
    }
    func stopDiscovering(){
        discoverer!.stopDiscovery()
    }
    
    func sendMessage(message:String,toEndpoint:EndpointID){
        let _ = connectionManager.send(message.toData(), to: [toEndpoint])
    }
}

extension Example: AdvertiserDelegate {
  func advertiser(
    _ advertiser: Advertiser, didReceiveConnectionRequestFrom endpointID: EndpointID,
    with context: Data, connectionRequestHandler: @escaping (Bool) -> Void) {
    // Accept or reject any incoming connection requests. The connection will still need to
    // be verified in the connection manager delegate.
    connectionRequestHandler(true)
  }
}

extension Example: DiscovererDelegate {
  func discoverer(
    _ discoverer: Discoverer, didFind endpointID: EndpointID, with context: Data) {
        print("didFind:\(endpointID) context:\(context.toString())")
        discoverer.requestConnection(to: endpointID, using: "Hello".toData())
//        if !self.arrEndPoints.contains(endpointID){
//            self.arrEndPoints.append(endpointID)
//        }
    // An endpoint was found.
  }

  func discoverer(_ discoverer: Discoverer, didLose endpointID: EndpointID) {
    // A previously discovered endpoint has gone away.
//      if let index = arrEndPoints.firstIndex(of: endpointID) {
//         arrEndPoints.remove(at: index)
//      }
      
  }
}

extension Example: ConnectionManagerDelegate {
    
  func connectionManager(
    _ connectionManager: ConnectionManager, didReceive verificationCode: String,
    from endpointID: EndpointID, verificationHandler: @escaping (Bool) -> Void) {
    // Optionally show the user the verification code. Your app should call this handler
    // with a value of `true` if the nearby endpoint should be trusted, or `false`
    // otherwise.
    print("code:\(verificationCode) endpointId:\(endpointID)")
//    delegate?.connected(endppoint: endpointID)
    verificationHandler(true)
        
  }

  func connectionManager(
    _ connectionManager: ConnectionManager, didReceive data: Data,
    withID payloadID: PayloadID, from endpointID: EndpointID) {
        
        if let str = String(data: data, encoding: .utf8) {
            print("Successfully decoded: \(str)")
//            delegate?.receivedMessage(message: str)
            print("PayloadId\(payloadID) endpointId:\(endpointID)")
        }
    // A simple byte payload has been received. This will always include the full data.
  }

  func connectionManager(
    _ connectionManager: ConnectionManager, didReceive stream: InputStream,
    withID payloadID: PayloadID, from endpointID: EndpointID,
    cancellationToken token: CancellationToken) {
    // We have received a readable stream.
  }

  func connectionManager(
    _ connectionManager: ConnectionManager,
    didStartReceivingResourceWithID payloadID: PayloadID,
    from endpointID: EndpointID, at localURL: URL,
    withName name: String, cancellationToken token: CancellationToken) {
    // We have started receiving a file. We will receive a separate transfer update
    // event when complete.
  }

  func connectionManager(
    _ connectionManager: ConnectionManager,
    didReceiveTransferUpdate update: TransferUpdate,
    from endpointID: EndpointID, forPayload payloadID: PayloadID) {
    // A success, failure, cancelation or progress update.
  }

  func connectionManager(
    _ connectionManager: ConnectionManager, didChangeTo state: ConnectionState,
    for endpointID: EndpointID) {
        
    switch state {
    case .connecting:
      // A connection to the remote endpoint is currently being established.
        print("Connecting...")
    case .connected:
      // We're connected! Can now start sending and receiving data.
        print("Connected...")
    case .disconnected:
      // We've been disconnected from this endpoint. No more data can be sent or received.
        print("Disconnected...")
    case .rejected:
      // The connection was rejected by one or both sides.
        print("Rejected...")
    }
  }
}
