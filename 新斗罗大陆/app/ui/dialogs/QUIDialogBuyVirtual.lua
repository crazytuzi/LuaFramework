--
-- Author: Your Name
-- Date: 2014-07-24 10:58:34
--
local QUIDialog = import(".QUIDialog")
local QUIDialogBuyVirtual = class("QUIDialogBuyVirtual", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBuyVirtualLog = import("..widgets.QUIWidgetBuyVirtualLog")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QVIPUtil = import("...utils.QVIPUtil")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogBuyVirtual:ctor(options)
	local ccbFile = "ccb/Dialog_Buy.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, QUIDialogBuyVirtual._onTriggerBuy)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogBuyVirtual._onTriggerClose)},
		{ccbCallbackName = "onTriggerBuyAgain", callback = handler(self, QUIDialogBuyVirtual._onTriggerBuyAgain)},
		{ccbCallbackName = "onTriggerVIP", callback = handler(self, QUIDialogBuyVirtual._onTriggerVIP)},
	}
	QUIDialogBuyVirtual.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true --是否动画显示

	self._typeName = options.typeName
	if options.enough == nil then
		self._enough = true
	else
		self._enough = options.enough
	end
	self._ccbOwner.tf_1:setString("")
	self._ccbOwner.tf_2:setString("")
	self._ccbOwner.tf_buy:setString("")
	self._ccbOwner.tf_need_num:setString("")
	self._ccbOwner.tf_receive_num:setString("")
	self._ccbOwner.tf_tips:setString("")
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
	self._ccbOwner.node_society_dungeon:setVisible(false)
	self._ccbOwner.node_invasion:setVisible(false)
	self._ccbOwner.node_goldPickaxe:setVisible(false)
	self._ccbOwner.node_bar:setVisible(true)
    self._ccbOwner.node_month_card:setVisible(false)
    self._ccbOwner.node_energyicon:setVisible(false)

    self._ccbOwner.frame_tf_title:setString("购 买")

	self._ccbOwner.tf_tips:setString("每日可购买金魂币次数在凌晨4点刷新")
	self._ccbOwner.tf_time_title:setString("")
	self._ccbOwner.tf_time:setString("")

	self:refreshInfo()
	self._isAnimation = false
	self._energyCount = 0
end

function QUIDialogBuyVirtual:viewWillDisappear()
    QUIDialogBuyVirtual.super.viewWillDisappear(self)
    if self._delayHandler ~= nil then
		scheduler.unscheduleGlobal(self._delayHandler)	
	end

	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end

	if self._goldPickaxeScheduler then
		scheduler.unscheduleGlobal(self._goldPickaxeScheduler)
		self._goldPickaxeScheduler = nil
	end

	remote.silverMine:setIsWaitShowChangeAni(false)
end

