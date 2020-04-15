import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gtd/capture/capture_bloc.dart';
import 'package:gtd/capture/capture_event.dart';
import 'package:gtd/capture/capture_state.dart';
import 'package:gtd/common/attached_image_card.dart';
import 'package:gtd/core/core_blocs/navigator_bloc.dart';
import 'package:gtd/core/repositories/remote/user_repository.dart';

class CaptureForm extends StatefulWidget {
  final UserRepository _userRepository;
  final bool _isEditing;

  CaptureForm({@required userRepository, @required isEditing})
      : assert(userRepository != null),
        assert(isEditing != null),
        _isEditing = isEditing,
        _userRepository = userRepository;

  @override
  State<StatefulWidget> createState() {
    return CaptureFormState(
        userRepository: _userRepository, isEditing: _isEditing);
  }
}

class CaptureFormState extends State<CaptureForm> {
  final UserRepository _userRepository;

  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  CaptureBloc _captureBloc;

  bool isRecurrent = false;
  bool _isEditing;
  int dropdownDayValue;
  String dropdownPeriodValue;
  DateTime selectedDate = DateTime.now();

  bool get isPopulated => _summaryController.text.isNotEmpty;

  CaptureFormState({@required userRepository, @required isEditing})
      : assert(userRepository != null),
        assert(isEditing != null),
        _isEditing = isEditing,
        _userRepository = userRepository;

  @override
  void initState() {
    super.initState();
    _captureBloc = BlocProvider.of<CaptureBloc>(context);
    _summaryController.addListener(_onSummaryChanged);
    _descriptionController.addListener(_onDescriptionChanged);
    _projectController.addListener(_onProjectChanged);
    _contextController.addListener(_onContextChanged);
    _dateController.addListener(_onDateChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CaptureBloc, CaptureState>(builder: (context, state) {
      return Scaffold(
        backgroundColor: Colors.orange,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          bottomOpacity: 0.0,
          title: Text('Capturar'),
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
                  style: new TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.white),
                  decoration: InputDecoration(
                    icon: Icon(Icons.edit, color: Colors.white),
                    labelText: 'Título',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: new UnderlineInputBorder(
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
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _descriptionController,
                  style: new TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.white),
                  maxLines: null,
                  decoration: InputDecoration(
                    icon: Icon(Icons.description, color: Colors.white),
                    labelText: 'Descripción',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: new UnderlineInputBorder(
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
                state is ImageAttached
                    ? AttachedImageCard(
                        image: state.attachedImage, fileName: state.fileName)
                    : Container(),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _projectController,
                  style: new TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.white),
                  decoration: InputDecoration(
                    icon: Icon(Icons.lightbulb_outline, color: Colors.white),
                    labelText: 'Proyecto',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: new UnderlineInputBorder(
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
                  style: new TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.white),
                  decoration: InputDecoration(
                    icon: Icon(Icons.dialpad, color: Colors.white),
                    labelText: 'Contexto',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: new UnderlineInputBorder(
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
                  controller: _dateController,
                  style: new TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.white),
                  decoration: InputDecoration(
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                    labelText: 'Fecha ocurrencia',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: new UnderlineInputBorder(
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
                  child: Text('Crear'),
                ),
              ],
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
    BlocProvider.of<NavigatorBloc>(context).add(NavigatorAction.OpenCamera);
  }

  void _onSummaryChanged() {}

  void _onDescriptionChanged() {}

  void _onProjectChanged() {}

  void _onContextChanged() {}

  void _onDateChanged() {}

  void _onFormSubmitted() {
    _captureBloc.add(Capture(
        summary: _summaryController.text,
        description: _descriptionController.text,
        project: _projectController.text));
    BlocProvider.of<NavigatorBloc>(context)
        .add(NavigatorAction.NavigatorActionPop);
  }

  void _checkBoxMarked(bool newValue) => setState(() {
        isRecurrent = newValue;
      });

  Widget _showRecurrentField() {
    var list = new List<int>.generate(31, (i) => i + 1);

    return Row(
      children: <Widget>[
        Text('Ocurre cada ', style: TextStyle(color: Colors.white)),
        DropdownButton<int>(
          value: dropdownDayValue,
          underline: Container(
            height: 2,
            color: Colors.white,
          ),
          onChanged: (int newValue) {
            setState(() {
              dropdownDayValue = newValue;
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
          onChanged: (String newValue) {
            setState(() {
              dropdownPeriodValue = newValue;
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
        // locale: Locale.fromSubtags(languageCode: 'SP'),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _dateController.text = selectedDate.toLocal().toString().split(' ')[0];
      });
  }
}
