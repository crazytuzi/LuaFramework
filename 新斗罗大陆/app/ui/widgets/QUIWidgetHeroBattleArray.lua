
local QUIWidget = import(".QUIWidget")
local QUIWidgetHeroBattleArray = class("QUIWidgetHeroBattleArray", QUIWidget)

-- local QScrollView = import("...views.QScrollView")
local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroSmallFrame = import(".QUIWidgetHeroSmallFrame")
local QUIWidgetHeroSmallFrameHasState = import(".QUIWidgetHeroSmallFrameHasState")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIWidgetHeroBattleArray.EVENT_SELECT_TAB = "EVENT_SELECT_TAB"

QUIWidgetHeroBattleArray.MARGIN = 0
QUIWidgetHeroBattleArray.GAP = 0
QUIWidgetHeroBattleArray.HERO_CHANGED = "HERO_CHANGED"
QUIWidgetHeroBattleArray.HERO_FULL = "魂师已满"
QUIWidgetHeroBattleArray.SOUL_FULL = "魂灵已满"
QUIWidgetHeroBattleArray.GODARM_FULL = "神器已满"
QUIWidgetHeroBattleArray.GODARM_SAME_FULL = "同类型神器只能同时上两个"

function QUIWidgetHeroBattleArray:ctor(options)
	local ccbFile = "ccb/Widget_HeroBattleArray.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerAll", callback = handler(self, self._onTriggerAll)},
		{ccbCallbackName = "onTriggerTank", callback = handler(self, self._onTriggerTank)},
		{ccbCallbackName = "onTriggerHeal", callback = handler(self, self._onTriggerHeal)},
		{ccbCallbackName = "onTriggerAttack", callback = handler(self, self._onTriggerAttack)},
		{ccbCallbackName = "onTriggerPAttack", callback = handler(self, self._onTriggerPAttack)},
		{ccbCallbackName = "onTriggerMAttack", callback = handler(self, self._onTriggerMAttack)},
		{ccbCallbackName = "onTriggerSoul", callback = handler(self, self._onTriggerSoul)},
		{ccbCallbackName = "onTriggerHelper", callback = handler(self, self.onTriggerHelper)},
		{ccbCallbackName = "onTriggerHelper2", callback = handler(self, self.onTriggerHelper2)},
		{ccbCallbackName = "onTriggerHelper3", callback = handler(self, self.onTriggerHelper3)},
		{ccbCallbackName = "onTriggerGodarm", callback = handler(self, self.onTriggerGodarm)},
		{ccbCallbackName = "onTriggerMain", callback = handler(self, self.onTriggerMain)},
		{ccbCallbackName = "onTriggerAlternate", callback = handler(self, self.onTriggerAlternate)},
	}
	QUIWidgetHeroBattleArray.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._state = options.state
    self._ccbOwner.tips:setString(options.tips or "")
	self._width = self._ccbOwner.sheet_layout:getContentSize().width
	self._items = {}

	self._isInherit = options.isInherit or false
	self._isEquilibrium = options.isEquilibrium or false

	self._selectConfig = nil
    self._heroList = options.heroList
    self._soulSpiritList = options.soulSpiritList or {}
    self._alternateList = options.alternateList or {}
    self._arrangement = options.arrangement
    self._isStromArena = options.isStromArena or false
    self._isAlternate = options.isAlternate or false
    self._godarmList = options.godarmList or {}

	for k, v in pairs(self._heroList) do
		v.isAlternate = v.isAlternate or false
	end

    self._buttonList = {
    	{name = "all", ccb = self._ccbOwner.all, condition = function (x) return true end, updateFun = handler(self, self._updateHero)},
    	{name = "tank", ccb = self._ccbOwner.tank, condition = function (x) return x == 't' end, updateFun = handler(self, self._updateHero)},
    	{name = "heal", ccb = self._ccbOwner.heal, condition = function (x) return x == 'h' end, updateFun = handler(self, self._updateHero)},
    	{name = "attack", ccb = self._ccbOwner.attack, condition = function (x) return x == 'pd' or x == 'md' end, updateFun = handler(self, self._updateHero)},
    	{name = "pAttack", ccb = self._ccbOwner.pAttack, condition = function (x) return x == 'pd' end, updateFun = handler(self, self._updateHero)},
    	{name = "mAttack", ccb = self._ccbOwner.mAttack, condition = function (x) return x == 'md' end, updateFun = handler(self, self._updateHero)},
    	{name = "soul", ccb = self._ccbOwner.soul, condition = function (x) return false end, updateFun = handler(self, self._updateSoulSpirit)},
	}
	self._currentButtonName = self._buttonList[1].name	
	self._unlockNumber = options and (options.unlockNumber or 4) or 4
	self._selectedNumber = 0
	self._selectTeamIndex = 0
	self._selectIsAlternate = false
	
	self._additionalMaxHp = {}
	self._ccbOwner.btn_helper:setVisible(false)
	self._ccbOwner.node_alternate:setVisible(false)

	local soulUnlock = app.unlock:checkLock("UNLOCK_SOUL_SPIRIT")
	self._ccbOwner.attack:setVisible(soulUnlock)
	self._ccbOwner.pAttack:setVisible(not soulUnlock)
	self._ccbOwner.mAttack:setVisible(not soulUnlock)
	self._ccbOwner.soul:setVisible(soulUnlock)

	if remote.godarm:checkGodArmUnlock() then
		self._ccbOwner.node_godarm:setVisible(true)
	else
		self._ccbOwner.node_godarm:setVisible(false)
	end
