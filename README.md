# Memory

Memory is a macOS app for writing quick notes and learning with flashcards. It combines the simplicity of Tot-style notes with Anki-style spaced repetition.

## What you can do

Memory lets you:

- keep 7 colour-coded notes for quick capture
- edit notes, questions and answers as Markdown text
- add flashcards with a question and an answer
- review cards when they are due
- rate each answer as Again, Hard, Good or Easy
- use the FSRS scheduler to set the next review date
- search, edit, reset and delete cards
- keep review history and scheduling data on your Mac

Notes save automatically as you type. Memory stores its data locally with SwiftData.

## Review shortcuts

Use these shortcuts during a review:

- press Space to show the answer
- press 1 for Again
- press 2 for Hard
- press 3 for Good
- press 4 for Easy

## Requirements

- macOS 14 or later
- Swift 6 or a compatible Xcode release

## Run the app

Clone the repository, move into its directory and run the app:

```sh
git clone https://github.com/voladelta/rmbr.git
cd rmbr
swift run Memory
```

You can also run the provided script:

```sh
./script/build_and_run.sh
```

## Run the tests

Run the test suite with:

```sh
swift test
```

The tests check that notes and flashcards remain available after the SwiftData container is reopened.

## Built with

- SwiftUI for the macOS interface
- SwiftData for local storage
- STTextView for the Markdown editor
- FSRS for spaced-repetition scheduling

## License

Memory is available under the [MIT License](LICENSE).
