//
//  PNDropDown.swift
//  PNDropDown
//
//  Created by prakash on 22/05/18.
//  Copyright © 2018 prakash. All rights reserved.
//

import Foundation

public enum UIDropDownAnimationType: Int {
    case Default
}

public class PNDropDown: UIControl {
    
    fileprivate var title: UILabel!
    fileprivate var arrow: Arrow!
    fileprivate var table: UITableView!
    
    public fileprivate(set) var selectedIndex: Int?
    public var optionsArray : NSMutableArray = NSMutableArray()
    public var hideOptionsWhenSelect = false
    public var placeholder: String! {
        didSet {
            title.text = placeholder
            title.adjustsFontSizeToFitWidth = true
        }
    }
    public var tint: UIColor? {
        didSet {
            title.textColor = textColor ?? tint
            arrow.backgroundColor = tint
        }
    }
    public var arrowPadding: CGFloat = 7.0 {
        didSet{
            let size = arrow.superview!.frame.size.width-(arrowPadding*2)
            arrow.frame = CGRect(x: arrowPadding, y: arrowPadding, width: size, height: size)
        }
    }
    
    public var font: String? {
        didSet {
            title.font = UIFont(name: font!, size: fontSize)
        }
    }
    public var fontSize: CGFloat = 17.0 {
        didSet{
            title.font = title.font.withSize(fontSize)
        }
    }
    public var textColor: UIColor? {
        didSet{
            title.textColor = textColor
        }
    }
    public var textAlignment: NSTextAlignment? {
        didSet{
            title.textAlignment = textAlignment!
        }
    }
    
    public var optionsFont: String?
    public var optionsSize: CGFloat = 17.0
    public var optionsTextColor: UIColor?
    public var optionsTextAlignment: NSTextAlignment?
    
    public var animationType: UIDropDownAnimationType = .Default
    public var tableHeight: CGFloat = 100.0
    public var rowHeight: CGFloat?
    public var rowBackgroundColor: UIColor?
    
    fileprivate var privatedidSelect: (String, Int) -> () = {option, index in }
    fileprivate var privateTableWillAppear: () -> () = { }
    fileprivate var privateTableDidAppear: () -> () = { }
    fileprivate var privateTableWillDisappear: () -> () = { }
    fileprivate var privateTableDidDisappear: () -> () = { }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    public func resign() -> Bool {
        if isSelected {
            hideTable()
        }
        return true
    }
    
