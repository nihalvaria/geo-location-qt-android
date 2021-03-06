import QtQuick 2.12
import QtQuick.Window 2.12
import QtPositioning 5.11
import QtLocation 5.3
import QtQuick.Controls 1.4
import QtQuick.Controls 2.2 as QQ2
import "./geofind.js" as Geofind

Item {
    id: home
    property variant fence: []
    property variant coorx: []
    property variant coory: []
    property real rlat
    property real rlong
    state: "view"

    PositionSource{
        id: pos
        updateInterval: 10000
        active: true
        onPositionChanged: {
            var coord = pos.position.coordinate;
            rlong = coord.longitude;
            rlat = coord.latitude;
            if(fence.length > 2) {
                var isInside =  Geofind.find(fence.length, coorx, coory, rlat, rlong)
                console.log("Inside : ",isInside);
                isInside === true ? map.state = "inside" : map.state = "outside"
            }
        }
    }

    Map {
        id: map
        anchors.fill: parent
        plugin: Plugin { name: "osm"}
        center: QtPositioning.coordinate( rlat, rlong )
        zoomLevel: 14

        MapQuickItem{
            id: marker
            anchorPoint.x: marker.width / 4
            anchorPoint.y: marker.height
            coordinate: QtPositioning.coordinate( rlat, rlong )
            sourceItem: Image{ source: "qrc:/assets/marker.png" }
        }

        MapQuickItem{
            id: pin
            anchorPoint.x: pin.width * 0.50
            anchorPoint.y: pin.height * 0.50
            coordinate: map.center
            sourceItem: Image{
                source: "qrc:/assets/cross.png"
                height: map.height * 0.05
                width: height
            }
        }

        MapPolygon {
            id: poly
            color: 'red'
            opacity: 0.3
            path: fence
        }

        states: [
            State {
                name: "inside"
                PropertyChanges { target: poly; color: "green"; }
            },
            State {
                name: "outside"
                PropertyChanges { target: poly; color: "red"; }
            }

        ]
    }

    SButton{
        id:plusButton
        visible: false
        enabled: false
        source: "assets/plus"
        width: map.width * 0.25
        height: map.height * 0.10
        scale: 1.1
        anchors.bottom: map.bottom
        anchors.left: map.left
        onClicked: {
            let {latitude,longitude} = map.center
            fence.push({ latitude: latitude, longitude: longitude })
            coorx.push(latitude)
            coory.push(longitude)
            poly.path = fence
        }
    }

    SButton{
        id:editButton
        source: "assets/pencil"
        width: map.width * 0.25
        height: map.height * 0.10
        scale: 1.1
        anchors.bottom: map.bottom
        anchors.right: map.right
        onClicked: {
            if(home.state === "view"){
                fence = []
                coorx = []
                coory = []
                poly.path = []
                home.state = "edit"
            } else home.state = "view"
        }

    }
    states :[
        State {
            name: "edit"
            PropertyChanges { target: plusButton; visible: true; enabled: true; }
            PropertyChanges { target: pin; visible: true; enabled: true; }
            PropertyChanges { target: marker; visible: false; enabled: false; }
            PropertyChanges { target: pos; active: false }
        },
        State {
            name: "view"
            PropertyChanges { target: plusButton; visible: false; enabled: false; }
            PropertyChanges { target: pin; visible: false; enabled: false; }
            PropertyChanges { target: marker; visible: true; enabled: true; }
            PropertyChanges { target: pos; active: true }
        }
    ]
}