function QUIDialogBuyVirtual:refreshInfo()
	self._totalNum = 0
	self._num = 0
	local config = QStaticDatabase:sharedDatabase():getTokenConsumeByType(self._typeName)
	self._buyCount = 0

	-- print("###", self._typeName)

	if config ~= nil then
		self._totalNum = QVIPUtil:getBuyVirtualCount(self._typeName)
		if self._typeName == ITEM_TYPE.MONEY then
			self._ccbOwner.btn_buyAgain:setVisible(true)
			self._ccbOwner.btn_buy:setVisible(true)
			if remote.user.todayMoneyBuyLastTime ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > remote.user.todayMoneyBuyLastTime then
				self._buyCount = 0
			else
				self._buyCount = remote.user.todayMoneyBuyCount or 0
			end
		elseif self._typeName == ITEM_TYPE.ENERGY then
			self._ccbOwner.btn_buy:setVisible(true)
			self._ccbOwner.btn_buy:setPositionX(0)
			if remote.user.todayEnergyBuyLastTime ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > remote.user.todayEnergyBuyLastTime then
				self._buyCount = 0
			else
				self._buyCount = remote.user.todayEnergyBuyCount or 0
			end
		elseif self._typeName == ITEM_TYPE.SUNWAR_REVIVE_COUNT then
			self._ccbOwner.btn_buy:setVisible(true)
			self._ccbOwner.btn_buy:setPositionX(0)
			-- if remote.user.todayEnergyBuyLastTime ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > remote.user.todayEnergyBuyLastTime then
			-- 	self._buyCount = 0
			-- else
				self._buyCount = remote.sunWar:getHeroReviveBuyCnt() or 0
			-- end
		elseif self._typeName == ITEM_TYPE.SOCIATY_CHAPTER_TIMES then
			-- 和时间有关的数据
			self:_updateTime()
			self._scheduler = scheduler.scheduleGlobal(function ()
				self:_updateTime()
			end, 1)

			self._ccbOwner.btn_buy:setVisible(true)
			self._ccbOwner.btn_buy:setPositionX(0)

			local userConsortia = remote.user:getPropForKey("userConsortia")

			if userConsortia.consortia_boss_buy_at ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > userConsortia.consortia_boss_buy_at then
				self._buyCount = 0
			else
				self._buyCount = userConsortia.consortia_boss_buy_count or 0
			end
		elseif self._typeName == ITEM_TYPE.SILVERMINE_LIMIT then
			self._ccbOwner.btn_buy:setVisible(true)
			self._ccbOwner.btn_buy:setPositionX(0)
			self._buyCount = remote.silverMine:getBuyFightCount()
		elseif self._typeName == ITEM_TYPE.GOLDPICKAXE_TIMES then
			-- remote.silverMine:setIsNeedShowGoldPickaxeRedTips(false)
			remote.silverMine:setIsWaitShowChangeAni(false)
			self._ccbOwner.btn_buy:setVisible(true)
			self._ccbOwner.btn_buy:setPositionX(0)
			self._buyCount = remote.silverMine:getMiningPickBuyCount()
			self._isCanBuyGoldPickaxeTime = true
		elseif self._typeName == ITEM_TYPE.PLUNDER_TIMES then
			self._ccbOwner.btn_buy:setVisible(true)
			self._ccbOwner.btn_buy:setPositionX(0)
			self._buyCount = remote.plunder:getBuyLootCnt()
		elseif self._typeName == ITEM_TYPE.MAZE_EXPLORE_ENERGY then
			self._ccbOwner.btn_buy:setVisible(true)
			self._ccbOwner.btn_buy:setPositionX(0)		
			local mazeExploreDataHandle = remote.activityRounds:getMazeExplore()
			self._totalNum = mazeExploreDataHandle:getTotalBuyNum()
			self._buyCount = mazeExploreDataHandle:getFinshBuyNum()
		end
		self._num = self._totalNum - self._buyCount
	end
	
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount + 1)
	self._needNum = config.money_num
	self._reveiveNum = config.return_count

	if self._typeName == ITEM_TYPE.MONEY then
		local teamExpLvlConfig = QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(remote.user.level)
		if teamExpLvlConfig ~= nil and self._reveiveNum ~= nil then
			self._reveiveNum = self._reveiveNum * teamExpLvlConfig.token_to_money
		end
		self:setMoneyInfo()
	elseif self._typeName == ITEM_TYPE.ENERGY then
		self:setEnergyInfo()
	elseif self._typeName == ITEM_TYPE.SUNWAR_REVIVE_COUNT then
		self:setSunwarInfo()
	elseif self._typeName == ITEM_TYPE.SOCIATY_CHAPTER_TIMES then
		self:setSocietyDungeonInfo()
	elseif self._typeName == ITEM_TYPE.SILVERMINE_LIMIT then
		self:setSilverMineInfo()
	elseif self._typeName == ITEM_TYPE.GOLDPICKAXE_TIMES then
		self:setSilverMineGoldPickaxeInfo()
	elseif self._typeName == ITEM_TYPE.PLUNDER_TIMES then
		self:setPlunderInfo()
	elseif self._typeName == ITEM_TYPE.MAZE_EXPLORE_ENERGY then
		self:setMazeExploreInfo()
	end

	if self._num <= 0 then
		-- self:showVIPButton()
		self._needVipAlert = true
	end
