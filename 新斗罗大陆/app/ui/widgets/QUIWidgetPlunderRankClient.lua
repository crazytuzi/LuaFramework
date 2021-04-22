-- @Author: xurui
-- @Date:   2016-12-16 20:08:09
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-04-04 12:06:08
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlunderRankClient = class("QUIWidgetPlunderRankClient", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUnionAvatar = import("...utils.QUnionAvatar")
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")

function QUIWidgetPlunderRankClient:ctor(options)
	local ccbFile = "ccb/Widget_plunder_ranksingle.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerLink", callback = handler(self, self._onTriggerLink)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
	}
	QUIWidgetPlunderRankClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetPlunderRankClient:onEnter()
end

function QUIWidgetPlunderRankClient:onExit()
end

function QUIWidgetPlunderRankClient:setInfo(param)
	self._info = param.info
	self._awardsType = param.awardsType
	
	self._ccbOwner.first:setVisible(false)
	self._ccbOwner.second:setVisible(false)
	self._ccbOwner.third:setVisible(false)
	self._ccbOwner.other:setVisible(false)
	if self._info.rank == 1 then
		self._ccbOwner.first:setVisible(true)
	elseif self._info.rank == 2 then
		self._ccbOwner.second:setVisible(true)
	elseif self._info.rank == 3 then
		self._ccbOwner.third:setVisible(true)
	else
		self._ccbOwner.other:setVisible(true)
		self._ccbOwner.other:setString(self._info.rank )
	end

	self._ccbOwner.tf_name:setString(self._info.name or "")
	self._ccbOwner.tf_level:setString(string.format("LV.%d",self._info.level or 1))

	local score = self._info.today_socre or 0
	if param.awardsType == 2 then
		self._ccbOwner.btn_link:setVisible(false)
		score = self._info.mineScore or 0
	end
	local num, str = q.convertLargerNumber(score)
	self._ccbOwner.tf_value1:setString(num..(str or ""))

	local areaName = self._info.game_area_name
	if not areaName then
		areaName = self._info.gameAreaName or ""
	end
	self._ccbOwner.tf_value2:setString(areaName)

	if self._info.vip then
		self._ccbOwner.tf_vip:setString("VIP "..self._info.vip)
	else
		self._ccbOwner.tf_vip:setVisible(false)
	end

	if self._avatar ~= nil then
		self._avatar:removeFromParent()
		self._avatar = nil
	end
	local avatar = self._info.avatar
	if self._info.avatar then
		self._avatar = QUIWidgetAvatar.new()
	elseif self._info.icon then
		self._avatar = QUnionAvatar.new()
		avatar = self._info.icon
	end
	self._avatar:setInfo(avatar)
	self._avatar:setSilvesArenaPeak(self._info.championCount)
    self._ccbOwner.node_headPicture:addChild(self._avatar)

	local config = QStaticDatabase:sharedDatabase():getBadgeByCount(self._info.nightmareDungeonPassCount or 0)
	if config ~= nil then
		self._ccbOwner.node_badge:setVisible(true)
		self._ccbOwner.node_badge:addChild(CCSprite:create(config.alphaicon))
	else
		self._ccbOwner.node_badge:setVisible(false)
	end
	if self._info.soulTrial then
		self:setSoulTrial(self._info.soulTrial)
	else
		self:setSoulTrial(-1)
	end
	self:autoLayout()
end

function QUIWidgetPlunderRankClient:_onTriggerInfo()
	if self._awardsType and self._awardsType == 2 then return end
    app.sound:playSound("common_small")
	remote.plunder:plunderQueryFighterRequest(self._info.userId, function(data)
			local fighter = data.kuafuMineQueryFighterResponse.fighter
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
		    		options = {fighter = fighter, specialTitle1 = "服务器名：", specialValue1 = fighter.game_area_name,  
		    		forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
		end, function()
			app.tip:floatTip("魂师大人，您当前网络不稳定，请稍后再试～")
		end)
end

-- 链接到魂兽森林
function QUIWidgetPlunderRankClient:_onTriggerLink(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_link) == false then return end
    app.sound:playSound("common_small")
    if remote.plunder:checkBurstIn() then return end 
    
	if self._info.userId == nil then return end
	remote.plunder:plunderGetUserCaveInfoRequest(self._info.userId, function(data)
			if self._ccbView then
				local caveId = data.kuafuMineGetCaveInfoResponse.mineCave.caveId
				local mineInfo = data.kuafuMineGetCaveInfoResponse.mineCave.occupies

				local mineId = nil
				for _, value in pairs(mineInfo) do
					if value.ownerId == self._info.userId then
						mineId = value.mineId
						break 
					end
				end
				if mineId then
					local caveConfig = remote.plunder:getCaveConfigByMineId(mineId)
					if caveConfig and table.nums(caveConfig) > 0 then
						local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
						if dialog.class.__cname == "QUIDialogPlunderMain" then
	            			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
						end
						app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderMain", 
							options = {caveId = caveConfig.cave_id, caveRegion = caveConfig.cave_region, caveName = caveConfig.cave_name, recommendMineId = mineId}}, {isPopCurrentDialog = true})
						-- if not app:getNavigationManager():getController(app.mainUILayer):getTopPage().inSilverMinePage then 
						-- 	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderMain", 
						-- 		options = {caveId = caveConfig.cave_id, caveRegion = caveConfig.cave_region, caveName = caveConfig.cave_name, recommendMineId = mineId}}, {isPopCurrentDialog = true})
						-- else
						--  	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
					 --        page:setAllUIVisible()
					 --        page:setScalingVisible(false)
					 --        page.topBar:showWithSilverMine()
					 --        app:getNavigationManager():getController(app.mainUILayer):getTopDialog():gotoMine(tonumber(caveConfig.cave_id), tonumber(caveConfig.cave_region), nil, mineId)
						-- end
					end
				end
			end
		end)
end

function QUIWidgetPlunderRankClient:getContentSize()
	return self._ccbOwner.background:getContentSize()
end

function QUIWidgetPlunderRankClient:setSoulTrial(soulTrial)
	local sp = self._ccbOwner.sp_soulTrial
	if not sp then return end

	local _, frame = remote.soulTrial:getSoulTrialTitleSpAndFrame(soulTrial)
	
    if frame then
        sp:setDisplayFrame(frame)
        sp:setVisible(true)
    else
        sp:setVisible(false)
    end
end


function QUIWidgetPlunderRankClient:autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.sp_soulTrial)
	table.insert(nodes, self._ccbOwner.tf_level)
	table.insert(nodes, self._ccbOwner.node_badge)
	table.insert(nodes, self._ccbOwner.tf_name)
	table.insert(nodes, self._ccbOwner.tf_vip)
	table.insert(nodes, self._ccbOwner.btn_link)
	q.autoLayerNode(nodes, "x", 5)
end

return QUIWidgetPlunderRankClient