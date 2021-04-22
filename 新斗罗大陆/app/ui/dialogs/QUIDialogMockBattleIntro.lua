-- @Author: qinsiyang
-- @Date:   2019-11-20 17:27:58
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-06 18:38:26
-- 模拟战赛季玩法说明
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMockBattleIntro = class("QUIDialogMockBattleIntro", QUIDialog)
local QRichText = import("...utils.QRichText")
local QMockBattle = import("..network.models.QMockBattle")

local TITLE_SINGLE="单队模拟战"
local TITLE_DOUBLE ="双队模拟战"
local DESC_TEXT = {
	"随机卡牌三选一，组建你的最强战队！",
	"挑战其他玩家，达到一定 负场/胜场 结束一轮挑战",
	"选择魂师+暗器组合的卡牌，可在上阵时重新搭配",
	"双队模拟战单场胜负结果由两小队各自的战绩决定",
}

local dur_action = q.flashFrameTransferDur(12)

function QUIDialogMockBattleIntro:ctor(options)
	local ccbFile = "ccb/Dialog_MockBattle_Intro.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerClickLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerClickRight)},
    }

    QUIDialogMockBattleIntro.super.ctor(self, ccbFile, callBacks, options)
	--self._isTouchSwallow = false
	if options.callback then
		self._callback = options.callback
	end


    self.isAnimation = false
    self._isAction = false

	self._seasonType =	options.seasonType or 1

	self._curIndex = 1
	if self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE  then
		self._my_idxs ={1,2,3,4}
		self._ccbOwner.tf_title:setString(TITLE_DOUBLE)
	else
		self._my_idxs ={2,1}
		self._ccbOwner.tf_title:setString(TITLE_SINGLE)
	end

	self._ccbOwner.node_arrow:setVisible(#self._my_idxs > 1)

	local seasoninfo = remote.mockbattle:getMockBattleSeasonInfo()
	local startAt = seasoninfo.startAt or 0
	local endAt = seasoninfo.endAt or 0
	local date_start = q.date("*t", startAt/1000)
	local date_end = q.date("*t", endAt/1000)
	local dateStr = string.format("赛季时间：%s年%s月%s日-%s年%s月%s日", date_start.year, date_start.month, date_start.day, date_end.year, date_end.month, date_end.day)
	self._ccbOwner.tf_time:setString(dateStr)

    self._seasonPic = QResPath("mockbattle_intro")
	self._maxNum = #self._my_idxs 
	self:_disableTouchSwallow()
	self:updateShowImage()
	self:_runAppearAction()
end

function QUIDialogMockBattleIntro:updateShowImage()
	self._ccbOwner.tf_desc:setString(DESC_TEXT[self._my_idxs[self._curIndex]] or "")

	if self._seasonPic[self._my_idxs[self._curIndex]] then
		QSetDisplayFrameByPath(self._ccbOwner.sp_image, self._seasonPic[self._my_idxs[self._curIndex]])
	end
end

function QUIDialogMockBattleIntro:_runAppearAction()

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

function QUIDialogMockBattleIntro:_runDisappearAction()

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


function QUIDialogMockBattleIntro:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMockBattleIntro:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:_runDisappearAction()
	
end

function QUIDialogMockBattleIntro:_onTriggerClickLeft()
  	app.sound:playSound("common_close")

  	self._curIndex = self._curIndex - 1
  	if self._curIndex < 1 then
  		self._curIndex = self._maxNum
  	end
	self:updateShowImage()
end

function QUIDialogMockBattleIntro:_onTriggerClickRight()
  	app.sound:playSound("common_close")
	self._curIndex = self._curIndex + 1
  	if self._curIndex > self._maxNum then
  		self._curIndex = 1
  	end
  	self:updateShowImage()
end

return QUIDialogMockBattleIntro
