import Foundation

enum FileIOError: ErrorType
{
    case NotSerializableObject(String)
    case FileCreationError(String)
    case FileWriteError(String)
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
        let fileName: String,
            let location: NSSearchPathDirectory,
                let shouldCreate: Bool) throws -> String?
    {
        let fm: NSFileManager = NSFileManager()
        let appSupportDir: NSURL = try fm.URLForDirectory(
            location,
            inDomain: NSSearchPathDomainMask.UserDomainMask,
            appropriateForURL: nil,
            create: true
        )
        
        if fm.fileExistsAtPath(appSupportDir.URLByAppendingPathComponent(fileName).path!) {
            return appSupportDir.URLByAppendingPathComponent(fileName).path
        }
        else {
            if shouldCreate {
                NSLog("=> FILE *%@* DOES NOT EXISTS! CREATING...", fileName)
                guard fm.createFileAtPath(appSupportDir.URLByAppendingPathComponent(fileName).path!, contents: nil, attributes: nil) else {
                    throw FileIOError.FileCreationError("File cannot be created.")
                }
                
                return appSupportDir.URLByAppendingPathComponent(fileName).path
            }
            else {
                throw FileIOError.FileCreationError("No file to open.")
            }
        }
    }
    
    /// Method for writing, updating a object to file.
    ///
    /// \param fileName The name of the file archive.
    /// \param newData The new object to save.
    static func write(let fileName: String, let newData: AnyObject) throws
    {
        let fileName = String(format: "%@.%@.%@", fileName, AKAppVersion(), AKAppBuild())
        
        // 1. Check that object is serializable.
        guard newData is NSCoding else { throw FileIOError.NotSerializableObject("Object not serializable.") }
        
        do {
            NSLog("=> WRITING DATA...")
            
            let path = try AKFileUtils.openFileArchive(fileName, location: NSSearchPathDirectory.ApplicationSupportDirectory, shouldCreate: true)
            guard NSKeyedArchiver.archiveRootObject(newData, toFile: path!) else {
                throw FileIOError.FileWriteError("Error writing data to file.")
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
    static func read(let fileName: String) throws -> AnyObject
    {
        let fileName = String(format: "%@.%@.%@", fileName, AKAppVersion(), AKAppBuild())
        
        do {
            NSLog("=> READING DATA...")
            
            let path = try AKFileUtils.openFileArchive(fileName, location: NSSearchPathDirectory.ApplicationSupportDirectory, shouldCreate: false)
            if let object = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) {
                return object
            }
        }
        catch {
            NSLog("=> ERROR: \(error)")
        }
        
        return AKMasterFile()
    }
}
