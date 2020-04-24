//
//  ViewController.swift
//  MemeMe
//
//  Created by Mahmoud Elkarargy on 4/22/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    
    //MARK: - Declerations and variables.
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var upperToolBar: UIToolbar!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var pickButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    
    var activeTextField : UITextField? = nil
    
    //MARK: -Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField(tf: topTextField, text: "TOP")
        setupTextField(tf: bottomTextField, text: "BOTTOM")
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    
    //MARK: -Meme Struct.
    struct Meme {
        var topText: String?
        var bottomText: String?
        var originalImage: UIImage?
        var memedImage: UIImage?
    }
    
    
    //MARK: -Notifications.
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    
    //MARK: -PickImage.
    func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
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
    
    //MARK: -TextFields.
    func setupTextField(tf: UITextField, text: String) {
        tf.defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.strokeColor : UIColor.black,
            NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -4.0,
        ]
        tf.textColor = UIColor.white
        tf.tintColor = UIColor.white
        tf.textAlignment = .center
        tf.text = text
        tf.delegate = self
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP"{
            topTextField.text = ""
        }
        else if textField.text == "BOTTOM"{
            bottomTextField.text = ""
        }
        self.activeTextField = textField
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.activeTextField = nil
        return true;
    }
    func getKeyboardHeight(_ notification: Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    @objc func keyboardWillShow(_ notification: Notification){
        if let activeTextField = activeTextField {
            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
            if bottomOfTextField > getKeyboardHeight(notification){
                view.frame.origin.y -= getKeyboardHeight(notification)
            }
        }
    }
    @objc func keyboardWillHide(_ notification: Notification){
        view.frame.origin.y = 0
    }
    
    //MARK: -Save Image, Share and Cancel.
    func save() {
            // Create the meme
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
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
