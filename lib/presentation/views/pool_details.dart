import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';

class PoolDetails extends StatefulWidget {
  const PoolDetails({super.key, required this.id});
  final String id;

  @override
  State<PoolDetails> createState() => _PoolDetailsState();
}

class _PoolDetailsState extends State<PoolDetails> {
  final String? url = null;

  String initialLetter(String name) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.colorWhite,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Image.asset("assets/images/Logo-Text.png", width: 100),
        ),
      ),
      backgroundColor: ColorConstant.colorWhite,
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Image.asset("assets/images/Logo.png", width: 415, height: 220),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  "Birthday Surprise for Clara",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  spacing: 16,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      child: url == null
                          ? Text(
                              initialLetter("Zaibre"),
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Image.asset("$url"),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Crée par Zaibre ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text('July 15,2021'),
                      ],
                    ),
                  ],
                ),
              ),
              Center(
                child: AppButton(
                  backgroundColor: ColorConstant.colorGreen,
                  text: "Contribuer",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ColorConstant.colorGreen,
                      ),
                    ),

                    Text(
                      "dfhsjgjhjfdhgjfhdsljgjkhsfjdkhgjfdhsjkhdsfjhgdiuosffhavjadfksjhgjhdgffvghasdjjfhjdshfjhdjvhdjskhfjkdshfjkhdskjfhdsjkk=hfjkdhsjkfhdjshfjkdshfjkhdsjikfhijkdskhfjkjdshfkjkhdsjkfhdsjkkhjjh",
                      softWrap: true,
                      maxLines: 4,
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ColorConstant.colorGreen,
                      ),
                    ),
                    Column(
                      spacing: 45,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Contributeurs",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "12",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total collecter",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "360.000 Fr",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Nombre de jour depuis la creation ",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "30",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 41),

                    Text(
                      "Contributeurs",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ColorConstant.colorGreen,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            spacing: 16,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                child: url == null
                                    ? Text(
                                        initialLetter("Zaibre"),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Image.asset("$url"),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Crée par Zaibre ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text('July 15,2021'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
