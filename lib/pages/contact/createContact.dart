// ignore_for_file: unrelated_type_equality_checks, unused_field

import 'dart:io';
import 'package:riquenanucleus/styles/colors.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:riquenanucleus/widgets/widgets.dart';
import 'package:riquenanucleus/functions.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import "package:riquenanucleus/pages/contact/listContact.dart";
import 'package:localstore/localstore.dart';

class CreateContact extends StatefulWidget {
  final String? editTodo;
  const CreateContact({Key? key, this.editTodo}) : super(key: key);

  @override
  State<CreateContact> createState() => _CreateContactState();
}

dynamic imageFile;

class _CreateContactState extends State<CreateContact> {
  int? notEdit;
  bool existdata = false;
  bool _setCep = false;
  bool _pickImage = false;

  List _data = [];
  dynamic dataToShow;
  bool _listSchedule = false;
  bool _isLoadSchedule = true;
  int _page = 0;
  int _perPage = 20;

  ImagePicker picker = ImagePicker();
  final format = DateFormat("dd/MM/yyyy, HH:mm");
  int stage = 0;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cepController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  TextEditingController compController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController();

  @override
  void initState() {
    setState(() {
      imageFile = null;
    });
    getData();
    super.initState();
  }

  listSchedule() async {
    await Future.delayed(const Duration(seconds: 1));
    _data = await getContact();
    if (_data.length < 20) {
      _perPage = _data.length;
    }

    dataToShow =
        _data.sublist((_page * _perPage), ((_page * _perPage) + _perPage));
    setState(() {
      _isLoadSchedule = false;
    });
  }

  _runFilter(String enteredKeyword) {
    dynamic results;
    if (enteredKeyword.isEmpty) {
      results =
          _data.sublist((_page * _perPage), ((_page * _perPage) + _perPage));
      setState(() {
        dataToShow = results;
      });
    } else if (enteredKeyword.length >= 3) {
      results = _data
          .where((element) => element.displayName
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
      setState(() {
        dataToShow = results;
      });
    }
  }

  // get db data if is editing
  final Map<String, dynamic> editData = <String, dynamic>{};
  final _db = Localstore.instance;
  getData() async {
    var data = await getLocalDb();

    if (widget.editTodo != null) {
      data.forEach((key, val) {
        if (val['id'] == widget.editTodo) {
          notEdit = int.parse(val['notId']);
          nameController.text = val['name'];
          emailController.text = val['email'];
          phoneController.text = val['cel'];
          cepController.text = val['cep'].replaceAll('-', '');
          cityController.text = val['city'];
          stateController.text = val['state'];
          streetController.text = val['street'];
          numberController.text = val['streetNumber'];
          provinceController.text = val['province'];
          compController.text = val['comp'];
          dateTimeController.text = val['date'] + ", " + val['time'];
          imageFile = val['imagePath'];
        }
      });
    }

    setState(() {
      if (data != null) {
        existdata = true;
      } else {
        existdata = false;
      }
    });
  }

//gallery permission
  getGalleryPermission() async {
    var status = await Permission.photos.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.photos.request();
    }
    return status;
  }

//camera permission
  getCameraPermission() async {
    var status = await Permission.camera.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.camera.request();
    }
    return status;
  }

//pick image from gallery
  pickImageFromGallery() async {
    var permission = await getGalleryPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        imageFile = pickedFile?.path;
        _pickImage = false;
      });
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Icon(Icons.error, size: 40, color: Colors.red),
          content: Text('Permita acesso à Galeria para escolher uma imagem',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
        ),
      );
    }
  }

