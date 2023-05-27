//
//  GPInput+CVC.swift
//  GrubPaySDK
//
//  Created by Edward Yuan on 2023-05-08.
//

import Foundation

class GPInputCVV: GPInput {
    // MARK: Validators

    var cleanText: String {
        return super.text ?? ""
    }

    func updateErrorState() {
        let targetErr: String? = valid ? nil : "Error"
        if super.errorMessage != targetErr {
            super.errorMessage = targetErr
        }
    }

    @discardableResult
    override open func resignFirstResponder() -> Bool {
        updateErrorState()
        return super.resignFirstResponder()
    }

    // MARK: Initializers

    override init(controller: GPFormController) {
        super.init(controller: controller)
        initField()
    }

    private func initField() {
        super.delegate = self
        super.titleText = "CVC"
        super.placeholder = "123"
        super.autocorrectionType = .no
        super.autocapitalizationType = .none
        super.keyboardType = .numberPad
    }
}

extension GPInputCVV: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return GPInputUtil.maskInput(
            mask: "####",
            textField: textField,
            shouldChangeCharactersIn: range,
            replacementString: string,
            allowMix: false
        )
    }
}

// Validator for controller
extension GPInputCVV {
    override var valid: Bool {
        if controller.config?.mode == .card {
            let trimmedStr = super.text ?? ""
            return trimmedStr.count > 2
        }
        return true
    }

    override func doValidate(
        onSuccess: @escaping ([String: Any]) -> Void,
        onError: @escaping (String) -> Void
    ) {
        if controller.config?.mode != .card {
            onSuccess([:])
            return
        }
        updateErrorState()
        if valid {
            onSuccess(["cvv": cleanText])
        } else {
            onError("CVV")
        }
    }
}
