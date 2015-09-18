//
//  ViewController.swift
//  manga
//
//  Created by Wesley Sun on 6/12/15.
//  Copyright (c) 2015 Wesley Sun. All rights reserved.
//


import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var containerView: UIView!
    var link:String = ""
    var chapterNum = ""
    var boxView:UIView!
    
    // Parses the chapter link to get the relevant pictures
    func getPictures(html: NSString){
        
        // finds location of area we want to parse
        let index = html.rangeOfString("lstImages.push")
        let endindex = html.rangeOfString("var lstImagesLoaded = new Array();")
        let length = endindex.location - index.location
        
        var text = html.substringWithRange(NSRange(location : index.location,length : length)) as NSString
        
        var array : NSMutableArray = []
        var check = true
        
        // loop that finds all images
        while(true){
            var start = text.rangeOfString("(\"")
            var end = text.rangeOfString("\");")
            if end.location == NSNotFound{
                break
            }
            
            var temptext = text.substringWithRange(NSRange(location : start.location + start.length, length : end.location - start.location - start.length))
            
            array.addObject(temptext)
            text = text.substringFromIndex(end.location+end.length)
            
        }
        
        var pageImages: NSMutableArray = []
        var totalHeight : CGFloat = 0
        var totalWidth : CGFloat = 0
        let bestHeight : CGFloat
        let bestWidth : CGFloat
        
        for x in array{
            var imgurl = NSURL(string: x as! String)
            var dataurl = NSData(contentsOfURL: imgurl!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            var img = UIImage(data: dataurl!)
            
            let tw = img!.size.width
            if totalWidth < tw {
                totalWidth = tw
            }
            
            pageImages.addObject(img!)
            
        }
        
        // here we get the idea image sizes
        bestHeight = pageImages[Int(pageImages.count/3)].size.height
        bestWidth = pageImages[Int(pageImages.count/3)].size.width
        
        // room for error
        let RFE: CGFloat = 5
        
        totalHeight = 0
        for pi in pageImages{
            let th = bestWidth/pi.size.width * pi.size.height
            totalHeight += th
        }
        
        // Adds the space between images into total height
        let spaceBetweenImages:CGFloat = 0
        totalHeight += spaceBetweenImages * CGFloat(pageImages.count - 1)
        
        var containerSize = CGSize(width: bestWidth, height: totalHeight)
        containerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size:containerSize))
        scrollView.addSubview(containerView)
        
        totalHeight = 0;
        for pi in pageImages{
            let th = bestWidth/pi.size.width * pi.size.height
            var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: bestWidth, height: th))
            imageView.image = pi as! UIImage
            imageView.center = CGPoint(x:bestWidth/2, y: th/2 + totalHeight)
            
            // This is where the space in between images was updated
            totalHeight += th + spaceBetweenImages
            containerView.addSubview(imageView)
        }
        
        scrollView.contentSize = containerSize
        
        
        // Gets iphone screen size
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        // Fixes zoom to fit from initial point
        let scrollViewFrame = scrollView.frame
        let scaleWidth = screenWidth / scrollView.contentSize.width
        scrollView.minimumZoomScale = scaleWidth;
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = scaleWidth
    
        // removes  activity indicator view
        boxView.removeFromSuperview()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // -----------------
        // Show activity indicator view
        // You only need to adjust this frame to move it anywhere you want
        boxView = UIView(frame: CGRect(x: view.frame.midX - 65, y: view.frame.midY - 100, width: 130, height: 50))
        boxView.backgroundColor = UIColor.blackColor()
        boxView.alpha = 0.8
        boxView.layer.cornerRadius = 10
        
        //Here the spinnier is initialized
        var activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        var textLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.whiteColor()
        textLabel.text = "Loading"
        textLabel.font = UIFont.boldSystemFontOfSize(16.0)
        
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        
        self.view.addSubview(boxView)
        // -----------------
        
        let url = NSURL(string: "http://kissmanga.com/" + link)
        
        // use async request to get images
        let request = NSURLRequest(URL: url!)
        var myHTMLString:NSString
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            if error == nil{
                self.title = "Chapter " + self.chapterNum
                self.getPictures(NSString(data: data, encoding: NSUTF8StringEncoding)!)
            }else{
                self.title = "Error"
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Delegate function to allow for zooming
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
    
    
}


