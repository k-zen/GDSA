import Foundation

enum FileIOError: Error
{
    case notSerializableObject(text: String)
    case fileCreationError(text: String)
    case fileWriteError(text: String)
}

/// Utility class for handling file IO inside the App.
class AKFileUtils {
    
    /// This method checks if a file archive exists and if it does then return its URL.
    ///
    /// \param fileName The name of the file archive.
    /// \param location The location in the OS file system where to find the file. i.e. NSApplicationSupportDirectory
    ///
    /// \returns The URL of the file archive.
    static func openFileArchive(
        _ fileName: String,
        location: FileManager.SearchPathDirectory,
        shouldCreate: Bool) throws -> String?
    {
        let fm: FileManager = FileManager()
        let appSupportDir: URL = try fm.url(
            for: FileManager.SearchPathDirectory.applicationSupportDirectory,
            in: FileManager.SearchPathDomainMask.userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        if fm.fileExists(atPath: appSupportDir.appendingPathComponent(fileName).path) {
            return appSupportDir.appendingPathComponent(fileName).path
        }
        else {
            if shouldCreate {
                NSLog("=> FILE *%@* DOES NOT EXISTS! CREATING...", fileName)
                guard fm.createFile(atPath: appSupportDir.appendingPathComponent(fileName).path, contents: nil, attributes: nil) else {
                    throw FileIOError.fileCreationError(text: "File cannot be created.")
                }
                
                return appSupportDir.appendingPathComponent(fileName).path
            }
            else {
                throw FileIOError.fileCreationError(text: "No file to open.")
            }
        }
    }
    
    /// Method for writing, updating a object to file.
    ///
    /// \param fileName The name of the file archive.
    /// \param newData The new object to save.
    static func write(_ fileName: String, newData: AnyObject) throws
    {
        let fileName = String(format: "%@.%@.%@", fileName, AKAppVersion(), AKAppBuild())
        
        // 1. Check that object is serializable.
        guard newData is NSCoding else { throw FileIOError.notSerializableObject(text: "Object not serializable.") }
        
        do {
            NSLog("=> WRITING DATA...")
            
            let path = try AKFileUtils.openFileArchive(fileName, location: FileManager.SearchPathDirectory.applicationSupportDirectory, shouldCreate: true)
            guard NSKeyedArchiver.archiveRootObject(newData, toFile: path!) else {
                throw FileIOError.fileWriteError(text: "Error writing data to file.")
            }
        }
        catch {
            NSLog("=> ERROR: \(error)")
        }
    }
    
    /// Method for reading an object from file.
    ///
    /// \param fileName The name of the file archive.
    ///
    /// \returns The object.
    static func read(_ fileName: String) throws -> AnyObject
    {
        let fileName = String(format: "%@.%@.%@", fileName, AKAppVersion(), AKAppBuild())
        
        do {
            NSLog("=> READING DATA...")
            
            let path = try AKFileUtils.openFileArchive(fileName, location: FileManager.SearchPathDirectory.applicationSupportDirectory, shouldCreate: false)
            if let object = NSKeyedUnarchiver.unarchiveObject(withFile: path!) {
                return object
            }
        }
        catch {
            NSLog("=> ERROR: \(error)")
        }
        
        return AKMasterFile()
    }
}