    fileprivate func setup() {
        
        title = UILabel(frame: CGRect(x: 0,y: 0,width: (self.frame.width-self.frame.height),height: self.frame.height))
        title.textAlignment = .center
        self.addSubview(title)
        
        let arrowIcon = UIView(frame: CGRect(x: title.frame.maxX,y: 0,width: title.frame.height, height:title.frame.height))
        arrowIcon.isUserInteractionEnabled = false
        self.addSubview(arrowIcon)
        
        arrow = Arrow(origin: CGPoint(x: arrowPadding,y: arrowPadding),size: arrowIcon.frame.width-(arrowPadding*2))
        arrow.backgroundColor = .black
        arrowIcon.addSubview(arrow)
        
        self.layer.cornerRadius = 3.0
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.black.cgColor
        self.addTarget(self, action: #selector(touch), for: .touchUpInside)
    }
    
    @objc fileprivate func touch() {
        isSelected = !isSelected
        isSelected ? showTable() : hideTable()
    }
    
    fileprivate func showTable() {
        
        privateTableWillAppear()
        
        table = UITableView(frame: CGRect(x: self.frame.minX,y: self.frame.minY,width: self.frame.width,height: self.frame.height))
        table.dataSource = self
        table.delegate = self
        table.alpha = 0
        table.layer.cornerRadius = 3.0
        table.layer.borderWidth = 0.5
        table.layer.borderColor = UIColor.black.cgColor
        table.rowHeight = rowHeight ?? table.rowHeight
        self.superview?.insertSubview(table, belowSubview: self)
        
        switch animationType {
        case .Default:
            UIView.animate(withDuration: 0.9,delay: 0,usingSpringWithDamping: 0.5,initialSpringVelocity: 0.1,options: .curveEaseInOut,animations: { () -> Void in
                
                self.table.frame = CGRect(x: self.frame.minX,y: self.frame.maxY+5, width: self.frame.width,height: self.tableHeight)
                self.table.alpha = 1
                
                self.arrow.position = .up
                
            },
                completion: { (didFinish) -> Void in
                self.privateTableDidAppear()
            })
        }
    }
    
    fileprivate func hideTable() {
        
        privateTableWillDisappear()
        
        switch self.animationType {
        case .Default :
            UIView.animate(withDuration: 0.3,delay: 0,usingSpringWithDamping: 0.9,initialSpringVelocity: 0.1,options: .curveEaseInOut,animations: { () -> Void in
                self.table.frame = CGRect(x: self.frame.minX,y: self.frame.minY, width: self.frame.width,height: 0)
                self.table.alpha = 0
                
                self.arrow.position = .down
            },
                completion: { (didFinish) -> Void in
                self.table.removeFromSuperview()
                self.isSelected = false
                self.privateTableDidDisappear()
            })
            
        }
    }
    
    public func didSelect(completion: @escaping (_ option: String, _ index: Int) -> ()) {
        privatedidSelect = completion
    }
    
    public func tableWillAppear(completion: @escaping () -> ()) {
        privateTableWillAppear = completion
    }
    
    public func tableDidAppear(completion: @escaping () -> ()) {
        privateTableDidAppear = completion
    }
    
    public func tableWillDisappear(completion: @escaping () -> ()) {
        privateTableWillDisappear = completion
    }
    
    public func tableDidDisappear(completion: @escaping () -> ()) {
        privateTableDidDisappear = completion
    }
}

extension PNDropDown: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "UIDropDownCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        if rowBackgroundColor != nil {
            cell!.contentView.backgroundColor = rowBackgroundColor
        }
        
        cell!.textLabel!.font = UIFont(name: optionsFont ?? font ?? cell!.textLabel!.font.fontName, size: optionsSize)
        cell!.textLabel!.textColor = optionsTextColor ?? tint ?? cell!.textLabel!.textColor
        cell!.textLabel!.textAlignment = optionsTextAlignment ?? cell!.textLabel!.textAlignment
        cell!.textLabel!.text = "\(optionsArray[indexPath.row])"
        cell!.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
        cell!.selectionStyle = .none
        
        return cell!
    }
}

extension PNDropDown: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = (indexPath as NSIndexPath).row
        
        title.alpha = 0.0
        title.text = "\(self.optionsArray[(indexPath as NSIndexPath).row])"
        
        UIView.animate(withDuration: 0.6,animations: { () -> Void in
            self.title.alpha = 1.0
        })
        
        tableView.reloadData()
        
        if hideOptionsWhenSelect {
            hideTable()
        }
        
        privatedidSelect("\(self.optionsArray[indexPath.row])", selectedIndex!)
    }
}


enum Position {
    case left
    case down
    case right
    case up
}

class Arrow: UIView {
    
    var position: Position = .down {
        didSet{
            switch position {
            case .left:
                self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                break
                
            case .down:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
                break
                
            case .right:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                break
                
            case .up:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                break
            }
        }
    }
    
    init(origin: CGPoint, size: CGFloat) {
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: size, height: size))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let size = self.layer.frame.width
        
        let bezierPath = UIBezierPath()
        
        let iconSize = size/4
        
        bezierPath.move(to: CGPoint(x: 0, y: iconSize))
        bezierPath.addLine(to: CGPoint(x: size, y: iconSize))
        bezierPath.addLine(to: CGPoint(x: size/2, y: iconSize*3))
        bezierPath.addLine(to: CGPoint(x: 0, y: iconSize))
        bezierPath.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        self.layer.mask = shapeLayer
    }
}
