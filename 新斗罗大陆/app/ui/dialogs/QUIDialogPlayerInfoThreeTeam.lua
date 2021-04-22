
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPlayerInfoThreeTeam = class("QUIDialogPlayerInfoThreeTeam", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QScrollContain = import("..QScrollContain")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QScrollView = import("...views.QScrollView")
local QUIViewController = import("..QUIViewController")

function QUIDialogPlayerInfoThreeTeam:ctor(options)
	local ccbFile = "ccb/Dialog_PlayerInfo_ThreeTeam.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerClickPVP1", callback = handler(self, self._onTriggerClickPVP1)},   
        {ccbCallbackName = "onTriggerClickPVP2", callback = handler(self, self._onTriggerClickPVP2)}, 
        {ccbCallbackName = "onTriggerClickPVP3", callback = handler(self, self._onTriggerClickPVP3)}, 
    }   
    QUIDialogPlayerInfoThreeTeam.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
    self._fighter = options.fighter
    if self._fighter == nil then
        return
    end
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    q.setButtonEnableShadow(self._ccbOwner.btn_pvp_1)
    q.setButtonEnableShadow(self._ccbOwner.btn_pvp_2)
    q.setButtonEnableShadow(self._ccbOwner.btn_pvp_3)
    self._heroActorIds = {}   -- 存放所有英雄id
    self._heroHeads = {}   -- 存放所有英雄id
    self._heroscrollViews = {}   -- 存放所有英雄id

    self._ccbOwner.frame_tf_title:setString("玩家信息")

    self.teamInfoDataStr = {}
    self.teamInfoDataStr[1] = {heros = "heros"  , soulspirits = "soulSpirit", godarms = "godArm1List" , subheros ="subheros" , activeSub = "activeSubActorId" , activeSub2 = "active1SubActorId"}
    self.teamInfoDataStr[2] = {heros = "main1Heros"  , soulspirits = "soulSpirit2", godarms = "godArm2List" , subheros ="sub1heros" , activeSub = "activeSub2ActorId" , activeSub2 = "active1Sub2ActorId"}
    self.teamInfoDataStr[3] = {heros = "mainHeros3"  , soulspirits = "soulSpirit3", godarms = "godArmList3" , subheros ="subheros3" , activeSub = "activeSubActorId3" , activeSub2 = "active1SubActorId3"}
    for i=1,3 do
        self["_scrollView"..i] =  QScrollView.new(self._ccbOwner["node_sheet"..i], self._ccbOwner["sheet_layout"..i]:getContentSize(), {bufferMode = 1, nodeAR = ccp(0.5, 0.5), sensitiveDistance = 10})
        self["_scrollView"..i]:setHorizontalBounce(true)

        self._ccbOwner["node_pvp_"..i]:setVisible(false)
    end
end

function QUIDialogPlayerInfoThreeTeam:viewDidAppear()
    QUIDialogPlayerInfoThreeTeam.super.viewDidAppear(self)
end

function QUIDialogPlayerInfoThreeTeam:viewWillDisappear()
    QUIDialogPlayerInfoThreeTeam.super.viewWillDisappear(self)
end

function QUIDialogPlayerInfoThreeTeam:setInfo()
    local head = QUIWidgetAvatar.new(self._fighter.avatar or 1001)
    head:setSilvesArenaPeak(self._fighter.championCount)
    self._ccbOwner.node_avatar:addChild( head )

    self._ccbOwner.tf_level:setString( "LV."..(self._fighter.level or 1))
    self._ccbOwner.tf_name:setString(self._fighter.name or "")
    self._ccbOwner.tf_vip:setString( "VIP"..(self._fighter.vip or 0))

    local force = self._fighter.force or 0
    local num, unit = q.convertLargerNumber(force)
    self._ccbOwner.tf_force:setString(num..(unit or ""))
    
    local socityName = self._fighter.consortiaName or ""
    if socityName == nil or socityName == "" then
        socityName = "无"
    end
    self._ccbOwner.tf_society_name:setString(socityName)
    self._ccbOwner.tf_server_name:setString(self._fighter.game_area_name or "")
end

