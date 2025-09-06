import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services

NIconButton {
  id: root

  property ShellScreen screen
  property real scaling: ScalingService.scale(screen)

  icon: IdleInhibitorService.isInhibited ? "wb_sunny" : "moon_stars"
  tooltipText: IdleInhibitorService.isInhibited 
    ? "Keep Awake: Active\n" + IdleInhibitorService.reason 
    : "Keep Awake: Inactive\nClick to prevent system sleep"
  sizeRatio: 0.8

  colorBg: IdleInhibitorService.isInhibited ? Color.mPrimary : Color.mSurfaceVariant
  colorFg: IdleInhibitorService.isInhibited ? Color.mOnPrimary : Color.mOnSurface
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent

  anchors.verticalCenter: parent.verticalCenter
  onClicked: IdleInhibitorService.manualToggle()
}
