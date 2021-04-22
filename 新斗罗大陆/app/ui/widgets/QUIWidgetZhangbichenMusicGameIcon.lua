--
-- Kumo.Wang
-- zhangbichen主题曲活动——音游主界面Icon
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetZhangbichenMusicGameIcon = class("QUIWidgetZhangbichenMusicGameIcon", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetZhangbichenMusicGameIcon.EVENT_CLICK = "QUIWidgetZhangbichenMusicGameIcon.EVENT_CLICK"

function QUIWidgetZhangbichenMusicGameIcon:ctor(options)
	local ccbFile = "ccb/Widget_Music_Game_zhangbichen_icon.ccbi"
	local callBacks = {}
	QUIWidgetZhangbichenMusicGameIcon.super.ctor(self, ccbFile, callBacks, options)

	self._isTestModel = false -- 测试模式
	self._ccbOwner.tf_test_id:setVisible(self._isTestModel)
	self._ccbOwner.tf_test_id:setString("")
end

function QUIWidgetZhangbichenMusicGameIcon:setInfo(info)
	if not info then return end

	self._info = clone(info)
	self._info.isEnd = false

	self:refreshInfo()
end

function QUIWidgetZhangbichenMusicGameIcon:refreshInfo()
	self._ccbOwner.sp_icon:setVisible(false)
	local path = QResPath("zhangbichenMusicGameIcon")[tonumber(self._info.type)]
	if path then
		QSetDisplayFrameByPath(self._ccbOwner.sp_icon, path)
		self._ccbOwner.sp_icon:setVisible(true)
	end

	self._ccbOwner.tf_test_id:setString(self._info.index)
end

function QUIWidgetZhangbichenMusicGameIcon:getContentSize()
	return self._ccbOwner.sp_icon:getContentSize()
end

function QUIWidgetZhangbichenMusicGameIcon:getInfo()
	return self._info
end

return QUIWidgetZhangbichenMusicGameIcon