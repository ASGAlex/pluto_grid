part of '../../pluto_grid.dart';

class PlutoRow {
  /// List of row
  Map<String, PlutoCell> cells;

  /// Value to maintain the default sort order when sorting columns.
  /// If there is no value, it is automatically set when loading the grid.
  int sortIdx;

  dynamic _model;

  PlutoRow({
    @required this.cells,
    this.sortIdx,
    bool checked = false,
    dynamic model
  })  : this._checked = checked,
        this._key = UniqueKey(),
        this._model = model;

  /// The state value that the checkbox is checked.
  /// If the enableRowChecked value of the [PlutoColumn] property is set to true,
  /// a check box appears in the cell of the corresponding column.
  /// To manually change the values at runtime,
  /// use the [PlutoStateManager.setRowChecked]
  /// or [PlutoStateManager.toggleAllRowChecked] methods.
  bool get checked => _checked;

  bool _checked;

  /// Row key
  Key get key => _key;

  Key _key;

  dynamic get model => _model;
}
