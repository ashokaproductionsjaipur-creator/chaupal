import '/components/audio_recorder/audio_recorder_widget.dart';
import '/components/button/button_widget.dart';
import '/components/form_label/form_label_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/components/upload_box2/upload_box2_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'create_job_post_widget.dart' show CreateJobPostWidget;
import 'package:flutter/material.dart';

class CreateJobPostModel extends FlutterFlowModel<CreateJobPostWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for FormLabel.
  late FormLabelModel formLabelModel1;
  // Model for TextField.
  late TextFieldModel textFieldModel1;
  // Model for FormLabel.
  late FormLabelModel formLabelModel2;
  // State field(s) for Dropdown widget.
  String? dropdownValue;
  FormFieldController<String>? dropdownValueController;
  // Model for FormLabel.
  late FormLabelModel formLabelModel3;
  // Model for UploadBox.
  late UploadBox2Model uploadBoxModel;
  // Model for AudioRecorder.
  late AudioRecorderModel audioRecorderModel;
  // Model for FormLabel.
  late FormLabelModel formLabelModel4;
  // Model for TextField.
  late TextFieldModel textFieldModel2;
  // Model for FormLabel.
  late FormLabelModel formLabelModel5;
  // Model for TextField.
  late TextFieldModel textFieldModel3;
  // Model for FormLabel.
  late FormLabelModel formLabelModel6;
  // Model for TextField.
  late TextFieldModel textFieldModel4;
  // Model for TextField.
  late TextFieldModel textFieldModel5;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    formLabelModel1 = createModel(context, () => FormLabelModel());
    textFieldModel1 = createModel(context, () => TextFieldModel());
    formLabelModel2 = createModel(context, () => FormLabelModel());
    formLabelModel3 = createModel(context, () => FormLabelModel());
    uploadBoxModel = createModel(context, () => UploadBox2Model());
    audioRecorderModel = createModel(context, () => AudioRecorderModel());
    formLabelModel4 = createModel(context, () => FormLabelModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    formLabelModel5 = createModel(context, () => FormLabelModel());
    textFieldModel3 = createModel(context, () => TextFieldModel());
    formLabelModel6 = createModel(context, () => FormLabelModel());
    textFieldModel4 = createModel(context, () => TextFieldModel());
    textFieldModel5 = createModel(context, () => TextFieldModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    formLabelModel1.dispose();
    textFieldModel1.dispose();
    formLabelModel2.dispose();
    formLabelModel3.dispose();
    uploadBoxModel.dispose();
    audioRecorderModel.dispose();
    formLabelModel4.dispose();
    textFieldModel2.dispose();
    formLabelModel5.dispose();
    textFieldModel3.dispose();
    formLabelModel6.dispose();
    textFieldModel4.dispose();
    textFieldModel5.dispose();
    buttonModel.dispose();
  }
}
