-- @Author: xurui
-- @Date:   2019-04-29 10:39:25
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-05-07 17:05:51
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFriendPlayer = class("QUIDialogFriendPlayer", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QScrollView = import("...views.QScrollView")

QUIDialogFriendPlayer.TAB_TEAM = "TAB_TEAM"
QUIDialogFriendPlayer.TAB_MULTIPLE_TEAM = "TAB_MULTIPLE_TEAM"

function QUIDialogFriendPlayer:ctor(options)
	local ccbFile = "ccb/Dialog_Battle_solo.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerTeam", callback = handler(self, self._onTriggerTeam)},
		{ccbCallbackName = "onTriggerMultipleTeam", callback = handler(self, self._onTriggerMultipleTeam)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogFriendPlayer.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._ccbOwner.frame_tf_title:setString("玩家信息")
    self._ccbOwner.tf_level:setString("")
    self._ccbOwner.tf_name:setString("")
    self._ccbOwner.tf_vip:setString("")

    if options then
    	self._callBack = options.callBack
    	self._fighterInfo = options.fighter     -- 一小队信息
    	self._tab = options.tab
    end
    if self._tab == nil then
    	self._tab = QUIDialogFriendPlayer.TAB_TEAM
    end

    self._heroActorIds = {}   -- 存放当前阵容英雄id
    self._heroMultipleActorIds = {}   -- 存放当前阵容英雄id
    self._teamFighterInfo = {} 
    self._multipleFighterInfo = {} 

    --一小队阵容
    self._scrollView = QScrollView.new(self._ccbOwner.node_sheet, self._ccbOwner.sheet_layout:getContentSize(), {bufferMode = 1, nodeAR = ccp(0.5, 0.5), sensitiveDistance = 10})
    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewEvent))
    self._scrollView:addEventListener(QScrollView.GESTURE_END, handler(self, self._onScrollViewEvent))
    self._scrollView:setHorizontalBounce(true)

    --两小队阵容
    self._scrollView1 = QScrollView.new(self._ccbOwner.node_sheet1, self._ccbOwner.sheet_layout1:getContentSize(), {bufferMode = 1, nodeAR = ccp(0.5, 0.5), sensitiveDistance = 10})
    self._scrollView1:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewEvent))
    self._scrollView1:addEventListener(QScrollView.GESTURE_END, handler(self, self._onScrollViewEvent))
    self._scrollView1:setHorizontalBounce(true)

    self._scrollView2 = QScrollView.new(self._ccbOwner.node_sheet2, self._ccbOwner.sheet_layout2:getContentSize(), {bufferMode = 1, nodeAR = ccp(0.5, 0.5), sensitiveDistance = 10})
    self._scrollView2:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewEvent))
    self._scrollView2:addEventListener(QScrollView.GESTURE_END, handler(self, self._onScrollViewEvent))
    self._scrollView2:setHorizontalBounce(true)
end

function QUIDialogFriendPlayer:viewDidAppear()
	QUIDialogFriendPlayer.super.viewDidAppear(self)

	self:setFighterInfo()
end

function QUIDialogFriendPlayer:viewWillDisappear()
  	QUIDialogFriendPlayer.super.viewWillDisappear(self)
end

function QUIDialogFriendPlayer:setFighterInfo()
    local head = QUIWidgetAvatar.new(self._fighterInfo.avatar or 1001)
    head:setSilvesArenaPeak(self._fighterInfo.championCount)
    self._ccbOwner.node_avatar:addChild( head )

    self._ccbOwner.tf_level:setString( "LV."..(self._fighterInfo.level or 1))
    self._ccbOwner.tf_name:setString(self._fighterInfo.name or "")
    self._ccbOwner.tf_vip:setString( "VIP"..(self._fighterInfo.vip or 0))
    q.autoLayerNode({self._ccbOwner.tf_level, self._ccbOwner.tf_name, self._ccbOwner.tf_vip}, "x", 10)

    local socityName = self._fighterInfo.consortiaName or ""
    if socityName == nil or socityName == "" then
    	socityName = "无"
    end
    self._ccbOwner.tf_special_value:setString(socityName)

    local options = self:getOptions()
    if options.specialTitle1 then
        self._ccbOwner.tf_special_name:setString(options.specialTitle1)
        self._ccbOwner.tf_special_value:setString(options.specialValue1 or 0)
    end

    self:selectTab()
