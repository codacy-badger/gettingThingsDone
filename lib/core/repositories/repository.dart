import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gtd/core/models/gtd_element.dart';
import 'package:gtd/core/models/gtd_project.dart';

abstract class Repository {}

abstract class ElementRepository {
  Future<Stream<List<GTDElement>>> getElements();
  Future<void> createElement(GTDElement element);
  Future<void> updateElement(GTDElement element);
  Future<void> deleteElement(GTDElement element);
  Future uploadFile(File file, String uuid);
  Future downloadFileUrl(GTDElement element);
  Future<String> getCurrentUserId();
}

abstract class ProjectRepository {
  Future<QuerySnapshot> getProject(String summary);
  Future<Stream<List<Project>>> getProjects();
  Future<void> createProject({Project project});
  Future<void> updateProject({Project project, String id});
  Future<void> deleteProject(Project project);
}
