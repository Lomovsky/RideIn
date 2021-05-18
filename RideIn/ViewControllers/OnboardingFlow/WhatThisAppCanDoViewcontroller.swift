//
//  WhatThisAppCanDoViewcontroller.swift
//  RideIn
//
//  Created by Алекс Ломовской on 18.05.2021.
//


import UIKit

final class WhatThisAppDoViewController: UIViewController {
  
  var onContinue: CompletionBlock?
  var secondCircleLeadingAnchor = NSLayoutConstraint()
  
  //MARK:- UIElements
  private let whatAppCanDoLabel = UILabel.createDefaultLabel()
  private let firstCircleImageView = UIImageView.createDefaultIV(withImage: .init(systemName: "circle.fill"))
  private let receiveRecommendationsLabel = UILabel.createDefaultLabel()
  private let secondCircleImageView = UIImageView.createDefaultIV(withImage: .init(systemName: "circle.fill"))
  private let findMoviesLabel = UILabel.createDefaultLabel()
  private let thirdCircleImageView = UIImageView.createDefaultIV(withImage: .init(systemName: "circle.fill"))
  private let saveFilmsLabel = UILabel.createDefaultLabel()
  private let nextButton = UIButton.createDefaultButton()
  
  //MARK:- viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(whatAppCanDoLabel)
    view.addSubview(firstCircleImageView)
    view.addSubview(secondCircleImageView)
    view.addSubview(receiveRecommendationsLabel)
    view.addSubview(findMoviesLabel)
    view.addSubview(nextButton)
    view.addSubview(thirdCircleImageView)
    view.addSubview(saveFilmsLabel)
    
