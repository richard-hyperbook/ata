import 'package:flutter/material.dart';
import '../appwrite_interface.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '../../app_state.dart';

class TemplatesPageWidget extends StatefulWidget {
  const TemplatesPageWidget({super.key});

  @override
  State<TemplatesPageWidget> createState() => _TemplatesPageWidgetState();
}

class _TemplatesPageWidgetState extends State<TemplatesPageWidget> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<TemplatesRecord>? _allTemplates;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<TemplatesRecord> templates = await listTemplateList();
      setState(() {
        _allTemplates = templates
            .where((t) =>
                t.isMaster == true ||
                t.creatorId?.path == currentUser?.reference?.path)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading templates: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addTemplate(TemplatesRecord? sourceTemplate) {
    TextEditingController nameController = TextEditingController();
    bool isMaster = false;
    if (sourceTemplate != null) {
      nameController.text = '${sourceTemplate.name} (Copy)';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            title: Text(
              sourceTemplate == null ? 'New Template' : 'Copy Template',
              style: FlutterFlowTheme.of(context).headlineSmall,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Template Name',
                    labelStyle: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .copyWith(
                            color: FlutterFlowTheme.of(context).secondaryText),
                    filled: true,
                    fillColor: FlutterFlowTheme.of(context).primaryBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 2),
                    ),
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
                if (currentUser?.userLevel == kUserLevelSupervisor)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        title: Text('Master Template',
                            style: FlutterFlowTheme.of(context).bodyMedium),
                        value: isMaster,
                        activeColor: FlutterFlowTheme.of(context).primary,
                        onChanged: (val) {
                          setDialogState(() {
                            isMaster = val ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ],
            ),
            actionsPadding: EdgeInsets.only(bottom: 16, right: 16, left: 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: TextStyle(
                        color: FlutterFlowTheme.of(context).secondaryText)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () async {
                  String name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    Navigator.pop(context);
                    try {
                      await createTemplate(
                        name: name,
                        questions: sourceTemplate?.questions?.toList() ?? [],
                        isMaster: isMaster,
                        creatorId: currentUser!.reference!,
                      );
                      _loadTemplates();
                    } catch (e) {
                      print('Error creating template: $e');
                    }
                  }
                },
                child: Text('Create'),
              ),
            ],
          );
        });
      },
    );
  }

  void _editQuestions(TemplatesRecord template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsEditPage(
          template: template,
          onSave: (updatedQuestions) async {
            await updateTemplateQuestions(
                template.reference!, updatedQuestions);
            _loadTemplates();
          },
        ),
      ),
    );
  }

  void _deleteTemplate(TemplatesRecord template) async {
    bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              title: Text('Delete Template',
                  style: FlutterFlowTheme.of(context).headlineSmall),
              content: Text(
                'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              actionsPadding: EdgeInsets.only(bottom: 16, right: 16, left: 16),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel',
                        style: TextStyle(
                            color:
                                FlutterFlowTheme.of(context).secondaryText))),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Delete')),
              ],
            ));

    if (confirm == true) {
      await deleteTemplate(template.reference!);
      _loadTemplates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
          title: Text('Templates',
              style: FlutterFlowTheme.of(context)
                  .headlineMedium
                  .copyWith(color: Colors.white, fontSize: 24)),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FlutterFlowIconButton(
                enabled: true,
                fillColor: Colors.white.withAlpha(50),
                tooltipMessage: 'Create Session',
                borderColor: Colors.transparent,
                borderRadius: 12,
                borderWidth: 0,
                buttonSize: 44,
                onPressed: () {
                  _addTemplate(null);
                },
                icon: Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ]),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: FlutterFlowTheme.of(context).primary))
          : _allTemplates == null || _allTemplates!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 80,
                          color: FlutterFlowTheme.of(context)
                              .secondaryText
                              .withAlpha(100)),
                      SizedBox(height: 16),
                      Text('No templates found',
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .copyWith(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  itemCount: _allTemplates?.length ?? 0,
                  itemBuilder: (context, index) {
                    final template = _allTemplates![index];
                    final isOwner = template.creatorId?.path ==
                        currentUser?.reference?.path;

                    return Container(
                      margin: EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        template.name ?? 'Unnamed',
                                        style: FlutterFlowTheme.of(context)
                                            .titleLarge
                                            .copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.list_alt,
                                              size: 16,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText),
                                          SizedBox(width: 4),
                                          Text(
                                            '${template.questions?.length ?? 0} questions',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .copyWith(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText),
                                          ),
                                          if (template.isMaster == true) ...[
                                            SizedBox(width: 12),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .tertiary
                                                        .withAlpha(30),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .tertiary
                                                        .withAlpha(80)),
                                              ),
                                              child: Text(
                                                'Master',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .copyWith(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .tertiary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                              ),
                                            ),
                                          ]
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Divider(
                                color: FlutterFlowTheme.of(context).lineColor,
                                height: 1),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _ModernIconButton(
                                  icon: Icons.copy,
                                  onPressed: () => _addTemplate(template),
                                  tooltip: 'Copy',
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                                SizedBox(width: 8),
                                _ModernIconButton(
                                  icon: Icons.edit_note,
                                  onPressed: () => _editQuestions(template),
                                  tooltip: 'View/Edit Questions',
                                  color: FlutterFlowTheme.of(context).secondary,
                                ),
                                if (isOwner) ...[
                                  SizedBox(width: 8),
                                  _ModernIconButton(
                                    icon: Icons.delete_outline,
                                    onPressed: () => _deleteTemplate(template),
                                    tooltip: 'Delete',
                                    color: FlutterFlowTheme.of(context).error,
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color color;

  const _ModernIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class QuestionsEditPage extends StatefulWidget {
  final TemplatesRecord template;
  final Function(List<String>) onSave;

  const QuestionsEditPage(
      {super.key, required this.template, required this.onSave});

  @override
  State<QuestionsEditPage> createState() => _QuestionsEditPageState();
}

class _QuestionsEditPageState extends State<QuestionsEditPage> {
  late List<String> _questions;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.template.questions ?? []);
  }

  void _addQuestion() {
    TextEditingController controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              title: Text('Add Question',
                  style: FlutterFlowTheme.of(context).headlineSmall),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter question text',
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).primaryBackground,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 2)),
                ),
                maxLines: 3,
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              actionsPadding: EdgeInsets.only(bottom: 16, right: 16, left: 16),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style: TextStyle(
                            color:
                                FlutterFlowTheme.of(context).secondaryText))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      setState(() {
                        _questions.add(controller.text.trim());
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ));
  }

  void _editQuestion(int index) {
    TextEditingController controller =
        TextEditingController(text: _questions[index]);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              title: Text('Edit Question',
                  style: FlutterFlowTheme.of(context).headlineSmall),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter question text',
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).primaryBackground,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 2)),
                ),
                maxLines: 3,
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              actionsPadding: EdgeInsets.only(bottom: 16, right: 16, left: 16),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style: TextStyle(
                            color:
                                FlutterFlowTheme.of(context).secondaryText))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      setState(() {
                        _questions[index] = controller.text.trim();
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final canEdit =
        widget.template.creatorId?.path == currentUser?.reference?.path;
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        title: Text('${widget.template.name}',
            style: FlutterFlowTheme.of(context)
                .headlineMedium
                .copyWith(color: Colors.white, fontSize: 24)),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (canEdit)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(Icons.done, size: 28),
                onPressed: () {
                  widget.onSave(_questions);
                  Navigator.pop(context);
                },
                tooltip: 'Save All',
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: FlutterFlowTheme.of(context).primary.withAlpha(20),
            child: Row(
              children: [
                Icon(Icons.format_list_numbered,
                    color: FlutterFlowTheme.of(context).primary),
                SizedBox(width: 12),
                Text(
                  '${_questions.length} Questions in Template',
                  style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: _questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.help_outline,
                            size: 80,
                            color: FlutterFlowTheme.of(context)
                                .secondaryText
                                .withAlpha(100)),
                        SizedBox(height: 16),
                        Text('No questions added yet',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .copyWith(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: FlutterFlowTheme.of(context).lineColor),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: 44,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primary
                                      .withAlpha(20),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16)),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .copyWith(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 16.0),
                                  child: Text(
                                    _questions[index],
                                    style: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .copyWith(height: 1.4),
                                  ),
                                ),
                              ),
                              if (canEdit)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            size: 20),
                                        onPressed: () => _editQuestion(index),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(
                                            minWidth: 32, minHeight: 32),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline,
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _questions.removeAt(index);
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(
                                            minWidth: 32, minHeight: 32),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              foregroundColor: Colors.white,
              onPressed: _addQuestion,
              child: Icon(Icons.add, size: 28),
              backgroundColor: FlutterFlowTheme.of(context).primary,
              elevation: 4,
            )
          : null,
    );
  }
}
