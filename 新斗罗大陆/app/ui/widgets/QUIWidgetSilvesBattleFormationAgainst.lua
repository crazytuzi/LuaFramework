--
-- Kumo.Wang
-- 西尔维斯大斗魂场出战布阵界面元素
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesBattleFormationAgainst = class("QUIWidgetSilvesBattleFormationAgainst", QUIWidget)

local QScrollContain = import("..QScrollContain")

local QUIWidgetHeroHead = import(".QUIWidgetHeroHead")
local QUIWidgetHeroHeadSketch = import(".QUIWidgetHeroHeadSketch")

function QUIWidgetSilvesBattleFormationAgainst:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Battle_Against.ccbi"
  	local callBacks = {}
	QUIWidgetSilvesBattleFormationAgainst.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSilvesBattleFormationAgainst:onEnter()
	QUIWidgetSilvesBattleFormationAgainst.super.onEnter(self)
end

function QUIWidgetSilvesBattleFormationAgainst:onExit()
	QUIWidgetSilvesBattleFormationAgainst.super.onExit(self)

    if self._scrollViewPlayer then
        self._scrollViewPlayer:disappear()
        self._scrollViewPlayer = nil
    end

    if self._scrollViewEnemy then
        self._scrollViewEnemy:disappear()
        self._scrollViewEnemy = nil
    end
end

function QUIWidgetSilvesBattleFormationAgainst:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSilvesBattleFormationAgainst:getPlayerInfo()
	return self._playerInfo
end

function QUIWidgetSilvesBattleFormationAgainst:getEnemyInfo()
    return self._enemyInfo
end


function QUIWidgetSilvesBattleFormationAgainst:update(playerData, enemyData)
	if q.isEmpty(playerData) or (q.isEmpty(self._enemyInfo) and q.isEmpty(enemyData)) then
		return
	end

    self._playerInfo = playerData
    if not q.isEmpty(enemyData) then
	   self._enemyInfo = enemyData
    end

	if self._playerInfo.clickPos then
		if self._playerInfo.clickPos == self._playerInfo.silvesArenaFightPos then
			self._ccbOwner.node_btn_click:setVisible(false)			
		else
			self._ccbOwner.node_btn_click:setVisible(true)			
			self._ccbOwner.tf_btn_click:setString("替 换")
		end
	else
		self._ccbOwner.node_btn_click:setVisible(true)			
		self._ccbOwner.tf_btn_click:setString("互 换")
	end
end

function QUIWidgetSilvesBattleFormationAgainst:setInfo(playerData, enemyData)
	self:update(playerData, enemyData)
	self._ccbOwner.node_normal:setVisible(true)
    
	self._ccbOwner.tf_index:setVisible(false)
	if self._playerInfo.silvesArenaFightPos then
		self._ccbOwner.tf_index:setString("队伍"..self._playerInfo.silvesArenaFightPos.."：")
		self._ccbOwner.tf_index:setVisible(true)
	end

	self._ccbOwner.tf_player_force:setVisible(false)
	if self._playerInfo.force then
		local num, unit = q.convertLargerNumber(self._playerInfo.force)
		self._ccbOwner.tf_player_force:setString(num..(unit or ""))
		self._ccbOwner.tf_player_force:setVisible(true)
    else
        self._ccbOwner.tf_player_force:setString("?????")
        self._ccbOwner.tf_player_force:setVisible(true)
	end

    self._ccbOwner.tf_player_name:setVisible(false)
    if self._playerInfo.name then
        self._ccbOwner.tf_player_name:setString(self._playerInfo.name)
        self._ccbOwner.tf_player_name:setVisible(true)
    else
        self._ccbOwner.tf_player_name:setString("?????")
        self._ccbOwner.tf_player_name:setVisible(true)
    end
    self._ccbOwner.sp_captain:setVisible(self._playerInfo.isCaptain)


    self._ccbOwner.sp_vs:setVisible(true)


    self._ccbOwner.tf_enemy_title:setVisible(true)
    self._ccbOwner.tf_enemy_force:setVisible(false)
    self._ccbOwner.tf_enemy_name:setVisible(false)
    self._ccbOwner.btn_enemy_detail:setVisible(false)

    if self._enemyInfo.silvesArenaFightPos and self._enemyInfo.silvesArenaFightPos == remote.silvesArena.MAX_TEAM_MEMBER_COUNT then
        self._ccbOwner.tf_enemy_title:setString("敌方阵容不可查看")
    else
        if self._enemyInfo.force then
            local num, unit = q.convertLargerNumber(self._enemyInfo.force)
            self._ccbOwner.tf_enemy_force:setString(num..(unit or ""))
            self._ccbOwner.tf_enemy_force:setVisible(true)
        else
            self._ccbOwner.tf_enemy_force:setString("?????")
            self._ccbOwner.tf_enemy_force:setVisible(true)
        end

        self._ccbOwner.tf_enemy_name:setVisible(false)
        if self._enemyInfo.name then
            self._ccbOwner.tf_enemy_name:setString(self._enemyInfo.name)
            self._ccbOwner.tf_enemy_name:setVisible(true)
        else
            self._ccbOwner.tf_enemy_name:setString("?????")
            self._ccbOwner.tf_enemy_name:setVisible(true)
        end

        self._ccbOwner.btn_enemy_detail:setVisible(true)
    end

	self:_showPlayerHeadListView()
    self:_showEnemyHeadListView()