    setupView()
    setupWhatAppCanDoLabel()
    setupSecondCircleImageView()
    setupFirstCircleImageView()
    setupReceiveRecommendationsLabel()
    setupFindMoviesLabel()
    setupNextButton()
    setupThirdCircleImageView()
    setupSaveFilmsLabel()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    animateLabels()
  }
  
  //MARK:- UIMethods
  private func setupView() {
    view.backgroundColor = .white
  }
  
  private func setupWhatAppCanDoLabel() {
    NSLayoutConstraint.activate([
      whatAppCanDoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      whatAppCanDoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      whatAppCanDoLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -(view.frame.height * 0.2)),
      whatAppCanDoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      whatAppCanDoLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
    ])
    whatAppCanDoLabel.text = NSLocalizedString(.Localization.Onboarding.whatAppCanDo, comment: "")
    whatAppCanDoLabel.textColor = .darkGray
    whatAppCanDoLabel.textAlignment = .center
    whatAppCanDoLabel.sizeToFit()
    whatAppCanDoLabel.numberOfLines = 0
    whatAppCanDoLabel.textAlignment = .center
    whatAppCanDoLabel.font = .boldSystemFont(ofSize: 40)
  }
  
  private func setupFirstCircleImageView() {
    NSLayoutConstraint.activate([
      firstCircleImageView.bottomAnchor.constraint(equalTo: secondCircleImageView.topAnchor, constant: -30),
      firstCircleImageView.leadingAnchor.constraint(equalTo: secondCircleImageView.leadingAnchor),
      firstCircleImageView.heightAnchor.constraint(equalTo: secondCircleImageView.heightAnchor),
      firstCircleImageView.widthAnchor.constraint(equalTo: firstCircleImageView.heightAnchor)
    ])
    firstCircleImageView.tintColor = .systemBlue
    firstCircleImageView.alpha = 0
  }
  
  private func setupReceiveRecommendationsLabel() {
    NSLayoutConstraint.activate([
      receiveRecommendationsLabel.centerYAnchor.constraint(equalTo: firstCircleImageView.centerYAnchor),
      receiveRecommendationsLabel.leadingAnchor.constraint(equalTo: firstCircleImageView.trailingAnchor, constant: 10),
      receiveRecommendationsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
    ])
    receiveRecommendationsLabel.sizeToFit()
    receiveRecommendationsLabel.textColor = .darkGray
    receiveRecommendationsLabel.font = .boldSystemFont(ofSize: 17)
    receiveRecommendationsLabel.text = NSLocalizedString(.Localization.Onboarding.recommendations, comment: "")
    receiveRecommendationsLabel.numberOfLines = 0
    receiveRecommendationsLabel.alpha = 0
  }
  
  private func setupSecondCircleImageView() {
    secondCircleLeadingAnchor = NSLayoutConstraint(item: secondCircleImageView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .leading,
                                                   multiplier: 1,
                                                   constant: 50)
    NSLayoutConstraint.activate([
      secondCircleImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      secondCircleImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.03),
      secondCircleImageView.widthAnchor.constraint(equalTo: secondCircleImageView.heightAnchor),
      secondCircleLeadingAnchor
    ])
    secondCircleImageView.tintColor = .systemBlue
    secondCircleImageView.alpha = 0
  }
  
  private func setupFindMoviesLabel() {
    NSLayoutConstraint.activate([
      findMoviesLabel.centerYAnchor.constraint(equalTo: secondCircleImageView.centerYAnchor),
      findMoviesLabel.leadingAnchor.constraint(equalTo: secondCircleImageView.trailingAnchor, constant: 10),
      findMoviesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
    ])
    findMoviesLabel.sizeToFit()
    findMoviesLabel.textColor = .darkGray
    findMoviesLabel.font = .boldSystemFont(ofSize: 17)
    findMoviesLabel.text = NSLocalizedString(.Localization.Onboarding.search, comment: "")
    findMoviesLabel.numberOfLines = 0
    findMoviesLabel.alpha = 0
  }
  
  private func setupNextButton() {
    NSLayoutConstraint.activate([
      nextButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07),
      nextButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
      nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
    ])
    nextButton.backgroundColor = .systemBlue
    nextButton.layer.cornerRadius = 12
    nextButton.setTitleColor(.white, for: .normal)
    nextButton.alpha = 0
    nextButton.setTitle(NSLocalizedString(.Localization.Onboarding.confirm, comment: ""), for: .normal)
    nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
  }
  
  private func setupThirdCircleImageView() {
    NSLayoutConstraint.activate([
      thirdCircleImageView.topAnchor.constraint(equalTo: secondCircleImageView.bottomAnchor, constant: 30),
      thirdCircleImageView.leadingAnchor.constraint(equalTo: secondCircleImageView.leadingAnchor),
      thirdCircleImageView.heightAnchor.constraint(equalTo: secondCircleImageView.heightAnchor),
      thirdCircleImageView.widthAnchor.constraint(equalTo: thirdCircleImageView.heightAnchor)
    ])
    thirdCircleImageView.tintColor = .systemBlue
    thirdCircleImageView.alpha = 0
  }
  
  private func setupSaveFilmsLabel() {
    NSLayoutConstraint.activate([
      saveFilmsLabel.centerYAnchor.constraint(equalTo: thirdCircleImageView.centerYAnchor),
      saveFilmsLabel.leadingAnchor.constraint(equalTo: thirdCircleImageView.trailingAnchor, constant: 10),
      saveFilmsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
    ])
    saveFilmsLabel.sizeToFit()
    saveFilmsLabel.textColor = .darkGray
    saveFilmsLabel.font = .boldSystemFont(ofSize: 17)
    saveFilmsLabel.text = NSLocalizedString(.Localization.Onboarding.saveTrips, comment: "")
    saveFilmsLabel.numberOfLines = 0
    saveFilmsLabel.alpha = 0
  }
  
}

//MARK:- Helping methods
extension WhatThisAppDoViewController {
  
  @objc private func nextButtonTapped() {
    onContinue?()
  }
  
  private func animateLabels() {
    view.setNeedsLayout()
    UIView.animate(withDuration: 0.5) {
      self.firstCircleImageView.alpha = 1
      self.secondCircleLeadingAnchor.constant = 20
      self.secondCircleImageView.alpha = 1
      self.receiveRecommendationsLabel.alpha = 1
      self.findMoviesLabel.alpha = 1
      self.thirdCircleImageView.alpha = 1
      self.saveFilmsLabel.alpha = 1
      self.view.layoutIfNeeded()
      
    } completion: { _ in
      UIView.animate(withDuration: 0.5) {
        self.nextButton.alpha = 1
      }
    }
  }
}
