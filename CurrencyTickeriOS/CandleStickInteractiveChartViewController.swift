//
//  CandleStickInteractiveChartViewController.swift
//  CurrencyTicker
//
//  Created by Kamil Badyla on 24.02.2017.
//  Copyright © 2017 ScienceSpir.IT. All rights reserved.
//

import Foundation
import SwiftCharts
import ReactiveSwift
import UIKit
import CurrencyTickerKit
import ReactiveCocoa

extension CandleStickData {
    func toChartData() -> ChartPointCandleStick {
        return ChartPointCandleStick(date: self.date, formatter: DefaultDateFormatter.shared.short, high: Double(self.high), low: Double(self.low), open: Double(self.open), close: Double(self.close))
    }
}

class CandleStickInteractiveChartViewController<T: CandleStickData>: UIViewController {
    
    fileprivate var chart: Chart? // arc
    let chartViewModel: CurrencyHistoricalDataViewModel<T>
    var emptyView: EmptyView?
    
    fileprivate static var defaultChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.trailing = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        chartSettings.labelsSpacing = 0
        return chartSettings
    }
    
    init(chartViewModel: CurrencyHistoricalDataViewModel<T>) {
        self.chartViewModel = chartViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emptyView = EmptyView(frame: self.view.bounds, screen: .chart)
        self.emptyView!.emptyStateDataSource.state <~ self.chartViewModel.emptyListState()
        self.emptyView!.reactive.isHidden <~ self.chartViewModel.chartData.signal.map { _ in true }
        self.view.addSubview(self.emptyView!)
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.backgroundColor = UIColor.white
        self.chartViewModel.chartData.signal.observeValues { [weak self] (data: CurrencyChartData<T>) in
            if let c = self?.chart {
                c.view.removeFromSuperview()
            }
            if let chart = self?.createChart(data: data) {
                self?.view.addSubview(chart.view)
                self?.chart = chart
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func createChart(data: CurrencyChartData<T>) -> Chart {
        let points = data.points.map { $0.toChartData() }
        let labelSettings = ChartLabelSettings(font: UIFont.annotationFont)
        
        let xValues = self.hideValues(values: data.xAxisDates
            .map { ChartAxisValueDate(date: $0, formatter: DefaultDateFormatter.shared.chartAxis, labelSettings: labelSettings) }, toLimit: 10)
        
        let yValues = data.yAxisValues.map { ChartAxisValueDouble(Double($0), labelSettings: labelSettings) }
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Date", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Value", settings: labelSettings.defaultVertical()))
        
        let defaultChartFrame = view.bounds.insetBy(dx: 5, dy: 5)
        let infoViewHeight: CGFloat = 50
        let chartFrame = CGRect(x: defaultChartFrame.origin.x, y: defaultChartFrame.origin.y + infoViewHeight, width: defaultChartFrame.width, height: defaultChartFrame.height - infoViewHeight)
        
        let chartSettings = CandleStickInteractiveChartViewController.defaultChartSettings
        
        let coordsSpace = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let viewGenerator = {(chartPointModel: ChartPointLayerModel<ChartPointCandleStick>, layer: ChartPointsViewsLayer<ChartPointCandleStick, ChartCandleStickView>, chart: Chart, isTransformed: Bool) -> ChartCandleStickView? in
            let (chartPoint, screenLoc) = (chartPointModel.chartPoint, chartPointModel.screenLoc)
            
            let x = screenLoc.x
            
            let highScreenY = screenLoc.y
            let lowScreenY = layer.modelLocToScreenLoc(x: Double(x), y: Double(chartPoint.low)).y
            let openScreenY = layer.modelLocToScreenLoc(x: Double(x), y: Double(chartPoint.open)).y
            let closeScreenY = layer.modelLocToScreenLoc(x: Double(x), y: Double(chartPoint.close)).y
            
            let (rectTop, rectBottom, fillColor) = closeScreenY < openScreenY ? (closeScreenY, openScreenY, UIColor.white) : (openScreenY, closeScreenY, UIColor.black)
            let v = ChartCandleStickView(lineX: screenLoc.x, width: 5, top: highScreenY, bottom: lowScreenY, innerRectTop: rectTop, innerRectBottom: rectBottom, fillColor: fillColor, strokeWidth: 0.5)
            v.isUserInteractionEnabled = false
            return v
        }
        let candleStickLayer = ChartPointsCandleStickViewsLayer<ChartPointCandleStick, ChartCandleStickView>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, chartPoints: points, viewGenerator: viewGenerator)
        
        
        let infoView = InfoWithIntroView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: infoViewHeight))
        view.addSubview(infoView)
        
        let trackerLayer = ChartPointsTrackerLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: points, locChangedFunc: { screenLoc in
            candleStickLayer.highlightChartpointView(screenLoc: screenLoc)
            if let chartPoint = candleStickLayer.chartPointsForScreenLocX(screenLoc.x).first {
                infoView.showChartPoint(chartPoint)
            } else {
                infoView.clear()
            }
            }, lineColor: UIColor.red, lineWidth: 0.6)
        
        
        let settings = ChartGuideLinesLayerSettings(linesColor: UIColor.black, linesWidth: 0.1)
        let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
        
        let dividersSettings =  ChartDividersLayerSettings(linesColor: UIColor.black, linesWidth: 0.1, start: 3, end: 0)
        let dividersLayer = ChartDividersLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: dividersSettings)
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                dividersLayer,
                candleStickLayer,
                trackerLayer
            ]
        )
        return chart

    }
    
    func hideValues<T: ChartAxisValue>(values: [T], toLimit limit: Int) -> [T] {
        let count = values.count
        let rest = count / limit
        if limit >= count {
            return values
        }
        else {
            return values.enumerated().map { index, element in
                if index % rest != 0 {
                    element.hidden = true
                }
                return element
            }
        }
    }
    
}


