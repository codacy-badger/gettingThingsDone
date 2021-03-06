import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gtd/capture/capture_bloc.dart';
import 'package:gtd/capture/capture_event.dart';
import 'package:gtd/capture/capture_state.dart';
import 'package:gtd/common/attached_image_card.dart';
import 'package:gtd/core/core_blocs/navigator_bloc.dart';
import 'package:gtd/core/models/gtd_element.dart';
import 'package:gtd/home/elements/element_bloc.dart';

enum DatePeriod { WEEK, DAY }

class AdvancedProcessForm extends StatefulWidget {

  final GTDElement _element;

  AdvancedProcessForm(
      {@required element})
      : assert(element != null),
        _element = element;

  @override
  State<StatefulWidget> createState() {
    return AdvancedProcessFormState();
  }
}

class AdvancedProcessFormState extends State<AdvancedProcessForm> {
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  ElementBloc _elementBloc;
  CaptureBloc _captureBloc;

  bool isRecurrent = false;
  bool isClosing = false;
  int dropdownDayValue;
  String dropdownPeriodValue;
  Image _attachedImage;
  List<Chip> contextList = [];
  DateTime selectedDate = DateTime.now();
  DatePeriod dropdownPeriod;
  String _imageFileName;
  File _imageFile;

  Chip ContextChip;

