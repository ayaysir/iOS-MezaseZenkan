//
//  RotationViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/05/05.
//

import UIKit

class RotationViewController: UIViewController {
  @IBOutlet weak var lblCurrentPeriod: UILabel!
  @IBOutlet weak var lblIncludeOpRace: UILabel!
  
  @IBOutlet weak var btnNextPeriodBigLeap: UIButton!
  @IBOutlet weak var btnPrevPeriodBigLeap: UIButton!
  @IBOutlet weak var btnPrevPeriod: UIButton!
  @IBOutlet weak var btnNextPeriod: UIButton!
  
  @IBOutlet weak var tblViewRaceList: UITableView!
  
  var raceViewModel: RaceViewModel!
  var raceStateViewModel: RaceStateViewModel!
  var musumeViewModel: MusumeViewModel!
  
  // new viewmodel
  var currentRaces: [Race]!
  var isIncludeOP: Bool = false {
    didSet {
      renderView()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Localization
    lblIncludeOpRace.text = "loc.rv_include_op".localized
    
    tblViewRaceList.delegate = self
    tblViewRaceList.dataSource = self
    
    // init
    currentRaces = raceViewModel.getRacesByPeriod(PeriodHelper.shared, isIncludeOP: isIncludeOP)
    
    renderView()
    
    TrackingTransparencyPermissionRequest()
  }
  
  @IBAction func btnActNextPeriod(_ sender: UIButton) {
    PeriodHelper.shared.moveNextPeriod()
    renderView()
  }
  
  @IBAction func btnActPrevPeriod(_ sender: UIButton) {
    PeriodHelper.shared.movePrevPeriod()
    renderView()
  }
  
  @IBAction func btnActNextPeriodBigLeap(_ sender: UIButton) {
    PeriodHelper.shared.moveNextPeriodBigLeap()
    renderView()
  }
  
  @IBAction func btnActPrevPeriodBigLeap(_ sender: UIButton) {
    PeriodHelper.shared.movePrevPeriodBigLeap()
    renderView()
  }
  
  @IBAction func swtActIncludeOP(_ sender: UISwitch) {
    isIncludeOP = sender.isOn
  }
  
  func renderView() {
    currentRaces = raceViewModel.getRacesByPeriod(PeriodHelper.shared, isIncludeOP: isIncludeOP)
    tblViewRaceList.reloadData()
    
    lblCurrentPeriod.text = PeriodHelper.shared.localizedDescription
    
    if PeriodHelper.shared.isLastPeriod {
      btnNextPeriodBigLeap.isEnabled = false
      btnNextPeriod.isEnabled = false
    } else {
      btnNextPeriodBigLeap.isEnabled = true
      btnNextPeriod.isEnabled = true
    }
    
    if PeriodHelper.shared.isFirstPeriod {
      btnPrevPeriodBigLeap.isEnabled = false
      btnPrevPeriod.isEnabled = false
    } else {
      btnPrevPeriodBigLeap.isEnabled = true
      btnPrevPeriod.isEnabled = true
    }
  }
}

extension RotationViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if currentRaces.count == 0 {
      return 1
    } else {
      return currentRaces.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if currentRaces.count == 0 {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "BlankAlertCell") as? BlankAlertCell else {
        return UITableViewCell()
      }
      
      cell.setupUI()
      return cell
    }
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "RaceInfoTableCell") as? RaceInfoTableCell else {
      return UITableViewCell()
    }
    
    let race = currentRaces[indexPath.row]
    let isFinished = raceStateViewModel.getFinishedBy(musumeName: musumeViewModel.currentMusume.name, raceName: race.name)
    cell.update(race: race, isFinished: isFinished)
    
    return cell
  }
}

class RaceInfoTableCell: UITableViewCell {
  @IBOutlet weak var imgViewRaceBanner: UIImageView!
  @IBOutlet weak var imgViewRaceFinished: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblRaceInfo: UILabel!
  @IBOutlet weak var lblTerrain: UILabel!
  @IBOutlet weak var lblLengthType: UILabel!
  @IBOutlet weak var lblGrade: UILabel!
  @IBOutlet weak var lblPeriodDuplicated: UILabel!
  
  func update(race: Race, isFinished: Bool) {
    if UserDefaults.standard.bool(forKey: .cfgShowHighResBanner) && !race.bannerURL.isEmpty {
      imgViewRaceBanner.image = UIImage(named: "images/\(race.bannerURL)")
    } else {
      imgViewRaceBanner.image = raceToBanner(race: race)
    }
    
    lblTitle.text = race.name
    
    lblTerrain.text = race.terrain
    lblLengthType.text = race.lengthType
    lblTerrain.layer.borderColor = UIColor.gray.cgColor
    lblTerrain.layer.borderWidth = 1
    lblTerrain.layer.cornerRadius = 10
    lblLengthType.layer.borderColor = UIColor.gray.cgColor
    lblLengthType.layer.borderWidth = 1
    lblLengthType.layer.cornerRadius = 10
    
    lblGrade.layer.cornerRadius = 10
    lblGrade.layer.masksToBounds = true
    lblGrade.text = race.grade
    
    if race.grade == "OP" || race.grade == "Pre-OP" {
      lblGrade.backgroundColor = UIColor(named: "OP-Color")
    } else {
      lblGrade.backgroundColor = UIColor(named: "\(race.grade)-Color")
    }
    
    let infoText = "\(race.place) \(race.terrain) \(race.length)m (\(race.lengthType)) \(race.direction)"
    lblRaceInfo.text = infoText
    
    if race.period == "classicsenior" {
      lblPeriodDuplicated.isHidden = false
      let periodText = PeriodHelper.shared.year == 3 ? "classic" : "senior"
      lblPeriodDuplicated.text = "loc.same_race_exist".localizedFormat(periodText)
    } else {
      lblPeriodDuplicated.isHidden = true
    }
    
    if race.grade == "OP" || race.grade == "Pre-OP" {
      imgViewRaceFinished.isHidden = true
      self.backgroundColor = .clear
    } else {
      imgViewRaceFinished.isHidden = false
      if isFinished {
        imgViewRaceFinished.image = UIImage(systemName: "checkmark")
        imgViewRaceFinished.tintColor = RGB255(red: 25, green: 190, blue: 63).uiColor
        self.backgroundColor = RGB255(red: 210, green: 250, blue: 142, alpha: 0.08).uiColor
      } else {
        imgViewRaceFinished.image = UIImage(systemName: "xmark")
        imgViewRaceFinished.tintColor = .red
        self.backgroundColor = RGB255(red: 250, green: 220, blue: 142, alpha: 0.15).uiColor
      }
    }
  }
}

class BlankAlertCell: UITableViewCell {
  @IBOutlet weak var lblNoRace: UILabel!
  
  func setupUI() {
    lblNoRace.text = "loc.rv_no_race".localized
  }
}
