--
-- Author: Your Name
-- Date: 2014-07-24 10:58:34
--
local QUIDialog = import(".QUIDialog")
local QUIDialogBuyCount = class("QUIDialogBuyCount", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBuyVirtualLog = import("..widgets.QUIWidgetBuyVirtualLog")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QVIPUtil = import("...utils.QVIPUtil")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QQuickWay = import("...utils.QQuickWay")
local QPayUtil = import("...utils.QPayUtil")

QUIDialogBuyCount.BUY_TYPE_1 = "bppty_bay" --活动本
QUIDialogBuyCount.BUY_TYPE_2 = "dwarf_cellar" --活动本
QUIDialogBuyCount.BUY_TYPE_3 = "strength_trial" --活动本
QUIDialogBuyCount.BUY_TYPE_4 = "sapiential_trial" --活动本
QUIDialogBuyCount.BUY_TYPE_5 = "intrusion_times" --要塞入侵
QUIDialogBuyCount.BUY_TYPE_6 = "dungeon_elite" --精英副本
QUIDialogBuyCount.BUY_TYPE_7 = "thunder_elite" --雷电王座精英试炼
QUIDialogBuyCount.BUY_TYPE_8 = "arena_times" --斗魂场
QUIDialogBuyCount.BUY_TYPE_9 = "tower_of_glory_times" --魂师大赛
QUIDialogBuyCount.BUY_TYPE_10 = "competion_times" --魂师大赛 争霸赛
QUIDialogBuyCount.BUY_TYPE_11 = "storm_arena_times" --风暴斗魂场 争霸赛
QUIDialogBuyCount.BUY_TYPE_12 = "yaosai_boss_times" --世界BOSS
QUIDialogBuyCount.BUY_TYPE_13 = "blackrock_award" --黑石塔
QUIDialogBuyCount.BUY_TYPE_14 = "maritime_num" --海商运送次数
QUIDialogBuyCount.BUY_TYPE_15 = "maritime_plunder" --海商掠夺次数
QUIDialogBuyCount.BUY_TYPE_16 = "mock_battle_times" --大师赛挑战次数


QUIDialogBuyCount.RFRESHE_GLORY_TOWER_FIGHT_NUM = "RFRESHE_GLORY_TOWER_FIGHT_NUM"  --魂师大赛挑战次数
QUIDialogBuyCount.RFRESHE_MARITIME_TRANSPORT_NUM = "RFRESHE_MARITIME_TRANSPORT_NUM"   --海商运送次数
QUIDialogBuyCount.RFRESHE_MARITIME_ROBBERY_NUM = "RFRESHE_MARITIME_ROBBERY_NUM"   --海商掠夺次数

function QUIDialogBuyCount:ctor(options)
	local ccbFile = "ccb/Dialog_Buy.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, QUIDialogBuyCount._onTriggerBuy)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogBuyCount._onTriggerClose)},
		{ccbCallbackName = "onTriggerBuyAgain", callback = handler(self, QUIDialogBuyCount._onTriggerBuyAgain)},
		{ccbCallbackName = "onTriggerVIP", callback = handler(self, QUIDialogBuyCount._onTriggerVIP)},
		{ccbCallbackName = "onTriggerBuyPrime", callback = handler(self, QUIDialogBuyCount._onTriggerBuyPrime)},
	}
	QUIDialogBuyCount.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示


	self._typeName = options.typeName
	self._buyCount = options.buyCount
	self._totalNum = options.totalNum
	self._dungeonId = options.dungeonId
	self._callBack = options.buyCallback

	self._ccbOwner.tf_1:setString("")
	self._ccbOwner.tf_2:setString("")
	self._ccbOwner.tf_buy:setString("")
	self._ccbOwner.tf_need_num:setString("")
	self._ccbOwner.tf_receive_num:setString("")
	self._ccbOwner.tf_tips:setString("")
	self._ccbOwner.tf_time_title:setVisible(false)
	self._ccbOwner.tf_time:setVisible(false)

	self._ccbOwner.icon_energy:setVisible(false)
	self._ccbOwner.icon_money:setVisible(false)
	self._ccbOwner.node_energy:setVisible(false)
	self._ccbOwner.node_money:setVisible(false)
	self._ccbOwner.btn_buyAgain:setVisible(false)
	self._ccbOwner.btn_buy:setVisible(false)
	self._ccbOwner.btn_VIP_Info:setVisible(false)
	self._ccbOwner.node_count:setVisible(false)
	self._ccbOwner.node_huodong:setVisible(false)
	self._ccbOwner.node_sunwar:setVisible(false)
	self._ccbOwner.node_invasion:setVisible(false)
	self._ccbOwner.node_society_dungeon:setVisible(false)
	self._ccbOwner.node_goldPickaxe:setVisible(false)
    self._ccbOwner.node_month_card:setVisible(false)

    self._ccbOwner.frame_tf_title:setString("购 买")

	self:refreshInfo()
	self._isAnimation = false
	self._energyCount = 0
	self._buyType = 0
end

function QUIDialogBuyCount:viewWillDisappear()
    QUIDialogBuyCount.super.viewWillDisappear(self)
    if self._delayHandler ~= nil then
		scheduler.unscheduleGlobal(self._delayHandler)	
	end
	
	if self._callBack and self._bought then 
		self._callBack() 
	end

	if self._rechargeProgress then
		scheduler.unscheduleGlobal(self._rechargeProgress)
		self._rechargeProgress = nil
	end
end

function QUIDialogBuyCount:refreshInfo()
	self._num = 0
	if self._totalNum == nil then
		self._totalNum = 0
	end
	if self._buyCount == nil then
		self._buyCount = 0
	end
    self._ccbOwner.node_month_card:setVisible(false)

	local config = db:getTokenConsumeByType(self._typeName)
	if config ~= nil then
		self._ccbOwner.btn_buy:setVisible(true)
		self._ccbOwner.btn_buy:setPositionX(0)
		if self._typeName == QUIDialogBuyCount.BUY_TYPE_1 then
			self._totalNum = QVIPUtil:getBarMaxCount()
			self._buyCount = remote.user.dungeonSeaBuyCount or 0
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_2 then
			self._totalNum = QVIPUtil:getSeaMaxCount()
			self._buyCount = remote.user.dungeonBarBuyCount or 0
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_3 then
			self._totalNum = QVIPUtil:getStengthMaxCount()
			self._buyCount = remote.user.dungeonStrengthBuyCount or 0
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_4 then
			self._totalNum = QVIPUtil:getIntellectMaxCount()
			self._buyCount = remote.user.dungeonSapientialBuyCount or 0
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_5 then
			self._totalNum = QVIPUtil:getInvasionTokenBuyCount()
			self._buyCount = remote.user.todayBuyIntrusionTokenCount or 0
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_6 then
			self._totalNum = QVIPUtil:getResetEliteDungeonCount()
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_7 then
			self._totalNum = QStaticDatabase:sharedDatabase():getConfiguration()["THUNDER_ELITE_BUY"].value
			self._buyCount = remote.thunder:getThunderFighter().thunderEliteChallengeBuyCount or 0
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_8 then
			self._totalNum = QVIPUtil:getArenaResetCount()
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_9 then
			self._totalNum = QVIPUtil:getTowerBuyCount()
			self._buyCount = remote.tower:getTowerInfo().fightTimesBuyCount or 0
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_10 then
			self._totalNum = QVIPUtil:getGloryArenaResetCount()
			-- self._buyCount = remote.tower.gloryArenaMyInfo.fightBuyCount or 0
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_11 then
			self._totalNum = QVIPUtil:getStormArenaResetCount()
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_12 then
			self._totalNum = QVIPUtil:getWorldBossBuyFightCount()
			self._buyCount = remote.worldBoss:getWorldBossInfo().buyFightCount or 0
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_13 then
			self._totalNum = QVIPUtil:getBlackRockBuyAwardsCount()
			self._buyCount = remote.blackrock:getMyInfo().buyAwardCount or 0
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_14 then
			self._totalNum = QVIPUtil:getMaritimeTransportCount()
			self._buyCount = remote.maritime:getMyMaritimeInfo().buyMaritimeCnt or 0
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_15 then
			self._totalNum = QVIPUtil:getMaritimeRobberyCount()
			self._buyCount = remote.maritime:getMyMaritimeInfo().buyLootCnt or 0
		elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_16 then
			self._totalNum = QVIPUtil:getMockBattleTicketCount()
			self._buyCount = remote.mockbattle:getMockBattleUserInfo().buyCount  or 0
		end

		self._num = self._totalNum - self._buyCount
	end

	local config = db:getTokenConsume(self._typeName, self._buyCount+1)
	self._needNum = config.money_num
	if self._typeName == QUIDialogBuyCount.BUY_TYPE_1 then
		self:setSeaInfo()
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_2 then
		self:setBarInfo()
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_3 then
		self:setStrengthInfo()
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_4 then
		self:setIntellectInfo()
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_5 then
		self:setInvasionInfo()
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_6 then
		self:setChallengeNumInfo(3, "UNLOCK_ELITE")
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_7 then
		self:setChallengeNumInfo(1, "UNLOCK_THUNDER")
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_8 then
		self:setChallengeNumInfo(1, "UNLOCK_ARENA")
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_9 then
		self:setChallengeNumInfo(1, "UNLOCK_TOWER_OF_GLORY", 0)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_10 then
		self:setChallengeNumInfo(1, "UNLOCK_TOWER_OF_GLORY", 0)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_11 then
		self:setChallengeNumInfo(1, "UNLOCK_STORM_ARENA")
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_12 then
		self:setWorldBossNumInfo(1, "UNLOCK_SHIJIEBOSS")
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_13 then
		self:setBlackRockNumInfo(1, "UNLOCK_BLACKROCK")
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_14 then
		self:setMaritimeNumInfo(1, "UNLOCK_MARITIME", "运送")
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_15 then
		self:setMaritimeNumInfo(1, "UNLOCK_MARITIME", "掠夺")
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_16 then
		self:setMockBattleInfo()
	end
	if self._num <= 0 then
		self._needVipAlert = true
	end
end

-- function QUIDialogBuyCount:showVIPButton()
-- 	self._ccbOwner.btn_buy:setVisible(false)
-- 	self._ccbOwner.btn_buyAgain:setVisible(false)
-- 	self._ccbOwner.btn_VIP_Info:setVisible(true)
-- end

function QUIDialogBuyCount:setSeaInfo()
	self:getView():setVisible(true)
	self._ccbOwner.node_huodong:setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买一次金魂币试炼次数")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 X 1")
	self._ccbOwner.tf_receive_num:setPositionX(15)
	self._ccbOwner.tf_tips:setString("每日可购买金魂币试炼次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新")

    if not remote.activity:checkMonthCardActive(2) then
        self._ccbOwner.node_month_card:setVisible(true)
        self._ccbOwner.node_all:setPositionX(140)
    end
end

function QUIDialogBuyCount:setBarInfo()
	self:getView():setVisible(true)
	self._ccbOwner.node_huodong:setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买一次经验试炼次数")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 X 1")
	self._ccbOwner.tf_receive_num:setPositionX(15)
	self._ccbOwner.tf_tips:setString("每日可购买经验试炼次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新")

	if not remote.activity:checkMonthCardActive(2) then
        self._ccbOwner.node_month_card:setVisible(true)
        self._ccbOwner.node_all:setPositionX(140)
    end
end

