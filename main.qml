import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.qfield
import org.qgis
import Theme

import "qrc:/qml" as QFieldItems

Item {
  id: plugin

  property var mainWindow: iface.mainWindow()
  property var positionSource: iface.findItemByObjectName('positionSource')
  property var dashBoard: iface.findItemByObjectName('dashBoard')
  property var overlayFeatureFormDrawer: iface.findItemByObjectName('overlayFeatureFormDrawer')
  property var fieldNames: []

  Component.onCompleted: {
    iface.addItemToPluginsToolbar(selectLayerButton)
  }

  QfToolButton {
    id: selectLayerButton
    bgcolor: Theme.darkGray
    round: true

    onClicked: layerSelectionDialog.open()
  }

  Dialog {
    id: layerSelectionDialog
    parent: mainWindow.contentItem
    title: qsTr("Select Layer by Name")
    standardButtons: Dialog.Ok | Dialog.Cancel

    anchors.centerIn: parent
    width: Math.min(300, parent.width - 50)

    ColumnLayout {
      width: parent.width

      TextField {
        id: layerNameInput
        placeholderText: qsTr("Enter layer name")
        Layout.fillWidth: true
      }
    }

    onAccepted: {
      var layerName = layerNameInput.text.trim()
      if (layerName) {
        let layer = qgisProject.mapLayersByName(layerName)[0]
        if (layer) {
          dashBoard.activeLayer = layer
          dashBoard.ensureEditableLayerSelected()
          mainWindow.displayToast(qsTr("Layer '%1' set as active").arg(layerName))

          if (!positionSource.active || !positionSource.positionInformation.latitudeValid || !positionSource.positionInformation.longitudeValid) {
            mainWindow.displayToast(qsTr('It require positioning to be active and returning a valid position'))
            return
          }
          
          if (dashBoard.activeLayer.geometryType() != Qgis.GeometryType.Point) {
            mainWindow.displayToast(qsTr('It require the active vector layer to be a point geometry'))
            return
          }

          fieldNames = dashBoard.activeLayer.fields

          fieldSelectionDialog.open()
        } else {
          mainWindow.displayToast(qsTr("Layer '%1' not found").arg(layerName), "warning")
        }
      }
      layerNameInput.text = ""
    }

    onRejected: {
      layerNameInput.text = ""
    }
  }

  Dialog {
    id: fieldSelectionDialog
    parent: mainWindow.contentItem
    title: qsTr("Enter Field Values")
    standardButtons: Dialog.Ok | Dialog.Cancel

    anchors.centerIn: parent
    width: Math.min(600, parent.width)
    height: Math.min(400, parent.height - 50)

    ColumnLayout {
      width: parent.width

      ListView {
        id: fieldListView
        model: ListModel {
          id: fieldListModel
        }
        delegate: Text {
          text: modelData
        }
        Layout.fillWidth: true
        Layout.fillHeight: true
      }

      TextArea {
        id: inputTextArea
        placeholderText: qsTr("Enter field values")
        topPadding: 10
        bottomPadding: 10
        rightPadding: 0
        Layout.fillWidth: true
        Layout.fillHeight: true
        wrapMode: TextInput.Wrap
      }
    }

    onAccepted: {
      parseInputText(inputTextArea.text)
    }

    onRejected: {
      inputTextArea.text = ""
    }

    onOpened: {
      inputTextArea.text = ""
    }

  }

  function parseInputText(inputText) {

    let lines = inputText.split("; ");

    let pos = positionSource.projectedPosition;
    let wkt = 'POINT(' + pos.x + ' ' + pos.y + ')';

    let geometry = GeometryUtils.createGeometryFromWkt(wkt);
    let feature = FeatureUtils.createBlankFeature(dashBoard.activeLayer.fields, geometry);

    for (let i = 0; i < lines.length; i++) {
      let line = lines[i].trim();

      if (line === "") {
        continue;
      }

      let words = line.split(/\s+/);

      let attributeName = words[0];
      let attributeValue = words.slice(1).join(" ");

      feature.setAttribute(fieldNames.indexOf(attributeName), attributeValue)

      
    }

    overlayFeatureFormDrawer.featureModel.feature = feature
    overlayFeatureFormDrawer.featureModel.resetAttributes(true)
    overlayFeatureFormDrawer.state = 'Add'
    overlayFeatureFormDrawer.open()
  }

  function findExistingIndex(attributeName) {
    for (let i = 0; i < fieldListModel.count; i++) {
      if (fieldListModel.get(i).attributeName.toLowerCase() === attributeName.toLowerCase()) {
        return i;
      }
    }
    return -1; // Not found
  }
}