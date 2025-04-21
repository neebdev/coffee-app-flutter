import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fussy_coffee_flutter/fade.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'cart_screen.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  int selectedIndex = 0;
  bool isSelected = false;
  final PageController _pageController = PageController(viewportFraction: 0.6);
  late List<bool> liked;
  late Box<bool> likedDrinksBox;
  late Box<Map> shoppingCartBox;
  String selectedSize = '';

  @override
  void initState() {
    super.initState();
    likedDrinksBox = Hive.box<bool>('likedDrinks');
    shoppingCartBox = Hive.box<Map>('shoppingCart');
    liked = List<bool>.generate(drinks.length, (index) {
      return likedDrinksBox.get(drinks[index].name, defaultValue: false) ??
          false;
    });
  }

  void _onDrinkSelected(int index) {
    setState(() {
      selectedIndex = index;
      isSelected = true;
      selectedSize = 'M';
    });
  }

  void _onBackButtonPressed() {
    setState(() {
      isSelected = false;
      selectedSize = '';
    });
  }

  void _onSizeSelected(String size) {
    setState(() {
      selectedSize = size;
    });
  }

  void _addToCart() {
    if (selectedSize.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a size first!')),
      );
      return;
    }

    final drink = drinks[selectedIndex];
    final cartKey = '${drink.name}_$selectedSize';

    final existingItem = shoppingCartBox.get(cartKey);

    if (existingItem != null) {
      final Map<String, dynamic> updatedItem =
          Map<String, dynamic>.from(existingItem);
      updatedItem['quantity'] = (updatedItem['quantity'] ?? 0) + 1;
      shoppingCartBox.put(cartKey, updatedItem);
    } else {
      final newItem = {
        'name': drink.name,
        'size': selectedSize,
        'imagePath': drink.imagePath,
        'quantity': 1,
      };
      shoppingCartBox.put(cartKey, newItem);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${drink.name} ($selectedSize) added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: drinks[selectedIndex].backgroundColor,
        end: drinks[selectedIndex].backgroundColor,
      ),
      duration: const Duration(milliseconds: 500),
      builder: (context, color, _) {
        return Scaffold(
          backgroundColor: color ?? drinks[0].backgroundColor,
          body: SafeArea(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Opacity(
                      opacity: 0.2,
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'images/logo.png',
                          width: 500,
                          height: 500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: AnimatedOpacity(
                      opacity: isSelected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: IconButton(
                        icon: SvgPicture.asset(
                          'images/back.svg',
                          height: 100,
                          width: 100,
                        ),
                        onPressed: _onBackButtonPressed,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 24,
                    right: 35,
                    child: AnimatedOpacity(
                      opacity: isSelected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CartScreen()),
                          );
                        },
                        child: SvgPicture.asset(
                          'images/cart.svg',
                          height: 47,
                          width: 47,
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: isSelected ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              Image(
                                image: AssetImage('images/logo.png'),
                                width: 100,
                                height: 100,
                              ),
                              Text(
                                "FUSSY COFFEE IS...",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "PURE LOVE",
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          SizedBox(
                            height: 550,
                            child: PageView.builder(
                              // physics: BouncingScrollPhysics(),
                              physics: isSelected
                                  ? const NeverScrollableScrollPhysics()
                                  : const BouncingScrollPhysics(),
                              controller: _pageController,
                              itemCount: drinks.length,
                              onPageChanged: (index) {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                bool isCurrent = selectedIndex == index;
                                double translateX = 0.0;
                                double translateY = 0.0;

                                if (isSelected && !isCurrent) {
                                  translateX =
                                      (index < selectedIndex ? -1 : 1) *
                                          MediaQuery.of(context).size.width;
                                }
                                if (isCurrent && isSelected) {
                                  translateY = -120.0;
                                }
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 900),
                                  curve: Curves.easeInOut,
                                  transform: Matrix4.translationValues(
                                    translateX,
                                    translateY,
                                    0,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(
                                          begin: 0.25,
                                          end: (isCurrent && isSelected)
                                              ? 0.0
                                              : 0.25,
                                        ),
                                        duration:
                                            const Duration(milliseconds: 400),
                                        builder: (context, angle, child) {
                                          return Transform.rotate(
                                            angle: angle,
                                            child: GestureDetector(
                                              onTap: () {
                                                if (isCurrent && !isSelected) {
                                                  _onDrinkSelected(index);
                                                }
                                              },
                                              child: Image(
                                                image: AssetImage(
                                                    drinks[index].imagePath),
                                                width: 300,
                                                height: 300,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        right: 10,
                                        child: IconButton(
                                          iconSize: 30,
                                          icon: SvgPicture.asset(
                                            liked[index]
                                                ? 'images/heart-red.svg'
                                                : 'images/heart-white.svg',
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              liked[index] = !liked[index];
                                              likedDrinksBox.put(
                                                  drinks[index].name,
                                                  liked[index]);
                                            });
                                          },
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            top: isSelected ? 360 : 400,
                            child: Text(
                              drinks[selectedIndex].name,
                              style: const TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Outlined reflection
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            top: isSelected ? 320 : 440,
                            child: Text(
                              drinks[selectedIndex].name,
                              style: TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2
                                  ..color = Colors.white,
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            top: isSelected ? 450 : 550,
                            child: FadeTransitionWidget(
                              visible: isSelected,
                              fadeInDuration: const Duration(milliseconds: 600),
                              fadeOutDuration:
                                  const Duration(milliseconds: 500),
                              child: Text(
                                drinks[selectedIndex].description,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 370,
                    child: FadeTransitionWidget(
                      visible: isSelected,
                      fadeInDuration: const Duration(milliseconds: 900),
                      fadeOutDuration: const Duration(milliseconds: 300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RawMaterialButton(
                            onPressed: () {
                              _onSizeSelected('S');
                            },
                            shape: const CircleBorder(),
                            fillColor: selectedSize == 'S'
                                ? Colors.black
                                : Colors.white,
                            child: Text(
                              'S',
                              style: TextStyle(
                                fontSize: 37,
                                fontWeight: FontWeight.w300,
                                color: selectedSize == 'S'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          RawMaterialButton(
                            onPressed: () {
                              _onSizeSelected('M');
                            },
                            shape: const CircleBorder(),
                            fillColor: selectedSize == 'M'
                                ? Colors.black
                                : Colors.white,
                            child: Text(
                              'M',
                              style: TextStyle(
                                fontSize: 47,
                                fontWeight: FontWeight.w300,
                                color: selectedSize == 'M'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          RawMaterialButton(
                            onPressed: () {
                              _onSizeSelected('L');
                            },
                            shape: const CircleBorder(),
                            fillColor: selectedSize == 'L'
                                ? Colors.black
                                : Colors.white,
                            child: Text(
                              'L',
                              style: TextStyle(
                                fontSize: 37,
                                fontWeight: FontWeight.w300,
                                color: selectedSize == 'L'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 680,
                    child: FadeTransitionWidget(
                      visible: isSelected,
                      fadeInDuration: const Duration(milliseconds: 600),
                      fadeOutDuration: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: _addToCart,
                        child: SvgPicture.asset(
                          'images/order.svg',
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Drink {
  final String name;
  final String imagePath;
  final String description;
  final Color backgroundColor;

  Drink({
    required this.name,
    required this.imagePath,
    required this.backgroundColor,
    required this.description,
  });
}

List<Drink> drinks = [
  Drink(
      name: 'Espresso',
      imagePath: 'images/fussycup2.png',
      backgroundColor: const Color.fromARGB(255, 174, 145, 119),
      description:
          'Concentrated coffee brewed by forcing hot water through finely-ground coffee beans.'),
  Drink(
      name: 'Cappuccino',
      imagePath: 'images/fussycup3.png',
      backgroundColor: const Color.fromARGB(255, 189, 172, 200),
      description: 'Espresso with steamed milk foam.'),
  Drink(
      name: 'Latte',
      imagePath: 'images/fussycup1.png',
      backgroundColor: const Color.fromARGB(255, 177, 158, 140),
      description: 'Espresso with steamed milk.'),
  Drink(
      name: 'Mocha',
      imagePath: 'images/fussycup2.png',
      backgroundColor: const Color.fromARGB(255, 174, 145, 119),
      description: 'Espresso with chocolate.'),
  Drink(
      name: 'Americano',
      imagePath: 'images/fussycup3.png',
      backgroundColor: const Color.fromARGB(255, 160, 145, 169),
      description: 'Espresso diluted with hot water.'),
  Drink(
      name: 'Macchiato',
      imagePath: 'images/fussycup1.png',
      backgroundColor: const Color.fromARGB(255, 155, 138, 122),
      description: 'Espresso with a dash of milk.'),
  Drink(
      name: 'Flat White',
      imagePath: 'images/fussycup2.png',
      backgroundColor: const Color.fromARGB(255, 155, 129, 106),
      description: 'Espresso with microfoam.'),
  Drink(
      name: 'Affogato',
      imagePath: 'images/fussycup3.png',
      backgroundColor: const Color.fromARGB(255, 160, 145, 169),
      description: 'Espresso poured over vanilla gelato.'),
];