//pick image from camera
  pickImageFromCamera() async {
    var permission = await getCameraPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      setState(() {
        imageFile = pickedFile?.path;
        _pickImage = false;
      });
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Icon(Icons.error, size: 40, color: Colors.red),
          content: Text('Permita acesso à Câmera para tirar uma foto',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
        ),
      );
    }
  }

  var phoneFormatter = MaskTextInputFormatter(
      mask: '(##) # ####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  var cepFormatter = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
        child: Scaffold(
            body: Stack(children: [
      Container(
        height: media.height * 1,
        width: media.width * 1,
        decoration: BoxDecoration(
          color: bgColor,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                  width: media.width * 1,
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
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(height: media.height * 0.05),
                        (existdata == true)
                            ? IconButton(
                                icon: Icon(Icons.arrow_back,
                                    color: bgColor, size: media.width * 0.1),
                                tooltip: 'voltar',
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              )
                            : (_listSchedule)
                                ? IconButton(
                                    icon: Icon(Icons.arrow_back,
                                        color: bgColor,
                                        size: media.width * 0.1),
                                    tooltip: 'voltar',
                                    onPressed: () {
                                      setState(() => _listSchedule = false);
                                    },
                                  )
                                : Container(),
                        SizedBox(height: media.height * 0.025),
                        Padding(
                          padding: EdgeInsets.fromLTRB(media.width * 0.05, 0,
                              media.width * 0.05, media.width * 0.2),
                          child: (stage == 1) // loader animation
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      SizedBox(
                                        width: media.width * 0.6,
                                        height: media.width * 0.6,
                                        child: Lottie.asset(
                                            'assets/lottie/default-loader.json'),
                                      )
                                    ])
                              : (stage == 0)
                                  ? Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                          Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    (widget.editTodo != null)
                                                        ? "Editar Lembrete"
                                                        : (_listSchedule)
                                                            ? "Selecionar Contato"
                                                            : 'Criar Lembrete',
                                                    style: GoogleFonts.poppins(
                                                        fontSize:
                                                            media.width * 0.08,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: bgColor)),
                                                (!_listSchedule)
                                                    ? CircleAvatar(
                                                        radius:
                                                            media.width * 0.075,
                                                        backgroundColor:
                                                            btnColor,
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons.person_search,
                                                            color: bgColor,
                                                          ),
                                                          tooltip:
                                                              'selecionar da agenda',
                                                          onPressed: () {
                                                            setState(() =>
                                                                _listSchedule =
                                                                    true);
                                                            listSchedule();
                                                          },
                                                        ))
                                                    : Container()
                                              ]),
                                          SizedBox(
                                            height: media.height * 0.025,
                                          ),
                                          Text(
                                              (widget.editTodo != null)
                                                  ? "Edite os Dados Corretamente"
                                                  : (_listSchedule)
                                                      ? "Selecione o contato para importar"
                                                      : 'Para começar, defina as informações do contato:',
                                              style: GoogleFonts.poppins(
                                                  fontSize: media.width * 0.05,
                                                  color: bgColor)),
                                          SizedBox(
                                            height: media.height * 0.025,
                                          ),
                                          (_listSchedule)
                                              ? (_isLoadSchedule)
                                                  ? Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                          SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.5,
                                                              child: Lottie.asset(
                                                                  'assets/lottie/calendario-branco.json')),
                                                        ])
                                                  : (_data == 401)
                                                      ? Text('Permissão Negada',
                                                          style: GoogleFonts.poppins(
                                                              fontSize:
                                                                  media.width *
                                                                      0.04,
                                                              color:
                                                                  titleColor))
                                                      : (_data == 400)
                                                          ? Text(
                                                              'Erro Desconhecido',
                                                              style: GoogleFonts.poppins(
                                                                  fontSize:
                                                                      media.width *
                                                                          0.04,
                                                                  color:
                                                                      titleColor))
                                                          : Column(children: [
                                                              TextField(
                                                                onChanged: (value) =>
                                                                    _runFilter(
                                                                        value),
                                                                decoration:
                                                                    InputDecoration(
                                                                  suffixIcon: Icon(
                                                                      Icons
                                                                          .search,
                                                                      color:
                                                                          titleColor),
                                                                  hintText:
                                                                      'Pesquisar...',
                                                                  hintStyle: GoogleFonts
                                                                      .poppins(
                                                                          color:
                                                                              titleColor),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      width: 0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      width: 0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  filled: true,
                                                                  fillColor:
                                                                      secundaryBg,
                                                                ),
                                                                style: GoogleFonts
                                                                    .poppins(
                                                                        color:
                                                                            titleColor),
                                                              ),
                                                              SizedBox(
                                                                height: media
                                                                        .height *
                                                                    0.025,
                                                              ),
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Button(
                                                                        color: const Color(
                                                                            0xFF5b4c5e),
                                                                        borcolor:
                                                                            const Color(
                                                                                0xFF5b4c5e),
                                                                        width: media.width *
                                                                            0.4,
                                                                        onTap: () =>
                                                                            {
                                                                              setState(() {
                                                                                if (_page > 0) {
                                                                                  _page -= 1;
                                                                                  dataToShow = _data.sublist((_page * _perPage), ((_page * _perPage) + _perPage));
                                                                                }
                                                                              })
                                                                            },
                                                                        text:
                                                                            'anterior'),
                                                                    Button(
                                                                        width: media.width *
                                                                            0.4,
                                                                        onTap: () =>
                                                                            {
                                                                              setState(() {
                                                                                if (_page < (_data.length / _perPage)) {
                                                                                  _page += 1;
                                                                                  dataToShow = _data.sublist((_page * _perPage), ((_page * _perPage) + _perPage));
                                                                                }
                                                                              })
                                                                            },
                                                                        text:
                                                                            'próximo'),
                                                                  ]),
                                                              SizedBox(
                                                                height: media
                                                                        .height *
                                                                    0.025,
                                                              ),
                                                              (dataToShow.length ==
                                                                      0)
                                                                  ? Text(
                                                                      'Nenhum Contato Encontrado 😕',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize: media.width *
                                                                              0.05,
                                                                          color:
                                                                              bgColor))
                                                                  : ListView
                                                                      .builder(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              0),
                                                                      physics:
                                                                          const NeverScrollableScrollPhysics(),
                                                                      shrinkWrap:
                                                                          true,
                                                                      itemCount:
                                                                          dataToShow
                                                                              .length,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        return InkWell(
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                nameController.text = '${dataToShow[index].displayName}';
                                                                                phoneController.text = '${dataToShow[index].phones[0]}';
                                                                                _listSchedule = false;
                                                                              });
                                                                            },
                                                                            child:
                                                                                ListTile(
                                                                              title: Text('${dataToShow[index].displayName}', style: GoogleFonts.poppins(fontSize: media.width * 0.05, color: bgColor)),
                                                                              subtitle: Text('${dataToShow[index].phones[0]}', style: GoogleFonts.poppins(fontSize: media.width * 0.03, color: bgColor)),
                                                                            ));
                                                                      },
                                                                    )
                                                            ])
                                              : Column(children: [
                                                  TextFormField(
                                                    controller: nameController,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Nome ou Apelido *',
                                                      hintStyle:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  titleColor),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          width: 0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          width: 0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      filled: true,
                                                      fillColor: secundaryBg,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                        color: titleColor),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        media.height * 0.025,
                                                  ),
                                                  TextFormField(
                                                    controller: phoneController,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    inputFormatters: [
                                                      phoneFormatter
                                                    ],
                                                    keyboardType:
                                                        TextInputType.number,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      hintText: 'Telefone *',
                                                      hintStyle:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  titleColor),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          width: 0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          width: 0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      filled: true,
                                                      fillColor: secundaryBg,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                        color: titleColor),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        media.height * 0.025,
                                                  ),
                                                  TextFormField(
                                                    controller: emailController,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      hintText: 'Email',
                                                      hintStyle:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  titleColor),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          width: 0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          width: 0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      filled: true,
                                                      fillColor: secundaryBg,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                        color: titleColor),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        media.height * 0.025,
                                                  ),
                                                  TextFormField(
                                                    controller: cepController,
                                                    //textInputAction: TextInputAction.next,
                                                    inputFormatters: [
                                                      cepFormatter
                                                    ],
                                                    keyboardType:
                                                        TextInputType.number,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      hintText: 'CEP',
                                                      hintStyle:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  titleColor),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          width: 0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          width: 0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      filled: true,
                                                      fillColor: bgColor,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                        color: titleColor),
                                                  ),
                                                ]),
                                          SizedBox(
                                            height: media.height * 0.025,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              (_listSchedule)
                                                  ? SizedBox()
                                                  : Button(
                                                      onTap: () async {
                                                        // check if the required fields are empty
                                                        if (nameController.text
                                                                .isNotEmpty &&
                                                            phoneController.text
                                                                .isNotEmpty) {
                                                          // check if the cep field is empty, true: continue to stage 3
                                                          if (cepController.text
                                                              .isNotEmpty) {
                                                            setState(() {
                                                              stage = 1;
                                                              _setCep = true;
                                                            });
                                                            var data = await getAddress((cepFormatter
                                                                    .getUnmaskedText()
                                                                    .isEmpty)
                                                                ? cepController
                                                                    .text
                                                                    .replaceAll(
                                                                        "-", "")
                                                                : cepFormatter
                                                                    .getUnmaskedText());
                                                            if (data != 400) {
                                                              cityController
                                                                      .text =
                                                                  data[
                                                                      'localidade'];
                                                              stateController
                                                                      .text =
                                                                  data['uf'];
                                                              streetController
                                                                      .text =
                                                                  data[
                                                                      'logradouro'];
                                                              provinceController
                                                                      .text =
                                                                  data[
                                                                      'bairro'];
                                                              compController
                                                                      .text =
                                                                  data[
                                                                      'complemento'];
                                                              setState(() {
                                                                stage = 2;
                                                              });
                                                            } else {
                                                              setState(() {
                                                                stage = 0;
                                                              });
                                                              showDialog<
                                                                  String>(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    AlertDialog(
                                                                  title: const Icon(
                                                                      Icons
                                                                          .error,
                                                                      size: 40,
                                                                      color: Colors
                                                                          .red),
                                                                  content: Text(
                                                                      'CEP inválido',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: GoogleFonts.roboto(
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          fontSize:
                                                                              16)),
                                                                ),
                                                              );
                                                            }
                                                          } else {
                                                            setState(() {
                                                              stage = 3;
                                                              _setCep = false;
                                                            });
                                                          }
                                                        } else {
                                                          showDialog<String>(
                                                            context: context,
                                                            builder: (BuildContext
                                                                    context) =>
                                                                AlertDialog(
                                                              title: const Icon(
                                                                  Icons.error,
                                                                  size: 40,
                                                                  color: Colors
                                                                      .red),
                                                              content: Text(
                                                                  'Os Campos Nome e Telefone são requiridos',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: GoogleFonts.roboto(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16)),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      text: "continuar",
                                                    )
                                            ],
                                          )
                                        ])
                                  : (stage == 2)
                                      ? Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                              Text('Boa! 😀',
                                                  style: GoogleFonts.poppins(
                                                      fontSize:
                                                          media.width * 0.07,
                                                      color: bgColor)),
                                              Text(
                                                  'Verifique se o endereço está correto:',
                                                  style: GoogleFonts.poppins(
                                                      fontSize:
                                                          media.width * 0.05,
                                                      color: bgColor)),
                                              SizedBox(
                                                height: media.height * 0.025,
                                              ),
                                              TextFormField(
                                                controller: cityController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintText: 'Cidade',
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                          color: titleColor),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  filled: true,
                                                  fillColor: secundaryBg,
                                                ),
                                                style: GoogleFonts.poppins(
                                                    color: titleColor),
                                              ),
                                              SizedBox(
                                                height: media.height * 0.025,
                                              ),
                                              TextFormField(
                                                controller: stateController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintText: 'Estado',
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                          color: titleColor),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  filled: true,
                                                  fillColor: secundaryBg,
                                                ),
                                                style: GoogleFonts.poppins(
                                                    color: titleColor),
                                              ),
                                              SizedBox(
                                                height: media.height * 0.025,
                                              ),
                                              TextFormField(
                                                controller: streetController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintText: 'Logradouro',
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                          color: titleColor),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  filled: true,
                                                  fillColor: secundaryBg,
                                                ),
                                                style: GoogleFonts.poppins(
                                                    color: titleColor),
                                              ),
                                              SizedBox(
                                                height: media.height * 0.025,
                                              ),
                                              TextFormField(
                                                controller: numberController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintText: 'Número',
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                          color: titleColor),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  filled: true,
                                                  fillColor: secundaryBg,
                                                ),
                                                style: GoogleFonts.poppins(
                                                    color: titleColor),
                                              ),
                                              SizedBox(
                                                height: media.height * 0.025,
                                              ),
                                              TextFormField(
                                                controller: provinceController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintText: 'Bairro',
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                          color: titleColor),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  filled: true,
                                                  fillColor: bgColor,
                                                ),
                                                style: GoogleFonts.poppins(
                                                    color: titleColor),
                                              ),
                                              SizedBox(
                                                height: media.height * 0.025,
                                              ),
                                              TextFormField(
                                                controller: compController,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintText: 'Complemento',
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                          color: titleColor),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      width: 0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  filled: true,
                                                  fillColor: bgColor,
                                                ),
                                                style: GoogleFonts.poppins(
                                                    color: titleColor),
                                              ),
                                              SizedBox(
                                                height: media.height * 0.025,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Button(
                                                    color:
                                                        const Color(0xFF5b4c5e),
                                                    borcolor:
                                                        const Color(0xFF5b4c5e),
                                                    onTap: () {
                                                      setState(() {
                                                        stage = 0;
                                                      });
                                                    },
                                                    text: "voltar",
                                                  ),
                                                  Button(
                                                    onTap: () async {
                                                      if (cityController
                                                              .text.isNotEmpty &&
                                                          stateController
                                                              .text.isNotEmpty &&
                                                          streetController.text
                                                              .isNotEmpty &&
                                                          numberController.text
                                                              .isNotEmpty &&
                                                          provinceController
                                                              .text
                                                              .isNotEmpty) {
                                                        setState(() {
                                                          stage = 3;
                                                        });
                                                      } else {
                                                        showDialog<String>(
                                                          context: context,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              AlertDialog(
                                                            title: const Icon(
                                                                Icons.error,
                                                                size: 40,
                                                                color:
                                                                    Colors.red),
                                                            content: Text(
                                                                'Os campos Cidade, Estado, Logradouro, Número e Bairro são requiridos',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: GoogleFonts.roboto(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        16)),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    text: "continuar",
                                                  )
                                                ],
                                              )
                                            ])
                                      : (stage == 3)
                                          ? Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                  Text('Show! 😎',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize:
                                                                  media.width *
                                                                      0.07,
                                                              color: bgColor)),
                                                  Text(
                                                      'Defina a Data e Hora do seu Lembrete:',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize:
                                                                  media.width *
                                                                      0.05,
                                                              color: bgColor)),
                                                  SizedBox(
                                                    height:
                                                        media.height * 0.025,
                                                  ),
                                                  DateTimeField(
                                                    controller:
                                                        dateTimeController,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      hintText: 'Data e Hora *',
                                                      hintStyle:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  titleColor),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          width: 0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          width: 0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      filled: true,
                                                      fillColor: secundaryBg,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                        color: titleColor),
                                                    format: format,
                                                    onShowPicker: (context,
                                                        currentValue) async {
                                                      final date =
                                                          await showDatePicker(
                                                              context: context,
                                                              firstDate:
                                                                  DateTime
                                                                      .now(),
                                                              initialDate:
                                                                  currentValue ??
                                                                      DateTime
                                                                          .now(),
                                                              lastDate:
                                                                  DateTime(
                                                                      2100));
                                                      if (date != null) {
                                                        final time =
                                                            await showTimePicker(
                                                          context: context,
                                                          initialTime: TimeOfDay
                                                              .fromDateTime(
                                                                  currentValue ??
                                                                      DateTime
                                                                          .now()),
                                                        );
                                                        return DateTimeField
                                                            .combine(
                                                                date, time);
                                                      } else {
                                                        return currentValue;
                                                      }
                                                    },
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        media.height * 0.025,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Button(
                                                        color: const Color(
                                                            0xFF5b4c5e),
                                                        borcolor: const Color(
                                                            0xFF5b4c5e),
                                                        onTap: () {
                                                          setState(() {
                                                            if (_setCep ==
                                                                false) {
                                                              stage = 0;
                                                            } else {
                                                              stage = 2;
                                                            }
                                                          });
                                                        },
                                                        text: "voltar",
                                                      ),
                                                      Button(
                                                        onTap: () async {
                                                          if (dateTimeController
                                                              .text
                                                              .isNotEmpty) {
                                                            final formatedDate =
                                                                DateTime.parse(
                                                                    "${dateTimeController.text.split(", ")[0].substring(6, 10)}${dateTimeController.text.split(", ")[0].substring(3, 5)}${dateTimeController.text.split(", ")[0].substring(0, 2)}T${dateTimeController.text.split(", ")[1].replaceAll(':', '')}");

                                                            final now = DateTime
                                                                    .now()
                                                                .add(
                                                                    const Duration(
                                                                        minutes:
                                                                            1));
                                                            if (formatedDate
                                                                    .compareTo(
                                                                        now) >
                                                                0) {
                                                              setState(() {
                                                                stage = 4;
                                                              });
                                                            } else {
                                                              showDialog<
                                                                  String>(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    AlertDialog(
                                                                  title: const Icon(
                                                                      Icons
                                                                          .error,
                                                                      size: 40,
                                                                      color: Colors
                                                                          .red),
                                                                  content: Text(
                                                                      'O campo Hora e Data deve ser definido para ao menos 1 minuto no futuro',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: GoogleFonts.roboto(
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          fontSize:
                                                                              16)),
                                                                ),
                                                              );
                                                            }
                                                          } else {
                                                            showDialog<String>(
                                                              context: context,
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  AlertDialog(
                                                                title: const Icon(
                                                                    Icons.error,
                                                                    size: 40,
                                                                    color: Colors
                                                                        .red),
                                                                content: Text(
                                                                    'O campo Hora e Data é requirido',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: GoogleFonts.roboto(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            16)),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        text: "continuar",
                                                      )
                                                    ],
                                                  )
                                                ])
                                          : (stage == 4)
                                              ? Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                      Text('Quase Lá! 😁',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize:
                                                                      media.width *
                                                                          0.07,
                                                                  color:
                                                                      bgColor)),
                                                      Text(
                                                          'Deseja definir uma imagem para o Lembrete?',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize:
                                                                      media.width *
                                                                          0.05,
                                                                  color:
                                                                      bgColor)),
                                                      SizedBox(
                                                        height:
                                                            media.height * 0.05,
                                                      ),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Container(
                                                              height:
                                                                  media.width *
                                                                      0.4,
                                                              width:
                                                                  media.width *
                                                                      0.4,
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color:
                                                                      bgColor,
                                                                  image: (imageFile ==
                                                                          null)
                                                                      ? const DecorationImage(
                                                                          image: AssetImage(
                                                                              'assets/images/user.png'),
                                                                          fit: BoxFit
                                                                              .cover)
                                                                      : DecorationImage(
                                                                          image: FileImage(File(
                                                                              imageFile)),
                                                                          fit: BoxFit
                                                                              .cover)),
                                                            ),
                                                          ]),
                                                      SizedBox(
                                                        height: media.height *
                                                            0.025,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  pickImageFromCamera();
                                                                },
                                                                child:
                                                                    Container(
                                                                        height: media.width *
                                                                            0.2,
                                                                        width: media.width *
                                                                            0.3,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                bgColor,
                                                                            border:
                                                                                Border.all(color: bgColor, width: 1.2),
                                                                            borderRadius: BorderRadius.circular(12)),
                                                                        child: Icon(
                                                                          Icons
                                                                              .camera_alt_outlined,
                                                                          color:
                                                                              titleColor,
                                                                          size: media.width *
                                                                              0.1,
                                                                        )),
                                                              ),
                                                              SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.01,
                                                              ),
                                                              Text(
                                                                "Câmera",
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        media.width *
                                                                            0.04,
                                                                    color:
                                                                        bgColor),
                                                              )
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  pickImageFromGallery();
                                                                },
                                                                child:
                                                                    Container(
                                                                        height: media.width *
                                                                            0.2,
                                                                        width: media.width *
                                                                            0.3,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                bgColor,
                                                                            border:
                                                                                Border.all(color: bgColor, width: 1.2),
                                                                            borderRadius: BorderRadius.circular(12)),
                                                                        child: Icon(
                                                                          Icons
                                                                              .image_outlined,
                                                                          color:
                                                                              titleColor,
                                                                          size: media.width *
                                                                              0.1,
                                                                        )),
                                                              ),
                                                              SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.01,
                                                              ),
                                                              Text(
                                                                "Galeria",
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        media.width *
                                                                            0.04,
                                                                    color:
                                                                        bgColor),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.height * 0.05,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Button(
                                                            color: const Color(
                                                                0xFF5b4c5e),
                                                            borcolor:
                                                                const Color(
                                                                    0xFF5b4c5e),
                                                            onTap: () {
                                                              setState(() {
                                                                stage = 3;
                                                              });
                                                            },
                                                            text: "voltar",
                                                          ),
                                                          Button(
                                                            onTap: () async {
                                                              setState(() {
                                                                stage = 1;
                                                              });
                                                              final formatedDate =
                                                                  "${dateTimeController.text.split(", ")[0].substring(6, 10)}${dateTimeController.text.split(", ")[0].substring(3, 5)}${dateTimeController.text.split(", ")[0].substring(0, 2)}T${dateTimeController.text.split(", ")[1].replaceAll(':', '')}";

                                                              final now = DateTime
                                                                      .now()
                                                                  .add(const Duration(
                                                                      minutes:
                                                                          1));

                                                              // se estiver editando um lembrete
                                                              if (widget
                                                                      .editTodo !=
                                                                  null) {
                                                                if (DateTime.parse(
                                                                            formatedDate)
                                                                        .compareTo(
                                                                            now) >
                                                                    0) {
                                                                  editData[
                                                                          'id'] =
                                                                      widget
                                                                          .editTodo;
                                                                  editData[
                                                                          'notId'] =
                                                                      '$notEdit';
                                                                  editData[
                                                                          'name'] =
                                                                      nameController
                                                                          .text;
                                                                  editData[
                                                                          'email'] =
                                                                      emailController
                                                                          .text;
                                                                  editData[
                                                                      'cel'] = (phoneFormatter
                                                                          .getUnmaskedText()
                                                                          .isEmpty)
                                                                      ? phoneController
                                                                          .text
                                                                      : phoneFormatter
                                                                          .getUnmaskedText();
                                                                  editData[
                                                                          'cep'] =
                                                                      cepController
                                                                          .text;
                                                                  editData[
                                                                          'city'] =
                                                                      cityController
                                                                          .text;
                                                                  editData[
                                                                          'state'] =
                                                                      stateController
                                                                          .text;
                                                                  editData[
                                                                          'street'] =
                                                                      streetController
                                                                          .text;
                                                                  editData[
                                                                          'streetNumber'] =
                                                                      numberController
                                                                          .text;
                                                                  editData[
                                                                          'province'] =
                                                                      provinceController
                                                                          .text;
                                                                  editData[
                                                                          'comp'] =
                                                                      compController
                                                                          .text;
                                                                  editData[
                                                                          'date'] =
                                                                      dateTimeController
                                                                          .text
                                                                          .split(
                                                                              ", ")[0];
                                                                  editData[
                                                                          'time'] =
                                                                      dateTimeController
                                                                          .text
                                                                          .split(
                                                                              ", ")[1];
                                                                  editData[
                                                                          'imagePath'] =
                                                                      imageFile;
                                                                  editData[
                                                                          'isActive'] =
                                                                      true;

                                                                  await _db
                                                                      .collection(
                                                                          'reminders')
                                                                      .doc(widget
                                                                          .editTodo)
                                                                      .set(
                                                                          editData);

                                                                  await NotificationApi
                                                                      .cancelNotification(
                                                                          notEdit!);

                                                                  await NotificationApi.showScheduleNotification(
                                                                      id:
                                                                          notEdit!,
                                                                      title:
                                                                          "Lembrete",
                                                                      body:
                                                                          "Você tem que ligar para ${nameController.text}",
                                                                      payload: (phoneFormatter
                                                                              .getUnmaskedText()
                                                                              .isEmpty)
                                                                          ? phoneController
                                                                              .text
                                                                          : phoneFormatter
                                                                              .getUnmaskedText(),
                                                                      scheduledDate:
                                                                          DateTime.parse(
                                                                              formatedDate));

                                                                  await Future.delayed(
                                                                      const Duration(
                                                                          seconds:
                                                                              1));

                                                                  await NotificationApi
                                                                      .showNotification(
                                                                    title:
                                                                        "Lembrete Editado!",
                                                                    body:
                                                                        "Ligar para ${nameController.text} na data ${dateTimeController.text.split(", ")[0]} às ${dateTimeController.text.split(", ")[1]}",
                                                                  );

                                                                  if (!mounted) {
                                                                    return;
                                                                  }
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              const ListContact()));
                                                                } else {
                                                                  setState(() {
                                                                    stage = 3;
                                                                  });
                                                                  showDialog<
                                                                      String>(
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        AlertDialog(
                                                                      title: const Icon(
                                                                          Icons
                                                                              .error,
                                                                          size:
                                                                              40,
                                                                          color:
                                                                              Colors.red),
                                                                      content: Text(
                                                                          'O campo Data e Hora deve ser definido para ao menos 1 minuto no futuro',
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style: GoogleFonts.roboto(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 16)),
                                                                    ),
                                                                  );
                                                                }
                                                              } else {
                                                                var data = Reminder(
                                                                    name: nameController
                                                                        .text,
                                                                    email: emailController
                                                                        .text,
                                                                    cel: (phoneFormatter
                                                                            .getUnmaskedText()
                                                                            .isEmpty)
                                                                        ? phoneController
                                                                            .text
                                                                        : phoneFormatter
                                                                            .getUnmaskedText(),
                                                                    cep: cepController
                                                                        .text,
                                                                    city: cityController
                                                                        .text,
                                                                    state: stateController
                                                                        .text,
                                                                    street: streetController
                                                                        .text,
                                                                    streetNumber:
                                                                        numberController
                                                                            .text,
                                                                    province:
                                                                        provinceController
                                                                            .text,
                                                                    comp: compController
                                                                        .text,
                                                                    date: dateTimeController
                                                                            .text
                                                                            .split(", ")[
                                                                        0],
                                                                    time: dateTimeController
                                                                        .text
                                                                        .split(", ")[1],
                                                                    isActive: true);
                                                                var response =
                                                                    await createNewReminder(
                                                                        data,
                                                                        imageFile);

                                                                if (response ==
                                                                    200) {
                                                                  setState(() {
                                                                    stage = 1;
                                                                  });
                                                                  await Future.delayed(
                                                                      const Duration(
                                                                          seconds:
                                                                              1));
                                                                  await NotificationApi
                                                                      .showNotification(
                                                                    title:
                                                                        "Lembrete Criado!",
                                                                    body:
                                                                        "Ligar para ${nameController.text} na data ${dateTimeController.text.split(", ")[0]} às ${dateTimeController.text.split(", ")[1]}",
                                                                  );
                                                                  if (!mounted) {
                                                                    return;
                                                                  }
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              const ListContact()));
                                                                } else if (response ==
                                                                    401) {
                                                                  setState(() {
                                                                    stage = 3;
                                                                  });
                                                                  showDialog<
                                                                      String>(
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        AlertDialog(
                                                                      title: const Icon(
                                                                          Icons
                                                                              .error,
                                                                          size:
                                                                              40,
                                                                          color:
                                                                              Colors.red),
                                                                      content: Text(
                                                                          'O campo Data e Hora deve ser definido para ao menos 1 minuto no futuro',
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style: GoogleFonts.roboto(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 16)),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  // some error
                                                                  setState(() {
                                                                    stage = 4;
                                                                  });
                                                                }
                                                              }
                                                            },
                                                            text: (imageFile ==
                                                                    null)
                                                                ? "não, obrigado"
                                                                : "continuar",
                                                          )
                                                        ],
                                                      )
                                                    ])
                                              : Column(),
                        )
                      ])),
              SizedBox(
                height: media.height * 0.05,
              ),
            ],
          ),
        ),
      ),
    ])));
  }
}
