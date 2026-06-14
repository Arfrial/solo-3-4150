# Dog Breed Diary

## Description

Dog Breed Diary is a Flutter app that fetches random dog images from a public API and allows users to save their favorite dogs locally for viewing later.

## API Used

Dog CEO API

Example Endpoint:

https://dog.ceo/api/breeds/image/random

## Storage Strategy

### SQLite

Used to store saved favorite dogs.

Each saved dog contains:

* id
* breed
* imageUrl
* savedAt

### Shared Preferences

Used to store the last viewed dog breed so it can be restored when the app is reopened.

## How to Run

1. Clone the repository.
2. Run:

```bash
flutter pub get
```

3. Run the application:

```bash
flutter run
```

## Testing Persistence

1. Fetch a dog.
2. Save it to Favorites.
3. Close the application.
4. Reopen the application.
5. Verify the saved dog is still present in Favorites.

## Edge Cases

### API Failure

If the API request fails, the app displays an error message and provides a Retry button.

### Empty Database

If no dogs have been saved, the Favorites screen displays a friendly empty-state message instead of crashing.

## AI Usage

AI tools used: ChatGPT

ChatGPT was used to help generate Flutter code, troubleshoot errors, and explain implementation details. All code was reviewed, tested, and understood before submission.
