//
//  PasswordGeneratorViewController.swift
//  NewPass
//
//  Created by Addison Francisco on 7/17/18.
//  Copyright © 2018 Addison Francisco. All rights reserved.
//

import UIKit

class PasswordGeneratorViewController: UIViewController {

    // MARK: - Properties

    private var viewModel = PasswordLabelViewModel()
    // Default password length to be 10 characters
    private var passwordLength = Constants.defaultPasswordLength
    private var passwordString = NSAttributedString(string: "")
    private var passwordSwitches: [PasswordAttributeSwitch]!

    // Change status bar to light color for app's dark background
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Outlets

    @IBOutlet weak private var passwordLabelViewContainer: UIView!
    // Animates from center to top
    @IBOutlet weak private var passwordLabel1: UILabel!
    // Animates from bottom to center
    @IBOutlet weak private var passwordLabel2: UILabel!
    @IBOutlet weak private var passwordLabel1BottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var passwordLabel2BottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var passwordLengthLabel: UILabel!
    @IBOutlet weak private var passwordLengthSlider: UISlider!
    @IBOutlet weak private var lowercaseLetterSwitch: PasswordAttributeSwitch!
    @IBOutlet weak private var uppercaseLetterSwitch: PasswordAttributeSwitch!
    @IBOutlet weak private var numberSwitch: PasswordAttributeSwitch!
    @IBOutlet weak private var symbolSwitch: PasswordAttributeSwitch!
    @IBOutlet weak private var generatePasswordButton: UIButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        generatePasswordButton.addTarget(self, action: #selector(generatePasswordTouchBegan(_:)), for: .touchDown)
        passwordLabel1.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(presentActionSheetForShare)))

        passwordSwitches = [lowercaseLetterSwitch, numberSwitch, symbolSwitch, uppercaseLetterSwitch]

        // Assign attributes to password switches
        lowercaseLetterSwitch.attributeType = .containsLowercaseLetters
        uppercaseLetterSwitch.attributeType = .containsUppercaseLetters
        numberSwitch.attributeType = .containsNumbers
        symbolSwitch.attributeType = .containsSymbols

        // Roundify view corners
        passwordLabelViewContainer.roundify(cornerRadius: 6)
        generatePasswordButton.roundify(cornerRadius: 6)

        // Configure default password and update views
        defaultPasswordSetup()
    }

}

// MARK: - Actions
extension PasswordGeneratorViewController {

    @IBAction private func attributeSwitchDidChange(_ attributeSwitch: PasswordAttributeSwitch) {
        viewModel.passwordAttributes = passwordSwitches.filter { $0.isOn }.map { switchThatIsOn -> PasswordAttribute in
            return switchThatIsOn.attributeType
        }
    }

    @IBAction private func passwordLengthSliderDidMove(_ sender: Any) {
        passwordLength = Int(passwordLengthSlider.value)
        passwordLengthLabel.text = "Password Length: \(passwordLength)"
    }

    @IBAction @objc private func generatePasswordTouchBegan(_ sender: UIButton) {
        if viewModel.hasSelectedPasswordAttributes {
            randomPasswordFromViewModel()
            updateLabelsWithAnimation()
        } else {
            presentAlertForEmptyAttributes()
        }
    }

}

// MARK: - Password Fetcher
extension PasswordGeneratorViewController {

    private func randomPasswordFromViewModel() {
        if viewModel.hasSelectedPasswordAttributes {
            passwordString = viewModel.getRandomPassword(length: passwordLength)
            HapticEngine().hapticTap(impactStyle: .light)
        } else {
            presentAlertForEmptyAttributes()
        }
    }

}

// MARK: - View Layout
extension PasswordGeneratorViewController {

    private func updateLabelsForPassword() {
        passwordLabel2.attributedText = passwordString
        passwordLengthLabel.text = "Password Length: \(passwordLength)"
    }

    private func defaultPasswordSetup() {
        // Generate a default password when view loads
        passwordString = viewModel.getRandomPassword(length: passwordLength)
        // Update password attribute switches for default password
        updateSwitchesToInitialState()
        // Update password legth slider for default password
        passwordLengthSlider.setValue(Float(passwordLength), animated: true)
        passwordLengthLabel.text = "Password Length: \(passwordLength)"
        // Update labels
        passwordLabel1.attributedText = passwordString
    }

    private func updateLabelsWithAnimation() {
        generatePasswordButton.isEnabled = false
        updateLabelsForPassword()

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 5,
                       options: [],
                       animations: {
                        performLayoutUpdatesForAnimation()
        },
                       completion: { _ in
                        self.generatePasswordButton.isEnabled = true
                        self.passwordLabel1.attributedText = self.passwordLabel2.attributedText
                        performLayoutUpdatesForCompletion()

                        if self.generatePasswordButton.state == .highlighted {
                            self.randomPasswordFromViewModel()
                            self.updateLabelsForPassword()
                            animateWithReducedDuration()
                        }
        })

        func animateWithReducedDuration() {
            UIView.animate(withDuration: 0.07,
                           delay: 0,
                           options: [],
                           animations: {
                            performLayoutUpdatesForAnimation()
            },
                           completion: { _ in
                            self.generatePasswordButton.isEnabled = true
                            self.passwordLabel1.attributedText = self.passwordLabel2.attributedText
                            performLayoutUpdatesForCompletion()

                            guard self.viewModel.hasSelectedPasswordAttributes else {
                                self.presentAlertForEmptyAttributes()
                                return
                            }

                            if self.generatePasswordButton.state == .highlighted {
                                self.randomPasswordFromViewModel()
                                self.updateLabelsForPassword()
                                animateWithReducedDuration()
                            }
            })
        }

        func performLayoutUpdatesForAnimation() {
            self.passwordLabel1.alpha = 0
            self.passwordLabel1BottomConstraint.constant = self.passwordLabelViewContainer.frame.height
            self.passwordLabel2.alpha = 1
            self.passwordLabel2BottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }

        func performLayoutUpdatesForCompletion() {
            self.passwordLabel1.alpha = 1
            self.passwordLabel1BottomConstraint.constant = 0
            self.passwordLabel2.alpha = 0
            self.passwordLabel2BottomConstraint.constant = 0 - self.passwordLabelViewContainer.frame.height
            self.view.layoutIfNeeded()
        }
    }

    /// This function is used only for updating the switches to the initial default state
    private func updateSwitchesToInitialState() {
        for passwordSwitch in passwordSwitches {
            if viewModel.passwordAttributes.contains(passwordSwitch.attributeType) {
                passwordSwitch.setOn(true, animated: true)
            }
        }
    }

}

// MARK: - Alerts
extension PasswordGeneratorViewController {

    @objc private func presentActionSheetForShare() {
        let items = [passwordString.string]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(ac, animated: true, completion: nil)
        HapticEngine().hapticTap(impactStyle: .light)
    }

    private func presentAlertForEmptyAttributes() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Hold On", message: "You need at least 1 attribute selected to generate a password.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: {
            })
            HapticEngine().hapticWarning()
        }
    }

}

// MARK: - Haptic Events
extension PasswordGeneratorViewController {
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        switch motion {
        case .motionShake:
            randomPasswordFromViewModel()
            updateLabelsWithAnimation()
        default:
            break
        }
    }

}
