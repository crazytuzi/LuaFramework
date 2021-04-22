--
-- Kumo.Wang
-- 西尔维斯大斗魂场阵容界面元素
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaBattleFormation = class("QUIWidgetSilvesArenaBattleFormation", QUIWidget)

local QScrollContain = import("..QScrollContain")

local QUIWidgetHeroHead = import(".QUIWidgetHeroHead")
local QUIWidgetHeroHeadSketch = import(".QUIWidgetHeroHeadSketch")

function QUIWidgetSilvesArenaBattleFormation:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_BattleFormation.ccbi"
  	local callBacks = {}
	QUIWidgetSilvesArenaBattleFormation.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSilvesArenaBattleFormation:onEnter()
	QUIWidgetSilvesArenaBattleFormation.super.onEnter(self)
end

function QUIWidgetSilvesArenaBattleFormation:onExit()
	QUIWidgetSilvesArenaBattleFormation.super.onExit(self)

    if self._scrollView then
        self._scrollView:disappear()
        self._scrollView = nil
    end
end

function QUIWidgetSilvesArenaBattleFormation:getContentSize()
	if self._info.module == remote.silvesArena.BATTLEFORMATION_MODULE_TIPS then
		return self._ccbOwner.node_tips_size:getContentSize()
	else
		return self._ccbOwner.node_size:getContentSize()
	end
end

function QUIWidgetSilvesArenaBattleFormation:getInfo()
	return self._info
end

function QUIWidgetSilvesArenaBattleFormation:update(info)
	if q.isEmpty(info) then
		return
	end

	self._info = info

	if info.module == remote.silvesArena.BATTLEFORMATION_MODULE_CAPTAINPOWER or info.module == remote.silvesArena.BATTLEFORMATION_MODULE_PVP then
		if self._info.clickPos then
			if self._info.clickPos == info.silvesArenaFightPos then
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

    if info.module == remote.silvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL or info.module == remote.silvesArena.BATTLEFORMATION_MODULE_RANK_PVP then
        self._ccbOwner.s9s_light_bg:setVisible(false)
        self._ccbOwner.sp_hide:setVisible(false)
    else
        if info.module ~= remote.silvesArena.BATTLEFORMATION_MODULE_SKETCH and info.silvesArenaFightPos == remote.silvesArena.MAX_TEAM_MEMBER_COUNT then
            self._ccbOwner.s9s_light_bg:setVisible(true)
            self._ccbOwner.sp_hide:setVisible(true)
        else
            self._ccbOwner.s9s_light_bg:setVisible(false)
            self._ccbOwner.sp_hide:setVisible(false)
        end
    end
end

