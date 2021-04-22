
-- @Author: xurui
-- @Date:   2019-12-27 16:33:14
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-08 18:48:39
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTotemChallengeFighterInfo = class("QUIDialogTotemChallengeFighterInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QRichText = import("...utils.QRichText")
local QTotemChallengeArrangement = import("...arrangement.QTotemChallengeArrangement")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

local NUMBER_TIME = 1

function QUIDialogTotemChallengeFighterInfo:ctor(options)
	local ccbFile = "ccb/Dialog_totemChallenge_fighter_info.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerChallenge", callback = handler(self, self._onTriggerChallenge)},
        {ccbCallbackName = "onTriggerChange", callback = handler(self, self._onTriggerChange)},
        {ccbCallbackName = "onTriggerSetQuickPass", callback = handler(self, self._onTriggerSetQuickPass)},
        {ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
		{ccbCallbackName = "onTriggerDifficultAward", callback = handler(self, self._onTriggerDifficultAward)},
    }
    QUIDialogTotemChallengeFighterInfo.super.ctor(self, ccbFile, callBacks, options)
    self._page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if self._page.setManyUIVisible then self._page:setManyUIVisible() end
    if self._page.topBar.showWithStyle then 
        self._page.topBar:showWithStyle({TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.GOD_ARM_MONEY, TOP_BAR_TYPE.BATTLE_FORCE})
    end

    q.setButtonEnableShadow(self._ccbOwner.btn_challenge)
    q.setButtonEnableShadow(self._ccbOwner.btn_change)
    q.setButtonEnableShadow(self._ccbOwner.btn_difficult)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._forceUpdate_1 = nil
    self._forceUpdate_2 = nil

    self._awardItemBox = {}
    self._awardNumTF = {}
    self._heroActorIds = {}
    self._items = {}

    self._isRefreshAction = false

    self._itemContentSize = CCSize(0, 0)
end

function QUIDialogTotemChallengeFighterInfo:viewDidAppear()
	QUIDialogTotemChallengeFighterInfo.super.viewDidAppear(self)
    local newOptions = self:getOptions()
    if newOptions then
        self._callBack = newOptions.callBack
        self._fighterInfo = newOptions.fighterInfo
        self._dungeonInfo = newOptions.dungeonInfo
    end

	self:setInfo()

	self:addBackEvent(true)
end

function QUIDialogTotemChallengeFighterInfo:viewWillDisappear()
  	QUIDialogTotemChallengeFighterInfo.super.viewWillDisappear(self)
    if self._forceUpdate_1 then
        self._forceUpdate_1:stopUpdate()
        self._forceUpdate_1 = nil
    end
    if self._forceUpdate_2 then
        self._forceUpdate_2:stopUpdate()
        self._forceUpdate_2 = nil
    end

	self:removeBackEvent()
end

function QUIDialogTotemChallengeFighterInfo:updateInfo()
    self:updateRivalsFight()
    self:runUpdateInfoAction()
end


function QUIDialogTotemChallengeFighterInfo:updateRivalsFight()
    self._rivalsFight = clone(self._fighterInfo.fighter or {})
    self._rivalsFight.buffId = self._fighterInfo.buffId
    self._rivalsFight.buffNum = self._fighterInfo.buffNum    
    remote.teamManager:sortTeam(self._rivalsFight.heros, true)
    remote.teamManager:sortTeam(self._rivalsFight.subheros, true)
    remote.teamManager:sortTeam(self._rivalsFight.sub2heros, true)
    remote.teamManager:sortTeam(self._rivalsFight.main1Heros, true)
    remote.teamManager:sortTeam(self._rivalsFight.sub1heros, true)
end



function QUIDialogTotemChallengeFighterInfo:runUpdateInfoAction()

    if self._forceUpdate_1 == nil then
        self._forceUpdate_1 = QTextFiledScrollUtils.new()
    end
    if self._forceUpdate_2 == nil then
        self._forceUpdate_2 = QTextFiledScrollUtils.new()
    end

    local dur = 0.7
    makeNodeFadeToByTimeAndOpacity(self._ccbOwner["sheet_layout_"..1] ,dur,0)
    makeNodeFadeToByTimeAndOpacity(self._ccbOwner["sheet_layout_"..2],dur,0)
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(1.0))
    arr:addObject(CCCallFunc:create(function()

        self._heroActorIds = {}
        self:setDungeonInfo()
        self:setTemaInfo(true)
        makeNodeFadeToByTimeAndOpacity(self._ccbOwner["sheet_layout_"..1] ,0.1,255)
        makeNodeFadeToByTimeAndOpacity(self._ccbOwner["sheet_layout_"..2] ,0.1,255)
        self:setBufferInfo()
        self._isRefreshAction = false
    end))

    self._ccbOwner.node_btn_challenge:stopAllActions()
    self._ccbOwner.node_btn_challenge:runAction(CCSequence:create(arr))

end


function QUIDialogTotemChallengeFighterInfo:_onForceUpdate1(value)
    local word = nil
    if value >= 1000000 then
      word = tostring(math.floor(value/10000)).."万"
    else
      word = math.floor(value)
    end
    self._ccbOwner.tf_team_1_force:setString(word)
    local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(value,true)
    if fontInfo ~= nil then
        local color = string.split(fontInfo.force_color, ";")
        self._ccbOwner.tf_team_1_force:setColor(ccc3(color[1], color[2], color[3]))
    end
end

function QUIDialogTotemChallengeFighterInfo:_onForceUpdate2(value)
    local word = nil
    if value >= 1000000 then
      word = tostring(math.floor(value/10000)).."万"
    else
      word = math.floor(value)
    end
    self._ccbOwner.tf_team_2_force:setString(word)
    local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(value,true)
    if fontInfo ~= nil then
        local color = string.split(fontInfo.force_color, ";")
        self._ccbOwner.tf_team_2_force:setColor(ccc3(color[1], color[2], color[3]))
    end
end



function QUIDialogTotemChallengeFighterInfo:setInfo()
	self._userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()
	self._levelConfig = remote.totemChallenge:getDungeonConfigByLevel(self._dungeonInfo.currentFloor or 1) or {}

    -- self._rivalsFight = clone(self._fighterInfo.fighter or {})
    -- self._rivalsFight.buffId = self._fighterInfo.buffId
    -- self._rivalsFight.buffNum = self._fighterInfo.buffNum
    -- remote.teamManager:sortTeam(self._rivalsFight.heros, true)
    -- remote.teamManager:sortTeam(self._rivalsFight.subheros, true)
    -- remote.teamManager:sortTeam(self._rivalsFight.sub2heros, true)
    -- remote.teamManager:sortTeam(self._rivalsFight.main1Heros, true)
    -- remote.teamManager:sortTeam(self._rivalsFight.sub1heros, true)
    self:updateRivalsFight()
	self:setDungeonInfo()

	self:setTemaInfo()

	self:setBufferInfo()
    self:_updateQuickPassInfo()
end

