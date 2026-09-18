import 'package:ui_common/ui_common.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _contact = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    _contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '意见反馈',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('欢迎告诉我们哪里需要改进',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 18),
              TextFormField(
                controller: _description,
                minLines: 5,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: '问题或建议',
                  hintText: '请尽量描述清楚操作步骤',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? '请填写问题或建议' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contact,
                decoration: const InputDecoration(
                  labelText: '联系方式（选填）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryActionButton(label: '提交反馈', onPressed: _submit),
              const SizedBox(height: 12),
              Text(
                '演示版反馈只保存在本次运行内，不会发送到服务器。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _description.clear();
    _contact.clear();
    AppToast.show(
      context,
      type: AppToastType.success,
      message: '反馈已生成本地演示记录，感谢您的建议',
    );
  }
}
