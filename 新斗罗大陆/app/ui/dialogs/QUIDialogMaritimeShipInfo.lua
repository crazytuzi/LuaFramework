-- @Author: xurui
-- @Date:   2016-12-26 12:01:05
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-11 19:31:01
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMaritimeShipInfo = class("QUIDialogMaritimeShipInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetShipBox = import("..widgets.QUIWidgetShipBox")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QMaritimeArrangement = import("...arrangement.QMaritimeArrangement")

local AWARDS_POS2 = {ccp(-83, -90), ccp(67, -90)}
local AWARDS_POS3 = {ccp(-183, -90),ccp(0, -90), ccp(167, -90)}
local AWARDS_POS4 = {ccp(-213, -90), ccp(-83, -90), ccp(67, -90), ccp(197, -90)}
function QUIDialogMaritimeShipInfo:ctor(options)
	local ccbFile = "ccb/Dialog_Haishang1.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
		{ccbCallbackName = "onTriggerRobbery", callback = handler(self, self._onTriggerRobbery)},
		{ccbCallbackName = "onTriggerTeam", callback = handler(self, self._onTriggerTeam)},
	}
	QUIDialogMaritimeShipInfo.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._shipInfo = options.shipInfo
		self._callBack = options.callBack
		self._quickCallBack = options.quickCallBack
	end
	self._timeIsDone = false
	self._canRobberyNum = 0

	q.setButtonEnableShadow(self._ccbOwner.btn_info)
	q.setButtonEnableShadow(self._ccbOwner.btn_robbery)

	self._database = QStaticDatabase:sharedDatabase()
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	self._rebberyTimes = configuration["maritime_be_plunder"].value
	self._rebberyItem = configuration["maritime_proportion"].value
	self._speedPrice = configuration["maritime_speed"].value
	self._speedTime = configuration["maritime_speed_time"].value
	self._robberyNum = configuration["maritime_plunder"].value

	self:resetAll()
end

function QUIDialogMaritimeShipInfo:resetAll()
	self._ccbOwner.frame_tf_title:setString("")
	self._ccbOwner.tf_transporter_level:setString("")
	self._ccbOwner.tf_transporter_name:setString("")
	self._ccbOwner.tf_protecter_level:setString("")
	self._ccbOwner.tf_protecter_name:setString("")
	self._ccbOwner.tf_last_time:setString("")
	self._ccbOwner.tf_robbery_num:setString("")
	self._ccbOwner.tf_last_time:setString("")
	self._ccbOwner.node_my_info:setVisible(false)
	self._ccbOwner.tf_no_rewards:setVisible(false)

	self._ccbOwner.tf_quicken_title:setString("使用加速可以减少仙品的运送时间（每次"..self._speedTime.."分钟）")
	self._ccbOwner.tf_token_price:setString(self._speedPrice)
end

function QUIDialogMaritimeShipInfo:viewDidAppear()
	QUIDialogMaritimeShipInfo.super.viewDidAppear(self)

	self:setShipInfo()
end

function QUIDialogMaritimeShipInfo:viewWillDisappear()
	QUIDialogMaritimeShipInfo.super.viewWillDisappear(self)

	if self._lastTimeScheduler then
		scheduler.unscheduleGlobal(self._lastTimeScheduler)
		self._lastTimeScheduler = nil
	end
end

function QUIDialogMaritimeShipInfo:setShipInfo()
	local ships = remote.maritime:getMaritimeShipInfoByShipId(self._shipInfo.shipId)
	self._shipInfo = remote.maritime:getShipInfoByUserId(self._shipInfo.userId)

	self._ccbOwner.frame_tf_title:setString(ships.ship_name or "")
	local color = ships.ship_colour or 2
	local fontColor = EQUIPMENT_COLOR[color]
	self._ccbOwner.frame_tf_title:setColor(fontColor)
	self._ccbOwner.frame_tf_title = setShadowByFontColor(self._ccbOwner.frame_tf_title,fontColor)

	if self._shipBox == nil then
		self._shipBox = QUIWidgetShipBox.new({isBig = true})
		self._ccbOwner.node_ship:addChild(self._shipBox)
		self._shipBox:setScale(0.8)
	end
	self._shipBox:setShipInfo(self._shipInfo, i)
	self._shipBox:setSelectState(false)

	self._ccbOwner.tf_transporter_level:setString("LV."..(self._shipInfo.teamLevel or ""))
	self._ccbOwner.tf_transporter_name:setString(self._shipInfo.nickname or "")
	if self._shipInfo.escortNickname == nil then
		self._ccbOwner.tf_protecter_level:setString("无")
		self._ccbOwner.tf_protecter_name:setString("")
		self._userId = self._shipInfo.userId
	else
		self._ccbOwner.tf_protecter_level:setString("LV."..self._shipInfo.escortTeamLevel or "")
		self._ccbOwner.tf_protecter_name:setString(self._shipInfo.escortNickname or "")
		self._userId = self._shipInfo.escortUserId
	end

	local force = self._shipInfo.defenseForce or 0
	local num, word = q.convertLargerNumber(force)
	self._ccbOwner.tf_battle_force:setString(num..word)
	
	self._ccbOwner.tf_no_rewards:setVisible(false)

	local robberyNum = self._shipInfo.lootedCnt or 0
	if self._shipInfo.isMy then
		self._ccbOwner.tf_reward_title:setString("运送奖励")
		self._ccbOwner.tf_robbery_title:setString("已被掠夺：") 
		self._ccbOwner.bf_btn_robbery:setString("加 速")
	else
		self._ccbOwner.tf_reward_title:setString("掠夺奖励")
		self._ccbOwner.tf_robbery_title:setString("可被掠夺：")
		self._canRobberyNum = (self._rebberyTimes - robberyNum)
		robberyNum = self._canRobberyNum.."/"..self._rebberyTimes
		self._ccbOwner.bf_btn_robbery:setString("立即掠夺")
	end
	self._ccbOwner.node_my_info:setVisible(self._shipInfo.isMy)
	self._ccbOwner.tf_robbery_num:setString(robberyNum or "")

	self._ccbOwner.node_lost_award:setVisible(false)
	if robberyNum ~= 0 and self._shipInfo.isMy == true then
		self._ccbOwner.node_lost_award:setVisible(true)
	end
	if self._shipInfo.isMy ~= true and self._canRobberyNum == 0 then
		makeNodeFromNormalToGray(self._ccbOwner.node_btn_robbery)
		self._ccbOwner.tf_no_rewards:setVisible(true)
	else
		self:setRewards()
	end

	self:setLastTimeScheduler((self._shipInfo.endAt or 0)/1000)
end

function QUIDialogMaritimeShipInfo:setLastTimeScheduler(endTime)
	if self._lastTimeScheduler then
		scheduler.unscheduleGlobal(self._lastTimeScheduler)
		self._lastTimeScheduler = nil
	end

	if endTime - q.serverTime() > 0 then
		local date = q.timeToHourMinuteSecond(endTime - q.serverTime())
		self._ccbOwner.tf_last_time:setString(date or "")
		self._lastTimeScheduler = scheduler.performWithDelayGlobal(function ()
			self:setLastTimeScheduler(endTime)
		end, 1)
	else
		self:_onTriggerClose({isForce = true})
	end
end

function QUIDialogMaritimeShipInfo:setRewards()
	local shipAwards = string.split(self._shipInfo.rewards, ";")
	if #shipAwards > 4 then return end
	local robberyNum = self._shipInfo.lootedCnt or 0
	local lostNum = 0
	local lostId = nil
	local posTable = {ccp(0,-90)}
	if #shipAwards == 2 then
		posTable = AWARDS_POS2
	elseif #shipAwards == 3 then
		posTable = AWARDS_POS3
	elseif #shipAwards == 4 then
		posTable = AWARDS_POS4
	end
	for i = 1, #shipAwards do
		if shipAwards[i] and shipAwards[i] ~= "" then
			local award = string.split(shipAwards[i], "^")
			local id = tonumber(award[1])
			local num = tonumber(award[2])
			if id ~= nil or self._shipInfo.isMy then
				local itemBox = QUIWidgetItemsBox.new()
				self._ccbOwner["node_item_"..i]:addChild(itemBox)
				self._ccbOwner["node_item_"..i]:setPosition(posTable[i])
				local itemType = ITEM_TYPE.ITEM
				if id == nil then
					itemType = award[1]
				end
				local count = math.ceil( num * self._rebberyItem )
				lostNum = count * robberyNum
				lostId = id

				if self._shipInfo.isMy then 
					count = num - (count * robberyNum)
					if id ~= nil then
						count = num
					end
				end
				itemBox:setGoodsInfo(id, itemType, count)
				itemBox:setPromptIsOpen(true)
			end
		end
	end
	self._ccbOwner.tf_lost_award:setString(lostNum.."）")
	if self._lostItemIcon == nil and lostId then
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(lostId)
		if itemConfig and itemConfig.icon_1 ~= nil then
			self._lostItemIcon = CCSprite:create(itemConfig.icon_1)
			self._lostItemIcon:setScale(0.5)
			self._lostItemIcon:setPosition(ccp(2, 2))
			self._ccbOwner.node_lost_item:addChild(self._lostItemIcon)
		end
	end
end

function QUIDialogMaritimeShipInfo:_onTriggerInfo()
	app.sound:playSound("common_small")

	remote.maritime:requestQueryMaritimeShipInfo(self._userId, function(data)
		local fighterInfo = (data.maritimeQueryFighterResponse.fighter or {})
  		local count  = 0

		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
    		options = {fighterInfo = fighterInfo, isPVP = true}}, {isPopCurrentDialog = false})
	end)
	
  
end

function QUIDialogMaritimeShipInfo:_onTriggerRobbery()
	app.sound:playSound("common_small")

	if self._shipInfo.isMy then
		local quickCallBack = self._quickCallBack
		remote.maritime:requestMaritimeShipQuick(function (data)
			if self:safeCheck() then
				self._shipInfo = data.maritimeShipQuickResponse.myShipInfo
				self._shipInfo.isMy = true
				self:setShipInfo()
			end
			if quickCallBack then
				quickCallBack()
			end
		end)
	else
		if self._shipInfo.consortiaId and remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" and 
		   remote.user.userConsortia.consortiaId == self._shipInfo.consortiaId then
			app.tip:floatTip("魂师大人，您不能掠夺同宗门成员哦~")
			return 
		end
		if self._canRobberyNum <= 0 then
			app.tip:floatTip("魂师大人，该仙品被掠夺已超过了最大次数~")
			return 
		end
		if self._shipInfo.escortUserId == remote.user.userId then
			app.tip:floatTip("魂师大人，您不能掠夺自己保护的仙品~")
			return 
		end

		local lootUserIds = string.split(self._shipInfo.lootUserIds, ";")
		for _, useId in pairs(lootUserIds) do
			if useId == remote.user.userId then
				app.tip:floatTip("魂师大人，您已掠夺过此仙品，不能重复掠夺哦~")
				return 
			end
		end

		local myInfo = remote.maritime:getMyMaritimeInfo()
		local robberyNum = self._robberyNum + (myInfo.buyLootCnt or 0) - (myInfo.lootCnt or 0)
		if robberyNum <= 0 then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", 
				options = {cls = "QBuyCountMaritimeRobbery"}}, {isPopCurrentDialog = false})
			return 
		end
		if self._timeIsDone then 
			app.tip:floatTip("魂师大人，对方仙品已抵达，无法打劫~")
			return 
		end

		local userId = self._shipInfo.userId
		if self._shipInfo.escortUserId then
			userId = self._shipInfo.escortUserId
		end
		self:startBattle(userId)
	end
end

function QUIDialogMaritimeShipInfo:startBattle(userId)
	local battleFunc = function ()
		remote.maritime:requestQueryMaritimeShipInfo(userId, function(data)
			local rivalsFight = (data.maritimeQueryFighterResponse.fighter or {})
			local myInfo = {avatar = remote.user.avatar, name = remote.user.nickname, level = remote.user.level}

			local arenaArrangement1 = QMaritimeArrangement.new({shipInfo = self._shipInfo, myInfo = myInfo, rivalInfo = rivalsFight, rivalsPos = rivalsPos, teamKey = remote.teamManager.MARITIME_ATTACK_TEAM1})
			local arenaArrangement2 = QMaritimeArrangement.new({shipInfo = self._shipInfo, myInfo = myInfo, rivalInfo = rivalsFight, rivalsPos = rivalsPos, teamKey = remote.teamManager.MARITIME_ATTACK_TEAM2})
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
				options = {arrangement1 = arenaArrangement1, arrangement2  = arenaArrangement2, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo", 
				fighterInfo = rivalsFight}})
		end)
	end

	remote.maritime:requestGetMaritimeShipInfo(self._shipInfo.userId, function(data)
			if self:safeCheck() then
				if battleFunc then
					battleFunc()
				end
			end
		end, function()
			if battleFunc then
				battleFunc()
			end
		end)
end

function QUIDialogMaritimeShipInfo:_onTriggerTeam()
	app.sound:playSound("common_small")
end

function QUIDialogMaritimeShipInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMaritimeShipInfo:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_close")
	if event and event.isForce then
		self:popSelf()
	else
		self:playEffectOut()
	end
end

function QUIDialogMaritimeShipInfo:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogMaritimeShipInfo