import Foundation

@main
enum MapctlMain {
  static func main() async {
    let code = await CommandRouter().run()
    exit(code)
  }
}
