//
//  SMViewController.swift
//  SideMenu
//
//  Created by Johnny Gu on 12/04/2017.
//  Copyright © 2017 Johnny Gu. All rights reserved.
//

import UIKit

class SMViewController: UIViewController {
    var menuStatus: Status = .menuClosed
    private(set) var options: Options = .default
    var rootViewController: UIViewController? {
        didSet {
            removeOldViewController(oldValue)
            addNewViewController(rootViewController, with: view.bounds)
            addGesture()
        }
    }
    var leftMenuViewController: UIViewController? {
        didSet {
            removeOldViewController(oldValue)
            var frame = view.bounds
            frame.size.width = SMViewController.menuWidth
            addNewViewController(leftMenuViewController, with: frame)
        }
    }
    var rightMenuViewController: UIViewController? {
        didSet {
            removeOldViewController(oldValue)
            var frame = view.bounds
            frame.size.width = SMViewController.menuWidth
            addNewViewController(rightMenuViewController, with: frame)
        }
    }
    var leftMenuView: UIView? {
        return leftMenuViewController?.view
    }
    var rightMenuView: UIView? {
        return rightMenuViewController?.view
    }
    var rootView: UIView? {
        return rootViewController?.view
    }
    var leftMenuViewOpenPositionX: CGFloat {
        return 0
    }
    var leftMenuViewClosePositionX: CGFloat {
        return -leftMenuView!.frame.width
    }
    var rightMenuViewOpenPositionX: CGFloat {
        return view.frame.maxX - rightMenuView!.frame.width
    }
    var rightMenuViewClosePositionX: CGFloat {
        return view.frame.maxX
    }
    private var rootViewDidApper = false
    fileprivate var panGestureToLeft = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(_ rootViewController: UIViewController? = nil, leftMenuViewController: UIViewController? = nil, rightMenuViewController: UIViewController? = nil, options: SMViewController.Options = .default) {
        super.init(nibName: nil, bundle: nil)
        self.rootViewController = rootViewController
        self.leftMenuViewController = leftMenuViewController
        self.rightMenuViewController = rightMenuViewController
        self.options = options
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !rootViewDidApper else { return }
        view.backgroundColor = UIColor.black
        rootViewDidApper = true
        addNewViewController(rootViewController, with: view.bounds)
        var frame = view.bounds
        frame.size.width = SMViewController.menuWidth
        addNewViewController(leftMenuViewController, with: frame)
        addNewViewController(rightMenuViewController, with: frame)
        if let rootView = rootView {
            view.sendSubview(toBack: rootView)
        }
        setupMenus()
        addGesture()
        if options.contains(.menuShadow) {
            if let leftView = leftMenuView { addShadow(to: leftView, vender: CGSize(width: 3, height: 0)) }
            if let rightView = rightMenuView { addShadow(to: rightView, vender: CGSize(width: -3, height: 0)) }
        }
    }
    
    func setMenuStatus(_ status: Status, animated: Bool) {
        guard status != menuStatus, status != .leftMenuAnimating, status != .rightMenuAnimating else { return }
        if status == .menuClosed {
            if menuStatus == .leftMenuOpened {
                triggleLeftMenu(false, animated: animated)
            }else if menuStatus == .rightMenuOpened {
                triggleRightMenu(false, animated: animated)
            }
        }else {
            if status == .leftMenuOpened {
                triggleLeftMenu(true, animated: animated)
            }else if status == .rightMenuOpened {
                triggleRightMenu(true, animated: animated)
            }
        }
    }
    
    func triggleMenuClose(animated: Bool = true) {
        if menuStatus == .leftMenuOpened { triggleLeftMenu(false, animated: true) }
        if menuStatus == .rightMenuOpened { triggleRightMenu(false, animated: true) }
    }
    
    func move(_ sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: view)
        if let leftMenuView = leftMenuView, !panGestureToLeft {
            let newX = leftMenuView.frame.minX + point.x
            guard (leftMenuViewClosePositionX...leftMenuViewOpenPositionX).contains(newX) else { return }
            if sender.state == .ended {
                let velocityPoint = sender.velocity(in: view)
                let finalX = velocityPoint.x < 0 ? leftMenuViewClosePositionX : leftMenuViewOpenPositionX
                let distance: CGFloat = CGFloat(fabsf(Float(leftMenuView.frame.minX - finalX)))
                let durantion: TimeInterval = TimeInterval(distance/(SMViewController.menuWidth)) * 0.3
                menuStatus = .leftMenuAnimating
                UIView.animate(withDuration: durantion, animations: { 
                    leftMenuView.frame.origin.x = finalX
                    if self.options.contains(.animateCenter) { self.animateCenterView(velocityPoint.x < 0 ? 0 : 1) }
                }) { _ in
                    self.menuStatus = velocityPoint.x < 0 ? .menuClosed : .leftMenuOpened
                }
                return
            }
            leftMenuView.frame.origin.x = newX
            let percent: Float = Float((leftMenuView.frame.minX - leftMenuViewClosePositionX)/SMViewController.menuWidth)
            if options.contains(.animateCenter) { animateCenterView(percent) }
        }
        if let rightMenuView = rightMenuView, panGestureToLeft {
            let newX = rightMenuView.frame.minX + point.x
            guard (rightMenuViewOpenPositionX...rightMenuViewClosePositionX).contains(newX) else { return }
            if sender.state == .ended {
                let velocityPoint = sender.velocity(in: view)
                let finalX = velocityPoint.x < 0 ? rightMenuViewOpenPositionX : rightMenuViewClosePositionX
                let distance: CGFloat = CGFloat(fabsf(Float(rightMenuView.frame.minX - finalX)))
                let durantion: TimeInterval = TimeInterval(distance/(SMViewController.menuWidth)) * 0.3
                menuStatus = .rightMenuAnimating
                UIView.animate(withDuration: durantion, animations: { 
                    rightMenuView.frame.origin.x = finalX
                    if self.options.contains(.animateCenter) { self.animateCenterView(velocityPoint.x < 0 ? 1 : 0)}
                }) { _ in
                    self.menuStatus = velocityPoint.x < 0 ? .rightMenuOpened : .menuClosed
                }
                return
            }
            rightMenuView.frame.origin.x = newX
            let percent: Float = Float((rightMenuViewClosePositionX - rightMenuView.frame.minX)/SMViewController.menuWidth)
            if options.contains(.animateCenter) { animateCenterView(percent) }
        }
        sender.setTranslation(CGPoint.zero, in: view)
    }
}

