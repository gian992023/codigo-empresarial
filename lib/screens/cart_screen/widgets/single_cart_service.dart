import 'package:conexion/models/service_model/service_model.dart';
import 'package:conexion/provider/app_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/constants.dart';

class SingleCartService extends StatelessWidget {
  final ServiceModel singleService;

  const SingleCartService({super.key, required this.singleService});

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 3),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 140,
              color: Colors.blue.withOpacity(0.5),
              child: Image.network(singleService.image),
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 140,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              child: Text(
                                singleService.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (!appProvider.getFavouriteServiceList.contains(singleService)) {
                                  appProvider.addFavouriteService(singleService);
                                  showMessage("Agregar a favoritos");
                                } else {
                                  appProvider.removeFavouriteService(singleService);
                                  showMessage("Remover de favoritos");
                                }
                              },
                              child: Text(
                                appProvider.getFavouriteServiceList.contains(singleService)
                                    ? "Remover de favoritos"
                                    : "Agregar a favoritos",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "\$${singleService.price.toString()}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        appProvider.removeCartService(singleService);
                        showMessage("Remover del carrito");
                      },
                      child: const CircleAvatar(
                        maxRadius: 13,
                        child: Icon(
                          Icons.delete,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
