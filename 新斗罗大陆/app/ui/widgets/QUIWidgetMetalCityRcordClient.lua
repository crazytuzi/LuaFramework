-- @Author: xurui
-- @Date:   2018-08-16 19:47:42
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-27 14:52:24
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMetalCityRcordClient = class("QUIWidgetMetalCityRcordClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")

QUIWidgetMetalCityRcordClient.EVENT_CLICK_REPLAY = "EVENT_CLICK_REPLAY"

function QUIWidgetMetalCityRcordClient:ctor(options)
	local ccbFile = "ccb/Widget_tower_tongguanjilu.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
    }
    QUIWidgetMetalCityRcordClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetMetalCityRcordClient:onEnter()
end

function QUIWidgetMetalCityRcordClient:onExit()
end

function QUIWidgetMetalCityRcordClient:setInfo(info, index,reportType)
	self._info = info
	self._index = index
	self._fighter = self._info.fighter or {}
	self._heros = {}
	self._team2heros = {}
	if self._info.fightersData then
        local content = crypto.decodeBase64(self._info.fightersData)
        local replayInfo = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayInfo", content)
		self._heros = replayInfo.fighter1 or {}
		self._team2heros = replayInfo.team2HeroInfoes
	end
	self._ccbOwner.tf_1:setString("LV."..(self._fighter.level or 0).." "..(self._fighter.name or ""))
	self._ccbOwner.tf_vip:setString("VIP"..(self._fighter.vip or 0))

	local num, word = q.convertLargerNumber(self._fighter.force or 0)
	self._ccbOwner.tf_4:setString("战力："..num..(word or ""))

	if self._avatar == nil then 
		self._avatar = QUIWidgetAvatar.new(self._fighter.avatar or 1)
		self._avatar:setSilvesArenaPeak(self._fighter.championCount)
		self._ccbOwner.node_avatar:addChild(self._avatar)
	end

	-- if self._fighter.soulTrial then
	-- 	local _, passChapter = remote.soulTrial:getCurChapter( self._fighter.soulTrial )
	-- 	local curBossConfig = remote.soulTrial:getBossConfigByChapter( passChapter )
	-- 	local url = curBossConfig.title_icon3

	-- 	if url then
	-- 		QSetDisplayFrameByPath(self._ccbOwner.sp_soulTrial, url)
	-- 	end
	-- 	self._ccbOwner.sp_soulTrial:setVisible(true)
	-- 	self._ccbOwner.tf_1:setPositionX(-20)
	-- else
	-- 	self._ccbOwner.tf_1:setPositionX(-110)
	-- 	self._ccbOwner.sp_soulTrial:setVisible(false)
	-- end

	self._ccbOwner.tf_1:setPositionX(-110)
	self._ccbOwner.sp_soulTrial:setVisible(false)
	self._ccbOwner.sp_first:setVisible(self._index == 1)
	self._ccbOwner.sp_second:setVisible(self._index == 2)
	self._ccbOwner.sp_third:setVisible(self._index == 3)

	if self._index > 3 then
		self._ccbOwner.tf_other:setVisible(true)
		self._ccbOwner.tf_other:setString(self._index)
	else
		self._ccbOwner.tf_other:setVisible(false)
	end

	local nodes = {}
	table.insert(nodes, self._ccbOwner.sp_soulTrial)
	table.insert(nodes, self._ccbOwner.tf_1)
	table.insert(nodes, self._ccbOwner.tf_vip)
	q.autoLayerNode(nodes, "x", 0)

	if reportType == REPORT_TYPE.METAL_CITY then
		self:setDoubleTeamHero()
	else
		self:setSingTeamHero()
	end
end

function QUIWidgetMetalCityRcordClient:setSingTeamHero()
	self._ccbOwner.node_fighter:removeAllChildren()
	self._ccbOwner.node_double:setVisible(false)

    local totalWidth = 0
    local headIndex = 0
    local offsetX = 10
    local offsetY = 0
    local lineDistance = 5
    for index, value in pairs(self._heros) do
        local heroHead = QUIWidgetHeroHead.new()
        headIndex = headIndex + 1
        heroHead:setTeam(0)
        heroHead:setHeroInfo(value)
        heroHead:setHeadScale(0.6)
    	local pos = ccp(offsetX+totalWidth,0)
    	heroHead:setPosition(pos)
       	totalWidth = totalWidth + heroHead:getContentSize().width*0.6 + lineDistance

        heroHead:initGLLayer()
        self._ccbOwner.node_fighter:addChild(heroHead)
    end
end

function QUIWidgetMetalCityRcordClient:setDoubleTeamHero( )
	self._ccbOwner.node_fighter:removeAllChildren()
	self._ccbOwner.node_double:setVisible(true)
	
	local calculateForceFunc = function(heros)
		local maxHero = nil
		local maxForce = 0		
		for _, value in ipairs(heros) do
			local force = value.force or 0
			if force > maxForce then
				maxForce = force
				maxHero = value
			end
		end

		return maxHero
	end

	local heroInfo1 = {}
	local heroInfo2 = {}

	if q.isEmpty(self._heros) == false then
		heroInfo1 = calculateForceFunc(self._heros)
	end
	QPrintTable(heroInfo1)
	if q.isEmpty(self._team2heros) == false then
		heroInfo2 = calculateForceFunc(self._team2heros)
	end
	QPrintTable(heroInfo2)
	local showHead = function(node,hideNode,info)
		if q.isEmpty(info) == false then
			local characherDisplay = db:getCharacterByID(info.actorId)
			if characherDisplay then
				local heroHead = QUIWidgetHeroHead.new()
				node:addChild(heroHead)
				heroHead:setScale(0.8)
				heroHead:setVisible(true)
				heroHead:setHeroInfo(info)
				hideNode:setVisible(false)
			else
				hideNode:setVisible(true)
			end
		end
	end

	showHead(self._ccbOwner.node_monster_head1,self._ccbOwner.sp_no_hero1,heroInfo1)
	showHead(self._ccbOwner.node_monster_head2,self._ccbOwner.sp_no_hero2,heroInfo2)	
end

function QUIWidgetMetalCityRcordClient:_onShowTeam1Heros( )
	local fighterInfo = {}
	fighterInfo.heros = self._heros
	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStormArenaEnemyTeamInfo",
		options = {trialNum = 1, info = fighterInfo}}, {isPopCurrentDialog = false})
	dialog:setTeamName("队伍1")
end

function QUIWidgetMetalCityRcordClient:_onShowTeam2Heros( )
	local fighterInfo = {}
	fighterInfo.heros = self._team2heros	
	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStormArenaEnemyTeamInfo",
		options = {trialNum = 1, info = fighterInfo}}, {isPopCurrentDialog = false})
	dialog:setTeamName("队伍2")
end

function QUIWidgetMetalCityRcordClient:getContentSize()
	return self._ccbOwner.sp_bg:getContentSize()
end

function QUIWidgetMetalCityRcordClient:_onTriggerReplay()
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetMetalCityRcordClient.EVENT_CLICK_REPLAY, recordId = self._info.reportId})
end

return QUIWidgetMetalCityRcordClient
