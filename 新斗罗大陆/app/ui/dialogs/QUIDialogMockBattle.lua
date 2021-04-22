-- @Author: qinsiyang
-- 大师赛


local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMockBattle = class("QUIDialogMockBattle", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QMockBattle = import("..network.models.QMockBattle")
local QUIWidgetMockBattlePickCard = import("..widgets.QUIWidgetMockBattlePickCard")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QMockBattleArrangement = import("...arrangement.QMockBattleArrangement")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMockBattleCard = import("..widgets.QUIWidgetMockBattleCard")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogMockBattle:ctor(options)
    local ccbFile = "ccb/Dialog_MockBattle.ccbi"
    local callBacks = {
    	{ccbCallbackName = "onTriggerMatch", callback = handler(self, self._onTriggerMatch)}, 
    	{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)}, 
        {ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},
		{ccbCallbackName = "onTriggerStatistics", callback = handler(self, self._onTriggerStatistics)}, 
		{ccbCallbackName = "onTriggerStore", callback = handler(self, self._onTriggerStore)},
		{ccbCallbackName = "onTriggerReward", callback = handler(self, self._onTriggerReward)},
		{ccbCallbackName = "onTriggerDel", callback = handler(self, self._onTriggerDel)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerSignUp", callback = handler(self, self._onTriggerSignUp)},
		{ccbCallbackName = "onTriggerPick", callback = handler(self, self._onTriggerPick)},
		{ccbCallbackName = "onTriggerClickChosenCard", callback = handler(self, self._onTriggerClickChosenCard)},
		{ccbCallbackName = "onTriggerCardsHelp", callback = handler(self, self._onTriggerCardsHelp)},
        {ccbCallbackName = "onTriggerSeasonTips", callback = handler(self, self._onTriggerSeasonTips)},   
        {ccbCallbackName = "onTriggerClickShowReward", callback = handler(self, self._onTriggerClickShowReward)},   
        {ccbCallbackName = "onTriggerRewardTips", callback = handler(self, self._onTriggerRewardTips)},   

		
    }
    QUIDialogMockBattle.super.ctor(self, ccbFile, callBacks, options)

    
    q.setButtonEnableShadow(self._ccbOwner.btn_rewardtips)
    q.setButtonEnableShadow(self._ccbOwner.btn_match)
    q.setButtonEnableShadow(self._ccbOwner.btn_del)
    q.setButtonEnableShadow(self._ccbOwner.btn_pick)
    q.setButtonEnableShadow(self._ccbOwner.btn_signup)
    q.setButtonEnableShadow(self._ccbOwner.btn_plus)
    q.setButtonEnableShadow(self._ccbOwner.btn_statistics)
    q.setButtonEnableShadow(self._ccbOwner.btn_cardshelp)
    q.setButtonEnableShadow(self._ccbOwner.btn_store)
    q.setButtonEnableShadow(self._ccbOwner.btn_season_tips)
    CalculateUIBgSize(self._ccbOwner.sp_bg)

    self:resetAll()
	self.nowGridInfo ={}
	self.chooseInfo ={}
	self._fun = nil
	self._seasonScheduler = nil

    local options = self:getOptions() or {}

    self:updateTopPage()
	self._cur_phase = 1
	self._old_phase = -1
	self._isChangePhase = false
	self._isBatlleBack = false

	self._pickNode = nil
    self:checkTutorial()
    self:checkEjectIntroduce()
	self._seasonType = 0

end


function QUIDialogMockBattle:updateTopPage()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page and page.setAllUIVisible then page:setAllUIVisible(true) end
    if page and page.setManyUIVisible then page:setManyUIVisible(true) end
    if page and page.setScalingVisible then page:setScalingVisible(false) end
    if page and page.topBar and page.topBar.showWithMockBattle then
        page.topBar:showWithMockBattle()
    end

end

function QUIDialogMockBattle:resetAll()
	self._ccbOwner.sp_record_tips:setVisible(false)
	self._ccbOwner.sp_statistics_tips:setVisible(false)

	self._ccbOwner.sp_store_tips:setVisible(false)
	self._ccbOwner.sp_score_tips:setVisible(false)
end


function QUIDialogMockBattle:viewDidAppear()
    QUIDialogMockBattle.super.viewDidAppear(self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QMockBattle.MOCKBATTLE_PHASE_UPDATE, self.updatePhase, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetMockBattlePickCard.SHOW_FLASH_EFFECT, self.ShowEffect, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

    self.mockBattleEventProxy = cc.EventProxy.new(remote.mockbattle)
    self.mockBattleEventProxy:addEventListener(remote.mockbattle.EVENT_MOCK_BATTLE_MY_INFO, handler(self, self.showRedTips))

    self:addBackEvent(true)
    self:setSelfInfo()
end

function QUIDialogMockBattle:viewWillDisappear()
    QUIDialogMockBattle.super.viewWillDisappear(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QMockBattle.MOCKBATTLE_PHASE_UPDATE, self.updatePhase, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetMockBattlePickCard.SHOW_FLASH_EFFECT, self.ShowEffect, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

    self.mockBattleEventProxy:removeAllEventListeners()
 
    self:removeBackEvent()
    if self._seasonScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._seasonScheduler)
    	self._seasonScheduler = nil
    end

    if self._seasonEndRequestScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._seasonEndRequestScheduler)
    	self._seasonEndRequestScheduler = nil
    end    
end

function QUIDialogMockBattle:checkTutorial()
    if app.tutorial and app.tutorial:isTutorialFinished() == false then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        if page.buildLayer then
            page:buildLayer()
        end
        local haveTutorial = false
       -- --change
       --  if app.tutorial:getStage().invasion == app.tutorial.Guide_Start and app.unlock:getUnlockInvasion() then
       --      haveTutorial = app.tutorial:startTutorial(app.tutorial.Stage_Invasion)
       --  end
        if haveTutorial == false and page.cleanBuildLayer then
            page:cleanBuildLayer()
        end
    end
end



function QUIDialogMockBattle:updatePhase(event)
	self:setSelfInfo()
end

function QUIDialogMockBattle:setSelfInfo()
	self._seasonType = remote.mockbattle:getMockBattleSeasonType()

	if self._old_phase ~= -1 and self._old_phase ~= self._cur_phase and self._cur_phase == QMockBattle.PHASE_PICK then
		self._isChangePhase = true
	end
	self._old_phase = self._cur_phase
	self._cur_phase = remote.mockbattle:getCurPhase()
	-- --战斗测试使用数据
	-- self._cur_phase = QMockBattle.PHASE_MATCH 
	-- remote.mockbattle:createFakeData()

	self:showPhaseDefault()
	self:showPhaseSignUp()
	self:showPhasePick()
	self:showPhaseMatch()
	self:showPhaseSeasonEnd()

	
	self:updatePickInfo()
	self:updateAwardInfo()
	self:updateSeasonAwardInfo()
	self:updateShowTimer()

	self:showRedTips()


	self:updateSeasonInfo()
	self:checkSeasonTimeToRefresh()

	self._isChangePhase = false
end


function QUIDialogMockBattle:showRedTips()
	self._ccbOwner.sp_record_tips:setVisible(false)
	self._ccbOwner.sp_statistics_tips:setVisible(false)
	
	self._ccbOwner.sp_store_tips:setVisible(remote.mockbattle:checkShopRedTips())
	self._ccbOwner.sp_score_tips:setVisible(remote.mockbattle:checkScoreRewardRedTips())
end


function QUIDialogMockBattle:showPhaseDefault()
	if self._cur_phase ~=  QMockBattle.PHASE_UNOPEN then return end
end

function QUIDialogMockBattle:showPhaseSignUp()

	self._ccbOwner.node_phase_1:setVisible(self._cur_phase ==  QMockBattle.PHASE_SIGNUP)
	self._ccbOwner.node_signup:setVisible(self._cur_phase ==  QMockBattle.PHASE_SIGNUP)
	self._ccbOwner.node_ticket:setVisible(self._cur_phase ==  QMockBattle.PHASE_SIGNUP)

	if self._cur_phase ~=  QMockBattle.PHASE_SIGNUP then 
		return 
	end
	self.cur_ticket = remote.mockbattle:getCurTicketNum()
	self._ccbOwner.tf_count:setString(self.cur_ticket)

end

function QUIDialogMockBattle:showPhasePick()

	self._ccbOwner.node_phase_2:setVisible(self._cur_phase ==  QMockBattle.PHASE_PICK)
	self.chooseInfo ={}
	self.chooseInfo = remote.mockbattle:getMockBattleRoundInfo().chooseInfo	or {}
	local gridInfo =  remote.mockbattle:getMockBattleRoundInfo().nowGridInfo	or {}
	self.nowGridInfo = {}
	self.nowBingGridInfo = {}-- 绑定的暗器
	if #gridInfo >=3 then
		for i=1,3 do
			table.insert(self.nowGridInfo,gridInfo[i])
		end

	end
	if #gridInfo >=6 then
		for i=4,6 do
			table.insert(self.nowBingGridInfo,gridInfo[i])
		end

	end


	if self._cur_phase ~=  QMockBattle.PHASE_PICK then return end

	if self._pickNode == nil then
		self._ccbOwner.node_pick_pos:removeAllChildren()
		self._pickNode = QUIWidgetMockBattlePickCard.new({options = {type_ = 1}})
		self._ccbOwner.node_pick_pos:addChild(self._pickNode)
	end

	local last_ = #self.chooseInfo

	local cards = {}
	local max_num = 8
	local type_str = ""
	local type_  = QUIWidgetMockBattleCard.CARD_TYPE_HERO
	for i,value in pairs(self.nowGridInfo) do
		local data_ = remote.mockbattle:getCardInfoByIndex(value)
		max_num = remote.mockbattle:getCardMaxBySeasonAndType( self._seasonType, data_.cType)
		if data_.cType == QMockBattle.CARD_TYPE_HERO then
			type_  = QUIWidgetMockBattleCard.CARD_TYPE_HERO
			type_str = "魂师"
		elseif data_.cType == QMockBattle.CARD_TYPE_MOUNT then
			type_  = QUIWidgetMockBattleCard.CARD_TYPE_MOUNT		
			type_str = "暗器"
		elseif data_.cType == QMockBattle.CARD_TYPE_SOUL then
			type_  = QUIWidgetMockBattleCard.CARD_TYPE_SOUL		
			type_str = "魂灵"
		elseif data_.cType == QMockBattle.CARD_TYPE_GODARM then
			type_  = QUIWidgetMockBattleCard.CARD_TYPE_GODARM		
			type_str = "神器"
		end

		local bind_card_idx = self.nowBingGridInfo[i]
		if bind_card_idx then 



			local data_bind = remote.mockbattle:getCardInfoByIndex(bind_card_idx)
			table.insert(cards, {oType = type_ ,id = data_.actorId,grade = data_.grade,index = i , card_id = value , bind_id = data_bind.actorId , bind_card_id = bind_card_idx})
		else
			table.insert(cards, {oType = type_ ,id = data_.actorId,grade = data_.grade,index = i , card_id = value })
		end

	end
	local add_str = ""
	for i,value in pairs(self.nowBingGridInfo) do
		local data_ = remote.mockbattle:getCardInfoByIndex(value)
		if data_.cType == QMockBattle.CARD_TYPE_HERO then
			 add_str= "及魂师"
		elseif data_.cType == QMockBattle.CARD_TYPE_MOUNT then
			add_str = "及暗器"
		elseif data_.cType == QMockBattle.CARD_TYPE_SOUL then
			add_str = "及魂灵"
		elseif data_.cType == QMockBattle.CARD_TYPE_GODARM then
			add_str = "及神器"
		end
	end
	

	self._pickNode:setInfo(cards,last_ == 0)
	last_ = remote.mockbattle:getChooseCardsNumByType( type_) + 1-- 根据当前卡牌类型 获得已选卡牌数量
	self._ccbOwner.tf_pick_title:setString("请选择您的"..type_str..add_str.."：")
	self._ccbOwner.tf_pick_title_num:setString(last_.."/"..max_num)
	self._ccbOwner.tf_pick_title_num:setPositionX(self._ccbOwner.tf_pick_title:getPositionX() + self._ccbOwner.tf_pick_title:getContentSize().width * 0.5  + self._ccbOwner.tf_pick_title_num:getContentSize().width * 0.5)
	self._ccbOwner.sp_choose_tip:setPositionX(self._ccbOwner.tf_pick_title:getPositionX() - self._ccbOwner.tf_pick_title:getContentSize().width * 0.5  - 15)

end

-- local function _converFun(time)
-- 	local str = ""
-- 	local day = math.floor(time/DAY)
-- 	time = time%DAY
-- 	local hour = math.floor(time/HOUR)
-- 	hour = hour < 10 and "0"..hour or hour
-- 	time = time%HOUR
-- 	local min = math.floor(time/MIN)
-- 	min = min < 10 and "0"..min or min
-- 	time = time%MIN
-- 	local sec = math.floor(time)
-- 	sec = sec < 10 and "0"..sec or sec
-- 	if day > 0 then
-- 		str = day.."天 "..hour..":"..min..":"..sec
-- 	else
-- 		str = hour..":"..min..":"..sec
-- 	end
-- 	return str
-- end

function QUIDialogMockBattle:showPhaseMatch()

	local is_cur_phase = self._cur_phase ==  QMockBattle.PHASE_MATCH or self._cur_phase ==  QMockBattle.PHASE_END

	self._ccbOwner.node_phase_3:setVisible(is_cur_phase)
	self._ccbOwner.node_next_award:setVisible(is_cur_phase)
	if not is_cur_phase then return end
	self.lose_num = remote.mockbattle:getMockBattleRoundInfo().loseCount or 0
	self.win_num = remote.mockbattle:getMockBattleRoundInfo().winCount or 0
	self.totle_integral_num = remote.mockbattle:getMockBattleUserInfo().totalScore or 0	

	self:updateMatchBtn()

	self:updateNumPic(self._ccbOwner.node_pic_num,self.totle_integral_num,-1)
	self:updateNumPic(self._ccbOwner.node_cur_score,self.win_num,0)

	local top_win_num = remote.mockbattle:getMockBattleUserInfo().topWinCount or 0
	self:updateNumPic(self._ccbOwner.node_top_win,top_win_num,-1)

	-- if self.totle_integral_num > 999 then
	-- 	self._ccbOwner.node_pic_num:setScale(0.8 * 0.65)
	-- else
	-- 	self._ccbOwner.node_pic_num:setScale(0.65)
	-- end

	-- 若战斗返回后 变换徽章 需要播放动画
	if remote.mockbattle:getMockBattleWinMark() == 1 and self._isBatlleBack  then
		self:checkScoreSpriteBgAndAction()
	else
		self:updateScoreSpriteBg(self.win_num)
	end

	for i=1,5 do
		local lose = i <= self.lose_num
		self._ccbOwner["sp_lose_n"..i]:setVisible(not lose)
		self._ccbOwner["sp_lose_y"..i]:setVisible(lose)
	end

	if self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE then
		for i=1,5 do
			self._ccbOwner["sp_lose_n"..i]:setPositionX(146 + ( i - 1 ) * 40)
			self._ccbOwner["sp_lose_y"..i]:setPositionX(146 + ( i - 1 ) * 40)
		end
	else
		for i=4,5 do
			self._ccbOwner["sp_lose_n"..i]:setVisible(false)
			self._ccbOwner["sp_lose_y"..i]:setVisible(false)
		end
	end


	if self._isChangePhase then
		self:playMacthAppear()
	end

end


function QUIDialogMockBattle:checkScoreSpriteBgAndAction()
	local  need_action = false
	local  final_scale = 1
	local frame = nil
	local  max_win_num , max_lose_num  = remote.mockbattle:getMockBattleMaxWinAndLoseNum()
	local silver =  max_win_num * 0.4
	local golden =  max_win_num * 0.8

	local oldWin = remote.mockbattle:getMockBattleOldWinValue()
	if self.win_num >= silver   and oldWin <  silver  then
		need_action = true
	elseif self.win_num  >= golden and oldWin < golden then
		need_action = true
	elseif self.win_num >= max_win_num then
		need_action = true
		final_scale = 0.8
		--延迟播放满胜界面
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(q.flashFrameTransferDur(20)))
		arr:addObject(CCCallFunc:create(function()
			self:showFullWinDialog()
		end))
		self._ccbOwner.node_cur_integral:runAction(CCSequence:create(arr))
	end

	if need_action then

		self:updateScoreSpriteBg(oldWin)

		local fcaAnimation = QUIWidgetFcaAnimation.new("fca/dsmnz_bao_1", "res")
        self._ccbOwner.node_cur_integral:addChild(fcaAnimation)
        fcaAnimation:playAnimation("animation", false)
        fcaAnimation:setEndCallback(function( )
            fcaAnimation:removeFromParent()
        end)

		local dur1 = q.flashFrameTransferDur(5)
			local arr = CCArray:create()
	        arr:addObject(CCScaleTo:create(dur1, 0.7 ))
			arr:addObject(CCCallFunc:create(function()
				self:updateScoreSpriteBg(self.win_num)
    			self._ccbOwner.sp_score_bg:stopAllActions()
				self._ccbOwner.sp_score_bg:runAction(CCScaleTo:create(dur1, 1 * final_scale))
			end))
	        self._ccbOwner.sp_score_bg:runAction(CCSequence:create(arr))
		return
	end

	self:updateScoreSpriteBg(self.win_num)

