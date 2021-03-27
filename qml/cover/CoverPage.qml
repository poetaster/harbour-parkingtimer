import QtQuick 2.0
import Sailfish.Silica 1.0


CoverBackground {
    Image {
        id: idImage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingLarge * 2
        fillMode: Image.PreserveAspectFit
        source: "harbour-parkingtimer.svg"
        scale: 2
    }
    Label {
        id: upperLabel
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: Theme.paddingLarge * 1.8
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Theme.fontSizeExtraLarge
        horizontalAlignment: Text.AlignHCenter
        text: coverCountdown + " " + qsTr("min")
    }
    Label {
        id: lowerLabel
        anchors.top: upperLabel.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        font.pixelSize: Theme.fontSizeExtraSmall
        horizontalAlignment: Text.AlignHCenter
        text: ( coverCountdown >= 0 ) ? qsTr("remaining") : qsTr("exceeding")
    }
}
