import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import QtQuick.LocalStorage 2.0


Page {
    id: page
    allowedOrientations: Orientation.Portrait

    // important variables
    property int countdownMinutesLeft : 0
    property string permittedMinutesChosenZoneText : qsTr("Select")
    property int permittedMinutesTillReset : 0
    property int additionalMinutesToHalfFull : 0
    property int nowIsMinutesOld : 0
    property bool countdownActive : false

    property int setDiskBeginningMinutes : 0
    property int setDiskBeginningHours : 0
    property string setDiskBeginningMinutesText : ""
    property string setDiskBeginningHoursText : ""

    property int currentHours : 0
    property int currentMinutes : 0
    property string currentHoursText : ""
    property string currentMinutesText : ""

    property int targetHours : 0
    property int targetMinutes : 0
    property int discRotateHours : 0
    property int discRotateMinutes : 0
    property string discRotateMinutesText : ""
    property string discRotateHoursText : ""

    property int nowIsHours : 0
    property int nowIsMinutes : 0
    property string nowIsMinutesText : ""
    property string nowIsHoursText : ""


    Component.onCompleted: {
        permittedBonusMinutes = storageItem.get("bonusMin", "30")
        playWarning = storageItem.get("playWarning", "true")
        playAlarm = storageItem.get("playAlarm", "true")
    }

    Timer {
        id: idTimerElement
        interval: 500 //triggers current time update twice per second
        running: true
        repeat: true
        onTriggered: {
            whatTimeIsItNow()
        }
    }
    SoundEffect {
        id: alarmMain
        loops: 45
        source: "/usr/share/sounds/jolla-ambient/stereo/battery_low.wav"
    }
    SoundEffect {
        id: alarmPre
        loops: 3
        source: "/usr/share/sounds/jolla-ambient/stereo/battery_low.wav"
    }


    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            quickSelect: true
            MenuItem {
                text: qsTr("30 min")
                onClicked: {
                    resetThings()
                    resetAndRecalculateTimes("30", qsTr("30 min"))
                }
            }
            MenuItem {
                text: qsTr("1 hour")
                onClicked: {
                    resetThings()
                    resetAndRecalculateTimes("60", qsTr("1 hour"))
                }
            }
            MenuItem {
                text: qsTr("2 hours")
                onClicked: {
                    resetThings()
                    resetAndRecalculateTimes("120", qsTr("2 hours"))
                }
            }
        }

        IconButton {
            width: Theme.itemSizeSmall
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingMedium * 1.25
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            icon.source: "image://theme/icon-m-about?"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("SettingsPage.qml"), { } )
            }
        }

        PageHeader {
            id: idPageHeader
            title: qsTr("Parking Zone") + " - " + permittedMinutesChosenZoneText
            description: nowIsHoursText + ":" + nowIsMinutesText + " " + qsTr("now")
        }


        ProgressCircle {
            id: idProgressCircle
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -page.height/6
            width: Theme.itemSizeExtraLarge
            height:3*Theme.itemSizeExtraLarge
            scale: 2.5
            backgroundColor: Theme.secondaryHighlightColor
            progressColor: Theme.darkPrimaryColor
            inAlternateCycle: false
            value: (permittedMinutesTillReset - countdownMinutesLeft) / permittedMinutesTillReset
            Label {
                id: labelCountdownText
                scale: 0.25
                horizontalAlignment: TextInput.AlignHCenter
                anchors.centerIn: parent
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeHuge
                text: ( countdownMinutesLeft >= 0 ) ? ("<font size=6>" + countdownMinutesLeft + " min" + "</font>" + "<br>" + "<font size=3>" + qsTr("remaining") + "</font>") : ("<font size=6>" + countdownMinutesLeft + " min" + "</font>" + "<br>" + "<font size=3>" + qsTr("exceeding") + "</font>")
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    alarmMain.stop()
                    alarmPre.stop()
                }
            }
        }

        Column {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: page.height/4
            Label {
                color: Theme.highlightColor
                anchors.horizontalCenter: parent.horizontalCenter
                padding: Theme.paddingSmall
                text: qsTr("start")
            }
            Label {
                font.pixelSize: Theme.fontSizeExtraLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: currentHoursText + " : " + currentMinutesText
            }
            Label {
                color: Theme.highlightColor
                anchors.horizontalCenter: parent.horizontalCenter
                padding: Theme.paddingSmall
                text: qsTr("set parking disk")
            }
            Label {
                font.pixelSize: Theme.fontSizeExtraLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: setDiskBeginningHoursText + " : " +setDiskBeginningMinutesText
            }
            Label {
                id: idParkingEndsLabel
                color: Theme.highlightColor
                anchors.horizontalCenter: parent.horizontalCenter
                padding: Theme.paddingSmall
                text: qsTr("end")
            }
            Label {
                font.pixelSize: Theme.fontSizeExtraLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: discRotateHoursText + " : " + discRotateMinutesText
            }
        }
    }


    Item {
        id: storageItem
        function getDatabase() {
           return storageItem.LocalStorage.openDatabaseSync("ParkingDisk", "0.1", "ParkingDiscDatabase", 100);
        }
        function set(setting, value) {
          var db = getDatabase();
          var res = "";
           db.transaction(function(tx) {
             tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
            var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
              if (rs.rowsAffected > 0) {
               res = "OK";
              } else {
               res = "Error";
              }
            }
           );
           return res;
        }
        function get(setting, default_value) {
           var db = getDatabase();
           var res="";
           try {
            db.transaction(function(tx) {
             var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
              if (rs.rows.length > 0) {
               res = rs.rows.item(0).value;
              } else {
               res = default_value;
              }
            })
           } catch (err) {
             //console.log("Database " + err);
            res = default_value;
           };
           return res
        }
    }

    function resetAndRecalculateTimes(selectedMinutes, selectedMinutesText) {
        permittedMinutesChosenZoneText = selectedMinutesText

        var startDate = new Date
        currentHours = startDate.getHours()
        currentMinutes = startDate.getMinutes()
        // add a zero for readability
        if (currentMinutes < 10) {
            currentMinutesText = "0"+currentMinutes
        }
        else {
            currentMinutesText = currentMinutes
        }
        if (currentHours < 10) {
            currentHoursText = "0"+currentHours
        }
        else {
            currentHoursText = currentHours
        }

        // get bonus minutes depending on country regulations
        var additionalMinutesToHalfFull;
        if (permittedBonusMinutes === "0") {
            additionalMinutesToHalfFull = 0
        }
        if (permittedBonusMinutes === "15")  {
            if (currentMinutes < 15) {
                additionalMinutesToHalfFull = (15 - currentMinutes)
            }
            if (currentMinutes >= 15 && currentMinutes < 30) {
                additionalMinutesToHalfFull = (30 - currentMinutes)
            }
            if (currentMinutes >= 30 && currentMinutes < 45) {
                additionalMinutesToHalfFull = (45 - currentMinutes)
            }
            if (currentMinutes >= 45 && currentMinutes < 60) {
                additionalMinutesToHalfFull = (60 - currentMinutes)
            }
        }
        if (permittedBonusMinutes === "30") {
            if (currentMinutes < 30) {
                additionalMinutesToHalfFull = (30 - currentMinutes)
            }
            if (currentMinutes >= 30 && currentMinutes < 60) {
                additionalMinutesToHalfFull = (60 - currentMinutes)
            }
        }
        permittedMinutesTillReset = parseInt(selectedMinutes) + additionalMinutesToHalfFull //"parseInt" makes an INT from a STRING

        // Set Parking-Disk to time (official beginning)
        var setDiskDate = new Date(startDate.getTime() + additionalMinutesToHalfFull*60000)
        setDiskBeginningHours = setDiskDate.getHours()
        setDiskBeginningMinutes = setDiskDate.getMinutes()
        // add a zero for readability
        if (setDiskBeginningMinutes < 10) {
            setDiskBeginningMinutesText = "0"+setDiskBeginningMinutes
        }
        else {
            setDiskBeginningMinutesText = setDiskBeginningMinutes
        }
        if (setDiskBeginningHours < 10) {
            setDiskBeginningHoursText = "0"+setDiskBeginningHours
        }
        else {
            setDiskBeginningHoursText = setDiskBeginningHours
        }

        var endParkingDate = new Date(startDate.getTime() + permittedMinutesTillReset*60000)
        targetHours = endParkingDate.getHours()
        targetMinutes = endParkingDate.getMinutes()
        discRotateMinutes = targetMinutes
        discRotateHours = targetHours
        // add a zero for readability
        if (discRotateMinutes < 10) {
            discRotateMinutesText = "0"+discRotateMinutes
        }
        else {
            discRotateMinutesText = discRotateMinutes
        }
        if (discRotateHours < 10) {
            discRotateHoursText = "0"+discRotateHours
        }
        else {
            discRotateHoursText = discRotateHours
        }

        // Reset the countdown from calculated total parking time
        countdownMinutesLeft = permittedMinutesTillReset
        coverCountdown = countdownMinutesLeft
    }

    function whatTimeIsItNow () {
        var nowIsDate = new Date;
        nowIsHours = nowIsDate.getHours()
        nowIsMinutes = nowIsDate.getMinutes()
        // add a zero for readability
        if (nowIsMinutes < 10) {
            nowIsMinutesText = "0"+nowIsMinutes
        }
        else {
            nowIsMinutesText = nowIsMinutes
        }
        if (nowIsHours < 10) {
            nowIsHoursText = "0"+nowIsHours
        }
        else {
            nowIsHoursText = nowIsHours
        }

        if (nowIsMinutesOld != nowIsMinutes && countdownActive==true) {
            countdownMinutes()
        }
        nowIsMinutesOld = nowIsMinutes
    }

    function countdownMinutes () {
        countdownMinutesLeft = countdownMinutesLeft - 1
        if (countdownMinutesLeft === 5 && playWarning === "true") {
            alarmPre.play()
        }
        if (countdownMinutesLeft === 0 && playAlarm === "true") {
            alarmMain.play()
        }
        if (countdownMinutesLeft <= 5 && countdownMinutesLeft > 0) {
            idProgressCircle.backgroundColor = "orange"
        }
        else if (countdownMinutesLeft === 0) {
            idProgressCircle.progressColor = "orange"
        }
        else if (countdownMinutesLeft < 0) {
            idProgressCircle.progressColor = Theme.errorColor
        }
        else {
            idProgressCircle.backgroundColor = Theme.secondaryHighlightColor
            idProgressCircle.progressColor = Theme.darkPrimaryColor
        }
        coverCountdown = countdownMinutesLeft
    }

    function resetThings() {
        alarmMain.stop()
        alarmPre.stop()
        idProgressCircle.backgroundColor = Theme.secondaryHighlightColor
        idProgressCircle.progressColor = Theme.darkPrimaryColor
        idParkingEndsLabel.color = Theme.highlightColor
        countdownActive = true
    }

}
