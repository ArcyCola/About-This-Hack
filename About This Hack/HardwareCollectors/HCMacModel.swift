import Foundation

class HCMacModel {
    static let shared = HCMacModel()
    private init() {}
    
    private(set) var macName: String = "Hackintosh Extreme Plus"
    private(set) var builtInDisplaySize: Float = 0
    private(set) var dataHasBeenSet: Bool = false
    
    func getMacModel() {
        guard !dataHasBeenSet else { return }
        ATHLogger.debug("Initializing Mac Model Info...", category: .hardware)
        macName = getMacName()
        ATHLogger.debug("Mac Name: \(macName)", category: .hardware)
        dataHasBeenSet = true
    }
    
    func getModelIdentifier() -> String {
        ATHLogger.debug("Getting Model Identifier...", category: .hardware)
        if let fullIdentifier = getSysctlValueByKey(inputKey: "hw.model") {
            let parts = fullIdentifier.components(separatedBy: ":")
            let modelId = parts.last?.trimmingCharacters(in: .whitespacesAndNewlines)
            let finalModelId = modelId?.nilIfEmpty ?? "Unknown"
            ATHLogger.debug("Full Model Identifier (hw.model): \(fullIdentifier), Parsed ID: \(finalModelId)", category: .hardware)
            return finalModelId
        }
        ATHLogger.warning("Failed to get Model Identifier from hw.model.", category: .hardware)
        return "Unknown"
    }
    
    private func getMacName() -> String {
        ATHLogger.debug("Getting Mac Name...", category: .hardware)
        let infoString = getModelIdentifier()
        let (displaySize, name) = macModels[infoString] ?? (0, "Mac")
        builtInDisplaySize = displaySize
        ATHLogger.debug("Looked up Mac Name for identifier '\(infoString)': (\(displaySize), \(name))", category: .hardware)
        
        // if not in macModels, use plist just in case
        if (name == "Mac" && infoString != "MacPro7,1") {
            let baseCommand = "defaults read"
            let plistPath = "~/Library/Preferences/com.apple.SystemProfiler.plist"
            let key = "\"CPU Names\""
            let cutCommand = "| cut -sd '\"' -f 4"
            let uniqCommand = "| uniq"

            // Combine all parts into a single command string
            let fullCommand = "\(baseCommand) \(plistPath) \(key) \(cutCommand) \(uniqCommand)"
    
            return run(fullCommand).trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? name
        }
        
        // MacPro7,1 OK
        let command = "cat \(InitGlobVar.hwFilePath) | grep \"Model Identifier\" | cut -d \":\" -f4"
        let macNameFromHwFile = run(command).trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? name
        ATHLogger.debug("Mac Name from hwFilePath: \(macNameFromHwFile)", category: .hardware)
        return macNameFromHwFile
    }
    
