

-- 大师赛上阵控件
-- Author: qinsiyang


local QUIWidget = import(".QUIWidget")
local QUIWidgetMockBattleArray = class("QUIWidgetMockBattleArray", QUIWidget)

local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroSmallFrame = import(".QUIWidgetHeroSmallFrame")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIWidgetMockBattleArray.EVENT_SELECT_TAB = "EVENT_SELECT_TAB"

QUIWidgetMockBattleArray.MARGIN = 0
QUIWidgetMockBattleArray.GAP = 0
QUIWidgetMockBattleArray.HERO_CHANGED = "HERO_CHANGED"
QUIWidgetMockBattleArray.HERO_FULL = "魂师已满"
QUIWidgetMockBattleArray.MOUNT_FULL = "暗器已满"
QUIWidgetMockBattleArray.SOUL_FULL = "魂灵已满"
QUIWidgetMockBattleArray.GODARM_FULL = "神器已满"
QUIWidgetMockBattleArray.GODARM_SAME_FULL = "同类型神器只能同时上两个"
QUIWidgetMockBattleArray.HERO_NOT_ENOUGH = "请先上阵魂师后继续装备暗器"

QUIWidgetMockBattleArray.SPECIAL_TYPE = 991


QUIWidgetMockBattleArray.HERO_TYPE = 1
QUIWidgetMockBattleArray.MOUNT_TYPE = 2
QUIWidgetMockBattleArray.SOUL_TYPE = 3
QUIWidgetMockBattleArray.GODARM_TYPE = 4



function QUIWidgetMockBattleArray:ctor(options)
	local ccbFile = "ccb/Widget_MockBattleArray.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerHero", callback = handler(self, self._onTriggerHero)},
		{ccbCallbackName = "onTriggerMount", callback = handler(self, self._onTriggerMount)},
		{ccbCallbackName = "onTriggerSoul", callback = handler(self, self._onTriggerSoul)},
		{ccbCallbackName = "onTriggerHelper", callback = handler(self, self.onTriggerHelper)},
		{ccbCallbackName = "onTriggerHelper2", callback = handler(self, self.onTriggerHelper2)},
		{ccbCallbackName = "onTriggerHelper3", callback = handler(self, self.onTriggerHelper3)},
		{ccbCallbackName = "onTriggerMain", callback = handler(self, self.onTriggerMain)},
		{ccbCallbackName = "onTriggerAlternate", callback = handler(self, self.onTriggerAlternate)},
		{ccbCallbackName = "onTriggerGodarm", callback = handler(self, self.onTriggerGodarm)},
		
	}
	QUIWidgetMockBattleArray.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._state = options.state
    self._ccbOwner.tips:setString(options.tips or "")
	self._width = self._ccbOwner.sheet_layout:getContentSize().width
	self._items = {}

	self._selectConfig = nil
    self._heroList = options.heroList
    self._soulSpiritList = options.soulSpiritList or {}
    self._mountList = options.mountList or {}
    self._godarmList = options.godarmList or {}
    self._alternateList = options.alternateList or {}
    self._arrangement = options.arrangement
    self._isAlternate = options.isAlternate or false
    self._trialNum = options.trialNum
    self._temp_pos = nil
	self._seasonType = options.seasonType

	for k, v in pairs(self._heroList) do
		v.isAlternate = v.isAlternate or false
	end

    self._buttonList = {
    	{name = "btn_hero", ccb = self._ccbOwner.btn_hero, updateFun = handler(self, self._updateHero)},
    	{name = "btn_mount", ccb = self._ccbOwner.btn_mount, updateFun = handler(self, self._updateMount)},
    	{name = "btn_soul", ccb = self._ccbOwner.btn_soul, updateFun = handler(self, self._updateSoulSpirit)},
	}
	self._currentButtonName = self._buttonList[1].name	
	self._unlockNumber = options.unlockNumber or 4
	self._unlockMountNumber = options.unlockMountNumber or 4

	print("self._unlockNumber ="..self._unlockNumber )
	print("self._unlockMountNumber ="..self._unlockMountNumber )
	self._selectedNumber = 0
	self._selectTeamIndex = 0
	self._selectIsAlternate = false
	
	self._additionalMaxHp = {}
	self._ccbOwner.btn_helper:setVisible(false)
	self._ccbOwner.node_alternate:setVisible(false)

	if self._seasonType == 2 then
		self._ccbOwner.node_helper:setVisible(false)
		self._ccbOwner.node_godarm:setVisible(true)
	else
		self._ccbOwner.node_helper:setVisible(true)
		self._ccbOwner.node_godarm:setVisible(false)
	end


end

function QUIWidgetMockBattleArray:updateArrangement(param)
	print("两小队----:updateArrangement-----------")
    -- self._heroList = param.heroList
    -- self._soulSpiritList = param.soulSpiritList
    -- self._mountList = param.mountList or {}
    -- self._godarmList = param.godarmList or {}
    self._arrangement = param.arrangement
	self._unlockNumber = param and (param.unlockNumber or 4) or 4
	self._selectedNumber = 0
	self._selectTeamIndex = 0
	self._selectIsAlternate = false
    self._trialNum = param.trialNum
		
	self:onTriggerMain()
	if self._currentButtonName == "soul" then
    	self:selectButton("all")
		self._selectConfig.updateFun()
	end
end


function QUIWidgetMockBattleArray:onEnter()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSmallFrame.EVENT_HERO_FRAMES_CLICK, self._onIconClick, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSmallFrame.EVENT_SOUL_FRAMES_CLICK, self._onSoulIconClick, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSmallFrame.EVENT_MOUNT_FRAMES_CLICK, self._onMountIconClick, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSmallFrame.EVENT_GODARM_FRAMES_CLICK, self._onGodarmIconClick, self)

    self._ccbOwner.node_btn:setVisible(app.unlock:getUnlockHelperDisplay())

    -- if app.unlock:getUnlockTeamHelp4() then
    -- 	self._ccbOwner.btn_helper:setVisible(false)
    -- 	self._ccbOwner.btn_helper1:setVisible(true)
    -- else
    -- 	self._ccbOwner.btn_helper:setVisible(true)
    -- 	self._ccbOwner.btn_helper1:setVisible(false)
    -- end
	self._ccbOwner.btn_helper:setVisible(true)
	self._ccbOwner.btn_helper1:setVisible(false)
    local isUnlock = true
	self._ccbOwner.node_helper:setVisible(isUnlock)
	self._ccbOwner.helperLock1:setVisible(not isUnlock)
	self._ccbOwner.helperLock2:setVisible(false)
	self._ccbOwner.helperLock3:setVisible(false)
	self._ccbOwner.node_helper2:setVisible(false)
	self._ccbOwner.node_helper3:setVisible(false)
	if self._seasonType == 2 then
		self._ccbOwner.node_helper:setVisible(false)
		self._ccbOwner.node_godarm:setVisible(true)
	else
		self._ccbOwner.node_helper:setVisible(true)
		self._ccbOwner.node_godarm:setVisible(false)
	end
	-- if app.unlock:getUnlockTeamHelp4() then
	-- 	if app.unlock:getUnlockTeamHelp5() == false then
	-- 		self._ccbOwner.helperLock2:setVisible(true)
	-- 	end
	-- 	self._ccbOwner.node_helper2:setVisible(true)
	-- else
	-- 	self._ccbOwner.node_helper2:setVisible(false)
	-- end
	-- if app.unlock:getUnlockTeamHelp8() then
	-- 	if app.unlock:getUnlockTeamHelp9() == false then
	-- 		self._ccbOwner.helperLock3:setVisible(true)
	-- 	end
	-- 	self._ccbOwner.node_helper3:setVisible(true)
	-- else
	-- 	self._ccbOwner.node_helper3:setVisible(false)
	-- end

	-- 替补战队按钮修改
	if self._isAlternate then
		self._ccbOwner.node_alternate:setVisible(true)
		self._ccbOwner.node_helper:setPositionX(self._ccbOwner.node_helper2:getPositionX())
		self._ccbOwner.node_helper2:setPositionX(self._ccbOwner.node_helper3:getPositionX())
		self._ccbOwner.node_helper3:setVisible(false)
		if not app.unlock:getUnlockTeamAlternateHelp5() then
			self._ccbOwner.node_helper2:setVisible(false)
		end
	end

	self:selectButton("btn_hero")
	self._schdulerHandler = scheduler.performWithDelayGlobal(function ( ... )
    	self._schdulerHandler = nil
		self:onTriggerMain()
    end, 0)
end

function QUIWidgetMockBattleArray:initListView( ... )
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._items[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
					item = QUIWidgetHeroSmallFrame.new()
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            item:initGLLayer()
	            info.item = item
	            info.size = item:getContentSize()
                list:registerBtnHandler(index,"btn_team", "_onTriggerHeroOverview")
	            return isCacheNode
	        end,
	        isVertical = false,
	        curOriginOffset = 10,
	        curOffset = 10,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 10,
	        totalNumber = #self._items,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
		self._lastItemNum = #self._items
	else
		print("QUIWidgetMockBattleArray:initListView    reload")

		if self._lastItemNum == #self._items then
			self._listViewLayout:refreshData() 
		else
			self._listViewLayout:reload({totalNumber = #self._items})
			self._lastItemNum = #self._items
		end

	end
end

function QUIWidgetMockBattleArray:runTo(actorId, callback)
	if self._listViewLayout then
		for i, value in ipairs(self._items) do
			if value.data.actorId == actorId or value.data.soulSpiritId == actorId then
				self._listViewLayout:startScrollToIndex(i, nil, 50, callback);
				return
			end
		end
	end
end

function QUIWidgetMockBattleArray:getIndexByHeroId(actorId)
	for i, value in ipairs(self._items) do
		if value.data.actorId == actorId then
			return i
		end
	end
	return nil
end

function QUIWidgetMockBattleArray:onExit()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSmallFrame.EVENT_HERO_FRAMES_CLICK, self._onIconClick, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSmallFrame.EVENT_SOUL_FRAMES_CLICK, self._onSoulIconClick, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSmallFrame.EVENT_MOUNT_FRAMES_CLICK, self._onMountIconClick, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSmallFrame.EVENT_GODARM_FRAMES_CLICK, self._onGodarmIconClick, self)
  
    if self._schdulerHandler ~= nil then
    	scheduler.unscheduleGlobal(self._schdulerHandler)
    	self._schdulerHandler = nil
    end
end

function QUIWidgetMockBattleArray:updateHeroByTeams(teams1, teams2,team_pos_change)
	for k, v in pairs(self._heroList) do
		v.index = 0
	end
	for k, v in pairs(self._soulSpiritList) do
		v.index = 0
	end
	for k,v in pairs(self._godarmList) do
		v.index = 0
	end
	for k,v in pairs(self._mountList) do
		v.index = 0
	end
	if teams1[1] then
		for idx, actorId in ipairs(teams1[1]) do
			local hero_info = remote.mockbattle:getCardInfoByIndex(actorId)
			actorId = hero_info.actorId
			self._heroList[actorId].index = 1
			self._heroList[actorId].trialNum = 1
			self._heroList[actorId].helpIndex = 0
		end
	end



	if teams1[2] then
		for helpIndex, actorId in ipairs(teams1[2]) do
			local hero_info = remote.mockbattle:getCardInfoByIndex(actorId)
			actorId = hero_info.actorId
			self._heroList[actorId].index = 2
			self._heroList[actorId].trialNum = 1
			self._heroList[actorId].helpIndex = helpIndex
		end
	end
	if teams1[3] then
		for _, soulSpiritId in ipairs(teams1[3]) do
			local hero_info = remote.mockbattle:getCardInfoByIndex(soulSpiritId)
			soulSpiritId = hero_info.actorId
			self._soulSpiritList[soulSpiritId].index = 1
			self._soulSpiritList[soulSpiritId].trialNum = 1
		end
	end

	if next(self._godarmList) ~= nil then
		if teams1[4] then
			for pos,godarmId in pairs(teams1[4]) do
				-- local hero_info = remote.mockbattle:getCardInfoByIndex(godarmId)
				-- godarmId = hero_info.actorId
				self._godarmList[godarmId].index = 5
				self._godarmList[godarmId].trialNum = 1
				self._godarmList[godarmId].pos = pos


			end
		end
	end




	if teams2[1] then
		for idx, actorId in ipairs(teams2[1]) do
			local hero_info = remote.mockbattle:getCardInfoByIndex(actorId)
			actorId = hero_info.actorId			
			self._heroList[actorId].index = 1
			self._heroList[actorId].trialNum = 2
			self._heroList[actorId].helpIndex = 0
		end
	end

	if teams2[2] then
		for helpIndex, actorId in ipairs(teams2[2]) do
			local hero_info = remote.mockbattle:getCardInfoByIndex(actorId)
			actorId = hero_info.actorId			
			self._heroList[actorId].index = 2
			self._heroList[actorId].trialNum = 2
			self._heroList[actorId].helpIndex = helpIndex
		end
	end
	if teams2[3] then
		for _, soulSpiritId in ipairs(teams2[3]) do
			local hero_info = remote.mockbattle:getCardInfoByIndex(soulSpiritId)
			soulSpiritId = hero_info.actorId			
			self._soulSpiritList[soulSpiritId].index = 1
			self._soulSpiritList[soulSpiritId].trialNum = 2
		end
	end

	if next(self._godarmList) ~= nil then
		if teams2[4] then
			for pos,godarmId in pairs(teams2[4]) do
				-- local hero_info = remote.mockbattle:getCardInfoByIndex(godarmId)
				-- godarmId = hero_info.actorId				
				self._godarmList[godarmId].index = 5
				self._godarmList[godarmId].trialNum = 2
				self._godarmList[godarmId].pos = pos
			end
		end
	end

	QPrintTable(team_pos_change)
	if next(self._mountList) ~= nil then
		if teams1[5] and team_pos_change[1] then
			for idx_,id in pairs(teams1[5]) do				
				local hero_info = remote.mockbattle:getCardInfoByIndex(id)
				id = hero_info.actorId
				self._mountList[id].index = 1
				self._mountList[id].trialNum = 1
				local pos__ = 99
				if team_pos_change[1][idx_] then
					pos__ = team_pos_change[1][idx_].pos or 99
				end
				self._mountList[id].pos = tonumber(pos__)
			end
		end
	end		

	if next(self._mountList) ~= nil then
		if teams2[5] and team_pos_change[2] then
			for idx_,id in pairs(teams2[5]) do
				local hero_info = remote.mockbattle:getCardInfoByIndex(id)
				id = hero_info.actorId				
				self._mountList[id].index = 1
				self._mountList[id].trialNum = 2
				local pos__ = 99
				if team_pos_change[2][idx_] then
					pos__ = team_pos_change[2][idx_].pos or 99
				end
				self._mountList[id].pos = tonumber(pos__)
			end
		end
	end



	self._selectedNumber = 0
	local heroList = {}
	for k, v in pairs(self._heroList) do
		if v.trialNum == self._trialNum and v.index == self._selectTeamIndex then
			self._selectedNumber = self._selectedNumber + 1
			table.insert(heroList, v)
		end
	end
	local soulSpiritList = {}
	for k, v in pairs(self._soulSpiritList) do
		if v.trialNum == self._trialNum and v.index == self._selectTeamIndex then
			table.insert(soulSpiritList, v)
		end
	end
	local godarmList = {}	
	for k,v in pairs(self._godarmList) do
		if v.index ~= 0 and v.trialNum == self._trialNum then
			table.insert(godarmList, v)
		end
	end
	local mountList = {}	
	for k,v in pairs(self._mountList) do
		if  v.trialNum == self._trialNum then
			table.insert(mountList, v)
		end
	end




	self:_updatePage()
	self:_checkTips()
    self:dispatchEvent({name = QUIWidgetMockBattleArray.HERO_CHANGED, godarmList = godarmList, hero = heroList, soulSpirits = soulSpiritList , mountList = mountList})	
end


function QUIWidgetMockBattleArray:removeSelectedHero(id)
	local hero = nil
	for k, v in pairs(self._heroList) do
		if v.actorId == id then
			v.index = 0
			v.isAlternate = false
			hero = v
			self._selectedNumber = self._selectedNumber - 1
			break
		end
	end

	local helperHpSum = 0
	for k, v in pairs(self._heroList) do
		if v.index == 2 or v.index == 4 then
			local _, _, hp = self:getHeroHpMp(v.actorId)
			helperHpSum = helperHpSum + (hp or 0)
		end
	end
	for k, v in pairs(self._heroList) do
		if v.index == 1 then
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId, helperHpSum / 4)
			v.additionalHpMax = helperHpSum / 4
			self._additionalMaxHp[v.actorId] = helperHpSum / 4
		else
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId)
			v.additionalHpMax = 0
			self._additionalMaxHp[v.actorId] = 0
		end
	end

	if hero then
		self:_updateWidget(hero)
	else
		self:_updatePage()
	end
	self:_checkTips()