  bool get isPopulated => _summaryController.text.isNotEmpty;
  bool get isContextPopulated => _contextController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _elementBloc = BlocProvider.of<ElementBloc>(context);
    _captureBloc = BlocProvider.of<CaptureBloc>(context);
    _summaryController.addListener(_onSummaryChanged);
    _descriptionController.addListener(_onDescriptionChanged);
    _projectController.addListener(_onProjectChanged);
    _contextController.addListener(_onContextChanged);
    _dateController.addListener(_onDateChanged);
    _summaryController.text = widget._element.summary;
    _descriptionController.text = widget._element.description;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CaptureBloc, CaptureState>(builder: (context, state) {
      
      
      if ((state is EmptyState || state is Captured) && widget._element.imageRemotePath != null && !isClosing) {
        _captureBloc.add(DownloadAttachedImage(widget._element));
      }

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Colors.orange[600],
                Colors.orange[300],
              ]),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            bottomOpacity: 0.0,
            title: Text('Procesar'),
            leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  isClosing = true;
                  BlocProvider.of<CaptureBloc>(context).add(ClearForm());
                  BlocProvider.of<NavigatorBloc>(context)
                      .add(NavigatorActionPop());
                }),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              child: ListView(
                shrinkWrap: true,
                controller: ScrollController(),
                children: [
                  TextFormField(
                    controller: _summaryController,
                    style:  TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                    decoration: InputDecoration(
                      icon: Icon(Icons.edit, color: Colors.white),
                      labelText: 'Título',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white),
                      errorStyle: TextStyle(color: Colors.white),
                      errorBorder:  UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white,
                            width: 1.0,
                            style: BorderStyle.solid),
                      ),
                      enabledBorder:  UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white,
                            width: 1.0,
                            style: BorderStyle.solid),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    autovalidate: true,
                    validator: (_) {
                      return !isPopulated ? 'Título no válido.' : null;
                    },
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    style:  TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                    maxLines: null,
                    decoration: InputDecoration(
                      icon: Icon(Icons.description, color: Colors.white),
                      labelText: 'Descripción',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder:  UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white,
                            width: 1.0,
                            style: BorderStyle.solid),
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    autocorrect: false,
                    autovalidate: true,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(),
                      FlatButton(
                          padding: const EdgeInsets.all(16.0),
                          onPressed: _onPhotoPressed,
                          child: Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                          )),
                      Spacer(),
                      FlatButton(
                          padding: const EdgeInsets.all(16.0),
                          onPressed: () {},
                          child: Icon(
                            Icons.mic,
                            color: Colors.white,
                          )),
                      Spacer(),
                    ],
                  ),
                  state is ImageDownloaded
                      ? _showDownloadedImage(state)
                      : Container(),
                  state is ImageAttached
                      ? _showAttachedImage(state)
                      : Container(),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _projectController,
                    style:  TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                    decoration: InputDecoration(
                      icon: Icon(Icons.lightbulb_outline, color: Colors.white),
                      labelText: 'Proyecto',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder:  UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white,
                            width: 1.0,
                            style: BorderStyle.solid),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    autovalidate: true,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _contextController,
                    style:  TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                    decoration: InputDecoration(
                        icon: Icon(Icons.dialpad, color: Colors.white),
                        labelText: 'Contexto',
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder:  UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                              style: BorderStyle.solid),
                        ),
                        suffix: FlatButton(
                          onPressed: isContextPopulated
                              ? () {
                                  _addChip(_contextController.text);
                                }
                              : null,
                          child: Text('AÑADIR',
                              style: TextStyle(color: Colors.white)),
                        )),
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    autovalidate: true,
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: contextList.toList()),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _dateController,
                    style:  TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                    decoration: InputDecoration(
                      icon: Icon(Icons.calendar_today, color: Colors.white),
                      labelText: 'Fecha ocurrencia',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder:  UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white,
                            width: 1.0,
                            style: BorderStyle.solid),
                      ),
                    ),
                    onTap: () => _selectDate(context),
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    autovalidate: true,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: isRecurrent,
                        onChanged: _checkBoxMarked,
                        activeColor: Colors.transparent,
                        checkColor: Colors.white,
                      ),
                      Text(
                        'Es un evento recurrente',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  isRecurrent ? _showRecurrentField() : Container(),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    color: Colors.white,
                    onPressed: isPopulated ? _onFormSubmitted : null,
                    child: Text('Procesar'),
                  ),
                  FlatButton(
                    onPressed: isPopulated ? _onMoveToReference : null,
                    child: Text('Mover a Referencias',
                        style: TextStyle(color: Colors.white)),
                  ),
                  FlatButton(
                    onPressed: isPopulated ? _onMoveToWaitingFor : null,
                    child: Text('Esperando por...',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _descriptionController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  void _onPhotoPressed() async {
    BlocProvider.of<NavigatorBloc>(context).add(OpenCamera());
  }

  void _onSummaryChanged() {}

  void _onDescriptionChanged() {}

  void _onProjectChanged() {}

  void _onContextChanged() {}

  void _onDateChanged() {}

  void _onMoveToReference() {
    BlocProvider.of<ElementBloc>(context).add(MoveToReference(widget._element));
    BlocProvider.of<NavigatorBloc>(context).add(NavigatorActionPop());
  }

  void _onMoveToWaitingFor() {}

  void _onFormSubmitted() {
    _elementBloc.add(
        AddTitleToElement(widget._element, _summaryController.text));
    _elementBloc.add(AddDescriptionToElement(
        widget._element, _descriptionController.text));
    _elementBloc.add(
        AddProjectToElement(widget._element, _projectController.text));
    String contexts = "";
    Text label;
    contextList.forEach(
        (chip) => {label = chip.label as Text, contexts += label.data + ","});
    _elementBloc.add(AddContextToElement(widget._element, contexts));
    _elementBloc.add(AddDateToElement(widget._element, _dateController.text));
    _elementBloc.add(AddImageToElement(fileName: _imageFileName, imageFile: _imageFile, takenImage: _attachedImage, element: widget._element));
    if (isRecurrent) {
      _elementBloc.add(AddRecurrencyToElement(
          widget._element, dropdownDayValue, dropdownPeriod));
    }
    _elementBloc.add(Process(widget._element));
    _captureBloc.add(ClearForm());
    BlocProvider.of<NavigatorBloc>(context).add(NavigatorActionPop());
  }

  void _addChip(String chipLabel) => setState(() => {
        ContextChip = Chip(
            label: Text(chipLabel),
            backgroundColor: Colors.white,
            deleteIconColor: Colors.orange,
            onDeleted: () {
              setState(() {
                contextList.removeWhere((Chip entryChip) {
                  return (entryChip.label as Text).toString() == chipLabel;
                });
              });
            }),
        contextList.add(ContextChip),
        _contextController.clear()
      });

  void _checkBoxMarked(bool Value) => setState(() {
        isRecurrent = Value;
      });

  Widget _showAttachedImage(ImageAttached imageState) {
    _attachedImage = imageState.attachedImage;
    _imageFileName = imageState.fileName;
    _imageFile = imageState.imageFile;
    return AttachedImageCard(
      image: imageState.attachedImage,
      fileName: imageState.fileName,
      element: widget._element,
    );
  }

    Widget _showDownloadedImage(ImageDownloaded imageState) {
    _attachedImage = imageState.attachedImage;
    _imageFileName = imageState.fileName;
    _imageFile = imageState.imageFile;
    return AttachedImageCard(
      image: imageState.attachedImage,
      fileName: imageState.fileName,
      element: widget._element,
    );
  }

  Widget _showRecurrentField() {
    var list =  List<int>.generate(31, (i) => i + 1);

    return Row(
      children: <Widget>[
        Text('Ocurre cada ', style: TextStyle(color: Colors.white)),
        DropdownButton<int>(
          value: dropdownDayValue,
          underline: Container(
            height: 2,
            color: Colors.white,
          ),
          onChanged: (int Value) {
            setState(() {
              dropdownDayValue = Value;
            });
          },
          items: list.map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(value.toString()),
            );
          }).toList(),
        ),
        Text(' '),
        DropdownButton<String>(
          value: dropdownPeriodValue,
          underline: Container(
            height: 2,
            color: Colors.white,
          ),
          onChanged: (String Value) {
            setState(() {
              dropdownPeriodValue = Value;
              dropdownPeriod = dropdownPeriodValue == 'Semanas'
                  ? DatePeriod.WEEK
                  : DatePeriod.DAY;
            });
          },
          items: <String>['Dias', 'Semanas']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        )
      ],
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        locale: const Locale('es', 'ES'),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = selectedDate.toLocal().toString().split(' ')[0];
      });
    }
  }
}
