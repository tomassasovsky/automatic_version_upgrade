# Automatic Version Upgrader

[![ci][ci_badge]][ci_link]
[![coverage][coverage_badge]][ci_link]
[![pub package][pub_badge]][pub_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

---

A command line interface to upgrade your app version automatically in a CI/CD flow.

## Installing

```sh
dart pub global activate automatic_version_upgrader
```

## Commands

### `automatic_version_upgrader google-play-version`

Check the latest version of your app on Google Play (includes internal testing) and upgrade the local version in your pubspec.yaml if necessary.


Note: see [here](https://developers.google.com/workspace/guides/create-credentials#service-account) for more information on how to get your Google Service Account credentials.

```sh
Gets the latest version of the app from the Google Play Store.

Usage: automatic_version_upgrader google-play-version
-h, --help                                       Print this usage information.
-p, --package-name (mandatory)                   The package name of the app.
    --credentials                                The credentials for the Google Cloud Service Account.
    --next=<major|minor|patch|breaking|build>    Updates the version number.

          [breaking]                             Gets the next breaking version number that follows this one. Increments [major] if it is greater than zero, otherwise [minor], resets subsequent digits to zero, and strips any [preRelease] or [build] suffix.
          [build] (default)                      Gets the next build number that follows this one. If this version is a pre-release, then it just strips the pre-release suffix. Otherwise, it increments the build. Note: If the latest version is actually bigger than the latest build, then the build number is reset to zero and the version grabbed will be the next patch to the latest version.
          [major]                                Gets the next major version number that follows this one. If this version is a pre-release of a major version release (i.e. the minor and patch versions are zero), then it just strips the pre-release suffix. Otherwise, it increments the major version and resets the minor and patch.
          [minor]                                Gets the next minor version number that follows this one. If this version is a pre-release of a minor version release (i.e. the patch version is zero), then it just strips the pre-release suffix. Otherwise, it increments the minor version and resets the patch.
          [patch]                                Gets the next patch version number that follows this one. If this version is a pre-release, then it just strips the pre-release suffix. Otherwise, it increments the patch version.

-u, --upgrade-mode=<always|never|outdated>       Updates the version in your app's pubspec.yaml file.

          [always]                               Updates the app's version to the newest and ups the patch number.
          [never] (default)                      Doesn't update the version.
          [outdated]                             Updates the app's version if there's a newer one available. Otherwise, does nothing.
```

#### Usage

```sh
# Gets the latest version of the app from the Google Play Store.
automatic_version_upgrader google-play-version --package-name=com.maps.google  --credentials=[the contents of your credentials.json file] 

# Updates the app's version to the newest and ups the patch number.
automatic_version_upgrader google-play-version --package-name=com.maps.google  --credentials=[the contents of your credentials.json file] --upgrade-mode=outdated

# Updates the app's version to the newest and ups the major number.
automatic_version_upgrader google-play-version --package-name=com.maps.google  --credentials=[the contents of your credentials.json file] --upgrade-mode=outdated --next=major
```


### `automatic_version_upgrader app-store-version`

Check the latest version of your app on App Store Connnect (includes TestFlight) and upgrade the local version in your pubspec.yaml if necessary.

Note: see [here](https://developer.apple.com/documentation/appstoreconnectapi) for more information on how to get your credentials for the App Store Connect API.

```sh
Gets the latest version of the app from the App Store.

Usage: automatic_version_upgrader app-store-version [arguments]
-h, --help                                       Print this usage information.
    --app-id (mandatory)                         The identifier of the app.
    --private-key                                The private key from the App Store Connect account.
    --key-id                                     The key id from the App Store Connect account.
    --issuer-id                                  The private key's issuer id from the App Store Connect account.
    --next=<major|minor|patch|breaking|build>    Updates the version number.

          [breaking]                             Gets the next breaking version number that follows this one. Increments [major] if it's greater than zero, otherwise [minor], resets subsequent digits to zero, and strips any [preRelease] or [build] suffix.
          [build] (default)                      Gets the next build number that follows this one. If this version is a pre-release, then it just strips the pre-release suffix. Otherwise, it increments the build. Note: If the latest version is actually bigger than the latest build, then the build number is reset to zero and the version grabbed will be the next patch to the latest version.
          [major]                                Gets the next major version number that follows this one. If this version is a pre-release of a major version release (i.e. the minor and patch versions are zero), then it just strips the pre-release suffix. Otherwise, it increments the major version and resets the minor and patch.
          [minor]                                Gets the next minor version number that follows this one. If this version is a pre-release of a minor version release (i.e. the patch version is zero), then it just strips the pre-release suffix. Otherwise, it increments the minor version and resets the patch.
          [patch]                                Gets the next patch version number that follows this one. If this version is a pre-release, then it just strips the pre-release suffix. Otherwise, it increments the patch version.

-u, --upgrade-mode=<always|never|outdated>       Updates the version in your app's pubspec.yaml file.

          [always]                               Updates the app's version to the oldest plus a patch.
          [never] (default)                      Doesn't update the version.
          [outdated]                             Updates the app's version if there's a newer one available. Otherwise, does nothing.

Run "automatic_version_upgrader help" to see global options.
```

#### Usage

```sh
# Gets the latest version of the app from App Store Connect.
automatic_version_upgrader app-store-version --app-id=[your app id] --private-key=[your private key] key-id=[your key id] --issuer-id=[your issuer id] 

# Updates the app's version to the newest and ups the patch number.
automatic_version_upgrader google-play-version --app-id=[your app id] --private-key=[your private key] key-id=[your key id] --issuer-id=[your issuer id] --upgrade-mode=outdated

# Updates the app's version to the newest and ups the major number.
automatic_version_upgrader google-play-version --app-id=[your app id] --private-key=[your private key] key-id=[your key id] --issuer-id=[your issuer id] --upgrade-mode=outdated --next=major
```

### `automatic_version_upgrader --help`

See the complete list of commands and usage information.

```sh
A command line interface to upgrade your app version automatically in a CI/CD flow.

Usage: automatic_version_upgrader <command> [arguments]

Global options:
-h, --help            Print this usage information.
    --version         Print the current version.
    --analytics       Toggle anonymous usage statistics.

          [false]     Disable anonymous usage statistics
          [true]      Enable anonymous usage statistics

    --[no-]verbose    Noisy logging, including all shell commands executed.

Available commands:
  app-store-version     Gets the latest version of the app from the App Store.
  google-play-version   automatic_version_upgrader google-play-version
                        Gets the latest version of the app from the Google Play Store.
  update                Update Automatic Version Upgrader CLI.

Run "automatic_version_upgrader help <command>" for more information about a command.
```

[ci_badge]: https://github.com/tomassasovsky/automatic_version_upgrader.dart/workflows/automatic_version_upgrader/badge.svg
[ci_link]: https://github.com/tomassasovsky/automatic_version_upgrader.dart/actions
[coverage_badge]: https://raw.githubusercontent.com/tomassasovsky/automatic_version_upgrader.dart/master/coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[pub_badge]: https://img.shields.io/pub/v/automatic_version_upgrader.svg
[pub_link]: https://pub.dartlang.org/packages/automatic_version_upgrader
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
