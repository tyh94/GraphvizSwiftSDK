//
//  GVColor.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 05.05.2025.
//

import Foundation

public indirect enum GVColor: Hashable {
    public typealias RawValue = String
    
    public enum Name: String, Hashable {
        case aliceblue, antiquewhite, antiquewhite1, antiquewhite2, antiquewhite3, antiquewhite4, aquamarine, aquamarine1, aquamarine2, aquamarine3, aquamarine4, azure, azure1, azure2, azure3, azure4, beige, bisque, bisque1, bisque2, bisque3, bisque4, black, blanchedalmond, blue, blue1, blue2, blue3, blue4, blueviolet, brown, brown1, brown2, brown3, brown4, burlywood, burlywood1, burlywood2, burlywood3, burlywood4, cadetblue, cadetblue1, cadetblue2, cadetblue3, cadetblue4, chartreuse, chartreuse1, chartreuse2, chartreuse3, chartreuse4, chocolate, chocolate1, chocolate2, chocolate3, chocolate4, coral, coral1, coral2, coral3, coral4, cornflowerblue, cornsilk, cornsilk1, cornsilk2, cornsilk3, cornsilk4, crimson, cyan, cyan1, cyan2, cyan3, cyan4, darkgoldenrod, darkgoldenrod1, darkgoldenrod2, darkgoldenrod3, darkgoldenrod4, darkgreen, darkkhaki, darkolivegreen, darkolivegreen1, darkolivegreen2, darkolivegreen3, darkolivegreen4, darkorange, darkorange1, darkorange2, darkorange3, darkorange4, darkorchid, darkorchid1, darkorchid2, darkorchid3, darkorchid4, darksalmon, darkseagreen, darkseagreen1, darkseagreen2, darkseagreen3, darkseagreen4, darkslateblue, darkslategray, darkslategray1, darkslategray2, darkslategray3, darkslategray4, darkslategrey, darkturquoise, darkviolet, deeppink, deeppink1, deeppink2, deeppink3, deeppink4, deepskyblue, deepskyblue1, deepskyblue2, deepskyblue3, deepskyblue4, dimgray, dimgrey, dodgerblue, dodgerblue1, dodgerblue2, dodgerblue3, dodgerblue4, firebrick, firebrick1, firebrick2, firebrick3, firebrick4, floralwhite, forestgreen, gainsboro, ghostwhite, gold, gold1, gold2, gold3, gold4, goldenrod, goldenrod1, goldenrod2, goldenrod3, goldenrod4, gray, gray0, gray1, gray10, gray100, gray11, gray12, gray13, gray14, gray15, gray16, gray17, gray18, gray19, gray2, gray20, gray21, gray22, gray23, gray24, gray25, gray26, gray27, gray28, gray29, gray3, gray30, gray31, gray32, gray33, gray34, gray35, gray36, gray37, gray38, gray39, gray4, gray40, gray41, gray42, gray43, gray44, gray45, gray46, gray47, gray48, gray49, gray5, gray50, gray51, gray52, gray53, gray54, gray55, gray56, gray57, gray58, gray59, gray6, gray60, gray61, gray62, gray63, gray64, gray65, gray66, gray67, gray68, gray69, gray7, gray70, gray71, gray72, gray73, gray74, gray75, gray76, gray77, gray78, gray79, gray8, gray80, gray81, gray82, gray83, gray84, gray85, gray86, gray87, gray88, gray89, gray9, gray90, gray91, gray92, gray93, gray94, gray95, gray96, gray97, gray98, gray99, green, green1, green2, green3, green4, greenyellow, grey, grey0, grey1, grey10, grey100, grey11, grey12, grey13, grey14, grey15, grey16, grey17, grey18, grey19, grey2, grey20, grey21, grey22, grey23, grey24, grey25, grey26, grey27, grey28, grey29, grey3, grey30, grey31, grey32, grey33, grey34, grey35, grey36, grey37, grey38, grey39, grey4, grey40, grey41, grey42, grey43, grey44, grey45, grey46, grey47, grey48, grey49, grey5, grey50, grey51, grey52, grey53, grey54, grey55, grey56, grey57, grey58, grey59, grey6, grey60, grey61, grey62, grey63, grey64, grey65, grey66, grey67, grey68, grey69, grey7, grey70, grey71, grey72, grey73, grey74, grey75, grey76, grey77, grey78, grey79, grey8, grey80, grey81, grey82, grey83, grey84, grey85, grey86, grey87, grey88, grey89, grey9, grey90, grey91, grey92, grey93, grey94, grey95, grey96, grey97, grey98, grey99, honeydew, honeydew1, honeydew2, honeydew3, honeydew4, hotpink, hotpink1, hotpink2, hotpink3, hotpink4, indianred, indianred1, indianred2, indianred3, indianred4, indigo, invis, ivory, ivory1, ivory2, ivory3, ivory4, khaki, khaki1, khaki2, khaki3, khaki4, lavender, lavenderblush, lavenderblush1, lavenderblush2, lavenderblush3, lavenderblush4, lawngreen, lemonchiffon, lemonchiffon1, lemonchiffon2, lemonchiffon3, lemonchiffon4, lightblue, lightblue1, lightblue2, lightblue3, lightblue4, lightcoral, lightcyan, lightcyan1, lightcyan2, lightcyan3, lightcyan4, lightgoldenrod, lightgoldenrod1, lightgoldenrod2, lightgoldenrod3, lightgoldenrod4, lightgoldenrodyellow, lightgray, lightgrey, lightpink, lightpink1, lightpink2, lightpink3, lightpink4, lightsalmon, lightsalmon1, lightsalmon2, lightsalmon3, lightsalmon4, lightseagreen, lightskyblue, lightskyblue1, lightskyblue2, lightskyblue3, lightskyblue4, lightslateblue, lightslategray, lightslategrey, lightsteelblue, lightsteelblue1, lightsteelblue2, lightsteelblue3, lightsteelblue4, lightyellow, lightyellow1, lightyellow2, lightyellow3, lightyellow4, limegreen, linen, magenta, magenta1, magenta2, magenta3, magenta4, maroon, maroon1, maroon2, maroon3, maroon4, mediumaquamarine, mediumblue, mediumorchid, mediumorchid1, mediumorchid2, mediumorchid3, mediumorchid4, mediumpurple, mediumpurple1, mediumpurple2, mediumpurple3, mediumpurple4, mediumseagreen, mediumslateblue, mediumspringgreen, mediumturquoise, mediumvioletred, midnightblue, mintcream, mistyrose, mistyrose1, mistyrose2, mistyrose3, mistyrose4, moccasin, navajowhite, navajowhite1, navajowhite2, navajowhite3, navajowhite4, navy, navyblue, none, oldlace, olivedrab, olivedrab1, olivedrab2, olivedrab3, olivedrab4, orange, orange1, orange2, orange3, orange4, orangered, orangered1, orangered2, orangered3, orangered4, orchid, orchid1, orchid2, orchid3, orchid4, palegoldenrod, palegreen, palegreen1, palegreen2, palegreen3, palegreen4, paleturquoise, paleturquoise1, paleturquoise2, paleturquoise3, paleturquoise4, palevioletred, palevioletred1, palevioletred2, palevioletred3, palevioletred4, papayawhip, peachpuff, peachpuff1, peachpuff2, peachpuff3, peachpuff4, peru, pink, pink1, pink2, pink3, pink4, plum, plum1, plum2, plum3, plum4, powderblue, purple, purple1, purple2, purple3, purple4, red, red1, red2, red3, red4, rosybrown, rosybrown1, rosybrown2, rosybrown3, rosybrown4, royalblue, royalblue1, royalblue2, royalblue3, royalblue4, saddlebrown, salmon, salmon1, salmon2, salmon3, salmon4, sandybrown, seagreen, seagreen1, seagreen2, seagreen3, seagreen4, seashell, seashell1, seashell2, seashell3, seashell4, sienna, sienna1, sienna2, sienna3, sienna4, skyblue, skyblue1, skyblue2, skyblue3, skyblue4, slateblue, slateblue1, slateblue2, slateblue3, slateblue4, slategray, slategray1, slategray2, slategray3, slategray4, slategrey, snow, snow1, snow2, snow3, snow4, springgreen, springgreen1, springgreen2, springgreen3, springgreen4, steelblue, steelblue1, steelblue2, steelblue3, steelblue4, tan, tan1, tan2, tan3, tan4, thistle, thistle1, thistle2, thistle3, thistle4, tomato, tomato1, tomato2, tomato3, tomato4, turquoise, turquoise1, turquoise2, turquoise3, turquoise4, violet, violetred, violetred1, violetred2, violetred3, violetred4, wheat, wheat1, wheat2, wheat3, wheat4, white, whitesmoke, yellow, yellow1, yellow2, yellow3, yellow4, yellowgreen
    }

    public enum GradientStyle: String, Hashable {
        case linear
        case radial
    }

    case transparent
    case named(Name)
    case rgb(red: UInt8, green: UInt8, blue: UInt8)
    case rgba(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8)
    case hsv(hue: Double, saturation: Double, value: Double)
//    case gradient(style: GradientStyle, angle: Double, colors: KeyValuePairs<Double, GVColor>)
    case custom(String)
    
    public var toString: String {
        switch self {
        case .transparent:
            return "transparent"
        case let .named(name):
            return name.rawValue
        case let .rgb(red, green, blue):
            return String(format: "#%02x%02x%02x", red, green, blue)
        case let .rgba(red, green, blue, alpha):
            return String(format: "#%02x%02x%02x%02x", red, green, blue, alpha)
        case let .hsv(hue, saturation, value):
            return String(format: "%1.3f %1.3 %1.3", hue, saturation, value)
            //        case .gradient(style: let style, angle: let angle, colors: let colors):
            //            fatalError() // TODO
        case let .custom(string):
            return string
        }
    }
    
    public static func fromString(_ string: String) -> Self {
        if let name = Name(rawValue: string) {
            return .named(name)
        }
        if string == "transparent" {
            return .transparent
        }
        if string.hasPrefix("#") {
            let start = string.index(string.startIndex, offsetBy: 1)
            let hexColor = String(string[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    let r = UInt8((hexNumber & 0xff000000) >> 24) / 255
                    let g = UInt8((hexNumber & 0x00ff0000) >> 16) / 255
                    let b = UInt8((hexNumber & 0x0000ff00) >> 8) / 255
                    let a = UInt8(hexNumber & 0x000000ff) / 255
                    
                    return .rgba(red: r, green: g, blue: b, alpha: a)
                }
            }
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    let r = UInt8((hexNumber & 0xff000000) >> 24) / 255
                    let g = UInt8((hexNumber & 0x00ff0000) >> 16) / 255
                    let b = UInt8((hexNumber & 0x0000ff00) >> 8) / 255
                    
                    return .rgb(red: r, green: g, blue: b)
                }
            }
        }
        return .custom(string)
    }
}

extension GVColor: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .custom(value)
    }
}