end

function QUIDialogFriendPlayer:selectTab()
	local isTeamTab = self._tab == QUIDialogFriendPlayer.TAB_TEAM
	self._ccbOwner.btn_team:setEnabled(not isTeamTab)
	self._ccbOwner.btn_team:setHighlighted(isTeamTab)

	local isMultipleTeamTab = self._tab == QUIDialogFriendPlayer.TAB_MULTIPLE_TEAM
	self._ccbOwner.btn_multipleTeam:setEnabled(not isMultipleTeamTab)
	self._ccbOwner.btn_multipleTeam:setHighlighted(isMultipleTeamTab)

	self._ccbOwner.node_team:setVisible(isTeamTab)
	self._ccbOwner.node_multipleTeam:setVisible(isMultipleTeamTab)


	if isTeamTab then
		if q.isEmpty(self._teamFighterInfo) then
			self._teamFighterInfo = self._fighterInfo
			self:setTeamList()
            self:updateForce(self._teamFighterInfo)
		else
            self:updateForce(self._teamFighterInfo)
        end
	elseif isMultipleTeamTab then
		if q.isEmpty(self._multipleFighterInfo) then
			remote.stormArena:stormArenaQueryDefenseHerosRequest(self._fighterInfo.userId, function(data)
				if self:safeCheck() then
					self._multipleFighterInfo = (data.towerFightersDetail or {})[1] or {}
					self:setMultipleTeamList()
                    self:updateForce(self._multipleFighterInfo)
				end
			end, function ()
                self:setMultipleForce(0, 0)
            end)
		else
            self:updateForce(self._multipleFighterInfo)
        end
	end
end

function QUIDialogFriendPlayer:updateForce(fighterInfo)
    local force = fighterInfo.force or 0
    local num, unit = q.convertLargerNumber(force)
    self._ccbOwner.tf_force:setString(num..(unit or ""))
end

function QUIDialogFriendPlayer:setTeamList()
    self._heroHeads = {}
    local totalWidth = 0
    local headIndex = 0
    local offsetX = 55
    local offsetY = -65
    local lineDistance = -15
	local setHeroFunc = function(heros, teamIndex)
		local force = 0
	    for index, value in ipairs(heros) do
	        local heroHead = QUIWidgetHeroHead.new()
	        headIndex = headIndex + 1
            heroHead:setTeam(teamIndex)
            if value.actorId then
	            heroHead:setHeroSkinId(value.skinId)
	            heroHead:setHero(value.actorId)
                heroHead:setBreakthrough(value.breakthrough)
                heroHead:setGodSkillShowLevel(value.godSkillGrade)
                local heroInfo = q.cloneShrinkedObject(db:getCharacterByID(value.actorId))
                local profession = heroInfo.func or "dps"
                heroHead:setProfession(profession)
            else
                heroHead:setHero(value.id)
                heroHead:setSoulSpiritFrame()
                heroHead:setInherit(value.devour_level or 0)  
            end
	        heroHead:setLevel(value.level)
	        heroHead:setStar(value.grade)
	        heroHead:showSabc()

	        heroHead:setHeadScale(0.8)
	        heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
	        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
	       	totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

	        heroHead:initGLLayer()
	        self._scrollView:addItemBox(heroHead)
            table.insert(self._heroHeads, heroHead)
	        table.insert(self._heroActorIds, value.actorId)
	    end

	    return force
	end

    local team1MainHeros = self._teamFighterInfo.heros or {}
    setHeroFunc(team1MainHeros, 1)

    local team1SoulSpirit = self._teamFighterInfo.soulSpirit or {}
     setHeroFunc(team1SoulSpirit, 1)

    local team1GodarmIds = self._teamFighterInfo.godArm1List or {}
    if team1GodarmIds then
        setHeroFunc(team1GodarmIds, 5)
    end
    local subheros = self._teamFighterInfo.subheros or {}
    setHeroFunc(subheros, 2+1)

    local sub2heros = self._teamFighterInfo.sub2heros or {}
    setHeroFunc(sub2heros, 2+2)

    local sub3heros = self._teamFighterInfo.sub3heros or {}
    setHeroFunc(sub3heros, 2+3)

    self._scrollView:setRect(0, -100, 0, totalWidth)
end

function QUIDialogFriendPlayer:setMultipleTeamList()
    self._heroHeads = {}
    -- team1
    local totalWidth = 0
    local teamIndex = 0
    local scale = 0.7
    local offsetX = 0
    local height = -0
    local force1 = 0
	local setHeroFunc = function(heros, scrollView, isHelp)
		local force = 0
	    for index, value in ipairs(heros) do
	        local heroHead = QUIWidgetHeroHead.new()
	        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
            if value.actorId then
                heroHead:setHeroSkinId(value.skinId)
                heroHead:setHero(value.actorId)
                heroHead:setBreakthrough(value.breakthrough)
                heroHead:setGodSkillShowLevel(value.godSkillGrade)
                local heroInfo = q.cloneShrinkedObject(db:getCharacterByID(value.actorId))
                local profession = heroInfo.func or "dps"
                heroHead:setProfession(profession)
            else
                heroHead:setHero(value.id)
                heroHead:setSoulSpiritFrame()
                heroHead:setInherit(value.devour_level or 0)  
            end
	        heroHead:setLevel(value.level)
	        heroHead:setStar(value.grade)
	        heroHead:showSabc()
	        heroHead:setScale(scale)

	      	if not isHelp then
	        	heroHead:setTeam(1)
		    else
		        if index <= 2 then
		            heroHead:setSkillTeam(index)
		        else
		            heroHead:setTeam(2)
		        end
		    end


	        local width = heroHead:getContentSize().width*scale+5
	        local height = heroHead:getContentSize().height*scale
	        heroHead:setPosition(ccp(teamIndex*width+offsetX+width/2, -height/2-18))
	        teamIndex = teamIndex + 1
	        totalWidth = totalWidth + width
	        heroHead:initGLLayer()
	      	scrollView:addItemBox(heroHead)
            table.insert(self._heroHeads, heroHead)
	        table.insert(self._heroMultipleActorIds, value.actorId)
	        force = force + (value.force or 0)
	    end

	    return force
	end

    local team1MainHeros = self._multipleFighterInfo.heros or {}
    force1 = force1 + setHeroFunc(team1MainHeros, self._scrollView1, false)

    local team1SoulSpirit = self._multipleFighterInfo.soulSpirit or {}
    force1 = force1 + setHeroFunc(team1SoulSpirit, self._scrollView1, false)

    local team1GodarmIds = self._multipleFighterInfo.godArm1List or {}
    if team1GodarmIds then
        force1 = force1 + setHeroFunc(team1GodarmIds, self._scrollView1, false)
    end

    local subheros = self._multipleFighterInfo.subheros or {}
    local team1HelpHeros = remote.teamManager:sortSubHeros(subheros, self._multipleFighterInfo.activeSubActorId, self._multipleFighterInfo.active1SubActorId)
    force1 = force1 + setHeroFunc(team1HelpHeros, self._scrollView1, true)

    self._scrollView1:setRect(0, -100, 0, totalWidth)

    -- team2
    local force2 = 0
    totalWidth = 0
    teamIndex = 0
    local team2MainHeros = self._multipleFighterInfo.main1Heros or {}
    force2 = force2 + setHeroFunc(team2MainHeros, self._scrollView2, false)
    
    local team2SoulSpirit = self._multipleFighterInfo.soulSpirit2 or {}
    if team2SoulSpirit then
        force2 = force2 + setHeroFunc(team2SoulSpirit, self._scrollView2, false)
    end

    local team2GodarmIds = self._multipleFighterInfo.godArm2List or {}
    if team2GodarmIds then
        force1 = force1 + setHeroFunc(team2GodarmIds, self._scrollView2, false)
    end

    local subheros = self._multipleFighterInfo.sub1heros or {}
    local team2HelpHeros = remote.teamManager:sortSubHeros(subheros, self._multipleFighterInfo.activeSub2ActorId, self._multipleFighterInfo.active1Sub2ActorId)
    force2 = force2 + setHeroFunc(team2HelpHeros, self._scrollView2, true)

    self._scrollView2:setRect(0, -100, 0, totalWidth)

    self:setMultipleForce(force1, force2)
end

function QUIDialogFriendPlayer:setMultipleForce(force1, force2)
    local num, unit = q.convertLargerNumber(force1)
    self._ccbOwner.tf_force1:setString(num..unit)
    local num, unit = q.convertLargerNumber(force2)
    self._ccbOwner.tf_force2:setString(num..unit)
