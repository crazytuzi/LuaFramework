-- 
-- Kumo.Wang
-- 押注阵容对比界面Cell
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaStakeTeamDetail = class("QUIWidgetSilvesArenaStakeTeamDetail", QUIWidget)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")

local NUMBERS = {"一","二","三"}
QUIWidgetSilvesArenaStakeTeamDetail.EVENT_CLICK_HEAD = "EVENT_CLICK_HEAD"
QUIWidgetSilvesArenaStakeTeamDetail.EVENT_CLICK_ONEREPLAY = "EVENT_CLICK_ONEREPLAY"


function QUIWidgetSilvesArenaStakeTeamDetail:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Stake_Team_Detail.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
	}
	QUIWidgetSilvesArenaStakeTeamDetail.super.ctor(self, ccbFile, callBack, options)
    
    q.setButtonEnableShadow(self._ccbOwner.btn_one_replay)
    
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
    self._originalHeight = self._ccbOwner.node_size:getContentSize().height
end

function QUIWidgetSilvesArenaStakeTeamDetail:ininGLLayer(glLayerIndex)
    self._glLayerIndex = glLayerIndex or 1
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_fight_num, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_item_left, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_item_right, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_force_1, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_force_2, self._glLayerIndex)
   
    for i,v in pairs(self._team1Heads or {}) do
        if v then
            self._glLayerIndex = v:initGLLayer(self._glLayerIndex)
        end
    end
    for i,v in pairs(self._team2Heads or {}) do
        if v then
            self._glLayerIndex = v:initGLLayer(self._glLayerIndex)
        end
    end

    return self._glLayerIndex
end

