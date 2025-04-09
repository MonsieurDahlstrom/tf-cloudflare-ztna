# [2.0.0-beta.1](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/compare/v1.1.2...v2.0.0-beta.1) (2025-04-09)


### Features

* Access user groups removed ([458998e](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/458998e96337b2822e0e3fa8b47dabff2fbd7d1c))


### BREAKING CHANGES

* Access configuration has been removed and team variable drives the gateway rules directly to give access to virtual networks

## [1.1.2](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/compare/v1.1.1...v1.1.2) (2025-04-07)


### Bug Fixes

* added warning that github identities are not implemeted yet ([7bcc22c](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/7bcc22c31003396b1e9a3a954e6b05ea7c521669))

## [1.1.2-beta.1](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/compare/v1.1.1...v1.1.2-beta.1) (2025-04-07)


### Bug Fixes

* added warning that github identities are not implemeted yet ([7bcc22c](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/7bcc22c31003396b1e9a3a954e6b05ea7c521669))

<<<<<<< HEAD
## [1.1.1-beta.2](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/compare/v1.1.1-beta.1...v1.1.1-beta.2) (2025-04-07)
=======
## [1.1.1](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/compare/v1.1.0...v1.1.1) (2025-04-02)
>>>>>>> main


### Bug Fixes

<<<<<<< HEAD
* added warning that github identities are not implemeted yet ([7bcc22c](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/7bcc22c31003396b1e9a3a954e6b05ea7c521669))
=======
* email_addresses, email_domains cant be set indepdently on a teams ([8a1a645](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/8a1a645005cfc8d914ce8e4e184772571ed3bfa9))
>>>>>>> main

## [1.1.1-beta.1](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/compare/v1.1.0...v1.1.1-beta.1) (2025-04-02)


### Bug Fixes

* email_addresses, email_domains cant be set indepdently on a teams ([8a1a645](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/8a1a645005cfc8d914ce8e4e184772571ed3bfa9))

# [1.1.0](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/compare/v1.0.1...v1.1.0) (2025-04-02)


### Bug Fixes

* fixed tunnel secret lookup ([0df48ac](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/0df48ac4401886cd56b5a98a08b01bf33a57dd28))


### Features

* added email_domains to teams resorurces ([23dd04f](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/23dd04f2a42bd56ebe628d14ff6b3eb3b28ab83d))

# [1.1.0-beta.1](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/compare/v1.0.2-beta.1...v1.1.0-beta.1) (2025-04-02)


### Features

* added email_domains to teams resorurces ([23dd04f](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/23dd04f2a42bd56ebe628d14ff6b3eb3b28ab83d))

## [1.0.2-beta.1](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/compare/v1.0.1...v1.0.2-beta.1) (2025-04-02)


### Bug Fixes

* fixed tunnel secret lookup ([0df48ac](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/0df48ac4401886cd56b5a98a08b01bf33a57dd28))

## [1.0.1](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/compare/v1.0.0...v1.0.1) (2025-04-02)


### Bug Fixes

* base64sha256 encode tunnel secret in resource and output ([99a5353](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/99a53539cc6cb2d465c2ac2ba586287043a65a4f))

## [1.0.1-beta.1](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/compare/v1.0.0...v1.0.1-beta.1) (2025-04-02)


### Bug Fixes

* base64sha256 encode tunnel secret in resource and output ([99a5353](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/99a53539cc6cb2d465c2ac2ba586287043a65a4f))

# 1.0.0 (2025-04-01)
### Bug Fixes
* stored the wrong keys as metadata about the tunnels in the output ([ee720c0](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/ee720c0e223225c58c111e73330a6429c112c769))

# 1.0.0-beta.1 (2025-04-01)
### Bug Fixes
* stored the wrong keys as metadata about the tunnels in the output ([ee720c0](https://github.com/MonsieurDahlstrom/tf-cloudflare-ztna/commit/ee720c0e223225c58c111e73330a6429c112c769))