end

function QUIWidgetHeroBattleArray:onEnter()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSmallFrame.EVENT_HERO_FRAMES_CLICK, self._onIconClick, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSmallFrame.EVENT_SOUL_FRAMES_CLICK, self._onSoulIconClick, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSmallFrame.EVENT_GODARM_FRAMES_CLICK, self._onGodarmIconClick, self)

    self._ccbOwner.node_btn:setVisible(app.unlock:getUnlockHelperDisplay())


    if app.unlock:getUnlockTeamHelp4() then
    	self._ccbOwner.btn_helper:setVisible(false)
    	self._ccbOwner.btn_helper1:setVisible(true)
    else
    	self._ccbOwner.btn_helper:setVisible(true)
    	self._ccbOwner.btn_helper1:setVisible(false)
    end

    local isUnlock = app.unlock:getUnlockHelper()
	self._ccbOwner.node_helper:setVisible(isUnlock)
	self._ccbOwner.helperLock1:setVisible(not isUnlock)
	self._ccbOwner.helperLock2:setVisible(false)
	self._ccbOwner.helperLock3:setVisible(false)

	if app.unlock:getUnlockTeamHelp4() then
		if app.unlock:getUnlockTeamHelp5() == false then
			self._ccbOwner.helperLock2:setVisible(true)
		end
		self._ccbOwner.node_helper2:setVisible(true)
	else
		self._ccbOwner.node_helper2:setVisible(false)
	end
	if app.unlock:getUnlockTeamHelp8() then
		if app.unlock:getUnlockTeamHelp9() == false then
			self._ccbOwner.helperLock3:setVisible(true)
		end
		self._ccbOwner.node_helper3:setVisible(true)
	else
		self._ccbOwner.node_helper3:setVisible(false)
	end

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
	if app.unlock:getUnlockGodarm(false) then
		if self._isAlternate then
			if not self._ccbOwner.node_helper2:isVisible() then
				self._ccbOwner.node_godarm:setPositionX(self._ccbOwner.node_helper2:getPositionX())
			end			
		else
			if not self._ccbOwner.node_helper3:isVisible() then
				self._ccbOwner.node_godarm:setPositionX(self._ccbOwner.node_helper3:getPositionX())
			end
		end
	end

	self:selectButton("all")
	self._schdulerHandler = scheduler.performWithDelayGlobal(function ( ... )
    	self._schdulerHandler = nil
		self:onTriggerMain()
    end, 0)
end

function QUIWidgetHeroBattleArray:initListView( ... )
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._items[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	if not self._state then
            			item = QUIWidgetHeroSmallFrame.new()
            		else
            			item = QUIWidgetHeroSmallFrameHasState.new()
            		end
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            item:initGLLayer()
	            info.item = item
	            info.size = item:getContentSize()
	            info.tag = itemData.oType
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
	else
		self._listViewLayout:reload({totalNumber = #self._items})
	end
end

function QUIWidgetHeroBattleArray:runTo(actorId, callback)
	if self._listViewLayout then
		for i, value in ipairs(self._items) do
			if value.data.actorId == actorId or value.data.soulSpiritId == actorId then
				self._listViewLayout:startScrollToIndex(i, nil, 50, callback);
				return
			end
		end
	end
end

function QUIWidgetHeroBattleArray:getIndexByHeroId(actorId)
	for i, value in ipairs(self._items) do
		if value.data.actorId == actorId then
			return i
		end
	end
	return nil
end

function QUIWidgetHeroBattleArray:onExit()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSmallFrame.EVENT_HERO_FRAMES_CLICK, self._onIconClick, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSmallFrame.EVENT_SOUL_FRAMES_CLICK, self._onSoulIconClick, self)
  	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSmallFrame.EVENT_GODARM_FRAMES_CLICK, self._onGodarmIconClick, self)
    if self._schdulerHandler ~= nil then
    	scheduler.unscheduleGlobal(self._schdulerHandler)
    	self._schdulerHandler = nil
    end
end

function QUIWidgetHeroBattleArray:updateHeroByTeams()
end

function QUIWidgetHeroBattleArray:getHeroList()
	local heroList = {}
	for k, v in pairs(self._heroList) do
		if v.index == self._selectTeamIndex then
			table.insert(heroList, v)
		end
	end
	return heroList
end

function QUIWidgetHeroBattleArray:getSoulSpiritList()
	local heroList = {}
	for k, v in pairs(self._soulSpiritList) do
		if v.index == self._selectTeamIndex then
			table.insert(heroList, v)
		end
	end
	return heroList
end

function QUIWidgetHeroBattleArray:removeSelectedHero(id)
	local hero = nil
	for k, v in pairs(self._heroList) do
		if v.actorId == id then
			if v.isAlternate then
				remote.teamManager:updateHeroOrder(1, id, false)
			end
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

function QUIWidgetHeroBattleArray:removeSelectedSoulSpirit(id)
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

function QUIWidgetHeroBattleArray:removeSelectedGodarm(id)
	local godarmSprit = nil
	local pos = 1
	for k, v in pairs(self._godarmList) do
		if v.godarmId == id then
			v.index = 0
			pos = v.pos
			v.pos = 5
			godarmSprit = v
			break
		end
	end
	for k, v in pairs(self._godarmList) do
		if v.pos and v.pos > pos and v.pos < 5 and v.pos > 1 then
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

function QUIWidgetHeroBattleArray:setUnlockNumber(value)
	self._unlockNumber = value
end

function QUIWidgetHeroBattleArray:getSelectIndex()
	return self._selectTeamIndex
end

function QUIWidgetHeroBattleArray:getSelectIsAlternate()
	return self._selectIsAlternate
end

-- 不包括替补
function QUIWidgetHeroBattleArray:getSelectTeam()
	local tbl = {}
	for _, value in pairs(self._heroList) do
		if value.index ~= 0 and not value.isAlternate then
			if tbl[value.index] == nil then tbl[value.index] = {} end
			table.insert(tbl[value.index], value.actorId)
		end
	end
	return tbl
end

-- 主力阵容包括替补
function QUIWidgetHeroBattleArray:getSelectMainTeam()
	local tbl = {}
	for _, value in pairs(self._heroList) do
		if value.index == 1 then
			table.insert(tbl, value.actorId)
		end
	end
	return tbl
end
-- 主力阵容不包括替补
function QUIWidgetHeroBattleArray:getSelectPureMainTeam()
	local tbl = {}
	for _, value in pairs(self._heroList) do
		if value.index == 1 and not value.isAlternate then
			table.insert(tbl, value.actorId)
		end
	end
	return tbl
end

function QUIWidgetHeroBattleArray:getSelectAlternateTeam()
	local tbl = {}
	for _, value in pairs(self._heroList) do
		if value.index ~= 0 and value.isAlternate then
			table.insert(tbl, value.actorId)
		end
	end
	return tbl
end

--获取精灵的战队
function QUIWidgetHeroBattleArray:getSelectSoulSpirit()
	local tbl = {}
	for _,v in pairs(self._soulSpiritList) do
		if v.index ~= 0 then
			table.insert(tbl, v.soulSpiritId)
		end
	end
	return tbl
end

--获取神器的Id
function QUIWidgetHeroBattleArray:getSelectGodarmList()
	local tbl = {}

	local godarmList = clone(self._godarmList)

	table.sort( godarmList, function( a,b )
		if a.pos ~= b.pos then
			return a.pos > b.pos
		end
	end)	
	for _,v in pairs(godarmList) do
		if v.index == 5 then
			print("神器的位置-----v.pos",v.pos)
			table.insert(tbl, v.godarmId)
		end
	end
	return tbl
end

--获取神器info
function QUIWidgetHeroBattleArray:getSelectGodarmListInfo()
	local tbl = {}

	local godarmList = clone(self._godarmList)

	table.sort( godarmList, function( a,b )
		if a.pos ~= b.pos then
			return a.pos > b.pos
		end
	end)	
	for _,v in pairs(godarmList) do
		if v.index == 5 then
			table.insert(tbl, v)
		end
	end
	return tbl
end

function QUIWidgetHeroBattleArray:_updatePage()
	if self._selectConfig ~= nil then
		self:_showArray(self._selectConfig.condition)
	end

	self:_updateButtonStatus()
end

function QUIWidgetHeroBattleArray:_updateButtonStatus()
	for k, v in ipairs(self._buttonList) do
		if v.name == self._currentButtonName then
			v.ccb:setHighlighted(true)
		else
			v.ccb:setHighlighted(false)
		end
	end
end 


--by:Kumo  new sort 星级（降序） > 战斗力（降序） > ID（升序）  
function QUIWidgetHeroBattleArray:_sortHero(a,b)
	local heroA
	local heroB
	if type(a) == "table" and type(b) == "table" then
		heroA = a
		heroB = b
	else
		heroA = remote.herosUtil:getHeroByID(a)
		heroB = remote.herosUtil:getHeroByID(b)
	end
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

	local modelA = nil
	if self._isNeedCreatModel == true then
		modelA = app:createHeroWithoutCache(heroA)
	else
		modelA = remote.herosUtil:createHeroProp(heroA)
	end
	local modelB = nil
	if self._isNeedCreatModel == true then
		modelB = app:createHeroWithoutCache(heroB)
	else
		modelB = remote.herosUtil:createHeroProp(heroB)
	end

	local attackA = modelA:getBattleForce()
	local attackB = modelB:getBattleForce()

	if attackA ~= attackB then
		return attackA < attackB
	end

	return heroA.actorId > heroB.actorId
end

function QUIWidgetHeroBattleArray:_showArray(condition)
	if self._currentButtonName == "soul" then --走精灵模块
		self._items = {}
		local soulSpiritList = clone(self._soulSpiritList)
		for k, v in pairs(soulSpiritList) do
			table.insert(self._items, {oType = "soul", data = v})
		end
		table.sort(self._items, function (a,b)
			local characherA = db:getCharacterByID(a.data.soulSpiritId)
			local characherB = db:getCharacterByID(b.data.soulSpiritId)
			local soulSpiritInfoA = remote.soulSpirit:getMySoulSpiritInfoById(a.data.soulSpiritId)
			local soulSpiritInfoB = remote.soulSpirit:getMySoulSpiritInfoById(b.data.soulSpiritId)
			if characherA.aptitude ~= characherB.aptitude then
				return characherA.aptitude > characherB.aptitude
			elseif soulSpiritInfoA.grade ~= soulSpiritInfoB.grade then
				return soulSpiritInfoA.grade > soulSpiritInfoB.grade
			elseif soulSpiritInfoA.level ~= soulSpiritInfoB.level then
				return soulSpiritInfoA.level > soulSpiritInfoB.level
			else
				return a.data.soulSpiritId > b.data.soulSpiritId
			end
		end)
	elseif self._currentButtonName == "godarm" then --神器上阵
		self._items = {}
		for k, v in pairs(self._godarmList) do
			table.insert(self._items, {oType = "godarm", data = v})
		end
		table.sort(self._items, function (a,b)
			local characherA = db:getCharacterByID(a.data.godarmId)
			local characherB = db:getCharacterByID(b.data.godarmId)
			local godarmA = remote.godarm:getGodarmById(a.data.godarmId)
			local godarmB = remote.godarm:getGodarmById(b.data.godarmId)			
			if characherA.aptitude ~= characherB.aptitude then
				return characherA.aptitude > characherB.aptitude
			elseif godarmA.grade ~= godarmB.grade then
				return godarmA.grade > godarmB.grade
			elseif godarmA.level ~= godarmB.level then
				return godarmA.level > godarmB.level
			else
				return a.data.godarmId > b.data.godarmId
			end
		end)		
	else
		local allHero = {}
		self._items = {}
		self._displayHero = {}
		for k, v in pairs(self._heroList) do
			if condition(v.type) then
				table.insert(allHero, v.actorId)
			end
		end
		table.sort(allHero, handler(self, self._sortHero))

		for i = #allHero, 1, -1 do 
			local v = self._heroList[allHero[i]]
			v.additionalHpMax = self._additionalMaxHp[v.actorId] or 0
			table.insert(self._items, {oType = "hero", data = v})
		end

		-- self:initInhertOrEquilibriumForce()
	end
	self:initListView()
end

function QUIWidgetHeroBattleArray:updateHeroSmallFrameForce(force)
	for _,actorInfo in pairs(self._items) do
		if self._isEquilibrium and actorInfo.data.index == 1 then
			actorInfo.data.junhengforce = force
		elseif self._isInherit and actorInfo.data.index == 1 and actorInfo.data.isAlternate then
			actorInfo.data.inheritforce = force
		else
			actorInfo.data.junhengforce = 0
			actorInfo.data.inheritforce = 0
		end
	end
	-- self:initListView()
	if self._listViewLayout then
		self._listViewLayout:refreshData()
	end
end

function QUIWidgetHeroBattleArray:_onIconClick(event)
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
					app.tip:floatTip(QUIWidgetHeroBattleArray.HERO_FULL) 
					return
				end
				victoryId = v.actorId
				v.index = self._selectTeamIndex
				v.isAlternate = self._selectIsAlternate
				if self._selectIsAlternate then
					remote.teamManager:updateHeroOrder(1, v.actorId, true)
				end
			else
				if v.isAlternate then
					remote.teamManager:updateHeroOrder(1, v.actorId, false)
				end
				v.index = 0
				v.isAlternate = false
			end
			hero = v
			break
		end
	end

	self:_updateHero(victoryId, hero)
	self:_checkTips()
end

function QUIWidgetHeroBattleArray:_onSoulIconClick(event)
	local victoryId = nil
	local hero = nil
	local selectIndex = self:getSelectIndex()
	local currentSelect = 0
	for k, v in pairs(self._soulSpiritList) do
		if v.index == selectIndex  then
			currentSelect = currentSelect + 1
		end
	end
	for k, v in pairs(self._soulSpiritList) do
		if v.soulSpiritId == event.soulSpiritId then
			if v.index == 0 then
				local teamKey = self._arrangement:getTeamKey()
				local teamVO = remote.teamManager:getTeamByKey(teamKey)
				if currentSelect >= teamVO:getSpiritsMaxCountByIndex(selectIndex) then
					app.tip:floatTip(QUIWidgetHeroBattleArray.SOUL_FULL) 
					return
				end
				victoryId = v.soulSpiritId
				v.index = self._selectTeamIndex
			else
				v.index = 0
			end
			hero = v
			break
		end
	end

	self:_updateSoulSpirit(victoryId, hero)
	self:_checkTips()
end

function QUIWidgetHeroBattleArray:_onGodarmIconClick( event )
	local victoryId = nil
	local hero = nil
	local selectIndex = self:getSelectIndex()
	local characherCOnfig  = db:getCharacterByID(event.godarmId)

	local currentSelect = 0
	local samelabelNum = 0
	for k, v in pairs(self._godarmList) do
		if v.index == selectIndex  then
			local curtentConfig  = db:getCharacterByID(v.godarmId)
			currentSelect = currentSelect + 1
			if characherCOnfig.label ~= nil and characherCOnfig.label == curtentConfig.label then
				samelabelNum = samelabelNum + 1
			end	
		end
	end
	local sortPos = function( pos)
		for k, v in pairs(self._godarmList) do
			if v.pos and v.pos > pos and v.pos ~= 5 then
				v.pos = v.pos - 1
			end
		end
	end
	for k, v in pairs(self._godarmList) do
		if v.godarmId == event.godarmId then
			if v.index == 0 then
				local teamKey = self._arrangement:getTeamKey()
				local teamVO = remote.teamManager:getTeamByKey(teamKey)
				print("currentSelect= selectIndex=",currentSelect,selectIndex)
				if currentSelect >= teamVO:getHerosMaxCountByIndex(selectIndex) then
					app.tip:floatTip(QUIWidgetHeroBattleArray.GODARM_FULL) 
					return
				end
				if samelabelNum >= 2 then
					app.tip:floatTip(QUIWidgetHeroBattleArray.GODARM_SAME_FULL) 
					return
				end
				victoryId = v.godarmId
				v.index = self._selectTeamIndex
				v.pos = currentSelect + 1
			else
				v.index = 0	
				sortPos(v.pos)	
				v.pos = 5
			end
			hero = v
			break
		end
	end

	self:_updateGodarmInfo(victoryId, hero)
	self:_checkTips()
end
function QUIWidgetHeroBattleArray:getHeroHpMp(actorId, additionalHpMax)
	local hp = 0
	local mp = 0
	local heroProp = remote.herosUtil:createHeroPropById(actorId)
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

function QUIWidgetHeroBattleArray:_updateHero(victoryId, hero)
	self._selectedNumber = 0
	local helperHpSum = 0
	
	for k, v in pairs(self._heroList) do
		if  v.index == remote.teamManager.TEAM_INDEX_HELP or 
			v.index == remote.teamManager.TEAM_INDEX_HELP2 or 
			v.index == remote.teamManager.TEAM_INDEX_HELP3 then
			local _, _, hp = self:getHeroHpMp(v.actorId)
			helperHpSum = helperHpSum + (hp or 0)
		end
	end
	for k, v in pairs(self._heroList) do
		if v.index == remote.teamManager.TEAM_INDEX_MAIN then
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId, helperHpSum / 4)
			v.additionalHpMax = helperHpSum / 4
			self._additionalMaxHp[v.actorId] = helperHpSum / 4
		else
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId)
			v.additionalHpMax = 0
			self._additionalMaxHp[v.actorId] = 0
		end
		if v.index == self._selectTeamIndex and v.isAlternate == self._selectIsAlternate then
			self._selectedNumber = self._selectedNumber + 1
		end
	end
	if hero then
		self:_updateWidget(hero)
	else
		self:_updatePage()  
	end
	self:notificationMainPage(victoryId)
