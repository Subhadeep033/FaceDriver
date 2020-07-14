//
//  PageViewController.swift
//  PageViewController
//
//  Created by 王小涛 on 2017/6/6.
//  Copyright © 2017. All rights reserved.
//

import Foundation
import UIKit


public class PageViewController: UIPageViewController {
    
    private(set) var controllers: [UIViewController] = []
    
    fileprivate var previousIndexs: [Int] = [0]
    fileprivate var lastPendingIndex: Int = 0
    
    public var currentController: UIViewController? {
        guard currentIndex < controllers.count else {return nil}
        return controllers[currentIndex]
    }
    
    public var totalPages: Int {
        return controllers.count
    }
    
    public fileprivate(set) var currentIndex: Int = 0 {
        didSet {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = (currentIndex == 0)
        }
    }
    
    public var didScrollToIndex: ((Int) -> Void)?
    
    public var isScrollEnabled: Bool = true {
        didSet {
            view.subviews.compactMap({ $0 as? UIScrollView}).forEach({$0.isScrollEnabled = isScrollEnabled})
        }
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    public convenience init(controllers: [UIViewController], interPageSpacing: CGFloat = 0.0) {
        self.init(transitionStyle: .scroll,
                  navigationOrientation: .horizontal,
                  options: [UIPageViewController.OptionsKey.interPageSpacing: interPageSpacing])
        
        self.controllers = controllers
        
        hidesBottomBarWhenPushed = true
        
        if let controller = controllers.first {
            
            setViewControllers([controller],
                               direction: .forward,
                               animated: false,
                               completion: nil)
        }
    }
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.automaticallyAdjustsScrollViewInsets = false
        self.dataSource = self
        self.delegate = self
    }
    
    public func scrollToIndex(index: Int, animated: Bool = true) {
        
        guard index >= 0 && index < controllers.count else {return}
        
        let direction: UIPageViewController.NavigationDirection = {
            if index < currentIndex  {
                return .reverse
            } else {
                return .forward
            }
        }()
        
        let controller = controllers[index]
        currentIndex = index
        setViewControllers([controller], direction: direction, animated: animated)
    }
    
    public func removeCurrentController(animated: Bool = true) {
        
        guard currentController != nil else {return}

        if currentIndex < controllers.count - 1 {
            
            let controller = controllers[currentIndex+1]
            setViewControllers([controller], direction: .forward, animated: animated)
            
            controllers.remove(at: currentIndex)
            
        } else {
            
            if currentIndex > 0 {
                let controller = controllers[currentIndex-1]
                setViewControllers([controller], direction: .reverse, animated: animated)
                controllers.remove(at: currentIndex)
                currentIndex = currentIndex - 1
            } else  {
                print("controller Remove")
            }
        }
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index = controllers.index(of: viewController), index > 0 else {
            return nil
        }
        
        return controllers[index-1]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let index = controllers.index(of: viewController), index < controllers.count-1 else {
            return nil
        }
        
        return controllers[index+1]
    }
}

extension PageViewController: UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let lastPendingController = pendingViewControllers.first else {return}
        guard let index = controllers.index(of: lastPendingController) else {return}
        lastPendingIndex = index
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {return}
        guard let previousController = previousViewControllers.first else {return}
        guard let previousIndex = controllers.index(of: previousController) else {return}
        previousIndexs.append(previousIndex)
        
        if previousIndex == lastPendingIndex {
            currentIndex = previousIndexs[previousIndexs.count-2]
        } else {
            currentIndex = lastPendingIndex
            didScrollToIndex?(currentIndex)
        }
    }
}