end

function QUIDialogMockBattle:updateScoreSpriteBg(win_num)
	local frame = nil
	local  max_win_num , max_lose_num  = remote.mockbattle:getMockBattleMaxWinAndLoseNum()
	local silver =  max_win_num * 0.4
	local golden =  max_win_num * 0.8
	if win_num < silver then
		frame = QSpriteFrameByPath(QResPath("mockbattle_scoreSp_bg")[1])
	elseif win_num < golden then
		frame = QSpriteFrameByPath(QResPath("mockbattle_scoreSp_bg")[2])
	elseif win_num == max_win_num  then
		frame = QSpriteFrameByPath(QResPath("mockbattle_scoreSp_bg")[4])
	else
		frame = QSpriteFrameByPath(QResPath("mockbattle_scoreSp_bg")[3])
	end

	if frame then
		self._ccbOwner.sp_score_bg:setDisplayFrame(frame)
	end
end

function QUIDialogMockBattle:showPhaseSeasonEnd()
	local is_cur_phase = self._cur_phase == QMockBattle.PHASE_SEASON_END
	self._ccbOwner.node_phase_4:setVisible(is_cur_phase)
	if not is_cur_phase then return end

	local topWinCount =  remote.mockbattle:getMockBattleUserInfo().topWinCount or 0
	local season_win_num = remote.mockbattle:getMockBattleUserInfo().seasonTotalWinCount or 0
	self.totle_integral_num = remote.mockbattle:getMockBattleUserInfo().totalScore or 0	
	self:updateNumPic(self._ccbOwner.node_season_end_win,topWinCount,-1)
	self:updateNumPic(self._ccbOwner.node_season_end_lose,season_win_num,-1)
	self:updateNumPic(self._ccbOwner.node_season_pic_num,self.totle_integral_num,0)
	if self.totle_integral_num > 999 then
		self._ccbOwner.node_season_pic_num:setScale(0.8)
	else
		self._ccbOwner.node_season_pic_num:setScale(1)
	end

