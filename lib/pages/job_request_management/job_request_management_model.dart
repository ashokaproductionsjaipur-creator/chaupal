import '/components/button/button_widget.dart';
import '/components/request_card/request_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'job_request_management_widget.dart' show JobRequestManagementWidget;
import 'package:flutter/material.dart';

class JobRequestManagementModel
    extends FlutterFlowModel<JobRequestManagementWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for RequestCard.
  late RequestCardModel requestCardModel1;
  // Model for RequestCard.
  late RequestCardModel requestCardModel2;
  // Model for RequestCard.
  late RequestCardModel requestCardModel3;
  // Model for RequestCard.
  late RequestCardModel requestCardModel4;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    requestCardModel1 = createModel(context, () => RequestCardModel());
    requestCardModel2 = createModel(context, () => RequestCardModel());
    requestCardModel3 = createModel(context, () => RequestCardModel());
    requestCardModel4 = createModel(context, () => RequestCardModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    requestCardModel1.dispose();
    requestCardModel2.dispose();
    requestCardModel3.dispose();
    requestCardModel4.dispose();
    buttonModel.dispose();
  }
}
