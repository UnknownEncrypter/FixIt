//
//  CustomerView.swift
//  FixIt
//
//  Created by Josiah Agosto on 5/20/20.
//  Copyright © 2020 Josiah Agosto. All rights reserved.
//

import UIKit

class CustomerView: UIView {
    // Properties / References
    // No issue Bool
    public var hasIssues: Bool = false
    // Table View
    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        return tableView
    }()
    // Profile Image
    public lazy var customerProfileImage: UIImage = {
        let image = UIImage(systemName: "person.circle")!
        return image
    }()
    // Add Image
    public lazy var addImage: UIImage = {
        let add = UIImage(systemName: "plus.circle")!
        return add
    }()
    // Add Bar Button
    public lazy var addBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        return item
    }()
    // Profile Bar Button
    public lazy var profileBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        return item
    }()
    public lazy var customerController = CustomerViewController()
    // Delegates
    public var customerTableViewDelegate: CustomerTableViewDelegate?
    public var customerTableViewDataSource: CustomerTableViewDataSource?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    private func setup() {
        // View
        backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        // Table View
        customerTableViewDelegate = CustomerTableViewDelegate(customerController: customerController)
        customerTableViewDataSource = CustomerTableViewDataSource(customerController: customerController)
        tableView.delegate = customerTableViewDelegate
        tableView.dataSource = customerTableViewDataSource
        tableView.register(hasIssues ? CustomerCell.self : EmptyIssueCustomerCell.self, forCellReuseIdentifier: hasIssues ? CustomerCell.reuseIdentifier : EmptyIssueCustomerCell.reuseIdentifier)
        // Subviews
        addSubview(tableView)
        // Constraints
        constraints()
    }
    
    
    private func constraints() {
        // Table View
        tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