fileprivate extension SMViewController {
    func removeOldViewController(_ viewController: UIViewController?) {
        guard let viewController = viewController else { return }
        viewController.willMove(toParentViewController: nil)
        viewController.removeFromParentViewController()
        viewController.view.removeFromSuperview()
        viewController.didMove(toParentViewController: nil)
    }
    
    func addNewViewController(_ viewController: UIViewController?, with frame: CGRect) {
        guard let viewController = viewController else { return }
        viewController.willMove(toParentViewController: self)
        addChildViewController(viewController)
        viewController.view.frame = frame
        view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    func triggleLeftMenu(_ open: Bool, animated: Bool = false) {
        guard let leftMenuView = leftMenuView else { return }
        if open && menuStatus != .menuClosed { return }
        if !open && menuStatus != .leftMenuOpened { return }
        menuStatus = .leftMenuAnimating
        let x = open ? leftMenuViewOpenPositionX : leftMenuViewClosePositionX
        if !animated {
            leftMenuView.frame.origin.x = x
        } else {
            UIView.animate(withDuration: SMViewController.animationDuration, animations: {
                leftMenuView.frame.origin.x = x
                self.animateCenterView(open ? 1 : 0)
            }) { _ in
                self.menuStatus = open ? .leftMenuOpened : .menuClosed
            }
        }
    }
    
    func triggleRightMenu(_ open: Bool, animated: Bool = false) {
        guard let rightMenuView = rightMenuView else { return }
        if open && menuStatus != .menuClosed { return }
        if !open && menuStatus != .rightMenuOpened { return }
        menuStatus = .rightMenuAnimating
        let x = open ? rightMenuViewOpenPositionX : rightMenuViewClosePositionX
        if !animated {
            rightMenuView.frame.origin.x = x
        } else {
            UIView.animate(withDuration: SMViewController.animationDuration, animations: {
                rightMenuView.frame.origin.x = x
                self.animateCenterView(open ? 1 : 0)
            }) { _ in
                self.menuStatus = open ? .rightMenuOpened : .menuClosed
            }
        }
    }
    
    func setupMenus() {
        if let leftMenuView = leftMenuView {
            leftMenuView.frame.origin.x = -leftMenuView.frame.width
        }
        if let rightMenuView = rightMenuView {
            rightMenuView.frame.origin.x = view.frame.maxX
        }
        menuStatus = .menuClosed
    }
    
    func addGesture() {
        guard let rootView = rootView else { return }
        rootView.gestureRecognizers?.forEach({self.view.removeGestureRecognizer($0)})
        let tap = UITapGestureRecognizer(target: self, action: #selector(triggleMenuClose))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(move))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        rootView.addGestureRecognizer(tap)
        rootView.addGestureRecognizer(pan)
    }
    
    func animateCenterView(_ percent: Float) {
        let scale: CGFloat = CGFloat(1 - percent*0.1)
        rootView?.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    func addShadow(to view: UIView, vender: CGSize) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = vender
        view.layer.shadowOpacity = 0.6
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: 0).cgPath
    }
}

extension SMViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let point = gesture.translation(in: view)
        if menuStatus == .menuClosed {
            if point.x > 0 {
                panGestureToLeft = false
            } else if point.x < 0 {
                panGestureToLeft = true
            }
        }else if menuStatus == .leftMenuOpened {
            panGestureToLeft = false
        }else if menuStatus == .rightMenuOpened {
            panGestureToLeft = true
        }
        return true
    }
    
}

extension SMViewController {
    static let menuWidth: CGFloat = 270
    static let animationDuration: TimeInterval = 0.3
    enum Status {
        case leftMenuOpened
        case rightMenuOpened
        case menuClosed
        case leftMenuAnimating
        case rightMenuAnimating
    }
    struct Options: OptionSet {
        let rawValue: Int
        
        static let menuShadow = Options(rawValue: 1<<0)
        static let animateCenter = Options(rawValue: 1<<1)
        
        static let `default`: Options = [.menuShadow, .animateCenter]
    }
}