end

function QUIDialogMockBattle:updateShowTimer()
	local is_cur_phase = self._cur_phase == QMockBattle.PHASE_SEASON_END or self._cur_phase ==  QMockBattle.PHASE_MATCH or self._cur_phase ==  QMockBattle.PHASE_END
	self._ccbOwner.node_season_timer:setVisible(is_cur_phase)

	if self._cur_phase == QMockBattle.PHASE_SEASON_END then
		self._ccbOwner.tf_season_time_desc:setString("下赛季开始时间：")
	else
		self._ccbOwner.tf_season_time_desc:setString("赛季结算时间：")
	end
	self._ccbOwner.sp_season_time:setPositionX(self._ccbOwner.tf_season_time_desc:getPositionX() - self._ccbOwner.tf_season_time_desc:getContentSize().width - 20)


	self:handlerTimer()
end

function QUIDialogMockBattle:handlerTimer()
	if self._fun == nil then
	    self._fun = function ()
	    	local currTime = q.serverTime()
	    	local endTime = remote.mockbattle:getMockBattleSeasonInfo().endAt or 0
	    	endTime = endTime / 1000
	    	-- if self._cur_phase ~= QMockBattle.PHASE_SEASON_END then
	    	-- 	-- endTime = endTime - 7 * DAY
	    	-- 	endTime = endTime 
	    	-- end
			endTime = endTime - currTime
			if endTime > 0 then
	    		self._ccbOwner.tf_season_timer:setString(q.converFun(endTime))
	    	else
	    		if self._seasonScheduler then
	    			scheduler.unscheduleGlobal(self._seasonScheduler)
	    			self._seasonScheduler = nil
	    		end
	    		self._ccbOwner.tf_season_timer:setString("赛季结束")
	    		--赛季结束 推出大师模拟战
	    		app.tip:floatTip("赛季已经结束，请重新进入开启新赛季")
	    		
				local arr = CCArray:create()
				arr:addObject(CCDelayTime:create(0.1))
				arr:addObject(CCCallFunc:create(function()
	    			self:_BackMockBattle()
				end))
				self._ccbOwner.tf_season_timer:stopAllActions()
	        	self._ccbOwner.tf_season_timer:runAction(CCSequence:create(arr))
	    	end
	    end
	end
	
	if self._seasonScheduler == nil then
    	self._seasonScheduler = scheduler.scheduleGlobal(self._fun, 1)
	end
    self._fun()
end

function QUIDialogMockBattle:updatePickInfo()

	local is_cur_phase =  self._cur_phase ==  QMockBattle.PHASE_PICK or self._cur_phase ==  QMockBattle.PHASE_MATCH or self._cur_phase ==  QMockBattle.PHASE_END
	if not is_cur_phase then 
		self._ccbOwner.node_pinfo:setVisible(false)
		return 
	end
	self._ccbOwner.node_pinfo:setVisible(true)

	self._ccbOwner.btn_del:setVisible(self._cur_phase ~=  QMockBattle.PHASE_END )
	self._ccbOwner.tf_del:setVisible(self._cur_phase ~=  QMockBattle.PHASE_END )


	local cur = remote.mockbattle:getChooseCardsNumByType( QMockBattle.CARD_TYPE_HERO)
	local max_num = remote.mockbattle:getCardMaxBySeasonAndType( self._seasonType, QMockBattle.CARD_TYPE_HERO)
	self._ccbOwner.tf_cur_hero_num:setString(cur.."/"..max_num)
	cur = remote.mockbattle:getChooseCardsNumByType( QMockBattle.CARD_TYPE_SOUL)
	max_num = remote.mockbattle:getCardMaxBySeasonAndType( self._seasonType, QMockBattle.CARD_TYPE_SOUL)	
	self._ccbOwner.tf_cur_soul_num:setString(cur.."/"..max_num)
	cur = remote.mockbattle:getChooseCardsNumByType( QMockBattle.CARD_TYPE_MOUNT)
	max_num = remote.mockbattle:getCardMaxBySeasonAndType( self._seasonType, QMockBattle.CARD_TYPE_MOUNT)		
	self._ccbOwner.tf_cur_mount_num:setString(cur.."/"..max_num)
	cur = remote.mockbattle:getChooseCardsNumByType( QMockBattle.CARD_TYPE_GODARM)
	max_num = remote.mockbattle:getCardMaxBySeasonAndType( self._seasonType, QMockBattle.CARD_TYPE_GODARM)		
	self._ccbOwner.tf_cur_godarm_num:setString(cur.."/"..max_num)
end


function QUIDialogMockBattle:updateNumPic(node_ , num , anchor) --anchor -1:left 0 : mid 1:right
	local num_table = {}
	num = tonumber(num)
	while num >= 10 do
		table.insert(num_table, num % 10 )
		num = math.floor(num / 10)
	end
	table.insert(num_table, num )
	local num_node = CCNode:create()
	local width = 0
	for i,value in pairs(num_table) do
		--local frame = QSpriteFrameByPath()
		local sprite = CCSprite:create(QResPath("mockbattle_num")[value + 1])
		-- width = width + sprite:getContentSize().width * 0.5
		-- width = width + sprite:getContentSize().width * 0.5
		sprite:setAnchorPoint(ccp(1, 0.5))
		sprite:setPositionX(- width)
		width = width + sprite:getContentSize().width 
		num_node:addChild(sprite)
	end

	if anchor  then
		if anchor == -1 then
			num_node:setPositionX(width) 
		elseif anchor == 0 then
			num_node:setPositionX( width * 0.5) 
		elseif anchor == 1 then
			num_node:setPositionX(0) 
		end
	else
		num_node:setPositionX(  width * 0.5) 
	end

	node_:removeAllChildren()
	node_:addChild(num_node)
end



function QUIDialogMockBattle:updateAwardInfo()
	if self._cur_phase ~=  QMockBattle.PHASE_MATCH then 
		self._ccbOwner.node_next_award:setVisible(false)
		return 
	end
	self._ccbOwner.node_next_award:setVisible(true)

	local  max_win_num , max_lose_num  = remote.mockbattle:getMockBattleMaxWinAndLoseNum()
	if self.win_num >= max_win_num then
	self._ccbOwner.node_next_award:setVisible(false)
		return 
	end
    local index_ = 1
    self._awardNodes = {}
    local score_item_num = db:getMockBattleScoreRewardById(self.win_num + 1 , self._seasonType)
	if score_item_num > 0 then
		local itemBox = QUIWidgetItemsBox.new()
	    itemBox:setPromptIsOpen(true)
	    itemBox:setGoodsInfo(70, "mock_battle_integral",score_item_num)
	    itemBox:setPositionX((index_-1)*92)
	    itemBox:setScale(0.7)
	    self._ccbOwner.node_next_award:addChild(itemBox)
	    table.insert(self._awardNodes,itemBox)
	    index_ = index_ +1
	end
	local top_win_num = remote.mockbattle:getMockBattleUserInfo().topWinCount or 0

	if self.win_num + 1 > top_win_num then
	    local item_reward = db:getMockBattleFirstWinRewardById(self.win_num + 1, self._seasonType)
		if item_reward then
	    	local item_table = string.split(item_reward, "^")
	    	--QPrintTable(item_table)
			local itemBox = QUIWidgetItemsBox.new()
		    itemBox:setPromptIsOpen(true)
		    itemBox:setGoodsInfo(nil,item_table[1], tonumber(item_table[2]))
		    itemBox:setPositionX((index_-1)*92)
		    itemBox:setFirstAward(true)
		    itemBox:setScale(0.7)
		    self._ccbOwner.node_next_award:addChild(itemBox)
	    	table.insert(self._awardNodes,itemBox)
		end
	end

	if self._isBatlleBack then
		for i,itemBox in ipairs(self._awardNodes) do
	    	itemBox:setVisible(false)
			local dur2 = q.flashFrameTransferDur(30)
			local arr = CCArray:create()
	        arr:addObject(CCDelayTime:create(dur2))
			arr:addObject(CCCallFunc:create(function()
	    		itemBox:setVisible(true)
	    		itemBox:setScale(0.1)
				itemBox:stopAllActions()
				itemBox:runAction(CCScaleTo:create(0.5, 0.7))
			end))
	        itemBox:runAction(CCSequence:create(arr))
		end
	end
end

