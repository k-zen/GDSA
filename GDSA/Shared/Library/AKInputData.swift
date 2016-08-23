import Foundation

/// Base class for all *Input Data* in the App.
class AKInputData: NSObject
{
    // MARK: Properties
    internal let inputData: String!
    internal var outputData: String!
    
    init(inputData: String)
    {
        self.inputData = inputData
    }
    
    internal func isReady() throws
    {
        guard inputData != nil && !inputData.isEmpty else { throw Exceptions.emptyData("Empty data.") }
    }
    
    func validate() throws
    {
        // Implement.
    }
    
    func process() throws
    {
        self.outputData = self.inputData
    }
}
