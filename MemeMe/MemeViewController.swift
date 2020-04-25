//
//  MemeViewController.swift
//  MemeMe
//
//  Created by Mahmoud Elkarargy on 4/22/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate {
    // MARK: Constants
    let textPositionScale: CGFloat = 0.9
    let keyboardViewPositionScale: CGFloat = 0.9
    
    //MARK: - Outlets.
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var upperToolBar: UIToolbar!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var pickButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var topTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextConstraint: NSLayoutConstraint!
     
    // MARK: Hold current image information
    var imageHeight: CGFloat = 0.0
    var imageWidth: CGFloat = 0.0
    var scale: CGFloat = 0.0
    var memedImage: UIImage!
    

    // MARK: Text Field Delegate objects
    let memeTextDelegate = MemeTextFieldDelegate()
    
    //MARK: -Override funcs
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField(tf: topTextField, text: "TOP")
        setupTextField(tf: bottomTextField, text: "BOTTOM")
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Move text to correct place
        setImageText()
    }
    
    
    
    //MARK: -Keyboard functions to avoid overlaying onto text (Notifications).
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    
    //MARK: -UIImagePicker Delegate functions.
    func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .photoLibrary)
    }
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .camera)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            // Set the image text
            setImageText()
            shareButton.isEnabled = true
            cancelButton.isEnabled = true
            cameraButton.isEnabled = false
            pickButton.isEnabled = false
        }
        else{
            //Show Error msg here!
            let controller = UIAlertController()
            controller.title = "Error"
            controller.message = "Please try agian"
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { action in self.dismiss(animated: true, completion: nil)
            }
            
            controller.addAction(okAction)
            self.present(controller, animated: true, completion: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Image Text helper functions
    func setImageText() {
        // Get the image dimensions and scale
        let imageViewHeight = imagePickerView.bounds.height
        let imageViewWidth = imagePickerView.bounds.width
        imageHeight = imagePickerView.intrinsicContentSize.height
        imageWidth = imagePickerView.intrinsicContentSize.width
        // Calculate image scale based on device orientation
        if UIDevice.current.orientation.isPortrait {
            scale = imageViewWidth / imageWidth
        } else {
            scale = imageViewHeight / imageHeight
        }
        let middle = imageViewHeight / 2
        // Move the meme text onto the image
        // Multiply by textPositionScale to move slightly into image
        topTextConstraint.constant =
            middle - (scale * (imageHeight / 2) * textPositionScale)
        bottomTextConstraint.constant =
            middle - (scale * (imageHeight / 2) * textPositionScale)
    }
    
    //MARK: -TextFields.
    func setupTextField(tf: UITextField, text: String) {
        let attributes = getAttributes()
        tf.text = text
        tf.delegate = memeTextDelegate
        tf.defaultTextAttributes = attributes
    }
    func getAttributes() -> [NSAttributedString.Key : Any] {
        var attributes = memeTextDelegate.memeTextAttributes
        // Add centering style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributes.merge([NSAttributedString.Key.paragraphStyle: paragraphStyle],
                         uniquingKeysWith: { (current, _) in current })
        return attributes
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP"{
            topTextField.text = ""
        }
        else if textField.text == "BOTTOM"{
            bottomTextField.text = ""
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    func getKeyboardHeight(_ notification: Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    @objc func keyboardWillShow(_ notification: Notification){
//        if let activeTextField = activeTextField {
//            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
//            if bottomOfTextField > getKeyboardHeight(notification){
//                view.frame.origin.y -= getKeyboardHeight(notification)
//            }
//        }
    }
    @objc func keyboardWillHide(_ notification: Notification){
        view.frame.origin.y = 0
    }
    
    //MARK: -Save Image, Share and Cancel.
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
//        appDelegate.memes.append(meme)
    }
    func generateMemedImage() -> UIImage {
        self.upperToolBar.isHidden = true
        self.bottomToolBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.upperToolBar.isHidden = false
        self.bottomToolBar.isHidden = false
        
        return memedImage
    }
    @IBAction func share(){
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        present(controller,animated: true, completion: nil)
        
        controller.completionWithItemsHandler = { activity, completed, items, error in
        if completed {
            self.save()
            return
            }
        }
    }
    
    @IBAction func resetAfterCancel(){
        imagePickerView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        pickButton.isEnabled = true
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
    }
}
