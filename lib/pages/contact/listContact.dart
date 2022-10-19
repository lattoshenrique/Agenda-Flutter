import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riquenanucleus/styles/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riquenanucleus/pages/contact/createContact.dart';
import 'package:riquenanucleus/functions.dart';
import 'package:riquenanucleus/widgets/widgets.dart';
import 'package:lottie/lottie.dart';

class ListContact extends StatefulWidget {
  const ListContact({Key? key}) : super(key: key);

  @override
  State<ListContact> createState() => _ListContactState();
}

class _ListContactState extends State<ListContact> {
  final _items = <String, Reminder>{};
  bool _isLoading = true;

  loadData() async {
    final it = await getLocalDb();
    final now = DateTime.now();
    for (var element in it.entries) {
      final item = Reminder.fromMap(element.value);
      final formatedDate = DateTime.parse(
          "${item.date!.substring(6, 10)}${item.date!.substring(3, 5)}${item.date!.substring(0, 2)}T${item.time!.replaceAll(':', '')}");
      if (formatedDate.compareTo(now) <= 0) {
        item.isActive = false;
        item.save();
      }
      _items.putIfAbsent(item.id.toString(), () => item);
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
        child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Icon(Icons.info, size: 40, color: titleColor),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('-> Tocar no Lembrete: Ver detalhes e editar',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: media.width * 0.04)),
                      SizedBox(
                        height: media.height * 0.01,
                      ),
                      Text('-> Lembrete colorido está ativo, sem cor está inativo',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: media.width * 0.04)),
                      SizedBox(
                        height: media.height * 0.01,
                      ),
                      Text('-> Tocar na Notificação do Lembrete irá abrir o app de Chamadas',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: media.width * 0.04)),
                      SizedBox(
                        height: media.height * 0.01,
                      ),
                      Text('-> Campos com * são obrigatórios',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: media.width * 0.04)),
                      SizedBox(
                        height: media.height * 0.04,
                      ),
                      Text('Feito com ❤ para a Nucleus.eti',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: media.width * 0.04))
                    ]),
                  ),
                );
              },
              backgroundColor: titleColor.withOpacity(0.6),
              child: Icon(Icons.info, color: bgColor),
            ),
            body: Stack(children: [
              Container(
                  // height: media.height * 1,
                  width: media.width * 1,
                  height: media.height * 1,
                  decoration: BoxDecoration(
                    color: bgColor,
                  ),
                  child: SingleChildScrollView(
                      physics: const ScrollPhysics(),
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                        (_isLoading == true)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                    SizedBox(height: media.height * 0.24),
                                    SizedBox(
                                        width: media.width * 0.5,
                                        child: Lottie.asset(
                                            'assets/lottie/calendario-branco.json')),
                                  ])
                            : (_items.keys.isEmpty)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                        SizedBox(height: media.height * 0.3),
                                        Text(
                                          'Nenhum Lembrete Criado 😕',
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * 0.05,
                                              color: titleColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ])
                                : Column(children: [
                                    SizedBox(height: media.height * 0.27),
                                    Container(
                                        padding: EdgeInsets.fromLTRB(
                                            media.width * 0.05,
                                            0,
                                            media.width * 0.05,
                                            0),
                                        child: Column(
                                          children: <Widget>[
                                            ListView.builder(
                                              padding: const EdgeInsets.all(0),
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: _items.keys.length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                final key = _items.keys
                                                    .elementAt(index);
                                                final item = _items[key]!;
                                                return Column(children: [
                                                  InkWell(
                                                      onTap: () {
                                                        showDialog<String>(
                                                          context: context,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              AlertDialog(
                                                            title: Text(
                                                              '${item.name}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts.poppins(
                                                                  fontSize:
                                                                      media.width *
                                                                          0.055,
                                                                  color:
                                                                      titleColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            content:
                                                                SingleChildScrollView(
                                                                    child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .start,
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      InkWell(
                                                                          child:
                                                                              Container(
                                                                        height: media.width *
                                                                            0.4,
                                                                        width: media.width *
                                                                            0.4,
                                                                        decoration: BoxDecoration(
                                                                            shape: BoxShape
                                                                                .circle,
                                                                            color:
                                                                                bgColor,
                                                                            image: (item.imagePath == null)
                                                                                ? const DecorationImage(image: AssetImage('assets/images/user.png'), fit: BoxFit.cover)
                                                                                : DecorationImage(image: FileImage(File("${item.imagePath}")), fit: BoxFit.cover)),
                                                                      )),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .height *
                                                                        0.04,
                                                                  ),
                                                                  Flexible(
                                                                    child:
                                                                        RichText(
                                                                      text:
                                                                          TextSpan(
                                                                        style: GoogleFonts.poppins(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: media.width * 0.04),
                                                                        children: <
                                                                            TextSpan>[
                                                                          TextSpan(
                                                                              text: 'Celular: ',
                                                                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: media.width * 0.04)),
                                                                          TextSpan(
                                                                              text: '${item.cel}',
                                                                              style: GoogleFonts.poppins(color: Colors.black, fontSize: media.width * 0.04)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .height *
                                                                        0.01,
                                                                  ),
                                                                  Flexible(
                                                                    child:
                                                                        RichText(
                                                                      text:
                                                                          TextSpan(
                                                                        style: GoogleFonts.poppins(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: media.width * 0.04),
                                                                        children: <
                                                                            TextSpan>[
                                                                          TextSpan(
                                                                              text: 'Email: ',
                                                                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: media.width * 0.04)),
                                                                          TextSpan(
                                                                              text: (item.email == '') ? 'Não Informado' : '${item.email}',
                                                                              style: GoogleFonts.poppins(color: Colors.black, fontSize: media.width * 0.04)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .height *
                                                                        0.01,
                                                                  ),
                                                                  Flexible(
                                                                    child:
                                                                        RichText(
                                                                      text:
                                                                          TextSpan(
                                                                        children: <
                                                                            TextSpan>[
                                                                          TextSpan(
                                                                              text: 'Endereço: ',
                                                                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: media.width * 0.04)),
                                                                          TextSpan(
                                                                              text: (item.cep == '') ? 'Não Informado' : '${item.street}, ${item.streetNumber}, ${item.province}, ${item.city} - ${item.state}, ${item.cep}',
                                                                              style: GoogleFonts.poppins(color: Colors.black, fontSize: media.width * 0.04)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .height *
                                                                        0.01,
                                                                  ),
                                                                  Flexible(
                                                                    child:
                                                                        RichText(
                                                                      text:
                                                                          TextSpan(
                                                                        style: GoogleFonts.poppins(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: media.width * 0.04),
                                                                        children: <
                                                                            TextSpan>[
                                                                          TextSpan(
                                                                              text: 'Data e Hora Agendado: ',
                                                                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: media.width * 0.04)),
                                                                          TextSpan(
                                                                              text: '${item.date} às ${item.time}',
                                                                              style: GoogleFonts.poppins(color: Colors.black, fontSize: media.width * 0.04)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .height *
                                                                        0.01,
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .height *
                                                                        0.04,
                                                                  ),
                                                                  Button(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => CreateContact(
                                                                                editTodo: "${item.id}",
                                                                              ),
                                                                            ));
                                                                      },
                                                                      text:
                                                                          "Editar")
                                                                ])),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            media.width * 0.05),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              width: 1,
                                                              color:
                                                                  (item.isActive ==
                                                                          true)
                                                                      ? btnColor
                                                                      : Colors
                                                                          .grey),
                                                          color: (item.isActive ==
                                                                  true)
                                                              ? btnColor
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      (item.name.toString().length >
                                                                              17)
                                                                          ? '${item.name.toString().substring(0, 17)}...'
                                                                          : "${item.name}",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: GoogleFonts.roboto(
                                                                          fontSize: media.width *
                                                                              0.06,
                                                                          color: (item.isActive == true)
                                                                              ? Colors.white
                                                                              : Colors.black,
                                                                          fontWeight: FontWeight.w600)),
                                                                  SizedBox(
                                                                      height: media
                                                                              .height *
                                                                          0.01),
                                                                  Text(
                                                                      "${item.date} às ${item.time}",
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                0.04,
                                                                        color: (item.isActive ==
                                                                                true)
                                                                            ? bgColor
                                                                            : Colors.black,
                                                                      )),
                                                                ]),
                                                            InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    if (item
                                                                        .isActive!) {
                                                                      NotificationApi
                                                                          .cancelNotification(
                                                                              int.parse(item.notId!));
                                                                    }
                                                                    item.delete();
                                                                    _items.remove(
                                                                        item.id);
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets.fromLTRB(
                                                                      media.width *
                                                                          0.05,
                                                                      media.width *
                                                                          0.04,
                                                                      media.width *
                                                                          0.05,
                                                                      media.width *
                                                                          0.04),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color:
                                                                        titleColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  child: Icon(
                                                                    Icons
                                                                        .delete,
                                                                    size: media
                                                                            .width *
                                                                        0.05,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      )),
                                                  SizedBox(
                                                    height:
                                                        media.height * 0.025,
                                                  ),
                                                ]);
                                              },
                                            ),
                                          ],
                                        ))
                                  ]),
                      ]))),
              Positioned(
                  top: 0,
                  child: Container(
                      width: media.width * 1,
                      height: media.height * 0.24,
                      decoration: BoxDecoration(
                        color: titleColor,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 7,
                            color: Color(0x4D090F13),
                            offset: Offset(0, 3),
                          )
                        ],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                        ),
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(media.width * 0.05),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Bem-Vindo(a)',
                                                style: GoogleFonts.poppins(
                                                    fontSize:
                                                        media.width * 0.05,
                                                    color: bgColor)),
                                            Text('Seus Lembretes',
                                                style: GoogleFonts.poppins(
                                                    fontSize:
                                                        media.width * 0.08,
                                                    fontWeight: FontWeight.w600,
                                                    color: bgColor)),
                                          ]),
                                      CircleAvatar(
                                          radius: media.width * 0.075,
                                          backgroundColor: bgColor,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.add,
                                              color: titleColor,
                                            ),
                                            tooltip: 'adicionar',
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const CreateContact()));
                                            },
                                          ))
                                    ])
                              ])))),
            ])));
  }
}
