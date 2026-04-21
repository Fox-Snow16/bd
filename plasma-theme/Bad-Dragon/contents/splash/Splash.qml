import QtQuick 2.5

Image {
    id: root
    source: "images/background.png"
    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true
        }
    }

    Image {
        id: topRect
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height
        source: "images/rectangle.svg"

        Image {
            id: logo
            source: "images/baddragon.svg"
            anchors.centerIn: parent
            scale: 1.75
            smooth: true
            mipmap: true
        }

        // Progress bar background (scaled by 1.25)
        Rectangle {
            id: barBackground
            radius: 5 // Slightly increased radius for the larger size
            color: "#2B1A1A"
            anchors {
                bottom: parent.bottom
                // Lowered to -100 to account for the larger bar and logo scale
                bottomMargin: -100 
                horizontalCenter: parent.horizontalCenter
            }
            // Height increased from 6 to 7.5
            height: 7.5
            // Total width is now 1.25x larger
            width: height * 50

            // The loading fill
            Rectangle {
                id: barFill
                radius: 4
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: stage > 0 ? (parent.width / 6) * stage : 0
                color: "#5e0000" 
                
                Behavior on width { 
                    PropertyAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: introAnimation
        running: false

        ParallelAnimation {
            PropertyAnimation {
                property: "y"
                target: topRect
                to: root.height / 3
                duration: 1000
                easing.type: Easing.InOutBack
                easing.overshoot: 1.0
            }
            
            PropertyAnimation {
                property: "opacity"
                target: root
                to: 1
                duration: 1000
            }
        }
    }
}
