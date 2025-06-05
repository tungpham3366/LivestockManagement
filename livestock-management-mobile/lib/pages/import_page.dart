import 'package:flutter/material.dart';
import '../models/batch_import.dart';
import '../services/batch_import_service.dart';
import '../pages/import_batch_detail_page.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({Key? key}) : super(key: key);

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final BatchImportService _service = BatchImportService();
  final int _displayCount = 5; // Số lượng hiển thị mặc định
  String? _userId;
  int _reloadKeyGhim = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await _service.getUserId();
    setState(() {
      _userId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập'),
      ),
      body: _userId == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Widget riêng cho nhóm Ghim
                  PinnedGroupSection(
                    userId: _userId!,
                    service: _service,
                    reloadKey: _reloadKeyGhim,
                    onReloadGhimGroup: () {
                      setState(() {
                        _reloadKeyGhim++;
                      });
                    },
                  ),

                  // Các nhóm khác
                  _buildGroupSection(
                    'Quá hạn',
                    FutureBuilder<BatchImportResponse>(
                      future: _service.getOverdueBatchImports(),
                      builder: (context, snapshot) {
                        return _buildGroupContent(
                          snapshot,
                          total: snapshot.data?.total,
                          group: 'Quá hạn',
                          onGhimPressed: () {
                            setState(() {
                              _reloadKeyGhim++;
                            });
                          },
                        );
                      },
                    ),
                    total: null,
                  ),
                  _buildGroupSection(
                    'Đang bị thiếu loài vật',
                    FutureBuilder<BatchImportResponse>(
                      future: _service.getMissingBatchImports(),
                      builder: (context, snapshot) {
                        return _buildGroupContent(
                          snapshot,
                          total: snapshot.data?.total,
                          group: 'Đang bị thiếu loài vật',
                          onGhimPressed: () {
                            setState(() {
                              _reloadKeyGhim++;
                            });
                          },
                        );
                      },
                    ),
                    total: null,
                  ),
                  _buildGroupSection(
                    'Sắp quá hạn',
                    FutureBuilder<BatchImportResponse>(
                      future: _service.getNearDueBatchImports(_displayCount),
                      builder: (context, snapshot) {
                        return _buildGroupContent(
                          snapshot,
                          total: snapshot.data?.total,
                          group: 'Sắp quá hạn',
                          onGhimPressed: () {
                            setState(() {
                              _reloadKeyGhim++;
                            });
                          },
                        );
                      },
                    ),
                    total: null,
                  ),
                  _buildGroupSection(
                    'Sắp tới',
                    FutureBuilder<BatchImportResponse>(
                      future: _service.getUpcomingBatchImports(_displayCount),
                      builder: (context, snapshot) {
                        return _buildGroupContent(
                          snapshot,
                          total: snapshot.data?.total,
                          group: 'Sắp tới',
                          onGhimPressed: () {
                            setState(() {
                              _reloadKeyGhim++;
                            });
                          },
                        );
                      },
                    ),
                    total: null,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGroupSection(String title, Widget content, {int? total}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title + (total != null ? ' ($total)' : ''),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildGroupContent(
    AsyncSnapshot<BatchImportResponse> snapshot, {
    Color? cardColor,
    String? emptyText,
    int? total,
    required String group,
    required VoidCallback onGhimPressed,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return SizedBox(
        height: 160,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (snapshot.hasError) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 32),
              const SizedBox(height: 8),
              const Text('Lỗi không lấy được dữ liệu',
                  style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      );
    }
    final items = snapshot.data?.items ?? [];
    if (items.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, color: Colors.grey.shade400, size: 32),
              const SizedBox(height: 8),
              Text(emptyText ?? 'Không có dữ liệu',
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    // Các nhóm khác (không phải Ghim)
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 8, right: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return BatchCardWidget(
            item: item,
            cardColor: cardColor,
            group: group,
            userId: _userId!,
            service: _service,
            onGhimSuccess: onGhimPressed,
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

// Widget riêng cho nhóm Ghim, quản lý state local
class PinnedGroupSection extends StatefulWidget {
  final String userId;
  final BatchImportService service;
  final int reloadKey;
  final VoidCallback onReloadGhimGroup;

  const PinnedGroupSection({
    Key? key,
    required this.userId,
    required this.service,
    required this.reloadKey,
    required this.onReloadGhimGroup,
  }) : super(key: key);

  @override
  State<PinnedGroupSection> createState() => _PinnedGroupSectionState();
}

class _PinnedGroupSectionState extends State<PinnedGroupSection> {
  late Future<BatchImportResponse> _pinnedFuture;

  @override
  void initState() {
    super.initState();
    _pinnedFuture = _fetchData();
  }

  @override
  void didUpdateWidget(PinnedGroupSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reloadKey != oldWidget.reloadKey) {
      _pinnedFuture = _fetchData();
    }
  }

  Future<BatchImportResponse> _fetchData() {
    return widget.service.getPinnedBatchImports(widget.userId);
  }

  void _handleRemoveSuccess(int index, List<BatchImport> items) {
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Ghim',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<BatchImportResponse>(
            key: ValueKey('pinned-${widget.reloadKey}'),
            future: _pinnedFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 160,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SizedBox(
                  height: 120,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 32),
                        const SizedBox(height: 8),
                        const Text('Lỗi không lấy được dữ liệu',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                );
              }

              final items = snapshot.data?.items ?? [];
              if (items.isEmpty) {
                return SizedBox(
                  height: 120,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox,
                            color: Colors.grey.shade400, size: 32),
                        const SizedBox(height: 8),
                        Text('Không có mục ghim nào',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 8, right: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return PinnedCardWidget(
                      item: item,
                      userId: widget.userId,
                      service: widget.service,
                      onRemoveSuccess: () => _handleRemoveSuccess(index, items),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Widget cho card trong nhóm Ghim
class PinnedCardWidget extends StatefulWidget {
  final BatchImport item;
  final String userId;
  final BatchImportService service;
  final VoidCallback onRemoveSuccess;

  const PinnedCardWidget({
    Key? key,
    required this.item,
    required this.userId,
    required this.service,
    required this.onRemoveSuccess,
  }) : super(key: key);

  @override
  State<PinnedCardWidget> createState() => _PinnedCardWidgetState();
}

class _PinnedCardWidgetState extends State<PinnedCardWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color statusColor = Colors.blue;
    String statusText = '';

    if (widget.item.dayOver != null) {
      bgColor = Colors.red.shade100;
      statusColor = Colors.red;
      statusText = widget.item.dayOver!;
    } else if (widget.item.totalMissing != null) {
      bgColor = Colors.orange.shade100;
      statusColor = Colors.orange;
      statusText = widget.item.totalMissing!;
    } else if (widget.item.dayleft != null) {
      bgColor = Colors.yellow.shade100;
      statusColor = Colors.orange;
      statusText = widget.item.dayleft!;
    }

    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ngày dự kiến:',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
              Text(
                _formatDate(widget.item.batchImportCompletedDate),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.batchImportName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      final String? id =
                          widget.item.batchImportId ?? widget.item.id;
                      if (id != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImportBatchDetailPage(
                              batchImportId: id,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      statusText.isNotEmpty ? statusText : 'Thực Hiện Ngay',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: -8,
            top: -8,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () async {
                      // Xác nhận xóa
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận'),
                          content: const Text(
                              'Bạn có chắc chắn muốn xóa khỏi nhóm Ghim?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        // Gọi API xóa ghim
                        if (widget.item.id != null) {
                          final result = await widget.service
                              .removePinnedBatchImport(
                                  widget.item.id!, widget.userId);

                          if (result) {
                            widget.onRemoveSuccess();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Đã xóa khỏi nhóm Ghim')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Xóa thất bại!')));
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: ${e.toString()}')));
                      } finally {
                        // Đảm bảo luôn reset trạng thái loading
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

// Widget cho card trong các nhóm khác
class BatchCardWidget extends StatefulWidget {
  final BatchImport item;
  final Color? cardColor;
  final String group;
  final String userId;
  final BatchImportService service;
  final VoidCallback onGhimSuccess;

  const BatchCardWidget({
    Key? key,
    required this.item,
    this.cardColor,
    required this.group,
    required this.userId,
    required this.service,
    required this.onGhimSuccess,
  }) : super(key: key);

  @override
  State<BatchCardWidget> createState() => _BatchCardWidgetState();
}

class _BatchCardWidgetState extends State<BatchCardWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor = widget.cardColor ?? Colors.white;
    Color statusColor = Colors.blue;
    String statusText = '';

    if (widget.item.dayOver != null) {
      bgColor = Colors.red.shade100;
      statusColor = Colors.red;
      statusText = widget.item.dayOver!;
    } else if (widget.item.totalMissing != null) {
      bgColor = Colors.orange.shade100;
      statusColor = Colors.orange;
      statusText = widget.item.totalMissing!;
    } else if (widget.item.dayleft != null) {
      bgColor = Colors.yellow.shade100;
      statusColor = Colors.orange;
      statusText = widget.item.dayleft!;
    }

    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ngày dự kiến:',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
              Text(
                _formatDate(widget.item.batchImportCompletedDate),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.batchImportName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      final String? id =
                          widget.item.batchImportId ?? widget.item.id;
                      if (id != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImportBatchDetailPage(
                              batchImportId: id,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      statusText.isNotEmpty ? statusText : 'Thực Hiện Ngay',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: -8,
            top: -8,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.push_pin,
                        size: 18, color: Colors.orange),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        // Gọi API thêm ghim
                        final result = await widget.service
                            .addPinnedBatchImport(
                                widget.item.batchImportId, widget.userId);

                        if (result) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Đã ghim vào nhóm Ghim')));
                          widget.onGhimSuccess(); // Chỉ reload nhóm Ghim
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ghim thất bại!')));
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: ${e.toString()}')));
                      } finally {
                        // Đảm bảo luôn reset trạng thái loading
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
