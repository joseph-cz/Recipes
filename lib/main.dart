import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}


class Recipe {
  //final String recipes;
  final List recipes;


  Recipe(this.recipes);

  Recipe.fromJson(Map<String,dynamic> json)
    : recipes = json['recipes'] as List;

      

  Map<String,dynamic> toJson()=> {
    'recipes': recipes,
  };

}

bool flag = true;
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecipeState(),
      child: MaterialApp(
      title: "Lab Seven",
      home: StartPage(), 
      theme: flag?ThemeData.dark():ThemeData.light(),
    ) 
    );
  }
}

class RecipeState extends ChangeNotifier {
  var RecipeList = [];
  var favouriteStatus = [];

  void getList(favouriteItem){
    RecipeList.add(favouriteItem);
    notifyListeners();
  }

  void favourite(Item){
    favouriteStatus.add(Item);
    notifyListeners();
  }
}

class MainPage extends StatefulWidget{

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {


  var recipes;
  var size;
  var imageURL;
  var selectedFlag = null;
  var recipeFavouriteList = [];
  var testRecipe;
  
  Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

  Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/counter.txt');
}

Future<File> writeCounter(int counter) async {
  final file = await _localFile;

  // Write the file
  return file.writeAsString('$counter');
}

  Future<File> addToRecipe(String json) async{
    final Directory directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    final file = File('${directory.path}/recipe_list.json');
    return file.writeAsString('json');
  }
  
  Future<void> readJson() async{
    final String getRecipes = await rootBundle.loadString('recipes/recipe_list.json');
    //final recipeItems = await json.decode(getRecipes);
    final recipeMap = jsonDecode(getRecipes);
    testRecipe = Recipe.fromJson(recipeMap);
    setState(() {
      print('New Map! ${testRecipe.recipes[1]}');
      print(testRecipe.recipes.length);
      //recipes = recipeItems["recipes"];
      recipes = testRecipe.recipes;
      //size = recipes.length;
      //imageURL = recipes[0]['imageUrl'];
      //print("Size of recipes : $size");
      //print(imageURL);
    });
  }

  @override
  void initState(){
    super.initState();
    readJson();
    writeCounter(3);
  }

