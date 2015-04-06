import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import U1db 1.0 as U1db
import "openstack.js" as OpenStack

/*!
    \brief MainView with a Label and Button elements.
*/
MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "testapp2.username"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    anchorToKeyboard: true

    width: units.gu(100)
    height: units.gu(75)

    U1db.Database {
        id: db1
        path: "db1.u1db"
    }

    U1db.Document {
        id: doc1
        database: db1
        docId: "doc1"
        create: true
        defaults: {"authUrl": "http://8.21.28.222:5000/v2.0"}
    }

    property var appModel: {
        "tokenId": '',
        "novaUrl": ''
    }

    ListModel {
        id: novaServersModel

/*
        ListElement {
            name: "Name"
            status: "Status"
        }
*/
    }

    function handleErrorJson(status, statusText, msg) {
        console.error(statusText);
        console.error(msg);

        //PopupUtils.open(msgPopoverComponent, loginButton);
        var dialog = PopupUtils.open(msgDialogComponent);
        // TODO: extract message from JSON
        dialog.text = msg;
    }

    Page {
        title: i18n.tr("OpenStack QML client")

        Column {
            id: column1
            spacing: units.gu(1)
            anchors {
                margins: units.gu(2)
                fill: parent
            }

            Component {
                id: msgDialogComponent
                Dialog {
                    id: msgDialog
                    title: "I haz error"
                    //text: "asd asd asd asd asd"
                    Button {
                        text: "Close"
                        onClicked: PopupUtils.close(msgDialog)
                    }
                }

            }

/*
            Component {
                id: msgPopoverComponent
                Popover {
                    id: msgPopover
                    Column {
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                        }

                        ListItem.Header {
                            text: "I haz error"
                        }
                        ListItem.Standard {
                            text: "zzzzzd"
                        }
                    }
                }
            }
*/

            Label {
                text: i18n.tr("Auth URL")
            }

            TextField {
                id: authUrl
                width: parent.width
                inputMethodHints: Qt.ImhUrlCharactersOnly
                text: doc1.contents.authUrl || ""
            }

            Label {
                text: i18n.tr("Username")
            }

            TextField {
                id: username
                width: parent.width
                text: doc1.contents.username || ""
            }

            Label {
                text: i18n.tr("Password")
            }

            TextField {
                id: password
                width: parent.width
                echoMode: TextInput.Password
                text: doc1.contents.password || ""
            }

            Label {
                text: i18n.tr("Tenant name")
            }

            TextField {
                id: tenantName
                width: parent.width
                text: doc1.contents.tenantName || ""
            }

            Button {
                id: loginButton
                width: parent.width
                text: i18n.tr("Login")

                onClicked: {
                    doc1.contents = {authUrl: authUrl.text, username: username.text, password: password.text, tenantName: tenantName.text};

                    OpenStack.getKeystoneToken(doc1.contents.authUrl, doc1.contents.username,
                                               doc1.contents.password, doc1.contents.tenantName,
                                               function (data) {
                        appModel.tokenId = data["access"]["token"]["id"]
                        // TODO: serach for the url through the endpoints instead of fetching the first one
                        appModel.novaUrl = data["access"]["serviceCatalog"][0]["endpoints"][0]["publicURL"];
                        listServersButton.enabled = true;
                    }, handleErrorJson);
                }
            }

            Button {
                id: listServersButton
                width: parent.width
                text: i18n.tr("List servers")
                enabled: false

                onClicked: {
                    OpenStack.getNovaServers(appModel.novaUrl, appModel.tokenId, function(data) {
                        novaServersModel.clear();
                        var servers = data['servers'];
                        for(var i in servers) {
                            var server = servers[i];
                            console.log(JSON.stringify(server));
                            novaServersModel.append({name: server.name, status: server.status});
                        }
                    }, handleErrorJson);
                }
            }

            /*
            Component {
                id: novaServersDelegate
                Item {
                    width: column1.width
                    height: 28
                    Label {
                        width: column1.width
                        text: name
                    }
                    Label {
                        width: column1.width
                        text: status
                    }
                }
            }
            */

            Rectangle {
                id: r1
                //color: "red"
                width: parent.width
                height: units.gu(15)

                ListView {
                    id: novaServers
                    anchors.fill: parent
                    width: parent.width
                    model: novaServersModel
                    delegate: Text {
                        text: name + ": " + status
                    }
                }
            }


/*
            Button {
                objectName: "button"
                width: parent.width
                onClicked: Qt.quit()
                text: i18n.tr("Quit")
            }
*/
        }
    }
}