end

function QUIWidgetSilvesBattleFormationAgainst:_showPlayerHeadListView()
    if self._scrollViewPlayer then
        self._scrollViewPlayer:disappear()
        self._scrollViewPlayer = nil
    end

    local totalWidth = 30
    local scrollOptions = {}
    scrollOptions.sheet = self._ccbOwner.sheet_player
    scrollOptions.sheet_layout = self._ccbOwner.sheet_layout_player
    scrollOptions.direction = QScrollContain.directionX
    scrollOptions.touchLayerOffsetY = -self._ccbOwner.sheet_layout_player:getContentSize().height
    self._scrollViewPlayer = QScrollContain.new(scrollOptions)

    local offsetX = 20
    local offsetY = 5
    local lineDistance = -30
    local allHeads = {}

    -- 主力
    for index, value in ipairs( self._playerInfo.heros or {} ) do
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
        heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
        totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

        heroHead:initGLLayer()
        self._scrollViewPlayer:addChild(heroHead)
        table.insert(allHeads, heroHead)
    end

    -- --魂灵
    -- for _, value in pairs( self._playerInfo.soulSpirit or {}) do
    --     local heroHead = QUIWidgetHeroHead.new()
    --     heroHead:setHero(value.id)
    --     heroHead:setLevel(value.level)
    --     heroHead:setInherit(value.devour_level or 0)  
    --     heroHead:setStar(value.grade)
    --     heroHead:showSabc()
    --     heroHead:setTeam(1)
    --     heroHead:setScale(0.6)
    --     heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
    --     totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

    --     heroHead:initGLLayer()
    --     self._scrollViewPlayer:addChild(heroHead)
    --     table.insert(allHeads, heroHead)
    -- end
    
    -- -- 神器
    -- for index, value in ipairs( self._playerInfo.godArm1List or {} ) do
    --     local heroHead = QUIWidgetHeroHead.new()
    --     heroHead:setHero(value.id)
    --     heroHead:setLevel(value.level)
    --     heroHead:setStar(value.grade)
    --     heroHead:setTeam(index, false, false,true)
    --     heroHead:showSabc()
    --     heroHead:setHeadScale(0.6)
    --     heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
    --     totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

    --     heroHead:initGLLayer()
    --     self._scrollViewPlayer:addChild(heroHead)
    --     table.insert(allHeads, heroHead)     
    -- end
    
    -- --援助1
    -- for index, value in ipairs( self._playerInfo.subheros or {} ) do
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
    --     heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
    --     totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

    --     heroHead:initGLLayer()
    --     self._scrollViewPlayer:addChild(heroHead)
    --     table.insert(allHeads, heroHead)
    -- end

    -- --援助2
    -- for index, value in ipairs( self._playerInfo.sub2heros or {} ) do
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
    --     heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
    --     totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

    --     heroHead:initGLLayer()
    --     self._scrollViewPlayer:addChild(heroHead)
    --     table.insert(allHeads, heroHead)
    -- end

    -- --援助3
    -- for index, value in ipairs( self._playerInfo.sub3heros or {} ) do
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
    --     heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
    --     totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

    --     heroHead:initGLLayer()
    --     self._scrollViewPlayer:addChild(heroHead)
    --     table.insert(allHeads, heroHead)
    -- end
    
    self._scrollViewPlayer:setRect(0, -self._ccbOwner.sheet_layout_player:getContentSize().height, 0, totalWidth)
end

