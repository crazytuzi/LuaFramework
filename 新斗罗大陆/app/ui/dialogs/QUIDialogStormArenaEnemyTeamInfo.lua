-- @Author: xurui
-- @Date:   2018-11-15 15:59:33
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-27 12:01:52
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStormArenaEnemyTeamInfo = class("QUIDialogStormArenaEnemyTeamInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QScrollView = import("...views.QScrollView")

function QUIDialogStormArenaEnemyTeamInfo:ctor(options)
	local ccbFile = "ccb/Widget_StormArenaBattle_change.ccbi"
    if options.ccbFile then
        ccbFile = options.ccbFile
    end
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogStormArenaEnemyTeamInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._fighterInfo = options.info
    	self._trialNum = options.trialNum
    	self._isDefence = options.isDefence
    end

    self._scrollView = QScrollView.new(self._ccbOwner.node_sheet, self._ccbOwner.sheet_layout:getContentSize(), {bufferMode = 1, nodeAR = ccp(0.5, 0.5), sensitiveDistance = 10})
    self._scrollView:setHorizontalBounce(true)
end

function QUIDialogStormArenaEnemyTeamInfo:viewDidAppear()
	QUIDialogStormArenaEnemyTeamInfo.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogStormArenaEnemyTeamInfo:viewWillDisappear()
  	QUIDialogStormArenaEnemyTeamInfo.super.viewWillDisappear(self)
end

function QUIDialogStormArenaEnemyTeamInfo:setInfo()
    local team1Index = 1
    local force = 0

    local mainHeros = {}
    local helpHeros = {}
    local soulSpirit = {}
    local godArmList = {}
	if self._trialNum == 1 then
        mainHeros = self._fighterInfo.heros or {}
        soulSpirit = self._fighterInfo.soulSpirit or {}
        local subheros = self._fighterInfo.subheros or {}
        helpHeros = remote.teamManager:sortSubHeros(subheros, self._fighterInfo.activeSubActorId, self._fighterInfo.active1SubActorId)
        godArmList = self._fighterInfo.godArm1List or {}

    elseif self._trialNum == 2 then
        mainHeros = self._fighterInfo.main1Heros or {}
        soulSpirit = self._fighterInfo.soulSpirit2 or {}
		local subheros = self._fighterInfo.sub1heros or {}
        helpHeros = remote.teamManager:sortSubHeros(subheros, self._fighterInfo.activeSub2ActorId, self._fighterInfo.active1Sub2ActorId)
        godArmList = self._fighterInfo.godArm2List or {}
    else
        mainHeros = self._fighterInfo.mainHeros3 or {}
        soulSpirit = self._fighterInfo.soulSpirit3 or {}
        local subheros = self._fighterInfo.subheros3 or {}
        helpHeros = remote.teamManager:sortSubHeros(subheros, self._fighterInfo.activeSubActorId3, self._fighterInfo.active1SubActorId3)
        godArmList = self._fighterInfo.godArmList3 or {}

	end

	local totalWidth = 0
    local team1Index = 0
    local scale = 0.7
    local offsetX = 0
    for index, value in ipairs(mainHeros) do
        local heroHead = QUIWidgetHeroHead.new()
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
        self._scrollView:addItemBox(heroHead)

        force = force + (value.force or 0)
    end

    -- if soulSpirit then
    for _,v in pairs(soulSpirit) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHero(v.id)
        heroHead:setLevel(v.level)
        heroHead:setSoulSpiritFrame()
        heroHead:setStar(v.grade)
        heroHead:showSabc()
        heroHead:setScale(scale)
        heroHead:setTeam(1)

        local width = heroHead:getContentSize().width*scale+5
        local height = heroHead:getContentSize().height*scale
        heroHead:setPosition(ccp(team1Index*width+offsetX+width/2, -height/2-18))
        team1Index = team1Index + 1
        totalWidth = totalWidth + width
        self._scrollView:addItemBox(heroHead)

        force = force + (v.force or 0)
    end

    for index,value in ipairs(godArmList) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHero(value.id)
        heroHead:setLevel(value.level)
        heroHead:setTeam(index,false,false,true)
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setTeam(1)
        heroHead:setScale(scale)

        local width = heroHead:getContentSize().width*scale+5
        local height = heroHead:getContentSize().height*scale
        heroHead:setPosition(ccp(team1Index*width+offsetX+width/2, -height/2-18))
        team1Index = team1Index + 1
        totalWidth = totalWidth + width
        heroHead:initGLLayer()
        self._scrollView:addItemBox(heroHead)

        force = force + (value.main_force or 0)         
    end

    for index, value in ipairs(helpHeros) do
        local heroHead = QUIWidgetHeroHead.new()
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
        self._scrollView:addItemBox(heroHead)

        force = force + (value.force or 0)
    end
    self._scrollView:setRect(0, -80, 0, totalWidth+10)

    local num, unit = q.convertLargerNumber(force or 0)
    self._ccbOwner.tf_force:setString(num..(unit or ""))

	local str = "敌方队伍1"
	if self._isDefence then
		str = "我方队伍1"
        if self._trialNum == 2 then
            str = "我方队伍2"
		elseif self._trialNum == 2 then
            str = "我方队伍3"
		end
	else
		if self._trialNum == 2 then
			str = "敌方队伍2"
        elseif self._trialNum == 3 then
            str = "敌方队伍3"
		end
	end
    self._ccbOwner.name:setString(str)

    if self._isDefence then
    	self._ccbOwner.tf_force_title:setString("我方战力：")
    end
end

function QUIDialogStormArenaEnemyTeamInfo:setTeamName( str)
    self._ccbOwner.name:setString(str or "队伍1")
    self._ccbOwner.tf_force_title:setString("")
    self._ccbOwner.tf_force:setString("")
end

function QUIDialogStormArenaEnemyTeamInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogStormArenaEnemyTeamInfo:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogStormArenaEnemyTeamInfo:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogStormArenaEnemyTeamInfo
