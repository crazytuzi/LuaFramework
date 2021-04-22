--
-- Author: Kumo
-- Date: 
-- 玩家信息展示主界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPlayerInfo = class("QUIDialogPlayerInfo", QUIDialog)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QScrollContain = import("..QScrollContain")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")

local up_node_posY =87
local bottom_node_posY = 56

local left_node_posX = -192
local right_node_posX = 78


function QUIDialogPlayerInfo:ctor(options)
    local ccbFile = "ccb/Dialog_wanjiaxinxi.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},   
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},   
    }   
    QUIDialogPlayerInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._fighter = options.fighter
    if self._fighter == nil then
        return
    end
    self._playerAvatar = options.avatar or self._fighter.avatar
    self._playerName = options.name or self._fighter.name or ""
    self._playerLevel = options.level or self._fighter.level or 0
    self._playerVIPLevel = options.vipLevel or self._fighter.vip
    self._playerForce = options.force or self._fighter.force
    self._societyName = options.societyName or self._fighter.consortiaName
    self._isPVP = options.isPVP
    self._isEquilibrium = options.isEquilibrium
    
    self._playerHeros = options.heros or self._fighter.heros or {}
    self._playerAlternates = options.alternateHeros or self._fighter.alternateHeros or {}
    self._playerSubheros = options.subheros or self._fighter.subheros or {}
    self._playerSub2heros = options.sub2heros or self._fighter.sub2heros or {}
    self._playerSub3heros = options.sub3heros or self._fighter.sub3heros or {}
    self._playerMounts = options.mounts or {}
    self._playerGodarms = options.godArm1List or  self._fighter.godArm1List  or  {}

    self._playerSoulSpirit = options.soulSpirit or self._fighter.soulSpirit
    self._trialNum = options.trialNum or 1

    self._ccbOwner.frame_tf_title:setString("玩家信息")
    self._ccbOwner.tf_level:setString("")
    self._ccbOwner.tf_name:setString("")
    self._ccbOwner.tf_vip:setString("")
    self._model = options.model or GAME_MODEL.NORMAL
    self._showTeamForce = options.showTeamForce or false

    if self._model ~=  GAME_MODEL.MOCKBATTLE  then
        table.sort(self._playerHeros, function(a, b)
                return a.force > b.force
            end)
        table.sort(self._playerSubheros, function(a, b)
                return a.force > b.force
            end)
        table.sort(self._playerSub2heros, function(a, b)
                return a.force > b.force
            end)
        table.sort(self._playerSub3heros, function(a, b)
                return a.force > b.force
            end)
    end

    self._isShowHpMp = options.isShowHpMp
    self._initMp = options.initMp or 500
    self._isAllDead = options.allDead
    self._forceTitle = options.forceTitle


    self._isMe = tostring(self._fighter.userId) == tostring(remote.user.userId) 
    self._ccbOwner.tf_force:setString(0)

    local hasSpecialOrAwardInfo = false
    local index = 1
    -- 特殊属性的处理 options = { specialTitle1 = "" , specialValue1 = "" }
    while true do
        local node = self._ccbOwner["node_special_"..index]
        if node then
            local node1 =  self._ccbOwner["tf_special_title_"..index]
            local node2 =  self._ccbOwner["tf_special_value_"..index]
            node:setVisible(false)

            if options["specialTitle"..index] then
                node1:setString( options["specialTitle"..index] or "")
            end
            if options["specialValue"..index] then

                node2:setString( options["specialValue"..index] or "")
            end
            if options["specialTitle"..index] and options["specialValue"..index] then
                hasSpecialOrAwardInfo = true
                node:setVisible(true)
            end

            print("node1:getPositionY() = "..node1:getPositionY())
            local size = node1:getContentSize()
            node2:setPositionX( node1:getPositionX() + size.width )
            index = index + 1
        else
            break
        end
    end

    index = 1
    -- 有奖励信息的处理 options = { awardTitle1 = "" , awardValue1 = { type[typeName], id, count } }
    while true do
        local node = self._ccbOwner["node_award_"..index]
        if node then
            local px = 0
            local node1 =  self._ccbOwner["tf_award_title_"..index]
            node1:setString( options["awardTitle"..index] or "")
            local size1 = node1:getContentSize()
            if device.platform == "android" then
                size1.width = 110
            end
            px = node1:getPositionX() + size1.width - 5
            node:setVisible(false)

            for i, award in pairs(options["awardValue"..index] or {}) do
                node:setVisible(true)
                hasSpecialOrAwardInfo = true
                local type = award.type or award.typeName
                local id = award.id
                local count = award.count
                -- print(type, id , count, index, i)
                local node2 =  self._ccbOwner["node_item_"..index.."_"..i]
                local node3 =  self._ccbOwner["tf_award_count_"..index.."_"..i]
                local size2 = nil
                local size3 = nil
                if node2 then
                    local itemBox = QUIWidgetItemsBox.new()
                    itemBox:setGoodsInfo(id, type, 0)
                    node2:addChild(itemBox)
                    size2 = itemBox:getContentSize()
                    node2:setPositionX(px + size2.width * node2:getScaleX() / 2)
                    px = px + size2.width * node2:getScaleX() 
                end
                if node3 then
                    node3:setString("x"..count)
                    node3:setPositionX(px)
                    px = px + node3:getContentSize().width+5
                end
            end
            index = index + 1
        else
            break
        end
    end

    if not hasSpecialOrAwardInfo then
        self._ccbOwner.node_baseInfo:setPositionY(bottom_node_posY)
        self._ccbOwner.node_union:setPositionY(bottom_node_posY)
    else
        self._ccbOwner.node_baseInfo:setPositionY(up_node_posY)
        self._ccbOwner.node_union:setPositionY(up_node_posY)
    end
    self._ccbOwner.node_pvp:setVisible(false)

    self:_processModel()