function QUIDialogMockBattle:updateSeasonAwardInfo()
	self._ccbOwner.node_season_end_award:setVisible(self._cur_phase ==  QMockBattle.PHASE_SEASON_END)
	if self._cur_phase ~=  QMockBattle.PHASE_SEASON_END then 
		return 
	end

    local index_ = 1
	if self.totle_integral_num > 0 then
		local itemBox = QUIWidgetItemsBox.new()
	    itemBox:setPromptIsOpen(true)
	    itemBox:setGoodsInfo(70, "mock_battle_integral",self.totle_integral_num)
	    itemBox:setPositionX((index_-1)*92)
	    itemBox:setScale(0.7)
	    self._ccbOwner.node_season_end_award:addChild(itemBox)
	    index_ = index_ +1
	end


	local top_win_num = remote.mockbattle:getMockBattleUserInfo().topWinCount or 0
	local first_num = 0
	if top_win_num > 0 then
		for i=1,top_win_num do
	    	local item_reward = db:getMockBattleFirstWinRewardById(i, self._seasonType)
	    	if item_reward then
	    		local item_table = string.split(item_reward, "^")
	    		first_num = first_num +tonumber(item_table[2])
		    	if i == top_win_num then
					local itemBox = QUIWidgetItemsBox.new()
				    itemBox:setPromptIsOpen(true)
				    itemBox:setGoodsInfo(nil,item_table[1], tonumber(first_num))
				    itemBox:setPositionX((index_-1)*92)
				    --itemBox:setFirstAward(true)
				    itemBox:setScale(0.7)
				    self._ccbOwner.node_season_end_award:addChild(itemBox)
		    	end
	    	end
		end
	end
end


function QUIDialogMockBattle:updateSeasonInfo()

	if self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE then
		self._ccbOwner.tf_season_name:setString("双队模拟战")
		QSetDisplayFrameByPath(self._ccbOwner.sp_title_type, QResPath("mockbattle_season_title")[self._seasonType])

		self._ccbOwner.sp_single_cardnum_bg:setVisible(false)
		self._ccbOwner.sp_double_cardnum_bg:setVisible(true)
	
		self._ccbOwner.tf_godarm_numdesc:setVisible(true)
		self._ccbOwner.tf_cur_godarm_num:setVisible(true)
		self._ccbOwner.btn_rewardtips:setVisible(self._cur_phase ~=  QMockBattle.PHASE_END and true)

		self._ccbOwner.btn_del:setPositionY(-220)
		self._ccbOwner.tf_del:setPositionY(-220)

		self._ccbOwner.touch_cardinfo:setContentSize(130, 280)

	else
		self._ccbOwner.tf_season_name:setString("单队模拟战")
		QSetDisplayFrameByPath(self._ccbOwner.sp_title_type,  QResPath("mockbattle_season_title")[self._seasonType])
		self._ccbOwner.sp_single_cardnum_bg:setVisible(true)
		self._ccbOwner.sp_double_cardnum_bg:setVisible(false)
		self._ccbOwner.btn_rewardtips:setVisible(false)
	
		self._ccbOwner.tf_godarm_numdesc:setVisible(false)
		self._ccbOwner.tf_cur_godarm_num:setVisible(false)
		self._ccbOwner.btn_del:setPositionY(-154)
		self._ccbOwner.tf_del:setPositionY(-154)
		self._ccbOwner.touch_cardinfo:setContentSize(130, 230)

	end


	local seasoninfo = remote.mockbattle:getMockBattleSeasonInfo() 
	local startAt = seasoninfo.startAt or 1574200000000
	local endAt = seasoninfo.endAt or 1574500000000
	local date_start = q.date("*t", startAt/1000)
	local date_end = q.date("*t", endAt/1000)
	local dateStr = string.format("%s年%s月%s日-%s年%s月%s日", date_start.year, date_start.month, date_start.day, date_end.year, date_end.month, date_end.day)
	self._ccbOwner.tf_last_time:setString(dateStr)
end


function QUIDialogMockBattle:checkEjectIntroduce()
	local isIntro_single = app:getUserData():getUserValueForKey("MOCK_BATTLE_SINGLE_TEAM"..tostring(remote.user.userId))
	local isIntro_double = app:getUserData():getUserValueForKey("MOCK_BATTLE_DOUBLE_TEAM"..tostring(remote.user.userId))
	self._seasonType = remote.mockbattle:getMockBattleSeasonType()
	if not isIntro_single and self._seasonType == QMockBattle.SEASON_TYPE_SINGLE then
		self:_onTriggerSeasonTips()
		app:getUserData():setUserValueForKey("MOCK_BATTLE_SINGLE_TEAM"..tostring(remote.user.userId),"1" )
	elseif not isIntro_double and self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE then
		self:_onTriggerSeasonTips()
		app:getUserData():setUserValueForKey("MOCK_BATTLE_DOUBLE_TEAM"..tostring(remote.user.userId),"1" )
	end

end

--若检测到活动截止时间小于当前时间每隔10秒请求一次服务器数据 来刷新 活动数据
function QUIDialogMockBattle:checkSeasonTimeToRefresh()
	local currTime = q.serverTime()
	local endTime = remote.mockbattle:getMockBattleSeasonInfo().endAt or 0

	if currTime > endTime then
		if self._seasonEndRequestScheduler == nil then
			local requestFunc = function()
				local exit_callback =  self:safeHandler(function () 
					remote.mockbattle:setMockBattleisRoundEnd(false)
					self:setSelfInfo()
				end)
				remote.mockbattle:mockBattleGetMainInfoRequest(exit_callback)	
			end

	    	self._seasonEndRequestScheduler = scheduler.scheduleGlobal(requestFunc, 10)
	    	requestFunc()
		end
	else
	   	if self._seasonEndRequestScheduler ~= nil then
	    	scheduler.unscheduleGlobal(self._seasonEndRequestScheduler)
	    	self._seasonEndRequestScheduler = nil
	    end    
	end
