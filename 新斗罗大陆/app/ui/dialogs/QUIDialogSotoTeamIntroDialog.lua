-- @Author: qinsiyang
-- @Date:   2019-11-20 17:27:58
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-06 18:38:26
-- 云顶之战赛季玩法说明
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSotoTeamIntroDialog = class("QUIDialogSotoTeamIntroDialog", QUIDialog)
local QRichText = import("...utils.QRichText")

local TITLE_ORIGIN ="云顶之战：起源"
local TITLE_INHERIT ="云顶之战：传承"
local TITLE_EQUILIBRIUM ="云顶之战：均衡"
local DESC_TEXT = {
	"每个替补成员 额外继承主力成员属性之和的25%",
	"7人团战， 替补位上阵将增加怒气",
	"7人团战， 上阵魂师（主力和替补）均摊上阵魂师的所有属性",
}

local dur_action = q.flashFrameTransferDur(12)

function QUIDialogSotoTeamIntroDialog:ctor(options)
	local ccbFile = "ccb/Dialog_SotoTean_Intro.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerClickLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerClickRight)},
    }

    QUIDialogSotoTeamIntroDialog.super.ctor(self, ccbFile, callBacks, options)
	--self._isTouchSwallow = false
	if options.callback then
		self._callback = options.callback
	end


    self.isAnimation = false
    self._isAction = false
	self._isInherit = remote.sotoTeam:checkIsInheritSeason()
	self._isEquilibrium = remote.sotoTeam:checkIsEquilibriumSeason()
	self._ccbOwner.node_arrow:setVisible(false)
	self._curIndex = 1
	if self._isInherit then
		self._ccbOwner.tf_title:setString(TITLE_INHERIT)
	elseif self._isEquilibrium then
		self._curIndex = 3
		self._ccbOwner.tf_title:setString(TITLE_EQUILIBRIUM)
	else
		self._curIndex = 2
		self._ccbOwner.tf_title:setString(TITLE_ORIGIN)
	end
	local seasoninfo = remote.sotoTeam:getSotoTeamSeasonInfo()
	local startAt = seasoninfo.seasonStartAt or 0
	local endAt = seasoninfo.seasonEndAt or 0
	local date_start = q.date("*t", startAt/1000)
	local date_end = q.date("*t", endAt/1000)
	local dateStr = string.format("赛季时间：%s年%s月%s日-%s年%s月%s日", date_start.year, date_start.month, date_start.day, date_end.year, date_end.month, date_end.day)
	self._ccbOwner.tf_time:setString(dateStr)

    self._seasonPic = QResPath("soto_team_season_pic")
	self._maxNum = 1
	self:_disableTouchSwallow()
	self:updateShowImage()
	self:_runAppearAction()
end

function QUIDialogSotoTeamIntroDialog:updateShowImage()
	self._ccbOwner.tf_desc:setString(DESC_TEXT[self._curIndex] or "")

	if self._seasonPic[self._curIndex] then
		QSetDisplayFrameByPath(self._ccbOwner.sp_image, self._seasonPic[self._curIndex])
	end
end

function QUIDialogSotoTeamIntroDialog:_runAppearAction()

	self._ccbOwner.node_main:setScale(0.1)
	self._ccbOwner.node_main:setOpacity(0)
	self._ccbOwner.node_main:setPosition(ccp( -display.width * 0.5 ,display.height * 0.37))
	makeNodeFadeToOpacity(self._ccbOwner.node_main,dur_action)
	makeNodeFadeToOpacity(self._backTouchLayer,dur_action)


	local arr = CCArray:create()
    arr:addObject(CCFadeIn:create(dur_action))
    --arr:addObject(CCMoveTo:create(dur_action, ccp(display.width/2, display.height/2)))
    arr:addObject(CCMoveTo:create(dur_action, ccp(0, 0)))
    arr:addObject(CCScaleTo:create(dur_action, 1))

    self._ccbOwner.node_main:runAction(CCSpawn:create(arr))	
	local fadeIn = CCFadeIn:create(dur_action)


end

function QUIDialogSotoTeamIntroDialog:_runDisappearAction()

	if self._isAction == true then return end

	self._isAction = true

	self._ccbOwner.node_main:stopAllActions()
	self._ccbOwner.tf_title:setOpacityModifyRGB(true)
	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_main,dur_action,0)
	makeNodeFadeToByTimeAndOpacity(self._backTouchLayer,dur_action,0)
	
	local arr = CCArray:create()
    arr:addObject(CCFadeOut:create(dur_action))
    arr:addObject(CCMoveTo:create(dur_action, ccp( -display.width * 0.5 ,display.height * 0.37)))
    arr:addObject(CCScaleTo:create(dur_action, 0.1))
	local arr2 = CCArray:create()
	arr2:addObject(CCSpawn:create(arr))
	arr2:addObject(CCCallFunc:create(function() 
		if self._callback then
			self._callback()
		end
		self:playEffectOut() 
		end))
    self._ccbOwner.node_main:runAction(CCSequence:create(arr2))	

end


function QUIDialogSotoTeamIntroDialog:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSotoTeamIntroDialog:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:_runDisappearAction()
	
end

function QUIDialogSotoTeamIntroDialog:_onTriggerClickLeft()
  	app.sound:playSound("common_close")

  	self._curIndex = self._curIndex - 1
  	if self._curIndex < 1 then
  		self._curIndex = self._maxNum
  	end
	self:updateShowImage()
end

function QUIDialogSotoTeamIntroDialog:_onTriggerClickRight()
  	app.sound:playSound("common_close")
	self._curIndex = self._curIndex + 1
  	if self._curIndex > self._maxNum then
  		self._curIndex = 1
  	end
  	self:updateShowImage()
end

return QUIDialogSotoTeamIntroDialog
