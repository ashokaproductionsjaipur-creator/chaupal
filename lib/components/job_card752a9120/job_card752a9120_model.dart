import '/components/button/button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'job_card752a9120_widget.dart' show JobCard752a9120Widget;
import 'package:flutter/material.dart';

class JobCard752a9120Model extends FlutterFlowModel<JobCard752a9120Widget> {
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
