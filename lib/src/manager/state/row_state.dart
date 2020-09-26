part of '../../../pluto_grid.dart';

abstract class IRowState {
  List<PlutoRow> get rows;

  List<PlutoRow> _rows;

  /// Row index of currently selected cell.
  int get currentRowIdx;

  /// Row of currently selected cell.
  PlutoRow get currentRow;

  /// set currentRowIdx to null
  void clearCurrentRowIdx({bool notify: true});

  void setCurrentRowIdx(int rowIdx, {bool notify: true});

  List<PlutoRow> setSortIdxOfRows(
    List<PlutoRow> rows, {
    bool increase = true,
    int start = 0,
  });

  void prependRows(List<PlutoRow> rows);

  void appendRows(List<PlutoRow> rows);

  void removeCurrentRow();

  void removeRows(List<PlutoRow> rows);

  /// Update RowIdx to Current Cell.
  void updateCurrentRowIdx({bool notify: true});
}

mixin RowState implements IPlutoState {
  List<PlutoRow> get rows => [..._rows];

  List<PlutoRow> _rows;

  int get currentRowIdx => _currentRowIdx;

  int _currentRowIdx;

  PlutoRow get currentRow {
    if (_currentRowIdx == null) {
      return null;
    }

    return _rows[_currentRowIdx];
  }

  void clearCurrentRowIdx({bool notify: true}) {
    setCurrentRowIdx(null, notify: notify);
  }

  void setCurrentRowIdx(int rowIdx, {bool notify: true}) {
    if (_currentRowIdx == rowIdx) {
      return;
    }

    _currentRowIdx = rowIdx;

    if (notify) {
      notifyListeners(checkCellValue: false);
    }
  }

  List<PlutoRow> setSortIdxOfRows(
    List<PlutoRow> rows, {
    bool increase = true,
    int start = 0,
  }) {
    int sortIdx = start;

    return rows.map((row) {
      row.sortIdx = sortIdx;

      sortIdx = increase ? ++sortIdx : --sortIdx;

      return row;
    }).toList(growable: false);
  }

  void prependRows(List<PlutoRow> rows) {
    if (rows == null || rows.length < 1) {
      return;
    }

    final start =
        _rows.length > 0 ? _rows.map((row) => row.sortIdx).reduce(min) - 1 : 0;

    PlutoStateManager.initializeRows(
      _columns,
      rows,
      increase: false,
      start: start,
    );

    _rows.insertAll(0, rows);

    /// Update currentRowIdx
    if (currentCell != null) {
      _currentRowIdx = rows.length + _currentRowIdx;

      setCurrentCellPosition(
          PlutoCellPosition(
            columnIdx: currentCellPosition.columnIdx,
            rowIdx: currentRowIdx,
          ),
          notify: false);

      double offsetToMove = rows.length * PlutoDefaultSettings.rowTotalHeight;

      scrollByDirection(MoveDirection.Up, offsetToMove);
    }

    /// Update currentSelectingPosition
    if (currentSelectingPosition != null) {
      setCurrentSelectingPosition(
        columnIdx: currentSelectingPosition.columnIdx,
        rowIdx: rows.length + currentSelectingPosition.rowIdx,
        notify: false,
      );
    }

    notifyListeners();
  }

  void appendRows(List<PlutoRow> rows) {
    if (rows == null || rows.length < 1) {
      return;
    }

    final start =
        _rows.length > 0 ? _rows.map((row) => row.sortIdx).reduce(max) + 1 : 0;

    PlutoStateManager.initializeRows(
      _columns,
      rows,
      start: start,
    );

    _rows.addAll(rows);

    notifyListeners();
  }

  void removeCurrentRow() {
    if (_currentRowIdx == null) {
      return;
    }

    _rows.removeAt(_currentRowIdx);

    resetCurrentState(notify: false);

    notifyListeners(checkCellValue: false);
  }

  void removeRows(List<PlutoRow> rows) {
    if (rows == null || rows.length < 1) {
      return;
    }

    final List<Key> removeKeys = rows.map((e) => e.key).toList(growable: false);

    if (_currentRowIdx != null &&
        removeKeys.contains(_rows[_currentRowIdx].key)) {
      resetCurrentState(notify: false);
    }

    _rows.removeWhere((row) => removeKeys.contains(row.key));

    notifyListeners(checkCellValue: false);
  }

  void updateCurrentRowIdx({bool notify: true}) {
    if (currentCell == null) {
      _currentRowIdx = null;

      if (notify) {
        notifyListeners(checkCellValue: false);
      }

      return;
    }

    for (var rowIdx = 0; rowIdx < _rows.length; rowIdx += 1) {
      for (var columnIdx = 0;
          columnIdx < columnIndexes.length;
          columnIdx += 1) {
        final field = _columns[columnIndexes[columnIdx]].field;

        if (_rows[rowIdx].cells[field]._key == currentCell.key) {
          _currentRowIdx = rowIdx;
        }
      }
    }

    if (notify) {
      notifyListeners(checkCellValue: false);
    }
  }
}