end

function QUIWidgetMockBattleArray:removeSelectedSoulSpirit(id)
	local soulSpirit = nil
	for k, v in pairs(self._soulSpiritList) do
		if v.soulSpiritId == id then
			v.index = 0
			v.trialNum = 0
			soulSpirit = v
			break
		end
	end

	if soulSpirit then
		self:_updateSoulWidget(soulSpirit)
	else
		self:_updatePage()
	end
	self:_checkTips()
end

function QUIWidgetMockBattleArray:removeSelectedGodarm(id)
	local godarmSprit = nil
	local pos = 1
	local trialNum = 0
	for k, v in pairs(self._godarmList) do
		if v.godarmId == id then
			v.index = 0
			pos = v.pos
			trialNum = v.trialNum
			v.trialNum = 0
			v.pos = 5
			godarmSprit = v
			break
		end
	end
	for k, v in pairs(self._godarmList) do
		if v.pos and v.pos > pos and v.pos < 5 and v.pos > 1 and v.trialNum == trialNum then
			QPrintTable(v)
			v.pos = v.pos - 1
		end
	end
	if godarmSprit ~= nil and next(godarmSprit) ~= nil then
		self:_updateGodarmWidget(godarmSprit)
	else
		self:_updatePage()
	end
	self:_checkTips()
end



function QUIWidgetMockBattleArray:removeSelectedMount(id)

	local mount = nil
	for k, v in pairs(self._mountList) do
		if v.mountId == id then
			v.index = 0
			v.trialNum = 0
			v.pos = 99
			mount = v
			break
		end
	end

	if mount then
		self:_updateMountWidget(mount)
	else
		self:_updatePage()
	end
	self:_checkTips()
end


function QUIWidgetMockBattleArray:setUnlockNumber(value)
	self._unlockNumber = value
end

function QUIWidgetMockBattleArray:getSelectIndex()
	return self._selectTeamIndex
end

function QUIWidgetMockBattleArray:getSelectIsAlternate()
	return self._selectIsAlternate
end

-- 不包括替补
function QUIWidgetMockBattleArray:getSelectTeam(need_id, trialNum)
	local tbl = {}
	for _, value in pairs(self._heroList) do
		local check_trial = trialNum == nil or  value.trialNum == trialNum

		if value.index ~= 0 and not value.isAlternate and check_trial then
			if tbl[value.index] == nil then tbl[value.index] = {} end
			if need_id then
				table.insert(tbl[value.index], value.id)
			else
				table.insert(tbl[value.index], value.actorId)
			end			
		end
	end
	return tbl
end

-- 主力阵容包括替补
function QUIWidgetMockBattleArray:getSelectMainTeam(need_id, trialNum)
	local tbl = {}
	for _, value in pairs(self._heroList) do
		local check_trial = trialNum == nil or  value.trialNum == trialNum
		if value.index == 1 and check_trial then
			if need_id then
				table.insert(tbl, value.id)
			else
				table.insert(tbl, value.actorId)
			end
		end
	end
	return tbl
end


function QUIWidgetMockBattleArray:getSelectGodarmListInfo(trialNum)
	local tbl = {}
	local godarmList = clone(self._godarmList)
	table.sort( godarmList, function( a,b )
		if a.pos ~= b.pos then
			return a.pos > b.pos
		end
	end)	
	for _,v in pairs(godarmList) do
		local check_trial = trialNum == nil or  v.trialNum == trialNum
		if v.index == 5 and check_trial then
			table.insert(tbl, v)
		end
	end
	return tbl
end


-- 主力阵容不包括替补
function QUIWidgetMockBattleArray:getSelectPureMainTeam(need_id, trialNum)
	local tbl = {}
	
	for _, value in pairs(self._heroList) do
		local check_trial = trialNum == nil or  value.trialNum == trialNum
		if value.index == 1 and not value.isAlternate and check_trial then
			if need_id then
				table.insert(tbl, value.id)
			else
				table.insert(tbl, value.actorId)
			end
		end
	end
	return tbl
end

function QUIWidgetMockBattleArray:getSelectAlternateTeam(need_id, trialNum)
	local tbl = {}

	for _, value in pairs(self._heroList) do
		local check_trial = trialNum == nil or  value.trialNum == trialNum
		if value.index ~= 0 and value.isAlternate and check_trial then
			if need_id then
				table.insert(tbl, value.id)
			else
				table.insert(tbl, value.actorId)
			end
		end
	end
	return tbl
end

--获取精灵的战队
function QUIWidgetMockBattleArray:getSelectSoulSpirit(need_id , trialNum)
	local tbl = {}

	for _,v in pairs(self._soulSpiritList) do
		local check_trial = trialNum == nil or  v.trialNum == trialNum
		if v.index ~= 0 and  check_trial then
			if need_id then
				table.insert(tbl, v.id)
			else
				table.insert(tbl, v.soulSpiritId)
			end
		end
	end
	return tbl
end

--获取神器的战队
function QUIWidgetMockBattleArray:getSelectGodarmList(need_id , trialNum)
	local tbl = {}

	local godarmList = clone(self._godarmList)

	table.sort( godarmList, function( a,b )
		if a.pos ~= b.pos then
			return a.pos > b.pos
		end
	end)	
	for _,v in pairs(godarmList) do
		local check_trial = trialNum == nil or v.trialNum == trialNum
		if v.index == 5 and check_trial then
			-- if need_id then
			-- 	tbl[v.pos] =  v.id
			-- else
			-- 	tbl[v.pos] =  v.godarmId
			-- end
			-- print("神器的位置-----v.pos",v.pos)			
			if need_id then
				table.insert(tbl, v.id)
			else
				table.insert(tbl, v.godarmId)
			end
		end
	end
	return tbl
end


--获取暗器的战队
function QUIWidgetMockBattleArray:getSelectMount(need_id , trialNum)
	local tbl = {}
	for _,v in pairs(self._mountList) do
		local check_trial = trialNum == nil or v.trialNum == trialNum
		if v.index ~= 0 and v.pos < 5 and check_trial then
			tbl[v.pos] =  v.mountId
			if need_id then
				tbl[v.pos] =  v.id
			else
				tbl[v.pos] =  v.mountId
			end
		end
	end
	return tbl
end


function QUIWidgetMockBattleArray:_updatePage()
	if self._selectConfig ~= nil then
		self:_showArray()
		print("self._selectConfig  ======= not nil")
	else
		print("self._selectConfig  ======= nil")
	end

	self:_updateButtonStatus()
end

function QUIWidgetMockBattleArray:_updateButtonStatus()
	for k, v in ipairs(self._buttonList) do
		if v.name == self._currentButtonName then
			v.ccb:setHighlighted(true)
		else
			v.ccb:setHighlighted(false)
		end
	end
end 


--by:Kumo  new sort 星级（降序） > 战斗力（降序） > ID（升序）  
function QUIWidgetMockBattleArray:_sortHero(a,b)

	local heroA = remote.mockbattle:getCardInfoById(a)
	local heroB = remote.mockbattle:getCardInfoById(b)	
	local characherA = QStaticDatabase:sharedDatabase():getCharacterByID(heroA.actorId)
	local characherB = QStaticDatabase:sharedDatabase():getCharacterByID(heroB.actorId)
	if characherA == nil and characherB ~= nil then
		return false
	elseif characherB == nil and characherA ~= nil then
		return true
	end
	if characherA == nil and characherB == nil then
		return heroA.actorId > heroB.actorId
	end
	if characherA.aptitude ~= characherB.aptitude then
		return characherA.aptitude < characherB.aptitude
	else
		return heroA.actorId > heroB.actorId
	end

end

--显示队列
function QUIWidgetMockBattleArray:_showArray()

	if self._currentButtonName == "btn_soul" then --走精灵模块
		self._items = {}
		local soulSpiritList = clone(self._soulSpiritList)
		for k, v in pairs(soulSpiritList) do
			table.insert(self._items, {oType = "soul",isMockBattle =true, data = v})
		end
			table.sort(self._items, function (a,b)
			local characherA = db:getCharacterByID(a.data.soulSpiritId)
			local characherB = db:getCharacterByID(b.data.soulSpiritId)
			if characherA.aptitude ~= characherB.aptitude then
				return characherA.aptitude > characherB.aptitude
			-- elseif a.data.grade ~= b.data.grade then
			-- 	return a.data.grade > b.data.grade
			-- elseif a.data.level ~= b.data.level then
			-- 	return a.data.level > b.data.level
			else
				return a.data.soulSpiritId > b.data.soulSpiritId
			end
		end)	
	elseif self._currentButtonName == "btn_mount" then --走暗器模块
		self._items = {}
		local mountList = clone(self._mountList)
		for k, v in pairs(mountList) do
			table.insert(self._items, {oType = "mount",isMockBattle =true, data = v})
		end
		table.sort(self._items, function (a,b)
			local characherA = db:getCharacterByID(a.data.mountId)
			local characherB = db:getCharacterByID(b.data.mountId)
			if characherA.aptitude ~= characherB.aptitude then
				return characherA.aptitude > characherB.aptitude
			-- elseif a.data.grade ~= b.data.grade then
			-- 	return a.data.grade > b.data.grade
			-- elseif a.data.level ~= b.data.level then
			-- 	return a.data.level > b.data.level
			else
				return a.data.mountId > b.data.mountId
			end
		end)	
	elseif self._currentButtonName == "godarm" then --神器上阵
		self._items = {}
		for k, v in pairs(self._godarmList) do
			table.insert(self._items, {oType = "godarm", data = v,isMockBattle =true})
		end
		table.sort(self._items, function (a,b)
			local characherA = db:getCharacterByID(a.data.godarmId)
			local characherB = db:getCharacterByID(b.data.godarmId)
			if characherA.aptitude ~= characherB.aptitude then
				return characherA.aptitude > characherB.aptitude
			-- elseif a.data.grade ~= b.data.grade then
			-- 	return a.data.grade > b.data.grade
			-- elseif a.data.level ~= b.data.level then
			-- 	return a.data.level > b.data.level
			else
				return a.data.godarmId > b.data.godarmId
			end
		end)		
	else
		local allHero = {}
		self._items = {}
		self._displayHero = {}
		for k, v in pairs(self._heroList) do
			table.insert(allHero, v.actorId)
		end
		table.sort(allHero, handler(self, self._sortHero))

		for i = #allHero, 1, -1 do 
			local v = self._heroList[allHero[i]]
			v.additionalHpMax = self._additionalMaxHp[v.actorId] or 0
			table.insert(self._items, {oType = "hero",isMockBattle =true, data = v})
		end
	end

	self:initListView()
end

function QUIWidgetMockBattleArray:_onIconClick(event)
	local unlockNumber = self._unlockNumber
	-- 替补只有三个
	if self._selectIsAlternate then
		unlockNumber = 3
	end
	local victoryId = nil
	local hero = nil
	for k, v in pairs(self._heroList) do
		if v.actorId == event.actorId then
			if v.index == 0 then
				if self._selectedNumber >= unlockNumber then
					app.tip:floatTip(QUIWidgetMockBattleArray.HERO_FULL) 
					return
				end
				victoryId = v.actorId
				v.index = self._selectTeamIndex
				v.isAlternate = self._selectIsAlternate
				v.trialNum = self._trialNum
			else
				if v.index  == remote.teamManager.TEAM_INDEX_MAIN then
					self:_dropHeroAndMountByHeroInf(v)
				end
				v.index = 0
				v.trialNum = 0
				v.isAlternate = false
			end
			hero = v
			break
		end
	end

	self:_updateHero(victoryId, hero)
	self:_checkTips()
end


function QUIWidgetMockBattleArray:_dropHeroAndMountByHeroInf(heroInfo)
	local heroList = {}
	for k, v in pairs(self._heroList) do
		if heroInfo.index == v.index and heroInfo.trialNum == v.trialNum and heroInfo.isAlternate == v.isAlternate then
			table.insert(heroList,v)
		end 
	end
	table.sort(heroList, function (x, y)
		if x.hatred == y.hatred then
			return x.force > y.force
		end
		return x.hatred > y.hatred
	end )
	for i,v in ipairs(heroList) do
		if v.actorId == heroInfo.actorId then
			self:removeSelectedMountByHeroPos(i,heroInfo.trialNum)
		end
	end
end


function QUIWidgetMockBattleArray:_onSoulIconClick(event)
	local victoryId = nil
	local hero = nil
	local selectIndex = self:getSelectIndex()
	local currentSelect = 0
	for k, v in pairs(self._soulSpiritList)  do
		if v.index ~= 0 and v.trialNum == self._trialNum then
			currentSelect = currentSelect + 1
		end
	end
	for k, v in pairs(self._soulSpiritList) do
		if v.soulSpiritId == event.soulSpiritId then
			if v.index == 0 then
				local teamKey = self._arrangement:getTeamKey()
				local teamVO = remote.teamManager:getTeamByKey(teamKey)
				if currentSelect >= teamVO:getSoulSpriteMaxCountByIndex(selectIndex) then
					app.tip:floatTip(QUIWidgetMockBattleArray.SOUL_FULL) 
					return
				end
				victoryId = v.soulSpiritId
				v.index = remote.teamManager.TEAM_INDEX_MAIN
				v.trialNum =  self._trialNum 
			else
				v.index = 0
				v.trialNum = 0
			end
			hero = v
			break
		end
	end

	self:_updateSoulSpirit(victoryId, hero)
	self:_checkTips()
end


function QUIWidgetMockBattleArray:_onGodarmIconClick( event )
	local victoryId = nil
	local hero = nil
	local selectIndex = self:getSelectIndex()
	local characherCOnfig  = db:getCharacterByID(event.godarmId)

	local currentSelect = 0
	local samelabelNum = 0
	for k, v in pairs(self._godarmList) do
		if v.index == selectIndex  and v.trialNum == self._trialNum  then
			local curtentConfig  = db:getCharacterByID(v.godarmId)
			currentSelect = currentSelect + 1
			if characherCOnfig.label ~= nil and characherCOnfig.label == curtentConfig.label then
				samelabelNum = samelabelNum + 1
			end	
		end
	end
	local sortPos = function( pos,trialNum)
		for k, v in pairs(self._godarmList) do
			if v.pos and v.pos > pos and v.pos ~= 5 and trialNum == v.trialNum then
				v.pos = v.pos - 1
			end
		end
	end
	for k, v in pairs(self._godarmList) do
		if v.godarmId == event.godarmId then
			if v.index == 0 then
				local teamKey = self._arrangement:getTeamKey()
				local teamVO = remote.teamManager:getTeamByKey(teamKey)
				if currentSelect >= teamVO:getHerosGodArmMaxCountByIndex(selectIndex) then
					app.tip:floatTip(QUIWidgetMockBattleArray.GODARM_FULL) 
					return
				end
				if samelabelNum >= 2 then
					app.tip:floatTip(QUIWidgetMockBattleArray.GODARM_SAME_FULL) 
					return
				end
				victoryId = v.godarmId
				v.index = self._selectTeamIndex
				v.trialNum = self._trialNum
				v.pos = currentSelect + 1
			else
				v.index = 0	
				sortPos(v.pos,v.trialNum)	
				v.trialNum = 0
				v.pos = 5
			end
			hero = v
			break
		end
	end

	self:_updateGodarmInfo(victoryId, hero)
	self:_checkTips()
end



function QUIWidgetMockBattleArray:_onMountIconClick(event)
	local victoryId = nil
	local unlockMountNumber = self._unlockMountNumber
	local cur_hero_num = self:getCurMainHeroNum(self._trialNum)

	local victoryId = nil
	local mount = nil
	local null_v = 99
	local currentSelect = 0
	local null_pos = {}
	for i=1,self._unlockMountNumber do
		table.insert(null_pos,0)
	end

	for k, v in pairs(self._mountList) do
		if v.index == remote.teamManager.TEAM_INDEX_MAIN and v.pos <= self._unlockMountNumber and v.trialNum == self._trialNum  then
			null_pos[v.pos] = 1
			currentSelect = currentSelect + 1
		end
	end

	for k, v in pairs(null_pos) do
		if v == 0 then
			null_v = k
			break
		end
	end

	for k, v in pairs(self._mountList) do
		if v.mountId == event.mountId then
			if v.index == 0 then
				if currentSelect >= unlockMountNumber then
					app.tip:floatTip(QUIWidgetMockBattleArray.MOUNT_FULL) 
					return
				end
				if currentSelect >= cur_hero_num then
					app.tip:floatTip(QUIWidgetMockBattleArray.HERO_NOT_ENOUGH) 
					return
				end
				victoryId = v.mountId
				v.index = remote.teamManager.TEAM_INDEX_MAIN
				v.pos = null_v
				v.trialNum = self._trialNum

				self._temp_pos = event.position_head
			else
				v.index = 0
				v.isAlternate = false
				v.pos = 99
				v.trialNum = 0
			end
			mount = v
			break
		end
	end

	self:_updateMount(victoryId, mount)
	self:_checkTips()
end

function QUIWidgetMockBattleArray:getCurMainHeroNum(trialNum)
	local num  = 0
	for k, v in pairs(self._heroList) do
		if remote.teamManager.TEAM_INDEX_MAIN == v.index and v.trialNum == trialNum  then
			num = num + 1
		end 
	end
	return num
end


--根据下阵容魂师 调整暗器位置
function QUIWidgetMockBattleArray:removeSelectedMountByHeroPos(pos,trialNum)
	print("removeSelectedMountByHeroPos  pos  "..pos)
	print("removeSelectedMountByHeroPos  trialNum  "..trialNum)
	local victoryId = nil
	local mount = nil

	for k, v in pairs(self._mountList) do
		if v.index == remote.teamManager.TEAM_INDEX_MAIN and v.trialNum == trialNum then
			if v.pos == pos then
				v.index = 0
				v.isAlternate = false
				v.pos = 99
				v.trialNum = 0
			elseif v.pos > pos and  v.pos ~= 99  then
				v.pos = v.pos - 1
			end
		end
	end
	self:_updateMount(victoryId, mount)
end

function QUIWidgetMockBattleArray:moveBackMountByHeroPos(pos,trialNum)
	local victoryId = nil
	local mount = nil
	for k, v in pairs(self._mountList) do
		if v.index == remote.teamManager.TEAM_INDEX_MAIN and v.trialNum == trialNum then
			if v.pos >= pos and  v.pos ~= 99  then
				v.pos = v.pos + 1
			end
		end
	end
	self:_updateMount(victoryId, mount)
end


function QUIWidgetMockBattleArray:getHeroHpMp(actorId, additionalHpMax)
	local hp = 0
	local mp = 0
	local heroProp = remote.mockbattle:getCardUiInfoById(actorId)
	local maxHp = heroProp:getMaxHp()
	maxHp = self._arrangement:getMaxHp(maxHp)
    maxHp = maxHp + (additionalHpMax or 0)
	local heroInfo = nil
	heroInfo = self._arrangement:getHeroInfoById(actorId)
	-- print("getHeroHpMp", actorId, heroInfo)
	-- printTable(heroInfo, actorId..">>>")
	if heroInfo == nil then
		hp = maxHp
		-- 太阳井魂师入场时有初始怒气值
		local rage_config = QStaticDatabase:sharedDatabase():getCharacterRageByCharacterID(actorId)
		if rage_config and rage_config.enter_rage then
			local dungeon_rage_config = QStaticDatabase:sharedDatabase():getDungeonRageOffenceByDungeonID("sunwell")
			local enter_coefficient = (dungeon_rage_config and dungeon_rage_config.enter_coefficient) and dungeon_rage_config.enter_coefficient or 1
			mp = rage_config.enter_rage * enter_coefficient
		else
			mp = 0
		end
		-- 盗贼初始连击点数满
		local character_config = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
		if character_config.combo_points_auto then
			mp = 1000
		end
	else
		hp = heroInfo.hp or heroInfo.currHp
		if heroInfo.mp or heroInfo.currMp then
			mp = heroInfo.mp or heroInfo.currMp
		else
			-- 太阳井魂师入场时有初始怒气值
			local rage_config = QStaticDatabase:sharedDatabase():getCharacterRageByCharacterID(actorId)
			if rage_config and rage_config.enter_rage then
				local dungeon_rage_config = QStaticDatabase:sharedDatabase():getDungeonRageOffenceByDungeonID("sunwell")
				local enter_coefficient = (dungeon_rage_config and dungeon_rage_config.enter_coefficient) and dungeon_rage_config.enter_coefficient or 1
				mp = rage_config.enter_rage * enter_coefficient
			else
				mp = 0
			end
			-- 盗贼初始连击点数满
			local character_config = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
			if character_config.combo_points_auto then
				mp = 1000
			end
		end
	end

	if hp == nil or hp > maxHp then
		hp = maxHp
	end

	local maxMp = heroProp:getRageTotal()
	local hpScale = hp/maxHp
	local mpScale = mp/maxMp

	-- 针对武魂之力或者其他英雄，导致溢出，按照1来复制
	if hpScale > 1 then hpScale = 1 end
	if mpScale > 1 then mpScale = 1 end

	return hpScale, mpScale, hp
end

function QUIWidgetMockBattleArray:_updateHero(victoryId, hero)
	local helperHpSum = 0
	self:_updateSelectedNum()

	for k, v in pairs(self._heroList) do
		if  v.index == remote.teamManager.TEAM_INDEX_HELP or 
			v.index == remote.teamManager.TEAM_INDEX_HELP2 or 
			v.index == remote.teamManager.TEAM_INDEX_HELP3 then
			local _, _, hp = self:getHeroHpMp(v.actorId)
			helperHpSum = helperHpSum + (hp or 0)
		end
	end
	for k, v in pairs(self._heroList) do
		if v.index == remote.teamManager.TEAM_INDEX_MAIN and v.trialNum == self._trialNum then
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId, helperHpSum / 4)
			v.additionalHpMax = helperHpSum / 4
			self._additionalMaxHp[v.actorId] = helperHpSum / 4
		else
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId)
			v.additionalHpMax = 0
			self._additionalMaxHp[v.actorId] = 0
		end
		
	end
	if hero then
		self:_updateWidget(hero)
		self:notificationMainPage(victoryId,QUIWidgetMockBattleArray.HERO_TYPE)
	else
		self:_updatePage()  
		self:notificationMainPage(victoryId)
	end

end

function QUIWidgetMockBattleArray:_updateSelectedNum()
	self._selectedNumber = 0
	for k, v in pairs(self._heroList) do
		if v.index == self._selectTeamIndex and v.isAlternate == self._selectIsAlternate and v.trialNum == self._trialNum then
			self._selectedNumber = self._selectedNumber + 1
		end
	end
end



--更新精灵
function QUIWidgetMockBattleArray:_updateSoulSpirit(victoryId, soulSpirit)
	if soulSpirit then
		self:_updateSoulWidget(soulSpirit)
		self:notificationMainPage(victoryId,QUIWidgetMockBattleArray.SOUL_TYPE)
	else
		self:_updatePage()  
		self:notificationMainPage(victoryId)
	end
end


--更新神器
function QUIWidgetMockBattleArray:_updateGodarmInfo(victoryId, godarmId)
	if godarmId then
		self:_updateGodarmWidget(godarmId)
		self:notificationMainPage(victoryId,QUIWidgetMockBattleArray.GODARM_TYPE)
	else
		self:_updatePage()  
		self:notificationMainPage(victoryId)
	end
end

--更新暗器
function QUIWidgetMockBattleArray:_updateMount(victoryId, mount)
	if mount then
		self:_updateMountWidget(mount)
		self:notificationMainPage(victoryId,QUIWidgetMockBattleArray.MOUNT_TYPE)
	else
		self:_updatePage()  
		self:notificationMainPage(victoryId)
	end
end

function QUIWidgetMockBattleArray:notificationMainPage(victoryId,type)
	local heroList = {}
	local soulSpiritList = {}
	local assistHeroList = {}
	local mountList = {}
	local godarmList = {}
	local selectIndex = self:getSelectIndex()
	for k, v in pairs(self._heroList) do
		if v.index == selectIndex and v.isAlternate == self._selectIsAlternate and v.trialNum == self._trialNum then
			table.insert(heroList, v)
		elseif v.index == (selectIndex+1000) then
			table.insert(assistHeroList, v)
		end
	end
	for k, v in pairs(self._soulSpiritList) do
		if v.index == selectIndex and v.trialNum == self._trialNum then
			table.insert(soulSpiritList, v)
		end
	end

	for k, v in pairs(self._mountList) do
		if v.index == selectIndex  and v.trialNum == self._trialNum then
			table.insert(mountList, v)
		end
	end
	for k,v in pairs(self._godarmList) do
		if v.index ~= 0 and v.trialNum == self._trialNum then
			table.insert(godarmList, v)
		end
	end
    self:dispatchEvent({name = QUIWidgetMockBattleArray.HERO_CHANGED, hero = heroList, soulSpirits = soulSpiritList, assistHeroList = assistHeroList
    	, mountList = mountList, godarmList = godarmList, victoryId = victoryId,idtype = type})
end


--检查是否有为上阵的
function QUIWidgetMockBattleArray:_checkTips()
	local unlockMainCount = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_MAIN)
	local unlockHelp1Count = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP)
	local unlockHelp2Count = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP2)
	local unlockHelp3Count = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP3)
	local unlockSoulCount = self._arrangement:getSoulSpiritUnlock(remote.teamManager.TEAM_INDEX_MAIN)
	local unlockAlternateCount = self._arrangement:getAlternateUnlock(remote.teamManager.TEAM_INDEX_MAIN)
	local unlockGodarmCount = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_GODARM)

	local emptyCount = 0
	local emptySoulCount = 0
	local emptyGodarmCount = 0
	local mainCount = 0
	local help1Count = 0
	local help2Count = 0
	local help3Count = 0
	local soulCount = 0
	local mountCount = 0
	local godarmCount = 0
	local alternateCount = 0
	for _,v in pairs(self._heroList) do
		if v.index == 0 then
			emptyCount = emptyCount + 1
		elseif v.index == remote.teamManager.TEAM_INDEX_MAIN and v.trialNum == self._trialNum then
			if v.isAlternate then
				alternateCount = alternateCount + 1
			else
				mainCount = mainCount + 1
			end
		elseif v.index == remote.teamManager.TEAM_INDEX_HELP and v.trialNum == self._trialNum then
			help1Count = help1Count + 1
		elseif v.index == remote.teamManager.TEAM_INDEX_HELP2 and v.trialNum == self._trialNum then
			help2Count = help2Count + 1
		elseif v.index == remote.teamManager.TEAM_INDEX_HELP3 and v.trialNum == self._trialNum then
			help3Count = help3Count + 1
		end
	end
	for k, v in pairs(self._soulSpiritList) do
		if v.index == 0 then
			emptySoulCount = emptySoulCount + 1
		elseif v.index == remote.teamManager.TEAM_INDEX_MAIN and v.trialNum == self._trialNum then
			soulCount = soulCount + 1
		end
	end
	for k, v in pairs(self._mountList) do
		if v.index == remote.teamManager.TEAM_INDEX_MAIN  and v.trialNum == self._trialNum then
			mountCount = mountCount + 1
		end
	end

	for k,v in pairs(self._godarmList) do
		if v.index ~= remote.teamManager.TEAM_INDEX_GODARM and v.trialNum == self._trialNum then
			emptyGodarmCount = emptyGodarmCount + 1
		else
			godarmCount = godarmCount + 1
		end
	end

	self._ccbOwner.tip_main:setVisible((emptyCount > 0 and unlockMainCount > mainCount) or (emptySoulCount > 0 and unlockSoulCount > soulCount) or (mountCount < mainCount))
	self._ccbOwner.tip_alternate:setVisible(emptyCount > 0 and unlockAlternateCount > alternateCount)
	self._ccbOwner.tip_helper1:setVisible(emptyCount > 0 and unlockHelp1Count > help1Count)
	self._ccbOwner.tip_helper2:setVisible(emptyCount > 0 and unlockHelp2Count > help2Count)
	self._ccbOwner.tip_helper3:setVisible(emptyCount > 0 and unlockHelp3Count > help3Count)
	self._ccbOwner.tip_godarm:setVisible(emptyGodarmCount > 0 and unlockGodarmCount > godarmCount)

	if self._selectTeamIndex == remote.teamManager.TEAM_INDEX_MAIN then
		self._ccbOwner.tip_main:setVisible(false)
	end
end

function QUIWidgetMockBattleArray:_updateWidget(hero)
	for _,info in ipairs(self._items) do
		if info.data.actorId == hero.actorId and info.data.actorId ~= nil  then
			info.data.index = hero.index
			info.data.additionalHpMax = hero.additionalHpMax
			info.data.trialNum = hero.trialNum
			break
		end
	end
	if self._listViewLayout then
		self._listViewLayout:refreshData()
	end
end

function QUIWidgetMockBattleArray:_updateSoulWidget(soulSpirit)
	for _,v in ipairs(self._items) do
		if v.data.soulSpiritId == soulSpirit.soulSpiritId and v.data.soulSpiritId ~= nil   then
			v.data.index = soulSpirit.index
			v.data.trialNum = soulSpirit.trialNum
			break
		end
	end

	if self._listViewLayout then
		self._listViewLayout:refreshData()
	end
end


function QUIWidgetMockBattleArray:_updateMountWidget(mount)
	for _,v in ipairs(self._items) do
		if v.data.mountId == mount.mountId  and v.data.mountId ~= nil   then
			v.data.index = mount.index
			v.data.pos = mount.pos
			v.data.trialNum = mount.trialNum
			break
		end
	end

	if self._listViewLayout then
		self._listViewLayout:refreshData()
	end
end

function QUIWidgetMockBattleArray:_updateGodarmWidget(godarmInfo)
	for _,v in ipairs(self._items) do
		if v.data.godarmId == godarmInfo.godarmId and v.data.godarmId ~= nil   then
			v.data.index = godarmInfo.index
			v.data.trialNum = godarmInfo.trialNum
			v.data.pos = godarmInfo.pos
			break
		end
	end

	if self._listViewLayout then
		self._listViewLayout:refreshData()
	end
end


function QUIWidgetMockBattleArray:selectButton(btnType)
	self._currentButtonName = btnType
	if self._selectTeamIndex == remote.teamManager.TEAM_INDEX_GODARM then -- 点击左侧按钮是 若为神器界面 则切换到主战魂师上阵界面
		self:updateTab(remote.teamManager.TEAM_INDEX_MAIN)
	end


	for k, v in ipairs(self._buttonList) do
		if v.name == self._currentButtonName then
			self._selectConfig = v
			break
		end
	end
end

function QUIWidgetMockBattleArray:_onTriggerHero(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "btn_hero" then
    		self._ccbOwner.btn_hero:setHighlighted(true)
    	end
    else
    	app.sound:playSound("common_menu")
    	self:selectButton("btn_hero")
	    self:_updatePage()
	end
end

function QUIWidgetMockBattleArray:_onTriggerMount(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "btn_mount" then
    		self._ccbOwner.btn_mount:setHighlighted(true)
    	end
    else
    	if self._currentButtonName ~= "btn_mount" then
			app.sound:playSound("common_menu")
	    	self:selectButton("btn_mount")
		    self:_updatePage()
    	end
		--self:onTriggerMain()

	end
end

function QUIWidgetMockBattleArray:_onTriggerSoul(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside and tonumber(eventType) ~= QUIWidgetMockBattleArray.SPECIAL_TYPE then
    	if self._currentButtonName == "btn_soul" then
    		self._ccbOwner.btn_soul:setHighlighted(true)
    	end
    else
    	app.sound:playSound("common_menu")
    	self:selectButton("btn_soul") 
	    self:_updatePage()
	end
end


function QUIWidgetMockBattleArray:handlerSoulAndMount(toMount,toSoul)
	if not toMount and toSoul and self._currentButtonName == "btn_mount" then
		self:_onTriggerSoul(CCControlEventTouchUpInside)
	elseif not toSoul and toMount and self._currentButtonName == "btn_soul" then
		self:_onTriggerMount(CCControlEventTouchUpInside)
	elseif self._currentButtonName ~= "btn_mount" and self._currentButtonName ~= "btn_soul" then
		if toSoul then
			self:_onTriggerSoul(CCControlEventTouchUpInside)
		elseif toMount then
			self:_onTriggerMount(CCControlEventTouchUpInside)
		end
	end
end


function QUIWidgetMockBattleArray:handlerTag(_selectIdx , _toMain,_toHelp,_toSoul,_toMount,_toGodarm)

	local btnTableMark = {}
	table.insert(btnTableMark , {btnName = "btn_hero" ,selectIdx = remote.teamManager.TEAM_INDEX_MAIN , boolValue = _toMain})
	table.insert(btnTableMark , {btnName = "btn_soul" ,selectIdx = remote.teamManager.TEAM_INDEX_MAIN , boolValue = _toSoul})
	table.insert(btnTableMark , {btnName = "btn_mount" ,selectIdx = remote.teamManager.TEAM_INDEX_MAIN , boolValue = _toMount})
	table.insert(btnTableMark , {btnName = "btn_hero" ,selectIdx = remote.teamManager.TEAM_INDEX_HELP , boolValue = _toHelp})
	table.insert(btnTableMark , {btnName = nil , selectIdx = remote.teamManager.TEAM_INDEX_GODARM , boolValue = _toGodarm})

	QPrintTable(btnTableMark)

	for i,v in ipairs(btnTableMark) do
		local btnBool = true
		if v.btnName~=nil then
			btnBool =  v.btnName == self._currentButtonName
		end
		if  btnBool and tonumber(_selectIdx) == tonumber(v.selectIdx) then
			if v.boolValue then
				return
			end
		end
	end

	for k,value in ipairs(btnTableMark) do
		if value.boolValue then
			app.sound:playSound("common_menu")
			if value.btnName ~= nil then
				self:selectButton(value.btnName) 
			end
			if tonumber(_selectIdx) == tonumber(value.selectIdx) then
				self:_updatePage()
			else
				self:updateTab(value.selectIdx)
				self:_updatePage()
			end
			return
		end
	end
	if _selectIdx ~=remote.teamManager.TEAM_INDEX_MAIN then
		self:onTriggerMain()
	end
end


function QUIWidgetMockBattleArray:updateTab(teamIndex, isAlternate)
	local oldSelectTeamIndex = self._selectTeamIndex
	isAlternate = isAlternate or false
	if self._selectTeamIndex == teamIndex and self._selectIsAlternate == isAlternate then
		return
	end

	self._selectTeamIndex = teamIndex
	self._selectIsAlternate = isAlternate
	self:dispatchEvent({name = QUIWidgetMockBattleArray.EVENT_SELECT_TAB, index = self._selectTeamIndex, isAlternate = isAlternate})
	self:_updateSelectedNum()
	self:resetButtons()
	if teamIndex == remote.teamManager.TEAM_INDEX_MAIN then
		if isAlternate then
			self._ccbOwner.btn_alternate:setEnabled(false)
			self._ccbOwner.btn_alternate:setHighlighted(true)
		else
			self._ccbOwner.btn_main:setEnabled(false)
			self._ccbOwner.btn_main:setHighlighted(true)
		end
	elseif teamIndex == remote.teamManager.TEAM_INDEX_HELP then
		self._ccbOwner.btn_helper:setEnabled(false)
		self._ccbOwner.btn_helper:setHighlighted(true)
		self._ccbOwner.btn_helper1:setEnabled(false)
		self._ccbOwner.btn_helper1:setHighlighted(true)
	elseif teamIndex == remote.teamManager.TEAM_INDEX_HELP2 then
		self._ccbOwner.btn_helper2:setEnabled(false)
		self._ccbOwner.btn_helper2:setHighlighted(true)
	elseif teamIndex == remote.teamManager.TEAM_INDEX_HELP3 then
		self._ccbOwner.btn_helper3:setEnabled(false)
		self._ccbOwner.btn_helper3:setHighlighted(true)
	elseif teamIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._ccbOwner.btn_godarm:setEnabled(false)
		self._ccbOwner.btn_godarm:setHighlighted(true)	
		self._currentButtonName = "godarm"
		self:_updateGodarmInfo()
		self:_checkTips()
		return
	end
	
	if self._currentButtonName == "btn_soul" or self._currentButtonName == "btn_mount" or self._currentButtonName == "godarm" then
    	self:selectButton("btn_hero")
		self._selectConfig.updateFun()
    elseif oldSelectTeamIndex ~= 0 then
		self._selectConfig.updateFun(nil, {})
	else
		self._selectConfig.updateFun()
	end
	self:_checkTips()
end

function QUIWidgetMockBattleArray:setNullTempPosition()
	self._temp_pos = nil
end

function QUIWidgetMockBattleArray:getTempPosition()
	return self._temp_pos
end


function QUIWidgetMockBattleArray:resetButtons()
	self._ccbOwner.btn_main:setEnabled(true)
	self._ccbOwner.btn_main:setHighlighted(false)
	self._ccbOwner.btn_alternate:setEnabled(true)
	self._ccbOwner.btn_alternate:setHighlighted(false)
	self._ccbOwner.btn_helper:setEnabled(true)
	self._ccbOwner.btn_helper:setHighlighted(false)
	self._ccbOwner.btn_helper1:setEnabled(true)
	self._ccbOwner.btn_helper1:setHighlighted(false)
	self._ccbOwner.btn_helper2:setEnabled(true)
	self._ccbOwner.btn_helper2:setHighlighted(false)
	self._ccbOwner.btn_helper3:setEnabled(true)
	self._ccbOwner.btn_helper3:setHighlighted(false)
	self._ccbOwner.btn_godarm:setEnabled(true)
	self._ccbOwner.btn_godarm:setHighlighted(false)
end

function QUIWidgetMockBattleArray:onTriggerHelper()
	app.sound:playSound("common_menu")
	self:updateTab(remote.teamManager.TEAM_INDEX_HELP)
end

function QUIWidgetMockBattleArray:onTriggerHelper2()
	app.sound:playSound("common_menu")
	self:updateTab(remote.teamManager.TEAM_INDEX_HELP2)
end

function QUIWidgetMockBattleArray:onTriggerHelper3()
	app.sound:playSound("common_menu")
	self:updateTab(remote.teamManager.TEAM_INDEX_HELP3)
end

function QUIWidgetMockBattleArray:onTriggerMain()
	app.sound:playSound("common_menu")
	self:updateTab(remote.teamManager.TEAM_INDEX_MAIN)
end

function QUIWidgetMockBattleArray:onTriggerGodarm( )
	app.sound:playSound("common_menu")
	self:updateTab(remote.teamManager.TEAM_INDEX_GODARM)
end

function QUIWidgetMockBattleArray:onTriggerAlternate()
	app.sound:playSound("common_menu")
	self:updateTab(remote.teamManager.TEAM_INDEX_MAIN, true)
end

function QUIWidgetMockBattleArray:_onTriggerLeft( ... )
	if self._listViewLayout then
		self._listViewLayout:startScrollToPosScheduler(self._width*0.8, 0.8, false, nil, true)
	end
end

function QUIWidgetMockBattleArray:_onTriggerRight( ... )
	if self._listViewLayout then
		self._listViewLayout:startScrollToPosScheduler(-self._width*0.8, 0.8, false, nil, true)
	end
end

return QUIWidgetMockBattleArray