end

function QUIDialogFriendPlayer:_onScrollViewEvent( event )
	if event.name == QScrollView.GESTURE_MOVING then
		self._isMoving = true
	elseif event.name == QScrollView.GESTURE_END then
		scheduler.performWithDelayGlobal(function()
			self._isMoving = false
			end, 0.1)
	end
end

function QUIDialogFriendPlayer:getActorIdBySoulSpiritId(soulSpiritId)
    if self._tab == QUIDialogFriendPlayer.TAB_TEAM then
        for i, v in pairs(self._teamFighterInfo.heros or {}) do
            if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
                return v.actorId
            end
        end
        for i, v in pairs(self._teamFighterInfo.subheros or {}) do
            if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
                return v.actorId
            end
        end
        for i, v in pairs(self._teamFighterInfo.sub2heros or {}) do
            if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
                return v.actorId
            end
        end
        for i, v in pairs(self._teamFighterInfo.sub3heros or {}) do
            if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
                return v.actorId
            end
        end
    else
        for i, v in pairs(self._multipleFighterInfo.heros or {}) do
            if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
                return v.actorId
            end
        end
        for i, v in pairs(self._multipleFighterInfo.subheros or {}) do
            if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
                return v.actorId
            end
        end
        for i, v in pairs(self._multipleFighterInfo.main1Heros or {}) do
            if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
                return v.actorId
            end
        end
        for i, v in pairs(self._multipleFighterInfo.sub1heros or {}) do
            if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
                return v.actorId
            end
        end
    end
end

function QUIDialogFriendPlayer:_onEvent( event )
    if self._isMoving then return end

    if event.name == QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK then
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
        	local heroActorIds = self._heroActorIds
        	local fighterInfo = self._fighterInfo
        	if self._tab == QUIDialogFriendPlayer.TAB_MULTIPLE_TEAM then
        		heroActorIds = self._heroMultipleActorIds
        		fighterInfo = self._multipleFighterInfo
        	end
            local pos = 0
            for i, id in ipairs(heroActorIds) do
                if id == actorId then
                    pos = i
                    break
                end
            end
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroInfo", 
                options = {hero = heroActorIds, pos = pos, fighter = fighterInfo or {}}})
        end
    end
end

function QUIDialogFriendPlayer:_checkNPCHero(actorId)
	local checkFunc = function(heros)
        for _, heroInfo in pairs(heros) do
	        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
	            return true
	        end
	    end
	    return false
	end

    if self._tab == QUIDialogFriendPlayer.TAB_TEAM then
    	if checkFunc(self._fighterInfo.heros or {}) then
    		return true
    	end
    	if checkFunc(self._fighterInfo.subheros or {}) then
    		return true
    	end
    	if checkFunc(self._fighterInfo.sub2heros or {}) then
    		return true
    	end
    	if checkFunc(self._fighterInfo.sub3heros or {}) then
    		return true
    	end
    elseif self._tab == QUIDialogFriendPlayer.TAB_MULTIPLE_TEAM then
    	if checkFunc(self._multipleFighterInfo.heros or {}) then
    		return true
    	end
    	if checkFunc(self._multipleFighterInfo.subheros or {}) then
    		return true
    	end
    	if checkFunc(self._multipleFighterInfo.main1Heros or {}) then
    		return true
    	end
    	if checkFunc(self._multipleFighterInfo.sub1heros or {}) then
    		return true
    	end
    end
    return false
end

function QUIDialogFriendPlayer:_onTriggerTeam(event)
	if self._tab == QUIDialogFriendPlayer.TAB_TEAM then return end
  	app.sound:playSound("common_small")

  	self._tab = QUIDialogFriendPlayer.TAB_TEAM
  	self:selectTab()
end

function QUIDialogFriendPlayer:_onTriggerMultipleTeam(event)
	if self._tab == QUIDialogFriendPlayer.TAB_MULTIPLE_TEAM  then return end
  	app.sound:playSound("common_small")

  	self._tab = QUIDialogFriendPlayer.TAB_MULTIPLE_TEAM
  	self:selectTab()
end

function QUIDialogFriendPlayer:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogFriendPlayer:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogFriendPlayer:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogFriendPlayer
