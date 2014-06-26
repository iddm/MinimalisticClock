import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras


PlasmaComponents.CommonDialog {
    id: root

    titleText: "Time zone"
    property alias model: listView.model

    property int selectedIndex: -1
    property Component delegate: defaultDelegate
    signal itemSelected(variant modelItem)
    
    PlasmaCore.Theme {
        id: plasmaTheme
    }
    
    Component {
        id: defaultDelegate
        
        PlasmaComponents.ListItem {   
            visible: model["Timezone"].search(RegExp(filterField.filterText, "i")) != -1
            height: visible ? (timeZoneName.paintedHeight * 2) : 0
            anchors.left: parent.left;
            anchors.right: parent.right
            
            
            Item {                
                Keys.onPressed: {
                    if (event.key == Qt.Key_Up || event.key == Qt.Key_Down)
                        scrollBar.flash()
                }
                
                Text {
                    id: timeZoneName
                    
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    
                    text: model["Timezone Continent"] + " - " + model["Timezone City"]
                    
                    color: plasmaTheme.textColor
                    
                    property bool selected: selectedIndex == index
                    onSelectedChanged: {
                        if (selected) {
                            color = "#00A6FF"
                        } else {
                            color = plasmaTheme.textColor
                        }
                    }
                }
            }
            
            MouseArea {
                anchors.fill: parent
                
                onDoubleClicked: {
                    selectedIndex = index
//                     var timeZoneObject = timeZoneDataModel.get(index)
//                     var modelItem = timeZoneDataSource.data[timeZoneObject]
                    var source;
                    
                    for (var i = 0; i < timeZoneDataSource.sources.length; i++) {
                        if (timeZoneDataSource.data[timeZoneDataSource.sources[i]]["Timezone"] == model["Timezone"]) {
                            source = timeZoneDataSource.sources[i];
                            
                            break;
                        }
                    }

//                     var modelItem = timeZoneDataSource.sources[index]
//                     root.itemSelected(timeZoneObject["Timezone"])            
                    root.itemSelected(source)
                    root.accept()
                }
                
                onClicked: {
                    selectedIndex = index
                }
            }
        }
    }

    content: Item {
        id: contentItem
        property alias filterText: filterField.filterText
        implicitWidth: theme.defaultFont.mSize.width * 40
        implicitHeight: theme.defaultFont.mSize.height * 12
        height: implicitHeight

        PlasmaComponents.TextField {
            id: filterField
            property string filterText
            clearButtonShown: true
            onTextChanged: {
                searchTimer.restart();
            }
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            Timer {
                id: searchTimer
                running: false
                repeat: false
                interval: 500
                onTriggered: filterField.filterText = filterField.text
            }
        }
        ListView {
            id: listView

            anchors {
                top: filterField.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            currentIndex : -1
            delegate: root.delegate
            clip: true

            Keys.onPressed: {
                if (event.key == Qt.Key_Up || event.key == Qt.Key_Down
                    || event.key == Qt.Key_Left || event.key == Qt.Key_Right
                    || event.key == Qt.Key_Select || event.key == Qt.Key_Enter
                    || event.key == Qt.Key_Return) {
                    listView.currentIndex = 0
                    event.accepted = true
                }
            }
            
            model: PlasmaCore.SortFilterModel {
                id: sortedDataModel            
                
                sortRole: "Timezone"
                sortOrder: "AscendingOrder"
                    
                sourceModel: PlasmaCore.DataModel {
                    id: timeZoneDataModel

                    dataSource: PlasmaCore.DataSource {
                        id: timeZoneDataSource
                        engine: "time"
                        connectedSources: sources
                        interval: 0
                    }
                }    
            }
//             model: PlasmaCore.DataModel {
//                 id: timeZoneDataModel
// 
//                 dataSource: PlasmaCore.DataSource {
//                     id: timeZoneDataSource
//                     engine: "time"
//                     connectedSources: sources
//                     interval: 0
//                 } 
//             }
        }

        PlasmaComponents.ScrollBar {
            id: scrollBar
            flickableItem: listView
            visible: listView.contentHeight > contentItem.height
            anchors { top: listView.top; right: contentItem.right }
        }
    }

    onClickedOutside: {
        reject()
    }

    Timer {
        id: focusTimer
        interval: 100
        onTriggered: {
            filterField.forceActiveFocus()
        }
    }
    onStatusChanged: {
        //FIXME: why needs focus deactivation then activation?
        if (status == DialogStatus.Open) {
            filterField.focus = false
            focusTimer.running = true
        }

        if (status == DialogStatus.Opening) {
            if (listView.currentItem != null) {
                listView.currentItem.focus = false
            }
            listView.currentIndex = -1
            listView.positionViewAtIndex(0, ListView.Beginning)
        } else if (status == DialogStatus.Open) {
            listView.focus = true
        }
    }
}