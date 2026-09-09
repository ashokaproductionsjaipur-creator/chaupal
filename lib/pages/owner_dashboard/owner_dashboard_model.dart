import '/components/button/button_widget.dart';
import '/components/job_card/job_card_widget.dart';
import '/components/stat_box/stat_box_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'owner_dashboard_widget.dart' show OwnerDashboardWidget;
import 'package:flutter/material.dart';

class OwnerDashboardModel extends FlutterFlowModel<OwnerDashboardWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for StatBox.
  late StatBoxModel statBoxModel1;
  // Model for StatBox.
  late StatBoxModel statBoxModel2;
  // Model for StatBox.
  late StatBoxModel statBoxModel3;
  // Model for Button.
  late ButtonModel buttonModel;
  // Model for JobCard.
  late JobCardModel jobCardModel1;
  // Model for JobCard.
  late JobCardModel jobCardModel2;

  @override
  void initState(BuildContext context) {
    statBoxModel1 = createModel(context, () => StatBoxModel());
    statBoxModel2 = createModel(context, () => StatBoxModel());
    statBoxModel3 = createModel(context, () => StatBoxModel());
    buttonModel = createModel(context, () => ButtonModel());
    jobCardModel1 = createModel(context, () => JobCardModel());
    jobCardModel2 = createModel(context, () => JobCardModel());
  }

  @override
  void dispose() {
    statBoxModel1.dispose();
    statBoxModel2.dispose();
    statBoxModel3.dispose();
    buttonModel.dispose();
    jobCardModel1.dispose();
    jobCardModel2.dispose();
  }
}
