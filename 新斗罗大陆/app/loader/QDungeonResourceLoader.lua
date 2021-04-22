--
-- Author: Qinyuanji
-- Date: 2016-05-20
-- Implemetation of QBaseLoader to load battle resources 

local QBaseLoader = import(".QBaseLoader")
local QDungeonResourceLoader = class("QDungeonResourceLoader", QBaseLoader)

local QSkeletonViewController = import("..controllers.QSkeletonViewController")
local QBaseEffectView = import("..views.QBaseEffectView")
local QHeroSkillCoolDown = import("..ui.battle.QHeroSkillCoolDown")
local QHeroStatusView = import("..ui.battle.QHeroStatusView")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QActor = import("..models.QActor")

local TYPE_CACHE_TEXTURE = 1
local TYPE_CACHE_TEXTURE_ATLAS = 2
local TYPE_CREATE_HEROES = 3
local TYPE_LOAD_HERO_STATUS_CCBI = 4
local TYPE_LOAD_SKILL_COOLDONW_CCBI = 6
local TYPE_LOAD_SUPPORT_HERO_BUST_CCBI = 7
local TYPE_LOAD_SUPPORT_ENEMY_BUST_CCBI = 8
local TYPE_LOAD_SUPPORT_HERO_BUFF_EFFECTS = 9
local TYPE_LOAD_SUPPORT_ENEMY_BUFF_EFFECTS = 10


function QDungeonResourceLoader:ctor(dungeonConfig)
	QDungeonResourceLoader.super.ctor(self)

    self._dungeonConfig = dungeonConfig
end

function QDungeonResourceLoader:start()
    collectgarbageCollect()
    app.ccbNodeCache:purgeCCBNodeCache()
    app:cleanTextureCache()
    if HIBERNATE_TEXTURE and CCTextureCache.wakeupAllTextures then
        app.ccbNodeCache:hibernate()
        app._uiScene:hibernate()
    end
    if HIBERNATE_TEXTURE_2 then
        hibernateUselessTexturesBeforeLoad(self._dungeonConfig)
    end

    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_ENTER_DUNGEON_LOADER, dungeon = self._dungeonConfig})
	self:loadBattleResources()
end

function QDungeonResourceLoader:finish()
    QDungeonResourceLoader.super.finish(self)

    scheduler.performWithDelayGlobal(function()
        if HIBERNATE_TEXTURE_2 then
            hibernateUselessTexturesAfterLoad(self._dungeonConfig)
        end
        app:enterIntoBattleScene(self._dungeonConfig, {})
    end, 0.05)
end

function QDungeonResourceLoader:_onLoadingFrame(percent)
    -- self._loadingTF:update(percent * 0.5)
    self:setPercent(percent * 0.5 * 100)
    if percent == 1 then
        self:_onLoadingSkeletonFinished()
    end
end

function QDungeonResourceLoader:_onLoadingFrame2(percent)
    percent = percent * 0.5 + 0.5
    -- self._loadingTF:update(percent)
    self:setPercent(percent * 100)
end

function QDungeonResourceLoader:loadBattleResources()
    scheduler.performWithDelayGlobal(function()
        scheduler.performWithDelayGlobal(function()
            app:setIsClearSkeletonData(false)
            app:cleanTextureCache()

            -- self._startLoadingTime = q.time()
            QSkeletonViewController.sharedSkeletonViewController():cacheSkeletonData(self._dungeonConfig, handler(self, QDungeonResourceLoader._onLoadingFrame), {isCacheSkillEffect = true})
            -- -- add game tips scheduler @qinyuanji
            -- if self._gameTips ~= nil and #self._gameTipsText > 0 then
            --     local config = QStaticDatabase:sharedDatabase():getConfiguration()
            --     self._tipSwitchingId = scheduler.scheduleGlobal(handler(self, QUIPageLoadResources._onTipSwitching), config.TIPS and config.TIPS.value or 2)
            -- end

        end, 0)
    end, 0)
end

