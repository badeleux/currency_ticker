platform :ios, '8.0'
use_frameworks!

def shared_pods
    pod 'ReactiveSwift'
    pod 'Moya-Argo/ReactiveCocoa'
    pod 'SwiftDate', '~> 4.0'
end

target 'CurrencyTicker' do
    shared_pods
end

target 'CurrencyTickerKit' do
    shared_pods
    pod 'Alamofire', '~> 4.3'
    pod 'Curry'
    pod 'Ogra'
    
    target 'CurrencyTickerKitTests' do
        inherit! :search_paths
        
        pod 'Quick'
        pod 'Nimble'
    end
end

target 'CurrencyTickeriOS' do
    shared_pods
    pod 'DZNEmptyDataSet'
    pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
    pod 'EasyPeasy'
    pod 'ReactiveCocoa'
    pod 'SwiftCharts', '~> 0.5'
    pod 'SwiftMessages'
    pod 'TextAttributes'
end