  @override
  Widget build(BuildContext context){
    var recipeState = context.watch<RecipeState>();
    recipeFavouriteList = recipeState.favouriteStatus;
    print("List now has: $recipeFavouriteList");
    return Scaffold(
      
      appBar: AppBar(
        title: const Text("Lab 7"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        
        
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Container(
                child: Text("Recipe App"),
                alignment: Alignment.center,
              ) 
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text("Recipes"),
              onTap: () {
                print("Recipes clicked!");
              },
              selected: true,
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Favourite Recipes"),
              onTap: () {
                print("Favourite Recipes clicked!");
                Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>FavouriteRecipesPage())
                    );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                print("Before toJSON: ${testRecipe.recipes}");
                
                
                setState(() {
                  testRecipe.toJson({
                    'recipes': [{'recipeName': 'Exerise 12', 'recipeAuthor':'Jose'}]
                  });
                });
                
                print("After toJSON:");
              

                Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>SettingsPage())
                    );
              },
            )
          ],
        ),
      ),

      body: Column(
        children: [
          recipes!=null ? 
          Expanded(
            child:GridView.builder(
            shrinkWrap: true,
            gridDelegate: 
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 30
              ),
            itemCount: recipes.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, index) {
              
              return 
              Semantics(
                label: "Recipe item. Click for more information on recipe.",
                //excludeSemantics: true,
                child: 
                  InkWell(
                    onTap: (){
                      var nameOfRecipe = recipes[index];
                      print("$nameOfRecipe Recipe clicked!");
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context)=>RecipePage(recipe: nameOfRecipe))
                        );
                    },
                    child:Container(  
                      decoration:BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5),BlendMode.darken),
                        image: NetworkImage(recipes[index]['imageUrl'].toString()),
                        fit: BoxFit.cover,
                        )
                      ),
                      child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      recipes[index]['recipeAuthor'].toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.favorite_border),
                                      tooltip: "A heart icon. Click to add to Favourite Recipes",
                                      onPressed: () {
                                        print("Recipe Favourite!!!");
                                        setState(() {
                                          print(recipes[index]['recipeName']);
                                          recipeState.getList(recipes[index]);
                                          recipeState.favourite(recipes[index]['recipeName']);
                                          //print(recipeFavouriteList);
                                        });
                                        //recipeState.getList(recipes[index]);
                                        //print(recipeFavouriteList.contains(Key("recipeName")));
                                      },
                                      isSelected: (recipeFavouriteList.contains(recipes[index]['recipeName'])),
                                      selectedIcon: Icon(Icons.favorite),

                                    )
                                  ]
                                ),
                                const SizedBox(height: 40),
                                Text(
                                  recipes[index]['recipeName'].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20
                                  ),
                                ),
                                Expanded(
                                  child:Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const WidgetSpan(
                                              child: Icon(
                                                      semanticLabel: "Time to cook",
                                                      Icons.access_time,
                                                      color: Colors.white,
                                                    )
                                            ),
                                            TextSpan(
                                              text: recipes[index]['cookingTime'].toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10
                                              )
                                            )
                                          ]
                                        )
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const WidgetSpan(
                                              child: Icon(
                                                      semanticLabel: "Price",
                                                      Icons.shopping_bag,
                                                      color: Colors.white,
                                                    )
                                            ),
                                            TextSpan(
                                              text: recipes[index]['amountOfIngredients'].toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10
                                              )
                                            )
                                          ]
                                        )
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const WidgetSpan(
                                              child: Icon(
                                                      semanticLabel: "Difficulty",
                                                      Icons.question_mark_rounded,
                                                      color: Colors.white,
                                                    )
                                            ),
                                            TextSpan(
                                              text: recipes[index]['recipeDifficulty'].toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10
                                              )
                                            )
                                          ]
                                        )
                                      ),
                                    ],
                                  )
                                )
                              ],
                          )
                    )
                  ),
              );
            })
          ): const Text("No Recipes Found")
      ]),
    );
  }
}

class RecipePage extends StatelessWidget {
  final recipe;
  
  RecipePage({this.recipe});
  
  List test(recipe)
  {
    List ingredients = recipe['ingredients'];
    List ingredientList = [];
    int counter = 1;
    for (var ingredient in ingredients){
      ingredientList.add("$counter. $ingredient");
      counter++;
    }
    //print(ingredientList);
    return ingredientList;
  }

  List directions(recipe)
  {
    List directions = recipe['directions'];
    List directionList = [];
    int counter = 1;
    for (var direction in directions){
      directionList.add("$counter. $direction");
      counter++;
    }

    return directionList;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['recipeName'].toString()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          Image.network(recipe['imageUrl'].toString(),
          fit: BoxFit.fill,
          height: 200,
          semanticLabel: "${recipe['recipeName']}",
        
          ),
          Expanded(
          child: ListView(
            //physics: ClampingScrollPhysics(),
            children: [
            RichText(
              text: TextSpan(
                text: "Author: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                  ),
                children: [
                  TextSpan(
                    text: recipe['recipeAuthor'],
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    )
                  )
                ]
              )
            
            ),
            SizedBox(height: 20,),
            RichText(
              text: TextSpan(
                text: "Description: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                  ),
              )
            ),
            Text(recipe['description']),
             SizedBox(height: 20,),
            RichText(
              text: const TextSpan(
                text: "Ingredients:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                  ),
              )
            ),
            
            Text(test(recipe).join("    ")),
             SizedBox(height: 20,),
          
            RichText(
              text: const TextSpan(
                text: "Time to Cook:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                  ),
              )
            ),
            Text("${recipe['cookTime']} mins"),
             SizedBox(height: 20,),
            RichText(
              text: const TextSpan(
                text: "Directions:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                  ),
              ),
            ),
            Text(directions(recipe).join(" \n")),
            ]
          ),
          )
        ],
      )
    );
  }
}