    private lazy var macModels: [String: (Float, String)] = [
        // iMacs
        "iMac4,1": (17, "iMac 17-Inch \"Core Duo\" 1.83"),
        "iMac4,2": (17, "iMac 17-Inch \"Core Duo\" 1.83"),
        "iMac5,1": (17, "iMac 17-Inch \"Core 2 Duo\" 2.0"),
        "iMac5,2": (17, "iMac 17-Inch \"Core 2 Duo\" 1.83"),
        "iMac7,1": (17, "iMac 17-Inch \"Core 2 Duo\" 2.0"),
        "iMac8,1": (20, "iMac (Early 2008)"),
        "iMac9,1": (20, "iMac (Mid 2009)"),
        "iMac10,1": (20, "iMac (Late 2009)"),
        "iMac11,2": (21.5, "iMac (21.5-Inch, Mid 2010)"),
        "iMac12,1": (21.5, "iMac (21.5-Inch, Mid 2011)"),
        "iMac13,1": (21.5, "iMac (21.5-Inch, Mid 2012/Early 2013)"),
        "iMac14,1": (21.5, "iMac (21.5-Inch, Late 2013)"),
        "iMac14,3": (21.5, "iMac (21.5-Inch, Late 2013)"),
        "iMac14,4": (21.5, "iMac (21.5-Inch, Mid 2014)"),
        "iMac16,1": (21.5, "iMac (21.5-Inch, Late 2015)"),
        "iMac16,2": (21.5, "iMac (21.5-Inch, Late 2015)"),
        "iMac18,1": (21.5, "iMac (21.5-Inch, 2017)"),
        "iMac18,2": (21.5, "iMac (Retina 4K, 2017)"),
        "iMac19,2": (21.5, "iMac (Retina 4K, 2019)"),
        "iMac19,3": (21.5, "iMac (Retina 4K, 2019)"),
        "iMac11,1": (27, "iMac (27-Inch, Late 2009)"),
        "iMac11,3": (27, "iMac (27-Inch, Mid 2010)"),
        "iMac12,2": (27, "iMac (27-Inch, Mid 2011)"),
        "iMac13,2": (27, "iMac (27-Inch, Mid 2012)"),
        "iMac14,2": (27, "iMac (27-Inch, Late 2013)"),
        "iMac15,1": (27, "iMac (Retina 5K, Late 2014)"),
        "iMac17,1": (27, "iMac (Retina 5K, Late 2015)"),
        "iMac18,3": (27, "iMac (Retina 5K, 2017)"),
        "iMac19,1": (27, "iMac (Retina 5K, 2019)"),
        "iMac20,1": (27, "iMac (Retina 5K, 2020)"),
        "iMac20,2": (27, "iMac (Retina 5K, 2020)"),
        "iMac21,1": (24, "iMac (24-inch, M1, 2021)"),
        "iMac21,2": (24, "iMac (24-inch, M1, 2021)"),
        "Mac15,4": (24, "iMac (24-inch, M3, 2023)"),
        "Mac15,5": (24, "iMac (24-inch, M3, 2023)"),
        "Mac16,2": (24, "iMac (24-inch, M4, 2024)"), // two ports
        "Mac16,3": (24, "iMac (24-inch, M4, 2024)"), // four ports
        
        // iMac Pros
        "iMacPro1,1": (27, "iMac Pro (2017)"),
        
        // Developer Transition Kits
        "ADP3,2": (0, "Developer Transition Kit (ARM)"),
        
        // Mac Minis
        "Macmini3,1": (0, "Mac Mini (Early 2009)"),
        "Macmini4,1": (0, "Mac Mini (Mid 2010)"),
        "Macmini5,1": (0, "Mac Mini (Mid 2011)"),
        "Macmini5,2": (0, "Mac Mini (Mid 2011)"),
        "Macmini5,3": (0, "Mac Mini (Mid 2011)"),
        "Macmini6,1": (0, "Mac Mini (Late 2012)"),
        "Macmini6,2": (0, "Mac Mini Server (Late 2012)"),
        "Macmini7,1": (0, "Mac Mini (Late 2014)"),
        "Macmini8,1": (0, "Mac Mini (Late 2018)"),
        "Macmini9,1": (0, "Mac Mini (M1, 2020)"),
        "Mac14,3": (0, "Mac Mini (M2, 2023)"),
        "Mac14,12": (0, "Mac Mini (M2 Pro, 2023)"),
        "Mac16,10": (0, "Mac Mini (2024)"), // not sure which ones m4 vs pro
        "Mac16,11": (0, "Mac Mini (2024)"),

        // Mac Pros
        "MacPro3,1": (0, "Mac Pro (2008)"),
        "MacPro4,1": (0, "Mac Pro (2009)"),
        "MacPro5,1": (0, "Mac Pro (2010-2012)"),
        "MacPro6,1": (0, "Mac Pro (Late 2013)"),
        "MacPro7,1": (0, "Mac Pro (2019)"),
        "Mac14,8": (0, "Mac Pro (2023)"),
        
        // Mac Studios
        "Mac13,1": (0, "Mac Studio (M1 Max, 2022)"),
        "Mac13,2": (0, "Mac Studio (M1 Ultra, 2022)"),
        "Mac14,13": (0, "Mac Studio (M2 Max, 2023)"),
        "Mac14,14": (0, "Mac Studio (M2 Ultra, 2023)"),
        "Mac15,14": (0, "Mac Studio (M3 Ultra, 2025)"),
        "Mac16,9": (0, "Mac Studio (M4 Max, 2025)"),
        
        // MacBooks
        "MacBook5,1": (13, "MacBook"),
        "MacBook5,2": (13, "MacBook (2009)"),
        "MacBook6,1": (13, "MacBook (Late 2009)"),
        "MacBook7,1": (13, "MacBook (Mid 2010)"),
        "MacBook8,1": (13, "MacBook (Early 2015)"),
        "MacBook9,1": (13, "MacBook (Early 2016)"),
        "MacBook10,1": (13, "MacBook (Mid 2017)"),
        
        // MacBook Airs
        "MacBookAir1,1": (13, "MacBook Air (2008)"),
        "MacBookAir2,1": (13, "MacBook Air (Mid 2009)"),
        "MacBookAir3,1": (11, "MacBook Air (11-inch, Late 2010)"),
        "MacBookAir3,2": (13, "MacBook Air (13-inch, Late 2010)"),
        "MacBookAir4,1": (11, "MacBook Air (11-inch, Mid 2011)"),
        "MacBookAir4,2": (13, "MacBook Air (13-inch, Mid 2011)"),
        "MacBookAir5,1": (11, "MacBook Air (11-inch, Mid 2012)"),
        "MacBookAir5,2": (13, "MacBook Air (13-inch, Mid 2012)"),
        "MacBookAir6,1": (11, "MacBook Air (11-inch, Mid 2013/Early 2014)"),
        "MacBookAir6,2": (13, "MacBook Air (13-inch, Mid 2013/Early 2014)"),
        "MacBookAir7,1": (11, "MacBook Air (11-inch, Early 2015/2017)"),
        "MacBookAir7,2": (13, "MacBook Air (13-inch, Early 2015/2017)"),
        "MacBookAir8,1": (13, "MacBook Air (13-inch, Late 2018)"),
        "MacBookAir8,2": (13, "MacBook Air (13-inch, 2019)"),
        "MacBookAir9,1": (13, "MacBook Air (13-inch, 2020)"),
        "MacBookAir10,1": (13, "MacBook Air (13-inch, M1, 2020)"),
        "Mac14,2": (13, "MacBook Air (13-inch, M2, 2022)"),
        "Mac14,15": (15, "MacBook Air (15-inch, M2, 2023)"),
        "Mac15,12": (13, "MacBook Air (13-inch, M3, 2024)"),
        "Mac15,13": (15, "MacBook Air (15-inch, M3, 2024)"),
        "Mac16,12": (13, "MacBook Air (13-inch, M4, 2025)"),
        "Mac16,13": (15, "MacBook Air (15-inch, M4, 2025)"),
        
        // MacBook Pros
        // 13-inch
        "MacBookPro5,5": (13, "MacBook Pro (13-inch, 2009)"),
        "MacBookPro7,1": (13, "MacBook Pro (13-inch, Mid 2010)"),
        "MacBookPro8,1": (13, "MacBook Pro (13-inch, Early 2011)"),
        "MacBookPro9,2": (13, "MacBook Pro (13-inch, Mid 2012)"),
        "MacBookPro10,2": (13, "MacBook Pro (Retina, 13-inch, 2012)"),
        "MacBookPro11,1": (13, "MacBook Pro (Retina, 13-inch, Late 2013/Mid 2014)"),
        "MacBookPro12,1": (13, "MacBook Pro (Retina, 13-inch, Early 2015)"),
        "MacBookPro13,1": (13, "MacBook Pro (Retina, 13-inch, Late 2016)"),
        "MacBookPro13,2": (13, "MacBook Pro (Retina, 13-inch, Late 2016)"),
        "MacBookPro14,1": (13, "MacBook Pro (Retina, 13-inch, Mid 2017)"),
        "MacBookPro14,2": (13, "MacBook Pro (Retina, 13-inch, Mid 2017)"),
        "MacBookPro15,2": (13, "MacBook Pro (Retina, 13-inch, Mid 2018)"),
        "MacBookPro15,4": (13, "MacBook Pro (Retina, 13-inch, Mid 2019)"),
        "MacBookPro16,2": (13, "MacBook Pro (Retina, 13-inch, Mid 2020)"),
        "MacBookPro16,3": (13, "MacBook Pro (Retina, 13-inch, Mid 2020)"),
        "MacBookPro17,1": (13, "MacBook Pro (13-inch, M1, 2020)"),
        "Mac14,7": (13, "MacBook Pro (13-inch, M2, 2022)"),
        
        // 14-inch
        "MacBookPro18,3": (14, "MacBook Pro (14-inch, 2021)"),
        "MacBookPro18,4": (14, "MacBook Pro (14-inch, 2021)"),
        "Mac14,5": (14, "MacBook Pro (14-inch, 2023)"),
        "Mac14,9": (14, "MacBook Pro (14-inch, 2023)"),
        "Mac15,3": (14, "MacBook Pro (14-inch, M3, Late 2023)"),
        "Mac15,6": (14, "MacBook Pro (14-inch, M3 Pro, Late 2023)"),
        "Mac15,10": (14, "MacBook Pro (14-inch, M3 Max, Late 2023)"),
        "Mac15,8": (14, "MacBook Pro (14-inch, M3 Max, Late 2023)"),
        "Mac16,1": (14, "MacBook Pro (14-inch, Nov 2024)"), // M4
        "Mac16,6": (14, "MacBook Pro (14-inch, Nov 2024)"), // M4 Pro/Max
        "Mac16,8": (14, "MacBook Pro (14-inch, Nov 2024)"), // M4 Pro/Max
        
        // 15-inch
        "MacBookPro4,1": (15, "MacBook Pro (15/17-inch, 2008)"),
        "MacBookPro6,2": (15, "MacBook Pro (15-inch, Mid 2010)"),
        "MacBookPro8,2": (15, "MacBook Pro (15-inch, Early 2011)"),
        "MacBookPro9,1": (15, "MacBook Pro (15-inch, Mid 2012)"),
        "MacBookPro10,1": (15, "MacBook Pro (Retina, 15-inch, Mid 2012)"),
        "MacBookPro11,2": (15, "MacBook Pro (Retina, 15-inch, Late 2013)"),
        "MacBookPro11,3": (15, "MacBook Pro (Retina, 15-inch, Mid 2014)"),
        "MacBookPro11,4": (15, "MacBook Pro (Retina, 15-inch, Mid 2015)"),
        "MacBookPro11,5": (15, "MacBook Pro (Retina, 15-inch, Mid 2015)"),
        "MacBookPro13,3": (15, "MacBook Pro (Retina, 15-inch, Late 2016)"),
        "MacBookPro14,3": (15, "MacBook Pro (Retina, 15-inch, Late 2017)"),
        "MacBookPro15,1": (15, "MacBook Pro (Retina, 15-inch, 2018/2019)"),
        "MacBookPro15,3": (15, "MacBook Pro (Retina, 15-inch, 2018/2019)"),
        
        // 16-inch
        "MacBookPro16,1": (16, "MacBook Pro (Retina, 16-inch, Mid 2019)"),
        "MacBookPro16,4": (16, "MacBook Pro (Retina, 16-inch, Mid 2019)"),
        "MacBookPro18,1": (16, "MacBook Pro (16-inch, 2021)"),
        "MacBookPro18,2": (16, "MacBook Pro (16-inch, 2021)"),
        "Mac14,6": (16, "MacBook Pro (16-inch, 2023)"),
        "Mac14,10": (16, "MacBook Pro (16-inch, 2023)"),
        "Mac15,7": (16, "MacBook Pro (16-inch, M3 Pro, Late 2023)"),
        "Mac15,9": (16, "MacBook Pro (16-inch, M3 Max, Late 2023)"),
        "Mac15,11": (16, "MacBook Pro (16-inch, M3 Max, Late 2023)"),
        "Mac16,5": (16, "MacBook Pro (16-inch, Nov 2024)"),
        "Mac16,7": (16, "MacBook Pro (16-inch, Nov 2024)"),
        
        // 17-inch
        "MacBookPro8,3": (17, "MacBook Pro (17-inch, Late 2011)"),
        
        // In the rare case that the Mac model is not found
        "Unknown": (0, "Mac (UNKNOWN)"),
        "Mac": (0, "Mac"),
    ]
}

enum MacType {
    case desktop
    case laptop
}

extension String {
    var nilIfEmpty: String? {
        self.isEmpty ? nil : self
    }
}
