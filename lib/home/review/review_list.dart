import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gtd/core/models/gtd_element.dart';
import 'package:gtd/core/models/gtd_project.dart';
import 'package:gtd/core/repositories/local/local_state_bloc.dart';
import 'package:gtd/home/review/review_card.dart';

class ReviewList extends StatefulWidget {
  final List<GTDElement> elements;
  final List<Project> projects;

  ReviewList({@required this.elements, @required this.projects});

  @override
  _ReviewListState createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<LocalStatusBloc>(context).add(LoadLocalSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          BlocBuilder<LocalStatusBloc, LocalState>(builder: (context, state) {
            if (state is SettingsLoaded) {
              return _showNotificationsSettings();
            } else {
              return Container();
            }
          }),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.projects.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index < widget.projects.length) {
                    print(
                        'creando tarjeta para el proyecto ${widget.projects[index].title}');
                    return ReviewCard(
                        project: widget.projects[index],
                        elements: widget.elements);
                  } else {
                    print('creando tarjeta para los elementos sin proyecto');
                    return ReviewCard(project: null, elements: widget.elements);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showNotificationsSettings() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Ajustes de revision: '),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text(
                  'Recordatorio \nSemanal',
                  textAlign: TextAlign.center,
                ),
                onPressed: () {},
              ),
              RaisedButton(
                child: Text(
                  'Recordatorio \nMensual',
                  textAlign: TextAlign.center,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
