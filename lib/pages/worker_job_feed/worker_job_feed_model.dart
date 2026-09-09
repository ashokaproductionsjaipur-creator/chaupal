import '/components/job_card752a9120/job_card752a9120_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'worker_job_feed_widget.dart' show WorkerJobFeedWidget;
import 'package:flutter/material.dart';

class WorkerJobFeedModel extends FlutterFlowModel<WorkerJobFeedWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for JobCard752a9120.
  late JobCard752a9120Model jobCard752a9120Model1;
  // Model for JobCard752a9120.
  late JobCard752a9120Model jobCard752a9120Model2;
  // Model for JobCard752a9120.
  late JobCard752a9120Model jobCard752a9120Model3;

  @override
  void initState(BuildContext context) {
    jobCard752a9120Model1 = createModel(context, () => JobCard752a9120Model());
    jobCard752a9120Model2 = createModel(context, () => JobCard752a9120Model());
    jobCard752a9120Model3 = createModel(context, () => JobCard752a9120Model());
  }

  @override
  void dispose() {
    jobCard752a9120Model1.dispose();
    jobCard752a9120Model2.dispose();
    jobCard752a9120Model3.dispose();
  }
}