end

-- function QUIDialogBuyVirtual:showVIPButton()
-- 	self._ccbOwner.btn_buy:setVisible(false)
-- 	self._ccbOwner.btn_buyAgain:setVisible(false)
-- 	self._ccbOwner.btn_VIP_Info:setVisible(true)
-- end

function QUIDialogBuyVirtual:setMoneyInfo()
	self:getView():setVisible(true)
	self._ccbOwner.icon_money:setVisible(true)
	self._ccbOwner.node_bar:setVisible(false)
	-- self._ccbOwner.node_money:setVisible(true)
	if self._icon ~= nil then
		self._icon:removeFromParent()
		self._icon = nil
	end
	self._icon = QUIWidgetItemsBox.new()
	self._icon:setGoodsInfo(nil, ITEM_TYPE.MONEY, 0)
	self._ccbOwner.node_money:getParent():addChild(self._icon)

	self._ccbOwner.tf_1:setString("金魂币购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买大量金魂币")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString(math.floor(self._reveiveNum))
	self._ccbOwner.tf_tips:setString("每日可购买金魂币次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新")
	local wallet = remote.items:getWalletByType("money")
	if wallet then
		self:setColor(EQUIPMENT_QUALITY[wallet.colour])
	end
end

function QUIDialogBuyVirtual:tipsMoneyInfo()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	local content = ""
	if self._enough == false then
		content = "金魂币不足，今日购买金魂币次数已达上限，提升VIP等级获取更多购买次数！"
	else
		content = "今日购买金魂币次数已达上限！"
	end
	app:alert({content=content,title="系统提示"})
end

function QUIDialogBuyVirtual:setEnergyInfo()
	self:getView():setVisible(true)
	self._ccbOwner.icon_energy:setVisible(true)
	self._ccbOwner.node_bar:setVisible(false)
	-- self._ccbOwner.node_energy:setVisible(true)
	if self._icon ~= nil then
		self._icon:removeFromParent()
		self._icon = nil
	end
	self._icon = QUIWidgetItemsBox.new()
	self._icon:setGoodsInfo(nil, ITEM_TYPE.ENERGY, 0)
	self._ccbOwner.node_energy:getParent():addChild(self._icon)

	self._ccbOwner.tf_1:setString("体力购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买大量体力")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString(math.floor(self._reveiveNum))
	self._ccbOwner.tf_tips:setString("每日可购买体力次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新")
	local wallet = remote.items:getWalletByType("money")
	if wallet then
		self:setColor(EQUIPMENT_QUALITY[wallet.colour])
	end
end

function QUIDialogBuyVirtual:setSunwarInfo()
	self:getView():setVisible(true)
	self._ccbOwner.node_sunwar:setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 x 1")
	self._ccbOwner.tf_receive_num:setPositionX(37)
	self._ccbOwner.tf_tips:setString("每日可购买复活次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新")
end

function QUIDialogBuyVirtual:setSocietyDungeonInfo()
	self:getView():setVisible(true)
	self._ccbOwner.node_society_dungeon:setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 x 1")
	self._ccbOwner.tf_receive_num:setPositionX(37)
	self._ccbOwner.tf_tips:setString("每日可购买宗门副本次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新")
end

function QUIDialogBuyVirtual:setSilverMineInfo()
	self:getView():setVisible(true)
	self._ccbOwner.node_silvermine:setVisible(true)
	self._ccbOwner.tf_1:setString("次数购买")
	self._ccbOwner.tf_2:setString("用少量钻石购买狩猎次数")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 x 1")
	self._ccbOwner.tf_receive_num:setPositionX(37)
	self._ccbOwner.tf_tips:setString("每日可购买狩猎次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新")
