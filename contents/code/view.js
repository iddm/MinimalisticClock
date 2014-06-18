function MinimalisticClockView(view) {
    this._view = view
}

MinimalisticClockView.prototype.configChanged = function() {
    this._view.textColor = plasmoid.readConfig( "textColor" )
    this._view.textFont = plasmoid.readConfig( "textFont" )
    
    this._view.timeStringFontSize = plasmoid.readConfig( "timeStringFontSize" )   
    this._view.ampmStringFontSize = plasmoid.readConfig( "ampmStringFontSize" )   
    this._view.dateStringFontSize = plasmoid.readConfig( "dateStringFontSize" )   
    this._view.dateStringFormat = plasmoid.readConfig( "dateStringFormat" )  
    this._view.fontStyleName = plasmoid.readConfig( "fontStyleName" ) 
    this._view.fontStyleColor = plasmoid.readConfig( "fontStyleColor" ) 
    
    this.updateTimeFormat()
    this.updateTextAlignment()
};

MinimalisticClockView.prototype.updateTextAlignment = function() {
    var selectedTextAlignment = plasmoid.readConfig( "textAlignment" ) 
    
    if (selectedTextAlignment == 0) {
        this._view.textAlignment = "AlignLeft"
        
        this._view.time.anchors.horizontalCenter = undefined
        this._view.time.anchors.right = undefined
        this._view.time.anchors.horizontalCenterOffset = 0
        this._view.time.anchors.rightMargin = 0
        this._view.time.anchors.left = this._view.time.parent.left;
        
        this._view.ampm.anchors.left = this._view.time.right
    } else if (selectedTextAlignment == 1) {
        this._view.textAlignment = "AlignHCenter"
        
        this._view.time.anchors.left = undefined
        this._view.time.anchors.right = undefined
        this._view.time.anchors.horizontalCenter = this._view.time.parent.horizontalCenter
        
        if (!this._view.fullTimeFormat) {
            this._view.time.anchors.horizontalCenterOffset = -this._view.ampm.paintedWidth / 2
            this._view.time.anchors.rightMargin = 0
        } else {                
            this._view.time.anchors.horizontalCenterOffset = 0
            this._view.time.anchors.rightMargin = 0
        }
        
        this._view.ampm.anchors.left = this._view.time.right
    } else {
        this._view.textAlignment = "AlignRight"
        
        this._view.time.anchors.horizontalCenter = undefined
        this._view.time.anchors.left = undefined
        this._view.time.anchors.horizontalCenterOffset = 0
        
        if (!this._view.fullTimeFormat) {
            this._view.time.anchors.rightMargin = this._view.ampm.paintedWidth
        } else {                
            this._view.time.anchors.horizontalCenterOffset = 0
            this._view.time.anchors.rightMargin = 0
        }
        
        this._view.time.anchors.right = this._view.time.parent.right
        
        this._view.ampm.anchors.left = this._view.time.right
    }        
};

MinimalisticClockView.prototype.updateTimeFormat = function() {

    this._view.showSeconds = plasmoid.readConfig( "showSeconds" )
    this._view.fullTimeFormat = plasmoid.readConfig( "timeFormat" )
    
    this.updateTime()
};

MinimalisticClockView.prototype.updateTime = function() {
    var format = "hh:mm"
    
    if (this._view.showSeconds) {
        format += ":ss"                  
    }
    
    if (this._view.fullTimeFormat) {
        this._view.timeString = (Qt.formatTime( this._view.dataSource.data["Local"]["Time"], this._view.format ))
        this._view.ampm.opacity = 0;
        
    } else {
        format += "ap";
        this._view.ampm.opacity = this._view.defaultHalfTimeSuffixOpacity;      
        
        this._view.timeString = (Qt.formatTime( this._view.dataSource.data["Local"]["Time"], this._view.format )).toString().slice(0, -2)
    } 
};