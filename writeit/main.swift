//
//  Created by Bruno Rocha
//

import Foundation

if File.pageTemplate.exists == false {
    print("Error: writeit_template.html not found!")
    exit(1)
}

if File.stubTemplate.exists == false {
    print("Error: writeit_stub_template.html not found!")
    exit(1)
}

print("WriteIt 0.2.0")
print("1 - Create a new blog post stub")
print("2 - Generate pages from template")
print("Choose: ", terminator: "")

let result = Int(readLine() ?? "")
if result == 1 {
    StubGenerator().run()
} else if result == 2 {
    PageGenerator().run()
} else {
    print("Unknown command!")
}
