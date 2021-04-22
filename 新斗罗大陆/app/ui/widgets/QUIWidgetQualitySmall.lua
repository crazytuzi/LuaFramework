local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetQualitySmall = class("QUIWidgetQualitySmall", QUIWidget)

function QUIWidgetQualitySmall:ctor(options)
	local ccbFile = "ccb/Widget_Hero_pingzhi_small.ccbi"
	local callBacks = {
    }
	QUIWidgetQualitySmall.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetQualitySmall:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_a, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_a, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_a1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_a2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.pingzhi_b, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.pingzhi_c, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner["pingzhi_a+"], self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_s, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_s, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_ss, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_ss, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s4, self._glLayerIndex)
	return self._glLayerIndex
end

function QUIWidgetQualitySmall:setQuality(quality)
    q.setAptitudeShow(self._ccbOwner, quality)
end

function QUIWidgetQualitySmall:cleanQuality()
    q.setAptitudeShow(self._ccbOwner)
end

return QUIWidgetQualitySmall