//
//  Utils.swift
//  listener
//
//  Created by Jon Lara Trigo on 02/05/2020.
//  Copyright © 2020 Jon Lara Trigo. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    public static func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
    static var date: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS "
        return formatter.string(from: Date())
    }()
}
