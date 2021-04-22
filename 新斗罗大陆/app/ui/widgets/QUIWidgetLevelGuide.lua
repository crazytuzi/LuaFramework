local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetLevelGuide = class("QUIWidgetLevelGuide", QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetLevelGuide:ctor(options)
	local ccbFile = "ccb/Dialog_NewOpen2.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLevelGuide", callback = handler(self, self._onTriggerLevelGuide)},
	}
	QUIWidgetLevelGuide.super.ctor(self,ccbFile,callBacks,options)
	self._ccbOwner.fca_playerRecall_new_1:setVisible(false)
	self._ccbOwner.fca_playerRecall_new_2:setVisible(false)
	self._ccbOwner.sp_playerRecall_tips:setVisible(false)
	self._levelGoalAnimationManager = tolua.cast(self._ccbOwner.ccb_levelGoal_bg:getUserObject(), "CCBAnimationManager")
	self._levelGoalAnimationManager:runAnimationsForSequenceNamed("2")
end

function QUIWidgetLevelGuide:setLevel(level, guideType)
	self._level = level
	self._type = guideType
	local levelInfos = QStaticDatabase:sharedDatabase():getLevelGuideInfosByType(self._type)
	local isHave = false
	local guideInfo = nil
	for _, value in pairs(levelInfos) do
		if value.show_in == 1 and self._level >= value.trigger_condition and self._level < value.closing_condition then
			isHave = true
			guideInfo = value
			break
		end
	end
	if isHave == true then
		self:getView():setVisible(true)
		self._ccbOwner.tf_open_level:setString(guideInfo.closing_condition.."级开启")

		local texture
		texture = CCTextureCache:sharedTextureCache():addImage("ui/"..guideInfo.icon)
		if texture then
 			self._ccbOwner.level_icon:setTexture(texture)
	        self._ccbOwner.level_icon:setTextureRect(CCRectMake(0, 0, texture:getContentSize().width, texture:getContentSize().height))
 		end
		self._ccbOwner.level_name:setString(guideInfo.name or "")
	else
		self:getView():setVisible(false)
	end
end

function QUIWidgetLevelGuide:setLevelIconScale(scale)
	if scale == nil then return end

	self._ccbOwner.level_icon:setScale(scale)
end

function QUIWidgetLevelGuide:_onTriggerLevelGuide()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogLevelGuide", 
		options = {level = self._level, guideType = self._type}})
end

return QUIWidgetLevelGuide