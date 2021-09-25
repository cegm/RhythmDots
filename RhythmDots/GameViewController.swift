//
//  GameViewController.swift
//  RhythmDots
//
//  Created by Eduardo Gil on 7/10/18.
//  Copyright © 2018 Eduardo Gil. All rights reserved.
//

import UIKit
import AVFoundation
import MultipeerConnectivity

class GameViewController: UIViewController {
    
    var columnsNumber: Int = 5
    var rowsNumber: Int = 5
    var densityNumber: Int = 50
    var metronome: Bool = true
    var tempo: Double = 60
    var color1: Int = 0
    var color2: Int = 0
    var colors: [String] = ["Black", "Red", "Orange", "Yellow", "Green", "Blue", "Purple"]
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(newGrid))
        tap.numberOfTapsRequired = 2
        repeatButton.addGestureRecognizer(tap)
        
        newGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        invalidateTimer()
    }
    override func viewDidDisappear(_ animated: Bool) {
        invalidateTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newGame() {
        fill()
        
        if metronome {
            repeatButton.isEnabled = true
            repeatButton.isHidden = false
            playPauseButton.isEnabled = true
            playPauseButton.isHidden = false
            label.text = "4"
            setTimer()
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
        let number = Int(arc4random_uniform(101))
        if number <= densityNumber {
            image = fillCellUpdateGrid(number: Int(arc4random_uniform(2)) + 1, row: row)
        }
        else {
            image = fillCellUpdateGrid(number: 0, row: row)
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
    
    @objc func setTimer() {
        timer =  Timer.scheduledTimer(timeInterval: 60/tempo, target: self,   selector: #selector(incrementCounter), userInfo: nil, repeats: true)
        isPaused = false
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    func invalidateTimer() {
        timer.invalidate()
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
        playPauseButton.isEnabled = true
        playPauseButton.isHidden = false
        count = -4
        invalidateTimer()
        resetDots()
        setTimer()
    }
    
    @objc func newGrid() {
        resetGrid()
        newGame()
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
    
    
    
    @IBAction func playPause(_ sender: UIButton) {
        if isPaused {
            setTimer()
        }
        else {
            invalidateTimer()
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
