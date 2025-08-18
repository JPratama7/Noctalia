pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.Commons
import qs.Widgets

Row {
  id: root

  anchors.verticalCenter: parent ? parent.verticalCenter : undefined
  spacing: Style.marginSmall

  property int iconSize: Math.max(16, Math.floor((parent ? parent.height : Style.barHeight) * 0.7))
  // Inherit scaling from parent bar if available; fallback to 1
  property real scaling: (parent && parent.scaling !== undefined) ? parent.scaling : 1

  NTooltip {
    id: appTooltip
    visible: false
    positionAbove: true
  }

  Rectangle {
    // Size to content with horizontal padding
    width: row.width + Style.marginMedium * root.scaling * 2
    
    height: Math.round(Style.barHeight * 0.75 * root.scaling)
    radius: Math.round(Style.radiusMedium * root.scaling)
    color: Color.mSurfaceVariant
    border.color: Color.mOutline
    border.width: Math.max(1, Math.round(Style.borderThin * root.scaling))
    
    anchors.verticalCenter: parent.verticalCenter

    Item {
      id: mainContainer
      anchors.fill: parent
      anchors.leftMargin: Style.marginSmall * root.scaling
      anchors.rightMargin: Style.marginSmall * root.scaling

      Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        // Remove horizontal center to match SystemMonitor's layout
        spacing: Style.marginSmall * root.scaling

        Repeater {
          model: ToplevelManager ? ToplevelManager.toplevels : null

          delegate: Item {
            id: appButton
            width: root.iconSize
            height: root.iconSize

            required property var modelData
            property bool isActive: !!(ToplevelManager && ToplevelManager.activeToplevel === modelData)
            property bool hovered: mouseArea.containsMouse
            property string appId: modelData ? modelData.appId : ""
            property string appTitle: modelData ? modelData.title : ""

            property url iconSource: {
              let icon = Quickshell.iconPath(appId?.toLowerCase(), true)
              if (!icon) icon = Quickshell.iconPath(appId, true)
              if (!icon) icon = Quickshell.iconPath(appTitle?.toLowerCase(), true)
              if (!icon) icon = Quickshell.iconPath(appTitle, true)
              return icon || Quickshell.iconPath("application-x-executable", true)
            }
            
            Rectangle {
              anchors.fill: parent
              radius: Style.radiusSmall
              // Subtle hover overlay on top of background
              color: Color.mPrimary
              opacity: appButton.hovered ? 0.12 : 0
              Behavior on opacity { NumberAnimation { duration: Style.animationFast; easing.type: Easing.OutQuad } }
            }


            IconImage {
              id: appIcon
              anchors.centerIn: parent
              width: root.iconSize
              height: root.iconSize
              source: appButton.iconSource
              visible: appButton.iconSource.toString() !== ""
              scale: appButton.hovered ? 1.1 : 1.0
              Behavior on scale { NumberAnimation { duration: Style.animationFast; easing.type: Easing.OutBack } }
            }

            // Fallback glyph if no icon
            NText {
              anchors.centerIn: parent
              visible: !appIcon.visible
              text: "question_mark"
              font.family: "Material Symbols Rounded"
              font.pointSize: Math.floor(root.iconSize * 0.7)
              color: appButton.isActive ? Color.mPrimary : Color.mOnSurfaceVariant
              scale: appButton.hovered ? 1.1 : 1.0
              Behavior on scale { NumberAnimation { duration: Style.animationFast; easing.type: Easing.OutBack } }
            }

            // Click / hover handling
            MouseArea {
              id: mouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              acceptedButtons: Qt.LeftButton

              onEntered: {
                const appName = appButton.appTitle || appButton.appId || "Unknown"
                appTooltip.text = appName.length > 40 ? appName.substring(0, 37) + "..." : appName
                appTooltip.target = appButton
                appTooltip.isVisible = true
              }
              onExited: appTooltip.hide()

              onClicked: function(mouse) {
                if (mouse.button === Qt.LeftButton && appButton.modelData?.activate) {
                  appButton.modelData.activate()
                }
              }
            }

            // Active indicator
            Rectangle {
              visible: appButton.isActive
              width: Math.floor(root.iconSize * 0.75)
              height: 3
              color: Color.mPrimary
              radius: Style.radiusTiny
              anchors.top: parent.bottom
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.topMargin: Style.marginTiniest
            }
          }
        }
      }
    }
  }
}
