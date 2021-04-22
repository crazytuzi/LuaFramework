-- 
--  zxs
--	搏击俱乐部战斗界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogFightClubBattle = class("QUIDialogFightClubBattle", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetFightClubBattleHead = import("..widgets.QUIWidgetFightClubBattleHead")
local QUIWidgetFightClubBattleHero = import("..widgets.QUIWidgetFightClubBattleHero")
local QFightClubArrangement = import("...arrangement.QFightClubArrangement")

local CELL_WIDTH = 130

function QUIDialogFightClubBattle:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_battle.ccbi"
	QUIDialogFightClubBattle.super.ctor(self, ccbFile, nil, options)
    CalculateUIBgSize(self._ccbOwner.sp_bg)

	if options then
		self._quickFightInfo = options.quickFightInfo
		self._callBack = options.callback
		self._fightType = options.fightType
	end

	self._headPosX, self._headPosY = self._ccbOwner.node_head:getPosition()
	self._virtualFrame = {}
	self._curIndex = 0


	if self._fightType == remote.fightClub.FAST_FIGHT then
		self._ccbOwner.tf_battle_tile:setString("一键挑战")
	end
end

function QUIDialogFightClubBattle:viewDidAppear()
	QUIDialogFightClubBattle.super.viewDidAppear(self)

	self.fightClubEventProxy = cc.EventProxy.new(remote.fightClub)
    self.fightClubEventProxy:addEventListener(remote.fightClub.FIGHT_CLUB_QUICK_ERROR, handler(self, self._onError))	

    self:addFrames()
	self:playersShowAni()	
end

function QUIDialogFightClubBattle:viewWillDisappear()
  	QUIDialogFightClubBattle.super.viewWillDisappear(self)
  	self.fightClubEventProxy:removeAllEventListeners()
end

function QUIDialogFightClubBattle:_onError()
	self:_close()
end

function QUIDialogFightClubBattle:addFrames()
	local quickFightInfo = self._quickFightInfo
	if not quickFightInfo then
		self:_close()
		return
	end
	self._opponentList = quickFightInfo.fighter
	
	self._lastPassWave = quickFightInfo.lastPassWave or {}
	for i, v in pairs(self._opponentList) do
		local beated = false
		for k,v in pairs(self._lastPassWave) do
			if i == v then
				beated = true
				break
			end
		end
		local frame = {}
		frame.widget = QUIWidgetFightClubBattleHead.new(v, i)
		frame.posX = CELL_WIDTH*(i-1)
		frame.rivalId = v.userId
		frame.beated = beated
		frame.widget:setPosition(ccp(display.width+CELL_WIDTH, 0))
		self._ccbOwner.node_head:addChild(frame.widget)
		table.insert(self._virtualFrame, frame)
	end

	-- 新一键扫荡相关
	-- self._lastPassWave = quickFightInfo.lastPassWave or {}
	-- for i, v in pairs(self._opponentList) do
	-- 	local beated = false
	-- 	for k,v in pairs(self._lastPassWave) do
	-- 		if i== v then
	-- 			beated = true
	-- 		end
	-- 	end

	-- 	local frame = {}
	-- 	frame.widget = QUIWidgetFightClubBattleHead.new(v, i)
	-- 	frame.posX = CELL_WIDTH*(i-1)
	-- 	frame.rivalId = v.userId
	-- 	frame.beated = beated
	-- 	frame.widget:setPosition(ccp(display.width+CELL_WIDTH, 0))
	-- 	self._ccbOwner.node_head:addChild(frame.widget)
	-- 	table.insert(self._virtualFrame, frame)
	-- end

	self._myInfo = remote.fightClub:getMyInfo()
	self._myHead = QUIWidgetFightClubBattleHero.new(self._myInfo)
	self._myHead:setIsMyHero( )
	self._ccbOwner.node_hero:addChild(self._myHead)

	local arrow_ccbProxy = CCBProxy:create()
    local arrow_ccbOwner = {}
    arrow_ccbOwner.onTriggerNext = handler(self, QUIDialogFightClubBattle._onTriggerNext)
    self._nextBt = CCBuilderReaderLoad("effects/arrow_battle.ccbi", arrow_ccbProxy, arrow_ccbOwner)
    self._ccbOwner.node_next:addChild(self._nextBt)
    self._nextBt:setVisible(false)
end

function QUIDialogFightClubBattle:fightAllSuccess()
	local options = {}
	options.info = {}
	options.isWin = true
	options.callback = function()
		self:_close()

		local quickSuccessAward = remote.fightClub:getQuickSuccessAward()
		if quickSuccessAward then
            local awards = {}
		    local rewards = string.split(quickSuccessAward, ";")
		    for i, v in pairs(rewards) do
		    	if v ~= "" then
		            local reward = string.split(v, "^")
		            local itemType = ITEM_TYPE.ITEM
		            if tonumber(reward[1]) == nil then
		                itemType = remote.items:getItemType(reward[1])
		            end
		            table.insert(awards, {id = reward[1], typeName = itemType, count = tonumber(reward[2])})
		        end
		    end
            if #awards > 0 then
                local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", 
                	options = {awards = awards}},{isPopCurrentDialog = true})
                dialog:setTitle("恭喜获得挑战奖励")
            end
		end
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubQuickFightResult", options = options}, {isPopCurrentDialog = false})
end

function QUIDialogFightClubBattle:fightingFail()
	local aniCallBack = function ( )
		local options = {}
		options.info = {}
		options.isWin = false
		options.callback = function()
			self:_close()
		end
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClubQuickFightResult", options = options}, {isPopCurrentDialog = false})
	end

	self._myHead:playDeathAni()
	self._opponentHead:playVictoryAni(aniCallBack)
end

function QUIDialogFightClubBattle:fightingSuccess(rivalId)
	for i, frame in pairs(self._virtualFrame) do 
		if frame.rivalId == rivalId then
			frame.beated = true
		end
	end

	local aniCallBack = function ( )
		self._opponentHead:removeFromParent()
		self:getNextPlayer()
	end
	self._myHead:playVictoryAni(aniCallBack)
	self._opponentHead:playDeathAni()
end

function QUIDialogFightClubBattle:startBattle()
	local rivalInfo = self._curOpponent
	local rivalsPos = self._curIndex
	local fightArrangement = QFightClubArrangement.new({rivalInfo = rivalInfo, rivalsPos = rivalsPos, myInfo = self._myInfo, teamKey = remote.teamManager.FIGHT_CLUB_ATTACK_TEAM})

	local isShow = false
	if self._curIndex == 1 then
		isShow = true
	end

    fightArrangement:startQuickFight(self._fightType, function(info)
	    	if self:safeCheck() then
	    		if info.isWin then
	    			self:fightingSuccess(info.rivalId)
	            else
	    			self:fightingFail(info.rivalId)
	            end
	        end
        end, nil, isShow)
    self._myHead:playAttackAni()
	self._opponentHead:playAttackAni()
end

function QUIDialogFightClubBattle:nextHeroIn()
	local aniCallBack = function ( )
		self:startBattle()
	end
	
	local diffIndex = self._curIndex - 8 
	if diffIndex > 0 then
		local movePos = diffIndex*CELL_WIDTH
		self._ccbOwner.node_head:runAction(CCMoveTo:create(0.5, ccp(self._headPosX-movePos, self._headPosY)))
	end

	local actionIn = CCArray:create()
    local moveTo = CCMoveTo:create(0.5, ccp(230, -170))
	local moveAni = CCEaseExponentialOut:create(moveTo)
	local delayTime = CCDelayTime:create(1)
    actionIn:addObject(moveAni)
    actionIn:addObject(delayTime)
    actionIn:addObject(CCCallFunc:create(aniCallBack))

	self._ccbOwner.node_opponent:setVisible(true)
	self._ccbOwner.node_opponent:runAction(CCSequence:create(actionIn))
end

function QUIDialogFightClubBattle:getNextPlayer(bFirst)
	self._curIndex = 0
	for i, frame in pairs(self._virtualFrame) do 
		if not frame.beated then
			frame.widget:setSelected()
			self._curIndex = i
			break
		else
			frame.widget:setDefeated()
		end
	end
	if self._curIndex == 0 then
		self:fightAllSuccess()
		return
	end

	self._curOpponent = self._opponentList[self._curIndex]
	self._opponentHead = QUIWidgetFightClubBattleHero.new(self._curOpponent)
	self._opponentHead:setFlipX(true)
	self._ccbOwner.node_opponent:addChild(self._opponentHead)
	self._ccbOwner.node_opponent:setPositionX(display.width+CELL_WIDTH)

	self:nextHeroIn()
end

function QUIDialogFightClubBattle:playersShowAni()
	for i, frame in pairs(self._virtualFrame) do 
		local time = 0.05*i 
		local actionIn = CCArray:create()
	    local delayTime = CCDelayTime:create(time)
	    local moveTo = CCMoveTo:create(0.1, ccp(frame.posX, 0))
		local moveAni = CCEaseExponentialOut:create(moveTo)
		actionIn:addObject(delayTime)
		actionIn:addObject(moveAni)

	    if i == #self._virtualFrame then
	    	actionIn:addObject(CCCallFunc:create(function()self:getNextPlayer(true)end))
	    end
		frame.widget:runAction(CCSequence:create(actionIn))
	end
end

function QUIDialogFightClubBattle:_onTriggerNext()
 	self._nextBt:setVisible(false)
	self:nextHeroIn()
end

function QUIDialogFightClubBattle:_close()
    self:viewAnimationOutHandler()
end

return QUIDialogFightClubBattle