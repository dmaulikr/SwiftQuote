import Foundation

// Swift 2.0

// poor man's parsers for (TSV) tab-separated value files
// for something more full-featured, the best avenue is CHCSVParser

/**
 Reads a multiline, tab-separated String and returns an Array<NSictionary>, taking column names from the first line or an explicit parameter
 */
func JSONObjectFromTSV(tsvInputString:String, columnNames optionalColumnNames:[String]? = nil) -> Array<NSDictionary>
{
    let lines = tsvInputString.componentsSeparatedByString("\n")
    guard lines.isEmpty == false else { return [] }
    
    let columnNames = optionalColumnNames ?? lines[0].componentsSeparatedByString("\t")
    var lineIndex = (optionalColumnNames != nil) ? 0 : 1
    let columnCount = columnNames.count
    var result = Array<NSDictionary>()
    
    for line in lines[lineIndex ..< lines.count] {
        let fieldValues = line.componentsSeparatedByString("\t")
        if fieldValues.count != columnCount {
            //      NSLog("WARNING: header has %u columns but line %u has %u columns. Ignoring this line", columnCount, lineIndex,fieldValues.count)
        }
        else
        {
            result.append(NSDictionary(objects: fieldValues, forKeys: columnNames))
        }
        lineIndex = lineIndex + 1
    }
    return result
}

/**
 commmand-line wrapper
 USAGE:
 # if file.tsv does not have field headers
 $ xcrun swift tsv_to_json.swift fieldname1 fieldName2 < file.tsv > output.json
 # if file.tsv does have field headers
 $ xcrun swift tsv_to_json.swift < file.tsv > output.json
 */
func mymain()
{
    let columnNames:[String]? = Process.arguments.count > 1 ? Array(Process.arguments[1..<Process.arguments.count]) : nil
    
    let stdin = NSFileHandle.fileHandleWithStandardInput()
    let inData = stdin.readDataToEndOfFile()
    let inString = NSString(data:inData,encoding:NSUTF8StringEncoding)! as String
    
    let outJSONObject =  JSONObjectFromTSV(inString,columnNames:columnNames)
    
    do {
        let outData = try NSJSONSerialization.dataWithJSONObject(outJSONObject,options:.PrettyPrinted)
        let stdout = NSFileHandle.fileHandleWithStandardOutput()
        stdout.writeData(outData)
        stdout.closeFile()
    }
    catch _ {
        NSLog("Error trying to deserialize JSON Object")
    }
}

// mymain()
