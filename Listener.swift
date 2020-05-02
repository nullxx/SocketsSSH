//
//  Listener.swift
//  listener
//
//  Created by Jon Lara Trigo on 01/05/2020.
//  Copyright © 2020 Jon Lara Trigo. All rights reserved.
//

import UIKit
import SocketIO


class Listener: UIViewController {

    var manager:SocketManager!
    var socketIOClient: SocketIOClient!
    
    static let socketURL = URL(string: "<YOUR_SOCKET_SERVER_ENDPOINT>")!;
    
    @IBOutlet weak var connectButtonLabel: UIButton!
    @IBOutlet weak var commandLabel: UITextField!
    @IBOutlet weak var sendButtonLabel: UIButton!
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var socketConnOutputLabel: UITextView!
    
    @IBAction func onConnectAction(_ sender: UIButton) {
        ConnectToSocket()
    }
    
    @IBAction func onSendCommandAction(_ sender: UIButton) {
        if (commandLabel.text != nil && commandLabel.text?.count ?? 0 > 0){
            sender.isEnabled = false;
            self.commandLabel.isEnabled = false;
            if (commandLabel.text! == "clear"){
                output.text.removeAll()
                self.commandLabel.isEnabled = true;
                self.sendButtonLabel.isEnabled = true;
                return;
            }
            self.socketIOClient.emit("SEND_COMMAND", commandLabel.text!)
            self.view.endEditing(true)
        }
    }

    
    func writeOutput(msg: String, source: UITextView, withTime: Bool, withColor: UIColor?){
        if (withTime){
            let date = Utils.date;
            source.text += date + ": " + msg +  "\n";
        }else{
            source.text += msg +  "\n";
        }
        if (withColor != nil){
            source.textColor = withColor;
        }
        
        Utils.scrollTextViewToBottom(textView: source);
    }
    
    func ConnectToSocket() {

        manager = SocketManager(socketURL:
            Listener.socketURL, config: [.log(false), .reconnects(true)])
        socketIOClient = manager.defaultSocket

        socketIOClient.on(clientEvent: .connect) {data, ack in
            self.writeOutput(msg: "Socket connected", source: self.socketConnOutputLabel, withTime: true, withColor: nil)
            self.sendButtonLabel.isEnabled = true;
            self.commandLabel.isEnabled = true;
            self.connectButtonLabel.isEnabled = false;
        }

        socketIOClient.on(clientEvent: .error) { (data, eck) in
            self.writeOutput(msg: "Socket error", source: self.socketConnOutputLabel, withTime: true, withColor: nil)
            self.sendButtonLabel.isEnabled = false;
            self.commandLabel.isEnabled = false;
        }

        socketIOClient.on(clientEvent: .disconnect) { (data, eck) in
            self.writeOutput(msg: "Socket disconnect", source: self.socketConnOutputLabel, withTime: true, withColor: nil)
            self.sendButtonLabel.isEnabled = false;
            self.commandLabel.isEnabled = false;
            self.connectButtonLabel.isEnabled = true;
        }

        socketIOClient.on(clientEvent: SocketClientEvent.reconnect) { (data, eck) in
            self.writeOutput(msg: "Socket reconnect", source: self.socketConnOutputLabel, withTime: true,withColor: nil)
        }
        reciveOutput()
        socketIOClient.connect()
    }
    
    func reciveOutput(){
        socketIOClient.on("RECIVE_COMMAND_OUTPUT") { (data, eck) in
            guard let dic = data[0] as? Dictionary<String, Any> else { return }
            let stringOut = dic.values[dic.index(forKey: "data")!]
            let commandReq = dic.values[dic.index(forKey: "commandReq")!]
            if ((stringOut as? String) != nil){
                self.writeOutput(msg: "root@nullx:~# " + (commandReq as! String)  + "\n" + (stringOut as! String), source: self.output, withTime: false, withColor: nil)
            }else{
                self.writeOutput(msg: "root@nullx:~# " + (commandReq as! String)  + "\n", source: self.output, withTime: false, withColor: nil)
            }
            self.commandLabel.isEnabled = true;
            self.sendButtonLabel.isEnabled = true;
        }
    }
}
