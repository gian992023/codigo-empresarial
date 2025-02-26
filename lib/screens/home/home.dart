import 'package:conexion/constants/routes.dart';
import 'package:conexion/firebase_helper/firebase_firestore_helper/firebase_firestore.dart';
import 'package:conexion/models/category_model/category_model.dart';
import 'package:conexion/provider/app_provider.dart';
import 'package:conexion/screens/category_view/category_view.dart';
import 'package:conexion/screens/product_detail/product_details.dart';
import 'package:conexion/widgets/top_titles/top_titles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/asset_images.dart';
import '../../models/product_model/product_model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoryModel> categoriesList = [];
  List<ProductModel> productModelList = [];
  bool isLoading = false;

  @override
  void initState() {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.getUserInfoFirebase();
    getCategoryList();
    super.initState();
  }

  void getCategoryList() async {
    setState(() {
      isLoading = true;
    });
    FirebaseFirestoreHelper.instance.updateTokenFromFirebase();
    categoriesList = await FirebaseFirestoreHelper.instance.getCategories();
    productModelList = await FirebaseFirestoreHelper.instance.getUserProducts();
    productModelList.shuffle();
    setState(() {
      isLoading = false;
    });
  }

  TextEditingController search = TextEditingController();
  List<ProductModel> searchList = [];

  void searchProducts(String value) {
    searchList = productModelList
        .where((element) =>
            element.name.toLowerCase().contains(value.toLowerCase()) )
        .toList();
    print(searchList.length);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: Container(
                height: 100,
                width: 100,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width, // Máximo ancho de la pantalla
                                maxHeight: 500, // Ajusta esto según el tamaño del logo
                              ),
                              child: Image.asset(
                                AssetsImages.instance.logo,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),


                          const SizedBox(
                            height: 2,
                          ),
                          TextFormField(
                            controller: search,
                            onChanged: (String value) {
                              searchProducts(value);
                            },
                            decoration: InputDecoration(
                              hintText: "Buscar...",
                              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                            ),
                            style: TextStyle(fontSize: 16),
                            cursorColor: Colors.blue,
                          ),

                          const SizedBox(
                            height: 24,
                          ),
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 132),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 7,
                                    blurRadius: 6,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Categorías",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )

                  ),
                  categoriesList.isEmpty
                      ? const Center(
                          child: Text("Categorias vacias"),
                        )
                      : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categoriesList
                          .map((e) => Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Routes.instance.push(
                                widget: CategoryView(
                                    categoryModel: e),
                                context: context);
                          },
                          child: Card(
                            color: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: Image.network(e.image),
                            ),
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  !isSearched()? const Padding(
                    padding: EdgeInsets.only(top: 12.0, left: 12),
                    child: Text(
                      "Mis productos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ):SizedBox.fromSize(),
                  const SizedBox(
                    height: 12,
                  ),
                  search.text.isNotEmpty && searchList.isEmpty?Center(child: Text("Producto no encontrado"),):searchList.isNotEmpty?Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                        padding: EdgeInsets.only(bottom: 50),
                        shrinkWrap: true,
                        primary: false,
                        itemCount: searchList.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 30,
                            childAspectRatio: 0.7,
                            crossAxisCount: 2),
                        itemBuilder: (ctx, index) {
                          ProductModel singleProduct =
                          searchList[index];
                          return Container(
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 12,
                                ),
                                Image.network(
                                  singleProduct.image,
                                  height: 100,
                                  width: 100,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  singleProduct.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Cantidad: ${singleProduct.qty}"),
                                const SizedBox(
                                  height: 30,
                                ),
                                SizedBox(
                                  height: 45,
                                  width: 120,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Routes.instance.push(
                                          widget: ProductDetails(
                                              singleProduct:
                                              singleProduct),
                                          context: context);
                                    },
                                    child: const Text(
                                      "Buy",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ): productModelList.isEmpty
                      ? const Center(
                          child: Text("Sin productos"),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                              padding: EdgeInsets.only(bottom: 50),
                              shrinkWrap: true,
                              primary: false,
                              itemCount: productModelList.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      mainAxisSpacing: 20,
                                      crossAxisSpacing: 30,
                                      childAspectRatio: 0.7,
                                      crossAxisCount: 2),
                              itemBuilder: (ctx, index) {
                                ProductModel singleProduct =
                                    productModelList[index];
                                //CONTENEDOR DE PRODUCTOS
                                return Container(
                                    decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // Cambia el desplazamiento de la sombra según sea necesario
                                ),
                                ],
                                    ),

                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Image.network(
                                        singleProduct.image,
                                        height: 100,
                                        width: 100,
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        singleProduct.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Text("Cantidad: ${singleProduct.qty}"),
                                      const SizedBox(
                                        height: 26,
                                      ),
                                      SizedBox(
                                        height: 45,
                                        width: 120,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Routes.instance.push(
                                                widget: ProductDetails(
                                                    singleProduct:
                                                        singleProduct),
                                                context: context);
                                          },
                                          child: const Text(
                                            "Editar",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                  const SizedBox(
                    height: 12,
                  )
                ],
              ),
            ),
    );
  }
  bool isSearched(){
    if (search.text.isNotEmpty && searchList.isEmpty){
      return true;
    }else if(search.text.isEmpty && searchList.isNotEmpty) {
      return false;
    } else if (searchList.isNotEmpty){
      return true;
    } else {
      return false;
    }
  }
}