private class InfoView: UIView {
    
    let statusView: UIView
    
    let dateLabel: UILabel
    let lowTextLabel: UILabel
    let highTextLabel: UILabel
    let openTextLabel: UILabel
    let closeTextLabel: UILabel
    
    let lowLabel: UILabel
    let highLabel: UILabel
    let openLabel: UILabel
    let closeLabel: UILabel
    
    override init(frame: CGRect) {
        
        let itemHeight: CGFloat = 40
        let y = (frame.height - itemHeight) / CGFloat(2)
        
        statusView = UIView(frame: CGRect(x: 0, y: y, width: itemHeight, height: itemHeight))
        statusView.layer.borderColor = UIColor.black.cgColor
        statusView.layer.borderWidth = 1
        statusView.layer.cornerRadius = 8
        
        let font = UIFont.annotationFont
        
        dateLabel = UILabel()
        dateLabel.font = font
        
        lowTextLabel = UILabel()
        lowTextLabel.text = "Low:"
        lowTextLabel.font = font
        lowLabel = UILabel()
        lowLabel.font = font
        
        highTextLabel = UILabel()
        highTextLabel.text = "High:"
        highTextLabel.font = font
        highLabel = UILabel()
        highLabel.font = font
        
        openTextLabel = UILabel()
        openTextLabel.text = "Open:"
        openTextLabel.font = font
        openLabel = UILabel()
        openLabel.font = font
        
        closeTextLabel = UILabel()
        closeTextLabel.text = "Close:"
        closeTextLabel.font = font
        closeLabel = UILabel()
        closeLabel.font = font
        
        super.init(frame: frame)
        
        addSubview(statusView)
        addSubview(dateLabel)
        addSubview(lowTextLabel)
        addSubview(lowLabel)
        addSubview(highTextLabel)
        addSubview(highLabel)
        addSubview(openTextLabel)
        addSubview(openLabel)
        addSubview(closeTextLabel)
        addSubview(closeLabel)
    }
    
    fileprivate override func didMoveToSuperview() {
        
        let views = [statusView, dateLabel, highTextLabel, highLabel, lowTextLabel, lowLabel, openTextLabel, openLabel, closeTextLabel, closeLabel]
        for v in views {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let namedViews = views.enumerated().map{index, view in
            ("v\(index)", view)
        }
        
        var viewsDict = Dictionary<String, UIView>()
        for namedView in namedViews {
            viewsDict[namedView.0] = namedView.1
        }
        
        let circleDiameter: CGFloat = 15
        let labelsSpace: CGFloat = 5
        
        let hConstraintStr = namedViews[1..<namedViews.count].reduce("H:|[v0(\(circleDiameter))]") {str, tuple in
            "\(str)-(\(labelsSpace))-[\(tuple.0)]"
        }
        
        let vConstraits = namedViews.flatMap {NSLayoutConstraint.constraints(withVisualFormat: "V:|-(18)-[\($0.0)(\(circleDiameter))]", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)}
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: hConstraintStr, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)
            + vConstraits)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showChartPoint(_ chartPoint: ChartPointCandleStick) {
        let color = chartPoint.open > chartPoint.close ? UIColor.black : UIColor.white
        statusView.backgroundColor = color
        
        dateLabel.text = chartPoint.x.labels.first?.text ?? ""
        lowLabel.text = String(format: "%.5f", chartPoint.low)
        highLabel.text = String(format: "%.5f", chartPoint.high)
        openLabel.text = String(format: "%.5f", chartPoint.open)
        closeLabel.text = String(format: "%.5f", chartPoint.close)
    }
    
    func clear() {
        statusView.backgroundColor = UIColor.clear
    }
}


private class InfoWithIntroView: UIView {
    
    var introView: UIView!
    var infoView: InfoView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    fileprivate override func didMoveToSuperview() {
        let label = UILabel(frame: CGRect(x: 0, y: bounds.origin.y, width: bounds.width, height: bounds.height))
        label.text = "Drag the line to see chartpoint data"
        label.font = UIFont.titleFont
        label.backgroundColor = UIColor.white
        introView = label
        
        infoView = InfoView(frame: bounds)
        
        addSubview(infoView)
        addSubview(introView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func animateIntroAlpha(_ alpha: CGFloat) {
        UIView.animate(withDuration: 0.1, animations: {
            self.introView.alpha = alpha
        })
    }
    
    func showChartPoint(_ chartPoint: ChartPointCandleStick) {
        animateIntroAlpha(0)
        infoView.showChartPoint(chartPoint)
    }
    
    func clear() {
        animateIntroAlpha(1)
        infoView.clear()
    }
}
