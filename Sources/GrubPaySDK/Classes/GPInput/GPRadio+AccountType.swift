//
//  GPRadio+AccountType.swift
//  GrubPaySDK
//
//  Created by Edward Yuan on 2023-05-16.
//

import Foundation
import UIKit

class GPRadioAccountType: UIStackView {
    var onChanged: (() -> Void)?
    
    let controller: GPFormController!
    private var currentType: GrubPayACHAccountType = .ECHK {
        didSet {
            checkingButton.isSelected = (currentType == .ECHK)
            savingButton.isSelected = (currentType == .ESAV)
        }
    }
    
    private lazy var checkingButton: GPRadioButton = {
        let b = GPRadioButton(controller: controller)
        b.setTitle("Checking", for: .normal)
        b.addTarget(
            self,
            action: #selector(self.radioButtonSelected(_:)),
            for: .touchUpInside
        )
        b.isSelected = (currentType == .ECHK)
        b.isEnabled = controller.isEnabled
        return b
    }()
    
    private lazy var savingButton: GPRadioButton = {
        let b = GPRadioButton(controller: controller)
        b.setTitle("Saving", for: .normal)
        b.addTarget(
            self,
            action: #selector(self.radioButtonSelected(_:)),
            for: .touchUpInside
        )
        b.isSelected = (currentType == .ESAV)
        b.isEnabled = controller.isEnabled
        return b
    }()
    
    let radioRow = UIStackView()
    
    let titleLabel = UILabel()
    
    @objc func radioButtonSelected(_ sender: UIButton) {
        if sender == checkingButton {
            currentType = .ECHK
        } else if sender == savingButton {
            currentType = .ESAV
        }
    }
   
    private func commonInit() {
        super.axis = .vertical
        super.spacing = 2

        savingButton.setTitle("Saving", for: .normal)
       
        radioRow.axis = .horizontal
        radioRow.spacing = 8
        radioRow.alignment = .fill
        
        radioRow.addArrangedSubview(checkingButton)
        radioRow.addArrangedSubview(savingButton)
        radioRow.addArrangedSubview(UIView())
        
        titleLabel.text = "Account Type"
        titleLabel.font = controller.style.labelStyle.font
        titleLabel.textColor = controller.style.labelStyle.color
        
        addArrangedSubview(titleLabel)
        addArrangedSubview(radioRow)
        controller.addField(self)
    }
    
    init(controller: GPFormController) {
        self.controller = controller
        super.init(frame: .zero)
        commonInit()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        controller.removeObs(self)
    }
}

extension GPRadioAccountType: GPFormObs {
    func doValidate(
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (String) -> Void
    ) {
        if controller.config?.channel == .card {
            onSuccess([:])
            return
        }
        onSuccess(["accountType": currentType.rawValue])
    }
    
    func isEnabledDidChange(_ isEnabled: Bool) {
        DispatchQueue.main.async {
            [weak self] in
            self?.checkingButton.isEnabled = isEnabled
            self?.savingButton.isEnabled = isEnabled
        }
    }
}