end

function QUIDialogPlayerInfo:_processModel()
    if self._model == GAME_MODEL.SUNWAR then
        local waveID = self:getOptions().waveID
        local lastPassWave = remote.sunWar:getLastPassedWave() or 0
        if waveID > lastPassWave then
            self._ccbOwner.sp_yilingqu:setVisible(false)
        else
            self._ccbOwner.sp_yilingqu:setVisible(true)
        end
    else
        self._ccbOwner.sp_yilingqu:setVisible(false)
    end
end

function QUIDialogPlayerInfo:_setAvatar()
    local head = QUIWidgetAvatar.new(self._playerAvatar)
    head:setSilvesArenaPeak(self._fighter.championCount)
    self._ccbOwner.node_avatar:addChild( head )
end

function QUIDialogPlayerInfo:_setInfo()
    self._ccbOwner.tf_level:setString( "LV."..self._playerLevel )
    self._ccbOwner.tf_name:setString( self._playerName )
    self._ccbOwner.tf_vip:setString( "VIP"..(self._playerVIPLevel or 0) )
    q.autoLayerNode({self._ccbOwner.tf_level, self._ccbOwner.tf_name, self._ccbOwner.tf_vip}, "x", 10)

    if self._societyName == nil or self._societyName == "" then
        self._ccbOwner.tf_society_name:setString("无")
    else
        self._ccbOwner.tf_society_name:setString(self._societyName)
    end
    self._ccbOwner.tf_force_title:setString(self._forceTitle or "战力：")

    -- print("self._ccbOwner.tf_force_title: = "..self._ccbOwner.tf_force_title:getPositionY())
    -- if self._forceTitle ~= nil then
    -- end
    self._ccbOwner.tf_force:setPositionX(self._ccbOwner.tf_force_title:getPositionX() + self._ccbOwner.tf_force_title:getContentSize().width - 10)

    local force = self._fighter.force or 0
    local num, unit = q.convertLargerNumber( force )
    self._ccbOwner.tf_force:setString(num..(unit or ""))
    local width_ = self._ccbOwner.tf_force:getPositionX() + self._ccbOwner.tf_force:getContentSize().width
    width_ = width_ + 15
    --继承战力。服务器传输
    local inherit_force = self._fighter.sotoTeamTopnForce or 0
    self._ccbOwner.tf_inherit_force:setVisible(false)
    self._ccbOwner.sp_inherit:setVisible(false)
    inherit_force = inherit_force - force
    if inherit_force > 0 then
        width_ = width_ - 10
        self._ccbOwner.tf_inherit_force:setVisible(true)
        self._ccbOwner.sp_inherit:setVisible(true)
        local _inum, _iunit = q.convertLargerNumber( inherit_force )
        self._ccbOwner.tf_inherit_force:setString("+".._inum..(_iunit or ""))

        self._ccbOwner.tf_inherit_force:setPositionX(width_)
        width_ = width_ + self._ccbOwner.tf_inherit_force:getContentSize().width
        self._ccbOwner.sp_inherit:setPositionX(width_+ 10)
        width_ = width_ + 5 + self._ccbOwner.sp_inherit:getContentSize().width
    end

    if ENABLE_PVP_FORCE and self._isPVP == true then
        self._ccbOwner.node_pvp:setVisible(true)
        self._ccbOwner.node_pvp:setPositionX(width_ + 10)
    end

    width_ = width_ + 30
    local off_side = right_node_posX - left_node_posX - width_


    if off_side < 0 then
        off_side =  right_node_posX - off_side
    else
        off_side =  right_node_posX 
    end
    self._ccbOwner.node_union:setPositionX(off_side )
    self._ccbOwner.node_award_2:setPositionX(off_side )
    self._ccbOwner.node_special_2:setPositionX(off_side )

    if self._model == GAME_MODEL.MOCKBATTLE or self._showTeamForce then
        local num, unit = q.convertLargerNumber( self._playerForce )
        self._ccbOwner.tf_force:setString(num..(unit or ""))
        self._ccbOwner.tf_force:setPositionX(self._ccbOwner.tf_force_title:getPositionX() + self._ccbOwner.tf_force_title:getContentSize().width + 5)
        self._ccbOwner.node_pvp:setPositionX(self._ccbOwner.tf_force:getPositionX() + self._ccbOwner.tf_force:getContentSize().width + 25)
    end
