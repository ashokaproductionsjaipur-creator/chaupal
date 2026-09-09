import '/components/button/button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'request_card_widget.dart' show RequestCardWidget;
import 'package:flutter/material.dart';

class RequestCardModel extends FlutterFlowModel<RequestCardWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    buttonModel1.dispose();
    buttonModel2.dispose();
  }
}
