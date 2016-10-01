//
//  ViewController.swift
//  paintPallet
//
//  Created by 山口智生 on 2015/10/24.
//  Copyright © 2015年 Tomoki Yamaguchi. All rights reserved.
//

import UIKit

class DrawableViewController: UIViewController, DrawableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var drawableView: DrawableView! = nil
    
    var undoButton: UIButton! = nil
    var saveButton: UIButton! = nil
    var clearButton: UIButton! = nil
    var blackButton: UIButton! = nil
    var redButton: UIButton! = nil
//    var loadButton: UIButton! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        let buttonWidth = self.view.bounds.width/5
        
        if drawableView == nil {
            drawableView = DrawableView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.width))
            drawableView.backgroundColor = UIColor.clearColor()
            drawableView.delegate = self
            self.view.addSubview(drawableView)
        }
        
        if undoButton == nil {
            undoButton = UIButton(frame: CGRectMake(0, 0, buttonWidth, 100))
            undoButton.backgroundColor = UIColor.yellowColor()
            undoButton.setTitle("undo", forState: .Normal)
            undoButton.setTitleColor(UIColor.brownColor(), forState: .Normal)
            undoButton.addTarget(drawableView, action: #selector(NSUndoManager.undo), forControlEvents: .TouchUpInside)
//            self.view.addSubview(undoButton)
        }
        if blackButton == nil {
            blackButton = UIButton(frame: CGRectMake(buttonWidth*2, 0, buttonWidth, 100))
            blackButton.backgroundColor = UIColor.blackColor()
            blackButton.setTitle("Blackcol", forState: .Normal)
            blackButton.setTitleColor(UIColor.brownColor(), forState: .Normal)
            blackButton.addTarget(drawableView, action: Selector("selectBlack"), forControlEvents: .TouchUpInside)
//            self.view.addSubview(blackButton)
        }
        if redButton == nil {
            redButton = UIButton(frame: CGRectMake(buttonWidth*3, 0, buttonWidth, 100))
            redButton.backgroundColor = UIColor.yellowColor()
            redButton.setTitle("Redcol", forState: .Normal)
            redButton.setTitleColor(UIColor.redColor(), forState: .Normal)
            redButton.addTarget(drawableView, action: Selector("selectRed"), forControlEvents: .TouchUpInside)
//            self.view.addSubview(redButton)
        }
        
        if clearButton == nil {
            clearButton = UIButton(frame: CGRectMake(buttonWidth*1, 0, buttonWidth, 100))
            clearButton.backgroundColor = UIColor.greenColor()
            clearButton.setTitle("clear", forState: .Normal)
            clearButton.setTitleColor(UIColor.brownColor(), forState: .Normal)
            clearButton.addTarget(drawableView, action: #selector(CIImageAccumulator.clear), forControlEvents: .TouchUpInside)
//            self.view.addSubview(clearButton)
        }
        
        if saveButton == nil {
            saveButton = UIButton(frame: CGRectMake(buttonWidth*4, 0, buttonWidth, 100))
            saveButton.backgroundColor = UIColor.cyanColor()
            saveButton.setTitle("save", forState: .Normal)
            saveButton.setTitleColor(UIColor.brownColor(), forState: .Normal)
            saveButton.addTarget(drawableView, action: Selector("save"), forControlEvents: .TouchUpInside)
//            self.view.addSubview(saveButton)
        }
        
    }
    
    
//    func load() {
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
//            let ipc: UIImagePickerController = UIImagePickerController()
//            ipc.delegate = self
//            ipc.allowsEditing = true
//            
//            ipc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//            
//            self.presentViewController(ipc, animated:true, completion:nil)
//        }
//    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        drawableView.setBackgroundImage(image)
    }
    
    func onUpdateDrawableView() {
        
    }
    
    func onFinishSave() {
        let alertController = UIAlertController(title: "Saved!", message: "saved to camera roll.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("memoryWarning")
        // Dispose of any resources that can be recreated.
    }


}