end

function QUIDialogPlayerInfo:_setHero()
    if self._scrollView then
        self._scrollView:disappear()
        self._scrollView = nil
    end
    self._heroHeads = {}
    self._subHeroHeads = {}
    self._heroActorIds = {}
    self._totalWidth = 30

    local scrollOptions = {}
    scrollOptions.sheet = self._ccbOwner.sheet
    scrollOptions.sheet_layout = self._ccbOwner.sheet_layout
    scrollOptions.direction = QScrollContain.directionX
    scrollOptions.touchLayerOffsetY = 10
    scrollOptions.touchLayerOffsetY = -self._ccbOwner.sheet_layout:getContentSize().height
    self._scrollView = QScrollContain.new(scrollOptions)

    local offsetX = 20
    local offsetY = -25
    local lineDistance = -15

    -------------------------------主力-------------------------
    local headIndex = 0
    for index, value in ipairs( self._playerHeros or {} ) do
        local heroHead = QUIWidgetHeroHead.new()
        headIndex = headIndex + 1
        if self._model == GAME_MODEL.STORM then
            heroHead:setUnKnowHero(3, 1)
        else
            heroHead:setTeam(1)
        end
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()

        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
        local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)

        if self._isShowHpMp then
            self:_showHpMp( heroHead, value.actorId, false, self._isAllDead, self._initMp )
            offsetY = -15
        end

        heroHead:setHeadScale(0.8)
        heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance

        heroHead:initGLLayer()
        self._scrollView:addChild(heroHead)
        table.insert(self._heroHeads, heroHead)
        table.insert(self._heroActorIds, value.actorId)
    end

    if self._model == GAME_MODEL.STORM then
        while (headIndex < 4) do
            local heroHead = QUIWidgetHeroHead.new()
            headIndex = headIndex + 1
            heroHead:setUnKnowHero(1, 1)
            heroHead:setHeadScale(0.8)
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance
            heroHead:initGLLayer()
            self._scrollView:addChild(heroHead)
            table.insert(self._heroHeads, heroHead)
        end
    end

    -------------------------------魂灵-------------------------
    local headIndex = 0
    -- if self._playerSoulSpirit then
    for _,v in pairs(self._playerSoulSpirit or {}) do
        local heroHead = QUIWidgetHeroHead.new()
        headIndex = headIndex + 1
        heroHead:setHero(v.id)
        heroHead:setLevel(v.level)
        heroHead:setInherit(v.devour_level or 0)  
        heroHead:setStar(v.grade)
        heroHead:showSabc()
        heroHead:setTeam(1)
        heroHead:setScale(0.8)
        heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance

        heroHead:initGLLayer()
        self._scrollView:addChild(heroHead)
    end
    
    -- 神器
    for index, value in ipairs( self._playerGodarms or {} ) do
            local heroHead = QUIWidgetHeroHead.new()
            if self._model == GAME_MODEL.MOCKBATTLE then
                heroHead:setHero(value.actorId)
            else
                heroHead:setHero(value.id)
            end
            heroHead:setLevel(value.level)
            heroHead:setStar(value.grade)
            heroHead:setTeam(index, false, false,true)
            heroHead:showSabc()
            heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
            heroHead:initGLLayer()
            heroHead:setHeadScale(0.8)
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance
            self._scrollView:addChild(heroHead)
            table.insert(self._heroHeads, heroHead)        
    end
    -------------------------------替补-------------------------
    local headIndex = 0
    for index, value in ipairs( self._playerAlternates or {} ) do
        local heroHead = QUIWidgetHeroHead.new()
        headIndex = headIndex + 1
        heroHead:setTeam(index, false, true)
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

        if self._isShowHpMp then
            self:_showHpMp( heroHead, value.actorId, false, self._isAllDead, self._initMp )
            offsetY = -15
        end

        heroHead:setHeadScale(0.8)
        heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance

        heroHead:initGLLayer()
        self._scrollView:addChild(heroHead)
        table.insert(self._heroHeads, heroHead)
        table.insert(self._heroActorIds, value.actorId)
    end

    if self._model == GAME_MODEL.STORM then
        while (headIndex < 4) do
            local heroHead = QUIWidgetHeroHead.new()
            headIndex = headIndex + 1
            heroHead:setUnKnowHero(1, 1)
            heroHead:setHeadScale(0.8)
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance
            heroHead:initGLLayer()
            self._scrollView:addChild(heroHead)
            table.insert(self._heroHeads, heroHead)
        end
    end

    -------------------------------援助1-------------------------
    headIndex = 0
    for index, value in ipairs( self._playerSubheros or {} ) do
        local heroHead = QUIWidgetHeroHead.new()
        headIndex = headIndex + 1
        if self._model == GAME_MODEL.STORM and not self._isMe then
            heroHead:setUnKnowHero(0, 2)
        else
            if self._model == GAME_MODEL.STORM then
                heroHead:setUnKnowHero(3, 2)
            else
                heroHead:setTeam(2+1)
            end
            heroHead:setHeroSkinId(value.skinId)
            heroHead:setHero(value.actorId)
            heroHead:setLevel(value.level)
            heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
            heroHead:setStar(value.grade)
            heroHead:showSabc()

            local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
            local profession = heroInfo.func or "dps"
            heroHead:setProfession(profession)

            if self._isShowHpMp then
                self:_showHpMp( heroHead, value.actorId, true, self._isAllDead, self._initMp )
                offsetY = -15
            end
            table.insert(self._heroActorIds, value.actorId)
        end

        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        heroHead:setHeadScale(0.8)
        heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
        self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance
        heroHead:initGLLayer()
        self._scrollView:addChild(heroHead)
        table.insert(self._subHeroHeads, heroHead)
    end

    if self._model == GAME_MODEL.STORM then
        while (headIndex < 4) do
            local heroHead = QUIWidgetHeroHead.new()
            headIndex = headIndex + 1
            if self._isMe then
                heroHead:setUnKnowHero(1, 2)
            else
                heroHead:setUnKnowHero(0, 2)
            end
            heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
            heroHead:setHeadScale(0.8)
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance
            heroHead:initGLLayer()
            self._scrollView:addChild(heroHead)
            table.insert(self._heroHeads, heroHead)
        end
    end

    -------------------------------

    headIndex = 0
    for index, value in ipairs( self._playerSub2heros or {} ) do
        local heroHead = QUIWidgetHeroHead.new()
         headIndex = headIndex + 1
        if self._model == GAME_MODEL.STORM and not self._isMe then
            heroHead:setUnKnowHero(0, 3)
        else
            if self._model == GAME_MODEL.STORM then
                heroHead:setUnKnowHero(3, 3)
            else
                heroHead:setTeam(2+2)
            end
            heroHead:setHeroSkinId(value.skinId)
            heroHead:setHero(value.actorId)
            heroHead:setLevel(value.level)
            heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
            heroHead:setStar(value.grade)
            heroHead:showSabc()

            local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
            local profession = heroInfo.func or "dps"
            heroHead:setProfession(profession)

            if self._isShowHpMp then
                self:_showHpMp( heroHead, value.actorId, true, self._isAllDead, self._initMp )
                offsetY = -15
            end
            table.insert(self._heroActorIds, value.actorId)
        end

        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        heroHead:setHeadScale(0.8)
        heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
        self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance
        heroHead:initGLLayer()
        self._scrollView:addChild(heroHead)
        table.insert(self._subHeroHeads, heroHead)
    end

    if self._model == GAME_MODEL.STORM then
        while (headIndex < 4) do
            local heroHead = QUIWidgetHeroHead.new()
            headIndex = headIndex + 1
            if self._isMe then
                heroHead:setUnKnowHero(1, 3)
            else
                heroHead:setUnKnowHero(0, 3)
            end
            heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
            heroHead:setHeadScale(0.8)
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance
            heroHead:initGLLayer()
            self._scrollView:addChild(heroHead)
            table.insert(self._heroHeads, heroHead)
        end
    end