end

function QUIDialogBuyVirtual:setSilverMineGoldPickaxeInfo()
	self:getView():setVisible(true)
	self._ccbOwner.node_goldPickaxe:setVisible(true)
	self._ccbOwner.node_purple:setVisible(true)
	self._ccbOwner.tf_1:setString("诱魂草")
	self._ccbOwner.tf_2:setString("购买后可获得100%产量加成")
	self._ccbOwner.tf_buy:setString("(剩余次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_need_num:setPositionX(-89)
	self._ccbOwner.sp_token:setPositionX(-126)
	local str = QStaticDatabase.sharedDatabase():getConfigurationValue("huangjinkuanggao_time")
	self._ccbOwner.tf_receive_num:setString(str.."小时")
	self._ccbOwner.tf_receive_num:setPositionX(33)
	self._ccbOwner.sp_jiantou:setPositionX(-18)
	self._ccbOwner.tf_tips:setString("")
	self._ccbOwner.tf_time_title:setString("当前剩余时间：")
	if self._goldPickaxeScheduler then
		scheduler.unscheduleGlobal(self._goldPickaxeScheduler)
		self._goldPickaxeScheduler = nil
	end
	self:_updateGoldPickaxeTime()
	self._goldPickaxeScheduler = scheduler.scheduleGlobal(self:safeHandler(function() 
			self:_updateGoldPickaxeTime()
		end), 1)
end

function QUIDialogBuyVirtual:setPlunderInfo()
	self:getView():setVisible(true)
	self._ccbOwner.node_plunder:setVisible(true)
	self._ccbOwner.node_purple:setVisible(true)
	self._ccbOwner.tf_1:setString("掠夺次数")
	self._ccbOwner.tf_2:setString("购买后可增加一次掠夺次数")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString("次数 x 1")
	self._ccbOwner.tf_receive_num:setPositionX(37)
	self._ccbOwner.tf_tips:setString("每日可购买狩猎次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新")
end

function QUIDialogBuyVirtual:setMazeExploreInfo( )
	self:getView():setVisible(true)
	self._ccbOwner.node_energyicon:setVisible(true)
	self._ccbOwner.node_orange:setVisible(true)
	self._ccbOwner.icon_energy:setVisible(true)
	local resureConfig = remote.items:getWalletByType(ITEM_TYPE.MAZE_EXPLORE_ENERGY)
	if resureConfig then
		QSetDisplayFrameByPath(self._ccbOwner.icon_energy,resureConfig.alphaIcon)
		QSetDisplayFrameByPath(self._ccbOwner.node_energyicon,resureConfig.icon)
	end
	self._ccbOwner.tf_1:setString("精神力购买")
	self._ccbOwner.tf_2:setString("购买后可增加精神力")
	self._ccbOwner.tf_buy:setString("(今日可购买次数"..self._num.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	self._ccbOwner.tf_receive_num:setString(math.floor(self._reveiveNum))
	local point = db:getConfigurationValue("daily_power_recover") or 200
	self._ccbOwner.tf_tips:setString("每日0点将回复精神力"..point.."点，增加购买次数1次")
	self._ccbOwner.tf_tips:setFontSize(20)
end

function QUIDialogBuyVirtual:tipsEnergyInfo()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	local content = ""
	if self._enough == false then
		content = "体力不足，今日购买体力次数已达上限，提升VIP等级获取更多购买次数！"
	else
		content = "今日购买体力次数已达上限！"
	end
	app:alert({content=content,title="系统提示"})
end

function QUIDialogBuyVirtual:animationBuySucc()
	if not self:safeCheck() then
		return
	end

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
			local isShow = false
			local bar = page.topBar:getBarForType(self._typeName)
			if bar ~= nil and bar:isVisible() == true then
				endP = bar:getIcon():convertToWorldSpaceAR(ccp(0,0))
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
									-- if self._energyCount == 0 then
									-- 	self:_onTriggerClose()
									-- end
								end
							end)
					end))
				local seq = CCSequence:create(arr)
				moveSp:runAction(seq)
			end
		end)
	end	
	if self._animationCount == nil or self._animationCount == 0 then
		self._animationCount = 1
	elseif self._animationCount < 3 then
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
function QUIDialogBuyVirtual:buyAgain()
	local token_cost = nil
	local receive = 0
	local count = self._buyCount
	local count2 = 0
	local teamExpLvlConfig = QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(remote.user.level)
	while true do
		if count2 >= 5 then break end
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
		self:buyMoney(count2)
	end
end


--添加购买记录
function QUIDialogBuyVirtual:addLog(cost, receive, crit)
	if self.log == nil then
		self.log = QUIWidgetBuyVirtualLog.new()
		self._ccbOwner.node_log:addChild(self.log)
		local posX = self:getChildView():getPositionX()
		local posY = self:getChildView():getPositionY() + 30
		self:getChildView():runAction(CCMoveTo:create(0.3,ccp(posX,posY)))
	end
	if self.log.addLog then
		self.log:addLog(cost, receive, crit)
	end
end

--添加购买记录
function QUIDialogBuyVirtual:buyMoney(count)
	app:getClient():buyMoney(count, function(data)
		remote.user:addPropNumForKey("addupBuyMoneyCount", count)
		remote.activity:updateLocalDataByType(504, count)
		remote.user:update({todayMoneyBuyLastTime = q.serverTime()})
		if self:safeCheck() then
			local config = QStaticDatabase:sharedDatabase():getTokenConsume(ITEM_TYPE.MONEY, data.dailyTask.todayMoneyBuyCount)
			local teamExpLvlConfig = QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(remote.user.level)
			if data.buyMoneyResponse ~= nil and data.buyMoneyResponse.info ~= nil then
				for _,value in ipairs(data.buyMoneyResponse.info) do
					self:addLog(config.money_num, value.money or 0, value.buyMoneyYield or 0)
				end
			end
		end
		self:animationBuySucc()
    end)
end

function QUIDialogBuyVirtual:_onTriggerBuyAgain(event)
	if q.buttonEventShadow(event, self._ccbOwner.buy_again) == false then return end
  	app.sound:playSound("common_confirm")

  	if self._needVipAlert then
  		self:_showVipAlert()
  		return
  	end

  	if self._animationCount == nil or self._animationCount <= 0 then
	  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyVirtualAgain",
	      options = {typeName = ITEM_TYPE.MONEY, count = self._buyCount, remainingCount = self._num, callBack = handler(self, self.buyAgain)}},{isPopCurrentDialog = false})
	end
end