class FavouriteRecipesPage extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    var recipeState = context.watch<RecipeState>();
    var recipeList = recipeState.RecipeList;
    //var test = recipeList[0];
    //print ("Index is: $test");
    if(recipeState.RecipeList.isEmpty){
      return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite Recipes"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Container(
                child: Text("Recipe App"),
                alignment: Alignment.center,
              ) 
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text("Recipes"),
              onTap: () {
                print("Recipes clicked!");
                Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>MainPage())
                    );
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Favourite Recipes"),
              onTap: () {
                print("Favourite Recipes clicked!");
                Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>FavouriteRecipesPage())
                    );
              },
              selected: true,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                print("Settings clicked!");
                Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>SettingsPage())
                    );
              },
            )
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Text("No Favourites Yet")
        ),
    );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite Recipes"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Container(
                child: Text("Recipe App"),
                alignment: Alignment.center,
              ) 
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text("Recipes"),
              onTap: () {
                print("Recipes clicked!");
                Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>MainPage())
                    );
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Favourite Recipes"),
              onTap: () {
                print("Favourite Recipes clicked!");
                Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>FavouriteRecipesPage())
                    );
              },
              selected: true,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                print("Settings clicked!");
                Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>SettingsPage())
                    );
              },
            )
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ //Text(recipeList.toString())
          Expanded(
            child: ListView.builder(
              itemCount: recipeList.length,
              itemBuilder: (BuildContext context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //Image.network(recipeList[index]['imageUrl']),
                    Image(
                      image: NetworkImage(recipeList[index]['imageUrl']),
                      height: 40,
                      width: 50,
                      semanticLabel: "Picture of ${recipeList[index]['recipeName']}",
                      ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        recipeList[index]['recipeName'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      Text(
                        recipeList[index]['recipeAuthor'],
                        style: TextStyle(fontWeight: FontWeight.normal),
                        )
                    ],),
                    SizedBox(
                      height: 50,
                    )
                  ],
                );
              })
              )
        ]
          )
        
        );
    
  }

}

class SettingsPage extends StatefulWidget{
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  
  void switchTheme(bool value)
  {
    setState(() {
      flag = value;
      print(flag);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Container(
                child: Text("Recipe App"),
                alignment: Alignment.center,
              ) 
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text("Recipes"),
              onTap: () {
                print("Recipes clicked!");
                Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>MainPage())
                    );
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Favourite Recipes"),
              onTap: () {
                print("Favourite Recipes clicked!");
                Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>FavouriteRecipesPage())
                    );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                print("Settings clicked!");
              },
              selected: true,
            )
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Switch(value: flag, onChanged: switchTheme)
        ),
    );
  }
}

class StartPage extends StatefulWidget{
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  double sizeOfFont = 10;
  double spacing = 1;
  double viewable = 1.0;
  @override
  void initState(){
    super.initState();
    Future.delayed(const Duration(seconds: 2),(){
      setState(() {
      sizeOfFont = 40;
      spacing = 8;
    });
    });
    
    
  }
  
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: AnimatedDefaultTextStyle(
          style: TextStyle(color: Colors.orange,fontSize: sizeOfFont),
          duration: Duration(seconds: 2),
          child: AnimatedOpacity(opacity: viewable,
          duration: Duration(milliseconds: 800),
          child: Text("The Recipe App")),
          curve: Curves.bounceIn,
          ),
          
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: AnimatedContainer(
        alignment: Alignment.center,
        duration: Duration(seconds: 2),
        color: Colors.orange,
        child:AnimatedOpacity(
          opacity: viewable,
          duration: Duration(milliseconds: 800),
          child: ElevatedButton(onPressed: (){
            setState(() {
              viewable = 0.0;
              Future.delayed(Duration(seconds: 2),(){
                 Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>MainPage(),               
                    )
                    );
              });
             
            });
          }, 
          child: AnimatedDefaultTextStyle(
            style: TextStyle(color: Colors.orange,fontSize: 20,letterSpacing: spacing),
            duration: Duration(seconds: 2),
            child: Text("Sign-in"),
            curve: Curves.ease
            ), 
          ),
        )
      ),
      
    );
  }
}