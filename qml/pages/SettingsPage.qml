import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import QtGraphicalEffects 1.0
import QtQuick.LocalStorage 2.0


Dialog {
    id: page
    allowedOrientations: Orientation.Portrait
    Component.onCompleted: {
        if (permittedBonusMinutes === "0") {
            idComboBoxBonusMin.currentIndex = 0
        }
        if (permittedBonusMinutes === "15") {
            idComboBoxBonusMin.currentIndex = 1
        }
        if (permittedBonusMinutes === "30") {
            idComboBoxBonusMin.currentIndex = 2
        }

        if (playWarning === "true") {
            idPlayWarning.currentIndex = 0
        }
        if (playWarning === "false") {
            idPlayWarning.currentIndex = 1
        }

        if (playAlarm === "true") {
            idPlayAlarm.currentIndex = 0
        }
        if (playAlarm === "false") {
            idPlayAlarm.currentIndex = 1
        }
    }

    Column {
        width: page.width
        DialogHeader { }


        Row {
            x: Theme.paddingLarge
            width: parent.width - 2 * Theme.paddingLarge

            Label {
                id: idTextBonusMinText

                width: parent.width / 6 * 3.8
                anchors.top: parent.top
                anchors.topMargin: Theme.paddingMedium * 1.5 //1.75
                font.pixelSize: Theme.fontSizeMedium
                text: qsTr("Country-specific interval")
            }

            ComboBox {
                id: idComboBoxBonusMin
                //width: parent.width / 6 * 2.2
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("precise")

                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        text: qsTr("15 min")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        text: qsTr("30 min")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }
        }


        Label {
            x: Theme.paddingLarge
            width: parent.width - 2 * Theme.paddingLarge
            font.pixelSize: Theme.fontSizeTiny
            wrapMode: TextEdit.Wrap
            text: qsTr("Set your parking disc's starting time ahead according to local regulations in order to calculate total parking time.") + "\n"
                  + qsTr("* 30 min interval, e.g. Germany") + "\n"
                  + qsTr("* 15 min interval, e.g. Austria") + "\n"
                  + qsTr("* precise parking time") + "\n"
        }

        Row {
            x: Theme.paddingLarge
            width: parent.width - 2 * Theme.paddingLarge
            Label {
                id: idPlayWarningText
                width: parent.width / 6 * 3.8
                anchors.top: parent.top
                anchors.topMargin: Theme.paddingMedium * 1.5
                font.pixelSize: Theme.fontSizeMedium
                text: qsTr("Warning (5 min)")
            }
            ComboBox {
                id: idPlayWarning
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("yes")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        text: qsTr("no")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }
        }

        Row {
            x: Theme.paddingLarge
            width: parent.width - 2 * Theme.paddingLarge
            Label {
                id: idPlayAlarmText
                width: parent.width / 6 * 3.8
                anchors.top: parent.top
                anchors.topMargin: Theme.paddingMedium * 1.5
                font.pixelSize: Theme.fontSizeMedium
                text: qsTr("Alarm")
            }
            ComboBox {
                id: idPlayAlarm
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("yes")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        text: qsTr("no")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }
        }
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            if (idPlayWarning.currentIndex === 0) {
                storageItem.set("playWarning", "true")
                playWarning = "true"
            }
            if (idPlayWarning.currentIndex === 1) {
                storageItem.set("playWarning", "false")
                playWarning = "false"
            }


            if (idPlayAlarm.currentIndex === 0) {
                storageItem.set("playAlarm", "true")
                playAlarm = "true"
            }
            if (idPlayAlarm.currentIndex === 1) {
                storageItem.set("playAlarm", "false")
                playAlarm = "false"
            }


            if (idComboBoxBonusMin.currentIndex === 0) {
                storageItem.set("bonusMin", "0")
                permittedBonusMinutes = "0"
            }
            if (idComboBoxBonusMin.currentIndex === 1) {
                storageItem.set("bonusMin", "15")
                permittedBonusMinutes = "15"
            }
            if (idComboBoxBonusMin.currentIndex === 2) {
                storageItem.set("bonusMin", "30")
                permittedBonusMinutes = "30"
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


}
