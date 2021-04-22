-- @Author: liaoxianbo
-- @Date:   2020-07-03 17:51:59
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-17 18:13:51
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAchievementCollectionBtn = class("QUIWidgetAchievementCollectionBtn", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetAchievementCollectionBtn:ctor(options)
	local ccbFile = "ccb/Widget_achievementCollection_btn.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetAchievementCollectionBtn.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetAchievementCollectionBtn:onEnter()
end

function QUIWidgetAchievementCollectionBtn:onExit()
end

function QUIWidgetAchievementCollectionBtn:setInfo(info)
	if q.isEmpty(info) then return end
	self._btnInfo = info
	self._ccbOwner.tf_btn_name:setString(self._btnInfo.name or "")

	local collegeState = remote.achievementCollege:checkAchievementIsFinash(self._btnInfo.id)
	self._ccbOwner.sp_is_collected:setVisible(collegeState)

	local redTips = remote.achievementCollege:checkRedTipsById(self._btnInfo.id)
	self._ccbOwner.sp_achiement_red_tips:setVisible(redTips)

	QSetDisplaySpriteByPath(self._ccbOwner.sp_normalBg,self._btnInfo.button_icon_normal)
	QSetDisplaySpriteByPath(self._ccbOwner.sp_choosebg,self._btnInfo.button_icon_light)
end

function QUIWidgetAchievementCollectionBtn:setSelect(b)
	self._ccbOwner.sp_choosebg:setVisible(b)
	if b then
		self._ccbOwner.sp_achiement_red_tips:setVisible(false)
	else
		local redTips = remote.achievementCollege:checkRedTipsById(self._btnInfo.id)
		self._ccbOwner.sp_achiement_red_tips:setVisible(redTips)		
	end
end

function QUIWidgetAchievementCollectionBtn:getInfo()
	return self._btnInfo
end

function QUIWidgetAchievementCollectionBtn:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetAchievementCollectionBtn
