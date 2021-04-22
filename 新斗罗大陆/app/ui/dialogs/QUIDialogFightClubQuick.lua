--
-- qsy
-- 地狱杀戮场一键扫荡优化
--
local QUIDialog = import(".QUIDialog")
local QUIDialogFightClubQuick = class("QUIDialogFightClubQuick", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetFightClubBattleQuick = import("..widgets.QUIWidgetFightClubBattleQuick")
local QUIWidgetFightClubBattleHero = import("..widgets.QUIWidgetFightClubBattleHero")
local QFightClubArrangement = import("...arrangement.QFightClubArrangement")
local QReplayUtil = import("...utils.QReplayUtil")


local CELL_WIDTH = 140
local CELL_HEIGH = 177

local CELL_COLUMN_MAX = 4

function QUIDialogFightClubQuick:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_quick.ccbi"
	QUIDialogFightClubQuick.super.ctor(self, ccbFile, nil, options)
	CalculateUIBgSize(self._ccbOwner.sp_bg)
	self._virtualFrame = {}
	self._curIndex = 0
	self._winCount = 0
end


function QUIDialogFightClubQuick:viewDidAppear()
	QUIDialogFightClubQuick.super.viewDidAppear(self)
	-- self.fightClubEventProxy = cc.EventProxy.new(remote.fightClub)
 --    --self.fightClubEventProxy:addEventListener(remote.fightClub.FIGHT_CLUB_QUICKALL, handler(self, self.fightEnd)) -- 一键挑战返回

 	self:addMyAction()
    self:addFrames()
 	self:requestFightClubQuick()
	self:playersShowAni()	
end

function QUIDialogFightClubQuick:viewWillDisappear()
  	QUIDialogFightClubQuick.super.viewWillDisappear(self)
	-- self.fightClubEventProxy:removeAllEventListeners()
end

function QUIDialogFightClubQuick:requestFightClubQuick()

    -- 计算所以未挑战的玩家
    local userDataList = {}
	-- local rivals = remote.fightClub:getRivalFighter()
	local FightInfo = remote.fightClub:getFightClubQuickFightInfo()
	local wave = 0
	--for _, value in ipairs(rivals) do
	for _, value in ipairs(FightInfo.fighter) do
		wave = wave + 1
		if value.userId ~= remote.user.userId then
			local bFail = remote.fightClub:getIsRivalFailed(value.userId)
			if not bFail then
				print("value.userId not bFail")
				local  repalyInfo = QReplayUtil:_createReplayFighterSingleTeamFromFighter(value)
				local buff = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.client.battle.ReplayFighter", repalyInfo)
				local fight_replayData = crypto.encodeBase64(buff)
				userDataList[#userDataList+1] = {userId = value.userId , wave = wave , replayData = fight_replayData}
			end
		end
	end
	local myData_repalyInfo = QReplayUtil:createReplayFighterSingleTeamBuffer(remote.teamManager.FIGHT_CLUB_ATTACK_TEAM)
	myData_repalyInfo = crypto.encodeBase64(myData_repalyInfo)	
	local myData =  {userId = remote.user.userId , wave = 0 , replayData = myData_repalyInfo}
	remote.fightClub:fightClubQuickFightRequest(myData ,userDataList, function() 	
		self:startInit()
	end)
end


function QUIDialogFightClubQuick:startInit()
    self:handleData()
	self:playEndAction()	
end


function QUIDialogFightClubQuick:addFrames()
	self._fighters = {}
	self._ccbOwner.arrowDown:setVisible(false)
	local FightInfo = remote.fightClub:getFightClubQuickFightInfo()
	local wave = 0
	for i, value in ipairs(FightInfo.fighter) do
		if value.userId ~= remote.user.userId then
			wave = wave + 1
			self._fighters[wave] = value
		end
	end

	if  not next(self._fighters) then
		self:_close()
		return
	end	
	-- QPrintTable(self._fighters)
	local start_cell_pos = ccp(69,-58)
    -- local fighter_num = 0

	for i, v in pairs(self._fighters) do
		-- if fighter_num >= 9 then
		-- 	self._ccbOwner.arrowDown:setVisible(true)
		-- 	break
		-- end
		local index = i - 1
		local line = math.floor(index / CELL_COLUMN_MAX)
		local column =  math.floor(index % CELL_COLUMN_MAX)
		local frame = {}
		frame.widget = QUIWidgetFightClubBattleQuick.new(v)
		frame.posX = start_cell_pos.x + CELL_WIDTH * column
		frame.posY = start_cell_pos.y - CELL_HEIGH * line
		frame.widget:setPosition(ccp(frame.posX  + display.width, frame.posY))
		frame.widget:setFightingVisible(true)
		self._ccbOwner.sheet:addChild(frame.widget)
		table.insert(self._virtualFrame, frame)
		-- fighter_num = fighter_num + 1
	end
end

function QUIDialogFightClubQuick:handleData()

	self._fight_end_result = remote.fightClub:getFightClubQuickFightEndInfo()
	for i,v in ipairs(self._fight_end_result) do
		if v.success then
			self._winCount = self._winCount + 1
		end
		-- for _, value in ipairs(self._fighters or {}) do
		-- 	if value.userId == v.rivalUserId then
		-- 		fighters[i] = value
		-- 	end
		-- end
	end

end

function QUIDialogFightClubQuick:addMyAction()
	self._myInfo = remote.fightClub:getMyInfo()
	self._myHead = QUIWidgetFightClubBattleHero.new(self._myInfo)
	self._myHead:setIsMyHero( )
	self._ccbOwner.node_hero:addChild(self._myHead)
	self._myHead:playAttackAni(nil)
end

function QUIDialogFightClubQuick:playersShowAni()

	local dur1 =0.2 
	local dur2 =0.2 

	for i, frame in pairs(self._virtualFrame) do 
		local index = i - 1
		local column = index % 4

		local time = dur1 * column 
		local actionIn = CCArray:create()
	    local delayTime = CCDelayTime:create(time)
	    local moveTo = CCMoveTo:create(dur2, ccp(frame.posX, frame.posY))
		local moveAni = CCEaseExponentialOut:create(moveTo)
		actionIn:addObject(delayTime)
		actionIn:addObject(moveAni)

	  --   if i == #self._virtualFrame then
	  --   	actionIn:addObject(CCCallFunc:create(function()self:goFightAllPlayers()end))

			-- actionIn:addObject(CCDelayTime:create(2))
	  --   	actionIn:addObject(CCCallFunc:create(function()self:fightEnd()end))
	  --   end
		frame.widget:runAction(CCSequence:create(actionIn))
	end
end

function QUIDialogFightClubQuick:playEndAction()
	local actionIn = CCArray:create()
	actionIn:addObject(CCCallFunc:create(function()self:goFightAllPlayers()end))

	actionIn:addObject(CCDelayTime:create(2))
	actionIn:addObject(CCCallFunc:create(function()self:fightEnd()end))	

	local node = self._virtualFrame[#self._virtualFrame].widget
	node:stopAllActions()
	node:runAction(CCSequence:create(actionIn))
end


function QUIDialogFightClubQuick:goFightAllPlayers()
	self._myHead:playAttackAni(nil)
end


function QUIDialogFightClubQuick:fightEnd()
	self:updateFrames()
	if self._winCount > 0 then
		self._myHead:playVictoryAni(function()self:showResult()end)
	else
		self._myHead:playDeathAni(function()self:showResult()end)
	end
end

function QUIDialogFightClubQuick:updateFrames()
	for i, frame in pairs(self._virtualFrame) do 
		local lose = self._fight_end_result[i].success
		frame.widget:setDefeated(lose)
		frame.widget:setFightingVisible(false)
	end
end

function QUIDialogFightClubQuick:showResult()

   remote.fightClub:requestFightClubInfo(function(data)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubQuickResult", 
					options = {callBack =function()
						if self:safeCheck() then
							self:_close()
						end
					end } , winCount = self._winCount}, {isPopCurrentDialog = false})
    end)

end

function QUIDialogFightClubQuick:_close()
    self:viewAnimationOutHandler()
end

return QUIDialogFightClubQuick