function QUIDialogPlayerInfoThreeTeam:setFormationInfo()

    for i=1,3 do
        local dataStr = self.teamInfoDataStr[i]
        local totalWidth = 0
        local force = 0
        local offsetX = 0
        local teamIndex = 0
        local heroHead = nil
        local teamInfo = self._fighter[dataStr["heros"]] or {}
        for _,v in ipairs(teamInfo) do
            heroHead ,teamIndex , totalWidth = self:getHeroIcon(v,teamIndex , totalWidth)
            self["_scrollView"..i]:addItemBox(heroHead)
            heroHead:setTeam(remote.teamManager.TEAM_INDEX_MAIN)
            force = force + (v.force or 0)     
            table.insert(self._heroHeads, heroHead)           
            table.insert(self._heroActorIds, v.actorId)
            self._heroscrollViews[v.actorId] = i
        end
        teamInfo = self._fighter[dataStr["soulspirits"]] or {}
        for _,v in ipairs(teamInfo) do
            heroHead ,teamIndex , totalWidth = self:getHeroIcon(v,teamIndex , totalWidth)
            self["_scrollView"..i]:addItemBox(heroHead)
            heroHead:setTeam(remote.teamManager.TEAM_INDEX_MAIN,true)
            force = force + (v.force or 0)
            self._heroscrollViews[v.id] = i

        end
        teamInfo = self._fighter[dataStr["godarms"]] or {}
        for ii,v in ipairs(teamInfo) do
            heroHead ,teamIndex , totalWidth = self:getHeroIcon(v,teamIndex , totalWidth)
            heroHead:setTeam(ii,false,false,true)
            self["_scrollView"..i]:addItemBox(heroHead)
            force = force + (v.main_force or 0)
            self._heroscrollViews[v.id] = i

        end    
        local subheros = self._fighter[dataStr["subheros"]] or {}
        local actorId = self._fighter[dataStr["activeSub"]]
        local actorId2 = self._fighter[dataStr["activeSub2"]]
        teamInfo= remote.teamManager:sortSubHeros(subheros, actorId, actorId2)
        for _,v in ipairs(teamInfo) do
            heroHead ,teamIndex , totalWidth = self:getHeroIcon(v,teamIndex , totalWidth)
            self["_scrollView"..i]:addItemBox(heroHead)
            if actorId == v.actorId then
                heroHead:setSkillTeam(1)
            elseif actorId2 == v.actorId then
                heroHead:setSkillTeam(2)
            else
                heroHead:setTeam(remote.teamManager.TEAM_INDEX_HELP)
            end
            self._heroscrollViews[v.actorId] = i

            force = force + (v.force or 0)   
            table.insert(self._heroHeads, heroHead)             
            table.insert(self._heroActorIds, v.actorId)
        end            
        print("teamIndex    "..teamIndex)
        print("totalWidth   "..totalWidth)
        self["_scrollView"..i]:setRect(0, -90, 0, totalWidth)
        local num, unit = q.convertLargerNumber(force)
        self._ccbOwner["tf_force"..i]:setString(num..unit)

        self._ccbOwner["node_pvp_"..i]:setVisible(true)
    end
end

function QUIDialogPlayerInfoThreeTeam:getHeroIcon(info , teamIndex , totalWidth)
    local scale = 0.7
    local heroHead = QUIWidgetHeroHead.new()
    heroHead:setHeroInfo(info)
    heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
    heroHead:setHeadScale(scale)
    local width = heroHead:getContentSize().width*scale+5
    local height = heroHead:getContentSize().height*scale
    heroHead:setPosition(ccp(teamIndex*width+10+width/2, -55))
    teamIndex = teamIndex + 1
    totalWidth = totalWidth + width
    heroHead:initGLLayer()
    return heroHead , teamIndex , totalWidth
end

function QUIDialogPlayerInfoThreeTeam:viewAnimationInHandler()
    if self._isError then
        self:popSelf()
        return
    end
    if self._fighter == nil then
        return
    end
    self:setInfo()
    self:setFormationInfo()
end

function QUIDialogPlayerInfoThreeTeam:getActorIdBySoulSpiritId(soulSpiritId)

    for i=1,3 do
        local dataStr = self.teamInfoDataStr[i]
        for _, v in pairs( self._fighter[dataStr["heros"]] or {}) do
            if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
                return v.actorId
            end
        end
        for _, v in pairs( self._fighter[dataStr["subheros"]] or {}) do
            if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
                return v.actorId
            end
        end        
    end
end

function QUIDialogPlayerInfoThreeTeam:_checkNPCHero(actorId)
    for i=1,3 do
        local dataStr = self.teamInfoDataStr[i]
        for _, heroInfo in pairs( self._fighter[dataStr["heros"]] or {}) do
            if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
                return true
            end
        end
        for _, heroInfo in pairs( self._fighter[dataStr["subheros"]] or {}) do
            if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
                return true
            end
        end        
    end
    return false
end


function QUIDialogPlayerInfoThreeTeam:_onEvent( event )
    if FinalSDK.isHXShenhe() then
        return
    end

    local heroHead = event.target
    local actorId = heroHead:getHeroActorID()

    local scrollViewId = 1
    if self._heroscrollViews[actorId] then
        scrollViewId = self._heroscrollViews[actorId]
    end
    if self["_scrollView"..scrollViewId] and self["_scrollView"..scrollViewId]:isScrollViewMoving() then return end

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
            options = {hero = self._heroActorIds, pos = pos, fighter = self._fighter or {}}})
    end
end



function QUIDialogPlayerInfoThreeTeam:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogPlayerInfoThreeTeam:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogPlayerInfoThreeTeam:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end


function QUIDialogPlayerInfoThreeTeam:_onTriggerClickPVP1(event)
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {fighter = self._fighter, showTeam = true}}, {isPopCurrentDialog = false})
end

function QUIDialogPlayerInfoThreeTeam:_onTriggerClickPVP2(event)
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {fighter2 = self._fighter, showTeam = true}}, {isPopCurrentDialog = false})
end

function QUIDialogPlayerInfoThreeTeam:_onTriggerClickPVP3(event)
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {fighter3 = self._fighter, showTeam = true}}, {isPopCurrentDialog = false})
end

return QUIDialogPlayerInfoThreeTeam

