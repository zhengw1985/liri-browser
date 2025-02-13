import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles.Material 0.1
import Material 0.1

Component {
    id: component

    Item {
        id: item
        height: root.tabHeight
        width: editModeActive ? root.tabWidthEdit : root.tabWidth
        property int widthWithClose: editModeActive ? root.tabWidthEdit : root.tabWidth*1.7
        property int widthWithoutClose: editModeActive ? root.tabWidthEdit : root.tabWidth

        property color backgroundColor: itemContainer.state != "dragging" ? "transparent" : page.backgroundColor
        property color textColor: root.privateNav ? "#FAFAFA" : (itemContainer.state == "active")
                                                    &&  !activeTab.customColor ? root.iconColor : (itemContainer.state != "active")
                                                                                 &&  !activeTab.customColor ? Theme.alpha(root.iconColor,0.5) : (itemContainer.state == "active")
                                                                                                              &&  activeTab.customColor ? "white" : Theme.alpha("white", 0.5)
        property alias state: itemContainer.state

        property QtObject modelData: listView.model.get(index)

        property url url: modelData.url

        property bool editModeActive: false

        onEditModeActiveChanged: {
            if (editModeActive) {
                if (activeTabInEditModeItem && activeTabInEditModeItem !== item) {
                    activeTabInEditModeItem.editModeActive = false;
                }

                ensureTabIsVisible(uid);
                canvasEditBackground.height = parent.height;
                itemEditComponents.opacity = 1;
                txtUrl.forceActiveFocus();
                txtUrl.selectAll();

                root.activeTabInEditMode = editModeActive;
                activeTabInEditModeItem = item;
            }
            else {
                canvasEditBackground.height = 0;
                itemEditComponents.opacity = 0;
            }
            root.activeTabInEditMode = editModeActive;
        }


        Item {
            id: itemContainer
            anchors.fill: parent

            property int uid: (index >= 0) ? listView.model.get(index).uid : -1

            state: modelData.state

            states: [
                State {
                    name: "active"
                    StateChangeScript {
                      script: {
                        root.activeTabItem = item;
                      }
                    }
                },

                State {
                    name: "inactive"
                },

                State {
                    name: "dragging"; when: mouseArea.draggingId == itemContainer.uid
                    PropertyChanges {
                        target: rectDefault
                        x: mouseArea.mouseX-rectDefault.width/2;
                        z: 10;
                        parent: listView
                        anchors.fill: null
                        y: item.y
                        width: item.width
                        height: item.height
                    }
                }
            ]

            Rectangle {
                id: rectDefault
                anchors.fill: parent
                visible: !item.editModeActive
                color: backgroundColor
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Units.dp(20)
                    anchors.rightMargin: Units.dp(5)
                    spacing: Units.dp(7)

                    Image {
                        id: icon
                        visible: isAFavicon && !modelData.webview.loading && !modelData.webview.newTabPage && !modelData.webview.settingsTabPage && !modelData.webview.settingsTabPageSitesColors && !modelData.webview.settingsTabPageQuickSearches && modelData.webview.url != "http://liri-browser.github.io/sourcecodeviewer/index.html"
                        width: webview.loading ?  0 : Units.dp(20)
                        height: Units.dp(20)
                        anchors.verticalCenter: parent.verticalCenter
                        source: modelData.webview.icon
                        property var isAFavicon: true
                        onStatusChanged: {
                            if (icon.status == Image.Error || icon.status == Image.Null)
                                isAFavicon = false;
                            else
                                isAFavicon = true;
                        }
                    }

                    Icon {
                        id: iconNoFavicon
                        color:  item.textColor
                        Behavior on color { ColorAnimation { duration : 500 }}
                        name: "action/description"
                        visible: !icon.isAFavicon && !modelData.webview.loading && !modelData.webview.newTabPage && !modelData.webview.settingsTabPage && !modelData.webview.settingsTabPageSitesColors && !modelData.webview.settingsTabPageQuickSearches
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        id: iconDashboard
                        color:  item.textColor
                        Behavior on color { ColorAnimation { duration : 500 }}
                        name: "action/dashboard"
                        visible: modelData.webview.newTabPage
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        id: iconSettings
                        name: "action/settings"
                        color:  item.textColor
                        Behavior on color { ColorAnimation { duration : 500 }}
                        visible: modelData.webview.settingsTabPage || modelData.webview.settingsTabPageSitesColors || modelData.webview.settingsTabPageQuickSearches
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        id: iconSource
                        name: "action/code"
                        color:  item.textColor
                        Behavior on color { ColorAnimation { duration : 500 }}
                        visible: modelData.webview.url == "http://liri-browser.github.io/sourcecodeviewer/index.html"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    LoadingIndicator {
                        id: prgLoading
                        visible: modelData.webview.loading
                        width: webview.loading ? Units.dp(24) : 0
                        height: Units.dp(24)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        id: title
                        text: modelData.webview.title.toUpperCase()
                        color: item.textColor
                        width: parent.width - closeButton.width - icon.width - prgLoading.width - Units.dp(16)
                        elide: Text.ElideRight
                        smooth: true
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: root.fontFamily
                        visible: !root.reduceTabsSizes
                        Behavior on color { ColorAnimation { duration : 500 }}
                    }

                    IconButton {
                        id: closeButton
                        color: item.textColor
                        Behavior on color { ColorAnimation { duration : 500 }}
                        anchors.verticalCenter: parent.verticalCenter
                        visible: {
                            if(modelData.hasCloseButton) {
                               if(root.reduceTabsSizes) {
                                   if(itemContainer.state == "active") {
                                       item.width =  item.widthWithClose
                                       return true
                                    }
                                    else {
                                       item.width =  item.widthWithoutClose
                                       return false
                                    }
                               }
                               else
                                   item.width =  item.widthWithoutClose
                                   return true
                             }
                            else
                                item.width =  item.widthWithoutClose
                                return false
                        }
                        iconName: modelData.closeButtonIconName
                        onClicked: {
                            saveThisTabUrl(modelData.webview.url)
                            console.log(modelData.webview.url)
                            removeTab(uid);
                        }
                    }
                }

                Rectangle {
                    id: rectIndicator
                    color: root.currentIconColor
                    visible: itemContainer.state == "active"
                    height: Units.dp(2)
                    width: parent.width
                    anchors.bottom: parent.bottom
                }

                MouseArea {
                    anchors.fill: parent

                    acceptedButtons: Qt.AllButtons

                    onClicked: {
                        if (mouse.button === Qt.LeftButton) {
                            var isAlreadyActive = (itemContainer.state == "active")
                            root.activeTab = modelData;
                            if (isAlreadyActive && root.app.integratedAddressbars && mouse.x < closeButton.x) {
                                item.editModeActive = true;
                            }
                            mouse.accepted = false;
                        }
                        else if (mouse.button === Qt.MiddleButton) {
                            removeTab(uid);
                        }
                    }
                }
            }
        }

        Rectangle {
            id: rectEdit
            visible: item.editModeActive
            color: backgroundColor

            anchors.fill: parent

            Item {
                id: itemEditComponents
                anchors.fill: parent
                opacity: 0
                z: 1
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }

                IconButton {
                    id: btnGoBack
                    iconName : "navigation/arrow_back"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.margins: Units.dp(16)
                    enabled: modelData.webview.canGoBack

                    onClicked: modelData.webview.goBack()
                    color: root.currentIconColor
                }

                IconButton {
                    id: btnGoForward
                    iconName : "navigation/arrow_forward"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: btnGoBack.right
                    anchors.margins: if (webview.canGoForward) { Units.dp(16) } else { 0 }
                    enabled: modelData.webview.canGoForward
                    visible: modelData.webview.canGoForward
                    width: if (modelData.webview.canGoForward) { Units.dp(24) } else { 0 }

                    Behavior on width {
                        SmoothedAnimation { duration: 200 }
                    }

                    onClicked: modelData.webview.goForward()
                    color: root.currentIconColor
                }

                IconButton {
                    id: btnRefresh
                    visible: !modelData.webview.loading
                    width: Units.dp(24)
                    hoverAnimation: true
                    iconName : "navigation/refresh"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: btnGoForward.right
                    anchors.margins: Units.dp(16)
                    color: root.currentIconColor
                    onClicked: {
                        item.editModeActive = false;
                        modelData.webview.reload();
                    }
                }

                LoadingIndicator {
                    id: prgLoadingEdit
                    visible: modelData.webview.loading
                    width: Units.dp(24)
                    height: Units.dp(24)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: btnGoForward.right
                    anchors.margins: Units.dp(16)
                }

                Icon {
                    id: iconConnectionType
                    name: modelData.webview.secureConnection ? "action/lock" :  "social/public"
                    color:  modelData.webview.secureConnection ? "green" :  root.currentIconColor
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: prgLoadingEdit.right
                    anchors.margins: Units.dp(16)
                }

                TextField {
                    id: txtUrl
                    anchors.margins: Units.dp(5)
                    anchors.left: iconConnectionType.right
                    anchors.right: btnTxtUrlHide.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    text: modelData.webview.url
                    style: TextFieldStyle { textColor: root.iconColor }
                    showBorder: false
                    onAccepted: {
                        item.editModeActive = false;
                        root.setActiveTabURL(text);
                    }
                    onActiveFocusChanged: {
                        if (!activeFocus)
                            item.editModeActive = false;
                    }
                }

                IconButton {
                    id: btnTxtUrlHide
                    color: root.currentIconColor
                    anchors.margins: Units.dp(16)
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    iconName: "hardware/keyboard_return"
                    onClicked: {
                        item.editModeActive = false;
                    }
                }

            }

            Canvas {
                id: canvasEditBackground
                visible: true
                height: 0
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                property color color: "transparent"
                Behavior on height {
                    SmoothedAnimation { duration: 100 }
                }
                onPaint: {
                    // get context to draw with
                    var ctx = getContext("2d");

                    ctx.clearRect(0, 0, width, height);
                    // setup the fill
                    ctx.fillStyle = color;
                    // begin a new path to draw
                    ctx.beginPath();
                    ctx.globalAlpha = 0.2;
                    // top-left start point
                    ctx.moveTo(0,0);
                    ctx.lineTo(width,0);
                    ctx.lineTo(width,height);
                    ctx.lineTo(0,height);
                    ctx.closePath();

                    // fill using fill style
                    ctx.fill();

                    // setup the stroke
                    ctx.strokeStyle = color;
                    ctx.globalAlpha = 1;
                    ctx.lineWidth = Units.dp(1)

                    // create a path
                    ctx.beginPath()
                    ctx.moveTo(0,0)
                    ctx.lineTo(width,0)

                    // stroke path
                    ctx.stroke()
                }
            }

        }

    }
}
