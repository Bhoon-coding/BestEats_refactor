import ProjectDescription

private let appName: String = "BestEats"
private let bundleId: String = "com.bhooncoding.Besteats"
private let appVersion: String = "2.0.1"
private let bundleVersion: String = "3"

// MARK: - Info.plist

private let infoPlist: [String: Plist.Value] = [
    "UILaunchScreen": [
        "UIColorName": "",
        "UIImageName": "",
    ],
    "CFBundleShortVersionString": "\(appVersion)",
    "CFBundleVersion": "\(bundleVersion)",
    "UIUserInterfaceStyle": "Light",
    "KAKAO_API_KEY": "7072eb0a506b5f651bf1ad06d6f4db81",
    "KAKAO_SERVER_HOST": "${KAKAO_SERVER_HOST}",
    "NSLocationWhenInUseUsageDescription": "근처 맛집 정보를 제공하기 위해 \n위치 권한이 필요합니다",
    "UISupportedInterfaceOrientations": [
        "Item0": "UIInterfaceOrientationPortrait"
    ],
    "UIAppFonts": [
        "Item0": "Pretendard-Black.otf",
        "Item1": "Pretendard-Bold.otf",
        "Item2": "Pretendard-ExtraBold.otf",
        "Item3": "Pretendard-ExtraLight.otf",
        "Item4": "Pretendard-Light.otf",
        "Item5": "Pretendard-Medium.otf",
        "Item6": "Pretendard-Regular.otf",
        "Item7": "Pretendard-SemiBold.otf",
        "Item8": "Pretendard-Thin.otf"
    ],
    "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)"
]

let project = Project(
    name: appName,
    targets: [
        .target(
            name: appName,
            destinations: [.iPhone],
            product: .app,
            bundleId: bundleId,
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .external(name: "Alamofire"),
                .external(name: "PopupView")
            ],
            settings: configureSettings()
            // MARK: - CoreData 아래처럼 하면 Default template 에러가 남
            /// 경로 다음과 같이 변경 Resources/CoreData/{모델명.xcdatamodeld}
            //            coreDataModels: [
            //                .coreDataModel("CoreData/RestaurantList.xcdatamodeld")
            //            ]
        ),
        .target(
            name: "BestEatsTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.bhooncoding.BesteatsTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "BestEats")]
        ),
    ],
    
    additionalFiles: ["README.md"],
    resourceSynthesizers: [
        .assets(),
        .fonts(),
    ]
)

private func configureSettings() -> Settings {
    .settings(
        base: [
            "DEVELOPMENT_TEAM": "R4G74AF442",
            "CODE_SIGN_STYLE": "Manual",
            "PROVISIONING_PROFILE_SPECIFIER": "match Development com.bhooncoding.Besteats",
            "KAKAO_SERVER_HOST": "https://dapi.kakao.com",
            "MARKETING_VERSION": "\(appVersion)",
            "CURRENT_PROJECT_VERSION": "\(bundleVersion)"
        ],
        configurations: makeConfigurations(),
        defaultSettings: .recommended
    )
}

private func makeConfigurations() -> [Configuration] {
    let debug: Configuration = .debug(name: "Debug", xcconfig: "Configs/Debug.xcconfig")
    let release: Configuration = .release(name: "Release", xcconfig: "Configs/Release.xcconfig")
    
    return [debug, release]
}