function QUIWidgetSilvesArenaBattleFormation:setInfo(info)
	self:update(info)

	if info.module == remote.silvesArena.BATTLEFORMATION_MODULE_TIPS then
		self._ccbOwner.node_normal:setVisible(false)
		self._ccbOwner.node_tips:setVisible(true)
		return
	else
		self._ccbOwner.node_normal:setVisible(true)
		self._ccbOwner.node_tips:setVisible(false)

		if info.module == remote.silvesArena.BATTLEFORMATION_MODULE_CAPTAINPOWER then
			self._ccbOwner.sheet_layout:setContentSize(CCSize(510, 90))
			self._ccbOwner.tf_player_name:setVisible(true)
			self._ccbOwner.ndoe_enemy_info:setVisible(false)
		elseif info.module == remote.silvesArena.BATTLEFORMATION_MODULE_PVP then
			self._ccbOwner.sheet_layout:setContentSize(CCSize(510, 90))
			self._ccbOwner.tf_player_name:setVisible(false)
			self._ccbOwner.ndoe_enemy_info:setVisible(true)
		elseif info.module == remote.silvesArena.BATTLEFORMATION_MODULE_NORMAL 
            or info.module == remote.silvesArena.BATTLEFORMATION_MODULE_PVP_NORMAL 
            or info.module == remote.silvesArena.BATTLEFORMATION_MODULE_SKETCH
            or info.module == remote.silvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL
            or info.module == remote.silvesArena.BATTLEFORMATION_MODULE_RANK_PVP then
			self._ccbOwner.sheet_layout:setContentSize(CCSize(640, 90))
			self._ccbOwner.node_btn_click:setVisible(false)
			self._ccbOwner.tf_player_name:setVisible(true)
			self._ccbOwner.ndoe_enemy_info:setVisible(false)	
		end
	end
    
	self._ccbOwner.tf_index:setVisible(false)
	if info.silvesArenaFightPos then
		self._ccbOwner.tf_index:setString("队伍"..info.silvesArenaFightPos.."：")
		self._ccbOwner.tf_index:setVisible(true)
	end

	self._ccbOwner.tf_player_force:setVisible(false)
	if info.force then
		local num, unit = q.convertLargerNumber(info.force)
		self._ccbOwner.tf_player_force:setString(num..(unit or ""))
		self._ccbOwner.tf_player_force:setVisible(true)
    else
        self._ccbOwner.tf_player_force:setString("?????")
        self._ccbOwner.tf_player_force:setVisible(true)
	end

	if self._ccbOwner.tf_player_name:isVisible() then
        if info.name then
            self._ccbOwner.tf_player_name:setString(info.name)
        else
            self._ccbOwner.tf_player_name:setString("?????")
        end
	end

    self._ccbOwner.sp_captain:setVisible(info.isCaptain)

	if info.enemyTeamId and not q.isEmpty(remote.silvesArena.teamInfo) then
        local enemyInfo = {}
        for _, team in ipairs(remote.silvesArena.teamInfo) do
            if team.teamId == info.enemyTeamId then
                if team.leader and team.leader.silvesArenaFightPos == info.silvesArenaFightPos then
                    enemyInfo = team.leader
                    break
                elseif team.member1 and team.member1.silvesArenaFightPos == info.silvesArenaFightPos then
                    enemyInfo = team.member1
                    break
                elseif team.member2 and team.member2.silvesArenaFightPos == info.silvesArenaFightPos then
                    enemyInfo = team.member2
                    break
                end
            end
        end
        if q.isEmpty(enemyInfo) then
            self._ccbOwner.ndoe_enemy_info:setVisible(false)    
            if info.module == remote.silvesArena.BATTLEFORMATION_MODULE_SKETCH then
                self._ccbOwner.node_player_info:setVisible(false)
            else
                self._ccbOwner.node_player_info:setVisible(true)
            end
        else
            self._ccbOwner.ndoe_enemy_info:setVisible(true)
            self._ccbOwner.node_player_info:setVisible(false)

            self._ccbOwner.sp_vs:setVisible(true)
            self._ccbOwner.tf_enemy_title:setVisible(true)
            self._ccbOwner.tf_enemy_force:setVisible(false)
            self._ccbOwner.btn_enemy_detail:setVisible(false)

            if info.silvesArenaFightPos and info.silvesArenaFightPos == remote.silvesArena.MAX_TEAM_MEMBER_COUNT then
                self._ccbOwner.tf_enemy_title:setString("敌方阵容不可查看")
            else
                if enemyInfo.force then
                    local num, unit = q.convertLargerNumber(enemyInfo.force)
                    self._ccbOwner.tf_enemy_force:setString(num..(unit or ""))
                    self._ccbOwner.tf_enemy_force:setVisible(true)
                end

                self._ccbOwner.btn_enemy_detail:setVisible(true)
            end
        end
    else
        if info.module == remote.silvesArena.BATTLEFORMATION_MODULE_SKETCH then
            self._ccbOwner.node_player_info:setVisible(false)
        else
            self._ccbOwner.node_player_info:setVisible(true)
        end
	end

    if info.module == remote.silvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL
        or info.module == remote.silvesArena.BATTLEFORMATION_MODULE_RANK_PVP then
        self._ccbOwner.node_btn_my_team:setVisible(false)
    else
        self._ccbOwner.node_btn_my_team:setVisible(info.userId == remote.user.userId)
    end
    
    if info.module == remote.silvesArena.BATTLEFORMATION_MODULE_CAPTAINPOWER then
        self._ccbOwner.node_btn_my_team:setPositionY(-43)
    else
        self._ccbOwner.node_btn_my_team:setPositionY(-83)
    end

	self:_showHeadListView()
end

