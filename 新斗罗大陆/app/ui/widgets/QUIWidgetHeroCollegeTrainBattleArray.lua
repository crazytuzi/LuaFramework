-- @Author: liaoxianbo
-- @Date:   2019-11-14 15:32:33
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-13 13:00:07
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroCollegeTrainBattleArray = class("QUIWidgetHeroCollegeTrainBattleArray", QUIWidget)

local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroSmallFrame = import(".QUIWidgetHeroSmallFrame")
local QUIWidgetHeroSmallFrameHasState = import(".QUIWidgetHeroSmallFrameHasState")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIWidgetHeroCollegeTrainBattleArray.EVENT_SELECT_TAB = "EVENT_SELECT_TAB"

QUIWidgetHeroCollegeTrainBattleArray.MARGIN = 0
QUIWidgetHeroCollegeTrainBattleArray.GAP = 0
QUIWidgetHeroCollegeTrainBattleArray.HERO_CHANGED = "HERO_CHANGED"
QUIWidgetHeroCollegeTrainBattleArray.HERO_FULL = "魂师已满"
QUIWidgetHeroCollegeTrainBattleArray.SOUL_FULL = "魂灵已满"

function QUIWidgetHeroCollegeTrainBattleArray:ctor(options)
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
		{ccbCallbackName = "onTriggerMain", callback = handler(self, self.onTriggerMain)},
		{ccbCallbackName = "onTriggerAlternate", callback = handler(self, self.onTriggerAlternate)},
	}
    QUIWidgetHeroCollegeTrainBattleArray.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._selectConfig = nil

	self._chapterId = options.chapterId
 	self._heroList = options.heroList

    self._soulSpiritList = options.soulSpiritList or {}

    self._ccbOwner.node_alternate:setVisible(false)

    self._chapterInfo = db:getCollegeTrainConfigById(self._chapterId)
    self._assisTanceNum = tonumber(self._chapterInfo.assistance_num_1) or 0
    self._soulSpiritNum = tonumber(self._chapterInfo.soul_sprite_1) or 0

	self._width = self._ccbOwner.sheet_layout:getContentSize().width

    self._buttonList = {
    	{name = "all", ccb = self._ccbOwner.all, condition = function (x) return true end, updateFun = handler(self, self._updateHero)},
    	{name = "tank", ccb = self._ccbOwner.tank, condition = function (x) return x == 't' end, updateFun = handler(self, self._updateHero)},
    	{name = "heal", ccb = self._ccbOwner.heal, condition = function (x) return x == 'h' end, updateFun = handler(self, self._updateHero)},
    	{name = "attack", ccb = self._ccbOwner.attack, condition = function (x) return x == 'pd' or x == 'md' end, updateFun = handler(self, self._updateHero)},
    	{name = "pAttack", ccb = self._ccbOwner.pAttack, condition = function (x) return x == 'pd' end, updateFun = handler(self, self._updateHero)},
    	{name = "mAttack", ccb = self._ccbOwner.mAttack, condition = function (x) return x == 'md' end, updateFun = handler(self, self._updateHero)},
    	{name = "soul", ccb = self._ccbOwner.soul, condition = function (x) return false end, updateFun = handler(self, self._updateSoulSpirit)},
	}
	self._selectTeamIndex = 0

	local soulUnlock = false
	if self._soulSpiritNum > 0 then
		soulUnlock = true
	end
	self._ccbOwner.attack:setVisible(soulUnlock)
	self._ccbOwner.pAttack:setVisible(not soulUnlock)
	self._ccbOwner.mAttack:setVisible(not soulUnlock)
	self._ccbOwner.soul:setVisible(soulUnlock)
	self._ccbOwner.node_godarm:setVisible(false)
end

