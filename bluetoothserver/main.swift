//
//  main.swift
//  bluetoothserver
//
//  Created by Paul Wagener on 03-04-18.
//  Copyright © 2018 Paul Wagener. All rights reserved.
//

import Foundation
import IOBluetooth
import AppKit

let open = NSSound(contentsOfFile: "open.wav", byReference: true)!
let close = NSSound(contentsOfFile: "close.wav", byReference: true)!

class Server : IOBluetoothRFCOMMChannelDelegate {

    var count: Int = 0

    init() {
        log("Bluetooth server started")
        IOBluetoothRFCOMMChannel.register(forChannelOpenNotifications: self, selector: #selector(self.opened(notification:channel:)))
    }

    @objc func opened(notification: IOBluetoothUserNotification, channel: IOBluetoothRFCOMMChannel) {
        log("Channel opened: " + channel.getDevice().name.description)
        open.play()
        count = 0
        channel.setDelegate(self)
    }

    public func rfcommChannelData(_ rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutableRawPointer!, length dataLength: Int) {
        let data = Data(bytesNoCopy: dataPointer, count: dataLength, deallocator: Data.Deallocator.none)

        var s = ""
        for i in 0..<dataLength {
            let byte = data[i]
            s += String(format: "%02hhx ", byte)
        }

        log("(\(count)) <- \(s)")
        count += 1;
    }

    public func rfcommChannelOpenComplete(_ rfcommChannel: IOBluetoothRFCOMMChannel!, status error: IOReturn) {
    }

    public func rfcommChannelClosed(_ rfcommChannel: IOBluetoothRFCOMMChannel!) {
        log("Channel closed")
        close.play()

    }

    func log(_ s: String) {
        print("\(Date().description) \(s)")
    }
}


let s = Server()

RunLoop.main.run()
