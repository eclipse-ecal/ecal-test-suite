# eCAL integration Tests

This repository contains automated integration tests for [eCAL](https://github.com/eclipse-ecal/ecall). It is designed to run and validate communication scenarios between multiple processes using eCAL middleware.

- View status and logs of last tests:

    https://github.com/EmirTutar/ECAL_Test_Framework/actions

- Test report (available after completion of the tests):
    
    https://emirtutar.github.io/ECAL_Test_Framework/

## Table of Contents

1. [Introduction](#ecal-integration-tests)
   - [Project Overview](#ecal-integration-tests)
   - [Test Status and Report Links](#ecal-integration-tests)

2. [Purpose](#purpose)
   - [Goals of the Project](#purpose)

3. [Features](#features)
   - [Supported Transport Layers](#features)
   - [Covered Scenarios](#features)
   - [Reporting and Integration](#features)

4. [Test Scenarios](#test-scenarios)
   - [Overview of Test Cases](#test-scenarios)
   - [Individual Test Descriptions with README Links](#test-scenarios)

5. [Test Reports](#test-reports)
   - [GitHub Pages Output](#test-reports)
   - [Report Artifacts](#test-reports)

6. [Triggering Tests](#triggering-tests)
   - [Manual Triggers](#triggering-tests)
   - [Automatic Dispatch from eCAL Repository](#triggering-tests)

7. [Note for Forks](#note-for-forks)
   - [Creating a Personal Access Token (PAT)](#1-create-a-personal-access-token-pat)
   - [Adding the Token to a Forked Repository](#2-add-the-token-to-your-forked-ecal-repository)

8. [Feedback to eCAL Repo](#feedback-to-ecal-repo)

9. [Requirements](#requirements)

10. [Structure](#structure)

11. [Local Development with VS Code](#local-development-with-vs-code)
    - [Using Dev Containers to Avoid Header Errors](#local-development-with-vs-code)
    - [Setup Instructions](#local-development-with-vs-code)

12. [Creating New Tests](#creating-new-tests)

## Purpose

The main goal of this project is to provide:

* Automated test runs on push, pull request, or schedule
* Reliable feedback on message communication and process stability
* Visual test reports for easy inspection

## Features

* Supports multiple eCAL transport layers (SHM, UDP, TCP)
* Covers common scenarios such as:

  * Publisher to Subscriber communication
  * Multi-publisher and multi-subscriber setups
  * Fault injection (e.g., crashing subscribers or publishers)
  * Network failure simulations
* Test results are published to GitHub Pages
* Integration in eCAL repositori via `repository_dispatch`

## Test Scenarios

Each test case is implemented using [Robot Framework](https://robotframework.org/), with Docker-based isolation.

| Test Case           | Description                                                  | README                                                            |
|---------------------|--------------------------------------------------------------|-------------------------------------------------------------------|
| basic_pub_sub       | Simple 1:1 publisher-subscriber communication                | [README](integration_tests/basic_pub_sub/README.md)              |
| multi_pub_sub       | Multiple publishers and subscribers (N:N)                    | [README](integration_tests/multi_pub_sub/README.md)              |
| network_crash       | Local UDP works after network disconnect                     | [README](integration_tests/network_crash/README.md)              |
| pub_crash           | One publisher crashes mid-test                               | [README](integration_tests/pub_crash/README.md)                  |
| sub_crash           | Subscriber crashes during message receive                    | [README](integration_tests/sub_crash/README.md)                  |
| sub_send_crash      | Subscriber crashes during send/zero-copy test                | [README](integration_tests/sub_send_crash/README.md)             |
| rpc_ping_test       | Simple RPC test with one client calling one server           | [README](integration_tests/rpc_ping_test/README.md)              |
| rpc_reconnect_test  | RPC client disconnects and reconnects during the test        | [README](integration_tests/rpc_reconnect_test/README.md)         |
| rpc_n_to_n_test     | Multiple RPC clients call multiple RPC servers (N:N)         | [README](integration_tests/rpc_n_to_n_test/README.md)            |

## Test Reports

Test results are automatically deployed to:
👉 [https://emirtutar.github.io/ECAL\_Test\_Framework](https://emirtutar.github.io/ECAL_Test_Framework)

Each run is timestamped and archived, with access to:

* `log.html`
* `report.html`
* `output.xml`

## Triggering Tests

Tests can be triggered in three ways:

1. Manually via GitHub Actions
2. Automatically from the eCAL repository using `repository_dispatch` (Create a PR or Push to Master)

## Note for Forks

If you are working on a fork of the official eCAL repository (e.g., UserName/ecal) and you create a pull request or push from develop to master within your fork, you need to allow GitHub Actions to trigger the integration tests in this repository.

To do so, follow these steps:

### 1. Create a Personal Access Token (PAT):
1. Go to your GitHub Developer Settings → Personal Access Tokens.
2. Click on “Generate new token (classic)”.
3. Set a name like ECAL Test Trigger Token.
4. Set an expiration (e.g., 90 days or custom).
5. Under Scopes, enable:
 - repo (for private forks)
 
    or

 - public_repo (for public forks only)

6. Click Generate token and copy it immediately. You won't see it again.

### 2. Add the Token to Your Forked eCAL Repository:
1. Go to your forked repository on GitHub (e.g., UserName/ecal).
2. Navigate to: Settings → Secrets and variables → Actions → New repository secret.
3. Name the secret exactly:

```bash
TEST_FRAMEWORK_TOKEN
```
4. Paste the copied token as the value.
5. Click Add secret.
6. Once added, GitHub Actions in your fork can use this token to trigger the test framework via repository_dispatch.

⚠️ This is only needed for forks. If you push or create PRs directly in eclipse-ecal/ecal, no token is required.

## Feedback to eCAL Repo

After the test run finishes, the result (pass/fail) is reported back to the Pull Request in the eCAL repository as a commit status.

## Requirements

* eCAL (If you build without Docker)
* Docker
* Python 3
* Robot Framework

## Structure

```
.
├── integration_tests/                       # Main directory for all test cases and supporting infrastructure
│   ├── basic_pub_sub/                       # Test case: simple 1:1 publisher-subscriber communication
│   ├── multi_pub_sub/                       # Test case: multiple publishers and subscribers (N:N)
│   ├── network_crash/                       # Test case: test resilience after network disconnect
│   ├── pub_crash/                           # Test case: publisher crashes mid-transmission
│   ├── sub_crash/                           # Test case: subscriber crashes during reception
│   ├── sub_send_crash/                      # Test case: subscriber crashes during send (zero-copy stress)
│   ├── rpc_ping_test/                       # Test case: basic RPC ping between client and server
│   ├── rpc_reconnect_test/                  # Test case: RPC reconnects after temporary disconnect
│   ├── lib/                                 # Shared helper libraries used by multiple test cases
│   │   ├── EcalConfigHelper/                # C++ helper to configure eCAL transport modes
│   │   ├── DockerLibrary.py                 # Robot Framework library to manage Docker containers
│   │   └── GlobalPathsLibrary.py            # Library to manage paths, container names, and image tags
│   └── docker/                              # Base Dockerfile used to build test environments
│       └── Dockerfile.ecal_base             # Base image with all dependencies (eCAL, build tools)
│
├──  create_new_test/                        # Generator to create new test case folder structure
│       ├── create_new_test.py               # Python script to auto-generate new test case folders
│       └── templates/                       # Jinja2 templates used by the generator
│
├── .devcontainer/                           # Devcontainer setup for local development in VS Code
│   ├── devcontainer.json                    # Container definition for VS Code Remote Containers
│   └── README.md                            # Instructions for using the dev container setup
│
├── .github/                                 # GitHub Actions CI configuration
│   └── workflows/
│       └── run-tests.yml                    # Main workflow file to build, test, and publish reports
└── README.md                                # Main documentation file of the repository
```

## Local Development with VS Code

If you want to develop and run the tests locally in VS Code **without getting header errors (e.g. eCAL or TCLAP not found)**, we recommend using the included `.devcontainer` setup.

### Steps:

1. Make sure Docker and VS Code are installed.
2. Install the **Dev Containers extension** in VS Code.
3. Open this repository in VS Code.
4. When prompted, click **"Reopen in Container"**.
5. VS Code will build and open a full-featured development environment inside Docker.

This container is based on the same Docker image used for testing, so **all dependencies like eCAL and TCLAP are pre-installed**. You can develop and run Robot Framework tests directly without needing to configure anything on your host system.

For more details, see: [.devcontainer/README.md](.devcontainer/README.md)

## Creating New Tests

To create a new test case folder automatically, use the generator in `create_new_test/`.

See: [create_new_test/README.md](create_new_test/README.md)
