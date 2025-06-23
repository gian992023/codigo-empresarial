import 'package:conexion/constants/routes.dart';
import 'package:conexion/firebase_helper/firebase_firestore_helper/firebase_firestore.dart';
import 'package:conexion/models/category_model/category_model.dart';
import 'package:conexion/provider/app_provider.dart';
import 'package:conexion/screens/category_view/category_view.dart';
import 'package:conexion/screens/product_detail/product_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/asset_images.dart';
import '../../models/product_model/product_model.dart';
import '../../models/service_model/service_model.dart';
import '../create_asset/create_assets.dart';
import '../service_details/service_details.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoryModel> categoriesList = [];
  List<ProductModel> productModelList = [];
  List<ServiceModel> serviceModelList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Obtenemos la info básica del usuario
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.getUserInfoFirebase();

    // Cargamos categorías + productos + servicios desde Firestore
    getCategoryList();
  }


  void getCategoryList() async {
    setState(() {
      isLoading = true;
    });


    FirebaseFirestoreHelper.instance.updateTokenFromFirebase();

    categoriesList = await FirebaseFirestoreHelper.instance.getCategories();

    // Traemos productos y servicios.
    productModelList = await FirebaseFirestoreHelper.instance.getUserProducts();
    serviceModelList = await FirebaseFirestoreHelper.instance.getUserServices();


    productModelList.shuffle();
    serviceModelList.shuffle();

    setState(() {
      isLoading = false;
    });
  }

  TextEditingController search = TextEditingController();
  List<ProductModel> searchProductList = [];
  List<ServiceModel> searchServiceList = [];

  /// Cada vez que el usuario escribe en el TextField de búsqueda,
  /// filtramos las listas completas de productos/servicios y luego
  /// “setState” para que se refresque la vista.
  void searchItems(String value) {
    searchProductList = productModelList
        .where((element) =>
        element.name.toLowerCase().contains(value.toLowerCase()))
        .toList();
    searchServiceList = serviceModelList
        .where((element) =>
        element.name.toLowerCase().contains(value.toLowerCase()))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0E6),
        appBar: AppBar(
          toolbarHeight: 150,
          backgroundColor: const Color(0xFFE3D5C5),
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Image.asset(
              AssetsImages.instance.Casanarev,
              height: 320,
              fit: BoxFit.contain,
              color: const Color(0xFF6B4F4F),
            ),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFF6B4F4F),
            labelColor: const Color(0xFF6B4F4F),
            unselectedLabelColor: const Color(0xFFA78B7D),
            tabs: const [
              Tab(
                child: Text(
                  "Productos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  "Servicios",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: search,
                onChanged: searchItems,
                decoration: InputDecoration(
                  hintText: "Buscar...",
                  prefixIcon:
                  const Icon(Icons.search, color: Color(0xFF6B4F4F)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                    const BorderSide(color: Color(0xFFD3C0B2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                    const BorderSide(color: Color(0xFF6B4F4F)),
                  ),
                ),
              ),
            ),
            // Pestañas: Productos / Servicios
            Expanded(
              child: TabBarView(
                children: [
                  _buildListView(
                      search.text.isNotEmpty
                          ? searchProductList
                          : productModelList,
                      true),
                  _buildListView(
                      search.text.isNotEmpty
                          ? searchServiceList
                          : serviceModelList,
                      false),
                ],
              ),
            ),
          ],
        ),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 60.0),
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF6B4F4F),
            child: const Icon(Icons.add),
            onPressed: () {
              Routes.instance
                  .push(widget: const RegisterSelection(), context: context)
                  .then((_) {
                // Al regresar de CreateProductPage, recargamos listas:
                getCategoryList();
              });
            },
          ),
        ),
        // ─────────────────────────────────────────────────────────────────
      ),
    );
  }

  /// Este método genera la cuadrícula de “tarjetas” de productos o servicios.
  Widget _buildListView(List<dynamic> list, bool isProduct) {
    return list.isEmpty
        ? Center(
      child: Text(
        isProduct ? "Sin productos" : "Sin servicios",
        style: const TextStyle(color: Color(0xFF6B4F4F)),
      ),
    )
        : SingleChildScrollView(
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (ctx, index) =>
                _buildItemCard(list[index], isProduct),
          ),
          // Espacio extra al final para separar del nav bar (si usas BottomNavigation)
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// Cada tarjeta muestra:
  ///  - Imagen
  ///  - Nombre
  ///  - Cantidad (si es producto) o Precio (si es servicio)
  ///  - Botón “Editar” que al volver hace getCategoryList() para refrescar.
  Widget _buildItemCard(dynamic item, bool isProduct) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EF),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 130),
              child: Image.network(
                item.image,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A3A3A),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              isProduct
                  ? "Cantidad: ${item.qty}"
                  : "Precio: \$${item.price}",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B4F4F),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              width: 110,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6B4F4F)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () {
                  /// IMPORTANTE: cada vez que regreses de la pantalla de "Editar",
                  /// llamas a getCategoryList() para refrescar los datos en esta vista:
                  Routes.instance
                      .push(
                    widget: isProduct
                        ? ProductDetails(singleProduct: item)
                        : ServiceDetails(singleService: item),
                    context: context,
                  )
                      .then((_) {
                    // Este callback se ejecuta cuando vuelves de la pantalla
                    // de edición (o creación). Con esto, recargamos la lista.
                    getCategoryList();
                  });
                },
                child: const Text(
                  "Editar",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// En este ejemplo, no es estrictamente necesario usar isSearched(),
  /// ya que simplemente usamos `searchItems(...)` para filtrar. Pero lo dejamos
  /// por si en un futuro quieres otra lógica condicional para búsquedas.
  bool isSearched() {
    if (search.text.isNotEmpty &&
        searchProductList.isNotEmpty &&
        searchServiceList.isNotEmpty) {
      return true;
    } else if (search.text.isEmpty &&
        searchProductList.isNotEmpty &&
        searchServiceList.isNotEmpty) {
      return false;
    } else if (searchProductList.isNotEmpty &&
        searchServiceList.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
