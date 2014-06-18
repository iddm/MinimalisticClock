/*
    Copyright 2013 Anant Kamath <kamathanant@gmail.com>
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This plasmoid is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this plasmoid. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 1.1
import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1 as QtExtraComponents

// import "../code/view.js" as MinimalisticClockView


Item {

    id: mainWindow
    property int minimumHeight: 160
    property int minimumWidth: 260
    property string textColor
    property string textFont
    /*readonly*/ property string defaultDateStringFormat: "dddd, d MMMM"
    property string dateStringFormat: defaultDateStringFormat
    property bool fullTimeFormat: true
    property bool showSeconds: false
    property string timeString
    property int timeStringFontSize: 72
    property int ampmStringFontSize: 48
    property int dateStringFontSize: 32
    property double defaultHalfTimeSuffixOpacity: 0.5
    property int fontStyleName: 0
    property string fontStyleColor: "black"
    property string textAlignment: "AlignHCenter"
    property variant view: MinimalisticClockView.MinimalisticClockView(mainWindow)
          
    Component.onCompleted: {    
        plasmoid.setBackgroundHints( 0 );
        plasmoid.addEventListener( 'ConfigChanged', configChanged ); 
            
        configChanged();
    }
    
    function configChanged() {    
        textColor = plasmoid.readConfig( "textColor" )
        textFont = plasmoid.readConfig( "textFont" )
        
        timeStringFontSize = plasmoid.readConfig( "timeStringFontSize" )   
        ampmStringFontSize = plasmoid.readConfig( "ampmStringFontSize" )   
        dateStringFontSize = plasmoid.readConfig( "dateStringFontSize" )   
        dateStringFormat = plasmoid.readConfig( "dateStringFormat" )  
        fontStyleName = plasmoid.readConfig( "fontStyleName" ) 
        fontStyleColor = plasmoid.readConfig( "fontStyleColor" ) 
        
        updateTimeFormat()
        updateTextAlignment()
    }
    
    function updateTextAlignment() {
        var selectedTextAlignment = plasmoid.readConfig( "textAlignment" ) 
        
        if (selectedTextAlignment == 0) {
            textAlignment = "AlignLeft"
            
            time.anchors.horizontalCenter = undefined
            time.anchors.right = undefined
            time.anchors.horizontalCenterOffset = 0
            time.anchors.rightMargin = 0
            time.anchors.left = time.parent.left;
            
            ampm.anchors.left = time.right
        } else if (selectedTextAlignment == 1) {
            textAlignment = "AlignHCenter"
            
            time.anchors.left = undefined
            time.anchors.right = undefined
            time.anchors.horizontalCenter = time.parent.horizontalCenter
            
            if (!fullTimeFormat) {
                time.anchors.horizontalCenterOffset = -ampm.paintedWidth / 2
                time.anchors.rightMargin = 0
            } else {                
                time.anchors.horizontalCenterOffset = 0
                time.anchors.rightMargin = 0
            }
            
            ampm.anchors.left = time.right
        } else {
            textAlignment = "AlignRight"
            
            time.anchors.horizontalCenter = undefined
            time.anchors.left = undefined
            time.anchors.horizontalCenterOffset = 0
            
            if (!fullTimeFormat) {
                time.anchors.rightMargin = ampm.paintedWidth
            } else {                
                time.anchors.horizontalCenterOffset = 0
                time.anchors.rightMargin = 0
            }
            
            time.anchors.right = time.parent.right
            
            ampm.anchors.left = time.right
        }      
    }
    
    function updateTimeFormat() {
        showSeconds = plasmoid.readConfig( "showSeconds" )
        fullTimeFormat = plasmoid.readConfig( "timeFormat" )
        
        updateTime()
    }

    function updateTime() {
        var format = "hh:mm"
        
        if (showSeconds) {
            format += ":ss"                  
        }
        
        if (fullTimeFormat) {
            timeString = (Qt.formatTime( dataSource.data["Local"]["Time"], format ))
            ampm.opacity = 0;
            
        } else {
            format += "ap";
            ampm.opacity = defaultHalfTimeSuffixOpacity;      
            
            timeString = (Qt.formatTime( dataSource.data["Local"]["Time"], format )).toString().slice(0, -2)
        } 
    }
    
            
    Text {
        id: time
        font.family:textFont
        font.bold: true
        color: textColor
        font.pointSize: timeStringFontSize
        text : timeString
        style: fontStyleName
        styleColor: fontStyleColor
        anchors {
            top: parent.top;
        }
    }    
    
    Text {
        id: ampm
        font.family:textFont
        opacity: defaultHalfTimeSuffixOpacity
        color: textColor
        font.pointSize: ampmStringFontSize
        text : Qt.formatTime( dataSource.data["Local"]["Time"],"ap" )
        style: fontStyleName
        styleColor: fontStyleColor
        horizontalAlignment: textAlignment
        anchors {
            top: parent.top;
        }
    }  
        
    Text {
        id: date
        font.family:textFont
        color: textColor
        font.pointSize: dateStringFontSize
        text : Qt.formatDate( dataSource.data["Local"]["Date"], dateStringFormat )
        style: fontStyleName
        styleColor: fontStyleColor
        horizontalAlignment: textAlignment
        textFormat: Text.RichText
        
        wrapMode: Text.WordWrap
        anchors {
            top: time.bottom;
            left: parent.left;
            right: parent.right;
        }
    }

    PlasmaCore.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 500
        
        onNewData: {
            updateTime()
        }
    }
}