import '/components/button/button_widget.dart';
import '/components/role_card/role_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'role_selection_widget.dart' show RoleSelectionWidget;
import 'package:flutter/material.dart';

class RoleSelectionModel extends FlutterFlowModel<RoleSelectionWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for RoleCard.
  late RoleCardModel roleCardModel1;
  // Model for RoleCard.
  late RoleCardModel roleCardModel2;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    roleCardModel1 = createModel(context, () => RoleCardModel());
    roleCardModel2 = createModel(context, () => RoleCardModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    roleCardModel1.dispose();
    roleCardModel2.dispose();
    buttonModel.dispose();
  }
}
