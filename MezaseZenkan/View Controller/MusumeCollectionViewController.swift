//
//  MusumeCollectionViewController.swift
//  MezaseZenkan
//
//  Created by yoonbumtae on 2022/04/27.
//

import UIKit

protocol MusumeCollectionVCDelegate: AnyObject {
    func didChangedMusume(_ controller: MusumeCollectionViewController, musumeName: String)
}

private let reuseIdentifier = "MusumeCell"

class MusumeCollectionViewController: UICollectionViewController {
    
    weak var delegate: MusumeCollectionVCDelegate?
    
    var musumeViewModel: MusumeViewModel = MusumeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }


    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return musumeViewModel.totalCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MusumeCell else {
            return UICollectionViewCell()
        }
    
        // Configure the cell
        cell.update(musume: musumeViewModel.getMusumeBy(index: indexPath.row))
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let musume = musumeViewModel.getMusumeBy(index: indexPath.row)
        if let delegate = delegate {
            delegate.didChangedMusume(self, musumeName: musume.name)
            self.dismiss(animated: true, completion: nil)
        }
    }

}

extension MusumeCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    // 사이즈 결정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let itemsPerRow: CGFloat = 6
        let widthPadding = 10 * (itemsPerRow + 1)
        let cellWidth = (width - widthPadding) / itemsPerRow
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

class MusumeCell: UICollectionViewCell {
    
    @IBOutlet weak var imgViewProfile: UIImageView!
    
    func update(musume: Musume) {
        print(musume.imgProfile)
        imgViewProfile.image = UIImage(named: "images/\(musume.imgProfile)")
    }
}
