import '/components/button/button_widget.dart';
import '/components/form_section/form_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/components/upload_box/upload_box_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'worker_registration_widget.dart' show WorkerRegistrationWidget;
import 'package:flutter/material.dart';

class WorkerRegistrationModel
    extends FlutterFlowModel<WorkerRegistrationWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for FormSection.
  late FormSectionModel formSectionModel1;
  // Model for TextField.
  late TextFieldModel textFieldModel1;
  // Model for TextField.
  late TextFieldModel textFieldModel2;
  // Model for TextField.
  late TextFieldModel textFieldModel3;
  // Model for FormSection.
  late FormSectionModel formSectionModel2;
  // Model for TextField.
  late TextFieldModel textFieldModel4;
  // Model for TextField.
  late TextFieldModel textFieldModel5;
  // Model for FormSection.
  late FormSectionModel formSectionModel3;
  // State field(s) for Dropdown widget.
  String? dropdownValue;
  FormFieldController<String>? dropdownValueController;
  // Model for FormSection.
  late FormSectionModel formSectionModel4;
  // Model for TextField.
  late TextFieldModel textFieldModel6;
  // Model for UploadBox.
  late UploadBoxModel uploadBoxModel1;
  // Model for UploadBox.
  late UploadBoxModel uploadBoxModel2;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    formSectionModel1 = createModel(context, () => FormSectionModel());
    textFieldModel1 = createModel(context, () => TextFieldModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    textFieldModel3 = createModel(context, () => TextFieldModel());
    formSectionModel2 = createModel(context, () => FormSectionModel());
    textFieldModel4 = createModel(context, () => TextFieldModel());
    textFieldModel5 = createModel(context, () => TextFieldModel());
    formSectionModel3 = createModel(context, () => FormSectionModel());
    formSectionModel4 = createModel(context, () => FormSectionModel());
    textFieldModel6 = createModel(context, () => TextFieldModel());
    uploadBoxModel1 = createModel(context, () => UploadBoxModel());
    uploadBoxModel2 = createModel(context, () => UploadBoxModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    formSectionModel1.dispose();
    textFieldModel1.dispose();
    textFieldModel2.dispose();
    textFieldModel3.dispose();
    formSectionModel2.dispose();
    textFieldModel4.dispose();
    textFieldModel5.dispose();
    formSectionModel3.dispose();
    formSectionModel4.dispose();
    textFieldModel6.dispose();
    uploadBoxModel1.dispose();
    uploadBoxModel2.dispose();
    buttonModel.dispose();
  }
}