-------------------------------

    headIndex = 0
    for index, value in ipairs( self._playerSub3heros or {} ) do
        local heroHead = QUIWidgetHeroHead.new()
         headIndex = headIndex + 1
        if self._model == GAME_MODEL.STORM and not self._isMe then
            heroHead:setUnKnowHero(0, 3)
        else
            if self._model == GAME_MODEL.STORM then
                heroHead:setUnKnowHero(3, 3)
            else
                heroHead:setTeam(2+3)
            end
            heroHead:setHeroSkinId(value.skinId)
            heroHead:setHero(value.actorId)
            heroHead:setLevel(value.level)
            heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
            heroHead:setStar(value.grade)
            heroHead:showSabc()

            local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
            local profession = heroInfo.func or "dps"
            heroHead:setProfession(profession)

            if self._isShowHpMp then
                self:_showHpMp( heroHead, value.actorId, true, self._isAllDead, self._initMp )
                offsetY = -15
            end
            table.insert(self._heroActorIds, value.actorId)
        end

        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
        heroHead:setHeadScale(0.8)
        heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
        self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance
        heroHead:initGLLayer()
        self._scrollView:addChild(heroHead)
        table.insert(self._subHeroHeads, heroHead)
    end

    if self._model == GAME_MODEL.STORM then
        while (headIndex < 4) do
            local heroHead = QUIWidgetHeroHead.new()
            headIndex = headIndex + 1
            if self._isMe then
                heroHead:setUnKnowHero(1, 4)
            else
                heroHead:setUnKnowHero(0, 4)
            end
            heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
            heroHead:setHeadScale(0.8)
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance
            heroHead:initGLLayer()
            self._scrollView:addChild(heroHead)
            table.insert(self._heroHeads, heroHead)
        end
    end

    --大师赛的暗器
    if self._model == GAME_MODEL.MOCKBATTLE then
        for index, value in ipairs( self._playerMounts or {} ) do
            local heroHead = QUIWidgetHeroHead.new()
            heroHead:setHero(value.actorId)
            heroHead:setLevel(value.level)
            heroHead:setStar(value.grade)
            heroHead:showSabc()
            heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
            heroHead:initGLLayer()
            heroHead:setHeadScale(0.8)
            heroHead:setPosition( self._totalWidth + offsetX, -heroHead:getContentSize().height/2 + offsetY )
            self._totalWidth = self._totalWidth + heroHead:getContentSize().width + lineDistance
            self._scrollView:addChild(heroHead)
            table.insert(self._heroHeads, heroHead)
        end
    end

    self._scrollView:setRect(0, -self._ccbOwner.sheet_layout:getContentSize().height, 0, self._totalWidth)
