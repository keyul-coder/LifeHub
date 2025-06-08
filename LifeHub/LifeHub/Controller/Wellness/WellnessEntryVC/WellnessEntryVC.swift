//
//  WellnessEntryVC.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-08.
//

import UIKit

protocol WellnessEntryVCDelegate: AnyObject {
    func wellnessEntry(didSave model: WellnessDiaryModel)
}

/// WellnessEntryVC
class WellnessEntryVC: ParentVC {
    
    /// @IBOutlet(s)
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lblPlaceholder: UILabel!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    /// Carried Varaiable(s)
    var model: WellnessDiaryModel = WellnessDiaryModel(text: "", date: Date())
    weak var delegate: WellnessEntryVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textView.becomeFirstResponder()
    }
}

// MARK: - UI Related Method(s)
extension WellnessEntryVC {
    
    private func prepareUI() {
        self.datePicker.date = model.date
        datePicker.maximumDate = Date() // Disables future dates
        self.textView.text = model.text
        self.handleTextViewPlaceholder()
    }
    
    private func handleTextViewPlaceholder() {
        self.lblPlaceholder.isHidden = !self.textView.text.isEmpty
    }
}

// MARK: - UITextViewDelegate
extension WellnessEntryVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.model.text = textView.text
        self.handleTextViewPlaceholder()
    }
}

// MARK: - @IBAction(s)
extension WellnessEntryVC {
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        self.delegate?.wellnessEntry(didSave: self.model)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func datePickerDateChanged(_ sender: UIDatePicker) {
        self.model.date = sender.date
    }
}
