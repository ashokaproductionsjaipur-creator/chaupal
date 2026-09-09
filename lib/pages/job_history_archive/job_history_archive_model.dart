import '/components/history_card/history_card_widget.dart';
import '/components/tab_group/tab_group_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'job_history_archive_widget.dart' show JobHistoryArchiveWidget;
import 'package:flutter/material.dart';

class JobHistoryArchiveModel extends FlutterFlowModel<JobHistoryArchiveWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for TabGroup.
  late TabGroupModel tabGroupModel;
  // Model for HistoryCard.
  late HistoryCardModel historyCardModel1;
  // Model for HistoryCard.
  late HistoryCardModel historyCardModel2;
  // Model for HistoryCard.
  late HistoryCardModel historyCardModel3;
  // Model for HistoryCard.
  late HistoryCardModel historyCardModel4;
  // Model for HistoryCard.
  late HistoryCardModel historyCardModel5;

  @override
  void initState(BuildContext context) {
    tabGroupModel = createModel(context, () => TabGroupModel());
    historyCardModel1 = createModel(context, () => HistoryCardModel());
    historyCardModel2 = createModel(context, () => HistoryCardModel());
    historyCardModel3 = createModel(context, () => HistoryCardModel());
    historyCardModel4 = createModel(context, () => HistoryCardModel());
    historyCardModel5 = createModel(context, () => HistoryCardModel());
  }

  @override
  void dispose() {
    tabGroupModel.dispose();
    historyCardModel1.dispose();
    historyCardModel2.dispose();
    historyCardModel3.dispose();
    historyCardModel4.dispose();
    historyCardModel5.dispose();
  }
}