end

function QUIDialogPlayerInfo:_showHpMp( heroHead, actorId, isSubhero, isAllDead, initMp )
    if not heroHead or not actorId then return end

    local maxMp = 1000
    
    if isSubhero then 
        heroHead:setHp()
        if initMp then
            heroHead:setMp(initMp, maxMp)
        else
            heroHead:setMp(500, maxMp)
            -- 盗贼初始连击点数满
            local character_config = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
            if character_config.combo_points_auto then
                heroHead:setMp(maxMp, maxMp)
            end
        end
        if isAllDead then
            makeNodeFromNormalToGray(heroHead)
        end
        return
    end

    local npcTbl = remote.sunWar:getNpcHeroInfo()
    if not npcTbl or table.nums(npcTbl) == 0 then
        -- NPC满血
        heroHead:setHp()
        if initMp then
            heroHead:setMp(initMp, maxMp)
        else
            heroHead:setMp(500, maxMp)
            -- 盗贼初始连击点数满
            local character_config = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
            if character_config.combo_points_auto then
                heroHead:setMp(maxMp, maxMp)
            end
        end
        if isAllDead then
            makeNodeFromNormalToGray(heroHead)
        end
        return
    end

    if npcTbl[actorId] then
        if not npcTbl[actorId].currHp then
            heroHead:setHp()
        else
            local waveID = self:getOptions().waveID
            local waveFighter = remote.sunWar:getWaveFigtherByWaveID(waveID)
            local maxHp = remote.sunWar:getNpcHeroMaxHp( actorId, waveFighter )
            heroHead:setHp( npcTbl[actorId].currHp, maxHp )
            if npcTbl[actorId].currHp <= 0 then
                -- heroHead:setDead(true)
                makeNodeFromNormalToGray(heroHead)
            end
        end

        if not npcTbl[actorId].currMp then
            if initMp then
                heroHead:setMp(initMp, maxMp)
            else
                heroHead:setMp(500, maxMp)
                -- 盗贼初始连击点数满
                local character_config = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
                if character_config.combo_points_auto then
                    heroHead:setMp(maxMp, maxMp)
                end
            end
        else
            heroHead:setMp( npcTbl[actorId].currMp, maxMp )
        end
    else
        heroHead:setHp()
        if initMp then
            heroHead:setMp(initMp, maxMp)
        else
            heroHead:setMp(500, maxMp)
            -- 盗贼初始连击点数满
            local character_config = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
            if character_config.combo_points_auto then
                heroHead:setMp(maxMp, maxMp)
            end
        end
    end

    if isAllDead then
        -- heroHead:setDead(true)
        makeNodeFromNormalToGray(heroHead)
    end
