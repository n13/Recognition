//
//  RecognitionUITests.swift
//  RecognitionUITests
//
//  Created by Nikolaus Heger on 11/16/15.
//  Copyright © 2015 Nikolaus Heger. All rights reserved.
//

import XCTest

@available(iOS 9.0, *)
class RecognitionUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUX() {
        XCUIDevice.shared().orientation = .faceUp
        XCUIDevice.shared().orientation = .portrait
        
        
        let app = XCUIApplication()
        
        // HOME SCREEN
        snapshot("01Home")
        
        app.staticTexts["Edit settings."].tap()
        
        // SETTINGS SCREEN
        snapshot("02Settings")

        let scroller = app.scrollViews.element(boundBy: 0)
        scroller.tapAtPosition(CGPoint(x: 100, y: 201))
        
        //app.pickerWheels["12, 12 of 50"].tap()
        
        // Set number of reminders
        snapshot("03EditSettings")

        
        // app.toolbars.buttons["Done"].tap()
        
        //app.staticTexts["done"].tap()
        
        
    }
    
    // helper
    

    func waitFor(_ element:XCUIElement, seconds waitSeconds:Double) {
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: waitSeconds, handler: nil)
    }

    
}
extension XCUIElement /*TapAtPosition*/ {
    func tapAtPosition(_ position: CGPoint) {
        let cooridnate = self.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: position.x, dy: position.y))
        cooridnate.tap()
    }
}