function QUIDialogTotemChallengeFighterInfo:_updateQuickPassInfo()
    self._userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()
    if remote.totemChallenge:hasHardModelByFloor(self._userInfoDict.currentFloor) then
        self._ccbOwner.node_quickPass_info:setVisible(true)

        self._ccbOwner.node_quickPass_1:setVisible(true)
        self._ccbOwner.tf_team_1_force:setVisible(true)
        self._ccbOwner.tf_quickPass_1:setVisible(false)

        self._ccbOwner.node_quickPass_2:setVisible(true)
        self._ccbOwner.tf_team_2_force:setVisible(true)
        self._ccbOwner.tf_quickPass_2:setVisible(false)

        if self._userInfoDict.team1IsQuickPass then
            self._ccbOwner.node_quickPass_1:setVisible(false)
            self._ccbOwner.tf_team_1_force:setVisible(false)
            self._ccbOwner.tf_quickPass_1:setVisible(true)
            self._ccbOwner.tf_quickPass_1:setString("对手已失去战斗力")
        end

        if self._userInfoDict.team2IsQuickPass then
            self._ccbOwner.node_quickPass_2:setVisible(false)
            self._ccbOwner.tf_team_2_force:setVisible(false)
            self._ccbOwner.tf_quickPass_2:setVisible(true)
            self._ccbOwner.tf_quickPass_2:setString("对手已失去战斗力")
        end
    else
        self._ccbOwner.node_quickPass_info:setVisible(false)
        self._ccbOwner.tf_team_1_force:setVisible(true)
        self._ccbOwner.tf_team_2_force:setVisible(true)
        return
    end

    local config = remote.totemChallenge:getDungeonConfigById(self._userInfoDict.totalNum or 1)
    local itemId
    if config and config.must_win_condition then
        local tbl = string.split(config.must_win_condition, "^")
        itemId = tbl[1]
    end
    if not itemId then
        itemId = 1000548
    end
    self._ccbOwner.tf_quiackPass_count:setString(remote.items:getItemsNumByID(itemId)) 

    self:_updateQuickPassEffect(1)
    self:_updateQuickPassEffect(2)
end

function QUIDialogTotemChallengeFighterInfo:setDungeonInfo()
	local rewardConfig = remote.totemChallenge:getDungeonRewardConfigById(self._userInfoDict.totalNum or 1)
	local reward = db:getLuckyDrawAwardTable(rewardConfig.reward)
	local config = self._levelConfig[tostring(self._dungeonInfo.rivalPos or 1)] or {}
    local fighterInfo = self._fighterInfo.fighter or {}
	self._ccbOwner.tf_title:setString(string.format("%s-%s%s: %s", 
        (self._userInfoDict.currentFloor or 1), (self._userInfoDict.currentDungeon or 1), (config.name or ""), (fighterInfo.name or "")))


    self._ccbOwner.node_difficult:setVisible(remote.totemChallenge:checkIsHardType())


	for i, value in ipairs(self._awardItemBox) do
		value:setVisible(false)
		if self._awardNumTF[i] then
			self._awardNumTF[i]:setVisible(false)
		end
	end
	local scale = 0.4
	local totalWidth = 0
	for i, value in ipairs(reward or {}) do
		if self._awardItemBox[i] == nil then
			self._awardItemBox[i] = QUIWidgetItemsBox.new()
			self._ccbOwner.node_award:addChild(self._awardItemBox[i])
			self._awardItemBox[i]:setScale(scale)
            self._awardItemBox[i]:setPromptIsOpen(true)
			
			if self._awardNumTF[i] == nil then
				self._awardNumTF[i] = CCLabelTTF:create("", global.font_default, 22)
				self._ccbOwner.node_award:addChild(self._awardNumTF[i])
				self._awardNumTF[i]:setAnchorPoint(ccp(0, 0.5))
			end
		end
		self._awardItemBox[i]:setGoodsInfo(value.id, value.itemType, 0)
		self._awardItemBox[i]:setVisible(true)
		self._awardNumTF[i]:setString(string.format("%s", value.count))
		self._awardNumTF[i]:setVisible(true)

		self._awardItemBox[i]:setPositionX(totalWidth)
		local itemContentSize = self._awardItemBox[i]:getContentSize()
		totalWidth = totalWidth + (itemContentSize.width * scale)/2 + 10

		self._awardNumTF[i]:setPositionX(totalWidth)
		local tffContentSize = self._awardNumTF[i]:getContentSize()
		totalWidth = totalWidth + tffContentSize.width + 30
	end
end

function QUIDialogTotemChallengeFighterInfo:setTemaInfo(playAction)
	self._teamInfo1 = {}

    local fighterInfo = self._fighterInfo.fighter or {}
    local team1MainHeros = fighterInfo.heros or {}
    local force1 = 0
    for index, value in ipairs(team1MainHeros) do
    	local teamIndex = 1
        table.insert(self._teamInfo1, {itemInfo = value, oType = "hero", teamIndex = teamIndex})
        table.insert(self._heroActorIds, value.actorId)
        force1 = force1 + value.force
    end
    
    local team1SoulSpirit = fighterInfo.soulSpirit or {}
    for index, value in ipairs(team1SoulSpirit) do
    	local teamIndex = 1
        table.insert(self._teamInfo1, {itemInfo = value, oType = "soulSpirit", teamIndex = teamIndex})
        force1 = force1 + (value.force or 0)
    end

    local team1GodArms = fighterInfo.godArm1List or {}
    if team1GodArms then
        for index, value in ipairs(team1GodArms) do
            local teamIndex = 1
            table.insert(self._teamInfo1, {itemInfo = value, oType = "godArm", teamIndex = teamIndex})
            force1 = force1 + (value.main_force or 0)
        end
    end

    local subheros = fighterInfo.subheros or {}
    local team1HelpHeros = remote.teamManager:sortSubHeros(subheros, fighterInfo.activeSubActorId, fighterInfo.active1SubActorId)
    for index, value in ipairs(team1HelpHeros) do
    	local teamIndex = 2
    	local skillTeamIndex
        if index <= 2 then
            skillTeamIndex = index
        end
        table.insert(self._teamInfo1, {itemInfo = value, oType = "hero", teamIndex = teamIndex, skillTeamIndex = skillTeamIndex})
        table.insert(self._heroActorIds, value.actorId)
        force1 = force1 + value.force
    end
    self:initTeamListView(1,playAction)
    self:setForce(1, force1,playAction)

    -- team2
    local force2 = 0
	self._teamInfo2 = {}
    local team2MainHeros = fighterInfo.main1Heros or {}
    for index, value in ipairs(team2MainHeros) do
    	local teamIndex = 1
        table.insert(self._teamInfo2, {itemInfo = value, oType = "hero", teamIndex = teamIndex})
        table.insert(self._heroActorIds, value.actorId)
        force2 = force2 + value.force
    end

    local team2SoulSpirit = fighterInfo.soulSpirit2 or {}
    for index, value in ipairs(team2SoulSpirit) do
    	local teamIndex = 1
        table.insert(self._teamInfo2, {itemInfo = value, oType = "soulSpirit", teamIndex = teamIndex})
        force2 = force2 + (value.force or 0)
    end

    local team2GodArms = fighterInfo.godArm2List or {}
    if team2GodArms then
        for index, value in ipairs(team2GodArms) do
            local teamIndex = 1
            table.insert(self._teamInfo2, {itemInfo = value, oType = "godArm", teamIndex = teamIndex})
            force1 = force1 + (value.main_force or 0)
        end
    end

    local subheros = fighterInfo.sub1heros or {}
    local team2HelpHeros = remote.teamManager:sortSubHeros(subheros, fighterInfo.activeSub2ActorId, fighterInfo.active1Sub2ActorId)
    for index, value in ipairs(team2HelpHeros) do
        local teamIndex = 2
    	local skillTeamIndex
        if index <= 2 then
            skillTeamIndex = index
        end
        table.insert(self._teamInfo2, {itemInfo = value, oType = "hero", teamIndex = teamIndex, skillTeamIndex = skillTeamIndex})
        table.insert(self._heroActorIds, value.actorId)
        force2 = force2 + value.force
    end
    self:initTeamListView(2,playAction)
    self:setForce(2, force2,playAction)


    local times = remote.totemChallenge:getTotemChallengeRivalsCount()
    self._ccbOwner.tf_change_times:setString(times)
end

function QUIDialogTotemChallengeFighterInfo:setForce(teamIndex, force , playAction)

    if playAction then
        -- force = force * 2 
        self["_forceUpdate_"..teamIndex]:addUpdate(self["force"..teamIndex] , force, handler(self, self["_onForceUpdate"..teamIndex]), NUMBER_TIME)
    else
        local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(tonumber(force),true)
        local num, unit = q.convertLargerNumber(force)
        self._ccbOwner["tf_team_"..teamIndex.."_force"]:setString(num..unit)
        local color = string.split(fontInfo.force_color, ";")
        self._ccbOwner["tf_team_"..teamIndex.."_force"]:setColor(ccc3(color[1], color[2], color[3]))
    end
        self["force"..teamIndex] = force

end

function QUIDialogTotemChallengeFighterInfo:initTeamListView(teamIndex,playAction)
	local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc1),
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._teamInfo1,
	        isVertical = false,
            spaceX = 10,
            curOffset = 20,
            curOriginOffset = 10,
            contentOffsetY = -33,  
		}
	if teamIndex == 2 then
		cfg.renderItemCallBack = handler(self, self._renderItemFunc2)
		cfg.totalNumber = #self._teamInfo2
	end
	if not self["_teamListView"..teamIndex] then
		self["_teamListView"..teamIndex] = QListView.new(self._ccbOwner["sheet_layout_"..teamIndex], cfg)
	else
		self["_teamListView"..teamIndex]:reload(cfg)
	end

    if playAction then
        self["_teamListView"..teamIndex]:startScrollToPosScheduler(560, 0.8, false, function ()
                                end,true)
    end
end

function QUIDialogTotemChallengeFighterInfo:_renderItemFunc1(list, index, info)
	return self:_renderItemFunc(list, index, info, self._teamInfo1, 1)

end

function QUIDialogTotemChallengeFighterInfo:_renderItemFunc2(list, index, info)
	return self:_renderItemFunc(list, index, info, self._teamInfo2, 2)
end

function QUIDialogTotemChallengeFighterInfo:_renderItemFunc(list, index, info, teamInfo, teamIndex)
    local scale = 0.8
    local isCacheNode = true
    local itemData = teamInfo[index]
    local item = list:getItemFromCache(itemData.oType)
    if not item then
	  	item = QUIWidgetQlistviewItem.new()
    	isCacheNode = false
    end
    self:setItemInfo(item, itemData, scale)

    info.tag = itemData.oType
    self._itemContentSize = item._itemNode:getContentSize()
    self._itemContentSize.width = self._itemContentSize.width * scale
    info.size = self._itemContentSize
    info.item = item

    list:registerBtnHandler(index, "btn_click", "_onTriggerClick")

    if not self._items[teamIndex] then self._items[teamIndex] = {} end
    table.insert(self._items[teamIndex], item)

    self._userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo() 
    if (teamIndex == 1 and self._userInfoDict.team1IsQuickPass) or (teamIndex == 2 and self._userInfoDict.team2IsQuickPass) then
        makeNodeFromNormalToGray(item)
    else
        makeNodeFromGrayToNormal(item)
    end
    return isCacheNode
end

function QUIDialogTotemChallengeFighterInfo:setItemInfo( item, itemData, scale)
    if not item._itemNode then
        item._itemNode = QUIWidgetHeroHead.new()
        item._itemNode:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        item._ccbOwner.parentNode:addChild(item._itemNode)
    end

    local itemInfo = itemData.itemInfo or {}
    if itemData.oType == "hero" then
        item._itemNode:setHeroSkinId(itemInfo.skinId)
        item._itemNode:setHero(itemInfo.actorId)
        item._itemNode:setLevel(itemInfo.level)
        item._itemNode:setBreakthrough(itemInfo.breakthrough)
        item._itemNode:setGodSkillShowLevel(itemInfo.godSkillGrade)
        item._itemNode:setStar(itemInfo.grade)
        if itemData.skillTeamIndex then
            item._itemNode:setSkillTeam(itemData.skillTeamIndex)
        else
            item._itemNode:setTeam(itemData.teamIndex)
        end
        local heroInfo = q.cloneShrinkedObject(db:getCharacterByID(itemInfo.actorId))
        item._itemNode:setProfession(heroInfo.func or "dps")
    elseif itemData.oType == "soulSpirit" then
        item._itemNode:setTeam(itemData.teamIndex)
        item._itemNode:setHeroInfo(itemInfo)
    elseif itemData.oType == "godArm" then  
        item._itemNode:setHero(itemInfo.id)
        item._itemNode:setLevel(itemInfo.level)
        item._itemNode:setStar(itemInfo.grade)
        item._itemNode:setTeam(itemData.teamIndex, false, false,true)
    end
    item._itemNode:showSabc()
    item._itemNode:setScale(scale)
    item._itemNode:initGLLayer()
    local contentSize = item._itemNode:getContentSize()
    item._itemNode:setPositionX(contentSize.width*scale/2)
    item._itemNode:setPositionY(contentSize.height*scale/2)
    item:setClickCallBack(function() 
        item._itemNode:_onTriggerTouch(CCControlEventTouchUpInside)
    end)
end

function QUIDialogTotemChallengeFighterInfo:_onEvent( event )
    if FinalSDK.isHXShenhe() then
        return
    end

    local heroHead = event.target
    local actorId = heroHead:getHeroActorID()
    if heroHead:getIsGodarm() then
        app.tip:floatTip("该神器已上阵")
        return
    end

    if heroHead:getIsSoulSpirit() then
        actorId = self:getActorIdBySoulSpiritId(actorId)
        if not actorId then
            app.tip:floatTip("该魂灵还没有护佑魂师")
            return
        end
        local heroHead = nil
        local isFind = false
        for i, v in pairs(self._heroActorIds) do
            if v == actorId then
                actorId = v
                isFind = true
                break
            end
        end
        if not isFind then
            app.tip:floatTip("该魂灵护佑的魂师不在队伍里")
            return
        end
    end
    local unkonwType = heroHead:getHeroType()
    if self:_checkNPCHero(actorId) then
        app.tip:floatTip("该魂师正在闭关修炼，请勿打扰")
    elseif unkonwType and unkonwType ~= 3 then
        if unkonwType == 1 then
            app.tip:floatTip("该位置未上阵魂师")
        elseif unkonwType == 0 then
            app.tip:floatTip("该位置为隐藏位")
        end
    else
        local pos = 0
        for i, id in ipairs(self._heroActorIds) do
            if id == actorId then
                pos = i
                break
            end
        end

        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroInfo", 
            options = {hero = self._heroActorIds, pos = pos, fighter = self._fighterInfo.fighter or {}}})
    end
end

function QUIDialogTotemChallengeFighterInfo:setBufferInfo()
    local buffConfig = remote.totemChallenge:getBuffConfigById(self._fighterInfo.buffId or 1)

    local buffNum = self._fighterInfo.buffNum
    local strFunc = function(heros, str)
        if buffNum then
            local actorId = 1001
            for index, value in ipairs(heros) do
                if index <= tonumber(buffNum) then
                    actorId = value.actorId
                end
            end
            local heroConfig = db:getCharacterByID(actorId)
            if heroConfig then
                local strs = string.split(str, "#HERO_NAME#")
                if strs[2] then
                    str = (strs[1] or "")..(heroConfig.name or "")..(strs[2] or "")
                end
            end
        end

        return str
    end

    local lineWidth = 325
    if self._richText1 == nil then
        self._richText1 = QRichText.new("", lineWidth, {stringType = 1, defaultSize = 22, defaultColor = COLORS.a})
        self._richText1:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_tf_desc_1:addChild(self._richText1)
    end
    local str1 = strFunc(self._rivalsFight.heros, buffConfig.ruletext1 or "")
    self._richText1:setString(str1)

    if self._richText2 == nil then
        self._richText2 = QRichText.new("", lineWidth, {stringType = 1, defaultSize = 22, defaultColor = COLORS.a})
        self._richText2:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_tf_desc_2:addChild(self._richText2)
    end
    local str2 = strFunc(self._rivalsFight.main1Heros, buffConfig.ruletext2 or "")
    self._richText2:setString(str2)
end

