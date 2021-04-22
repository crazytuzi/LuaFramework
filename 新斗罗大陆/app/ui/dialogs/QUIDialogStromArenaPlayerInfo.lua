-- @Author: xurui
-- @Date:   2018-11-13 15:26:32
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-04 22:09:35
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStromArenaPlayerInfo = class("QUIDialogStromArenaPlayerInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QScrollView = import("...views.QScrollView")

function QUIDialogStromArenaPlayerInfo:ctor(options)
	local ccbFile = "ccb/Dialog_StormArena_wanjiaxinxi.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerClickPVP1", callback = handler(self, self._onTriggerClickPVP1)},   
        {ccbCallbackName = "onTriggerClickPVP2", callback = handler(self, self._onTriggerClickPVP2)},   
    }
    QUIDialogStromArenaPlayerInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._fighterInfo = options.fighterInfo
        self._isPVP = options.isPVP
    end

    self._ccbOwner.frame_tf_title:setString("玩家信息")
    self._heroActorIds = {}   -- 存放所有英雄id

    self._scrollView1 = QScrollView.new(self._ccbOwner.node_sheet1, self._ccbOwner.sheet_layout1:getContentSize(), {bufferMode = 1, nodeAR = ccp(0.5, 0.5), sensitiveDistance = 10})
    self._scrollView1:setHorizontalBounce(true)

    self._scrollView2 = QScrollView.new(self._ccbOwner.node_sheet2, self._ccbOwner.sheet_layout2:getContentSize(), {bufferMode = 1, nodeAR = ccp(0.5, 0.5), sensitiveDistance = 10})
    self._scrollView2:setHorizontalBounce(true)
end

function QUIDialogStromArenaPlayerInfo:viewDidAppear()
	QUIDialogStromArenaPlayerInfo.super.viewDidAppear(self)

	self:setFighterInfo()
end

function QUIDialogStromArenaPlayerInfo:viewWillDisappear()
  	QUIDialogStromArenaPlayerInfo.super.viewWillDisappear(self)
end

function QUIDialogStromArenaPlayerInfo:setFighterInfo()
    local head = QUIWidgetAvatar.new(self._fighterInfo.avatar or 1001)
    head:setSilvesArenaPeak(self._fighterInfo.championCount)
    self._ccbOwner.node_avatar:addChild( head )

    self._ccbOwner.tf_level:setString( "LV."..(self._fighterInfo.level or 1))
    self._ccbOwner.tf_name:setString(self._fighterInfo.name or "")
    self._ccbOwner.tf_vip:setString( "VIP"..(self._fighterInfo.vip or 0))

    local force = self._fighterInfo.force or 0
    local num, unit = q.convertLargerNumber(force)
    self._ccbOwner.tf_force:setString(num..(unit or ""))
    
    local socityName = self._fighterInfo.consortiaName or ""
    if socityName == nil or socityName == "" then
    	socityName = "无"
    end
    self._ccbOwner.tf_special_value:setString(socityName)
	self._ccbOwner.tf_server_name:setString(self._fighterInfo.game_area_name or "")

    local options = self:getOptions()
    if options.specialTitle1 then
        self._ccbOwner.tf_special_name:setString(options.specialTitle1)
        self._ccbOwner.tf_special_value:setString(options.specialValue1 or 0)
    end

	self:setTeamList()
end

function QUIDialogStromArenaPlayerInfo:setTeamList()
    self._heroHeads = {}
    -- team1
    local totalWidth = 0
    local team1Index = 0
    local scale = 0.7
    local offsetX = 0
    local height = 0
    local force1 = 0
    local team1MainHeros = self._fighterInfo.heros or {}
    for index, value in ipairs(team1MainHeros) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        heroHead:setTeam(1)
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setScale(scale)

        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
        local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)

        local width = heroHead:getContentSize().width*scale+5
        local height = heroHead:getContentSize().height*scale
        heroHead:setPosition(ccp(team1Index*width+offsetX+width/2, -height/2-18))
        team1Index = team1Index + 1
        totalWidth = totalWidth + width
        heroHead:initGLLayer()
        self._scrollView1:addItemBox(heroHead)
        table.insert(self._heroHeads, heroHead)
        table.insert(self._heroActorIds, value.actorId)

        force1 = force1 + value.force
    end
    
    local team1SoulSpirit = self._fighterInfo.soulSpirit or {}
    for index, value in ipairs( team1SoulSpirit ) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        heroHead:setTeam(1)
        heroHead:setHeroInfo(value)
        heroHead:showSabc()
        heroHead:setScale(scale)

        local width = heroHead:getContentSize().width*scale+5
        local height = heroHead:getContentSize().height*scale
        heroHead:setPosition(ccp(team1Index*width+offsetX+width/2, -height/2-18))
        team1Index = team1Index + 1
        totalWidth = totalWidth + width
        heroHead:initGLLayer()
        self._scrollView1:addItemBox(heroHead)

        force1 = force1 + (value.force or 0)
    end
    -- 神器1小队
    local team1GodarmList = self._fighterInfo.godArm1List or {}
    for index, value in ipairs( team1GodarmList ) do
            local heroHead = QUIWidgetHeroHead.new()
            heroHead:setHero(value.id)
            heroHead:setLevel(value.level)
            heroHead:setTeam(index,false,false,true)
            heroHead:setStar(value.grade)
            heroHead:showSabc()
            heroHead:setTeam(1)
            heroHead:setScale(scale)
            heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
            local width = heroHead:getContentSize().width*scale+5
            local height = heroHead:getContentSize().height*scale
            heroHead:setPosition(ccp(team1Index*width+offsetX+width/2, -height/2-18))
            team1Index = team1Index + 1
            totalWidth = totalWidth + width
            heroHead:initGLLayer()
            self._scrollView1:addItemBox(heroHead)

            force1 = force1 + (value.main_force or 0)     
    end

    local subheros = self._fighterInfo.subheros or {}
    local team1HelpHeros = remote.teamManager:sortSubHeros(subheros, self._fighterInfo.activeSubActorId, self._fighterInfo.active1SubActorId)
    for index, value in ipairs(team1HelpHeros) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setScale(scale)
        if index <= 2 then
            heroHead:setSkillTeam(index)
        else
            heroHead:setTeam(2)
        end
        
        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
        local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)

        local width = heroHead:getContentSize().width*scale+5
        local height = heroHead:getContentSize().height*scale
        heroHead:setPosition(ccp(team1Index*width+offsetX+width/2, -height/2-18))
        team1Index = team1Index + 1
        totalWidth = totalWidth + width

        heroHead:initGLLayer()
        self._scrollView1:addItemBox(heroHead)
        table.insert(self._heroHeads, heroHead)
        table.insert(self._heroActorIds, value.actorId)

        force1 = force1 + value.force
    end
    self._scrollView1:setRect(0, -80, 0, totalWidth)

    -- team2
    totalWidth = 0
    local force2 = 0
    local team2Index = 0
    local team2MainHeros = self._fighterInfo.main1Heros or {}
    for index, value in ipairs(team2MainHeros) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        heroHead:setTeam(1)
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setScale(scale)

        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
        local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)
        
        local width = heroHead:getContentSize().width*scale+5
        local height = heroHead:getContentSize().height*scale
        heroHead:setPosition(ccp(team2Index*width+offsetX+width/2, -height/2-18))
        team2Index = team2Index + 1
        totalWidth = totalWidth + width

        heroHead:initGLLayer()
        self._scrollView2:addItemBox(heroHead)
        table.insert(self._heroHeads, heroHead)
        table.insert(self._heroActorIds, value.actorId)

        force2 = force2 + value.force
    end

    local team2SoulSpirit = self._fighterInfo.soulSpirit2 or {}
    for index, value in ipairs(team2SoulSpirit) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        heroHead:setTeam(1)
        heroHead:setHeroInfo(value)
        heroHead:showSabc()
        heroHead:setScale(scale)

        local width = heroHead:getContentSize().width*scale+5
        local height = heroHead:getContentSize().height*scale
        heroHead:setPosition(ccp(team2Index*width+offsetX+width/2, -height/2-18))
        team2Index = team2Index + 1
        totalWidth = totalWidth + width
        heroHead:initGLLayer()
        self._scrollView2:addItemBox(heroHead)

        force2 = force2 + (value.force or 0)
    end
    -- 神器2小队
    local team2GodarmList = self._fighterInfo.godArm2List or {}
    for index, value in ipairs( team2GodarmList ) do
            local heroHead = QUIWidgetHeroHead.new()
            heroHead:setHero(value.id)
            heroHead:setLevel(value.level)
            heroHead:setStar(value.grade)
            heroHead:setTeam(index,false,false,true)
            heroHead:setScale(scale)
            heroHead:showSabc()
            heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
            local width = heroHead:getContentSize().width*scale+5
            local height = heroHead:getContentSize().height*scale
            heroHead:setPosition(ccp(team2Index*width+offsetX+width/2, -height/2-18))
            team2Index = team2Index + 1
            totalWidth = totalWidth + width
            heroHead:initGLLayer()
            self._scrollView2:addItemBox(heroHead)

            force2 = force2 + (value.main_force or 0)     
    end

    local subheros = self._fighterInfo.sub1heros or {}
    local team2HelpHeros = remote.teamManager:sortSubHeros(subheros, self._fighterInfo.activeSub2ActorId, self._fighterInfo.active1Sub2ActorId)
    for index, value in ipairs(team2HelpHeros) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setScale(scale)
        if index <= 2 then
            heroHead:setSkillTeam(index)
        else
            heroHead:setTeam(2)
        end
        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
        local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)

        local width = heroHead:getContentSize().width*scale+5
        local height = heroHead:getContentSize().height*scale
        heroHead:setPosition(ccp(team2Index*width+offsetX+width/2, -height/2-18))
        team2Index = team2Index + 1
        totalWidth = totalWidth + width

        heroHead:initGLLayer()
        self._scrollView2:addItemBox(heroHead)
        table.insert(self._heroHeads, heroHead)
        table.insert(self._heroActorIds, value.actorId)

        force2 = force2 + value.force
    end

    self._scrollView2:setRect(0, -100, 0, totalWidth)

    self._ccbOwner.node_pvp_1:setVisible(false)
    self._ccbOwner.node_pvp_2:setVisible(false)
    if ENABLE_PVP_FORCE and self._isPVP then
        self._ccbOwner.node_pvp_1:setVisible(true)
        self._ccbOwner.node_pvp_2:setVisible(true)
    end
    local num, unit = q.convertLargerNumber(force1)
    self._ccbOwner.tf_force1:setString(num..unit)
    local num, unit = q.convertLargerNumber(force2)
    self._ccbOwner.tf_force2:setString(num..unit)
