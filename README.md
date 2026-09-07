# Swift Closure Lifecycle Demo

This command-line project models callbacks in an avatar-loading screen. It demonstrates non-escaping transformations, stored escaping callbacks, trailing-closure syntax, a strong-capture retain cycle, and the weak-capture fix.

## Requirements

- macOS 13 or later
- Swift 5.9 or later (`swift --version`)

## Run

```bash
git clone https://github.com/2252408699/swift-closure-lifecycle-demo.git
cd swift-closure-lifecycle-demo
swift run
```

The program performs eight checks and exits with an error if any expected lifecycle behavior changes.

