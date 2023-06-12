import UIKit

protocol AlertPresenterProtocol {
    func showAlert(model: AlertModel)
}

class AlertPresenter: AlertPresenterProtocol {
    weak private var delegate: UIViewController?
    
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)

        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        delegate?.present(alert, animated: true)
    }
}
