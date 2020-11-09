part of '../../../pluto_grid.dart';

class DefaultCellWidget extends StatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;
  final int rowIdx;

  DefaultCellWidget({
    this.stateManager,
    this.cell,
    this.column,
    this.rowIdx,
  });

  @override
  _DefaultCellWidgetState createState() => _DefaultCellWidgetState();
}

class _DefaultCellWidgetState extends State<DefaultCellWidget> {
  PlutoRow get thisRow => widget.stateManager.getRowByIdx(widget.rowIdx);

  bool get isCurrentRowSelected {
    return widget.stateManager.isSelectedRow(thisRow?.key);
  }

  Icon getDragIcon() {
    return Icon(
      Icons.drag_indicator,
      size: 18,
      color: widget.stateManager.configuration.iconColor,
    );
  }

  Widget getCellWidget() {
    return widget.column.hasRenderer
        ? widget.column.renderer(PlutoColumnRendererContext(
            column: widget.column,
            rowIdx: widget.rowIdx,
            row: thisRow,
            cell: widget.cell,
            stateManager: widget.stateManager,
          ))
        : Text(
            widget.column.formattedValueForDisplay(widget.cell.value),
            style: widget.stateManager.configuration.cellTextStyle.copyWith(
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: widget.column.textAlign.value,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // todo : implement scrolling by onDragUpdate
        // https://github.com/flutter/flutter/pull/68185
        if (widget.column.enableRowDrag)
          _RowDragIconWidget(
            column: widget.column,
            stateManager: widget.stateManager,
            onDragEnd: (dragDetails) {
              List<PlutoRow> rows = isCurrentRowSelected
                  ? widget.stateManager.currentSelectingRows
                  : [thisRow];

              widget.stateManager.moveRows(
                  rows,
                  dragDetails.offset.dy +
                      (PlutoDefaultSettings.rowTotalHeight / 2));
            },
            dragIcon: getDragIcon(),
            feedbackWidget: getCellWidget(),
          ),
        if (widget.column.enableRowChecked)
          _CheckboxSelectionWidget(
            column: widget.column,
            row: thisRow,
            stateManager: widget.stateManager,
          ),
        Expanded(
          child: getCellWidget(),
        ),
      ],
    );
  }
}

class _RowDragIconWidget extends StatelessWidget {
  final PlutoColumn column;
  final PlutoStateManager stateManager;
  final Function(DraggableDetails dragDetails) onDragEnd;
  final Widget dragIcon;
  final Widget feedbackWidget;

  const _RowDragIconWidget({
    Key key,
    this.column,
    this.stateManager,
    this.onDragEnd,
    this.dragIcon,
    this.feedbackWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable(
      onDragEnd: onDragEnd,
      feedback: Material(
        child: ShadowContainer(
          width: column.width,
          height: PlutoDefaultSettings.rowHeight,
          backgroundColor: stateManager.configuration.gridBackgroundColor,
          borderColor: stateManager.configuration.activatedBorderColor,
          child: Row(
            children: [
              dragIcon,
              Expanded(
                child: feedbackWidget,
              ),
            ],
          ),
        ),
      ),
      child: dragIcon,
    );
  }
}

class _CheckboxSelectionWidget extends StatefulWidget {
  final PlutoColumn column;
  final PlutoRow row;
  final PlutoStateManager stateManager;

  _CheckboxSelectionWidget({
    this.column,
    this.row,
    this.stateManager,
  });

  @override
  __CheckboxSelectionWidgetState createState() =>
      __CheckboxSelectionWidgetState();
}

class __CheckboxSelectionWidgetState extends State<_CheckboxSelectionWidget> {
  bool _checked;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _checked = widget.row.checked;

    widget.stateManager.addListener(changeStateListener);
  }

  void changeStateListener() {
    bool changedChecked = widget.row.checked;

    if (_checked != changedChecked) {
      setState(() {
        _checked = changedChecked;
      });
    }
  }

  void _handleOnChanged(bool changed) {
    if (changed == _checked) {
      return;
    }

    widget.stateManager.setRowChecked(widget.row, changed);

    setState(() {
      _checked = changed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaledCheckbox(
      value: _checked,
      handleOnChanged: _handleOnChanged,
      scale: 0.86,
      unselectedColor: widget.stateManager.configuration.iconColor,
      activeColor: widget.stateManager.configuration.activatedBorderColor,
      checkColor: widget.stateManager.configuration.activatedColor,
    );
  }
}