function QUIDialogBuyVirtual:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogBuyVirtual:_onTriggerBuy(event)
	if q.buttonEventShadow(event, self._ccbOwner.buy) == false then return end
  	app.sound:playSound("common_confirm")
  	if self._needVipAlert then
  		self:_showVipAlert()
  		return
  	end

	if self._typeName == ITEM_TYPE.MONEY then
		self:buyMoney(1)
	elseif self._typeName == ITEM_TYPE.ENERGY then
		if (self._reveiveNum + remote.user.energy) > 999 then
    		app.tip:floatTip("体力已达上限，请先消耗后再购买") 
    		return
		end
		app:getClient():buyEnergy(1, false, function(data)
				self._energyCount = self._energyCount + 1
				remote.user:addPropNumForKey("addupBuyEnergyCount")
				-- remote.user:addPropNumForKey("todayEnergyBuyCount")
				remote.activity:updateLocalDataByType(506,1)
				remote.user:update({todayEnergyBuyLastTime = q.serverTime()})

        		app.taskEvent:updateTaskEventProgress(app.taskEvent.BUY_ENERGY_EVENT, 1, false, false)

  				self:animationBuySucc()
			end)
	elseif self._typeName == ITEM_TYPE.SUNWAR_REVIVE_COUNT then
		app:getClient():sunwarBuyReviveCountRequest(false, function (data)
			remote.sunWar:responseHandler(data)
			self:_onTriggerClose()
		end)
	elseif self._typeName == ITEM_TYPE.SOCIATY_CHAPTER_TIMES then
		if not self._isInTime then
			app.tip:floatTip("当前时段无法购买")
			return
		end
		remote.union:unionBuyFightCountRequest(1, false, function (data)
			self._buyCount = self._buyCount + 1
			self._num = self._totalNum - self._buyCount
			if self._num <= 0 then 
				self._num = 0 
				self._needVipAlert = true
			end

			self._ccbOwner.tf_buy:setString("（今日可购买次数"..self._num.."/"..self._totalNum.."）")

			local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount + 1)
			self._needNum = config.money_num
			-- print("[Kumo] ", self._needNum, self._buyCount + 1)
			self._ccbOwner.tf_need_num:setString(self._needNum)

			remote.union:sendBuyFightCountSuccess()
			-- self:_onTriggerClose()
		end)
	elseif self._typeName == ITEM_TYPE.SILVERMINE_LIMIT then
		remote.silverMine:silvermineBuyFightCountRequest(function(data)
				self:_onTriggerClose()
			end)
	elseif self._typeName == ITEM_TYPE.GOLDPICKAXE_TIMES then
		local myOccupy = remote.silverMine:getMyOccupy()
		if myOccupy and table.nums(myOccupy) > 0 then
			if not self._isCanBuyGoldPickaxeTime then
				local limit = tonumber(QStaticDatabase.sharedDatabase():getConfigurationValue("huangjinkuanggao_time_limit")) - tonumber(QStaticDatabase.sharedDatabase():getConfigurationValue("huangjinkuanggao_time"))
				app.tip:floatTip("魂师大人，剩余时间低于"..limit.."小时后才能购买哦~")
			else
				remote.silverMine:setIsNeedShowChangeAni(true)
				remote.silverMine:setIsWaitShowChangeAni(true)
				remote.silverMine:silverMineBuyMiningPick(function(data)
					self._buyCount = self._buyCount + 1
					self._num = self._totalNum - self._buyCount
					if self._num <= 0 then 
						self._num = 0 
						self._needVipAlert = true
					end
					self._ccbOwner.tf_buy:setString("（剩余次数"..self._num.."/"..self._totalNum.."）")

					local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount + 1)
					self._needNum = config.money_num
					-- print("[Kumo] ", self._needNum, self._buyCount + 1)
					self._ccbOwner.tf_need_num:setString(self._needNum)

					app.tip:floatTip("购买成功")
				end)
			end
		else
			app.tip:floatTip("魂师大人，您当前还未狩猎魂兽区，无法购买哦~")
		end
	elseif self._typeName == ITEM_TYPE.PLUNDER_TIMES then
		remote.plunder:plunderBuyLootCntRequest(function(data)
				-- self._buyCount = self._buyCount + 1
				-- self._num = self._totalNum - self._buyCount
				-- if self._num <= 0 then 
				-- 	self._num = 0 
				-- 	self._needVipAlert = true
				-- end
				-- self._ccbOwner.tf_buy:setString("（今日可购买次数"..self._num.."/"..self._totalNum.."）")
				-- local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount + 1)
				-- self._needNum = config.money_num
				-- self._ccbOwner.tf_need_num:setString(self._needNum)
				self:_onTriggerClose()
			end)
	elseif self._typeName == ITEM_TYPE.MAZE_EXPLORE_ENERGY then
		local mazeExploreDataHandle = remote.activityRounds:getMazeExplore()
		if self._num > 0 and mazeExploreDataHandle then
			mazeExploreDataHandle:MazeExploreBuyPowerRequest(1,function()
				app.tip:floatTip("购买成功")
				self:_onTriggerClose()
			end)
		else
			app.tip:floatTip("今日达到了最大购买次数~")
		end
	end