end


function QUIDialogMockBattle:ShowEffect()
	self._ccbOwner.node_fly_pos:removeAllChildren()
	local ccbFile = "effects/tx_baoguang_effect.ccbi"
	local effect = QUIWidget.new(ccbFile)
	effect:setScale(0.1)
	self._ccbOwner.node_fly_pos:addChild(effect)

    local dur2 = q.flashFrameTransferDur(6)
	local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(dur2))
    arr:addObject(CCCallFunc:create(function()
    	effect:stopAllActions()
    	effect:removeFromParent()
    end))
	effect:runAction(CCSequence:create(arr))
end


function QUIDialogMockBattle:updateMatchBtn()
	self._ccbOwner.btn_rewardtips:setVisible(true)
	self._ccbOwner.tf_match:setString("匹配对手")
	local  max_win_num , max_lose_num  = remote.mockbattle:getMockBattleMaxWinAndLoseNum()

	if self._cur_phase ==  QMockBattle.PHASE_END then
		self._ccbOwner.btn_rewardtips:setVisible(false)

		if self.lose_num >=  max_lose_num then
			self._ccbOwner.tf_match:setString("遗憾退场")
		else
			self._ccbOwner.tf_match:setString("胜利闭幕")
		end

	elseif remote.mockbattle:checkIsMatchRound() then
		self._ccbOwner.tf_match:setString("继续挑战")
	end
end


function QUIDialogMockBattle:playMacthAppear()
    self._ccbOwner.node_phase_3:stopAllActions()
    self._ccbOwner.node_phase_3:setScale(0.1)
	self._ccbOwner.node_phase_3:runAction(CCScaleTo:create(0.3, 1))
end

function QUIDialogMockBattle:exitFromBattleHandler()
	self._isBatlleBack = true
	if remote.mockbattle:getMockBattleWinMark() == 1 then
		--奖励飞入动画
		self:playAwardFlyAction() 
		self:setSelfInfo()
		self._ccbOwner.node_cur_score:stopAllActions()
    	self._ccbOwner.node_cur_score:setScale(1.8)
		self._ccbOwner.node_cur_score:runAction(CCScaleTo:create(0.3, 1))

	elseif remote.mockbattle:getMockBattleWinMark() == 2 then
		self:cleanAward()
		self:setSelfInfo()
		if self.lose_num  and self.lose_num ~= 0 and self._ccbOwner["sp_lose_y"..self.lose_num] then
			self._ccbOwner["sp_lose_y"..self.lose_num]:stopAllActions()
	    	self._ccbOwner["sp_lose_y"..self.lose_num]:setScale(1.8)
			self._ccbOwner["sp_lose_y"..self.lose_num]:runAction(CCScaleTo:create(0.3, 1))
		end
	end
	self._isBatlleBack = false
	remote.mockbattle:clearMockBattleisWinMark()
end

function QUIDialogMockBattle:cleanAward()
	for i,node_ in ipairs(self._awardNodes or {}) do
		if node_ then
		    node_:removeFromParent()
		end
	end

end


function QUIDialogMockBattle:playAwardFlyAction()
	print("QUIDialogMockBattle:playAwardFlyAction ====== ")
	local xx = self._ccbOwner.node_reward_fly:getPositionX()
	local yy = self._ccbOwner.node_reward_fly:getPositionY()

    local dur = q.flashFrameTransferDur(20)

	for i,node_ in ipairs(self._awardNodes or {}) do
		if node_ then
			local array2 = CCArray:create()
		    array2:addObject(CCMoveTo:create(dur,  ccp(xx, yy)))
		    array2:addObject(CCScaleTo:create(dur, 0.1))
		    local arr = CCArray:create()
		    arr:addObject(CCSpawn:create(array2))
		    arr:addObject(CCCallFunc:create(function()
				node_:removeFromParent()
		    end))
		    node_:stopAllActions()
			node_:runAction(CCSequence:create(arr))
		end
	end

end


function QUIDialogMockBattle:showFullWinDialog()

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleFullWin",
		options = {}})
end


-------------------------------------------
function QUIDialogMockBattle:_onTriggerClickShowReward()

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRewardInfo",
		options = {showCancel = false ,notGiveUp = true, rewardType ="MOCK_BATTLE" }})
end

function QUIDialogMockBattle:_onTriggerRewardTips()
app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleRewardTips",
		options = {}})
end

function QUIDialogMockBattle:showEndDialog()
	local exit_callback =  self:safeHandler(function () 
		remote.mockbattle:setMockBattleisRoundEnd(false)
		self:setSelfInfo()
	end)
	-- local exit_callback = function ( ... )
	-- 	-- body
	-- 	remote.mockbattle:setMockBattleisRoundEnd(false)
	-- 	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QMockBattle.MOCKBATTLE_PHASE_UPDATE})
	-- end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRewardInfo",
		options = {showCancel = false ,exit_callback = exit_callback , rewardType ="MOCK_BATTLE" }})
end


function QUIDialogMockBattle:_onTriggerMatch()

	if self._cur_phase ==  QMockBattle.PHASE_END then
		self:showEndDialog()
		return
	end

	local success = function() 
		self:_reqBattleInfo()
	end
	if remote.mockbattle:checkIsMatchRound() then
		success()
		return 
	end

	remote.mockbattle:mockBattleMatchRequest(success,nil)
end


function QUIDialogMockBattle:_reqBattleInfo()
	local success = function() 
		local arrangements ={}
		if self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE then
			local mockBattleArrangement1 = QMockBattleArrangement.new({teamKey = remote.teamManager.MOCK_BATTLE_DOUBLE_TEAM1 })
			local mockBattleArrangement2 = QMockBattleArrangement.new({teamKey = remote.teamManager.MOCK_BATTLE_DOUBLE_TEAM2 })
			table.insert(arrangements , mockBattleArrangement1)
			table.insert(arrangements , mockBattleArrangement2)
		else
			local mockBattleArrangement = QMockBattleArrangement.new({teamKey = remote.teamManager.MOCK_BATTLE_TEAM })
			table.insert(arrangements , mockBattleArrangement)
		end

		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMockTeamArrangement"
			,options = {arrangements = arrangements,seasonType = self._seasonType , backCallback = self:safeHandler(function () 
						self:updateMatchBtn()
					end) }})
	end
	--success()

	remote.mockbattle:mockBattleQueryFighterRequest(success,nil)
end


function QUIDialogMockBattle:_onTriggerDel()
	local ok_callback = function ( ... )
		-- body
		remote.mockbattle:mockBattleGiveUpequest(self:safeHandler(function () 
		self:setSelfInfo()
	end),nil)
	end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRewardInfo",
		options = {ok_callback = ok_callback , showCancel = true , rewardType ="MOCK_BATTLE" }})
end

function QUIDialogMockBattle:_onTriggerPlus()

	local buyedCount = remote.mockbattle:getMockBattleUserInfo().buyCount or 0
	--local totlebuyCount = QVIPUtil:getCountByWordField("mock_battle_times")
	local totlebuyCount = QVIPUtil:getMockBattleTicketCount()
	if buyedCount < totlebuyCount then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCount",
			options = {typeName = QUIDialogBuyCount["BUY_TYPE_16" ], buyCallback = self:safeHandler(function () 
					self:showPhaseSignUp()
				end)}})
	else
		app.tip:floatTip("挑战次数已用完")
	end

end

function QUIDialogMockBattle:_onTriggerSignUp()
	if self.cur_ticket <= 0 then
    	app.tip:floatTip("挑战次数不足")
    	self:_onTriggerPlus()
		return
	end

	local success = function() 
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSignUpSuccess",
			options = {callback = self:safeHandler(function () 
					self:setSelfInfo()
				end)}})
	end
	remote.mockbattle:mockBattleSignUpRequest(success,nil)
end

function QUIDialogMockBattle:_onTriggerPick()
	print("_onTriggerPick")

	if self._pickNode and self._pickNode:getIsAction() then
		return
	end

	local index_ = self._pickNode:getChosenIdx()
	if index_ == 0 then return end

	local success = function() 
		self.chooseInfo = remote.mockbattle:getMockBattleRoundInfo().chooseInfo	or {}
		local max_card_num = remote.mockbattle:getTotalCardMaxNumBySeasonType(self._seasonType)
		if #self.chooseInfo >= max_card_num then
			self:setSelfInfo()
		else
			local achieveEndPos = self._ccbOwner.node_fly_pos:convertToWorldSpace(ccp(0, 0))
			self._pickNode:playChooseCardFlyAction(achieveEndPos)
			self:showPhasePick()
			self:updatePickInfo()
		end
	end
	remote.mockbattle:mockBattleChooseCardRequest(self.nowGridInfo[index_],success,nil)	
end

function QUIDialogMockBattle:_onTriggerClickChosenCard()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleCardInfo",
			options = {info = self.chooseInfo , isDouble = self._seasonType == 2}}, {isPopCurrentDialog = false})
end

function QUIDialogMockBattle:_onTriggerCardsHelp(event)
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleCardInfo",
			options = {info = self.chooseInfo, isDouble = self._seasonType == 2}}, {isPopCurrentDialog = false})
end


function QUIDialogMockBattle:_onTriggerSeasonTips(event)
    app.sound:playSound("common_small")



    local dur_ = q.flashFrameTransferDur(11)

	self._ccbOwner.mySeasonInfo:stopAllActions()
	self._ccbOwner.tf_season_name:setOpacityModifyRGB(true)

	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.mySeasonInfo,dur_,0)
   local exit_callback = function() 
		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.mySeasonInfo,dur_,255)
	end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMockBattleIntro", options = {callback = exit_callback , seasonType = self._seasonType}}, {isPopCurrentDialog = false})

end


-------------------------------------------

function QUIDialogMockBattle:_onTriggerRecord()
	app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleRecord",
    	options = {}}, {isPopCurrentDialog = false})		
end

function QUIDialogMockBattle:_onTriggerStatistics()
	app.sound:playSound("common_small")
	local success = function() 
	  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleRank",
    		options = {}}, {isPopCurrentDialog = false})
	end
	remote.mockbattle:mockBattleGetTopHeroRankListRequest(success,nil)
	--success()
end

function QUIDialogMockBattle:_onTriggerStore()

	app.sound:playSound("common_small")

	remote.stores:openShopDialog(SHOP_ID.mockbattleShop,function()
		if self:safeCheck() then
			self:updateTopPage()
		end
	end)
	-- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilverStore",
	-- 	options = {type = SHOP_ID.mockbattleShop , callback =  self:safeHandler(function () 
	-- 				self:updateTopPage()
	-- 			end)}}, {isPopCurrentDialog = false})
end

function QUIDialogMockBattle:_onTriggerReward()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleScore"}, {isPopCurrentDialog = false})	
end

function QUIDialogMockBattle:_onTriggerRule()

    app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleHelp",
    	options = {}}, {isPopCurrentDialog = false})
end

function QUIDialogMockBattle:_BackMockBattle()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
 	if page and page._onTriggerBack then page:_onTriggerBack() end
end


function QUIDialogMockBattle:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMockBattle:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end
return QUIDialogMockBattle