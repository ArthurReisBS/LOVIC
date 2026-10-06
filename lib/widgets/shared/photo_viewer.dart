import 'package:flutter/material.dart';

/// Abre as fotos em tela cheia: deslize (ou use as setas) para trocar e use o
/// zoom (pinça ou scroll). Toque na foto ou no X para fechar.
void showPhotoViewer(
  BuildContext context,
  List<ImageProvider> images, {
  int initialIndex = 0,
}) {
  if (images.isEmpty) return;
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => _PhotoViewer(images: images, initialIndex: initialIndex),
  );
}

class _PhotoViewer extends StatefulWidget {
  final List<ImageProvider> images;
  final int initialIndex;

  const _PhotoViewer({required this.images, required this.initialIndex});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) => _controller.animateToPage(
    _index + delta,
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    final total = widget.images.length;
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: total,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                maxScale: 5,
                child: Center(child: Image(image: widget.images[i])),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
          if (total > 1) ...[
            if (_index > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => _go(-1),
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            if (_index < total - 1)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => _go(1),
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Text(
                '${_index + 1}/$total',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