end

function QUIDialogBuyVirtual:_onTriggerVIP(event)
	if q.buttonEventShadow(event, self._ccbOwner.button_vipinfo) == false then return end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVip", options = {vipContentLevel = QVIPUtil:VIPLevel()}})
end

function QUIDialogBuyVirtual:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogBuyVirtual:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.class.__cname == "QUIPageMainMenu" then
		page:checkGuiad()
	end
end

function QUIDialogBuyVirtual:setColor(name)
	-- print(name)
	self:hideAllColor()
	if name ~= nil then
    		self:setNodeVisible(self._ccbOwner["node_"..name],true)
	else
		self:setNodeVisible(self._ccbOwner["node_normal"],true)
	end
end

function QUIDialogBuyVirtual:hideAllColor()
	self:setNodeVisible(self._ccbOwner.node_green,false)
	self:setNodeVisible(self._ccbOwner.node_blue,false)
	self:setNodeVisible(self._ccbOwner.node_orange,false)
	self:setNodeVisible(self._ccbOwner.node_purple,false)
	self:setNodeVisible(self._ccbOwner.node_white,false)
end

function QUIDialogBuyVirtual:setNodeVisible(node,b)
	if node ~= nil then
		node:setVisible(b)
	end
end

function QUIDialogBuyVirtual:_showVipAlert()
	if self._typeName == ITEM_TYPE.MONEY then
		app:vipAlert({title = "金魂币可购买次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.BUY_VIRTUAL_MONEY_COUNT}, false)
	elseif self._typeName == ITEM_TYPE.ENERGY then
		app:vipAlert({title = "体力可购买次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.BUY_VIRTUAL_ENERGY_COUNT}, false)
	elseif self._typeName == ITEM_TYPE.SUNWAR_REVIVE_COUNT then
		app:vipAlert({title = "海神岛可复活次数购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.SUNWAR_BUY_REVIVECOUNT}, false)
	elseif self._typeName == ITEM_TYPE.SOCIATY_CHAPTER_TIMES then
		app:vipAlert({title = "宗门副本可购买攻击次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.SOCIETYDUNGEON_BUY_FIGHTCOUNT}, false)
	elseif self._typeName == ITEM_TYPE.SILVERMINE_LIMIT then
		app:vipAlert({title = "狩猎次数购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.SILVERMINE_BUY_FIGHTCOUNT}, false)
	elseif self._typeName == ITEM_TYPE.GOLDPICKAXE_TIMES then
		app:vipAlert({title = "诱魂草可购买次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.SILVERMINE_BUY_GOLDPICKAXECOUNT}, false)
	elseif self._typeName == ITEM_TYPE.PLUNDER_TIMES then
		app:vipAlert({title = "掠夺次数购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.PLUNDER_BUY_LOOTCOUNT}, false)
	elseif self._typeName == ITEM_TYPE.MAZE_EXPLORE_ENERGY then
		app.tip:floatTip("今日达到了最大购买次数~")
	end
end

function QUIDialogBuyVirtual:_updateTime()
	if (not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") then return end
	
	local curTimeTbl = q.date("*t", q.serverTime())
	local startTime = remote.union:getSocietyDungeonStartTime()
	local endTime = remote.union:getSocietyDungeonEndTime()
	if curTimeTbl.hour < startTime or curTimeTbl.hour >= endTime then
		self._isInTime = false
	else
		self._isInTime = true
	end
end

function QUIDialogBuyVirtual:_updateGoldPickaxeTime()
	local isOvertime, timeStr, _, isCanBuy = remote.silverMine:updateGoldPickaxeTime(true)
	self._isCanBuyGoldPickaxeTime = isCanBuy
	if isOvertime then
		self._ccbOwner.tf_time:setString("00:00:00")
	else
		self._ccbOwner.tf_time:setString(timeStr)
	end
end

return QUIDialogBuyVirtual