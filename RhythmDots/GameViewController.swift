//
//  GameViewController.swift
//  RhythmDots
//
//  Created by Jorge Rotter on 7/10/18.
//  Copyright © 2018 Eduardo Gil. All rights reserved.
//

import UIKit
import AVFoundation
import MultipeerConnectivity

class GameViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var columnsNumber: Int = 5
    var rowsNumber: Int = 5
    var densityNumber: Int = 50
    var metronome: Bool = true
    var tempo: Double = 60
    var color1: Int = 0
    var color2: Int = 0
    var dots: [UIImage] = [UIImage(named: "black")!, UIImage(named: "red")!, UIImage(named: "orange")!, UIImage(named: "yellow")!, UIImage(named: "green")!, UIImage(named: "blue")!, UIImage(named: "purple")!, UIImage(named: "blank")!]
    var dotsOff: [UIImage] = [UIImage(named: "blackOff")!, UIImage(named: "redOff")!, UIImage(named: "orangeOff")!, UIImage(named: "yellowOff")!, UIImage(named: "greenOff")!, UIImage(named: "blueOff")!, UIImage(named: "purpleOff")!]
    var dotsOn: [UIImage] = [UIImage(named: "blackOn")!, UIImage(named: "redOn")!, UIImage(named: "orangeOn")!, UIImage(named: "yellowOn")!, UIImage(named: "greenOn")!, UIImage(named: "blueOn")!, UIImage(named: "purpleOn")!]
    @IBOutlet weak var gridStackView: UIStackView!
    var gridNumbers: [[Int]] = []
    var linearGrid: [Int] = []
    var stackViews: [UIStackView] = []
    var gridImageViews: [[UIImageView]] = []
    var count = -4
    var timer = Timer()
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    var isPaused: Bool = false
    var click: AVAudioPlayer?
    var url: URL = URL(fileURLWithPath: Bundle.main.path(forResource: "click.mp3", ofType:nil)!)
    
    var master: Bool = false
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var messageToSend: String!
    
    var syncronizationTimer = Timer()
    
    
    var iPhone: Bool!
    var picker: UIPickerView!
    var dataArray = ["English", "Maths", "History", "German", "Science"]
    var blurEffectView: UIVisualEffectView!
    var toolBar: UIToolbar!
    var pickerStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iPhone = isiPhone()
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        

        if master {
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(newGrid))
            tap.numberOfTapsRequired = 2
            repeatButton.addGestureRecognizer(tap)
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeDown.direction = UISwipeGestureRecognizer.Direction.down
            gridStackView.addGestureRecognizer(swipeDown)
            
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeUp.direction = UISwipeGestureRecognizer.Direction.up
            gridStackView.addGestureRecognizer(swipeUp)
            
            createPicker()
            //hidePicker(animation: false)

            newGame()
        }
        else {
            repeatButton.isEnabled = false
            repeatButton.isHidden = true
            playPauseButton.isEnabled = false
            playPauseButton.isHidden = true
            label.text = "Waiting for Master Device to connect..."
        }
        
        if mcSession.connectedPeers.count > 0 {
            if master {
                sendParameters()
                playMode()
            }
        }
        else {
            triggerPairing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func deviceRotated(){
        if master {
            if UIDevice.current.orientation.isLandscape {
                setSizeConstraints(view: blurEffectView, landscape: true)
                setSizeConstraints(view: pickerStackView, landscape: true)
            } else {
                setSizeConstraints(view: blurEffectView, landscape: false)
                setSizeConstraints(view: pickerStackView, landscape: false)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        invalidateTimer()
        if master {
            sendCommand(command: "disconnected")
        }
        else {
            sendCommand(command: "quit")
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        invalidateTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func triggerPairing() {
        if master {
            joinSession()
        }
        else {
            hostSession()
        }
    }
    
    func newGame() {
        fill()
        
        if metronome {
            repeatButton.isEnabled = true
            repeatButton.isHidden = false
            playPauseButton.isEnabled = true
            playPauseButton.isHidden = false
            label.text = "4"
        }
        else {
            repeatButton.isEnabled = false
            repeatButton.isHidden = true
            playPauseButton.isEnabled = false
            playPauseButton.isHidden = true
            label.text = ""
        }
    }
    
    func fill() {
        /*
         @IBOutlet weak var gridStackView: UIStackView!
         var gridNumbers: [[Int]] = []
         var linearGrid: [Int] = []
         var stackViews: [UIStackView] = []
         var gridImageViews: [[UIImageView]] = []
         var count = -4
         */
        for row in 0..<rowsNumber {
            gridNumbers.append([])
            gridImageViews.append([])
            gridStackView.addArrangedSubview(createRow(row: row))
        }
    }
    
    func createRow(row: Int) -> UIStackView {
        var stackView: UIStackView
        var cells: [UIImageView] = []
        for column in 0..<columnsNumber {
            cells.append(createCell(row: row, column: column))
        }
        stackView = createStackView(array: cells)
        stackViews.append(stackView)
        return stackView
    }
    
    func createStackView(array: [UIView]) -> UIStackView {
        var stackView: UIStackView
        stackView = UIStackView(arrangedSubviews: array)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 5
        return stackView
    }
    
    func createCell(row: Int, column: Int) -> UIImageView {
        var image: UIImage
        var imageView: UIImageView
        let number: Int
        if master {
            number = Int(arc4random_uniform(101))
            if number <= densityNumber {
                image = fillCellUpdateGrid(number: Int(arc4random_uniform(2)) + 1, row: row)
            }
            else {
                image = fillCellUpdateGrid(number: 0, row: row)
            }
        }
        else {
            number = linearGrid[0]
            image = fillCellUpdateGrid(number: number, row: row)
            linearGrid.removeFirst(1)
        }
        
        imageView = createImageView(image: image)
        gridImageViews[row].append(imageView)
        return imageView
    }
    
    func fillCellUpdateGrid(number: Int, row: Int) -> UIImage {
        switch number {
        case 1:
            gridNumbers[row].append(1)
            return dots[color1]
        case 2:
            gridNumbers[row].append(2)
            return dots[color2]
        default:
            gridNumbers[row].append(0)
            return UIImage()
        }
    }
    
    func createImageView(image: UIImage) -> UIImageView {
        var imageView: UIImageView
        imageView = UIImageView(image: image)
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        return imageView
    }
    
    @objc func incrementCounter() {
        if count < 0 {
            label.text = String(abs(count))
        }
        else {
            if count == 0 {
                label.text = ""
            }
            if count < (rowsNumber)*(columnsNumber) {
                changeDot(count: count, on: 1)
                if count != 0 {
                    changeDot(count: count-1, on: 0)
                }
            }
            else {
                changeDot(count: count-1, on: 0)
                invalidateTimer()
                label.text = ":)"
                playPauseButton.isEnabled = false
                playPauseButton.isHidden = true
                if master {
                    showPicker(animation: true)
                }
                
            }
        }
        do {
            click = try AVAudioPlayer(contentsOf: url)
            click?.play()
        } catch {
            // couldn't load file :(
        }
        count = count + 1
    }
    
    func changeDot(count: Int, on: Int) {
        let row = count / columnsNumber
        let column = count % columnsNumber
        let color = gridNumbers[row][column]
        if color != 0 {
            var image: UIImage
            switch on {
            case 0:
                if color == 1 {
                    image = dotsOff[color1]
                }
                else {
                    image = dotsOff[color2]
                }
            case 1:
                if color == 1 {
                    image = dotsOn[color1]
                }
                else {
                    image = dotsOn[color2]
                }
            case 2:
                if color == 1 {
                    image = dots[color1]
                }
                else {
                    image = dots[color2]
                }
            default:
                image = UIImage()
            }
            
            gridImageViews[row][column].removeFromSuperview()
            gridImageViews[row][column] = createImageView(image: image)
            stackViews[row].insertArrangedSubview(gridImageViews[row][column], at: column)
            gridStackView.insertArrangedSubview(stackViews[row], at: row)
        }
    }
    
    func playMode() {
        let startTime = Date().addingTimeInterval(1)
        syncronizationTimer = Timer(fireAt: startTime, interval: 0, target: self, selector: #selector(setTimer), userInfo: nil, repeats: false)
        RunLoop.main.add(syncronizationTimer, forMode: .common)
    }
    
    @objc func setTimer() {
        timer =  Timer.scheduledTimer(timeInterval: 60/tempo, target: self,   selector: #selector(incrementCounter), userInfo: nil, repeats: true)
        isPaused = false
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    func invalidateTimer() {
        timer.invalidate()
        syncronizationTimer.invalidate()
        isPaused = true
        playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        click?.stop()
    }
    
    func resetDots() {
        for n in 0..<(rowsNumber)*(columnsNumber) {
            changeDot(count: n, on: 2)
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        resetRemote()
        resetLocal()
    }
    
    func resetLocal() {
        playPauseButton.isEnabled = true
        playPauseButton.isHidden = false
        count = -4
        invalidateTimer()
        resetDots()
        playMode()
    }
    
    func resetRemote() {
        sendCommand(command: "reset")
    }
    
    @objc func newGrid() {
        resetGrid()
        newGame()
        newGridRemote()
        sendParameters()
        playMode()
    }
    
    func resetGrid() {
        if gridNumbers.count > 0 {
            for row in 0..<rowsNumber {
                for column in 0..<columnsNumber {
                    gridImageViews[row][column].removeFromSuperview()
                }
                stackViews[row].removeFromSuperview()
            }
            
        }
        
        gridNumbers = []
        linearGrid = []
        stackViews = []
        gridImageViews = []
        count = -4
        label.text = ""
        invalidateTimer()
    }
    
    func newGridRemote() {
        sendCommand(command: "new")
    }
    
    @IBAction func playPause(_ sender: UIButton) {
        playPauseRemote()
        playPauseLocal()
    }
    
    func playPauseLocal() {
        if isPaused {
            playMode()
        }
        else {
            invalidateTimer()
        }
    }
    
    func playPauseRemote() {
        sendCommand(command: "pause")
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            if master {
                sendParameters()
                playMode()
            }
            print("Connected: \(peerID.displayName)")
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            print("fatal error")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [unowned self] in
            do{
                let message = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
                print(message)
                
                switch message {
                case "pause":
                    self.playPauseLocal()
                    print("pause")
                case "reset":
                    self.resetLocal()
                    print("reset")
                case "new":
                    self.resetGrid()
                    print("new")
                case "disconnected":
                    self.resetGrid()
                    self.label.text = "Waiting for Master Device to connect..."
                    self.repeatButton.isEnabled = false
                    self.repeatButton.isHidden = true
                    self.playPauseButton.isEnabled = false
                    self.playPauseButton.isHidden = true
                    print("disconnected")
                case "quit":
                    self.navigationController?.popViewController(animated: true)
                    print("quit")
                default:
                    self.resetGrid()
                    let parameters = try JSONSerialization.jsonObject(with: data) as? [String:String]
                    self.columnsNumber = Int((parameters?["columnsNumber"])!)!
                    self.rowsNumber = Int((parameters?["rowsNumber"])!)!
                    self.densityNumber = Int((parameters?["densityNumber"])!)!
                    self.metronome = Bool((parameters?["metronome"])!)!
                    self.tempo = Double((parameters?["tempo"])!)!
                    self.color1 = Int((parameters?["color1"])!)!
                    self.color2 = Int((parameters?["color2"])!)!
                    self.master = Bool((parameters?["master"])!)!
                    
                    for char in (parameters?["linearGrid"])! {
                        let number = Int(String(char))
                        if number != nil {
                            self.linearGrid.append(number!)
                        }
                    }
                    
                    
                    self.newGame()
                    self.playMode()
                }
            }
            catch {
                print ("Error recieving message")
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func hostSession() {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "RhythmDots-CEGM", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession() {
        let mcBrowser = MCBrowserViewController(serviceType: "RhythmDots-CEGM", session: mcSession)
        mcBrowser.delegate = self
        mcBrowser.maximumNumberOfPeers = 2
        present(mcBrowser, animated: true)
    }
    
    func sendParameters() {
        let parameters:[String:String] = ["linearGrid": gridNumbers.description,
                                              "columnsNumber": String(columnsNumber),
                                              "rowsNumber": String(rowsNumber),
                                              "densityNumber": String(densityNumber),
                                              "metronome": String(metronome),
                                              "tempo": String(tempo),
                                              "color1": String(color1),
                                              "color2": String(color2),
                                              "master": "false"]
            
        var paramString = parameters.description
        paramString = paramString.replacingCharacters(in: ...paramString.startIndex, with: "{")
        //paramString = paramString.replacingCharacters(in: paramString.endIndex.predecessor(), with: "}")
        paramString.removeLast()
        paramString = paramString + "}"
        
        sendMessage(message: paramString)
    }
    
    func sendCommand(command: String) {
        sendMessage(message: command)
    }
    
    func sendMessage(message: String) {
        if mcSession.connectedPeers.count > 0 {
            let message = message.data(using: String.Encoding.utf8, allowLossyConversion: false)
            do {
                try self.mcSession.send(message!, toPeers: self.mcSession.connectedPeers, with: .unreliable)
            }
            catch {
                print("Error sending message")
            }
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.up:
                changeBackGroundColor(answer: true)
                print("Swiped up")
            case UISwipeGestureRecognizer.Direction.down:
                changeBackGroundColor(answer: false)
                print("Swiped down")
            default:
                break
            }
        }
    }
    
    func changeBackGroundColor(answer: Bool) {
        let time = (60/tempo)*0.44
        let color: UIColor
        if answer {
            color = UIColor(red: 0.6, green: 1, blue: 0.6, alpha: 1)
        }
        else {
            color = UIColor(red: 1, green: 0.6, blue: 0.6, alpha: 1)
        }
        UIView.animate(withDuration: time) {
            self.view.backgroundColor = color
        }
        UIView.animate(withDuration: time) {
            self.view.backgroundColor = UIColor.white
        }
    }
    
    func createPicker() {
        setBlurryEffect()
        setPicker()
        setToolbar()
        setPickerStackView(array: [toolBar, picker])
    }
    
    func isiPhone() -> Bool {
        let width = UIScreen.main.bounds.size.width
        return width < 415
    }
    
    func isiPadPro(landscape: Bool) -> Bool {
        if landscape {
            return UIScreen.main.bounds.size.height > 1000
        }
        else {
            return UIScreen.main.bounds.size.width > 1000
        }
        
    }
    
    
    func setBlurryEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        self.view.addSubview(blurEffectView)
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        setConstraints(view: blurEffectView)
        
        blurEffectView.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 0.55)
        
        blurEffectView.layer.shadowColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1).cgColor
        blurEffectView.layer.shadowOpacity = 0.3
        blurEffectView.layer.shadowOffset = .zero
        blurEffectView.layer.shadowRadius = 4
        
        blurEffectView.layer.cornerRadius = 20.0
        blurEffectView.clipsToBounds = true
        
    }
    
    func setPickerStackView(array: [UIView]) {
        pickerStackView = UIStackView(arrangedSubviews: array)
        pickerStackView.axis = .vertical
        pickerStackView.distribution = .fill
        pickerStackView.alignment = .fill
        pickerStackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pickerStackView)
        setConstraints(view: pickerStackView)
        
        pickerStackView.layer.cornerRadius = 20.0
        pickerStackView.clipsToBounds = true;
    }
    
    func setConstraints(view: UIView){
        view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        if iPhone {
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        }
        else {
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        }
        
        let landscape = UIApplication.shared.statusBarOrientation.isLandscape
        setSizeConstraints(view: view, landscape: landscape)

    }
    
    func setSizeConstraints(view: UIView, landscape: Bool) -> [NSLayoutConstraint] {
        let widthConstant: CGFloat
        let heightConstant: CGFloat
        
        if iPhone {
            widthConstant = 0
            heightConstant = -680
        }
        else {
            if isiPadPro(landscape: landscape) {
                /*
                if landscape {
                    widthConstant = -825
                    heightConstant = -720
                } else {
                    widthConstant = -500
                    heightConstant = -1075
                }*/
                widthConstant = -500
                heightConstant = -1075
            }
            else {
                /*
                if landscape {
                    widthConstant = -485
                    heightConstant = -470
                }
                else {
                    widthConstant = -230
                    heightConstant = -750
                }*/
                widthConstant = -230
                heightConstant = -750
            }
        }
        let widthLandscape = view.widthAnchor.constraint(equalTo: self.view.heightAnchor, constant: widthConstant)
        let heightLandscape = view.heightAnchor.constraint(equalTo: self.view.widthAnchor, constant: heightConstant)
        let widthPortrait = view.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: widthConstant)
        let heightPortrait = view.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: heightConstant)
        return [widthLandscape, heightLandscape, widthPortrait, heightPortrait]
    }
    
    func setPicker() {
        picker = UIPickerView()
        picker.delegate = self as UIPickerViewDelegate
        picker.dataSource = self as UIPickerViewDataSource
    }
    
    func setToolbar() {
        toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        doneButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        cancelButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        /*let path = UIBezierPath(roundedRect: toolBar.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = toolBar.bounds
        maskLayer.path = path.cgPath
        toolBar.layer.mask = maskLayer*/
        toolBar.layer.cornerRadius = 20.0
        toolBar.clipsToBounds = true
        if #available(iOS 11.0, *) {
            toolBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row = dataArray[row]
        return row
    }
    
    @objc func doneClick() {
        hidePicker(animation: true)
    }
    @objc func cancelClick() {
        hidePicker(animation: true)
    }
    
    func showPicker(animation: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.blurEffectView.alpha = 1
            self.picker.alpha = 1
            self.toolBar.alpha = 1
        }
    }
    
    func hidePicker(animation: Bool) {
        let time: Double
        if animation {
            time = 0.22
        }
        else {
            time = 0
        }
        UIView.animate(withDuration: time) {
            self.blurEffectView.alpha = 0
            self.picker.alpha = 0
            self.toolBar.alpha = 0
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
