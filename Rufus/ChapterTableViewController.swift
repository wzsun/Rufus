//
//  ChapterTableViewController.swift
//  manga
//
//  Created by Wesley Sun on 6/12/15.
//  Copyright (c) 2015 Wesley Sun. All rights reserved.
//

import UIKit

extension String {
    var htmlToString:String {
        return NSAttributedString(data: dataUsingEncoding(NSUTF8StringEncoding)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil, error: nil)!.string
    }
    var htmlToNSAttributedString:NSAttributedString {
        return NSAttributedString(data: dataUsingEncoding(NSUTF8StringEncoding)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil, error: nil)!
    }
}

class ChapterTableViewController: UITableViewController{
    
    // store relevant information
    var chapterLink: NSMutableArray = []
    var chapterName: NSMutableArray = []
    var chapterNumber: NSMutableArray = []
    var volumeNumber: NSMutableArray = []
    var mangaName:String = ""
    var originalMangaName = ""
    var boxView:UIView!
    
    override func viewDidLoad() {
        
        self.title = "Loading"
        // puts in user initiated thread
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
        
            self.getChapterLinks(self.mangaName)
            dispatch_async(dispatch_get_main_queue()) { // Get main thread to update
                self.title = self.originalMangaName
                self.tableView.reloadData()
                self.title = self.originalMangaName
            }
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func getChapterLinks(mangaName:String){
        
        // format the mangaName to get correct link
        var name = mangaName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        name = name.stringByReplacingOccurrencesOfString("'", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
        name = name.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
        name = name.stringByReplacingOccurrencesOfString(":", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        name = name.stringByReplacingOccurrencesOfString("(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        name = name.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        // Able to get the URL of the manga chapter list
        let url = NSURL(string: "http://kissmanga.com/Manga/" + name)
        var html = NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding, error: nil)
        
        // Check if we actually recieved anything, if so then we continue the parsing
        if html != nil{
            
            // finds the title name
            let titleIndex = html!.rangeOfString("bigChar");
            var findTitle = html!.substringFromIndex(titleIndex.location)
            let titleStartIndex = findTitle.rangeOfString(">")
            let titleEndIndex = findTitle.rangeOfString("<")
            
            findTitle = findTitle.substringWithRange(titleStartIndex!.endIndex...titleEndIndex!.startIndex.predecessor())
            
            let htmlCheck = findTitle.rangeOfString("&")
            if htmlCheck == nil{
                originalMangaName = findTitle
            }else{
                originalMangaName = findTitle.htmlToString
            }
            
            
            var index = html!.rangeOfString("<table class=\"listing\">")
            html = html?.substringFromIndex(index.location)
            index = html!.rangeOfString("</table>")
            html = html?.substringToIndex(index.location)
            
            // start loop
            while(true){
                let startIndex:NSRange = html!.rangeOfString("<a")
                if startIndex.location == NSNotFound{
                    break
                }
                let endIndex:NSRange = html!.rangeOfString("</a>")
                let tempSection = html!.substringWithRange(NSRange(location : startIndex.location, length : endIndex.location - startIndex.location)) as NSString
                // Gets Link
                var startIndex2 = tempSection.rangeOfString("/")
                let endIndex2 = tempSection.rangeOfString("title")
                var tempLink = tempSection.substringWithRange(NSRange(location : startIndex2.location, length : endIndex2.location - startIndex2.location))
                tempLink = tempLink.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                tempLink = tempLink.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                
                // Gets Name and Number
                startIndex2 = tempSection.rangeOfString("\n")
                var tempName = tempSection.substringFromIndex(startIndex2.location + startIndex2.length)
                
                // parse function
                
                parseChapNum(tempName)
                
                chapterLink.addObject(tempLink)
                html = html!.substringFromIndex(endIndex.location+endIndex.length)
            }
        }else{
            // Shows error
            chapterName.addObject("error")
        }
        
    }
    
    func parseChapNum(input: String){
        var tempName = input
        // --------------------------------------------------------------------------------------
        // Parse this shit into sections like a boss
        tempName = tempName.stringByReplacingOccurrencesOfString(originalMangaName, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        tempName = tempName.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
        tempName = tempName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var nextIndication = tempName.rangeOfString("Ch.")
        
        if nextIndication == nil{
            nextIndication = tempName.rangeOfString("Ep.")
            if nextIndication == nil{
                nextIndication = tempName.rangeOfString("Chapter")
                if nextIndication == nil{
                    nextIndication = tempName.rangeOfString(tempName)
                }
            }
        }
        
        var nextSpace = tempName.rangeOfString(" ")
        let volCheck = tempName.rangeOfString("Vol.")
        
        if nextSpace == nil{
            // store chapter num
            chapterNumber.addObject(tempName)
            
            // no name
            chapterName.addObject("Unknown Chapter Name")
            
            // no volume
            volumeNumber.addObject("N/A")
        }else if nextIndication!.endIndex == nextSpace!.startIndex{ // Parses if there is a space between chapter and number
            var chapterNum = tempName.substringFromIndex(nextSpace!.endIndex)
            nextSpace = chapterNum.rangeOfString(" ")
            if nextSpace == nil{
                // store chapter num
                chapterNumber.addObject(chapterNum)
                
                // say theres no chapter name
                chapterName.addObject("Unknown Chapter Name")
                
                // no volume number
                volumeNumber.addObject("N/A")
            }else{
                chapterNum = chapterNum.substringToIndex(nextSpace!.endIndex)
                chapterNum = chapterNum.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                chapterNum = chapterNum.stringByTrimmingCharactersInSet(NSCharacterSet.letterCharacterSet())
                chapterNum = chapterNum.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                chapterNumber.addObject(chapterNum)
                // We have the chapter num now
                
                tempName = tempName.substringFromIndex(nextSpace!.endIndex)
                nextSpace = tempName.rangeOfString(" ")
                tempName = tempName.substringFromIndex(nextSpace!.endIndex)
                tempName = tempName.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                tempName = tempName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                let readOnlineCheck = tempName.rangeOfString("Read Online")
                if readOnlineCheck != nil{
                    chapterName.addObject("Unknown Chapter Name")
                }else{
                    let htmlCheck = tempName.rangeOfString("&")
                    if htmlCheck == nil{
                        chapterName.addObject(tempName)
                    }else{
                        dispatch_async(dispatch_get_main_queue()) {
                        self.chapterName.addObject(tempName.htmlToString)
                        //chapterName.addObject(tempName)
                        }
                    }
                    
                }
                // We have the name of the chapter now
                
                volumeNumber.addObject("N/A")
                // no volume number
            }
        }else if volCheck != nil{ // Parses if there is a volume label
            
            var volNum = tempName.substringToIndex(nextSpace!.endIndex)
            volNum = volNum.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            volNum = volNum.stringByTrimmingCharactersInSet(NSCharacterSet.letterCharacterSet())
            volNum = volNum.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
            volumeNumber.addObject(volNum)
            // got volume num
            
            tempName = tempName.substringFromIndex(nextSpace!.endIndex)
            nextSpace = tempName.rangeOfString(" ")
            var chapterNum = tempName.substringToIndex(nextSpace!.startIndex)
            chapterNum = chapterNum.stringByTrimmingCharactersInSet(NSCharacterSet.letterCharacterSet())
            chapterNum = chapterNum.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
            chapterNum = chapterNum.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            chapterNumber.addObject(chapterNum)
            // get chapter num
            
            tempName = tempName.substringFromIndex(nextSpace!.endIndex)
            tempName = tempName.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
            tempName = tempName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let readOnlineCheck = tempName.rangeOfString("Read Online")
            if readOnlineCheck != nil{
                chapterName.addObject("Unknown Chapter Name")
            }else{
                let htmlCheck = tempName.rangeOfString("&")
                if htmlCheck == nil{
                    chapterName.addObject(tempName)
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                    self.chapterName.addObject(tempName.htmlToString)
                    //chapterName.addObject(tempName)
                    }
                }
            }
            // get chapter name
            
        }else{ // Catch all parse
            var chapterNum = tempName.substringToIndex(nextSpace!.endIndex)
            chapterNum = chapterNum.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            chapterNum = chapterNum.stringByTrimmingCharactersInSet(NSCharacterSet.letterCharacterSet())
            chapterNum = chapterNum.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
            chapterNumber.addObject(chapterNum)
            // got chapter num
            
            tempName = tempName.substringFromIndex(nextSpace!.endIndex)
            tempName = tempName.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
            tempName = tempName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let readOnlineCheck = tempName.rangeOfString("Read Online")
            if readOnlineCheck != nil{
                chapterName.addObject("Unknown Chapter Name")
            }else{
                let htmlCheck = tempName.rangeOfString("&")
                if htmlCheck == nil{
                    chapterName.addObject(tempName)
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                    self.chapterName.addObject(tempName.htmlToString)
                    //chapterName.addObject(tempName)
                    }
                }
            }
            // get chapter name
            
            volumeNumber.addObject("N/A")
            // no volume number
        }
        // --------------------------------------------------------------------------------------
    }
    
    func loadingBar(){
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
        
    }
    
    func closeLoadingBar(){
        // removes  activity indicator view
        boxView.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // How many sections do we have
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    // How many rows do we have
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return chapterName.count
    }

    // This is where we configure the cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        
        
        // Configure the cell...
        if chapterName[indexPath.row] as! String == "error"{
            cell.textLabel!.text = "Sorry, couldn't find your request"
            cell.detailTextLabel?.text = "Did you spell the manga name correctly?"

        }else{
            
            // Label the cell with our info
            cell.textLabel!.text = chapterName[indexPath.row] as! String
            if volumeNumber[indexPath.row] as! String != "N/A"{
                let detailString = "Volume " + (volumeNumber[indexPath.row] as! String) + ", Chapter " + (chapterNumber[indexPath.row] as! String)
                cell.detailTextLabel?.text = detailString
            }else{
                let detailString = "Chapter " + (chapterNumber[indexPath.row] as! String)
                cell.detailTextLabel?.text = detailString
            }
        }
        return cell
    }
    
    // This is where we make it so that it can't be selected if it throws an error
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if chapterName[indexPath.row] as! String == "error"{
            return nil
        }
        return indexPath
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        var mangaScene = segue.destinationViewController as! ImageViewController
        if let indexPath = self.tableView.indexPathForSelectedRow(){
            let link = chapterLink[indexPath.row] as! String
            mangaScene.link = link
            mangaScene.chapterNum = chapterNumber[indexPath.row] as! String
            
        }
    }

    

}
