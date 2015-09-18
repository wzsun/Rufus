//
//  SearchViewController.swift
//  manga
//
//  Created by Wesley Sun on 6/13/15.
//  Copyright (c) 2015 Wesley Sun. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, UITextFieldDelegate {

    var boxView:UIView!
    @IBOutlet weak var textField: UITextField!
    @IBAction func searchButton(sender: AnyObject) {
        
//        textField.resignFirstResponder()
//        if textField.text == "index"{
//            getMangaIndex()
//            println(mangaList.count)
//        }
    }
    
//    // Head object for CoreData
//    var mangaList = [NSManagedObject]()
//    
//    func saveList(name: String, link: String) {
//        
//        //1 get the "in memory sketch pad" to store shit
//        let appDelegate =
//        UIApplication.sharedApplication().delegate as! AppDelegate
//        
//        let managedContext = appDelegate.managedObjectContext!
//        
//        // Dunno what this shit does, wraps it
//        let entity =  NSEntityDescription.entityForName("MangaList",
//            inManagedObjectContext:
//            managedContext)
//        
//        let manga = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
//        
//        // Saves to the key
//        manga.setValue(name, forKey: "name")
//        manga.setValue(link, forKey: "link")
//        
//        // Check for errors
//        var error: NSError?
//        if !managedContext.save(&error) {
//            println("Could not save \(error), \(error?.userInfo)")
//        }  
//        // Commit the changes
//        mangaList.append(manga)
//        
//    }
    
    // Gets the manga index list
    func getMangaIndex(){
        
        
        let link = "http://kissmanga.com/MangaList?page="
        
        let url = NSURL(string: "http://kissmanga.com/MangaList?page=1")
        var html = NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding, error: nil)
        
        var lastIndex = html!.rangeOfString("Next")
        var lastIndex2 = html!.rangeOfString("Last")
        var lastPage:NSString = html!.substringWithRange(NSRange(location: lastIndex.location, length: lastIndex2.location - lastIndex.location))
        
        lastIndex = lastPage.rangeOfString("page=\"")
        lastIndex2 = lastPage.rangeOfString("\">")
        
        
        lastPage = lastPage.substringWithRange(NSRange(location:lastIndex.location+lastIndex.length, length: lastIndex2.location-lastIndex.location-lastIndex.length))
        
        for x in 0...1{
            
            let tempURL = NSURL(string: link + String(x))
            //println(tempURL)
            var html = NSString(contentsOfURL: tempURL!, encoding: NSUTF8StringEncoding, error: nil)
            
            var startIndex = html!.rangeOfString("<tr class=\"odd")
            html = html!.substringFromIndex(startIndex.location)
            var endIndex = html!.rangeOfString("</table")
            html = html!.substringToIndex(endIndex.location)
            //println(html)
            while(true){
                // get the elements piece by piece and parse now
                startIndex = html!.rangeOfString("<tr")
                if startIndex.location == NSNotFound{
                    break
                }
                endIndex = html!.rangeOfString("</tr")
                let endSegment = endIndex
                
                var tempHtml:NSString = html!.substringWithRange(NSRange(location:startIndex.location, length: endIndex.location - startIndex.location))
                
                // find the <a> tags
                startIndex = tempHtml.rangeOfString("<a")
                endIndex = tempHtml.rangeOfString("</a")
                tempHtml = tempHtml.substringWithRange(NSRange(location:startIndex.location, length:endIndex.location - startIndex.location))
                
                // find href reference
                startIndex = tempHtml.rangeOfString("href=\"")
                endIndex = tempHtml.rangeOfString(">")
                var link = tempHtml.substringWithRange(NSRange(location: startIndex.location + startIndex.length, length:endIndex.location - startIndex.location - startIndex.length))
                //println(link)
                var name = tempHtml.substringFromIndex(endIndex.location.successor())
                
                // part of auto complete
                //saveList(name, link: link)
                
                html = html!.substringFromIndex(endSegment.location + endSegment.length)
            }
        }

    }
    

    
    // Makes keyboard dissapear after hitting a blank area on the screen
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
//    func checkDatabase(input:String){
//        for x in mangaList{
//            println(input)
//            let actualName = x.valueForKey("name") as! String
//            let check = x.valueForKey("name")!.rangeOfString(input).location
//            if check < count(actualName){
//                println(input)
//                println(check)
//                println(x.valueForKey("name"))
//            }
//        }
//    }
    
//    // auto complete
//    let userInputCount = 1
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        let text = textField.text
//        
//        if  count(text) > userInputCount{
//            
//            checkDatabase(textField.text)
//        }
//        return true
//    }
    
    // make keyboard go away and perform segue when return button is pushed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        //if textField.text != "index"{
            performSegueWithIdentifier("pushToChapter", sender: nil)
//        }else{
//            getMangaIndex()
//            println(mangaList[0].valueForKey("link"))
//        }
        return true
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if textField.text == ""{
            return false
        }else{
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gets iphone screen size
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let imgWidth = screenWidth
        
        // load up super image
        var img = UIImage(named: "opmimage")
        var imgView = UIImageView(image: img)
        imgView.alpha = 0.75
        
        let imgHeight = imgWidth/img!.size.width * img!.size.height
        imgView.frame = CGRectMake(view.frame.midX - imgWidth/2,view.frame.midY*2 - imgHeight,imgWidth,imgHeight)
        self.view.addSubview(imgView)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        // make keyboard go away
        textField.resignFirstResponder()
        
        var chapterList = segue.destinationViewController as! ChapterTableViewController
    
        chapterList.mangaName = textField.text
    
    }


}
