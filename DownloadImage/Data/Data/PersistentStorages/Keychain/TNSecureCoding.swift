//
//  TNSecureCoding.swift
//  DownloadImage
//
//  Created by Trieu Nguyen on 27/08/2021.
//

import Foundation

public enum TNSecureCodingError: Error {
    case unableArchived(underlyingError: Error)
    case unableUnarchived(underlyingError: Error)
    
    public var errorCode: Int {
        switch self {
        case .unableArchived:
            return 640
        case .unableUnarchived:
            return 641
        }
    }
    
    public var localizedDescription: String {
        switch self {
        case .unableArchived(let underlyingError):
            return "unableArchived errorCode: \(self.errorCode) - underlyingError: \(underlyingError.localizedDescription)"
            
        case .unableUnarchived(let underlyingError):
            return "unableUnarchived errorCode: \(self.errorCode) - underlyingError: \(underlyingError.localizedDescription)"
        }
    }
}

final public class TNSecureCoding {
    
    static public func archivedData(with rootObject: Any) throws -> Data? {
        var archiveData: Data? = nil
        
        if #available(iOS 11, *) {
            do {
                archiveData = try NSKeyedArchiver.archivedData(withRootObject: rootObject,
                                                               requiringSecureCoding: true)
            } catch let archiveError {
                throw TNSecureCodingError.unableArchived(underlyingError: archiveError)
            }
        } else {
            let data = NSMutableData()
            
            let archiver = NSKeyedArchiver(forWritingWith: data)
            archiver.requiresSecureCoding = true
            
            archiver.encode(rootObject, forKey: NSKeyedArchiveRootObjectKey)
            archiveData = data.copy() as? Data
        }
        
        return archiveData
    }
    
    static public func unarchivedObjectOfClass(_ cls: AnyClass, data: Data) throws -> Any? {
        return try self.unarchivedObjectOfClasses([cls], data: data)
    }
    
    static public func unarchivedObjectOfClasses(_ classes: [AnyClass], data: Data) throws -> Any? {
        var object: Any? = nil
        
        if #available(iOS 11, *) {
            do {
                object = try NSKeyedUnarchiver.unarchivedObject(ofClasses: classes, from: data)
            } catch let unarchivedError {
                throw TNSecureCodingError.unableUnarchived(underlyingError: unarchivedError)
            }
        } else {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            unarchiver.requiresSecureCoding = true
            
            object = unarchiver.decodeObject(of: classes, forKey: NSKeyedArchiveRootObjectKey)
        }
        
        return object
    }
}