function QUIWidgetHeroCollegeTrainBattleArray:onEnter()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSmallFrame.EVENT_HERO_FRAMES_CLICK, self._onIconClick, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSmallFrame.EVENT_SOUL_FRAMES_CLICK, self._onSoulIconClick, self)

    self._ccbOwner.node_btn:setVisible(app.unlock:getUnlockHelperDisplay())

    print("self._assisTanceNum=",self._assisTanceNum)
    if self._assisTanceNum > 0 then
    	self._ccbOwner.node_helper:setVisible(true)
    else
    	self._ccbOwner.node_helper:setVisible(false)
    end

	self._ccbOwner.helperLock2:setVisible(false)
	self._ccbOwner.helperLock3:setVisible(false)

	if self._assisTanceNum > 4 then
		self._ccbOwner.node_helper2:setVisible(true)
	else
		self._ccbOwner.node_helper2:setVisible(false)
	end
	if self._assisTanceNum > 8 then
		self._ccbOwner.node_helper3:setVisible(true)
	else
		self._ccbOwner.node_helper3:setVisible(false)
	end

	self:selectButton("all")
 	self:updateTab(remote.collegetrain.TEAM_INDEX_MAIN)
 	 	
end

function QUIWidgetHeroCollegeTrainBattleArray:_updateHero(victoryId, hero,isLocal)
	self._selectedNumber = 0
	local helperHpSum = 0
	for k, v in pairs(self._heroList) do
		if  v.index == remote.collegetrain.TEAM_INDEX_HELP or 
			v.index == remote.collegetrain.TEAM_INDEX_HELP2 or 
			v.index == remote.collegetrain.TEAM_INDEX_HELP3 then
			local _, _, hp = self:getHeroHpMp(v.actorId)
			helperHpSum = helperHpSum + (hp or 0)
		end
	end
	for k, v in pairs(self._heroList) do
		if v.index == remote.collegetrain.TEAM_INDEX_MAIN then
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId, helperHpSum / 4)
			v.additionalHpMax = helperHpSum / 4
			-- self._additionalMaxHp[v.actorId] = helperHpSum / 4
		else
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId)
			v.additionalHpMax = 0
			-- self._additionalMaxHp[v.actorId] = 0
		end
		if v.index == self._selectTeamIndex then
			self._selectedNumber = self._selectedNumber + 1
		end
	end

	if hero then
		self:_updateWidget(hero)
	else
		self:_updatePage()  
	end
	-- self:_updatePage()  

	self:notificationMainPage(victoryId,isLocal)
end

--获取精灵的战队
function QUIWidgetHeroCollegeTrainBattleArray:getSelectSoulSpirit()
	local tbl = {}
	for _,v in pairs(self._soulSpiritList) do
		if v.index ~= 0 then
			table.insert(tbl, v.soulSpiritId)
		end
	end
	return tbl
end

function QUIWidgetHeroCollegeTrainBattleArray:removeSelectedHero(id)
	local hero = nil
	for k, v in pairs(self._heroList) do
		if v.actorId == id then
			v.index = 0
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
			-- self._additionalMaxHp[v.actorId] = helperHpSum / 4
		else
			v.hpScale, v.mpScale = self:getHeroHpMp(v.actorId)
			v.additionalHpMax = 0
			-- self._additionalMaxHp[v.actorId] = 0
		end
	end

	if hero then
		self:_updateWidget(hero)
	else
		self:_updatePage()
	end
	-- self:_checkTips()
end

function QUIWidgetHeroCollegeTrainBattleArray:removeSelectedSoulSpirit(id)
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
	-- self:_checkTips()
end

function QUIWidgetHeroCollegeTrainBattleArray:_updatePage()
	if self._selectConfig ~= nil then
		self:_showArray(self._selectConfig.condition)
	end

	self:_updateButtonStatus()
end

function QUIWidgetHeroCollegeTrainBattleArray:_updateWidget(hero)
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

function QUIWidgetHeroCollegeTrainBattleArray:setUnlockNumber(value)
	self._unlockNumber = value
end

function QUIWidgetHeroCollegeTrainBattleArray:updateTab(teamIndex)
	local oldSelectTeamIndex = self._selectTeamIndex
	if self._selectTeamIndex == teamIndex then
		return
	end

	self._selectTeamIndex = teamIndex

	self:dispatchEvent({name = QUIWidgetHeroCollegeTrainBattleArray.EVENT_SELECT_TAB, index = self._selectTeamIndex})

	self:resetButtons()
	if teamIndex == remote.collegetrain.TEAM_INDEX_MAIN then
		self._ccbOwner.btn_main:setEnabled(false)
		self._ccbOwner.btn_main:setHighlighted(true)
	elseif teamIndex == remote.collegetrain.TEAM_INDEX_HELP then
		self._ccbOwner.btn_helper:setEnabled(false)
		self._ccbOwner.btn_helper:setHighlighted(true)
		self._ccbOwner.btn_helper1:setEnabled(false)
		self._ccbOwner.btn_helper1:setHighlighted(true)
	elseif teamIndex == remote.collegetrain.TEAM_INDEX_HELP2 then
		self._ccbOwner.btn_helper2:setEnabled(false)
		self._ccbOwner.btn_helper2:setHighlighted(true)
	elseif teamIndex == remote.collegetrain.TEAM_INDEX_HELP3 then
		self._ccbOwner.btn_helper3:setEnabled(false)
		self._ccbOwner.btn_helper3:setHighlighted(true)
	end
	
	if self._currentButtonName == "soul" then
    	self:selectButton("all")
		self._selectConfig.updateFun()
    elseif oldSelectTeamIndex ~= 0 then
		self._selectConfig.updateFun(nil, {})
	else
		self._selectConfig.updateFun()
	end
	-- self:_checkTips()
end

function QUIWidgetHeroCollegeTrainBattleArray:_onIconClick(event)
	local unlockNumber = self._unlockNumber

	local victoryId = nil
	local hero = nil
	for k, v in pairs(self._heroList) do
		if tonumber(v.actorId) == tonumber(event.actorId) then
			if v.index == 0 then
				if self._selectedNumber >= unlockNumber then
					app.tip:floatTip(QUIWidgetHeroCollegeTrainBattleArray.HERO_FULL) 
					return
				end
				victoryId = v.actorId
				v.index = self._selectTeamIndex
			else
				v.index = 0
			end
			hero = v
			break
		end
	end

	self:_updateHero(victoryId, hero)
	-- self:_checkTips()
end

function QUIWidgetHeroCollegeTrainBattleArray:_onSoulIconClick(event)
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
				if currentSelect >= 1 then
					app.tip:floatTip(QUIWidgetHeroCollegeTrainBattleArray.SOUL_FULL) 
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
end

--更新精灵
function QUIWidgetHeroCollegeTrainBattleArray:_updateSoulSpirit(victoryId, soulSpirit)
	if soulSpirit then
		self:_updateSoulWidget(soulSpirit)
	else
		self:_updatePage()  
	end
	self:notificationMainPage(victoryId)
end

function QUIWidgetHeroCollegeTrainBattleArray:_updateSoulWidget(soulSpirit)
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

-- sort 战斗力（降序）  
function QUIWidgetHeroCollegeTrainBattleArray:_sortHero(a,b)
	local attackA = 0
	local attackB = 0
	if a.data then
		attackA = a.data.force or 0
	end

	if b.data then
		attackB = b.data.force or 0
	end

	return attackA > attackB
end

function QUIWidgetHeroCollegeTrainBattleArray:_showArray(condition)
	if self._currentButtonName == "soul" then --走精灵模块
		self._items = {}
		local soulSpiritList = clone(self._soulSpiritList)
		for k, v in pairs(soulSpiritList) do
			table.insert(self._items, {oType = "soul", data = v,chapterId = self._chapterId})
		end
		table.sort(self._items, function (a,b)
			local characherA = db:getCharacterByID(a.data.soulSpiritId)
			local characherB = db:getCharacterByID(b.data.soulSpiritId)
			-- local soulSpiritInfoA = remote.soulSpirit:getMySoulSpiritInfoById(a.data.soulSpiritId)
			-- local soulSpiritInfoB = remote.soulSpirit:getMySoulSpiritInfoById(b.data.soulSpiritId)
			if characherA.aptitude ~= characherB.aptitude then
				return characherA.aptitude > characherB.aptitude
			else
				return a.data.soulSpiritId > b.data.soulSpiritId
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
		for i = #allHero, 1, -1 do 
			local v = self._heroList[allHero[i]]
			v.additionalHpMax = 0
			table.insert(self._items, {oType = "hero", data = v,chapterId = self._chapterId})
		end
	end

	table.sort(self._items, handler(self, self._sortHero))

	self:initListView()
end

function QUIWidgetHeroCollegeTrainBattleArray:initListView( ... )
	-- body
	-- QPrintTable(self._items)
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

function QUIWidgetHeroCollegeTrainBattleArray:getHeroHpMp(actorId, additionalHpMax)
	local hp = 0
	local mp = 0
	local heroInfo = nil
	-- local heroInfo = remote.collegetrain:getHeroInfoById(self._chapterId,actorId)
	-- local heroProp = remote.herosUtil:createHeroProp(heroInfo)
	local heroProp = remote.collegetrain:getHeroModelById(self._chapterId,actorId)
	local maxHp = heroProp:getMaxHp()
	local maxMp = heroProp:getRageTotal()
	if heroInfo == nil then
		hp = maxHp
		mp = maxMp/2
	else
		hp = heroInfo.hp or heroInfo.currHp
		mp = maxMp/2
		-- if heroInfo.mp or heroInfo.currMp then
		-- 	mp = heroInfo.mp or heroInfo.currMp
		-- end
	end

	if hp == nil or hp > maxHp then
		hp = maxHp
	end

	
	local hpScale = hp/maxHp
	local mpScale = mp/maxMp

	-- 针对武魂之力或者其他英雄，导致溢出，按照1来复制
	if hpScale > 1 then hpScale = 1 end
	if mpScale > 1 then mpScale = 1 end

	return hpScale, mpScale, hp
end

function QUIWidgetHeroCollegeTrainBattleArray:selectButton(btnType)
	self._currentButtonName = btnType
	for k, v in ipairs(self._buttonList) do
		if v.name == self._currentButtonName then
			self._selectConfig = v
			break
		end
	end
end

function QUIWidgetHeroCollegeTrainBattleArray:_updateButtonStatus()
	for k, v in ipairs(self._buttonList) do
		if v.name == self._currentButtonName then
			v.ccb:setHighlighted(true)
		else
			v.ccb:setHighlighted(false)
		end
	end
end 

function QUIWidgetHeroCollegeTrainBattleArray:resetButtons()
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
end

function QUIWidgetHeroCollegeTrainBattleArray:notificationMainPage(victoryId,isLocal)
	local heroList = {}
	local soulSpiritList = {}
	local assistHeroList = {}
	local selectIndex = self:getSelectIndex()
	for k, v in pairs(self._heroList) do
		if v.index == selectIndex then
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
    self:dispatchEvent({name = QUIWidgetHeroCollegeTrainBattleArray.HERO_CHANGED, hero = heroList, soulSpirits = soulSpiritList, assistHeroList = assistHeroList, victoryId = victoryId,isLocal=isLocal})
end

function QUIWidgetHeroCollegeTrainBattleArray:getSelectTeam()
	local tbl = {}
	for _, value in pairs(self._heroList) do
		if value.index ~= 0 then
			if tbl[value.index] == nil then tbl[value.index] = {} end
			table.insert(tbl[value.index], tonumber(value.actorId))
		end
	end
	return tbl
end

function QUIWidgetHeroCollegeTrainBattleArray:_onTriggerAll(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "all" then
    		self._ccbOwner.all:setHighlighted(true)
    	end
    else
    	app.sound:playSound("common_menu")
    	self:selectButton("all")
	    self:_updatePage()
	end
end

function QUIWidgetHeroCollegeTrainBattleArray:_onTriggerTank(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "tank" then
    		self._ccbOwner.tank:setHighlighted(true)
    	end
    else
    	app.sound:playSound("common_menu")
    	self:selectButton("tank")
	    self:_updatePage()
	end
end

function QUIWidgetHeroCollegeTrainBattleArray:_onTriggerHeal(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "heal" then
    		self._ccbOwner.heal:setHighlighted(true)
    	end
    else
    	app.sound:playSound("common_menu")
    	self:selectButton("heal")
	    self:_updatePage()
	end
end

function QUIWidgetHeroCollegeTrainBattleArray:_onTriggerAttack(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "attack" then
    		self._ccbOwner.attack:setHighlighted(true)
    	end
    else
    	app.sound:playSound("common_menu")
    	self:selectButton("attack")
	    self:_updatePage()
	end
end

function QUIWidgetHeroCollegeTrainBattleArray:_onTriggerPAttack(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "pAttack" then
    		self._ccbOwner.pAttack:setHighlighted(true)
    	end
    else
    	app.sound:playSound("common_menu")
    	self:selectButton("pAttack")
	    self:_updatePage()
	end
end

function QUIWidgetHeroCollegeTrainBattleArray:_onTriggerMAttack(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "mAttack" then
    		self._ccbOwner.mAttack:setHighlighted(true)
    	end
    else
    	app.sound:playSound("common_menu")
    	self:selectButton("mAttack")
	    self:_updatePage()
	end
end

function QUIWidgetHeroCollegeTrainBattleArray:_onTriggerSoul(eventType)
    if tonumber(eventType) ~= CCControlEventTouchUpInside then
    	if self._currentButtonName == "soul" then
    		self._ccbOwner.soul:setHighlighted(true)
    	end
    else
    	app.sound:playSound("common_menu")
    	self:selectButton("soul") 
	    self:_updatePage()
	end
end

function QUIWidgetHeroCollegeTrainBattleArray:getSelectIndex()
	return self._selectTeamIndex
end

function QUIWidgetHeroCollegeTrainBattleArray:onExit()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSmallFrame.EVENT_HERO_FRAMES_CLICK, self._onIconClick, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSmallFrame.EVENT_SOUL_FRAMES_CLICK, self._onSoulIconClick, self)
end

function QUIWidgetHeroCollegeTrainBattleArray:onTriggerHelper()
	app.sound:playSound("common_menu")
	if self._assisTanceNum <= 0 then
		return
	end
	self:updateTab(remote.collegetrain.TEAM_INDEX_HELP)
end

function QUIWidgetHeroCollegeTrainBattleArray:onTriggerHelper2()
	app.sound:playSound("common_menu")
	if self._assisTanceNum <= 4 then
		return
	end
	self:updateTab(remote.collegetrain.TEAM_INDEX_HELP2)
end

function QUIWidgetHeroCollegeTrainBattleArray:onTriggerHelper3()
	app.sound:playSound("common_menu")
	if self._assisTanceNum <= 8 then
		return
	end
	self:updateTab(remote.collegetrain.TEAM_INDEX_HELP3)
end

function QUIWidgetHeroCollegeTrainBattleArray:onTriggerMain()
	app.sound:playSound("common_menu")

	self:updateTab(remote.collegetrain.TEAM_INDEX_MAIN)
end

function QUIWidgetHeroCollegeTrainBattleArray:onTriggerAlternate()
	app.sound:playSound("common_menu")

	self:updateTab(remote.collegetrain.TEAM_INDEX_MAIN, true)
end

function QUIWidgetHeroCollegeTrainBattleArray:_onTriggerLeft( ... )
	if self._listViewLayout then
		self._listViewLayout:startScrollToPosScheduler(self._width*0.8, 0.8, false, nil, true)
	end
end

function QUIWidgetHeroCollegeTrainBattleArray:_onTriggerRight( ... )
	if self._listViewLayout then
		self._listViewLayout:startScrollToPosScheduler(-self._width*0.8, 0.8, false, nil, true)
	end
end

function QUIWidgetHeroCollegeTrainBattleArray:getContentSize()
end

return QUIWidgetHeroCollegeTrainBattleArray
