part of '../../pluto_grid.dart';

class ColumnWidget extends StatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoColumn column;

  ColumnWidget({
    @required this.stateManager,
    @required this.column,
  }) : super(key: column._key);

  @override
  _ColumnWidgetState createState() => _ColumnWidgetState();
}

class _ColumnWidgetState extends State<ColumnWidget> {
  PlutoColumnSort _sort;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _sort = widget.column.sort;

    widget.stateManager.addListener(changeStateListener);
  }

  void changeStateListener() {
    final changedColumn = widget.stateManager.columns
        .firstWhere((element) => element._key == widget.column._key);

    if (_sort != changedColumn.sort) {
      setState(() {
        _sort = changedColumn.sort;
      });
    }
  }

  void _showContextMenu(BuildContext context, Offset position) async {
    // The below GestureDetector's onTapDown event doesn't work if you click quickly, so it's null
    if (position == null) {
      return;
    }

    final RenderBox overlay = Overlay.of(context).context.findRenderObject();

    final Color textColor =
        widget.stateManager.configuration.cellTextStyle.color;

    final Color backgroundColor =
        widget.stateManager.configuration.menuBackgroundColor;

    final buildTextItem = (String text) {
      return Text(
        text,
        style: TextStyle(
          color: textColor,
        ),
      );
    };

    final _MenuItem selectedMenu = await showMenu<_MenuItem>(
      context: context,
      color: backgroundColor,
      position: RelativeRect.fromRect(
          position & Size(40, 40), Offset.zero & overlay.size),
      items: [
        if (widget.column.fixed.isFixed == true)
          PopupMenuItem(
            value: _MenuItem.Unfix,
            child: buildTextItem('Unfix'),
          ),
        if (widget.column.fixed.isFixed != true) ...[
          PopupMenuItem(
            value: _MenuItem.ToLeft,
            child: buildTextItem('ToLeft'),
          ),
          PopupMenuItem(
            value: _MenuItem.ToRight,
            child: buildTextItem('ToRight'),
          ),
        ],
        PopupMenuItem(
          value: _MenuItem.AutoSize,
          child: buildTextItem('AutoSize'),
        ),
      ],
    );

    switch (selectedMenu) {
      case _MenuItem.Unfix:
        widget.stateManager
            .toggleFixedColumn(widget.column._key, PlutoColumnFixed.None);
        break;
      case _MenuItem.ToLeft:
        widget.stateManager
            .toggleFixedColumn(widget.column._key, PlutoColumnFixed.Left);
        break;
      case _MenuItem.ToRight:
        widget.stateManager
            .toggleFixedColumn(widget.column._key, PlutoColumnFixed.Right);
        break;
      case _MenuItem.AutoSize:
        final String maxValue =
            widget.stateManager.rows.fold('', (previousValue, element) {
          final value = element.cells.entries
              .firstWhere((element) => element.key == widget.column.field)
              .value
              .value;

          if (previousValue.toString().length < value.toString().length) {
            return value.toString();
          }

          return previousValue.toString();
        });

        // Get size after rendering virtually
        // https://stackoverflow.com/questions/54351655/flutter-textfield-width-should-match-width-of-contained-text
        TextSpan textSpan = new TextSpan(
          style: widget.stateManager.configuration.cellTextStyle,
          text: maxValue,
        );

        TextPainter textPainter = new TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        widget.stateManager.resizeColumn(
            widget.column._key,
            textPainter.width -
                widget.column.width +
                (PlutoDefaultSettings.cellPadding * 2) +
                10);
        break;
    }
  }

  Widget _buildDraggable(Widget child) {
    return Draggable(
      onDragEnd: (dragDetails) {
        widget.stateManager
            .moveColumn(widget.column._key, dragDetails.offset.dx);
      },
      feedback: Container(
        width: widget.column.width,
        height: PlutoDefaultSettings.rowHeight,
        padding: const EdgeInsets.symmetric(
            horizontal: PlutoDefaultSettings.cellPadding),
        decoration: BoxDecoration(
          color: Colors.black26,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.column.title,
            style: widget.stateManager.configuration.columnTextStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
      child: child,
    );
  }

  Widget _buildColumn() {
    Widget _column = Container(
      width: widget.column.width,
      height: PlutoDefaultSettings.rowHeight,
      padding: const EdgeInsets.symmetric(
          horizontal: PlutoDefaultSettings.cellPadding),
      decoration: widget.stateManager.configuration.enableColumnBorder
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: widget.stateManager.configuration.borderColor,
                  width: 1.0,
                ),
              ),
            )
          : BoxDecoration(),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.column.title,
          style: widget.stateManager.configuration.columnTextStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );

    return widget.column.enableSorting
        ? InkWell(
            onTap: () {
              widget.stateManager.toggleSortColumn(widget.column._key);
            },
            child: _column,
          )
        : _column;
  }

  @override
  Widget build(BuildContext context) {
    Offset _currentPosition;

    return Stack(
      children: [
        Positioned(
          child: widget.column.enableDraggable
              ? _buildDraggable(_buildColumn())
              : _buildColumn(),
        ),
        if (widget.column.enableContextMenu)
          Positioned(
            right: -3,
            child: GestureDetector(
              onTapUp: (TapUpDetails details) {
                _showContextMenu(context, details.globalPosition);
              },
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                _currentPosition = details.localPosition;
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                widget.stateManager
                    .resizeColumn(widget.column._key, _currentPosition.dx - 20);
              },
              child: Container(
                height: widget.stateManager.columnHeight,
                alignment: Alignment.center,
                child: IconButton(
                  icon: ColumnIcon(
                    sort: widget.column.sort,
                    color: widget.stateManager.configuration.iconColor,
                  ),
                  iconSize: 18,
                  onPressed: null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ColumnIcon extends StatelessWidget {
  final PlutoColumnSort sort;
  final Color color;

  ColumnIcon({
    this.sort,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (sort) {
      case PlutoColumnSort.Ascending:
        return Transform.rotate(
          angle: 90 * pi / 90,
          child: const Icon(
            Icons.sort,
            color: Colors.green,
          ),
        );
      case PlutoColumnSort.Descending:
        return const Icon(
          Icons.sort,
          color: Colors.red,
        );
      default:
        return Icon(
          Icons.menu,
          color: color ?? Colors.black26,
        );
    }
  }
}

enum _MenuItem {
  Unfix,
  ToLeft,
  ToRight,
  AutoSize,
}
