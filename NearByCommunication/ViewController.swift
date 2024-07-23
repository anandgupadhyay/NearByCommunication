//
//  ViewController.swift
//  NearByCommunication
//
//  Created by Anand Upadhyay on 19/07/24.
//

import UIKit
import NearbyConnections
extension String {
    func toData() -> Data {
        return Data(self.utf8)
    }
}

extension Data {
      func toString() -> String {
          return String(decoding: self, as: UTF8.self)
      }
   }


class ViewController: UIViewController {
    var arrEndPoints:[EndpointID] = []
    var arrEndPointNames:[String] = []//{
//        didSet {
//            print("array changed");
//            tblEndpoints.reloadData()
//        }
//    }
    
//    static var shared = Example()
    var connectionManager: ConnectionManager!
    var advertiser: Advertiser?
    var discoverer: Discoverer?
//    var delegate:TrackNearByConnectionDelegate?
    var isAdvertising = false
    
    @IBOutlet weak var tblEndpoints: UITableView!
    var connectedEndpointId: String = ""
    @IBOutlet weak var txtReceiver: UITextField!
    @IBOutlet weak var txtSender: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        tblEndpoints.delegate = self
        tblEndpoints.dataSource = self
        
        connectionManager = ConnectionManager(serviceID: ServiceId, strategy: .cluster)
        
        //advertiser
        advertiser = Advertiser(connectionManager: connectionManager)
        advertiser!.delegate = self

        //Discoverer
        discoverer = Discoverer(connectionManager: connectionManager)
        discoverer!.delegate = self

        stopAdvertising()
        stopDiscovering()
        
//        Example.shared.delegate = self
//        Example.shared.setDelegate()
//        Example.shared.stopDiscovering()
//        Example.shared.stopAdvertising()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func didTapSend(_ sender: Any){
//        Example.shared.stopDiscovering()
//        Example.shared.startAdvertising()
        stopAdvertising()
        stopDiscovering()
        startAdvertising()
        txtSender.resignFirstResponder()
    }
    
    @IBAction func didTapReceive(_ sender: Any) {
//        Example.shared.stopAdvertising()
//        Example.shared.startDiscovering()
        stopAdvertising()
        stopDiscovering()
        startDiscovering()
        txtSender.resignFirstResponder()
    }
    
    func stopAdvertising(){
        advertiser!.stopAdvertising()
    }
    
    func startAdvertising(){
        // The endpoint info can be used to provide arbitrary information to the
        // discovering device (e.g. device name or type).
        isAdvertising = true
         
        var message = ""
        if let somem = txtSender.text {
            message = somem
        }
        if message.isEmpty{
            message = UIDevice.current.name
        }
        if message.isEmpty{
            message = "No Message"
        }
        advertiser!.startAdvertising(using: message.toData())
    }
    
    func startDiscovering(){
        isAdvertising = false
        discoverer!.startDiscovery()
    }
    
    func stopDiscovering(){
        discoverer!.stopDiscovery()
    }
    
    func sendMessage(message:String,toEndpoint:EndpointID){
        let _ = connectionManager.send(message.toData(), to: [toEndpoint])
    }
}
extension ViewController: AdvertiserDelegate {
  func advertiser(
    _ advertiser: Advertiser, didReceiveConnectionRequestFrom endpointID: EndpointID,
    with context: Data, connectionRequestHandler: @escaping (Bool) -> Void) {
    // Accept or reject any incoming connection requests. The connection will still need to
    // be verified in the connection manager delegate.
    connectionRequestHandler(true)
  }
}
//extension ViewController: TrackNearByConnectionDelegate{
//    func connected(endppoint: EndpointID){
//        self.connectedEndpointId = endppoint
////        Example.shared.sendMessage(message: self.txtSender.text ?? "Hello", toEndpoint: self.connectedEndpointId)
//    }
//    
//    func receivedMessage(message: String) {
//        self.txtReceiver.text = message
//        txtSender.resignFirstResponder()
//    }
//}
extension ViewController: DiscovererDelegate {
  func discoverer(
    _ discoverer: Discoverer, didFind endpointID: EndpointID, with context: Data) {
        print("didFind:\(endpointID) context:\(context.toString())")
        discoverer.requestConnection(to: endpointID, using: "Hello".toData())
        if !self.arrEndPoints.contains(endpointID){
            self.arrEndPoints.append(endpointID)
            self.arrEndPointNames.append(context.toString())
        }
        self.tblEndpoints.reloadData()
    // An endpoint was found.
  }

