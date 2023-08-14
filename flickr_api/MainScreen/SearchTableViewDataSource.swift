//
//  SearchTableViewDataSource.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 14.08.2023.
//

import UIKit

final class SearchTableViewDataSource: NSObject, UITableViewDataSource {
    
    var viewModel: MainScreenViewModel
    
    init(viewModel: MainScreenViewModel) {
        self.viewModel = viewModel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfSearchItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.defaultReuseIdentifier,
                                                 for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = viewModel.searchItemAt(indexPath)
        cell.contentConfiguration = config
        
        return cell
    }
}

extension UITableViewCell {
    static var defaultReuseIdentifier: String { String(describing: self) }
}