function QUIWidgetSilvesBattleFormationAgainst:_showEnemyHeadListView()
    if self._scrollViewEnemy then
        self._scrollViewEnemy:disappear()
        self._scrollViewEnemy = nil
    end

    local totalWidth = 30
    local scrollOptions = {}
    scrollOptions.sheet = self._ccbOwner.sheet_enemy
    scrollOptions.sheet_layout = self._ccbOwner.sheet_layout_enemy
    scrollOptions.direction = QScrollContain.directionX
    scrollOptions.touchLayerOffsetY = -self._ccbOwner.sheet_layout_enemy:getContentSize().height
    self._scrollViewEnemy = QScrollContain.new(scrollOptions)

    local offsetX = 20
    local offsetY = 5
    local lineDistance = -30
    local allHeads = {}

    if self._enemyInfo.silvesArenaFightPos == remote.silvesArena.MAX_TEAM_MEMBER_COUNT then
        for i = 1, 4, 1 do
            local heroHead = QUIWidgetHeroHeadSketch.new()
            heroHead:setScale(0.6)

            heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance
            heroHead:initGLLayer()

            self._scrollViewEnemy:addChild(heroHead)
            table.insert(allHeads, heroHead)
        end
    else
        -- 主力
        for index, value in ipairs( self._enemyInfo.heros or {} ) do
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
            heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

            heroHead:initGLLayer()
            self._scrollViewEnemy:addChild(heroHead)
            table.insert(allHeads, heroHead)
        end

        -- --魂灵
        -- for _, value in pairs( self._enemyInfo.soulSpirit or {}) do
        --     local heroHead = QUIWidgetHeroHead.new()
        --     heroHead:setHero(value.id)
        --     heroHead:setLevel(value.level)
        --     heroHead:setInherit(value.devour_level or 0)  
        --     heroHead:setStar(value.grade)
        --     heroHead:showSabc()
        --     heroHead:setTeam(1)
        --     heroHead:setScale(0.6)
        --     heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
        --     totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

        --     heroHead:initGLLayer()
        --     self._scrollViewEnemy:addChild(heroHead)
        --     table.insert(allHeads, heroHead)
        -- end
        
        -- -- 神器
        -- for index, value in ipairs( self._enemyInfo.godArm1List or {} ) do
        --     local heroHead = QUIWidgetHeroHead.new()
        --     heroHead:setHero(value.id)
        --     heroHead:setLevel(value.level)
        --     heroHead:setStar(value.grade)
        --     heroHead:setTeam(index, false, false,true)
        --     heroHead:showSabc()
        --     heroHead:setHeadScale(0.6)
        --     heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
        --     totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

        --     heroHead:initGLLayer()
        --     self._scrollViewEnemy:addChild(heroHead)
        --     table.insert(allHeads, heroHead)     
        -- end
        
        -- --援助1
        -- for index, value in ipairs( self._enemyInfo.subheros or {} ) do
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
        --     heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
        --     totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

        --     heroHead:initGLLayer()
        --     self._scrollViewEnemy:addChild(heroHead)
        --     table.insert(allHeads, heroHead)
        -- end

        -- --援助2
        -- for index, value in ipairs( self._enemyInfo.sub2heros or {} ) do
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
        --     heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
        --     totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

        --     heroHead:initGLLayer()
        --     self._scrollViewEnemy:addChild(heroHead)
        --     table.insert(allHeads, heroHead)
        -- end

        -- --援助3
        -- for index, value in ipairs( self._enemyInfo.sub3heros or {} ) do
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
        --     heroHead:setPosition( totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
        --     totalWidth = totalWidth + heroHead:getContentSize().width + lineDistance

        --     heroHead:initGLLayer()
        --     self._scrollViewEnemy:addChild(heroHead)
        --     table.insert(allHeads, heroHead)
        -- end
    end
    
    self._scrollViewEnemy:setRect(0, -self._ccbOwner.sheet_layout_enemy:getContentSize().height, 0, totalWidth)

    for _, head in ipairs(allHeads) do
        if head and head.getHeroSprite then
            local img = head:getHeroSprite()
            if img then
                img:setScaleX( img:getScaleX() * -1 )
            end
        end
    end
end

function QUIWidgetSilvesBattleFormationAgainst:onTouchListView( event )
	if not event then
		return
	end

	if event.name == "began" then
		self._startX = event.x
		self._startTime = q.serverTime()
	elseif event.name == "ended" then
		local currentTime = q.serverTime()
		local offsetXTime = 0
		if currentTime ~= self._startTime then
			if currentTime - self._startTime < 0.3 then
				offsetXTime = 0.5/(currentTime - self._startTime) * 0.3
			end
		end

		self._distanceX = (event.x - self._startX) * offsetXTime
	end

	-- if self._scrollViewPlayer then
	-- 	self._scrollViewPlayer:onEvent(event)
	-- 	if event.name == "ended" then
	-- 		self._scrollViewPlayer:moveTo(self._distanceX, 0, true)
	-- 	end
	-- end

 --    if self._scrollViewEnemy then
 --        self._scrollViewEnemy:onEvent(event)
 --        if event.name == "ended" then
 --            self._scrollViewEnemy:moveTo(self._distanceX, 0, true)
 --        end
 --    end
end

return QUIWidgetSilvesBattleFormationAgainst