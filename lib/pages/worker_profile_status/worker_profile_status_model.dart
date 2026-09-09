import '/components/button/button_widget.dart';
import '/components/profile_stat/profile_stat_widget.dart';
import '/components/status_badge0f480090/status_badge0f480090_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'worker_profile_status_widget.dart' show WorkerProfileStatusWidget;
import 'package:flutter/material.dart';

class WorkerProfileStatusModel
    extends FlutterFlowModel<WorkerProfileStatusWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for StatusBadge0f480090.
  late StatusBadge0f480090Model statusBadge0f480090Model;
  // Model for ProfileStat.
  late ProfileStatModel profileStatModel1;
  // Model for ProfileStat.
  late ProfileStatModel profileStatModel2;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    statusBadge0f480090Model =
        createModel(context, () => StatusBadge0f480090Model());
    profileStatModel1 = createModel(context, () => ProfileStatModel());
    profileStatModel2 = createModel(context, () => ProfileStatModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    statusBadge0f480090Model.dispose();
    profileStatModel1.dispose();
    profileStatModel2.dispose();
    buttonModel.dispose();
  }
}
