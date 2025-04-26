import ArgumentParser

@main
struct Writeit: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Static website generator by Bruno Rocha (rockbruno.com)",
        version: "1.0.0",
        subcommands: [Generate.self, New.self]
    )
}