  func discoverer(_ discoverer: Discoverer, didLose endpointID: EndpointID) {
    // A previously discovered endpoint has gone away.
      if let index = arrEndPoints.firstIndex(of: endpointID) {
          self.arrEndPoints.remove(at: index)
          self.arrEndPointNames.remove(at: index)
      }
      self.tblEndpoints.reloadData()
  }
}

extension ViewController: ConnectionManagerDelegate {
    
  func connectionManager(
    _ connectionManager: ConnectionManager, didReceive verificationCode: String,
    from endpointID: EndpointID, verificationHandler: @escaping (Bool) -> Void) {
    // Optionally show the user the verification code. Your app should call this handler
    // with a value of `true` if the nearby endpoint should be trusted, or `false`
    // otherwise.
    print("code:\(verificationCode) endpointId:\(endpointID)")
//  delegate?.connected(endppoint: endpointID)
    verificationHandler(true)
  }

  func connectionManager(
    _ connectionManager: ConnectionManager, didReceive data: Data,
    withID payloadID: PayloadID, from endpointID: EndpointID) {
        
        if let str = String(data: data, encoding: .utf8) {
            print("Successfully decoded: \(str)")
//            delegate?.receivedMessage(message: str)
            self.txtReceiver.text = str
            print("PayloadId\(payloadID) endpointId:\(endpointID)")
        }
    // A simple byte payload has been received. This will always include the full data.
  }

  func connectionManager(
    _ connectionManager: ConnectionManager, didReceive stream: InputStream,
    withID payloadID: PayloadID, from endpointID: EndpointID,
    cancellationToken token: CancellationToken) {
    // We have received a readable stream.
        print("endpointID:\(endpointID) - didReceive stream")

  }

  func connectionManager(
    _ connectionManager: ConnectionManager,
    didStartReceivingResourceWithID payloadID: PayloadID,
    from endpointID: EndpointID, at localURL: URL,
    withName name: String, cancellationToken token: CancellationToken) {
    // We have started receiving a file. We will receive a separate transfer update
    // event when complete.
        print("endpointID:\(endpointID) - didStartReceivingResourceWithID")
  }

  func connectionManager(
    _ connectionManager: ConnectionManager,
    didReceiveTransferUpdate update: TransferUpdate,
    from endpointID: EndpointID, forPayload payloadID: PayloadID) {
    // A success, failure, cancelation or progress update.
        print("endpointID:\(endpointID) - didReceiveTransferUpdate")
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
        self.connectedEndpointId = endpointID
        if(isAdvertising){
            self.sendMessage(message: self.txtSender.text ?? "Sending 123", toEndpoint: self.connectedEndpointId)
        }
    case .disconnected:
      // We've been disconnected from this endpoint. No more data can be sent or received.
        print("Disconnected...")
        self.connectedEndpointId = ""
    case .rejected:
      // The connection was rejected by one or both sides.
        self.connectedEndpointId = ""
        print("Rejected...")
    }
  }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrEndPoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cellid")
        cell.textLabel?.text = self.arrEndPoints[indexPath.row]
        cell.textLabel?.text = "\(cell.textLabel?.text ?? "") - \(self.arrEndPointNames[indexPath.row])"
        cell.selectionStyle = .gray
        if !self.connectedEndpointId.isEmpty{
            if self.arrEndPoints[indexPath.row] == self.connectedEndpointId{
                cell.textLabel?.text = "\(cell.textLabel?.text ?? "") - Connected"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if !isAdvertising{
//            if self.connectedEndpointId == arrEndPoints[indexPath.row] {
//                connectionManager.disconnect(from: arrEndPoints[indexPath.row])
//            }
//            
//            self.discoverer?.requestConnection(to: arrEndPoints[indexPath.row], using: (self.txtSender.text ?? "Hello").toData()){ error in
//                if error != nil{
//                    print("Error in Connectiong:\(String(describing: error?.localizedDescription))")
//                }
//            }
//        }
    }
}
