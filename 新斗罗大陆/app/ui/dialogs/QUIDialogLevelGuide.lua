--
-- Author: xurui
-- Date: 2016-05-21 11:01:56
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogLevelGuide = class("QUIDialogLevelGuide", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("...ui.QUIViewController")

function QUIDialogLevelGuide:ctor(options)
	local ccbFile = "ccb/Dialog_NewOpen.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerDetil", callback = handler(self, self._onTriggerDetil)},
	}
	QUIDialogLevelGuide.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	self._level = options.level
	self._guideType = options.guideType
end

function QUIDialogLevelGuide:viewDidAppear()
	QUIDialogLevelGuide.super.viewDidAppear(self)

	self:_setGuideInfo()
end

function QUIDialogLevelGuide:viewWillDisappear()
	QUIDialogLevelGuide.super.viewWillDisappear(self)
end

function QUIDialogLevelGuide:_setGuideInfo()
	--self._ccbOwner.btn_detail:setVisible(self._guideType == LEVEL_GOAL.UNION)

	local levelInfos = QStaticDatabase:sharedDatabase():getLevelGuideInfosByType(self._guideType)
	local guideInfo = {}
	for _, value in pairs(levelInfos) do
		if value.show_in == 1 and self._level >= value.trigger_condition and self._level < value.closing_condition then
			guideInfo = value
			break
		end
	end

	self._ccbOwner.guide_open_info:setString(guideInfo.tip or "")
	self._ccbOwner.guide_dec:setString(guideInfo.desc or "")

    QSetDisplayFrameByPath(self._ccbOwner.guide_icon, "ui/"..guideInfo.icon)

    if guideInfo.icon_position then
    	local offsets = string.split(guideInfo.icon_position, ",")
    	local position = ccp(self._ccbOwner.guide_icon:getPosition())
    	self._ccbOwner.guide_icon:setPosition(ccp(position.x+tonumber(offsets[1]), position.y+tonumber(offsets[2])))
    end

    self._ccbOwner.guide_name:setString(guideInfo.name or "")
end

function QUIDialogLevelGuide:_backClickHandler()
	self:playEffectOut()
end

--跳转
function QUIDialogLevelGuide:_onTriggerDetil()
	if self._guideType == LEVEL_GOAL.UNION then
		self:popSelf()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionManage", 
	        options = {curSelectBtn = "onTriggerLevel"}}, {isPopCurrentDialog = true})
	end
end

return QUIDialogLevelGuide