function QDungeonResourceLoader:_onLoadingSkeletonFinished()
    local db = QStaticDatabase.sharedDatabase()
    db:validateData()
    remote.herosUtil:validate()

    -- image
    local loadingOthers = {
        {TYPE_CACHE_TEXTURE, global.ui_actor_select_target},
        {TYPE_CACHE_TEXTURE, global.ui_actor_select_target_health},
        {TYPE_CACHE_TEXTURE, global.ui_hp_background_hero},
        {TYPE_CACHE_TEXTURE, global.ui_hp_foreground_hero},
        {TYPE_CACHE_TEXTURE, global.ui_hp_background_npc},
        {TYPE_CACHE_TEXTURE, global.ui_hp_foreground_npc},
        {TYPE_CACHE_TEXTURE, global.ui_hp_background_tmp},
        {TYPE_CACHE_TEXTURE_ATLAS, "ui/Fighting.plist", "ui/Fighting.pvr.ccz"},
        {TYPE_CACHE_TEXTURE_ATLAS, "ui/Fighting2.plist", "ui/Fighting2.pvr.ccz"}
    }

    -- heroes
    local teamName = remote.teamManager.INSTANCE_TEAM
    if self._dungeonConfig.teamName ~= nil then
        teamName = self._dungeonConfig.teamName
    end

    -- pvp coefficient initialization
    if self._dungeonConfig.isPVPMode then
        QActor.setPVPCoefficientByLevel(math.ceil(((self._dungeonConfig.userLevel or 0) + (self._dungeonConfig.enemyLevel or 0)) / 2))
    end

    if self._dungeonConfig.isReplay then
        -- support hero bust
        for _, heroInfo in ipairs(self._dungeonConfig.supportHeroInfos or {}) do
            table.insert(loadingOthers, {TYPE_CACHE_TEXTURE, db:getCharacterByID(heroInfo.actorId).aid_bust})
        end
        for _, heroInfo in ipairs(self._dungeonConfig.supportHeroInfos2 or {}) do
            table.insert(loadingOthers, {TYPE_CACHE_TEXTURE, db:getCharacterByID(heroInfo.actorId).aid_bust})
        end
        for _, heroInfo in ipairs(self._dungeonConfig.supportHeroInfos3 or {}) do
            table.insert(loadingOthers, {TYPE_CACHE_TEXTURE, db:getCharacterByID(heroInfo.actorId).aid_bust})
        end
    else
        -- support hero bust
        for _, heroId in ipairs(remote.teamManager:getActorIdsByKey(teamName, remote.teamManager.TEAM_INDEX_HELP)) do
            table.insert(loadingOthers, {TYPE_CACHE_TEXTURE, db:getCharacterByID(heroId).aid_bust})
        end
        for _, heroId in ipairs(remote.teamManager:getActorIdsByKey(teamName, remote.teamManager.TEAM_INDEX_HELP2)) do
            table.insert(loadingOthers, {TYPE_CACHE_TEXTURE, db:getCharacterByID(heroId).aid_bust})
        end
        for _, heroId in ipairs(remote.teamManager:getActorIdsByKey(teamName, remote.teamManager.TEAM_INDEX_HELP3)) do
            table.insert(loadingOthers, {TYPE_CACHE_TEXTURE, db:getCharacterByID(heroId).aid_bust})
        end
    end
    -- support enemy bust
    for _, enemy in ipairs(self._dungeonConfig.pvp_rivals2 or {}) do
        table.insert(loadingOthers, {TYPE_CACHE_TEXTURE, db:getCharacterByID(enemy.actorId).aid_bust})
    end
    for _, enemy in ipairs(self._dungeonConfig.pvp_rivals4 or {}) do
        table.insert(loadingOthers, {TYPE_CACHE_TEXTURE, db:getCharacterByID(enemy.actorId).aid_bust})
    end
    for _, enemy in ipairs(self._dungeonConfig.pvp_rivals6 or {}) do
        table.insert(loadingOthers, {TYPE_CACHE_TEXTURE, db:getCharacterByID(enemy.actorId).aid_bust})
    end
    -- ccbi
    for i = 1, 4 do
        table.insert(loadingOthers, {TYPE_LOAD_HERO_STATUS_CCBI})
    end
    for i = 1, 8 do
        table.insert(loadingOthers, {TYPE_LOAD_SKILL_COOLDONW_CCBI})
    end
    table.insert(loadingOthers, {TYPE_LOAD_SUPPORT_HERO_BUST_CCBI})
    table.insert(loadingOthers, {TYPE_LOAD_SUPPORT_ENEMY_BUST_CCBI})
    self._dungeonConfig.heroStatusView = {}
    self._dungeonConfig.heroStatus3View = {}
    self._dungeonConfig.activeSkillCoolDownView = {}
    self._dungeonConfig.supportHeroBustView = nil
    self._dungeonConfig.supportEnemyBustView = nil

    -- damage font atlas and texture
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/battle_bumber_all.plist")

    -- effects
    if self._dungeonConfig.isReplay then
        local supportHeroInfos = self._dungeonConfig.supportHeroInfos or {}
        local supportHeroInfos2 = self._dungeonConfig.supportHeroInfos2 or {}
        local supportHeroInfos3 = self._dungeonConfig.supportHeroInfos3 or {}
        if next(supportHeroInfos) or next(supportHeroInfos2) or next(supportHeroInfos3) then
            for _, heroInfo in ipairs(self._dungeonConfig.heroInfos) do
                local character = db:getCharacterByID(heroInfo.actorId)
                local effect1, effect2
                if character.func == "t" then
                    effect1, effect2 = "aid_buff_1", "aid_buff_dun_1"
                elseif character.func == "health" then
                    effect1, effect2 = "aid_buff_3", "aid_buff_shu_1"
                elseif character.func == "dps" then
                    if character.attack_type == 1 then
                        effect1, effect2 = "aid_buff_2", "aid_buff_jian_1"
                    elseif character.attack_type == 2 then
                        effect1, effect2 = "aid_buff_4", "aid_buff_zhang_1"
                    else
                        assert(false, "")
                    end
                else
                    assert(false, "")
                end
                -- table.insert(loadingOthers, {TYPE_LOAD_SUPPORT_HERO_BUFF_EFFECTS, heroInfo.actorId, effect1, effect2})
            end
        end
    else
        if next(remote.teamManager:getActorIdsByKey(teamName, remote.teamManager.TEAM_INDEX_HELP)) or 
            next(remote.teamManager:getActorIdsByKey(teamName, remote.teamManager.TEAM_INDEX_HELP2)) or
            next(remote.teamManager:getActorIdsByKey(teamName, remote.teamManager.TEAM_INDEX_HELP3)) then
            for _, heroId in ipairs(remote.teamManager:getActorIdsByKey(teamName)) do
                local character = db:getCharacterByID(heroId)
                local effect1, effect2
                if character.func == "t" then
                    effect1, effect2 = "aid_buff_1", "aid_buff_dun_1"
                elseif character.func == "health" then
                    effect1, effect2 = "aid_buff_3", "aid_buff_shu_1"
                elseif character.func == "dps" then
                    if character.attack_type == 1 then
                        effect1, effect2 = "aid_buff_2", "aid_buff_jian_1"
                    elseif character.attack_type == 2 then
                        effect1, effect2 = "aid_buff_4", "aid_buff_zhang_1"
                    else
                        assert(false, "")
                    end
                else
                    assert(false, "")
                end
                table.insert(loadingOthers, {TYPE_LOAD_SUPPORT_HERO_BUFF_EFFECTS, heroId, effect1, effect2})
            end
        end
    end
    if (self._dungeonConfig.pvp_rivals2 and next(self._dungeonConfig.pvp_rivals2)) or
        (self._dungeonConfig.pvp_rivals4 and next(self._dungeonConfig.pvp_rivals4)) or
        (self._dungeonConfig.pvp_rivals6 and next(self._dungeonConfig.pvp_rivals6)) then
        for _, enemy in ipairs(self._dungeonConfig.pvp_rivals) do
            local character = db:getCharacterByID(enemy.actorId)
            local effect1, effect2
            if character.func == "t" then
                effect1, effect2 = "aid_buff_1", "aid_buff_dun_1"
            elseif character.func == "health" then
                effect1, effect2 = "aid_buff_3", "aid_buff_shu_1"
            elseif character.func == "dps" then
                if character.attack_type == 1 then
                    effect1, effect2 = "aid_buff_2", "aid_buff_jian_1"
                elseif character.attack_type == 2 then
                    effect1, effect2 = "aid_buff_4", "aid_buff_zhang_1"
                else
                    assert(false, "")
                end
            else
                assert(false, "")
            end
            table.insert(loadingOthers, {TYPE_LOAD_SUPPORT_ENEMY_BUFF_EFFECTS, enemy.actorId, effect1, effect2})
        end
    end
    self._dungeonConfig.supportHeroBuffEffects = {}
    self._dungeonConfig.supportEnemyBuffEffects = {}

    local uuid_processed = false

    local TYPE_CACHE_TEXTURE = TYPE_CACHE_TEXTURE
    local TYPE_CACHE_TEXTURE_ATLAS = TYPE_CACHE_TEXTURE_ATLAS
    -- local TYPE_CREATE_HEROES = TYPE_CREATE_HEROES
    local TYPE_LOAD_HERO_STATUS_CCBI = TYPE_LOAD_HERO_STATUS_CCBI
    local TYPE_LOAD_SKILL_COOLDONW_CCBI = TYPE_LOAD_SKILL_COOLDONW_CCBI
    local TYPE_LOAD_SUPPORT_HERO_BUST_CCBI = TYPE_LOAD_SUPPORT_HERO_BUST_CCBI
    local TYPE_LOAD_SUPPORT_ENEMY_BUST_CCBI = TYPE_LOAD_SUPPORT_ENEMY_BUST_CCBI
    local TYPE_LOAD_SUPPORT_HERO_BUFF_EFFECTS = TYPE_LOAD_SUPPORT_HERO_BUFF_EFFECTS
    local TYPE_LOAD_SUPPORT_ENEMY_BUFF_EFFECTS = TYPE_LOAD_SUPPORT_ENEMY_BUFF_EFFECTS
    if DISABLE_LOAD_BATTLE_RESOURCES or true then
        TYPE_CACHE_TEXTURE = nil
        TYPE_CACHE_TEXTURE_ATLAS = nil
        -- local TYPE_CREATE_HEROES = nil
        TYPE_LOAD_HERO_STATUS_CCBI = nil
        TYPE_LOAD_SKILL_COOLDONW_CCBI = nil
        TYPE_LOAD_SUPPORT_HERO_BUST_CCBI = nil
        TYPE_LOAD_SUPPORT_ENEMY_BUST_CCBI = nil
        -- TYPE_LOAD_SUPPORT_HERO_BUFF_EFFECTS = nil
        -- TYPE_LOAD_SUPPORT_ENEMY_BUFF_EFFECTS = nil
    end

    -- start loading
    local loadingIndex = 1
    self._loadingFrameId = scheduler.scheduleUpdateGlobal(function(dt)
        if uuid_processed == false then
            -- set_replay_pseudo_id(0)
        end

        for i=1,2 do
            local item = loadingOthers[loadingIndex]

            if item[1] == TYPE_CACHE_TEXTURE then
                CCTextureCache:sharedTextureCache():addImage(item[2])

            elseif item[1] == TYPE_CACHE_TEXTURE_ATLAS then
                CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(item[2], item[3])
                
            elseif item[1] == TYPE_LOAD_HERO_STATUS_CCBI then
                local view = QHeroStatusView.new()
                view:retain()
                table.insert(self._dungeonConfig.heroStatusView, view)

            elseif item[1] == TYPE_LOAD_SKILL_COOLDONW_CCBI then
                local view = QHeroSkillCoolDown.new()
                view:retain()
                table.insert(self._dungeonConfig.activeSkillCoolDownView, view)

            elseif item[1] == TYPE_LOAD_SUPPORT_HERO_BUST_CCBI then
                local owner = {}
                local proxy = CCBProxy:create()
                local root = CCBuilderReaderLoad("Battle_Aid_Appear.ccbi", proxy, owner)
                root.owner = owner
                root:retain()
                self._dungeonConfig.supportHeroBustView = root

            elseif item[1] == TYPE_LOAD_SUPPORT_ENEMY_BUST_CCBI then
                local owner = {}
                local proxy = CCBProxy:create()
                local root = CCBuilderReaderLoad("Battle_Aid_Appear2.ccbi", proxy, owner)
                root.owner = owner
                root:retain()
                self._dungeonConfig.supportEnemyBustView = root

            elseif item[1] == TYPE_LOAD_SUPPORT_HERO_BUFF_EFFECTS then
                local actorId = item[2]
                local effect1 = QBaseEffectView.createEffectByID(item[3])
                local effect2 = QBaseEffectView.createEffectByID(item[4])
                effect1:retain()
                effect2:retain()
                local effects = {effect1, effect2}
                self._dungeonConfig.supportHeroBuffEffects[actorId] = effects

            elseif item[1] == TYPE_LOAD_SUPPORT_ENEMY_BUFF_EFFECTS then
                local actorId = item[2]
                local effect1 = QBaseEffectView.createEffectByID(item[3])
                local effect2 = QBaseEffectView.createEffectByID(item[4])
                effect1:retain()
                effect2:retain()
                local effects = {effect1, effect2}
                self._dungeonConfig.supportEnemyBuffEffects[actorId] = effects

            end

            self:_onLoadingFrame2(loadingIndex/(#loadingOthers))

            loadingIndex = loadingIndex + 1
            if loadingIndex > #loadingOthers then
                scheduler.unscheduleGlobal(self._loadingFrameId)
                self._loadingFrameId = nil
                self:finish()
                break
            end
        end
        

    end, 0.0)
end


return QDungeonResourceLoader
