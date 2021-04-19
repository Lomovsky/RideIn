//
//  ViewController.swift
//  RideIn
//
//  Created by Алекс Ломовской on 16.04.2021.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    lazy var views = [allTripsView, carTripsView, busTripsView]

    
    let allTripsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        return view
    }()
    

    
    let carTripsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemRed
        return view
    }()
    
    
    let busTripsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemTeal
        return view
    }()
    
    lazy var pageScrollView: UIScrollView = {
        let height = view.frame.height
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = true
        scroll.isPagingEnabled = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.contentSize = CGSize(width: view.frame.width * CGFloat(views.count), height: height)
        
        for i in 0..<views.count {
            scroll.addSubview(views[i])
            views[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
           
        }
        scroll.delegate = self
        return scroll
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pageScrollView)
        // Do any additional setup after loading the view.
        NSLayoutConstraint.activate([
            pageScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            pageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        ])
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
