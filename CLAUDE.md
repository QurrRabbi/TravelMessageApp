# TravelMessageApp

## Project Overview and Purpose

TravelMessageApp is a mobile application for travellers to record and share their journeys around the world. Users can:

- Log routes taken and places visited
- Drop geo-tagged messages at specific locations
- Attach photos/pictures or write simple text messages
- Send encrypted links to friends that can only be opened when the friend is physically present at the same geolocation where the message was originally tagged

## Key Architecture Decisions

- **Platform:** iOS application built with Xcode using Swift
- **Authentication:** Gmail account-based user registration and authentication
- **Backend:** Server-based architecture using AWS Lambda functions and S3 buckets for storage
- **Geolocation:** Messages are tagged with precise geolocation coordinates and access is gated by proximity validation
- **Encryption:** Links shared with friends are AES end-to-end encrypted and location-locked
- **AWS Region:** eu-west-2 (London)
- **Proximity Threshold:** Friends must be within **50 metres** of the tagged location to unlock a message

## Important Conventions and Patterns

- All code must include **Unit Tests** and **Integration Tests** to meet Apple's strict coding standards
- Use established **Design Patterns** (e.g. MVVM, Repository, Coordinator) to ensure sound architectural principles
- Ask for clarification whenever requirements are ambiguous before proceeding
- Keep separation of concerns clear between UI, business logic, and data layers

## Build/Run Instructions

- Always run the full test suite before and after making changes to ensure no tests are broken
- Use Xcode's built-in test runner (`Cmd+U`) or run tests via the command line with `xcodebuild test`
- Ensure AWS credentials and environment configuration are set up before running the backend-dependent features

## Quirks and Gotchas

- **Plan first:** Always present a plan of action and wait for approval before executing any implementation
- **Check-in code:** Always ask before committing and pushing code to the repository
- **Geolocation sensitivity:** Proximity threshold is **50 metres** — the app must validate the friend's real-time location is within this radius before decrypting and displaying the message
- **Encryption:** AES end-to-end encryption is required for all message content and shared links. Keys must never be stored server-side in plaintext
- **AWS Region:** All infrastructure must be provisioned in **eu-west-2 (London)**
