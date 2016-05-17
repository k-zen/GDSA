import Foundation

enum InputDataError: ErrorType
{
    case EmptyData(String)
    case InvalidLength(String)
    case NotValid(String)
}

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
        guard inputData != nil && !inputData.isEmpty else { throw InputDataError.EmptyData("Empty data.") }
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
