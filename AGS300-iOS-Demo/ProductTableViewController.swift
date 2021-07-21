//
//  ProductTableViewController.swift
//  AGS300-iOS-Demo
//
//  Created by Vadym Ustymenko on 3/11/20.
//  Copyright © 2020 VUES. All rights reserved.
//

import UIKit

class ProductTableViewController: UITableViewController {
    
    let productData = [
        // Section 1
        [   ["Product Header"],
            ["Product-AA", "Adobe Analytics", "subtitle", "#9F7FFF"],
             ["Product-AT", "Adobe Target", "subtitle", "#17D8FF"],
             ["Product-AC", "Adobe Campaign", "subtitle", "#D4F10D"],
             ["Product-AAM", "Adobe Audience Manager", "subtitle", "#6390FF"],
             ["Product-AEM", "Adobe Experience Manager", "subtitle", "#FF7618"],
            ["Product-AEP", "Adobe Experience Platform", "subtitle", "#F90025"]
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tableView.register(UITableViewCell.self, forCellWithReuseIdentifier: "cell")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("in viewWillAppear")
        
        self.getTargetOffers()
        
    }
     
    
    //MARK: table delegates
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSections \(productData.count)")
        return productData.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection \(productData[0].count-1)")
        return productData[0].count-1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        
        //let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "mycell")
        
        
        let cellData = productData[indexPath.section][indexPath.row + 1]
        // Configure the cell...
        
        print("cellData \(cellData[1]) \(cellData[2])")
        
        //cell.imageView?.image = UIImage(named: cellData[0])
        cell.imageView?.image = imageWithImage(image: UIImage(named: cellData[0])!, scaledToSize: CGSize(width: 50, height: 50))

        cell.imageView?.tintColor = UIColor(hexString: cellData[3] )
        cell.textLabel?.text = cellData[1]
        cell.detailTextLabel?.text = cellData[2]
        
        let buyNowLabel = UILabel()
        buyNowLabel.frame = CGRect(x: 0, y: 0, width: 70, height: 20)
        buyNowLabel.text = "Order >"
//        buyNowLabel.backgroundColor = UIColor.blue
//        buyNowLabel.textColor = UIColor.white
        cell.accessoryView = buyNowLabel
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "orderViewController", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: Target Implementation

extension ProductTableViewController{
    
    @objc func getTargetOffers(){
        print("in getTargetOffers")
        // Handle prefetched content
        AEPSDKManager.getLocation(forKey: .GlobalPage, location: "sdk-demo-4") { (content) in
            print("getTargetOffers content \(String(describing: content))")
            if let message = AEPSDKManager.getJsonValueFromTargetOffer(key: "promocode", response: content),
                message.count > 0 {
                    print("Target message \(message)")
                    DispatchQueue.main.async {
                        
                        //self.messageView.text = message
                        let alertController = UIAlertController(title: "Promotion", message: "Promotion found in your area. Use Promo code \(message) in Checkout", preferredStyle: .alert)

                        // Create the actions
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            print("OK Pressed")
                        }
                        /*let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                            UIAlertAction in
                            print("Cancel Pressed")
                        }*/
                        alertController.addAction(okAction)
                        //alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
            }
        }

    }
    
    func imageWithImage(image:UIImage,scaledToSize newSize:CGSize)->UIImage{

      UIGraphicsBeginImageContext( newSize )
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
        return (newImage?.withRenderingMode(.alwaysTemplate))!
    }
    
    
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
