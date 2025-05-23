extension XPtr {
    enum CountType {
        case x8 // 1...63
        case x64 // 64, 128, 192, 256, 320, 384, 448, 512, 576, 640, 704, 768, 832, 896, 960
        case x64X8 // 65...127, 129...191, 193...255, 257...319, 321...383, 385...447, 449...511, 513...575, 577...639, 641...703, 705...767, 769...831, 833...895, 897...959, 961...1023
        case x1k // 1024
        case x1kX8 // 1025...1087
        case x1kX64 // 1088, 1152, 1216, 1280, 1344, 1408, 1472, 1536, 1600, 1664, 1728, 1792, 1856, 1920, 1984
        case x1kX64X8 // 1089...1151, 1153...1215, 1217...1279, 1281...1343, 1345...1407, 1409...1471, 1473...1535, 1537...1599, 1601...1663, 1665...1727, 1729...1791, 1793...1855, 1857...1919, 1921...1983, 1985...2047
        case x1kPlus // 2048, 3072, 4096, 5120, 6144, 7168, 8192, 9216, 10240, ..., 4294966272
        case x1kPlusX8 // 2049...2111, 3073...3135, ..., 4294966273...4294966335
        case x1kPlusX64 // 2112, ..., 4294966400
        case x1kPlusX64X8
        
        init(count: Int) {
            precondition(count > 0, "CountType out of bounds: \(count)")
            
            switch count {
            case 1...63:
                self = .x8
            case 64...1023:
                self = count & 63 == 0 ? .x64 : .x64X8 // count & 63 <-> count % 64
            case 1024:
                self = .x1k
            case 1025...1087:
                self = .x1kX8
            case 1088...2047:
                self = count & 63 == 0 ? .x1kX64 : .x1kX64X8
            default:
                let m1024 = count & 1023 // count & 1023 <-> count % 1024
                
                if m1024 == 0 {
                    self = .x1kPlus
                } else if m1024 <= 63 {
                    self = .x1kPlusX8
                } else if count & 63 == 0 {
                    self = .x1kPlusX64
                } else {
                    self = .x1kPlusX64X8
                }
            }
        }
    }
}
