//
//  SecondProtocol.swift
//  
//
//  Created by Fabian Rottensteiner on 09.08.22.
//

#if canImport(UIKit)

import UIKit

protocol SecondProtocol {
    var onColor: UIColor { get set }
    var offColor: UIColor { get set }

    var state: SecondState { get set }

    init(onColor: UIColor, offColor: UIColor)

    func setupView()
}

#endif
