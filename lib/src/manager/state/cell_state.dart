part of '../../../pluto_grid.dart';

abstract class ICellState {
  /// True, check the change of value when moving cells.
  bool get checkCellValue;

  /// currently selected cell.
  PlutoCell get currentCell;

  PlutoCell _currentCell;

  /// The position index value of the currently selected cell.
  PlutoCellPosition get currentCellPosition;

  PlutoCell get firstCell;

  /// Execute the function without checking if the value has changed.
  /// Improves cell rendering performance.
  void withoutCheckCellValue(Function() callback);

  void updateCurrentCellPosition({bool notify: true});

  /// Index position of cell in a column
  PlutoCellPosition cellPositionByCellKey(Key cellKey);

  int columnIdxByCellKeyAndRowIdx(Key cellKey, int rowIdx);

  /// Change the selected cell.
  void setCurrentCell(
    PlutoCell cell,
    int rowIdx, {
    bool notify = true,
  });

  /// Whether it is possible to move in the [direction] from [cellPosition].
  bool canMoveCell(PlutoCellPosition cellPosition, MoveDirection direction);

  bool canNotMoveCell(PlutoCellPosition cellPosition, MoveDirection direction);

  /// Whether the cell is in a mutable state
  bool canChangeCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  });

  bool canNotChangeCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  });

  /// Filter on cell value change
  dynamic filteredCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  });

  /// Whether the cell is the currently selected cell.
  bool isCurrentCell(PlutoCell cell);
}

mixin CellState implements IPlutoState {
  bool get checkCellValue => _checkCellValue;

  bool _checkCellValue = true;

  PlutoCell get currentCell => _currentCell;

  PlutoCell _currentCell;

  PlutoCellPosition get currentCellPosition => _currentCellPosition;

  PlutoCellPosition _currentCellPosition;

  PlutoCell get firstCell {
    if (_rows == null || _rows.length < 1) {
      return null;
    }

    final columnIndexes = columnIndexesByShowFixed();

    final columnField = _columns[columnIndexes.first].field;

    return _rows.first.cells[columnField];
  }

  void withoutCheckCellValue(Function() callback) {
    _checkCellValue = false;

    callback();

    _checkCellValue = true;
  }

  void updateCurrentCellPosition({bool notify: true}) {
    if (_currentCell == null) {
      return;
    }

    _currentCellPosition = cellPositionByCellKey(_currentCell.key);

    if (notify) {
      notifyListeners(checkCellValue: false);
    }
  }

  PlutoCellPosition cellPositionByCellKey(Key cellKey) {
    assert(cellKey != null);

    for (var rowIdx = 0; rowIdx < _rows.length; rowIdx += 1) {
      final columnIdx = columnIdxByCellKeyAndRowIdx(cellKey, rowIdx);

      if (columnIdx != null) {
        return PlutoCellPosition(columnIdx: columnIdx, rowIdx: rowIdx);
      }
    }

    throw Exception('CellKey was not found in the list.');
  }

  int columnIdxByCellKeyAndRowIdx(Key cellKey, int rowIdx) {
    if (cellKey == null ||
        rowIdx < 0 ||
        _rows == null ||
        rowIdx >= _rows.length) {
      return null;
    }

    final columnIndexes = columnIndexesByShowFixed();

    for (var columnIdx = 0; columnIdx < columnIndexes.length; columnIdx += 1) {
      final field = _columns[columnIndexes[columnIdx]].field;

      if (_rows[rowIdx].cells[field]._key == cellKey) {
        return columnIdx;
      }
    }

    return null;
  }

  void setCurrentCell(
    PlutoCell cell,
    int rowIdx, {
    bool notify = true,
  }) {
    if (cell == null ||
        rowIdx == null ||
        rowIdx < 0 ||
        rowIdx > _rows.length - 1) {
      return;
    }

    if (_currentCell != null && _currentCell._key == cell._key) {
      return;
    }

    _currentCell = cell;

    _currentCellPosition = PlutoCellPosition(
      rowIdx: rowIdx,
      columnIdx: columnIdxByCellKeyAndRowIdx(cell.key, rowIdx),
    );

    _currentSelectingPosition = null;

    _currentRowIdx = rowIdx;

    _currentSelectingRows = [];

    setEditing(false, notify: false);

    if (notify) {
      notifyListeners(checkCellValue: false);
    }
  }

  bool canMoveCell(PlutoCellPosition cellPosition, MoveDirection direction) {
    switch (direction) {
      case MoveDirection.Left:
        return cellPosition.columnIdx > 0;
      case MoveDirection.Right:
        return cellPosition.columnIdx <
            _rows[cellPosition.rowIdx].cells.length - 1;
      case MoveDirection.Up:
        return cellPosition.rowIdx > 0;
      case MoveDirection.Down:
        return cellPosition.rowIdx < _rows.length - 1;
    }

    throw Exception('Not handled MoveDirection');
  }

  bool canNotMoveCell(PlutoCellPosition cellPosition, MoveDirection direction) {
    return !canMoveCell(cellPosition, direction);
  }

  bool canChangeCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  }) {
    if (column.type.readOnly) {
      return false;
    }

    if (newValue.toString() == oldValue.toString()) {
      return false;
    }

    return true;
  }

  bool canNotChangeCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  }) {
    return !canChangeCellValue(
      column: column,
      newValue: newValue,
      oldValue: oldValue,
    );
  }

  dynamic filteredCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  }) {
    if (column.type.isSelect &&
        column.type.select.items.contains(newValue) != true) {
      newValue = oldValue;
    } else if (column.type.isDate) {
      final parseNewValue = DateTime.tryParse(newValue);

      if (parseNewValue == null) {
        newValue = oldValue;
      } else {
        newValue =
            intl.DateFormat(column.type.date.format).format(parseNewValue);
      }
    } else if (column.type.isTime) {
      final time = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');

      if (!time.hasMatch(newValue)) {
        newValue = oldValue;
      }
    }

    return newValue;
  }

  bool isCurrentCell(PlutoCell cell) {
    return _currentCell != null && _currentCell._key == cell._key;
  }
}
