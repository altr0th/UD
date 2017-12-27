# UrbanDictionary

## Data Model

The app uses CoreData to persist search results to disk, enabling limited offline capabilities. When performing a search, the resulting JSON response is parsed into `SearchResult` (`NSManagedObject` subclass) objects, written to a background `NSManagedObjectContext` with a `privateQueueConcurrencyType`.

The app also uses an `NSFetchedResultsController` to monitor changes to the main queue's `NSManagedObjectContext` and updates the UI. Even though a fetched results controller is probably overkill for this project (espcially since the fetch request changes with each query), I wanted to show an example of how a production app would be architected.

## UI Architecture

The rest of the app uses an MVVM architecture: `SearchViewController` and `SearchResultCell` make up the View, responsible for displaying search results and responding to both changes to the View Model, and input from the user. `SearchViewModel` and `SearchResultViewModel` make up the UI-independent View Model, responsible for responding to changes to the model (using the `NSFetchedResultsController`) and telling the view to update, and performing the search when the user types into the text field. The View Model does the bulk of the work: sending the search api request, parsing the results into CoreData in a background queue, then responding to changes to the main queue context and telling the View to update. The Model in this case is just the `SearchResult` CoreData entity.

## Unit Tests

I wrote a couple small unit tests for `SearchViewModel`, which is the best candidate for unit tests. Since its written to be UI independent, its much more easily testable. Its also designed using dependency injection, which lets us use mock objects for those dependencies. Other beneficial test cases would be around the `NSFetchedResultsController`, making sure that when objects are written to the background context, `controllerDidChangeContent` is triggered on the main queue.