part of '../pluto_grid.dart';

class PlutoDualGridPopup {
  final BuildContext context;
  final PlutoDualGridProps gridPropsA;
  final PlutoDualGridProps gridPropsB;
  final PlutoMode mode;
  final PlutoDualOnSelectedEventCallback onSelected;
  final double width;
  final double height;

  PlutoDualGridPopup({
    this.context,
    this.gridPropsA,
    this.gridPropsB,
    this.mode,
    this.onSelected,
    this.width,
    this.height,
  }) {
    this.open();
  }

  Future<void> open() async {
    PlutoDualOnSelectedEvent selected =
        await showDialog<PlutoDualOnSelectedEvent>(
            context: context,
            builder: (BuildContext ctx) {
              return Dialog(
                child: LayoutBuilder(
                  builder: (ctx, size) {
                    return Container(
                      width: (width ?? size.maxWidth) +
                          PlutoDefaultSettings.gridInnerSpacing,
                      height: height ?? size.maxHeight,
                      child: PlutoDualGrid(
                        gridPropsA: gridPropsA,
                        gridPropsB: gridPropsB,
                        mode: mode,
                        onSelected: (PlutoDualOnSelectedEvent event) {
                          Navigator.pop(ctx, event);
                        },
                      ),
                    );
                  },
                ),
              );
            });
    if (onSelected != null) {
      onSelected(selected);
    }
  }
}
