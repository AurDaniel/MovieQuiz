import UIKit

final class AlertPresenter{
    
    func show(from viewController: UIViewController, with model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Game Results"
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