end

function QUIDialogStromArenaPlayerInfo:getActorIdBySoulSpiritId(soulSpiritId)
    for i, v in pairs(self._fighterInfo.heros or {}) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
    for i, v in pairs(self._fighterInfo.subheros or {}) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
    for i, v in pairs(self._fighterInfo.main1Heros or {}) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
    for i, v in pairs(self._fighterInfo.sub1heros or {}) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
end

function QUIDialogStromArenaPlayerInfo:_onEvent( event )
    if FinalSDK.isHXShenhe() then
        return
    end

    local heroHead = event.target
    local actorId = heroHead:getHeroActorID()
    if heroHead:getIsSoulSpirit() then
        actorId = self:getActorIdBySoulSpiritId(actorId)
        if not actorId then
            app.tip:floatTip("该魂灵还没有护佑魂师")
            return
        end
        local heroHead = nil
        for i, v in pairs(self._heroHeads) do
            if v:getHeroActorID() == actorId then
                heroHead = v
                break
            end
        end
        if not heroHead then
            app.tip:floatTip("该魂灵护佑的魂师不在队伍里")
            return
        end
    end
    
    if heroHead:getIsGodarm() then
        app.tip:floatTip("该神器已经上阵")
        return
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
            options = {hero = self._heroActorIds, pos = pos, fighter = self._fighterInfo or {}}})
    end
end

function QUIDialogStromArenaPlayerInfo:_checkNPCHero(actorId)
    for _, heroInfo in pairs(self._fighterInfo.heros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end
    for _, heroInfo in pairs(self._fighterInfo.subheros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end
    for _, heroInfo in pairs(self._fighterInfo.main1Heros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end
    for _, heroInfo in pairs(self._fighterInfo.sub1heros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end

    return false
end

function QUIDialogStromArenaPlayerInfo:_onTriggerClickPVP1(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp_1) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {fighter = self._fighterInfo, showTeam = true}}, {isPopCurrentDialog = false})
end

function QUIDialogStromArenaPlayerInfo:_onTriggerClickPVP2(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp_2) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {fighter2 = self._fighterInfo, showTeam = true}}, {isPopCurrentDialog = false})
end

function QUIDialogStromArenaPlayerInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogStromArenaPlayerInfo:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogStromArenaPlayerInfo:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogStromArenaPlayerInfo
