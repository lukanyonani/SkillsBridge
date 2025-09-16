import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';

// Enhanced Job Application WebView Screen
class JobApplicationWebView extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobApplicationWebView({super.key, required this.job});

  @override
  State<JobApplicationWebView> createState() => _JobApplicationWebViewState();
}

class _JobApplicationWebViewState extends State<JobApplicationWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('🌐 Initializing WebView for job: ${widget.job['title']}');
    debugPrint('🔗 Job URL: ${widget.job['url']}');
    _initializeWebView();
  }

  void _initializeWebView() {
    // ✅ Use platform-specific params
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('🔄 Loading progress: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('📄 Page started loading: $url');
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            debugPrint('✅ Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebView error: ${error.description}');
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = error.description;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🔄 Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      );

    _controller = controller;
    _loadJobUrl();
  }

  void _loadJobUrl() {
    final jobUrl = widget.job['url'] as String?;

    if (jobUrl != null && jobUrl.isNotEmpty) {
      String finalUrl = jobUrl;
      if (!jobUrl.startsWith('http://') && !jobUrl.startsWith('https://')) {
        finalUrl = 'https://$jobUrl';
      }

      debugPrint('🚀 Loading job URL: $finalUrl');
      _controller.loadRequest(Uri.parse(finalUrl));
    } else {
      final fallbackUrl = _constructFallbackUrl();
      debugPrint('🔍 No direct URL found, using fallback: $fallbackUrl');
      _controller.loadRequest(Uri.parse(fallbackUrl));
    }
  }

  String _constructFallbackUrl() {
    final company = widget.job['company'] ?? '';
    final title = widget.job['title'] ?? '';
    final location = widget.job['location'] ?? '';

    return 'https://www.careerjet.co.za/search/jobs?s=${Uri.encodeComponent('$title $company $location')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2563EB),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          debugPrint('🔙 User closed job application WebView');
          Navigator.pop(context);
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.job['title'] ?? 'Job Application',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            widget.job['company'] ?? '',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        if (!_isLoading && !_hasError)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              debugPrint('🔄 User refreshed WebView');
              _controller.reload();
            },
          ),
        IconButton(
          icon: const Icon(Icons.open_in_browser),
          onPressed: () => _openInExternalBrowser(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading application page...',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text(
              'Unable to load application page',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'The job application page could not be loaded.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _loadJobUrl(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _openInExternalBrowser(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in Browser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openInExternalBrowser() async {
    final jobUrl = widget.job['url'] as String?;
    if (jobUrl != null && jobUrl.isNotEmpty) {
      String finalUrl = jobUrl;
      if (!jobUrl.startsWith('http://') && !jobUrl.startsWith('https://')) {
        finalUrl = 'https://$jobUrl';
      }

      debugPrint('🌐 Opening in external browser: $finalUrl');

      try {
        final uri = Uri.parse(finalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showErrorSnackBar('Could not open the job application page');
        }
      } catch (e) {
        debugPrint('❌ Error launching URL: $e');
        _showErrorSnackBar('Could not open the job application page');
      }
    } else {
      _showErrorSnackBar('No application URL available for this job');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }
}
