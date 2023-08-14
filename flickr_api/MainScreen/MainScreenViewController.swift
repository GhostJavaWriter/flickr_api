//
//  MainScreenViewController.swift
//  flickr_api
//
//  Created by Bair Nadtsalov on 4.08.2023.
//

import UIKit

class MainScreenViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = view.frame.width / 2 - 30
        let height = width * 3 / 2
        layout.itemSize = CGSize(width: width, height: height)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.register(CollectionViewCell.self,
                                forCellWithReuseIdentifier: CollectionViewCell.defaultReuseIdentifier)
        collectionView.register(LoadingReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: LoadingReusableView.defaultReuseIdentifier)
        return collectionView
    }()
    
    private lazy var searchBarPlaceholder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchController.searchBar)
        return view
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.sizeToFit()
        controller.searchBar.placeholder = "Search photo..."
        controller.searchBar.delegate = viewModel
        return controller
    }()
    
    private var loadingReusableView: LoadingReusableView?
    
    private lazy var dataSource = CollectionViewDataSource(viewModel: viewModel)
    var viewModel: MainScreenViewModel
    
    // MARK: - Init
    
    init(viewModel: MainScreenViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        viewModel.updateUI = { [weak self] in
            self?.updateUI()
        }
        viewModel.setupIndicatorView = { [weak self] view in
            self?.loadingReusableView = view
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addKeyboardObservers()
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(searchBarPlaceholder)
        
        let layouGuide = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            searchBarPlaceholder.topAnchor.constraint(equalTo: layouGuide.topAnchor),
            searchBarPlaceholder.leadingAnchor.constraint(equalTo: layouGuide.leadingAnchor),
            searchBarPlaceholder.trailingAnchor.constraint(equalTo: layouGuide.trailingAnchor),
            searchBarPlaceholder.heightAnchor.constraint(equalTo: layouGuide.heightAnchor, multiplier: 0.05),
            collectionView.topAnchor.constraint(equalToSystemSpacingBelow: searchBarPlaceholder.bottomAnchor, multiplier: 1),
            collectionView.leadingAnchor.constraint(equalTo: layouGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: layouGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: layouGuide.bottomAnchor)
        ])
    }
    
}

extension MainScreenViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.viewModel.loadingIndicatorShouldAnimate {
            return CGSize(width: collectionView.bounds.size.width, height: 55)
        } else {
            return CGSize.zero
        }
    }
}

extension MainScreenViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            viewModel.loadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingReusableView?.activityIndicatorView.startAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingReusableView?.activityIndicatorView.stopAnimating()
        }
    }
}

private extension MainScreenViewController {
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
    }
}
