//
//  ViewController.swift
//  ALGridView
//
//  Created by Alexandre Leite on 4/11/15.
//  Copyright (c) 2015 Alexandre Leite. All rights reserved.
//
import UIKit
//import ALGridView

class ScoreCardController: UIViewController {
    
    //MARK- View Lifecycle
    /*
     override func loadView() {
     self.view = ViewControllerView()
     }
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let controllerView = ScoreCardControllerView()
        self.view.addSubview(controllerView)
    }
    
}

class ScoreCardControllerView: UIView {
    var gridView: GridView?
    
    //MARK- Initializers
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.white
        
        var gridFrame = CGRect.zero
        gridFrame.size.width = min(self.bounds.size.width, self.bounds.size.height)
        gridFrame.size.height = min(self.bounds.size.width, self.bounds.size.height)
        
        let margins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        /** SAMPLE CODE BELOW **/
        
        self.gridView = GridView(frame: gridFrame, columns: 18, rows: 3, margins: margins, padding: 0) {
            column, row, contentView in
            
            let label = UILabel(frame: contentView.bounds)
            label.textAlignment = .center
            label.backgroundColor = UIColor.lightGray
            label.textColor = UIColor.darkGray
            label.text = "\(column)x\(row)"
            contentView.addSubview(label)
        }
        self.addSubview(self.gridView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK- Base Overrides
    
    override func layoutSubviews() {
        self.gridView?.center = self.center
    }
}
