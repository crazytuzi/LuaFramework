-- @Author: xurui
-- @Date:   2018-08-16 17:25:05
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-08-24 19:20:06
-- Author: Kumo
-- Date: 2017-09-29
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QMetalCityDialogWin = class(".QMetalCityDialogWin", QBattleDialogBaseFightEnd)
local QTutorialDefeatedGuide = import(".....tutorial.defeated.QTutorialDefeatedGuide")
local QUIDialogMystoryStoreAppear = import("....dialogs.QUIDialogMystoryStoreAppear")
local QUIWidgetBattleWinHeroHead = import("....widgets.QUIWidgetBattleWinHeroHead")
local QTextFiledScrollUtils = import(".....utils.QTextFiledScrollUtils")
local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")
local QUIViewController = import("....QUIViewController")
local QBattleLog = import(".....controllers.QBattleLog")
local QBuriedPoint = import(".....utils.QBuriedPoint")
local QUIWidget = import(".....ui.widgets.QUIWidget")

function QMetalCityDialogWin:ctor(options, owner)
	print("<<<QMetalCityDialogWin>>>")
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QMetalCityDialogWin.super.ctor(self, options, owner)
    -- self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))
	self:resetAll()


	--保存传递数据 awards
	local data = options.config
	--显示胜负背景和client
	local isWin = options.isWin
	--显示星星title或文字title
	local star = options.star or 0
	local text = options.text or ""
	--显示比赛信息、魂师、数据
	local isHero = options.isHero
	local isFightData = options.isFightData
	
	local activityYield = options.activityYield

	-- 是否屏蔽打星震动的效果
	self._donotShakeScreen = false
	self._isWin = isWin
	self._schedulerHandlers = {}
	
	print("[Kumo] Battle_Dialog_FightEnd ", isWin, star, text)
	if isWin then
		self._audioHandler = app.sound:playSound("battle_complete")
		makeNodeFromGrayToNormal(self._ccbOwner.node_bg_mvp)

    	self._ccbOwner.node_win_text_title:setVisible(true)
		self._ccbOwner.node_win_client:setVisible(true)
		self._ccbOwner.node_bg_win:setVisible(true)

		self._ccbOwner.node_exp_money_score:setVisible(true)
		self._ccbOwner.node_exp:setVisible(true)
		self._ccbOwner.node_money:setVisible(true)
		self:onMoneyUpdate(0)
		self:onExpUpdate(0)
		


		self._ccbOwner.tf_award_title:setString("战斗奖励")
		self._ccbOwner.node_award_title:setVisible(true)
	else
		self._audioHandler = app.sound:playSound("battle_failed")
		makeNodeFromNormalToGray(self._ccbOwner.node_bg_mvp)

		self._ccbOwner.node_bg_lost:setVisible(true)
		self._ccbOwner.node_lost_client:setVisible(true)

		self:hideAllPic()
		self:chooseBestGuide()
	end


	if isHero then
		self._ccbOwner.node_hero_head:setVisible(true)
		-- self._heroBox = {}
	   	self:setHeroInfo(0)

	   	-- 中心对齐
	    local teamHero = remote.teamManager:getActorIdsByKey(self.teamName, 1)
	    local heroHeadCount = #teamHero
		if self.heroBox and heroHeadCount > 0 then
			local heroTotalWidth = self.heroHeadWidth * (heroHeadCount - 1) + (self.heroBox[1]:getSize().width * 1.5)
			self._ccbOwner.node_hero_head:setPositionX( self._ccbOwner.node_hero_head:getPositionX() + (self._ccbOwner.ly_hero_head_size:getContentSize().width - heroTotalWidth) / 2 )
		end
	end
	
	self._openTime = q.time()
	self._isFirst = options.isFirst
end

function QMetalCityDialogWin:onEnter()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QMetalCityDialogWin:onExit()
   self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
   	if self._schedulerHandlers ~= nil then
	   	for _,v in pairs(self._schedulerHandlers) do
	   		scheduler.unscheduleGlobal(v)
	   	end
   	end
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
   	if self._updateScheduler ~= nil then
		scheduler.unscheduleGlobal(self._updateScheduler)
		self._updateScheduler = nil
   	end
   	if self._expUpdate then
        self._expUpdate:stopUpdate()
        self._expUpdate = nil
    end
    if self._moneyUpdate then
        self._moneyUpdate:stopUpdate()
        self._moneyUpdate = nil
    end
	if self._shadowScheduler ~= nil then
		scheduler.unscheduleGlobal(self._shadowScheduler)
		self._shadowScheduler = nil
	end
	if self._effectScheduler ~= nil then
		scheduler.unscheduleGlobal(self._effectScheduler)
		self._effectScheduler = nil
	end
end

function QMetalCityDialogWin:_onTriggerNext()
	-- 埋点: “结算关卡X-Y点击”
	app:triggerBuriedPoint(QBuriedPoint:getDungeonWinBuriedPointID(self._dungeonID))
	
	app.sound:playSound("common_item")
  	self:_onClose()
end

function QMetalCityDialogWin:animationEndHandler(name)
	self._animationStage = name
end

return QMetalCityDialogWin
