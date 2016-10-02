//
//  PhotoAlbum.swift
//  ZenHack
//
//  Created by kojpkn on 2016/10/02.
//  Copyright © 2016年 KazushiKawamura. All rights reserved.
//
// Must import AssetsLibrary.framework(Required), Photos.framework(Optional) from Targets > General > Linked Frameworks and Libraries
import Photos
import AssetsLibrary

enum PhotoAlbumUtilResult {
    case SUCCESS, ERROR, DENIED
}

class PhotoAlbumUtil: NSObject {
    
    class func isAuthorized() -> Bool {
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue < 8 {
            return ALAssetsLibrary.authorizationStatus() == ALAuthorizationStatus.Authorized || ALAssetsLibrary.authorizationStatus() == ALAuthorizationStatus.NotDetermined
        } else {
            return PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized || PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.NotDetermined
        }
    }
    
    class func saveImageInAlbum(image: UIImage, albumName: String, completion: ((result: PhotoAlbumUtilResult) -> ())?) {
        
        if albumName.isEmpty {
            completion?(result: .ERROR)
            return
        }
        
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue < 8 {
            if  !isAuthorized() {
                completion?(result: .DENIED)
                return
            }
            var found = false
            let library = ALAssetsLibrary()
            library.enumerateGroupsWithTypes(ALAssetsGroupAlbum, usingBlock: { (group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) in
                if group != nil {
                    if albumName == group.valueForProperty(ALAssetsGroupPropertyName) as! String {
                        found = true
                        library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!, completionBlock: { (assetUrl: NSURL!, error: NSError!) in
                            library.assetForURL(assetUrl, resultBlock: { (asset: ALAsset!) in
                                group.addAsset(asset)
                                completion?(result: .SUCCESS)
                                }, failureBlock: { (error: NSError!) in
                                    print(error.localizedDescription)
                                    completion?(result: .ERROR)
                            })
                        })
                    }
                } else {
                    if !found {
                        library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!, completionBlock: { (assetUrl: NSURL!, error: NSError!) in
                            library.addAssetsGroupAlbumWithName(albumName, resultBlock: { (group: ALAssetsGroup!) in
                                library.assetForURL(assetUrl, resultBlock: { (asset: ALAsset!) in
                                    group.addAsset(asset)
                                    completion?(result: .SUCCESS)
                                    }, failureBlock: { (error: NSError!) in
                                        print(error.localizedDescription)
                                        completion?(result: .ERROR)
                                })
                                }, failureBlock:  { (error: NSError!) in
                                    print(error.localizedDescription)
                                    completion?(result: .ERROR)
                            })
                        })
                    }
                }
                }, failureBlock:  { (error: NSError!) in
                    print(error.localizedDescription)
                    completion?(result: .ERROR)
            })
        } else {
            if  !isAuthorized() {
                completion?(result: .DENIED)
                return
            }
            var assetAlbum: PHAssetCollection?
            let list = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: nil)
            list.enumerateObjectsUsingBlock{ (album, index, isStop) in
                let assetCollection = album as! PHAssetCollection
                if albumName == assetCollection.localizedTitle {
                    assetAlbum = assetCollection
                    isStop.memory = true
                }
            }
            if let album = assetAlbum {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    let result = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                    let assetPlaceholder = result.placeholderForCreatedAsset
                    let albumChangeRequset = PHAssetCollectionChangeRequest(forAssetCollection: album)
                    let enumeration: NSArray = [assetPlaceholder!]
                    albumChangeRequset!.addAssets(enumeration)
                    }, completionHandler: { (isSuccess, error) -> Void in
                        if isSuccess {
                            completion?(result: .SUCCESS)
                        } else{
                            print(error!.localizedDescription)
                            completion?(result: .ERROR)
                        }
                        
                })
            } else {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName)
                    }, completionHandler: { (isSuccess, error) in
                        self.saveImageInAlbum(image, albumName: albumName, completion: completion)
                })
            }
        }
    }
    
}