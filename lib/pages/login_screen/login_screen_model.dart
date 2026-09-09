import '/components/brand_header/brand_header_widget.dart';
import '/components/button/button_widget.dart';
import '/components/role_chip/role_chip_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'login_screen_widget.dart' show LoginScreenWidget;
import 'package:flutter/material.dart';

class LoginScreenModel extends FlutterFlowModel<LoginScreenWidget> {
  ///  Local state fields for this page.

  String selectedRole = 'owner';

  ///  State fields for stateful widgets in this page.

  // Model for BrandHeader.
  late BrandHeaderModel brandHeaderModel;
  // Model for RoleChip.
  late RoleChipModel roleChipModel1;
  // Model for RoleChip.
  late RoleChipModel roleChipModel2;
  // Model for TextField.
  late TextFieldModel textFieldModel1;
  // Model for TextField.
  late TextFieldModel textFieldModel2;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;
  // Model for Button.
  late ButtonModel buttonModel3;

  @override
  void initState(BuildContext context) {
    brandHeaderModel = createModel(context, () => BrandHeaderModel());
    roleChipModel1 = createModel(context, () => RoleChipModel());
    roleChipModel2 = createModel(context, () => RoleChipModel());
    textFieldModel1 = createModel(context, () => TextFieldModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    buttonModel3 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    brandHeaderModel.dispose();
    roleChipModel1.dispose();
    roleChipModel2.dispose();
    textFieldModel1.dispose();
    textFieldModel2.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
    buttonModel3.dispose();
  }
}
