// Hungry Philosophers Problem Solution in Swift
import UIKit

class ViewController: UIViewController {
    var n = 5 { // Default number of philosophers
        didSet {
            countLabel.text = "Philosophers: \(n)"
            resetPhilosophers()
        }
    }

    var roundNumber = 0 {
        didSet {
            roundLabel.text = "Round \(roundNumber)"
        }
    }

    var philosopherViews: [UILabel] = []
    let advanceButton = UIButton(type: .system)
    let roundLabel = UILabel()
    let countLabel = UILabel()
    let slider = UISlider()

    var centerPoint: CGPoint {
        CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        resetPhilosophers()
        renderRound()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPhilosophers()
    }

    func setupUI() {
        advanceButton.setTitle("Advance Round", for: .normal)
        advanceButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(advanceButton)
        advanceButton.addTarget(self, action: #selector(advanceRound), for: .touchUpInside)

        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(roundLabel)

        countLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countLabel)

        slider.minimumValue = 3
        slider.maximumValue = 21
        slider.value = Float(n)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        view.addSubview(slider)

        NSLayoutConstraint.activate([
            advanceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            advanceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            slider.bottomAnchor.constraint(equalTo: advanceButton.topAnchor, constant: -20),
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            countLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            roundLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 10),
            roundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    func resetPhilosophers() {
        for label in philosopherViews { label.removeFromSuperview() }
        philosopherViews.removeAll()

        for _ in 0..<n {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 16)
            label.text = "🍽"
            label.backgroundColor = .clear
            philosopherViews.append(label)
            view.addSubview(label)
        }

        layoutPhilosophers()
        renderRound()
    }

    func layoutPhilosophers() {
        let radius: CGFloat = min(view.bounds.width, view.bounds.height) / 2.5
        for (i, label) in philosopherViews.enumerated() {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(n))
            let x = centerPoint.x + radius * cos(angle)
            let y = centerPoint.y + radius * sin(angle)
            label.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
            label.center = CGPoint(x: x, y: y)
            label.layer.cornerRadius = 20
            label.layer.masksToBounds = true
        }
    }

    func eatingIndices(forRound round: Int, total: Int) -> Set<Int> {
        // Use a fixed stride to space out eating philosophers
        var indices = Set<Int>()
        let stride = 3
        var start = round % total
        for _ in 0..<total {
            if indices.contains((start - 1 + total) % total) == false &&
               indices.contains((start + 1) % total) == false {
                indices.insert(start)
            }
            start = (start + 1) % total
        }
        return indices
    }

    func renderRound() {
        let eaters = eatingIndices(forRound: roundNumber, total: n)
        for (i, label) in philosopherViews.enumerated() {
            label.backgroundColor = eaters.contains(i) ? UIColor.green.withAlphaComponent(0.3) : .clear
        }
    }

    @objc func advanceRound() {
        roundNumber += 1
        renderRound()
    }

    @objc func sliderChanged() {
        n = Int(slider.value)
        roundNumber = 0
    }
}
