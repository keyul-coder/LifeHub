//
//  WellnessVC.swift
//  LifeHub
//
//  Created by Jenish Shah on 2025-06-07.
//

import UIKit

/// WellnessVC
class WellnessVC: ParentVC {
    
    /// @IBOutlet(s)
    @IBOutlet weak var btnAdd: UIButton!
    
    /// Variable Declration(s)
    var arrJournalEntries: [WellnessDiaryModel] = []
    
    /// View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "segueWellnessEntryVC" {
            let vc = segue.destination as! WellnessEntryVC
            if let model = sender as? WellnessDiaryModel {
                vc.model = model
            }
            vc.delegate = self
        }
    }
}

// MARK: - UI Related Method(s)
extension WellnessVC {
    
    private func prepareUI() {
        self.navigationItem.title = "Journal"
        self.arrJournalEntries = WellnessDiaryModel.loadDiaryEntries()
    }
    
    private func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
}

// MARK: - @IBAction(s)
extension WellnessVC {
    
    @IBAction func onTapAddBtn(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueWellnessEntryVC", sender: nil)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension WellnessVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrJournalEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WellnessTableViewCell
        cell.tag = indexPath.row
        cell.parentVC = self
        cell.model = self.arrJournalEntries[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "segueWellnessEntryVC", sender: self.arrJournalEntries[indexPath.row])
    }
}

// MARK: - WellnessEntryVCDelegate
extension WellnessVC: WellnessEntryVCDelegate {
    
    func wellnessEntry(didSave model: WellnessDiaryModel) {
        if let index = self.arrJournalEntries.firstIndex(where: { $0.id == model.id}) {
            self.arrJournalEntries[index] = model
        } else {
            self.arrJournalEntries.append(model)
        }
        self.arrJournalEntries.sort { $0.date > $1.date }
        WellnessDiaryModel.saveDiaryEntries(self.arrJournalEntries)
        self.reloadData()
    }
}
