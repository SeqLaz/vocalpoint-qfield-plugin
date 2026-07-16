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
    property var overlayFeatureFormDrawer: iface.findItemByObjectName(
                                               'overlayFeatureFormDrawer')
    property var fields: undefined

    Component.onCompleted: {
        iface.addItemToPluginsToolbar(selectLayerButton)
    }

    QfToolButton {
        id: selectLayerButton
        bgcolor: Theme.darkGray
        iconSource: "icon.svg"
        iconColor: Theme.mainColor
        round: true

        onClicked: {
            updateLayers()
            vocalEntryDialog.open()
        }
    }

    Dialog {
        id: vocalEntryDialog
        parent: mainWindow.contentItem
        title: qsTr("Vocal Entry")
        standardButtons: Dialog.Ok | Dialog.Cancel

        anchors.centerIn: parent
        width: Math.min(700, parent.width * 0.9)
        height: Math.min(dialogLayout.childrenRect.height + 120, parent.height - Theme.popupScreenEdgeMargin * 2)

        ColumnLayout {
            id: dialogLayout
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10

            Label {
                Layout.fillWidth: true;
                wrapMode: TextInput.Wrap
                text: qsTr("Select a point layer")
                font: Theme.defaultFont
                color: Theme.mainTextColor
            }
            
            ComboBox {
                id: layerSelector
                Layout.fillWidth: true
                model: []
                enabled: model.length > 0
                
                onCurrentIndexChanged: {
                    const layerName = layerSelector.currentText
                    if (layerName != "") {
                        const layer = qgisProject.mapLayersByName(layerName)[0]
                        if (layer) {
                            dashBoard.activeLayer = layer
                            mainWindow.displayToast(
                                        qsTr("Layer '%1' set as active").arg(layerName))

                            plugin.fields = dashBoard.activeLayer.fields
                            fieldNamesHelper.text = plugin.fields.names.join('; ')
                        }
                    }
                }
            }
            
            Label {
                Layout.fillWidth: true;
                Layout.preferredWidth: parent.width
                wrapMode: TextInput.Wrap
                text: qsTr("Use speech-to-text to enter field names and values with a name and values separated by a space and fields separated by semicolon (;).")
                font.pointSize: Theme.tipFont.pointSize
                color: Theme.mainTextColor
            }
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight:  true
                Layout.maximumHeight: 200

                TextArea {
                    id: inputTextArea
                    bottomPadding: 10
                    wrapMode: TextInput.Wrap
                }
            }
            
            Label {
                id: fieldNamesHelper
                visible: text.length > 0
                Layout.fillWidth: true;
                Layout.minimumWidth: 0
                Layout.preferredWidth: dialogLayout.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pointSize: Theme.tipFont.pointSize
                font.italic: true
                color: Theme.secondaryTextColor
            }
        }

        onOpened: {
            inputTextArea.text = ""
        }

        onAccepted: {
            if (!positionSource.active
                    || !positionSource.positionInformation.latitudeValid
                    || !positionSource.positionInformation.longitudeValid) {
                mainWindow.displayToast(
                            qsTr('It requires positioning to be active and returning a valid position'))
                return
            }

            parseInputText(inputTextArea.text)
        }

        onRejected: {
            inputTextArea.text = ""
        }
    }

    function updateLayers() {
        var layers = ProjectUtils.mapLayers(qgisProject)
        var editableLayers = []

        for (var id in layers) {
            var layer = layers[id]

            if (layer && layer.supportsEditing && layer.geometryType && layer.geometryType() == Qgis.GeometryType.Point) {
                editableLayers.push(layer.name)
            }
        }

        editableLayers.sort()
        layerSelector.model = editableLayers
        layerSelector.currentIndex = -1
        if (editableLayers.length > 0) {
            layerSelector.currentIndex = 0
        }
    }

    function parseInputText(inputText) {
        let lines = inputText.split(";")

        let pos = positionSource.projectedPosition
        let wkt = 'POINT(' + pos.x + ' ' + pos.y + ')'

        let geometry = GeometryUtils.createGeometryFromWkt(wkt)
        let feature = FeatureUtils.createBlankFeature(
                dashBoard.activeLayer.fields, geometry)

        for (var i = 0; i < lines.length; i++) {
            let line = lines[i].trim()

            if (line === "") {
                continue
            }

            let words = line.split(/\s+/)

            let attributeName = words[0].toLowerCase()
            let firstWord = convertToTitleCase(words[1])
            let attributeValue = [firstWord].concat(words.slice(2)).join(" ")

            let attributeIndex = plugin.fields.indexOf(attributeName)

            if (attributeIndex === -1) {
                mainWindow.displayToast(qsTr("Attribute '%1' not found").arg(
                                            attributeName), "warning")
                continue
            }

            feature.setAttribute(attributeIndex, attributeValue)
        }

        overlayFeatureFormDrawer.featureModel.feature = feature
        overlayFeatureFormDrawer.featureModel.resetAttributes(true)
        overlayFeatureFormDrawer.state = 'Add'
        overlayFeatureFormDrawer.open()
    }

    function convertToTitleCase(word) {
        if (!word) {
            return word
        }

        if (!isNaN(word)) {
            return word
        }

        return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
    }
}