function QUIDialogBuyCount:setStrengthInfo()
	self:getView():setVisible(true)
	self._ccbOwner.node_huodong:setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买一次力量试炼次数")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 X 1")
	self._ccbOwner.tf_receive_num:setPositionX(15)
	self._ccbOwner.tf_tips:setString("每日可购买力量试炼次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新")
end

function QUIDialogBuyCount:setIntellectInfo()
	self:getView():setVisible(true)
	self._ccbOwner.node_huodong:setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买一次智慧试炼次数")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 X 1")
	self._ccbOwner.tf_receive_num:setPositionX(15)
	self._ccbOwner.tf_tips:setString("每日可购买智慧试炼次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新")
end

function QUIDialogBuyCount:setInvasionInfo()
	self:getView():setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买一次攻击次数")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 X 1")
	self._ccbOwner.tf_receive_num:setPositionX(15)
	self._ccbOwner.tf_tips:setString("每日可购买攻击次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新")
	self._ccbOwner.node_invasion:setVisible(true)
end

function QUIDialogBuyCount:setChallengeNumInfo(challengeNum, unlockType, refreshTime)
	self:getView():setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买挑战次数")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 X "..(challengeNum or 1))
	self._ccbOwner.tf_receive_num:setPositionX(15)

	refreshTime = refreshTime == nil and remote.user.c_systemRefreshTime or refreshTime
	self._ccbOwner.tf_tips:setString("每日可购买挑战次数在凌晨"..refreshTime.."点刷新")

    local unlockInfo = app.unlock:getConfigByKey(unlockType)
	self:setIconPath(unlockInfo.icon)
end


function QUIDialogBuyCount:setWorldBossNumInfo(challengeNum, unlockType, refreshTime)
	self:getView():setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买挑战次数")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 X "..(challengeNum or 1))
	self._ccbOwner.tf_receive_num:setPositionX(15)

	refreshTime = refreshTime == nil and remote.user.c_systemRefreshTime or refreshTime
	self._ccbOwner.tf_tips:setString("攻打boss可能获得幸运奖励哦")

    local unlockInfo = app.unlock:getConfigByKey(unlockType)
	self:setIconPath(unlockInfo.icon)
end

function QUIDialogBuyCount:setBlackRockNumInfo(challengeNum, unlockType, refreshTime)
	self:getView():setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买奖励次数")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 X "..(challengeNum or 1))
	self._ccbOwner.tf_receive_num:setPositionX(15)

	refreshTime = refreshTime == nil and remote.user.c_systemRefreshTime or refreshTime
	self._ccbOwner.tf_tips:setString("每日可购买挑战次数在凌晨"..refreshTime.."点刷新")

    local unlockInfo = app.unlock:getConfigByKey(unlockType)
	self:setIconPath(unlockInfo.icon)
end

function QUIDialogBuyCount:setMaritimeNumInfo(challengeNum, unlockType, content)
	self:getView():setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买"..content.."次数")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 X "..(challengeNum or 1))
	self._ccbOwner.tf_receive_num:setPositionX(15)

	refreshTime = refreshTime == nil and remote.user.c_systemRefreshTime or refreshTime
	self._ccbOwner.tf_tips:setString("每日可购买"..content.."次数在凌晨"..refreshTime.."点刷新")

    local unlockInfo = app.unlock:getConfigByKey(unlockType)
	self:setIconPath(unlockInfo.icon)
end

function QUIDialogBuyCount:setMockBattleInfo()
	self:getView():setVisible(true)
	self._ccbOwner.node_huodong:setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买一次模拟战挑战次数")
	self._ccbOwner.tf_buy:setString("(本赛季可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 X 1")
	self._ccbOwner.tf_receive_num:setPositionX(15)
	self._ccbOwner.tf_tips:setString("购买次数在赛季开始时刷新")

    -- if not remote.activity:checkMonthCardActive(2) then
    --     self._ccbOwner.node_month_card:setVisible(true)
    --     self._ccbOwner.node_all:setPositionX(140)
    -- end
	local unlockInfo = app.unlock:getConfigByKey("UNLOCK_MOCK_BATTLE")
	if remote.mockbattle:getMockBattleSeasonTypeIsDouble() then
		unlockInfo = app.unlock:getConfigByKey("UNLOCK_MOCK_BATTLE2")
	end
	self:setIconPath(unlockInfo.icon)