end

function QUIDialogPlayerInfo:getActorIdBySoulSpiritId(soulSpiritId)
    for i, v in pairs(self._playerHeros) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
    for i, v in pairs(self._playerAlternates) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
    for i, v in pairs(self._playerSubheros) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
    for i, v in pairs(self._playerSub2heros) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
    for i, v in pairs(self._playerSub3heros) do
        if v.soulSpirit and v.soulSpirit.id == soulSpiritId then
            return v.actorId
        end
    end
end

function QUIDialogPlayerInfo:getHeadByActorId(actorId)
    local heroHead = nil
    for i, v in pairs(self._heroHeads) do
        if v:getHeroActorID() == actorId then
            heroHead = v
            break
        end
    end
    for i, v in pairs(self._subHeroHeads) do
        if v:getHeroActorID() == actorId then
            heroHead = v
            break
        end
    end
    return heroHead
end

function QUIDialogPlayerInfo:_onEvent( event )
    if FinalSDK.isHXShenhe() then
        return
    end    
    if self._scrollView:getMoveState() then return end

    local heroHead = event.target
    if self._model == GAME_MODEL.MOCKBATTLE then
        self:handleMockBattle(heroHead)
        return
    end

    if heroHead:getIsGodarm() then
        app.tip:floatTip("该神器已经上阵")
        return
    end

    local actorId = heroHead:getHeroActorID()
    if heroHead:getIsSoulSpirit() then
        actorId = self:getActorIdBySoulSpiritId(actorId)
        if not actorId then
            app.tip:floatTip("该魂灵还没有护佑魂师")
            return
        end
        local heroHead = self:getHeadByActorId(actorId)
        if not heroHead then
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
            options = {hero = self._heroActorIds, pos = pos, fighter = self._fighter or {}}})
    end
end


function QUIDialogPlayerInfo:handleMockBattle(heroHead)
    local actorId = heroHead:getHeroActorID()
    local id = remote.mockbattle:getCardInfoById(actorId).id
    if heroHead:getIsSoulSpirit() then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleSoulCardInfo",
            options = {actorId = actorId,id = id}})
    elseif heroHead:getIsMount() then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleMountCardInfo",
            options = {actorId = actorId,id = id}})
    elseif heroHead:getIsGodarm() then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleGodarmCardInfo",
            options = {actorId = actorId, id = id}})        
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleHeroCardInfo",
            options = {actorId = actorId,id = id}})
    end
end



function QUIDialogPlayerInfo:_checkNPCHero(actorId)
    for _, heroInfo in pairs(self._fighter.heros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end
    for _, heroInfo in pairs(self._fighter.alternateHeros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end
    for _, heroInfo in pairs(self._fighter.subheros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end
    for _, heroInfo in pairs(self._fighter.sub2heros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end
    for _, heroInfo in pairs(self._fighter.sub3heros or {}) do
        if heroInfo and heroInfo.actorId == actorId and not heroInfo.equipments then
            return true
        end
    end
    return false
end

function QUIDialogPlayerInfo:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")
    local options =  {fighter = self._fighter, isEquilibrium = self._isEquilibrium}
    if self._trialNum == 1 then
    elseif self._trialNum == 2 then
        options =  {fighter2 = self._fighter, isEquilibrium = self._isEquilibrium}
    elseif self._trialNum == 3 then
        options =  {fighter3 = self._fighter, isEquilibrium = self._isEquilibrium}
    end


    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = options }, {isPopCurrentDialog = false})
end

function QUIDialogPlayerInfo:viewDidAppear()
    QUIDialogPlayerInfo.super.viewDidAppear(self)
end

function QUIDialogPlayerInfo:viewWillDisappear()
    QUIDialogPlayerInfo.super.viewWillDisappear(self)

    if self._scrollView then
        self._scrollView:disappear()
        self._scrollView = nil
    end
    if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end
end

function QUIDialogPlayerInfo:viewAnimationInHandler()
    if self._isError then
        self:popSelf()
        return
    end
    if self._fighter == nil then
        return
    end
    self:_setAvatar()
    self:_setInfo()
    self:_setHero()
end

function QUIDialogPlayerInfo:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogPlayerInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogPlayerInfo:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogPlayerInfo