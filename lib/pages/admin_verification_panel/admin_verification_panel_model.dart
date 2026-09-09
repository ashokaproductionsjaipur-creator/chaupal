import '/components/button/button_widget.dart';
import '/components/stat_box2/stat_box2_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/components/verification_card/verification_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'admin_verification_panel_widget.dart' show AdminVerificationPanelWidget;
import 'package:flutter/material.dart';

class AdminVerificationPanelModel
    extends FlutterFlowModel<AdminVerificationPanelWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for StatBox.
  late StatBox2Model statBoxModel1;
  // Model for StatBox.
  late StatBox2Model statBoxModel2;
  // Model for StatBox.
  late StatBox2Model statBoxModel3;
  // Model for TextField.
  late TextFieldModel textFieldModel;
  // Model for VerificationCard.
  late VerificationCardModel verificationCardModel1;
  // Model for VerificationCard.
  late VerificationCardModel verificationCardModel2;
  // Model for VerificationCard.
  late VerificationCardModel verificationCardModel3;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    statBoxModel1 = createModel(context, () => StatBox2Model());
    statBoxModel2 = createModel(context, () => StatBox2Model());
    statBoxModel3 = createModel(context, () => StatBox2Model());
    textFieldModel = createModel(context, () => TextFieldModel());
    verificationCardModel1 =
        createModel(context, () => VerificationCardModel());
    verificationCardModel2 =
        createModel(context, () => VerificationCardModel());
    verificationCardModel3 =
        createModel(context, () => VerificationCardModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    statBoxModel1.dispose();
    statBoxModel2.dispose();
    statBoxModel3.dispose();
    textFieldModel.dispose();
    verificationCardModel1.dispose();
    verificationCardModel2.dispose();
    verificationCardModel3.dispose();
    buttonModel.dispose();
  }
}
