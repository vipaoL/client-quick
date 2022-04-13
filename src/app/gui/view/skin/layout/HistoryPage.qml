import QtQuick 1.0
import com.nokia.symbian 1.0
import ru.curoviyxru.kutegram 1.0

Page {
    property alias peer: dataModel.peer

    id: root

    ListView {
        id: dialogsView
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: messageField.top; }
        cacheBuffer: height
        clip: true
        focus: true

        model: HistoryListModel {
            id: dataModel
            client: telegram

            property int lastSize: 0

            onLoadingMessages: {
                dialogsView.interactive = false;
                dialogsView.positionViewAtIndex(0, ListView.Beginning);
            }

            onLoadedMessages: {
                dialogsView.positionViewAtIndex(Math.min(dialogsView.count - lastSize, dialogsView.count - 1), ListView.Beginning);
                dialogsView.interactive = true;
                lastSize = dialogsView.count;
            }

            property bool atYEnd: false

            onAddingMessage: {
                atYEnd = dialogsView.atYEnd;
            }

            onAddedMessage: {
                if (atYEnd)
                    dialogsView.positionViewAtIndex(dialogsView.count - 1, ListView.End);
                atYEnd = false;
            }
        }

        //TODO: delegate
        delegate: Column {
            anchors { left: parent.left; right: parent.right; margins: platformStyle.paddingLarge; }
            ListItemText {
                id: titleText
                anchors { left: parent.left; right: parent.right; }
                role: "Title"
                text: title
            }
            ListItemText {
                id: subtitleText
                anchors { left: parent.left; right: parent.right; }
                role: "SubTitle"
                elide: Text.ElideNone
                wrapMode: Text.Wrap
                text: message
            }
        }

        onMovementEnded: {
            if (dialogsView.atYBeginning) {
                dataModel.tryLoadUpwards();
            }
        }

        ScrollDecorator {
            flickableItem: parent
        }
    }

    TextArea {
        id: messageField
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
        placeholderText: "Type a message..."
    }

    tools: ToolBarLayout {
        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ToolButton {
            flat: true
            iconSource: "qrc:/icons/create_message.svg"
            onClicked: {
                dataModel.sendMessage(messageField.text);
                messageField.text = "";
            }
        }

        ToolButton {
            flat: true
            iconSource: "toolbar-menu"
            onClicked: {
                optionsMenu.open();
            }

            Menu {
                id: optionsMenu
                content: MenuLayout {
                    MenuItem {
                        text: "Test option"
                        onClicked: {

                        }
                    }
                    MenuItem {
                        text: "Test option"
                        onClicked: {

                        }
                    }
                    MenuItem {
                        text: "Test option"
                        onClicked: {

                        }
                    }
                }
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            dataModel.tryLoadUpwards();
        }
    }
}
