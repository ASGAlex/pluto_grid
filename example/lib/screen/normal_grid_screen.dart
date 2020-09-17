import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../dummy_data/development.dart';

class NormalGridScreen extends StatelessWidget {
  static const routeName = 'normal-grid';

  @override
  Widget build(BuildContext context) {
    final dummyData = DummyData(10, 100);

    return Scaffold(
      appBar: AppBar(
        title: Text('PlutoGrid - Normal'),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: PlutoGrid(
          columns: dummyData.columns,
          rows: dummyData.rows,
          onChanged: (PlutoOnChangedEvent event) {
            print(event);
          },
        ),
      ),
    );
  }
}
