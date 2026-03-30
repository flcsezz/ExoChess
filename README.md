# Chessigma Mobile

Chessigma Mobile is a Flutter chess app focused on local play, puzzles, learning, and analysis.
The next product push is analysis-board intelligence: move-quality labels, piece badges, and preloaded Stockfish review with explicit loading states.

## Roadmap

- Canonical plan: [docs/PLAN.md](./docs/PLAN.md)
- Feature backlog: [docs/New_features.md](./docs/New_features.md)
- Active task: [CURRENT_TASK.md](./CURRENT_TASK.md)

## How to contribute

Contributions to this project are welcome!

If you want to contribute, please read the [contributing guide](./CONTRIBUTING.md).

## Setup

tl;dr: Install Flutter, clone the repo, run in order:
- `flutter pub get`
- `dart run build_runner watch`
- `flutter analyze --watch`,

and you're ready to code!

See [the dev environment docs](./docs/setting_dev_env.md) for detailed instructions.

## Running the app

To run the app, you can use the following command:

```bash
# if not already done, run the code generation
dart run build_runner build

# run the app on all available devices
flutter run -d all
```

## Running tests

To run the tests, you can use the following command:

```bash
# if not already done, run the code generation
dart run build_runner build

flutter test
```

## Internationalisation

Do not edit the `app_en.arb` file by hand, this file is generated.
For more information, see [Internationalisation](./docs/internationalisation.md).
