//
//  SharedMemeCollectionViewController.swift
//  MemeMe
//
//  Created by Mahmoud Elkarargy on 4/25/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit

class SharedMemeCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .always
        }
        setFlowLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Make sure collection data is reloaded appropriately
        self.collectionView.reloadData()
    }
    // MARK: Get memes from App Delegate
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(memes.count)
        return memes.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeItem", for: indexPath) as! SharedMemeCollectionViewCell
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        // Set the image in the cell
        cell.CollectionImage?.image = meme.memedImage
        return cell
    }
    
    // MARK: Handle device rotations to re-calculate flow layout
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        setFlowLayout()
    }
    
    // MARK: Function to handle flow layout
    func setFlowLayout() {
        let space: CGFloat = 3.0
        let divisor: CGFloat = UIDevice.current.orientation.isPortrait ? 2.0 : 3.0
        let dimension = (view.safeAreaLayoutGuide.layoutFrame.width - (2 * space)) / divisor
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout();
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: (view.safeAreaLayoutGuide.layoutFrame.width), height: 80);
    }
    // MARK: Show Meme detail view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Helper.showMemeDetail(self.storyboard!, navigationController!,
                              memes, indexPath)
    }
    
}
