//
//  JuiceMaker - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom academy. All rights reserved.
// 

import UIKit

class JuiceMakerViewController: UIViewController {

    private let juiceMaker = JuiceMaker()
    
    @IBOutlet weak var strawberryStockLabel: UILabel!
    @IBOutlet weak var bananaStockLabel: UILabel!
    @IBOutlet weak var pineappleStockLabel: UILabel!
    @IBOutlet weak var kiwiStockLabel: UILabel!
    @IBOutlet weak var mangoStockLabel: UILabel!
    
    @IBOutlet weak var orderStrawberryBananaJuiceButton: UIButton!
    @IBOutlet weak var orderMangoKiwiJuiceButton: UIButton!
    @IBOutlet weak var orderStrawberryJuiceButton: UIButton!
    @IBOutlet weak var orderBananaJuiceButton: UIButton!
    @IBOutlet weak var orderPineappleJuiceButton: UIButton!
    @IBOutlet weak var orderKiwiJuiceButton: UIButton!
    @IBOutlet weak var orderMangoJuiceButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFruitLabels()
    
        NotificationCenter.default.addObserver(self, selector: #selector(fruitLabelChanged(notification:)), name: .changedFruitStockNotification, object: nil)
    }
    
    @IBAction func orderJuiceButtonTapped(_ sender: UIButton) {
        let juice: Juice
        
        switch sender {
        case orderStrawberryBananaJuiceButton:
            juice = .strawberryBanana
        case orderMangoKiwiJuiceButton:
            juice = .mangoKiwi
        case orderStrawberryJuiceButton:
            juice = .strawberry
        case orderBananaJuiceButton:
            juice = .banana
        case orderPineappleJuiceButton:
            juice = .pineapple
        case orderKiwiJuiceButton:
            juice = .kiwi
        case orderMangoJuiceButton:
            juice = .mango
        default:
            showNotificationAlert(message: Message.unknownError.description)
            return
        }
        
        mixFruit(juice: juice)
    }
    
    func mixFruit(juice: Juice) {
        do {
            try juiceMaker.mixFruit(juice: juice)
            showNotificationAlert(message: Message.juiceFinish(juice: juice).description)
        } catch RequestError.fruitStockOut {
            showOutOfStockAlert()
        } catch let error as RequestError {
            showNotificationAlert(message: error.errorDescription)
        } catch {
            showNotificationAlert(message: Message.unknownError.description)
        }
    }
    
    @objc func fruitLabelChanged(notification: Notification) {
        guard let fruit = notification.object as? Fruit else {
            showNotificationAlert(message: Message.unknownError.description)
            return
        }
        currentStockLabelUpdate(fruit: fruit, label: fruitlabel(of: fruit))
    }
    
    func updateFruitLabels() {
        currentStockLabelUpdate(fruit: .strawberry, label: strawberryStockLabel)
        currentStockLabelUpdate(fruit: .banana, label: bananaStockLabel)
        currentStockLabelUpdate(fruit: .pineapple, label: pineappleStockLabel)
        currentStockLabelUpdate(fruit: .kiwi, label: kiwiStockLabel)
        currentStockLabelUpdate(fruit: .mango, label: mangoStockLabel)
    }
    
    func currentStockLabelUpdate(fruit: Fruit, label: UILabel) {
        do {
            let stock = try FruitStore.shared.stock(fruit: fruit)
            label.text = stock.description
        } catch let error as RequestError {
            showNotificationAlert(message: error.errorDescription)
        } catch {
            showNotificationAlert(message: Message.unknownError.description)
        }
    }
    
    func fruitlabel(of fruit: Fruit) -> UILabel {
        switch fruit {
        case .strawberry:
            return strawberryStockLabel
        case .banana:
            return bananaStockLabel
        case .pineapple:
            return pineappleStockLabel
        case .kiwi:
            return kiwiStockLabel
        case .mango:
            return mangoStockLabel
        }
    }
    
    func showNotificationAlert(message: String, title: String = Text.ok.title) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: title, style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func showOutOfStockAlert() {
        let alert = UIAlertController(title: nil, message: Message.outOfStock.description, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Text.cancel.title, style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: Text.ok.title, style: .default, handler: presentFruitStoreViewController)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func presentFruitStoreViewController(_ action: UIAlertAction) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FruitStoreViewController") as? UINavigationController else { return }
        self.present(viewController, animated: true, completion: nil)
        
        guard let nextViewController = viewController.topViewController as? FruitStoreViewController else { return }
        
        nextViewController.loadViewIfNeeded()
        nextViewController.strawberryStockLabel.text = strawberryStockLabel.text
        nextViewController.bananaStockLabel.text = bananaStockLabel.text
        nextViewController.pineappleStockLabel.text = pineappleStockLabel.text
        nextViewController.kiwiStockLabel.text = kiwiStockLabel.text
        nextViewController.mangoStockLabel.text = mangoStockLabel.text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController else { return }
        
        guard let nextViewController = navigationController.topViewController as? FruitStoreViewController else { return }
        
        nextViewController.loadViewIfNeeded()
        nextViewController.strawberryStockLabel.text = strawberryStockLabel.text
        nextViewController.bananaStockLabel.text = bananaStockLabel.text
        nextViewController.pineappleStockLabel.text = pineappleStockLabel.text
        nextViewController.kiwiStockLabel.text = kiwiStockLabel.text
        nextViewController.mangoStockLabel.text = mangoStockLabel.text
    }
}

