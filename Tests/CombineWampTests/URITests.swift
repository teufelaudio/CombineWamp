import CombineWamp
import XCTest

// https://wamp-proto.org/_static/gen/wamp_latest.html#uris
// Not wildcard
final class URINotWildcardTests: XCTestCase {
    func testValidString1Component() {
        let sut = URI(rawValue: "myprocedure1")
        XCTAssertEqual(sut?.rawValue, "myprocedure1")
        XCTAssertEqual(sut?.isWildcard, false)
    }

    func testValidString2Components() {
        let sut = URI(rawValue: "myapp.myprocedure1")
        XCTAssertEqual(sut?.rawValue, "myapp.myprocedure1")
        XCTAssertEqual(sut?.isWildcard, false)
    }

    func testValidString3Components() {
        let sut = URI(rawValue: "com.myapp.myprocedure1")
        XCTAssertEqual(sut?.rawValue, "com.myapp.myprocedure1")
        XCTAssertEqual(sut?.isWildcard, false)
    }

    func testValidString3ComponentsWithUnderscore() {
        let sut = URI(rawValue: "com.myapp.my__procedure1")
        XCTAssertEqual(sut?.rawValue, "com.myapp.my__procedure1")
        XCTAssertEqual(sut?.isWildcard, false)
    }

    func testInvalidStringFirstEmpty() {
        let sut = URI(rawValue: ".myapp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringMiddleEmpty() {
        let sut = URI(rawValue: "com..myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringLastEmpty() {
        let sut = URI(rawValue: "com.myapp.")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringFirstHashtag() {
        let sut = URI(rawValue: "c#m.myapp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringMiddleHashtag() {
        let sut = URI(rawValue: "com.my#app.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringLastHashtag() {
        let sut = URI(rawValue: "com.myapp.myprocedure#1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringFirstSpace() {
        let sut = URI(rawValue: "c m.myapp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringMiddleSpace() {
        let sut = URI(rawValue: "com.my app.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringLastSpace() {
        let sut = URI(rawValue: "com.myapp.myprocedure 1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringNotTrimmedStart() {
        let sut = URI(rawValue: " com.myapp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringNotTrimmedEnd() {
        let sut = URI(rawValue: "com.myapp.myprocedure1 ")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringFirstUppercase() {
        let sut = URI(rawValue: "Com.myapp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringMiddleUppercase() {
        let sut = URI(rawValue: "com.myApp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringLastUppercase() {
        let sut = URI(rawValue: "com.myapp.myProcedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringFirstDash() {
        let sut = URI(rawValue: "c-om.myapp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringMiddleDash() {
        let sut = URI(rawValue: "com.my-app.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringLastDash() {
        let sut = URI(rawValue: "com.myapp.my-procedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringStartsWithWamp() {
        XCTAssertNil(URI(rawValue: "wamp.error.not_authorized"))
        XCTAssertNil(URI(rawValue: "wamp.error.procedure_already_exists"))
    }
}

// Wildcard
final class URIWildcardTests: XCTestCase {
    func testValidString1Component() {
        let sut = URI(wildcard: "myprocedure1")
        XCTAssertEqual(sut?.rawValue, "myprocedure1")
        XCTAssertEqual(sut?.isWildcard, false)
    }

    func testValidString2Components() {
        let sut = URI(wildcard: "myapp.myprocedure1")
        XCTAssertEqual(sut?.rawValue, "myapp.myprocedure1")
        XCTAssertEqual(sut?.isWildcard, false)
    }

    func testValidString3Components() {
        let sut = URI(wildcard: "com.myapp.myprocedure1")
        XCTAssertEqual(sut?.rawValue, "com.myapp.myprocedure1")
        XCTAssertEqual(sut?.isWildcard, false)
    }

    func testValidString3ComponentsWithUnderscore() {
        let sut = URI(wildcard: "com.myapp.my__procedure1")
        XCTAssertEqual(sut?.rawValue, "com.myapp.my__procedure1")
        XCTAssertEqual(sut?.isWildcard, false)
    }

    func testInvalidStringFirstEmpty() {
        let sut = URI(wildcard: ".myapp.myprocedure1")
        XCTAssertEqual(sut?.rawValue, ".myapp.myprocedure1")
        XCTAssertEqual(sut?.isWildcard, true)
    }

    func testInvalidStringMiddleEmpty() {
        let sut = URI(wildcard: "com..myprocedure1")
        XCTAssertEqual(sut?.rawValue, "com..myprocedure1")
        XCTAssertEqual(sut?.isWildcard, true)
    }

    func testInvalidStringLastEmpty() {
        let sut = URI(wildcard: "com.myapp.")
        XCTAssertEqual(sut?.rawValue, "com.myapp.")
        XCTAssertEqual(sut?.isWildcard, true)
    }

    func testInvalidStringFirstHashtag() {
        let sut = URI(wildcard: "c#m.myapp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringMiddleHashtag() {
        let sut = URI(wildcard: "com.my#app.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringLastHashtag() {
        let sut = URI(wildcard: "com.myapp.myprocedure#1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringFirstSpace() {
        let sut = URI(wildcard: "c m.myapp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringMiddleSpace() {
        let sut = URI(wildcard: "com.my app.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringLastSpace() {
        let sut = URI(wildcard: "com.myapp.myprocedure 1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringNotTrimmedStart() {
        let sut = URI(wildcard: " com.myapp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringNotTrimmedEnd() {
        let sut = URI(wildcard: "com.myapp.myprocedure1 ")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringFirstUppercase() {
        let sut = URI(wildcard: "Com.myapp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringMiddleUppercase() {
        let sut = URI(wildcard: "com.myApp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringLastUppercase() {
        let sut = URI(wildcard: "com.myapp.myProcedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringFirstDash() {
        let sut = URI(wildcard: "c-om.myapp.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringMiddleDash() {
        let sut = URI(wildcard: "com.my-app.myprocedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringLastDash() {
        let sut = URI(wildcard: "com.myapp.my-procedure1")
        XCTAssertNil(sut?.rawValue)
    }

    func testInvalidStringStartsWithWamp() {
        XCTAssertNil(URI(wildcard: "wamp.error.not_authorized"))
        XCTAssertNil(URI(wildcard: "wamp.error.procedure_already_exists"))
    }
}
