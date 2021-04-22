local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetInstanceProgress = class("QUIWidgetInstanceProgress", QUIWidget)

function QUIWidgetInstanceProgress:ctor(options)
	local ccbFile = "ccb/Widget_InstanceFuliProgress.ccbi"
	local callbacks = {}
	QUIWidgetInstanceProgress.super.ctor(self, ccbFile, callbacks, options)
    self._initScaleX = self._ccbOwner.node_bar:getScaleX()
end

function QUIWidgetInstanceProgress:updateProgress(cur, total, isPercentage)
    local sx = cur / total * self._initScaleX
    self._ccbOwner.node_bar:setScaleX( sx )
    if isPercentage then
        self._ccbOwner.tf_progress:setString( math.floor((cur / total)* 100) .."%" )
    else
        self._ccbOwner.tf_progress:setString(cur .. "/" .. total)
    end
end

return QUIWidgetInstanceProgress