function QUIWidgetSilvesArenaBattleFormation:_showHeadListView()
    if self._scrollView then
        self._scrollView:disappear()
        self._scrollView = nil
    end

    -- self._heroHeads = {}
    -- self._subHeroHeads = {}
    -- self._heroActorIds = {}
    self._totalWidth = 30

    local scrollOptions = {}
    scrollOptions.sheet = self._ccbOwner.sheet
    scrollOptions.sheet_layout = self._ccbOwner.sheet_layout
    scrollOptions.direction = QScrollContain.directionX
    scrollOptions.touchLayerOffsetY = -self._ccbOwner.sheet_layout:getContentSize().height
    self._scrollView = QScrollContain.new(scrollOptions)

    local offsetX = 20
    local offsetY = 5
    local lineDistance = -30
    self._allHeads = {}

    if self._info.module == remote.silvesArena.BATTLEFORMATION_MODULE_SKETCH then
        for i = 1, 6, 1 do
            local heroHead = QUIWidgetHeroHeadSketch.new()
            heroHead:setScale(0.6)

            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance
            heroHead:initGLLayer()

            self._scrollView:addChild(heroHead)
            table.insert(self._allHeads, heroHead)
        end
    else
        -- 主力
        for index, value in ipairs( self._info.heros or {} ) do
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
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance

            heroHead:initGLLayer()
            self._scrollView:addChild(heroHead)
            table.insert(self._allHeads, heroHead)
        end

        --魂灵
        for _, value in pairs( self._info.soulSpirit or {}) do
            local heroHead = QUIWidgetHeroHead.new()
            heroHead:setHero(value.id)
            heroHead:setLevel(value.level)
            heroHead:setInherit(value.devour_level or 0)  
            heroHead:setStar(value.grade)
            heroHead:showSabc()
            heroHead:setTeam(1)
            heroHead:setScale(0.6)
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance

            heroHead:initGLLayer()
            self._scrollView:addChild(heroHead)
            table.insert(self._allHeads, heroHead)
        end
        
        -- 神器
        for index, value in ipairs( self._info.godArm1List or {} ) do
            local heroHead = QUIWidgetHeroHead.new()
            heroHead:setHero(value.id)
            heroHead:setLevel(value.level)
            heroHead:setStar(value.grade)
            heroHead:setTeam(index, false, false,true)
            heroHead:showSabc()
            heroHead:setHeadScale(0.6)
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance

            heroHead:initGLLayer()
            self._scrollView:addChild(heroHead)
            table.insert(self._allHeads, heroHead)     
        end
        
        --援助1
        for index, value in ipairs( self._info.subheros or {} ) do
            local heroHead = QUIWidgetHeroHead.new()
            heroHead:setTeam(2+1)
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
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance

            heroHead:initGLLayer()
            self._scrollView:addChild(heroHead)
            table.insert(self._allHeads, heroHead)
        end

        --援助2
        for index, value in ipairs( self._info.sub2heros or {} ) do
            local heroHead = QUIWidgetHeroHead.new()
            heroHead:setTeam(2+2)
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
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance

            heroHead:initGLLayer()
            self._scrollView:addChild(heroHead)
            table.insert(self._allHeads, heroHead)
        end

        --援助3
        for index, value in ipairs( self._info.sub3heros or {} ) do
            local heroHead = QUIWidgetHeroHead.new()
            heroHead:setTeam(2+3)
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
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance

            heroHead:initGLLayer()
            self._scrollView:addChild(heroHead)
            table.insert(self._allHeads, heroHead)
        end
    end
    
    self._scrollView:setRect(0, -self._ccbOwner.sheet_layout:getContentSize().height, 0, self._totalWidth)

    for _, head in ipairs(self._allHeads) do
        if head and head.getHeroSprite then
            local img = head:getHeroSprite()
            if img then
                if self._info.module == remote.silvesArena.BATTLEFORMATION_MODULE_PVP_NORMAL then
                    img:setScaleX( img:getScaleX() * -1 )
                end
            end
        end
    end
    
end

function QUIWidgetSilvesArenaBattleFormation:onTouchListView( event )
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

	if self._scrollView then
		self._scrollView:onEvent(event)
		if event.name == "ended" then
			self._scrollView:moveTo(self._distanceX, 0, true)
		end
	end
end

return QUIWidgetSilvesArenaBattleFormation