# Sonerim_Test_Task

 `Description`

 The app is built for iOS 18 and was launched only in iPad and iPhone Simulators
 `Fill free changing the bundle identifier`
 
 Main Entry point is SonerimTestTaskApp file where the `RootModel` is created

 Main Root Screen is handled by the `RootView` where the `RootModel` is injected


 The main dependencies are created by `RootModel` as top level object that has information of them.
 Additional `Factory` class is used by `RootModel` to separate functionality somehow.


 There are different types of URL requests: for obtaining the Posts lists for each "Category" from the App Bundle, 
 and for obtaining Images for Main(`MainView`) screen and for the Details(`FlickPostDetailsView`) screen.

The only object used for requesting data is `URLSessionRequestService`, which handles those types of Requests by returning werher a Raw response Data or the asked SuccessType object.

The URL Requests are build using separate cless `MainViewDataRequestBuiilder`

There was an attempt to devide networking logic and responsibilities into several classes as well as View models make more agnostic of underlying data providers.

 - App Workflow:

    - The app launches with `RootView` screen displaying `MainView` containing scrollable view that has caterogy names as title for each scrollable row
      Loading starts immediatelyy since there is no data yet.
    - On obtaining results for each individual category - reloading of accorting scrollable row happens and another bucnch of requests is spawned - to get the images for each post in category.
    - Images also load asyncronously and update the Post view cells accordingly on loading finish
  
    - on tap of a Post item the `FlickPostDetailsView` is displayed from the Root View


      - the Post Details screen (`FlickPostDetailsView`) contains additional action represented by revealing and hiding the player view. This details screen also has different UI for smaller iPhones in Landscape mode: it will only display fullsize image without scroling and displaying details text.
   
 - UI
There are separate file for rounded buttons button style, also separate files/structs for small pieces of the screen to divide the complexity.
  




