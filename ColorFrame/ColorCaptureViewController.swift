//
//  CameraVC.swift
//  ColorFrame
//
//  Created by vidhi on 13/06/22.
//

import UIKit
import AVFoundation
import Vision
import CoreML


class ColorCaptureViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        setUpViews()
        enableConstraints()
    }
    
    // MARK: - Private methods
    
    private func setUpViews() {
        view.addSubview(colorNameLbl)
        view.addSubview(captureButton)
        view.addSubview(cropColorImageView)
        view.addSubview(colorImageView)
        
    }
    
    private func enableConstraints() {
        
        colorNameLbl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 10).isActive = true
        colorNameLbl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 10).isActive = true
        colorNameLbl.centerXAnchor.constraint(equalTo:  self.view.centerXAnchor).isActive = true
        
        colorImageView.topAnchor.constraint(equalTo: self.colorNameLbl.bottomAnchor,constant: 40).isActive = true
        //        colorImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 10).isActive = true
        //        colorImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -10).isActive = true
        colorImageView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        colorImageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        colorImageView.centerXAnchor.constraint(equalTo: colorNameLbl.centerXAnchor).isActive = true
        
        
        
        cropColorImageView.topAnchor.constraint(equalTo: self.colorImageView.bottomAnchor,constant: 20).isActive = true
        cropColorImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 10).isActive = true
        cropColorImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -10).isActive = true
        cropColorImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        captureButton.topAnchor.constraint(equalTo: self.cropColorImageView.bottomAnchor,constant: 20).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -50).isActive = true
        captureButton.centerXAnchor.constraint(equalTo:  self.colorImageView.centerXAnchor).isActive = true
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            let superview = gesture.view?.superview
            let superviewSize = superview?.bounds.size
            let thisSize = gesture.view?.frame.size
            var translation = gesture.translation(in: self.view)
            var center = CGPoint(x: gesture.view!.center.x + translation.x, y: gesture.view!.center.y + translation.y)
            var resetTranslation = CGPoint(x: translation.x, y: translation.y)
            
            if center.x - (thisSize?.width)!/2 < 0 {
                center.x = (thisSize?.width)!/2
            } else if center.x + (thisSize?.width)!/2 > (superviewSize?.width)! {
                center.x = (superviewSize?.width)!-(thisSize?.width)!/2
            } else {
                resetTranslation.x = 0 //Only reset the horizontal translation if the view *did* translate horizontally
            }
            
            if center.y - (thisSize?.height)!/2 < 0 {
                center.y = (thisSize?.height)!/2
            } else if center.y + (thisSize?.height)!/2 > (superviewSize?.height)! {
                center.y = (superviewSize?.height)!-(thisSize?.height)!/2
            } else {
                resetTranslation.y = 0 //Only reset the vertical translation if the view *did* translate vertically
            }
            
            gesture.view?.center = center
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
            
            
            translation = gesture.translation(in: colorImageView)
            cropView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            frm = cropView.frame
            frm.origin.x = frm.origin.x
            frm.origin.y = frm.origin.y
            frm.size.width = frm.size.width
            frm.size.height = frm.size.height
            print(frm)
            
            
        } else if gesture.state == .ended {
            let superview = gesture.view?.superview
            let superviewSize = superview?.bounds.size
            let thisSize = gesture.view?.frame.size
            let translation = gesture.translation(in: self.view)
            var center = CGPoint(x: gesture.view!.center.x + translation.x, y: gesture.view!.center.y + translation.y)
            var resetTranslation = CGPoint(x: translation.x, y: translation.y)
            
            if center.x - (thisSize?.width)!/2 < 0 {
                center.x = (thisSize?.width)!/2
            } else if center.x + (thisSize?.width)!/2 > (superviewSize?.width)! {
                center.x = (superviewSize?.width)!-(thisSize?.width)!/2
            } else {
                resetTranslation.x = 0
            }
            
            if center.y - (thisSize?.height)!/2 < 0 {
                center.y = (thisSize?.height)!/2
            } else if center.y + (thisSize?.height)!/2 > (superviewSize?.height)! {
                center.y = (superviewSize?.height)!-(thisSize?.height)!/2
            } else {
                resetTranslation.y = 0
            }
            
            gesture.view?.center = center
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
            
            modelConfig()
            
        }
    }
    
    @objc private func captureButtonDidPress() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerController.SourceType.camera;
            imagePickerController.view?.isUserInteractionEnabled = true
            self.present(imagePickerController, animated: true, completion: nil)
            
        }
    }
    
    // MARK: - Private variables
    
    private lazy var captureButton: UIButton = {
        let captureButton = UIButton()
        captureButton.setTitle("Scan Image", for: .normal)
        captureButton.setTitleColor(UIColor.black, for: .normal)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        captureButton.addTarget(self, action: #selector(captureButtonDidPress), for: .touchUpInside)
        return captureButton
    }()
    
    private lazy var colorNameLbl: UILabel = {
        let colorNameLbl = UILabel()
        colorNameLbl.translatesAutoresizingMaskIntoConstraints = false
        colorNameLbl.textAlignment = .center
        colorNameLbl.font = colorNameLbl.font.withSize(60)
        return colorNameLbl
    }()
    
    private lazy var cropView: UIView = {
        let Cropview = UIView()
        Cropview.backgroundColor = .clear
        Cropview.layer.borderColor = UIColor.yellow.cgColor
        Cropview.layer.borderWidth = 2.0
        Cropview.translatesAutoresizingMaskIntoConstraints = false
        return Cropview
    }()
    
    private lazy var colorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var cropColorImageView: UIImageView = {
        let colorView = UIImageView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        return colorView
    }()
    
    private let imagePickerController = UIImagePickerController()
    var translation = CGPoint()
    var frm =  CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
    private var cropImage = UIImage()
    var resizeImage = UIImage()
    
    func modelConfig() {
        print("originalSize\(colorImageView.image?.size)")
        cropImage = cropImage2(image: resizeImage, rect: frm, scale: 1.0) ?? UIImage()
        cropColorImageView.image = cropImage
        print("CropSize\(cropImage.size)")
        
        let model: ColorModel = {
            do {
                let config = MLModelConfiguration()
                return try ColorModel(configuration: config)
            } catch {
                print(error)
                fatalError("Couldn't get color")
            }
        }()
        
        guard let model = try? VNCoreMLModel(for: model.model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            guard let result = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let fristObservation = result.first else {
                return }
            DispatchQueue.main.async {
                self.colorNameLbl.text = fristObservation.identifier
                self.colorNameLbl.textColor = UIColor.init(hex: fristObservation.identifier.uppercased()).hexDescription().hexStringToUIColor()
            }
        }
        
        guard let cgImage = cropImage.convertImageToCGImage() else {
            return
        }
        
        try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ColorCaptureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            dismiss(animated: true)
            colorImageView.addSubview(cropView)
            
            colorImageView.isUserInteractionEnabled = true
            cropView.clipsToBounds = false
            cropView.isUserInteractionEnabled = true
            cropView.widthAnchor.constraint(equalToConstant: 50).isActive = true
            cropView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            cropView.centerXAnchor.constraint(equalTo:  colorImageView.centerXAnchor).isActive = true
            cropView.centerYAnchor.constraint(equalTo: colorImageView.centerYAnchor).isActive = true
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
            cropView.addGestureRecognizer(gesture)
            // cropView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture)))
        }
        
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        let finalImage = image.fixOrientation()
        resizeImage = finalImage.resize(finalImage,imageViewHeight:colorImageView.frame.height ,imageWidth: colorImageView.frame.width)
        colorImageView.image = resizeImage
    }
    
    func cropImage2(image: UIImage, rect: CGRect, scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width / scale, height: rect.size.height / scale), true, 0.0)
        image.draw(at: CGPoint(x: -rect.origin.x / scale, y: -rect.origin.y / scale))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
}