end

--更新精灵
function QUIWidgetHeroBattleArray:_updateSoulSpirit(victoryId, soulSpirit)
	if soulSpirit then
		self:_updateSoulWidget(soulSpirit)
	else
		self:_updatePage()  
	end
	self:notificationMainPage(victoryId)
end

--更新神器
function QUIWidgetHeroBattleArray:_updateGodarmInfo(victoryId, godarmId)
	if godarmId then
		self:_updateGodarmWidget(godarmId)
	else
		self:_updatePage()  
	end
	self:notificationMainPage(victoryId,true)
end

function QUIWidgetHeroBattleArray:notificationMainPage(victoryId,isGodarmTab)
	local heroList = {}
	local soulSpiritList = {}
	local assistHeroList = {}
	local godarmList = {}
	local selectIndex = self:getSelectIndex()
	for k, v in pairs(self._heroList) do
		if v.index == selectIndex and v.isAlternate == self._selectIsAlternate then
			table.insert(heroList, v)
		elseif v.index == (selectIndex+1000) then
			table.insert(assistHeroList, v)
		end
	end
	for k, v in pairs(self._soulSpiritList) do
		if v.index == selectIndex then
			table.insert(soulSpiritList, v)
		end
	end
	for k,v in pairs(self._godarmList) do
		if v.index ~= 0 then
			table.insert(godarmList, v)
		end
	end
    self:dispatchEvent({name = QUIWidgetHeroBattleArray.HERO_CHANGED, hero = heroList, isGodarmTab = isGodarmTab,soulSpirits = soulSpiritList, assistHeroList = assistHeroList, godarmList = godarmList,victoryId = victoryId})