function QUIDialogTotemChallengeFighterInfo:_checkNPCHero(actorId)
    local fighterInfo = self._fighterInfo.fighter or {}
    for _, heroInfo in pairs(fighterInfo.heros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end
    for _, heroInfo in pairs(fighterInfo.subheros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end
    for _, heroInfo in pairs(fighterInfo.main1Heros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end
    for _, heroInfo in pairs(fighterInfo.sub1heros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end

    return false
end

function QUIDialogTotemChallengeFighterInfo:getActorIdBySoulSpiritId(soulSpiritId)
    local fighterInfo = self._fighterInfo.fighter or {}
    for i, v in pairs(fighterInfo.heros or {}) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
    for i, v in pairs(fighterInfo.subheros or {}) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
    for i, v in pairs(fighterInfo.main1Heros or {}) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
    for i, v in pairs(fighterInfo.sub1heros or {}) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
end

function QUIDialogTotemChallengeFighterInfo:_onTriggerChallenge(event)
	app.sound:playSound("common_small")
    if self._isRefreshAction then
        return
    end

    self._userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()
    if self._userInfoDict then
        if self._userInfoDict.team1IsQuickPass and self._userInfoDict.team2IsQuickPass then
            remote.totemChallenge:responsFightQuickPass(self._userInfoDict.totalNum, function(data)
                if self:safeCheck() then
                    remote.totemChallenge:setDungeonPassRivalPos(self._fighterInfo.rivalPos)
                    local info = {}
                    local rivalsInfo = self._rivalsFight
                    local myInfo = {}
                    myInfo.name = remote.user.nickname
                    myInfo.avatar = remote.user.avatar
                    myInfo.level = remote.user.level
                    local _,_,topNForce = remote.herosUtil:getMaxForceHeros()
                    myInfo.force = topNForce

                    local reward = ""
                    if data.gfQuickResponse and data.gfQuickResponse.totemChallengeFightEndResponse and data.gfQuickResponse.totemChallengeFightEndResponse.fightEndReward then
                        reward = reward..(data.gfQuickResponse.totemChallengeFightEndResponse.fightEndReward.reward or "")
                    end

                    local heroScore, enemyScore = 2, 0
                    local isWin = true

                    info.isTotemChallenge = true
                    info.team1Score = heroScore
                    info.team2Score = enemyScore
                    info.team1avatar = myInfo.avatar
                    info.team2avatar = rivalsInfo.avatar
                    info.team1Name = myInfo.name
                    info.team2Name = rivalsInfo.name
                    info.reward = reward

                    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTotemChallengeBattleResult", 
                        options = {info = info, isWin = isWin, rankInfo = data, rivalId = rivalsInfo.userId, isQuickPass = true}}, {isPopCurrentDialog = true})
                end
            end)
            return
        end
    end

    local arenaArrangement1 = QTotemChallengeArrangement.new({fighterInfo = self._fighterInfo, rivalsFight = self._rivalsFight, teamKey = remote.teamManager.TOTEM_CHALLENGE_TEAM1})
    local arenaArrangement2 = QTotemChallengeArrangement.new({fighterInfo = self._fighterInfo, rivalsFight = self._rivalsFight, teamKey = remote.teamManager.TOTEM_CHALLENGE_TEAM2})
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
        options = {arrangement1 = arenaArrangement1, arrangement2  = arenaArrangement2, widgetClass = "QUIWidgetTotemChallengeTeamBossInfo", 
        fighterInfo = self._rivalsFight, isTotemChallenge = true}})
end

function QUIDialogTotemChallengeFighterInfo:_onTriggerChange(event)
    app.sound:playSound("common_small")
    local cost_num ,isCanRefresh= remote.totemChallenge:getRefreshCost()
    if isCanRefresh then
        local str = string.format("本次更换对手将消耗%s钻石,是否确定更换对手？", cost_num)
        if cost_num == 0 then
            str = "本次更换对手免费,是否确定更换对手？"
        end
        app:alert({content = str, title = "系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                self:refreshRival()
            end
        end})   
    else
        app.tip:floatTip("刷新对手次数已用完，无法刷新")
    end
end

function QUIDialogTotemChallengeFighterInfo:refreshRival()
    remote.totemChallenge:requestTotemChallengeRefresh(handler(self, self.refreshRival2))
end


function QUIDialogTotemChallengeFighterInfo:refreshRival2()
    remote.totemChallenge:requestTotemChallengeFighterInfo(self._dungeonInfo.rivalPos, function(data1) 
            if data1.totemChallengeQueryFightResponse.battle then
                self._isRefreshAction = true
                self._fighterInfo = clone(data1.totemChallengeQueryFightResponse.battle or {})
                self._dungeonInfo = clone( remote.totemChallenge:getTotemChallengeRivalsByrivalPos(self._dungeonInfo.rivalPos) or {})

                local newOptions = self:getOptions()
                newOptions.dungeonInfo = self._dungeonInfo
                newOptions.fighterInfo = self._fighterInfo                
                self:updateInfo()
            end
        end)
end

function QUIDialogTotemChallengeFighterInfo:_updateQuickPassEffect( teamIndex )
    if teamIndex and self["_teamListView"..teamIndex] and self._items[teamIndex] then
        local index = 1
        while true do
            local item = self._items[teamIndex][index]
            if item then
                if (teamIndex == 1 and self._userInfoDict.team1IsQuickPass) or (teamIndex == 2 and self._userInfoDict.team2IsQuickPass) then
                    makeNodeFromNormalToGray(item)
                else
                    makeNodeFromGrayToNormal(item)
                end
                index = index + 1
            else
                break
            end
        end
    end
end

function QUIDialogTotemChallengeFighterInfo:_onTriggerSetQuickPass(e, target)
    if e then
        app.sound:playSound("common_small")
    end

    local setQuickPassFunc = function()
        if self:safeCheck() then
            if target == self._ccbOwner.btn_quickPass_1 then
                -- 一队
                remote.totemChallenge:requestTotemChallengeSetQuickPass(true, nil, function()
                    app.tip:floatTip("神罚成功！对手将失去战斗能力！")
                    if self:safeCheck() then
                        self:_updateQuickPassInfo()
                    end
                end)
            elseif target == self._ccbOwner.btn_quickPass_2 then
                -- 二队
                remote.totemChallenge:requestTotemChallengeSetQuickPass(nil, true, function()
                    app.tip:floatTip("神罚成功！对手将失去战斗能力！")
                    if self:safeCheck() then
                        self:_updateQuickPassInfo()
                    end
                end)
            end
        end
    end

    self._userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo()
    local config = remote.totemChallenge:getDungeonConfigById(self._userInfoDict.totalNum or 1)
    if config and config.must_win_condition then
        local tbl = string.split(config.must_win_condition, "^")
        local itemId = tbl[1]
        local price = tonumber(tbl[2])
        local num = remote.items:getItemsNumByID(itemId)
        if num >= price then
            -- local text = "当前持有海神的庇护符"..num.."个，将消耗"..price.."个道具，对对手小队施以神罚，是否继续？"
            local text = "消耗"..price.."个海神的庇护符，对其施以神罚，是否继续？"
            app:alert({content = text, title = "系统提示", 
                callback = function(state)
                    if state == ALERT_TYPE.CONFIRM then
                        setQuickPassFunc()
                    end
                end, isAnimation = false}, false, false)  
        else
            app.tip:floatTip("海神的庇护符数量不足，无法神罚")
        end
    end
end

function QUIDialogTotemChallengeFighterInfo:_onTriggerDifficultAward(e)
    if e then
        app.sound:playSound("common_small")
    end
    app.tip:wordsTip("困难模式下，光明神力和圣柱币奖励提升20%")
end

function QUIDialogTotemChallengeFighterInfo:_onTriggerHelp(e)
    if e then
        app.sound:playSound("common_small")
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalHelp", options = {helpType = "god_punish_shuoming"}})
end

return QUIDialogTotemChallengeFighterInfo