function QUIWidgetSilvesArenaStakeTeamDetail:setInfo(info)
    self._height = self._originalHeight
    self._info = info

    local strSplt = info.strSplit or "第%s场"
	local fightNumStr = string.format(strSplt, NUMBERS[info.player1.silvesArenaFightPos])
	self._ccbOwner.tf_fight_num:setString(fightNumStr)

    local spaceX = 77
    local spaceY = 100
    local curX = 0
    local curY = 0
    local number = 4 -- 一行几个

    local player1 = self._info.player1
    self._ccbOwner.node_item_left:removeAllChildren()
    self._team1Heads = {}
    local team1Force = 0
    -- 主力
    for index, value in ipairs( player1.heros or {} ) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setTeam(1)
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()

        local heroInfo = q.cloneShrinkedObject(db:getCharacterByID(value.actorId))
        local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)
        heroHead:setHeadScale(0.6)
        heroHead:setPosition( curX, curY )

        curX = curX + spaceX
        if curX > spaceX * (number - 1) then
            curX = 0
            curY = curY - spaceY
        end

        heroHead:initGLLayer()
        self._ccbOwner.node_item_left:addChild(heroHead)
        table.insert(self._team1Heads, heroHead)
        team1Force = team1Force + (value.force or 0)
    end
    --魂灵
    for _, value in pairs( player1.soulSpirit or {}) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHero(value.id)
        heroHead:setLevel(value.level)
        heroHead:setInherit(value.devour_level or 0)  
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setTeam(1)
        heroHead:setScale(0.6)
        heroHead:setPosition( curX, curY )

        curX = curX + spaceX
        if curX > spaceX * (number - 1) then
            curX = 0
            curY = curY - spaceY
        end

        heroHead:initGLLayer()
        self._ccbOwner.node_item_left:addChild(heroHead)
        table.insert(self._team1Heads, heroHead)
        team1Force = team1Force + (value.force or 0)
    end
    -- 神器
    for index, value in ipairs( player1.godArm1List or {} ) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHero(value.id)
        heroHead:setLevel(value.level)
        heroHead:setStar(value.grade)
        heroHead:setTeam(index, false, false,true)
        heroHead:showSabc()
        heroHead:setHeadScale(0.6)
        heroHead:setPosition( curX, curY )

        curX = curX + spaceX
        if curX > spaceX * (number - 1) then
            curX = 0
            curY = curY - spaceY
        end

        heroHead:initGLLayer()
        self._ccbOwner.node_item_left:addChild(heroHead)
        table.insert(self._team1Heads, heroHead)
        team1Force = team1Force + (value.force or 0)
    end
    -- --援助1
    -- for index, value in ipairs( player1.subheros or {} ) do
    --     local heroHead = QUIWidgetHeroHead.new()
    --     heroHead:setTeam(2+1)
    --     heroHead:setHeroSkinId(value.skinId)
    --     heroHead:setHero(value.actorId)
    --     heroHead:setLevel(value.level)
    --     heroHead:setBreakthrough(value.breakthrough)
    --     heroHead:setGodSkillShowLevel(value.godSkillGrade)
    --     heroHead:setStar(value.grade)
    --     heroHead:showSabc()

    --     local heroInfo = q.cloneShrinkedObject(db:getCharacterByID(value.actorId))
    --     local profession = heroInfo.func or "dps"
    --     heroHead:setProfession(profession)
    --     heroHead:setHeadScale(0.6)
    --     heroHead:setPosition( curX, curY )

    --     curX = curX + spaceX
    --     if curX > spaceX * (number - 1) then
    --         curX = 0
    --         curY = curY - spaceY
    --     end

    --     heroHead:initGLLayer()
    --     self._ccbOwner.node_item_left:addChild(heroHead)
    --     table.insert(self._team1Heads, heroHead)
    --     team1Force = team1Force + (value.force or 0)
    -- end
    -- --援助2
    -- for index, value in ipairs( player1.sub2heros or {} ) do
    --     local heroHead = QUIWidgetHeroHead.new()
    --     heroHead:setTeam(2+2)
    --     heroHead:setHeroSkinId(value.skinId)
    --     heroHead:setHero(value.actorId)
    --     heroHead:setLevel(value.level)
    --     heroHead:setBreakthrough(value.breakthrough)
    --     heroHead:setGodSkillShowLevel(value.godSkillGrade)
    --     heroHead:setStar(value.grade)
    --     heroHead:showSabc()

    --     local heroInfo = q.cloneShrinkedObject(db:getCharacterByID(value.actorId))
    --     local profession = heroInfo.func or "dps"
    --     heroHead:setProfession(profession)
    --     heroHead:setHeadScale(0.6)
    --     heroHead:setPosition( curX, curY )

    --     curX = curX + spaceX
    --     if curX > spaceX * (number - 1) then
    --         curX = 0
    --         curY = curY - spaceY
    --     end

    --     heroHead:initGLLayer()
    --     self._ccbOwner.node_item_left:addChild(heroHead)
    --     table.insert(self._team1Heads, heroHead)
    --     team1Force = team1Force + (value.force or 0)
    -- end
    -- --援助3
    -- for index, value in ipairs( player1.sub3heros or {} ) do
    --     local heroHead = QUIWidgetHeroHead.new()
    --     heroHead:setTeam(2+3)
    --     heroHead:setHeroSkinId(value.skinId)
    --     heroHead:setHero(value.actorId)
    --     heroHead:setLevel(value.level)
    --     heroHead:setBreakthrough(value.breakthrough)
    --     heroHead:setGodSkillShowLevel(value.godSkillGrade)
    --     heroHead:setStar(value.grade)
    --     heroHead:showSabc()

    --     local heroInfo = q.cloneShrinkedObject(db:getCharacterByID(value.actorId))
    --     local profession = heroInfo.func or "dps"
    --     heroHead:setProfession(profession)
    --     heroHead:setHeadScale(0.6)
    --     heroHead:setPosition( curX, curY )

    --     curX = curX + spaceX
    --     if curX > spaceX * (number - 1) then
    --         curX = 0
    --         curY = curY - spaceY
    --     end

    --     heroHead:initGLLayer()
    --     self._ccbOwner.node_item_left:addChild(heroHead)
    --     table.insert(self._team1Heads, heroHead)
    --     team1Force = team1Force + (value.force or 0)
    -- end

    self._height = -curY + 35
    if player1.force and player1.force ~= 0 then
        team1Force = player1.force
    end
    local num1, unit1 = q.convertLargerNumber(team1Force)
    self._ccbOwner.tf_force_1:setString( num1..(unit1 or "") )

    curX = 0
    curY = 0
    local player2 = self._info.player2
    self._ccbOwner.node_item_right:removeAllChildren()
    self._team2Heads = {}
    local team2Force = 0
    -- 主力
    for index, value in ipairs( player2.heros or {} ) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setTeam(1)
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()

        local heroInfo = q.cloneShrinkedObject(db:getCharacterByID(value.actorId))
        local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)
        heroHead:setHeadScale(0.6)
        heroHead:setPosition( curX, curY )

        curX = curX + spaceX
        if curX > spaceX * (number - 1) then
            curX = 0
            curY = curY - spaceY
        end

        heroHead:initGLLayer()
        self._ccbOwner.node_item_right:addChild(heroHead)
        table.insert(self._team2Heads, heroHead)
        team2Force = team2Force + (value.force or 0)
    end
    --魂灵
    for _, value in pairs( player2.soulSpirit or {}) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHero(value.id)
        heroHead:setLevel(value.level)
        heroHead:setInherit(value.devour_level or 0)  
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setTeam(1)
        heroHead:setScale(0.6)
        heroHead:setPosition( curX, curY )

        curX = curX + spaceX
        if curX > spaceX * (number - 1) then
            curX = 0
            curY = curY - spaceY
        end

        heroHead:initGLLayer()
        self._ccbOwner.node_item_right:addChild(heroHead)
        table.insert(self._team2Heads, heroHead)
        team2Force = team2Force + (value.force or 0)
    end
    -- 神器
    for index, value in ipairs( player2.godArm1List or {} ) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHero(value.id)
        heroHead:setLevel(value.level)
        heroHead:setStar(value.grade)
        heroHead:setTeam(index, false, false,true)
        heroHead:showSabc()
        heroHead:setHeadScale(0.6)
        heroHead:setPosition( curX, curY )

        curX = curX + spaceX
        if curX > spaceX * (number - 1) then
            curX = 0
            curY = curY - spaceY
        end

        heroHead:initGLLayer()
        self._ccbOwner.node_item_right:addChild(heroHead)
        table.insert(self._team2Heads, heroHead)
        team2Force = team2Force + (value.force or 0)
    end
    -- --援助1
    -- for index, value in ipairs( player2.subheros or {} ) do
    --     local heroHead = QUIWidgetHeroHead.new()
    --     heroHead:setTeam(2+1)
    --     heroHead:setHeroSkinId(value.skinId)
    --     heroHead:setHero(value.actorId)
    --     heroHead:setLevel(value.level)
    --     heroHead:setBreakthrough(value.breakthrough)
    --     heroHead:setGodSkillShowLevel(value.godSkillGrade)
    --     heroHead:setStar(value.grade)
    --     heroHead:showSabc()

    --     local heroInfo = q.cloneShrinkedObject(db:getCharacterByID(value.actorId))
    --     local profession = heroInfo.func or "dps"
    --     heroHead:setProfession(profession)
    --     heroHead:setHeadScale(0.6)
    --     heroHead:setPosition( curX, curY )

    --     curX = curX + spaceX
    --     if curX > spaceX * (number - 1) then
    --         curX = 0
    --         curY = curY - spaceY
    --     end

    --     heroHead:initGLLayer()
    --     self._ccbOwner.node_item_right:addChild(heroHead)
    --     table.insert(self._team2Heads, heroHead)
    --     team2Force = team2Force + (value.force or 0)
    -- end
    -- --援助2
    -- for index, value in ipairs( player2.sub2heros or {} ) do
    --     local heroHead = QUIWidgetHeroHead.new()
    --     heroHead:setTeam(2+2)
    --     heroHead:setHeroSkinId(value.skinId)
    --     heroHead:setHero(value.actorId)
    --     heroHead:setLevel(value.level)
    --     heroHead:setBreakthrough(value.breakthrough)
    --     heroHead:setGodSkillShowLevel(value.godSkillGrade)
    --     heroHead:setStar(value.grade)
    --     heroHead:showSabc()

    --     local heroInfo = q.cloneShrinkedObject(db:getCharacterByID(value.actorId))
    --     local profession = heroInfo.func or "dps"
    --     heroHead:setProfession(profession)
    --     heroHead:setHeadScale(0.6)
    --     heroHead:setPosition( curX, curY )

    --     curX = curX + spaceX
    --     if curX > spaceX * (number - 1) then
    --         curX = 0
    --         curY = curY - spaceY
    --     end

    --     heroHead:initGLLayer()
    --     self._ccbOwner.node_item_right:addChild(heroHead)
    --     table.insert(self._team2Heads, heroHead)
    --     team2Force = team2Force + (value.force or 0)
    -- end
    -- --援助3
    -- for index, value in ipairs( player2.sub3heros or {} ) do
    --     local heroHead = QUIWidgetHeroHead.new()
    --     heroHead:setTeam(2+3)
    --     heroHead:setHeroSkinId(value.skinId)
    --     heroHead:setHero(value.actorId)
    --     heroHead:setLevel(value.level)
    --     heroHead:setBreakthrough(value.breakthrough)
    --     heroHead:setGodSkillShowLevel(value.godSkillGrade)
    --     heroHead:setStar(value.grade)
    --     heroHead:showSabc()

    --     local heroInfo = q.cloneShrinkedObject(db:getCharacterByID(value.actorId))
    --     local profession = heroInfo.func or "dps"
    --     heroHead:setProfession(profession)
    --     heroHead:setHeadScale(0.6)
    --     heroHead:setPosition( curX, curY )

    --     curX = curX + spaceX
    --     if curX > spaceX * (number - 1) then
    --         curX = 0
    --         curY = curY - spaceY
    --     end

    --     heroHead:initGLLayer()
    --     self._ccbOwner.node_item_right:addChild(heroHead)
    --     table.insert(self._team2Heads, heroHead)
    --     team2Force = team2Force + (value.force or 0)
    -- end

    if self._height < -curY + 35 then
        self._height = -curY + 35
    end
    self._height = self._height - self._ccbOwner.node_item_right:getPositionY()
    if player2.force and player2.force ~= 0 then
        team2Force = player2.force
    end
    local num2, unit2 = q.convertLargerNumber(team2Force)
    self._ccbOwner.tf_force_2:setString( num2..(unit2 or "") )

    for _, head in pairs(self._team2Heads) do
        if head and head.getHeroSprite then
            local img = head:getHeroSprite()
            if img then
                img:setScaleX( img:getScaleX() * -1 )
            end
        end
    end
end

function QUIWidgetSilvesArenaStakeTeamDetail:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	size.height = self._height
	return size
end

function QUIWidgetSilvesArenaStakeTeamDetail:getInfo()
    return self._info
end

return QUIWidgetSilvesArenaStakeTeamDetail