end

--检查是否有为上阵的
function QUIWidgetHeroBattleArray:_checkTips()
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
	local godarmCount = 0
	local alternateCount = 0
	for _,v in pairs(self._heroList) do
		if v.index == 0 then
			emptyCount = emptyCount + 1
		elseif v.index == remote.teamManager.TEAM_INDEX_MAIN then
			if v.isAlternate then
				alternateCount = alternateCount + 1
			else
				mainCount = mainCount + 1
			end
		elseif v.index == remote.teamManager.TEAM_INDEX_HELP then
			help1Count = help1Count + 1
		elseif v.index == remote.teamManager.TEAM_INDEX_HELP2 then
			help2Count = help2Count + 1
		elseif v.index == remote.teamManager.TEAM_INDEX_HELP3 then
			help3Count = help3Count + 1
		end
	end
	for k, v in pairs(self._soulSpiritList) do
		if v.index == 0 then
			emptySoulCount = emptySoulCount + 1
		elseif v.index == remote.teamManager.TEAM_INDEX_MAIN then
			soulCount = soulCount + 1
		end
	end

	for k,v in pairs(self._godarmList) do
		if v.index ~= remote.teamManager.TEAM_INDEX_GODARM then
			emptyGodarmCount = emptyGodarmCount + 1
		else
			godarmCount = godarmCount + 1
		end
	end

	self._ccbOwner.tip_main:setVisible((emptyCount > 0 and unlockMainCount > mainCount) or (emptySoulCount > 0 and unlockSoulCount > soulCount))
	self._ccbOwner.tip_alternate:setVisible(emptyCount > 0 and unlockAlternateCount > alternateCount)
	self._ccbOwner.tip_helper1:setVisible(emptyCount > 0 and unlockHelp1Count > help1Count)
	self._ccbOwner.tip_helper2:setVisible(emptyCount > 0 and unlockHelp2Count > help2Count)
	self._ccbOwner.tip_helper3:setVisible(emptyCount > 0 and unlockHelp3Count > help3Count)
	self._ccbOwner.tip_godarm:setVisible(emptyGodarmCount > 0 and unlockGodarmCount > godarmCount)

	if self._selectTeamIndex == remote.teamManager.TEAM_INDEX_MAIN then
		self._ccbOwner.tip_main:setVisible(false)
	end
end

function QUIWidgetHeroBattleArray:_updateWidget(hero)
	for _,info in ipairs(self._items) do
		if info.data.actorId == hero.actorId then
			info.data.index = hero.index
			info.data.additionalHpMax = hero.additionalHpMax
			break
		end
	end
	if self._listViewLayout then
		self._listViewLayout:refreshData()
	end
end

function QUIWidgetHeroBattleArray:_updateSoulWidget(soulSpirit)
	for _,v in ipairs(self._items) do
		if v.data.soulSpiritId == soulSpirit.soulSpiritId then
			v.data.index = soulSpirit.index
			break
		end
	end

	if self._listViewLayout then
		self._listViewLayout:refreshData()
	end
end

function QUIWidgetHeroBattleArray:_updateGodarmWidget(godarmInfo)
	for _,v in ipairs(self._items) do
		if v.data.godarmId == godarmInfo.godarmId then
			v.data.index = godarmInfo.index
			v.data.pos = godarmInfo.pos
			break
		end
	end

	if self._listViewLayout then
		self._listViewLayout:refreshData()
	end
end


function QUIWidgetHeroBattleArray:selectButton(btnType)
	self._currentButtonName = btnType
	for k, v in ipairs(self._buttonList) do
		if v.name == self._currentButtonName then
			self._selectConfig = v
			break
		end
	end
end

function QUIWidgetHeroBattleArray:_onTriggerAll(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "all" then
    		self._ccbOwner.all:setHighlighted(true)
    	end
    else
		if self._currentButtonName == "godarm" then
			self:onTriggerMain()
		end
    	app.sound:playSound("common_menu")
    	self:selectButton("all")
	    self:_updatePage()
	end
end

function QUIWidgetHeroBattleArray:_onTriggerTank(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "tank" then
    		self._ccbOwner.tank:setHighlighted(true)
    	end
    else
		if self._currentButtonName == "godarm" then
			self:onTriggerMain()
		end    	
    	app.sound:playSound("common_menu")
    	self:selectButton("tank")
	    self:_updatePage()
	end
end

function QUIWidgetHeroBattleArray:_onTriggerHeal(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "heal" then
    		self._ccbOwner.heal:setHighlighted(true)
    	end
    else
		if self._currentButtonName == "godarm" then
			self:onTriggerMain()
		end    	
    	app.sound:playSound("common_menu")
    	self:selectButton("heal")
	    self:_updatePage()
	end
end

function QUIWidgetHeroBattleArray:_onTriggerAttack(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "attack" then
    		self._ccbOwner.attack:setHighlighted(true)
    	end
    else
		if self._currentButtonName == "godarm" then
			self:onTriggerMain()
		end    	
    	app.sound:playSound("common_menu")
    	self:selectButton("attack")
	    self:_updatePage()
	end
end

function QUIWidgetHeroBattleArray:_onTriggerPAttack(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "pAttack" then
    		self._ccbOwner.pAttack:setHighlighted(true)
    	end
    else
		if self._currentButtonName == "godarm" then
			self:onTriggerMain()
		end    	
    	app.sound:playSound("common_menu")
    	self:selectButton("pAttack")
	    self:_updatePage()
	end
end

function QUIWidgetHeroBattleArray:_onTriggerMAttack(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "mAttack" then
    		self._ccbOwner.mAttack:setHighlighted(true)
    	end
    else
		if self._currentButtonName == "godarm" then
			self:onTriggerMain()
		end    	
    	app.sound:playSound("common_menu")
    	self:selectButton("mAttack")
	    self:_updatePage()
	end
end

function QUIWidgetHeroBattleArray:_onTriggerSoul(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "soul" then
    		self._ccbOwner.soul:setHighlighted(true)
    	end
    else
		if self._currentButtonName == "godarm" then
			self:onTriggerMain()
		end    	
    	app.sound:playSound("common_menu")
    	self:selectButton("soul") 
	    self:_updatePage()
	end
end

function QUIWidgetHeroBattleArray:updateTab(teamIndex, isAlternate)
	local oldSelectTeamIndex = self._selectTeamIndex
	isAlternate = isAlternate or false
	if self._selectTeamIndex == teamIndex and self._selectIsAlternate == isAlternate then
		return
	end
	print("更新列表--------teamIndex=",teamIndex)
	self._selectTeamIndex = teamIndex
	self._selectIsAlternate = isAlternate
	self:dispatchEvent({name = QUIWidgetHeroBattleArray.EVENT_SELECT_TAB, index = self._selectTeamIndex, isAlternate = isAlternate})

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
	
	print("self._currentButtonName=",self._currentButtonName,oldSelectTeamIndex)
	if self._currentButtonName == "soul" or self._currentButtonName == "godarm" then
    	self:selectButton("all")
		self._selectConfig.updateFun()
    elseif oldSelectTeamIndex ~= 0 then
		self._selectConfig.updateFun(nil, {})
	else
		self._selectConfig.updateFun()
	end
	self:_checkTips()
end

function QUIWidgetHeroBattleArray:resetButtons()
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

function QUIWidgetHeroBattleArray:onTriggerHelper()
	app.sound:playSound("common_menu")
	if app.unlock:getUnlockHelper(true, "战队%d级可上阵援助魂师") == false then
		return
	end
	self:updateTab(remote.teamManager.TEAM_INDEX_HELP)
end

function QUIWidgetHeroBattleArray:onTriggerHelper2()
	app.sound:playSound("common_menu")
	if app.unlock:getUnlockTeamHelp5(true, "%d级可以开启更多的援助位") == false then
		return
	end
	self:updateTab(remote.teamManager.TEAM_INDEX_HELP2)
end

function QUIWidgetHeroBattleArray:onTriggerHelper3()
	app.sound:playSound("common_menu")
	if app.unlock:getUnlockTeamHelp9(true, "%d级可以开启更多的援助位") == false then
		return
	end
	self:updateTab(remote.teamManager.TEAM_INDEX_HELP3)
end

function QUIWidgetHeroBattleArray:onTriggerGodarm( )
	app.sound:playSound("common_menu")
	if app.unlock:getUnlockGodarm(false) == false then
		return
	end
	self:updateTab(remote.teamManager.TEAM_INDEX_GODARM)
end

function QUIWidgetHeroBattleArray:onTriggerMain()
	app.sound:playSound("common_menu")

	self:updateTab(remote.teamManager.TEAM_INDEX_MAIN)
end

function QUIWidgetHeroBattleArray:onTriggerAlternate()
	app.sound:playSound("common_menu")

	self:updateTab(remote.teamManager.TEAM_INDEX_MAIN, true)
end

function QUIWidgetHeroBattleArray:_onTriggerLeft( ... )
	if self._listViewLayout then
		self._listViewLayout:startScrollToPosScheduler(self._width*0.8, 0.8, false, nil, true)
	end
end

function QUIWidgetHeroBattleArray:_onTriggerRight( ... )
	if self._listViewLayout then
		self._listViewLayout:startScrollToPosScheduler(-self._width*0.8, 0.8, false, nil, true)
	end
end

return QUIWidgetHeroBattleArray