end

function QUIDialogBuyCount:setIconPath(path)
	if path == nil then return end
    local icon = CCSprite:create()
    icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
    self._ccbOwner.node_icon:addChild(icon)
    self._ccbOwner.node_icon:setScale(0.82)
end

function QUIDialogBuyCount:animationBuySucc()
	self:refreshInfo()
	local animationFun = function ()
		local effectPlayer = QUIWidgetAnimationPlayer.new()
	    local startP = self._ccbOwner.node_money:convertToWorldSpaceAR(ccp(0,0))
	    startP = self:getView():convertToNodeSpaceAR(startP)
		effectPlayer:setPosition(startP.x, startP.y)
		self:getView():addChild(effectPlayer)
		effectPlayer:playAnimation("ccb/Widget_TiliBuy.ccbi",function(ccbOwner)
			end,function(name)
			local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
			local endP = ccp(0,0)
			local moveSp = display.newSprite(remote.items:getURLForItem(self._typeName, "alphaIcon"))
			if self._typeName == ITEM_TYPE.MONEY then
				-- endP = page._topRegion[1]._ccbOwner.sprite_gold:convertToWorldSpaceAR(ccp(0,0))
				endP = page.topBar:getBarForType(ITEM_TYPE.MONEY):getIcon():convertToWorldSpaceAR(ccp(0,0))
			else
				-- endP = page._topRegion[3]._ccbOwner.sprite_gold:convertToWorldSpaceAR(ccp(0,0))
				endP = page.topBar:getBarForType(ITEM_TYPE.ENERGY):getIcon():convertToWorldSpaceAR(ccp(0,0))
			end
			moveSp:setScale(0.5)
			moveSp:setPosition(startP.x, startP.y)
			self:getView():addChild(moveSp)
			endP = self:getView():convertToNodeSpaceAR(endP)
			local arr = CCArray:create()
			arr:addObject(CCMoveTo:create(0.2, endP))
			arr:addObject(CCCallFunc:create(function()
					self:getView():removeChild(moveSp)
					local effectPlayer = QUIWidgetAnimationPlayer.new()
					effectPlayer:setPosition(endP.x, endP.y)
					self:getView():addChild(effectPlayer)
					effectPlayer:playAnimation("ccb/Widget_TiliBuy.ccbi",function(ccbOwner)
						end,function ()
							if self._typeName == ITEM_TYPE.ENERGY then
								self._energyCount = self._energyCount - 1
								if self._energyCount == 0 then
									self:_onTriggerClose()
								end
							end
						end)
				end))
			local seq = CCSequence:create(arr)
			moveSp:runAction(seq)
		end)
	end	
	if self._animationCount == nil or self._animationCount == 0 then
		self._animationCount = 1
	else
		self._animationCount = self._animationCount + 1
	end

	if self._delayFun == nil then
		self._delayFun = function ()
			self._animationCount = self._animationCount - 1
			if self._animationCount > 0 then
				animationFun()
				self._delayHandler = scheduler.performWithDelayGlobal(self._delayFun, 0.15)
			end
		end
	end

	if self._animationCount == 1 then
		animationFun()
		self._delayHandler = scheduler.performWithDelayGlobal(self._delayFun, 0.15)
	end
end

--TODO: check the maximum continuous money consume @qinyuanji
function QUIDialogBuyCount:buyAgain()
	local token_cost = nil
	local receive = 0
	local count = self._buyCount
	local count2 = 0
	local teamExpLvlConfig = QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(remote.user.level)
	while true do
		count = count + 1
		local config = QStaticDatabase:sharedDatabase():getTokenConsume(ITEM_TYPE.MONEY, count)
		if config ~= nil then
			if (token_cost == nil or token_cost == config.money_num) and count2 < self._num then
				if token_cost == nil then token_cost = config.money_num end
				if receive == nil then 
					receive = config.return_count * teamExpLvlConfig.token_to_money
				end
				count2 = count2 + 1
			else
				break
			end
		else
			break
		end
	end
	local token = token_cost * count2
	if token > remote.user.token then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
		return 
	else
		for i=1,count2,1 do
			self:buyMoney()
		end
	end
end

function QUIDialogBuyCount:_onTriggerClose()
  	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogBuyCount:_onTriggerBuy(event)
	if q.buttonEventShadow(event, self._ccbOwner.buy) == false then return end
  	app.sound:playSound("common_confirm")
  	if self._buyType ~= 0 then return end
  	if self._num <= 0 then
  		self._needVipAlert = true
  	end

  	if self._needVipAlert then
  		self:_showVipAlert()
  		return
  	end
  	if self._needNum > remote.user.token then
    	app:vipAlert({textType = VIPALERT_TYPE.NO_TOKEN}, false)
    	return
  	end

	if self._typeName == QUIDialogBuyCount.BUY_TYPE_1 then
		self._buyType = 1
		app:getClient():dungeonBuyCountRequest(1, function ()
			self._buyType = 0
			remote.user:update({todaydungeonSeaBuyLastTime = q.serverTime()})
			self._bought = true
			self:playEffectOut()
		end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_2 then
		self._buyType = 2
		app:getClient():dungeonBuyCountRequest(2, function ()
			self._buyType = 0
			remote.user:update({todaydungeonBarBuyLastTime = q.serverTime()})
			self._bought = true
			self:playEffectOut()
		end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_3 then
		self._buyType = 3
		app:getClient():dungeonBuyCountRequest(3, function ()
			self._buyType = 0
			remote.user:update({todaydungeonStrengthBuyLastTime = q.serverTime()})
			self._bought = true
			self:playEffectOut()
		end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_4 then
		self._buyType = 4
		app:getClient():dungeonBuyCountRequest(4, function ()
			self._buyType = 0
			remote.user:update({todaydungeonIntellectBuyLastTime = q.serverTime()})
			self._bought = true
			self:playEffectOut()
		end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_5 then
		self._buyType = 5
        remote.invasion:buyInvasionTokenRequest(function ()
			self._buyType = 0
			self._bought = true
            remote.user:addPropNumForKey("c_buyInvasionCount")
            remote.activity:updateLocalDataByType(539, 1)
            self:refreshInfo()
        end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_6 then
		self._buyType = 6
        app:getClient():buyDungeonTicket(self._dungeonId, function ()
			self._buyType = 0
			self._bought = true
			self:playEffectOut()
        end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_7 then
		self._buyType = 7
        remote.thunder:thunderBuyEliteRequest(function ()
			self._buyType = 0
			self._bought = true
			if self._callBack then
				self._callBack()
			end
            self:refreshInfo()
        end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_8 then
		self._buyType = 8
        remote.arena:requestBuyFighterCount(function ()
			self._buyType = 0
			self._bought = true
			self:playEffectOut()
        end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_9 then
		self._buyType = 9
       	remote.tower:towerBuyFightCountRequest(function ()
			self._buyType = 0
			self._bought = true
			-- if self._callBack then
			-- 	self._callBack()
			-- end
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogBuyCount.RFRESHE_GLORY_TOWER_FIGHT_NUM})
            self:refreshInfo()
        end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_10 then
		self._buyType = 10
       	remote.tower:requestGloryArenaBuyFightTimes(function ()
			self._buyType = 0
			self._bought = true
            self:refreshInfo()
            remote.tower:updateGloryArenaBuyCount()
            self:playEffectOut()
        end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_11 then
		self._buyType = 11
		
       	remote.stormArena:requestStormArenaBuyFightTimes(function ()
			self._buyType = 0
			self._bought = true
            self:refreshInfo()
            remote.stormArena:updateStormArenaBuyCount()
            self:playEffectOut()
        end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_12 then
		self._buyType = 12
		
       	remote.worldBoss:requestBuyWorldBossFightCount(function ()
			self._buyType = 0
			self._bought = true
			if self._callBack then
				self._callBack()
			end
            self:refreshInfo()
        end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_13 then
		self._buyType = 13
		
       	remote.blackrock:blackRockBuyAwardCountRequest(function ()
			self._buyType = 0
			self._bought = true
            self:refreshInfo()
			self:playEffectOut()
        end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_14 then
		self._buyType = 14
		
       	remote.maritime:requestBuyMaritimeShipNum(function ()
			self._buyType = 0
			self._bought = true
            self:refreshInfo()
			-- if self._callBack then
			-- 	self._callBack()
			-- end
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogBuyCount.RFRESHE_MARITIME_TRANSPORT_NUM})
			self:playEffectOut()
        end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_15 then
		self._buyType = 15
		
       	remote.maritime:requestBuyRobberyNum(function ()
			self._buyType = 0
			self._bought = true
			-- if self._callBack then
			-- 	self._callBack()
			-- end
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogBuyCount.RFRESHE_MARITIME_ROBBERY_NUM})
            self:playEffectOut()
        end,function ()
			self._buyType = 0
		end)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_16 then
		self._buyType = 16
       	remote.mockbattle:mockBattleBuyFightCountRequest(function ()
			self._buyType = 0
			self._bought = true
            self:refreshInfo()
            self:playEffectOut()
        end,function ()
			self._buyType = 0
		end)
	end
end

function QUIDialogBuyCount:_onTriggerVIP(event)
	if q.buttonEventShadow(event, self._ccbOwner.button_vipinfo) == false then return end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVip", options = {vipContentLevel = QVIPUtil:VIPLevel()}})
end

function QUIDialogBuyCount:_onTriggerBuyPrime(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy_2) == false then return end
	self:viewAnimationOutHandler()
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel",
        options = {themeId = 1, curActivityID = "a_yueka"}}, {isPopCurrentDialog = true})
end

function QUIDialogBuyCount:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogBuyCount:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogBuyCount:_showVipAlert()
	if QVIPUtil:isVIPMaxLevel() then
		app.tip:floatTip("魂师大人大人，当前次数已用完。")
        return
	end

	local level = QVIPUtil:VIPLevel() + 1
	local count = 0
	local text = ""

	if self._typeName == QUIDialogBuyCount.BUY_TYPE_1 then
		app:vipAlert({title = "金魂币海湾购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.BAR_MAX_COUNT}, false)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_2 then
		app:vipAlert({title = "经验酒吧购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.SEA_MAX_COUNT}, false)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_3 then
		app:vipAlert({title = "力量试炼购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.STENGTH_MAX_COUNT}, false)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_4 then
		app:vipAlert({title = "智慧试炼购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.INTELLECT_MAX_COUNT}, false)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_5 then
		app:vipAlert({title = "要塞入侵购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.INVASION_TOKEN_BUY_COUNT}, false)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_9 then
		app:vipAlert({title = "大魂师赛购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.TOWER_BUY_COUNT}, true)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_14 then
		app:vipAlert({title = "海商运送次数购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.MARITIME_BUY_TRANSPORT_COUNT}, true)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_15 then
		app:vipAlert({title = "海商掠夺次数购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.MARITIME_BUY_LOOTCOUNT}, true)
	elseif self._typeName == QUIDialogBuyCount.BUY_TYPE_7 then
		app.tip:floatTip("今日购买次数已达上限")
	end
end

return QUIDialogBuyCount