require "app.cfg.knight_info"
require "app.cfg.monster_info"
require "app.cfg.play_info"
require "app.cfg.buff_info"
--require "app.cfg.unite_skill_info"
require "app.cfg.dress_info"
local storage = require("app.storage.storage")

local FunctionLevelConst = require "app.const.FunctionLevelConst"
local BattleFieldConst = require "app.scenes.battle.BattleFieldConst"
local BattleConst = require("app.const.BattleConst")
-- BattleLayer

local BattleLayer = class("BattleLayer", function()
    return display.newLayer()
end)

-- battlelayer const

-- 战斗开始
BattleLayer.BATTLE_START = "battle_start"
-- 战斗结束
BattleLayer.BATTLE_FINISH = "battle_finish"
-- 战斗开始拉幕动画结束
BattleLayer.BATTLE_OPENING_FINISH = "battle_openning_finish"
-- 战斗移动(外部)结束
BattleLayer.BATTLE_MOVE_FROM_OUTSIDE_FINISH = "battle_move_from_outside_finish"
-- 战斗波数移动结束
BattleLayer.BATTLE_MOVE_FINISH = "battle_move_finish"
-- 战斗回合数
BattleLayer.BATTLE_ROUND_UPDATE = "battle_round_update"
-- 战斗冒血
BattleLayer.BATTLE_DAMAGE_UPDATE = "battle_damage_update"
-- 某个角色攻击
BattleLayer.BATTLE_SOMEONE_ATTACK = "someone_attack"
-- 某个角色死亡
BattleLayer.BATTLE_SOMEONE_DEAD = "someone_dead"


-- 战斗时间间隔
BattleLayer.BATTLE_DELTA = 1 / 20

-- battle type
BattleLayer.DUNGEON_BATTLE = "dengeon_battle"
BattleLayer.ARENA_BATTLE = "arena_battle"
BattleLayer.MOSHEN_BATTLE = "moshen_battle"
BattleLayer.LEGION_BATTLE = "legion_battle"
BattleLayer.LEGION_CROSS_BATTLE = "legion_cross_battle"
BattleLayer.CROSSWAR_BATTLE = "crosswar_battle"
BattleLayer.ROBRICE_BATTLE = "robrice_battle"
BattleLayer.REBEL_BOSS = "rebel_boss"
BattleLayer.WUSH_BOSS_BATTLE = "wush_boss_battle"
BattleLayer.CRUSADE_BATTLE = "crusade_battle"


BattleLayer.SkipConst = {}

-- skip type
BattleLayer.SkipConst.SKIP_YES = 1          -- 可以跳过
BattleLayer.SkipConst.SKIP_YES_LIMIT = 2    -- 有限制的跳过（读秒)
BattleLayer.SkipConst.SKIP_NO = 3           -- 不能跳过

function BattleLayer.create(...)
    return BattleLayer.new(...)
end

function BattleLayer:ctor(pack, eventHandler)
   if patchMe and patchMe("BattleLayer", self) then return end  
    self._pack = pack
    
    -- 私有变量
    -- 战斗事件接口
    self._eventHandler = eventHandler
    
    -- 用来存放所有战场上的角色的表。
    self._knights = {}
    -- 1表示是我方自己，2表示是敌方
    self._knights[1] = {}
    self._knights[2] = {}

    -- 用来存放战宠，索引1是我方战宠，索引2是敌方战宠
    self._pets = {}
    
    -- 场景特效下层
    self._effectNodeDown = display.newNode()
    self:addChild(self._effectNodeDown)

    -- 宠物虚影层
    self._petShadowNode = display.newNode()
    self:addChild(self._petShadowNode)
    
    -- 节点层，主要显示卡牌
    self._cardNode = display.newNode()
    self:addChild(self._cardNode)

    -- buff特效层，主要负责显示buff特效动画
    self._buffSpNode = display.newNode()
    self:addChild(self._buffSpNode)
    
    -- 场景特效上层
    self._effectNodeUp = display.newNode()
    self:addChild(self._effectNodeUp)
    
    -- 粒子特效
    self._effectParticleNode = display.newNode()
    self:addChild(self._effectParticleNode)

    -- 战宠攻击层
    self._petAttackNode = display.newNode()
    self:addChild(self._petAttackNode)
    
    -- 合击特效层，主要显示合击的特效
    self._comboNode = display.newNode()
    self:addChild(self._comboNode)

    -- 一般特效层，主要负责显示类似普通砍杀的特效动画
    self._normalSpNode = display.newNode()
    self:addChild(self._normalSpNode)

    -- 冒血特效层，主要负责显示冒血特效动画
    self._damageSpNode = display.newNode()
    self:addChild(self._damageSpNode)

    -- 大招特效层，主要负责显示大招特效动画
    self._superSpNode = display.newNode()
    self:addChild(self._superSpNode)

    -- 数据层，主要负责一些战场上的数据显示
    self._dataNode = display.newNode()
    self:addChild(self._dataNode)
    
    -- 载入数据显示
    self._loadDataView = self:_loadDataView(pack.battleType)
    
    self._doubleOptions = {1, 2, 3}
    self._doubleMaxFrames = {1, 1.5, 2}

    local FunctionLevelConst = require "app.const.FunctionLevelConst"
    
    -- 当前倍数
    if not pack.double then
        local params = storage.load(storage.rolePath("battle_double")) or {}
        self._double = params._double or 1
        -- 看看是否到达开启等级，如果到达则直接跳过去
        params = storage.load(storage.rolePath("battle_double_level")) or {_doubleLevel=1}
        -- 直接找最高级别的
        if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.BATTLE_RATE_3, true) and params._doubleLevel < 3 then
            self._double = 3
            storage.save(storage.rolePath("battle_double_level"), {_doubleLevel=3})
        elseif G_moduleUnlock:isModuleUnlock(FunctionLevelConst.BATTLE_RATE_2, true) and params._doubleLevel < 2 then
            self._double = 2
            storage.save(storage.rolePath("battle_double_level"), {_doubleLevel=2})
        end
        -- 记录等级
        storage.save(storage.rolePath("battle_double"), {_double=self._double})
    else
        self._double = pack.double
    end
    
    -- debug
--    self._double = 2
    
    -- 战斗是否结束(默认初始是已经结束的)
    self._isFinish = true
    
    -- 是否暂停
    self._isPause = false
    
    -- 波数
    self._waveCount = pack.waveCount or 1
    
    -- 执行队列, 主要负责播放战斗数据
    self._entryQueue = require("app.scenes.battle.entry.Entry").new()
    self._entryQueue:retainEntry()
    
    -- 载入关卡数据（地图背景数据等）
--    if pack.battleBg then
        self:_loadLevel(pack.battleBg, pack.curWave)
--    end
    
    -- 战报消息
    self:reset(pack.msg)
    
    if pack.moveFromOutside then
        for i=1, #pack.moveFromOutsidePositions do
            self:moveFromOutside(pack.moveFromOutsidePositions[i])
        end
    end
    
    -- 1x
    local doubleCount = self._double
    local double = ui.newImageMenuItem {
        image = G_Path.getBattleImage("jiasu_"..doubleCount..".png"),
        imageSelected = G_Path.getBattleImage("jiasu_"..doubleCount..".png"),
    }
    
    double:setAnchorPoint(ccp(0, 0))
    double:setPosition(ccp(10, 10))
    
    -- 现在所有不满足5级开启的2倍数都是1倍数, 并且不显示倍数按钮
    if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.BATTLE_RATE_2, true) then
        double:setVisible(false)
        self._double = 2
    end
    
    double:registerScriptTapHandler(function()
        
        if self._isFinish then return end
        
        local result = true
        
        if doubleCount + 1 == 2 then
            result = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.BATTLE_RATE_2, true)
            if result then doubleCount = (doubleCount + 1) % (#self._doubleOptions+1) end
        elseif doubleCount + 1 == 3 then
            result = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.BATTLE_RATE_3, true)
            doubleCount = (doubleCount + 1) % (#self._doubleOptions+1)
        else
            doubleCount = (doubleCount + 1) % (#self._doubleOptions+1) ~= 0 and (doubleCount + 1) % (#self._doubleOptions+1) or 1
        end
        
        if not result then return end
        
        self._double = doubleCount
        
        if self._double == 0 then self._double = 1 end
        double:setNormalImage(display.newSprite(G_Path.getBattleImage("jiasu_"..self._double..".png")))
        double:setSelectedImage(display.newSprite(G_Path.getBattleImage("jiasu_"..self._double..".png")))
        
        --save
        storage.save(storage.rolePath("battle_double"), {_double=self._double})
    end)

-- if open the debug panel
local pause = nil
local restart = nil
local nextStep = nil
if BattleConst.SHOW_HP_DETAIL == true then
    -- pause
     pause = ui.newTTFLabelMenuItem {
         text = "Pause",
         font = "Marker Felt",
         size = 40,
         align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
     }
    
     pause:setAnchorPoint(ccp(0.5, 0))
     pause:setPosition(ccp(display.width / 2, 10))
    
     pause:registerScriptTapHandler(function(_, target)
         if self._isFinish then return end
         if not self._isPause then
             self:pause()
             local menuItemLabel = tolua.cast(target, "CCMenuItemLabel")
             menuItemLabel:setString("Resume")
         else
             self:resume()
             local menuItemLabel = tolua.cast(target, "CCMenuItemLabel")
             menuItemLabel:setString("Pause")
         end
     end)
    
    -- restart
     restart = ui.newTTFLabelMenuItem {
         text = "Restart",
         font = "Marker Felt",
         size = 40,
         align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
     }
    
     restart:setAnchorPoint(ccp(1, 0))
     restart:setPosition(ccp(display.width / 2 - 60, 10))
    
     restart:registerScriptTapHandler(function()
         self:replay()
     end)
    
    -- Next
     nextStep = ui.newTTFLabelMenuItem {
         text = "Next",
         font = "Marker Felt",
         size = 40,
         align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
     }
    
     nextStep:setAnchorPoint(ccp(0, 0))
     nextStep:setPosition(ccp(display.width / 2 + 100, 10))
    
     nextStep:registerScriptTapHandler(function()
         if self._isFinish then return end
         self:next()
     end)
 end
    
    -- skip
    local skip = ui.newImageMenuItem {
        image = G_Path.getBattleTxtImage("zd-tiaoguo.png"),
        imageSelected = G_Path.getBattleTxtImage("zd-tiaoguo.png"),
        imageDisabled = G_Path.getBattleTxtImage("zd-tiaoguo-gray.png")
    }
    
    assert(pack.skip == BattleLayer.SkipConst.SKIP_YES or pack.skip == BattleLayer.SkipConst.SKIP_YES_LIMIT or pack.skip == BattleLayer.SkipConst.SKIP_NO, "Unknown skip type: "..tostring(pack.skip))
    
    skip.isSkip = pack.skip
 --   skip:setVisible((skip.isSkip == BattleLayer.SkipConst.SKIP_YES or skip.isSkip == BattleLayer.SkipConst.SKIP_YES_LIMIT) and true or false)
    skip:setVisible(true)
    skip:setAnchorPoint(ccp(1, 0))
    skip:setPosition(ccp(display.width-10, 10))

    skip.countDown = function()
        
        local countDown = skip.isSkip == BattleLayer.SkipConst.SKIP_YES_LIMIT and 10 or nil
        if countDown then
            
            -- 按钮不可用
            skip:setEnabled(false)
            -- 按钮可用但是可点击图得换一下
            skip:setNormalImage(display.newSprite(G_Path.getBattleTxtImage("zd-tiaoguo-gray.png")))
            skip:setSelectedImage(display.newSprite(G_Path.getBattleTxtImage("zd-tiaoguo-gray.png")))
            
            skip.isDone = false
            
            -- 倒计时文本
            
            local label = Label:create()
            label:setFontName(G_Path.getBattleLabelFont())
            label:setFontSize(26)
            label:setColor(ccc3(255, 0, 0))
            label:createStroke(Colors.strokeBlack, 1)
            label:setText(string.format("%02d:%02d", 0, countDown))
            
            skip:addChild(label)
            skip.countDownLabel = label
            label:setPosition(ccp(skip:getContentSize().width/2, skip:getContentSize().height+label:getContentSize().height/2))
            label:runAction(CCRepeat:create(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(function()
                countDown = countDown - 1
                label:setText(string.format("%02d:%02d", 0, countDown))
                if countDown == 0 then
                    label:removeFromParent()
                    skip.countDownLabel = nil
                    skip:setEnabled(true)
                                                
                    -- 表示倒计时结束
                    skip.isDone = true
                    
                    skip:setNormalImage(display.newSprite(G_Path.getBattleTxtImage("zd-tiaoguo.png")))
                    skip:setSelectedImage(display.newSprite(G_Path.getBattleTxtImage("zd-tiaoguo.png")))
                end
            end)), countDown+1))
            
        end
    end
    
    skip.stopCountDown = function()
        if skip.countDownLabel then
            skip.countDownLabel:removeFromParent()
            skip.countDownLabel = nil
        end
    end
    
    if skip.isSkip == BattleLayer.SkipConst.SKIP_YES_LIMIT then
        skip:countDown()
    end

    skip:registerScriptTapHandler(handler(self, self._onUpdateNotifity))
    
    self._skipBtn = skip

    local menu = ui.newMenu{double, pause, restart, nextStep, skip}
    self:addChild(menu, 100)
    
    self:setNodeEventEnabled(true)

    -- 关闭聊天
    GlobalFunc.showChatBtn(false)
    
    -- 禁用返回键
    uf_keypadHandler:enableKeypadEvent(false)
    
--    self:setScale(0.5)
    
    self._textureCache = {}
    
    -- 有一些特效要一直放在缓存里
    local function _loadCommonRes(spFilePath)
        display.addSpriteFramesWithFile(spFilePath..".plist", spFilePath..".png")
        local texture = CCTextureCache:sharedTextureCache():textureForKey(spFilePath..".png")
        assert(texture, "Could not load the texture with plist: "..spFilePath..".plist")
        
        -- 手动保存，防止被误释放
        self._textureCache[spFilePath..".png"] = texture
        texture:retain()
    end

    _loadCommonRes("battle/sp/sp_char_show/sp_char_show")
    _loadCommonRes("battle/sp/sp_char_die/sp_char_die")
    _loadCommonRes("battle/sp/sp_angerfull/sp_angerfull")
end

function BattleLayer:_onUpdateNotifity()
    
    if self._isFinish then return end

    -- 普通叛军战斗，跳过按钮是提前5级可见的，但是如果没到解锁等级，并不让它真的跳过
    if self._pack.battleType == BattleLayer.MOSHEN_BATTLE then
        if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.MOSHENG_BATTLE_SKIP) then
            return
        end
    end

    -- 然后看看谁死亡了播放死亡特效
    local result = rawget(self._message, "result")
    assert(result, "The result of message could not be nil !")

    self._skipBtn:setVisible(false)

    -- 清空entry
    if self._entryQueue then
        self._entryQueue:releaseEntry()
        self._entryQueue = require("app.scenes.battle.entry.Entry").new()
        self._entryQueue:retainEntry()
    end

    -- 重置knight
    for i=1, #self._knights do
        for k, knight in pairs(self._knights[i]) do
            if not knight:isDead() then
                self:_resetKnight(knight)
            end
        end
    end

    local leftOwnTeams = rawget(result, "left_own_teams")
    if leftOwnTeams then
        local units = rawget(leftOwnTeams, "units")
        if units then
            for i=1, #units do
                local unit = units[i]
                local knight = self._knights[1][tostring(unit.position+1)]
                if knight then
                    knight:changeHp(math.min(0, unit.hp - knight:getHPAmount()))
                    knight.alive = true
                end
            end
        end
    end

    local leftEnemyTeams = rawget(result, "left_enemy_teams")
    if leftEnemyTeams then
        local units = rawget(leftEnemyTeams, "units")
        if units then
            for i=1, #units do
                local unit = units[i]
                local knight = self._knights[2][tostring(unit.position+1)]
                if knight then
                    knight:changeHp(math.min(0, unit.hp - knight:getHPAmount()))
                    knight.alive = true
                end
            end
        end
    end

    -- 死亡动画
    local entrySet = require("app.scenes.battle.entry.Entry").new()
    local ActionEntry = require "app.scenes.battle.entry.ActionEntry"

    for i=1, #self._knights do
        for k, knight in pairs(self._knights[i]) do
            -- 中途被秒杀死了的武将直接删除
            if knight:isDead() then
                self:_removeKnight(_, knight)
            elseif not knight.alive then
                knight:setHPVisible(false)
                knight:setNameVisible(false)
                knight:setAngerVisible(false)
                knight:setAwakenStarVisible(false)
                knight:setBreathAniEnabled(false)
                knight:delAllBuffs()
                knight:setIsDead(true)

                if not knight.isBoss then

                    local deadEntry = ActionEntry.new(BattleFieldConst.action.CHAR_DIE, knight, self)
                    entrySet:addEntryToQueue(deadEntry, deadEntry.updateEntry, nil, knight)
                    -- 死亡音效
                    deadEntry:addEntryToNewQueue(nil, function()
                        local deadSound = knight:getCardConfig().dead_sound ~= "0" and knight:getCardConfig().dead_sound or nil
                        if deadSound then
                            require("app.sound.SoundManager"):playSound(deadSound)
                        end
                        require("app.sound.SoundManager"):playSound(require("app.const.SoundConst").BattleSound.BATTLE_DEAD)
                        return true
                    end)
                    entrySet:addOnceEntryToQueue(self, self._removeKnight, nil, knight, knight)
                else
                    local check = nil
                    entrySet:addEntryToQueue(nil, function(_, frameIndex)
                        if not check then check = knight:playDead() end
                        return check(frameIndex)
                    end, nil, knight)
                    entrySet:addOnceEntryToQueue(self, self._removeKnight, nil, knight, knight)
                end

            end
        end
    end

    self:addEntryToQueue(entrySet, entrySet.updateEntry)

end

function BattleLayer:onCleanup()
    
    self:_clear()
    
    if self._entryQueue then
        self._entryQueue:releaseEntry()
        self._entryQueue = nil
    end
    
    self:_purgeTextureCached()
    
    for k, texture in pairs(self._textureCache) do
        CCTextureCache:sharedTextureCache():removeTexture(texture)
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromTexture(texture)

        texture:release()
    end
    
    self._textureCache = {}
    
    -- 开启聊天
    GlobalFunc.showChatBtn(true)
    
    if not G_GuideMgr or not G_GuideMgr:isCurrentGuiding() then
        -- 开启返回键
        uf_keypadHandler:enableKeypadEvent(true)
    end
    
end

function BattleLayer:_purgeTextureCached()
    
    self._spriteFrames = self._spriteFrames or {}
    for key in pairs(self._spriteFrames) do
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromTexture(CCTextureCache:sharedTextureCache():textureForKey(key))
        CCTextureCache:sharedTextureCache():removeTextureForKey(key)
    end
    self._spriteFrames = nil
    
    -- 清除颜色shader
--    G_ColorShaderManager:removeColors()
    
    require("app.scenes.battle.LoadTexture").clear()
    
end

function BattleLayer:addSpriteFrameList(frame)
    self._spriteFrames = self._spriteFrames or {}
    self._spriteFrames[frame] = true
end

function BattleLayer:addEntryToSynchQueue(...)
    self._entryQueue:addEntryToNewQueue(...)
end

function BattleLayer:addEntryToQueue(...)
    self._entryQueue:addEntryToQueue(...)
end

function BattleLayer:addOnceEntryToQueue(...)
    self._entryQueue:addOnceEntryToQueue(...)
end

function BattleLayer:insertEntryToQueueAtTop(...)
    self._entryQueue:insertEntryToQueueAtTop(...)
end

function BattleLayer:addToPetShadowNode(node, ...)
    assert(node, "node could not be nil !")
    self._petShadowNode:addChild(node, ...)
end

function BattleLayer:addToCardNode(node, ...)
    assert(node, "node could not be nil !")
    self._cardNode:addChild(node, ...)
end

function BattleLayer:addToPetAttackNode(node, ...)
    assert(node, "node could not be nil !")
    self._petAttackNode:addChild(node, ...)
end

function BattleLayer:addToComboNode(node, ...)
    assert(node, "node could not be nil !")
    self._comboNode:addChild(node, ...)
end

function BattleLayer:addToBuffSpNode(node, ...)
    assert(node, "node could not be nil !")
    self._buffSpNode:addChild(node, ...)
end

function BattleLayer:addToDamageSpNode(node, ...)
    assert(node, "node could not be nil !")
    self._damageSpNode:addChild(node, ...)
end

function BattleLayer:addToSuperSpNode(node, ...)
    assert(node, "node could not be nil !")
    self._superSpNode:addChild(node, ...)
end

function BattleLayer:addToNormalSpNode(node, ...)
    assert(node, "node could not be nil !")
    self._normalSpNode:addChild(node, ...)
end

function BattleLayer:addToDataNode(node, ...)
    assert(node, "node could not be nil !")
    self._dataNode:addChild(node, ...)
end

function BattleLayer:getCardNode()      return self._cardNode      end
function BattleLayer:getPetShadowNode() return self._petShadowNode end
function BattleLayer:getPetAttackNode() return self._petAttackNode end

--function BattleLayer:addToSceneNode(node, ...)
--    assert(node, "node could not be nil !")
--    CCDirector:sharedDirector():getRunningScene():addChild(node, ...)
--end

function BattleLayer:getHeroKnight() return self._knights[1] end
function BattleLayer:getEnemyKnight() return self._knights[2] end
function BattleLayer:getHeroPet() return self._pets[1] end
function BattleLayer:getEnemyPet() return self._pets[2] end
function BattleLayer:getPets() return self._pets end

function BattleLayer:getHeroKnightAmount() return table.nums(self._knights[1]) end
function BattleLayer:getEnemyKnightAmount() return table.nums(self._knights[2]) end

function BattleLayer:getHeroKnightUpAmount() return self._heroKnightUpAmount or 0 end
function BattleLayer:getEnemyKnightUpAmount() return self._monsterKnightUpAmount or 0 end

-- 获取我方最后剩余人数
function BattleLayer:getLeftHeroKnightAmount()
    if self._message then
        if not rawget(self._message,"result") then
            return 0
        end
    else
        return 0
    end
    local leftOwnTeams = rawget(self._message.result, "left_own_teams")
    if leftOwnTeams then
        local units = rawget(leftOwnTeams, "units")
        if units then
            return #units
        end
    end
    return 0
end

-- 获取敌方最后剩余人数
function BattleLayer:getLeftEnemyKnightAmount()
    if self._message then
        if not rawget(self._message,"result") then
            return 0
        end
    else
        return 0
    end
    local leftEnemyTeams = rawget(self._message.result, "left_enemy_teams")
    if leftEnemyTeams then
        local units = rawget(leftEnemyTeams, "units")
        if units then
            return #units
        end
    end
    return 0
end

-- 获取某一方武将的总血量（初始血量），这里不考虑本地计算的初始血量的情况
function BattleLayer:getKnightTotalHP(identity)
    
    identity = identity or 1
    
    local totalHP = 0
    
    local message = self._message
    
    for i=1, #message.bouts do
        local bout = message.bouts[i]
        if identity == 1 then
            local ownTeamID = bout.own_team
            for i=1, #message.own_teams[ownTeamID+1].units do
                local unit = message.own_teams[ownTeamID+1].units[i]
                totalHP = totalHP + unit.hp
            end
        elseif identity == 2 then
            local enemyTeamID = bout.enemy_team
            for i=1, #message.enemy_teams[enemyTeamID+1].units do
                local unit = message.enemy_teams[enemyTeamID+1].units[i]
                totalHP = totalHP + unit.hp
            end
        end
        break
    end

    return totalHP
end

-- 获取战斗中某一方的当前总血量
function BattleLayer:getKnightCurrentHP(identity)
    
    identity = identity or 1
    
    local currentHP = 0
    
    for k, knight in pairs(self._knights[identity]) do
        currentHP = currentHP + knight:getHPAmount()
    end
    
    return currentHP
end

-- 获取总共战斗回合数
function BattleLayer:getRound()
    local roundNum = 0
    for i, v in ipairs(self._message.bouts[1].rounds) do
        if v.type == BattleFieldConst.ROUND_NORMAL then
            roundNum = roundNum + 1
        end
    end

    return roundNum
    
end

function BattleLayer:play()
    
    if self._isFinish then
        
        self._isFinish = false
        
        -- 战报更换过后需要预加载资源
        self:_loadResPrevious()
        
        local plistLoad = require "app.scenes.battle.PlistLoader"
--        plistLoad.desc()
        
        local list = plistLoad.getList()
        for i=1, #list do
            self:addSpriteFrameList(list[i])
        end
        
        local count = 0
        local isFinish = true
        local totalFinish = false
        
        local TextureLoadFactory = require("app.scenes.battle.LoadTexture")
        
        self:addEntryToSynchQueue(nil, function()
            if isFinish then
                -- 是否全部完成
                totalFinish = count >= #list
                if not totalFinish then
                    count = count + 1
                    isFinish = false
                    TextureLoadFactory.loadTextureAsync({list[count]}, function()
                        isFinish = true
                    end)
                end
            end
            return totalFinish
        end)
        
        self:_restartBattle()
    end
end

function BattleLayer:_clear()
        
    -- 清空entry
    if self._entryQueue then
        self._entryQueue:releaseEntry()
        self._entryQueue = require("app.scenes.battle.entry.Entry").new()
        self._entryQueue:retainEntry()
    end
    
    -- 清理knight
    for i=1, #self._knights do
        for k, v in pairs(self._knights[i]) do
            self:_removeKnight(nil, v)
        end
    end

    -- 清理战宠
    for k, v in pairs(self._pets) do
        self:_removePet(k, v)
    end
	
    G_MemoryUtils:forceGC()
--    print("RESTART BATTLE LUA VM MEMORY USED: "..collectgarbage("count"))
    
--    -- 清理特效节点
--    self._buffSpNode:removeAllChildrenWithCleanup(true);
--    self._normalSpNode:removeAllChildrenWithCleanup(true);
--    self._damageSpNode:removeAllChildrenWithCleanup(true);
--    self._superSpNode:removeAllChildrenWithCleanup(true);
    self._dataNode:removeAllChildrenWithCleanup(true);
    
    -- 战斗是否结束
    self._isFinish = true
    self._isPause = false
    
end

function BattleLayer:replay()
    
    self:_clear()
    
    self:_loadDataView()
    
    self:_loadHero()
    
    self:play()
    
end

function BattleLayer:isPause() return self._isPause end
function BattleLayer:pause()
    if self._isFinish or self._isPause then return end
    self._isPause = true
    self:_stopUpdate()
end

function BattleLayer:resume()
    if self._isFinish or not self._isPause then return end
    self._isPause = false
    self:_startUpdate()
end

function BattleLayer:next()
    if self._isFinish then return end
    self:_update()
end

function BattleLayer:isFinish()
    return self._isFinish
end

function BattleLayer:reset(message)
    
    assert(message, "message could not be nil !!!")
--    print ("BattleLayer:reset: "..tostring(message))pla
    
    -- 因为此方法可能会在战斗中被误调用，所以为了避免误操作导致的战斗错误问题，这里只允许在战斗一波结束或者没有战报的情况下才可能进行操作
    if self._message ~= message and self._isFinish then
        
        self._message = message
        G_Report:setLastBattle(message)
        
        self._pack.msg = message
        
--        dumpTable('message', message)
--        dump(message)
        
        --  如果是不一样的战报要把原来的资源清理掉
        self:_purgeTextureCached()
        
        -- 登记一下我方全员人数和敌方的
        for i=1, #message.bouts do
            local bout = message.bouts[i]
            self._heroKnightUpAmount = #message.own_teams[bout.own_team+1].units
            self._monsterKnightUpAmount = #message.enemy_teams[bout.enemy_team+1].units
            break
        end
        
        -- 这里之所以重新载入英雄是因为每一波怪的英雄是新的 
        -- 先清理Heroknight
        for k, v in pairs(self._knights[1]) do
            self:_removeKnight(nil, v)
        end

        self:_loadHero()

        -- 清理战宠
        for k, v in pairs(self._pets) do
            self:_removePet(k, v)
        end  
    end
end

function BattleLayer:move(waveCount, insertToTop, hideWave)
    
--    if not self._isFinish then return end
    
    assert(waveCount == 1 or waveCount == 2, "Unknown wave count: "..waveCount)
    
    self._curWave = waveCount + 1
    
    -- 移动波数提示更新
    if not self._waveLabel and not hideWave then
        
        self._waveLabel = display.newNode()
        self:addToDataNode(self._waveLabel)
        
        local label = Label:create()
        label:setFontName(G_Path.getBattleLabelFont())
        label:setFontSize(28)
        label:setColor(ccc3(0xfe, 0xf6, 0xd8))
        label:createStroke(Colors.strokeBlack, 1)
        label:setText(G_lang:get("LANG_BATTLEFIELD_WAVE", {curWave = waveCount+1, waveAmount = self._waveCount}))
        
        label:setPosition(ccp(display.width-label:getContentSize().width/2-10, display.height-label:getContentSize().height/2-10))
        self._waveLabel:addChild(label)
        
        local waveName = Label:create()
        waveName:setFontName(G_Path.getBattleLabelFont())
        waveName:setFontSize(28)
        waveName:setColor(ccc3(0xf1, 0xdd, 0x90))
        waveName:createStroke(Colors.strokeBlack, 1)
        waveName:setText(G_lang:get("LANG_BATTLEFIELD_WAVE_NAME"))
        
        waveName:setPosition(ccpAdd(ccp(label:getPosition()), ccp(-0.5 * (label:getContentSize().width+waveName:getContentSize().width), 0)))
        self._waveLabel:addChild(waveName)

        self._waveLabel.setString = function(_, text)
            label:setText(text)
        end
        
    else
        if self._waveLabel then
            self._waveLabel:setString(G_lang:get("LANG_BATTLEFIELD_WAVE", {curWave = waveCount+1, waveAmount = self._waveCount}))
        end
    end
    
    -- 隐藏我方全员的血量和怒气等
    for k, knight in pairs(self._knights[1]) do
        knight:setHPVisible(false)
        knight:setNameVisible(false)
        knight:setAwakenStarVisible(false)
        knight:setAngerVisible(false)
        knight:setBreathAniEnabled(false)
    end
    
    -- 隐藏跳过按钮
    self._skipBtn:setVisible(false)
    
    local Entry = require "app.scenes.battle.entry.Entry"
    local entryAllSet = Entry.new()
    if insertToTop then
        self:insertEntryToQueueAtTop(entryAllSet, entryAllSet.updateEntry)
    else
        self:addEntryToQueue(entryAllSet, entryAllSet.updateEntry)
    end
    
    if waveCount == 1 then
    
--        local moveSpeed = -10 * 40 / 36    -- y轴向下
--        local _, positionY = self._background:getPosition()

        local scaleFactor = self._background:getScale()
        
        local positionX, positionY = self._background:getPosition()
        local dstPosition = ccp(positionX, positionY + -10 * 40)
        local duration = 18
        
        local action = nil
        
        local entrySet = Entry.new()
        
        local pause = "resume"

        -- 人物移动
        local ActionEntry = require "app.scenes.battle.entry.ActionEntry"
        local bSound = false
        for k, knight in pairs(self._knights[1]) do
            for i=1, 3 do
                local actionEntry = ActionEntry.new(BattleFieldConst.action.RUN, knight, self, function(event, ...)
                    if event == "stopbg" then
                        if not bSound then
                            bSound = true
                            require("app.sound.SoundManager"):playSound(require("app.const.SoundConst").BattleSound.BATTLE_MOVE)
                        end
                        pause = "pause"
                    elseif event == "finish" then
                        pause = "resume"
                    end
                end)
                entrySet:addEntryToQueue(actionEntry, actionEntry.updateEntry, nil, knight)
            end
        end
        
        -- 地图移动
        entrySet:addEntryToQueue(nil, function(_, frameIndex)
            
--            local _positionY = positionY + moveSpeed * frameIndex
--            self._background:setPositionY(_positionY)
--    --        local _scaleFactor = LocationFactory.getScaleByPosition{positionX, _positionY} / scaleFactor
--            local _scaleFactor = scaleFactor + 0.7 * 40 / 36 * frameIndex / 100
--            self._background:setScale(_scaleFactor)
--            
--            return frameIndex == 36, pause
            
            if not (pause == "pause") then
                if not action then
                    local ActionFactory = require "app.common.action.Action"
                    action = ActionFactory.newSpawn{
                        ActionFactory.newMoveTo(duration, dstPosition),
                        ActionFactory.newScaleTo(duration, scaleFactor + 0.7*40/100)
                    }

                    action:startWithTarget(self._background)
                    action:retain()
                end

                action:step(1)

                if action:isDone() then
                    action:release()
                    return true, pause
                end
            end
            
            return false, pause
        end)
                
        entryAllSet:addEntryToQueue(entrySet, entrySet.updateEntry)
        
    elseif waveCount == 2 then
        
--        local moveSpeed = -12.8 * 40 / 36   -- y轴向下
--        local _, positionY = self._background:getPosition()

        local scaleFactor = self._background:getScale()
        
        local positionX, positionY = self._background:getPosition()
        local dstPosition = ccp(positionX, positionY + -12.8 * 40)
        local duration = 18
        
        local action = nil
        
        local entrySet = Entry.new()
        
        local pause = "resume"

        -- 人物移动
        local ActionEntry = require "app.scenes.battle.entry.ActionEntry"
        local bSound = false
        for k, knight in pairs(self._knights[1]) do
            for i=1, 3 do
                local actionEntry = ActionEntry.new(BattleFieldConst.action.RUN, knight, self, function(event, ...)
                    if event == "stopbg" then
                        if not bSound then
                            bSound = true
                            require("app.sound.SoundManager"):playSound(require("app.const.SoundConst").BattleSound.BATTLE_MOVE)
                        end
                        pause = "pause"
                    elseif event == "finish" then
                        pause = "resume"
                    end
                end)
                entrySet:addEntryToQueue(actionEntry, actionEntry.updateEntry, nil, knight)
            end
        end
        
        entrySet:addEntryToQueue(nil, function(_, frameIndex)

--            local _positionY = positionY + moveSpeed * frameIndex
--            self._background:setPositionY(_positionY)
--    --        local _scaleFactor = LocationFactory.getScaleByPosition{positionX, _positionY} / scaleFactor
--            local _scaleFactor = scaleFactor + 1.1 * 40 / 36 * frameIndex / 100
--            self._background:setScale(_scaleFactor)
--
--            return frameIndex == 36, pause
            
            if not (pause == "pause") then
                if not action then
                    local ActionFactory = require "app.common.action.Action"
                    action = ActionFactory.newSpawn{
                        ActionFactory.newMoveTo(duration, dstPosition),
                        ActionFactory.newScaleTo(duration, scaleFactor + 1.1*40/100)
                    }

                    action:startWithTarget(self._background)
                    action:retain()
                end

                action:step(1)

                if action:isDone() then
                    action:release()
                    return true, pause
                end
            end
            
            return false, pause
        end)
        
        entryAllSet:addEntryToQueue(entrySet, entrySet.updateEntry)

    end
    
    -- 收尾
    entryAllSet:addOnceEntryToQueue(nil, function()
        
        -- 清空显示
        if self._waveLabel then
            self._waveLabel:removeFromParent()
            self._waveLabel = nil
        end
        
        -- 恢复我方全员的血量和怒气显示
        for k, knight in pairs(self._knights[1]) do
            knight:setHPVisible(true)
            knight:setNameVisible(true)
            knight:setAwakenStarVisible(true)
            knight:setAngerVisible(true)
            knight:setBreathAniEnabled(true)
        end
        
        -- 恢复跳过按钮
     --   self._skipBtn:setVisible((self._skipBtn.isSkip == BattleLayer.SkipConst.SKIP_YES or self._skipBtn.isSkip == BattleLayer.SkipConst.SKIP_YES_LIMIT) and true or false)
     self._skipBtn:setVisible(true)
        if self._skipBtn.isSkip == BattleLayer.SkipConst.SKIP_YES_LIMIT then
            self._skipBtn:countDown()
        end
        
        self:dispatchEvent(BattleLayer.BATTLE_MOVE_FINISH, self._curWave)
        
        return true
    end)
    
end

function BattleLayer:hideSp()
    self._buffSpNode:setVisible(false)
    self._normalSpNode:setVisible(false)
    self._damageSpNode:setVisible(false)
    self._superSpNode:setVisible(false)
end

function BattleLayer:showSp()
    self._buffSpNode:setVisible(true)
    self._normalSpNode:setVisible(true)
    self._damageSpNode:setVisible(true)
    self._superSpNode:setVisible(true)
end

-- @private function
-- 载入关卡
function BattleLayer:_loadLevel(battleBg, curWave)
    
--    battleBg = 'pic/dungeonbattle_map/31007.png'

    -- 背景
    self._background = display.newNode()
    self:addChild(self._background, display.height*-1)
    
    local background = display.newSprite(battleBg)
    self._background:addChild(background)
    
    -- 实际背景图需要按照屏幕尺寸铺满
    local size = background:getContentSize()
    local scaleFactor = display.width / size.width
    size = CCSizeMake(size.width * scaleFactor, size.height * scaleFactor)
        
    background:setScale(display.width / CONFIG_SCREEN_WIDTH * scaleFactor)
    
    self._background:setContentSize(size)
    background:setPosition(ccp(size.width/2, size.height/2))
    
    local setPositionXY = self._background.setPositionXY
    self._background.setPositionXY = function(node, positionX, positionY)
        setPositionXY(node, positionX, positionY)
        local backgroundSize = background:boundingBox().size
        local dstPositionX, dstPositionY = self:convertToNodeSpaceXY(self._background:convertToWorldSpaceXY(backgroundSize.width/2, backgroundSize.height/2))
        self._effectNodeUp:setPositionXY(dstPositionX, dstPositionY)
        self._effectNodeDown:setPositionXY(dstPositionX, dstPositionY)
        self._effectParticleNode:setPositionXY(dstPositionX, dstPositionY)
    end
    
    local setScale = self._background.setScale
    self._background.setScale = function(target, ...)
        setScale(target, ...)
        self._effectNodeUp:setScale(...)
        self._effectNodeDown:setScale(...)
    end
    
    self._background:setAnchorPoint(ccp(0.5, 1140 / 2 / size.height))
    -- 这里需要根据波数自动定位到不同的位置, 这里的计算于移动相同
    if curWave == 1 then
        self._background:setPositionXY(display.cx, display.cy)
    elseif curWave == 2 then
        self._background:setScale(1+0.7*40/100)
        self._background:setPositionXY(display.cx, display.cy + -10 * 40)
    elseif curWave == 3 then
        self._background:setScale(1+0.7*40/100+1.1*40/100)
        self._background:setPositionXY(display.cx, display.cy + -10 * 40 + -12.8 * 40)
    else
        self._background:setPositionXY(display.cx, display.cy)
    end
        
    -- 场景特效
    if battleBg and require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        require "app.cfg.scene_effect_info"
        local scene = scene_effect_info.get(2, battleBg)

        if scene then
            local EffectNode = require "app.common.effects.EffectNode"
            for i=1, 5 do
                local effect = scene['effect_'..i]
                if effect ~= "0" then
                    -- effect
                    if scene['effect_btype_'..i] == 1 then
                        local effectNode = EffectNode.new(effect)
                        local effectType = scene['effect_type_'..i]
                        if effectType == 0 then -- 0表示在上面
                            self._effectNodeUp:addChild(effectNode)
                        elseif effectType == 1 then -- 1表示在下面
                            self._effectNodeDown:addChild(effectNode)
                        else
                            assert(false, "Unknown effect_type: "..effectType)
                        end
                        effectNode:play()
                    -- particle
                    elseif scene['effect_btype_'..i] == 2 then
                        local emiter = CCParticleSystemQuad:create("particles/" .. scene["effect_" .. i] .. ".plist")
--                        self._effectNodeUp:addChild(emiter)
                        self._effectParticleNode:addChild(emiter)
                        --[[ -- 9宫格位置
                            1--2--3
                            |  |  |
                            4--5--6
                            |  |  |
                            7--8--9
                        ]]
                        if scene["effect_position_type_"..i] ~= 0 then
                            local positionType = scene["effect_position_type_"..i]
                            if positionType >= 1 and positionType <= 3 then
                                emiter:setPosition(emiter:getParent():convertToNodeSpace(self._background:convertToWorldSpace(ccp(size.width/2 * (positionType-1), size.height))))
                            elseif positionType >= 4 and positionType <= 6 then
                                emiter:setPosition(emiter:getParent():convertToNodeSpace(self._background:convertToWorldSpace(ccp(size.width/2 * (positionType-4), size.height/2))))
                            elseif positionType >= 7 and positionType <= 9 then
                                emiter:setPosition(emiter:getParent():convertToNodeSpace(self._background:convertToWorldSpace(ccp(size.width/2 * (positionType-7), 0))))
                            end
                        end
                    end
                end
            end
        end
    end
end

function BattleLayer:_loadDataView(battleType)
    
    local loadView = function()
        
        if battleType == BattleLayer.ARENA_BATTLE then return end
        
        local ratio = string.format("%.2f", display.height/display.width)
        
        if ratio <= string.format("%.2f", 853/640) then   -- 853/640是ipad及其系列的分辨率，这里是为了把分辨率在一定范围内的设备修改其UI显示方式
            
            -- 道具
            local itemBox = display.newSprite(G_Path.getBattleImage("diaoluo_daoju_small.png"))
            self:addToDataNode(itemBox)
        --    itemBox:setScale(layer:getContentSize().height / itemBox:getContentSize().height)
            itemBox:setAnchorPoint(ccp(0, 1))
            itemBox:setPosition(ccp(10, display.height - 10))
            self._itemBox = itemBox

            -- 道具计数
    --        local itemBoxCount = ui.newTTFLabel{text="0", font=G_Path.getBattleLabelFont(), size=28, color = ccc3(0xfe, 0xf6, 0xd8)}
            local itemBoxCount = Label:create()
            itemBoxCount:setFontName(G_Path.getBattleLabelFont())
            itemBoxCount:setFontSize(28)
            itemBoxCount:setColor(ccc3(0xfe, 0xf6, 0xd8))
            itemBoxCount:createStroke(Colors.strokeBlack, 1)
            itemBoxCount:setText('0')
            itemBox:addChild(itemBoxCount)
        --    itemBoxCount:setScale(1 / itemBox:getScale())
        --    itemBoxCount:setAnchorPoint(ccp(0, 0.5))
            itemBoxCount:setPosition(ccp(itemBoxCount:getContentSize().width/2 + itemBox:getContentSize().width + 15, itemBox:getContentSize().height / 2))
            itemBoxCount.setString = itemBoxCount.setText
            itemBoxCount.getString = itemBoxCount.getStringValue
            self._itemBoxCount = itemBoxCount

            -- 卡牌
            local knightBox = display.newSprite(G_Path.getBattleImage("diaoluo_wujiang_small.png"))
            self:addToDataNode(knightBox)
        --    knightBox:setScale(layer:getContentSize().height / knightBox:getContentSize().height)
            knightBox:setAnchorPoint(ccp(0, 1))
            knightBox:setPosition(ccp(10, display.height - (knightBox:getContentSize().height + 20)))
            self._knightBox = knightBox

            -- 卡牌计数
    --        local knightBoxCount = ui.newTTFLabel{text="0", font=G_Path.getBattleLabelFont(), size=28, color = ccc3(0xfe, 0xf6, 0xd8)}
            local knightBoxCount = Label:create()
            knightBoxCount:setFontName(G_Path.getBattleLabelFont())
            knightBoxCount:setFontSize(28)
            knightBoxCount:setColor(ccc3(0xfe, 0xf6, 0xd8))
            knightBoxCount:createStroke(Colors.strokeBlack, 1)
            knightBoxCount:setText('0')
            knightBox:addChild(knightBoxCount)
        --    knightBoxCount:setScale(1 / knightBox:getScale())
        --    knightBoxCount:setAnchorPoint(ccp(0, 0.5))
            knightBoxCount:setPosition(ccp(knightBoxCount:getContentSize().width/2 + knightBox:getContentSize().width + 15, knightBox:getContentSize().height / 2))
            knightBoxCount.setString = knightBoxCount.setText
            knightBoxCount.getString = knightBoxCount.getStringValue
            self._knightBoxCount = knightBoxCount

            -- 装备
            local equipBox = display.newSprite(G_Path.getBattleImage("diaoluo_zhuangbei_small.png"))
            self:addToDataNode(equipBox)
        --    equipBox:setScale(layer:getContentSize().height / equipBox:getContentSize().height)
            equipBox:setAnchorPoint(ccp(0, 1))
            equipBox:setPosition(ccp(10, display.height - (knightBox:getContentSize().height * 2 + 30)))
            self._equipBox = equipBox

            -- 装备计数
    --        local equipBoxCount = ui.newTTFLabel{text="0", font=G_Path.getBattleLabelFont(), size=28, color = ccc3(0xfe, 0xf6, 0xd8)}
            local equipBoxCount = Label:create()
            equipBoxCount:setFontName(G_Path.getBattleLabelFont())
            equipBoxCount:setFontSize(28)
            equipBoxCount:setColor(ccc3(0xfe, 0xf6, 0xd8))
            equipBoxCount:createStroke(Colors.strokeBlack, 1)
            equipBoxCount:setText('0')
            equipBox:addChild(equipBoxCount)
        --    goldenBoxCount:setScale(1 / equipBox:getScale())
        --    goldenBoxCount:setAnchorPoint(ccp(0, 0.5))
            equipBoxCount:setPosition(ccp(equipBoxCount:getContentSize().width/2 + equipBox:getContentSize().width + 15, equipBox:getContentSize().height / 2))
            equipBoxCount.setString = equipBoxCount.setText
            equipBoxCount.getString = equipBoxCount.getStringValue
            self._equipBoxCount = equipBoxCount
            
        else
        
            -- 道具
            local itemBox = display.newSprite(G_Path.getBattleImage("diaoluo_daoju_small.png"))
            self:addToDataNode(itemBox)
        --    itemBox:setScale(layer:getContentSize().height / itemBox:getContentSize().height)
            itemBox:setAnchorPoint(ccp(0, 0.5))
            itemBox:setPosition(ccp(10 + display.width * 0.3, display.height - itemBox:getContentSize().height / 2))
            self._itemBox = itemBox

            -- 道具计数
    --        local itemBoxCount = ui.newTTFLabel{text="0", font=G_Path.getBattleLabelFont(), size=28, color = ccc3(0xfe, 0xf6, 0xd8)}
            local itemBoxCount = Label:create()
            itemBoxCount:setFontName(G_Path.getBattleLabelFont())
            itemBoxCount:setFontSize(28)
            itemBoxCount:setColor(ccc3(0xfe, 0xf6, 0xd8))
            itemBoxCount:createStroke(Colors.strokeBlack, 1)
            itemBoxCount:setText('0')
            itemBox:addChild(itemBoxCount)
        --    itemBoxCount:setScale(1 / itemBox:getScale())
        --    itemBoxCount:setAnchorPoint(ccp(0, 0.5))
            itemBoxCount:setPosition(ccp(itemBoxCount:getContentSize().width/2 + itemBox:getContentSize().width + 15, itemBox:getContentSize().height / 2))
            itemBoxCount.setString = itemBoxCount.setText
            itemBoxCount.getString = itemBoxCount.getStringValue
            self._itemBoxCount = itemBoxCount

            -- 卡牌
            local knightBox = display.newSprite(G_Path.getBattleImage("diaoluo_wujiang_small.png"))
            self:addToDataNode(knightBox)
        --    knightBox:setScale(layer:getContentSize().height / knightBox:getContentSize().height)
            knightBox:setAnchorPoint(ccp(0, 0.5))
            knightBox:setPosition(ccp(10 + display.width * 0.15, display.height - knightBox:getContentSize().height / 2))
            self._knightBox = knightBox

            -- 卡牌计数
    --        local knightBoxCount = ui.newTTFLabel{text="0", font=G_Path.getBattleLabelFont(), size=28, color = ccc3(0xfe, 0xf6, 0xd8)}
            local knightBoxCount = Label:create()
            knightBoxCount:setFontName(G_Path.getBattleLabelFont())
            knightBoxCount:setFontSize(28)
            knightBoxCount:setColor(ccc3(0xfe, 0xf6, 0xd8))
            knightBoxCount:createStroke(Colors.strokeBlack, 1)
            knightBoxCount:setText('0')
            knightBox:addChild(knightBoxCount)
        --    knightBoxCount:setScale(1 / knightBox:getScale())
        --    knightBoxCount:setAnchorPoint(ccp(0, 0.5))
            knightBoxCount:setPosition(ccp(knightBoxCount:getContentSize().width/2 + knightBox:getContentSize().width + 15, knightBox:getContentSize().height / 2))
            knightBoxCount.setString = knightBoxCount.setText
            knightBoxCount.getString = knightBoxCount.getStringValue
            self._knightBoxCount = knightBoxCount

            -- 装备
            local equipBox = display.newSprite(G_Path.getBattleImage("diaoluo_zhuangbei_small.png"))
            self:addToDataNode(equipBox)
        --    equipBox:setScale(layer:getContentSize().height / equipBox:getContentSize().height)
            equipBox:setAnchorPoint(ccp(0, 0.5))
            equipBox:setPosition(ccp(10, display.height - equipBox:getContentSize().height / 2))
            self._equipBox = equipBox

            -- 装备计数
    --        local equipBoxCount = ui.newTTFLabel{text="0", font=G_Path.getBattleLabelFont(), size=28, color = ccc3(0xfe, 0xf6, 0xd8)}
            local equipBoxCount = Label:create()
            equipBoxCount:setFontName(G_Path.getBattleLabelFont())
            equipBoxCount:setFontSize(28)
            equipBoxCount:setColor(ccc3(0xfe, 0xf6, 0xd8))
            equipBoxCount:createStroke(Colors.strokeBlack, 1)
            equipBoxCount:setText('0')
            equipBox:addChild(equipBoxCount)
        --    goldenBoxCount:setScale(1 / equipBox:getScale())
        --    goldenBoxCount:setAnchorPoint(ccp(0, 0.5))
            equipBoxCount:setPosition(ccp(equipBoxCount:getContentSize().width/2 + equipBox:getContentSize().width + 15, equipBox:getContentSize().height / 2))
            equipBoxCount.setString = equipBoxCount.setText
            equipBoxCount.getString = equipBoxCount.getStringValue
            self._equipBoxCount = equipBoxCount
        
        end
        
    end
    
    loadView()
    
    return loadView
    
end

-- 获取各个宝箱和计数
function BattleLayer:getItemBox() return self._itemBox end
function BattleLayer:getItemBoxCount() return self._itemBoxCount end

function BattleLayer:getKnightBox() return self._knightBox end
function BattleLayer:getKnightBoxCount() return self._knightBoxCount end

function BattleLayer:getEquipBox() return self._equipBox end
function BattleLayer:getEquipBoxCount() return self._equipBoxCount end

-- 载入英雄
function BattleLayer:_loadHero()

    -- 获取战斗我方英雄数据
    local message = self._message
    local datas = message.own_teams[1].units
    local name = rawget(message, "own_name")
    
    -- 绘制    
    local HeroCardSprite = require "app.scenes.battle.HeroCardSprite"
    local LocationFactory = require "app.scenes.battle.Location"
    
    for i=1 ,#datas do
        local data = datas[i]
        
        local anger = rawget(data, "anger") or 0
        
        local card = knight_info.get(data.id)
        assert(card, "Could not find the card with id: "..data.id)
        local clid = 0
        if rawget(data, "clid") and G_Me.userData:checkCltm(rawget(data, "cltm")) and rawget(data, "clop") then 
            clid = rawget(data, "clid")
        end
        -- 1表示是主角，如果主角有名字（服务器获取）则直接读取，否则读取本地数据缓存，data.name是unit中自己加的字段，主要是剧情战报（本地）自己更改的名字
        local cardSprite = HeroCardSprite.new(card, rawget(data, "name") or (card.type == 1 and (name or G_Me.userData.name) or card.name), data.hp, data.hp, 1, data.position+1, anger, self, 
            rawget(data, "dress_id"), rawget(data, "awaken") or 0 , clid, rawget(message, "own_fight_base") or 1, rawget(data, "wid") or 0, rawget(data, "sacredwp") or 0)

        local position = LocationFactory.getSelfPositionByIndex(data.position+1)
        cardSprite:setPositionXY(position[1], position[2])
        
        cardSprite:setScale(LocationFactory.getScaleByPosition(position))
        
        -- 存储英雄, 根据位置编号, 1表示是我方，2表示是敌方
        self._knights[1] = self._knights[1] or {}
        self._knights[1][tostring(data.position+1)] = cardSprite
        
        self:addToCardNode(cardSprite, position[2]*-1 - data.position)
    end
    
end

function BattleLayer:moveFromOutside(positions)
    
    if not positions or #positions == 0 then
        return
    end
    
    local Entry = require "app.scenes.battle.entry.Entry"
    local entrySet = Entry.new()

    local distance = 0
    local bMatch = false
    
    local knights = {}
    for i=1, #positions do
        -- 去最大的距离屏幕下边缘的位置
        local knight = self._knights[1][tostring(positions[i])]
        assert(knight, "Could not find the knight with position: "..positions[i])
        
        knights[positions[i]] = knight
        distance = math.max(distance, knight:getCardSprite():getCardSpriteHeightInWorldSpace())
        bMatch = positions[i] <= 3
    end

    -- 然后移动到屏幕外
    for k, knight in pairs(knights) do
        knight:setPositionY(knight:getPositionY() - distance)
    end

    -- 人物移动
    local ActionEntry = require "app.scenes.battle.entry.ActionEntry"
    for k, knight in pairs(knights) do

        -- 隐藏名字，血条和怒气
        knight:setBreathAniEnabled(false)
        knight:setHPVisible(false)
        knight:setNameVisible(false)
        knight:setAwakenStarVisible(false)
        knight:setAngerVisible(false)

        -- 移动, 3此表示人物都站最后一排，因为距离不同，所以处最后一排的只移动两次，而有人站前排的则移动3次
        local times = bMatch and 3 or 2

        for i=1, times do
            local MoveEntry = require "app.scenes.battle.entry.MoveEntry"
            local moveEntry = MoveEntry.new(ccp(0, distance / times), knight, 6)
            moveEntry:addEntryToNewQueue(nil, function(_, frameIndex)
                return frameIndex == 9  -- action_run总共有9帧，前6帧为移动，后3帧为停止，所以总共是9帧
            end)
            entrySet:addEntryToQueue(moveEntry, moveEntry.updateEntry, nil, "script_move"..k)

            -- 移动的动作
            local actionEntry = ActionEntry.new(BattleFieldConst.action.RUN, knight, self, function(event, ...)
                if event == "stopbg" then
                    require("app.sound.SoundManager"):playSound(require("app.const.SoundConst").BattleSound.BATTLE_MOVE)
                end
            end)
            entrySet:addEntryToQueue(actionEntry, actionEntry.updateEntry, nil, "script_action_move"..k)
        end
    end

    self:addEntryToQueue(entrySet, entrySet.updateEntry)

    self:addEntryToQueue(nil, function()
        for k, knight in pairs(knights) do
            -- 恢复名字，血条和怒气
            knight:setBreathAniEnabled(true)
            knight:setHPVisible(true)
            knight:setNameVisible(true)
            knight:setAwakenStarVisible(true)
            knight:setAngerVisible(true)
        end

        -- 从屏幕外入场结束
        self:dispatchEvent(BattleLayer.BATTLE_MOVE_FROM_OUTSIDE_FINISH, positions)

        return true
    end)
    
end

-- 更新操作
function BattleLayer:_update(dt)
    
    dt = dt or BattleLayer.BATTLE_DELTA
    
    self._delta = self._delta or 0
    self._delta = self._delta + dt
    
    -- 计算实际上应该播放多少帧
    local actualInterval = BattleLayer.BATTLE_DELTA/self._doubleOptions[self._double]
    local frames = math.floor(self._delta/actualInterval)

    -- 更新角色
    for i=1, #self._knights do
        for key, knight in pairs(self._knights[i]) do
            -- 呼吸动画
            knight:updateBreathAnimation()
        end
    end
    if frames >= self._doubleMaxFrames[self._double] then frames = self._doubleMaxFrames[self._double] end
    
    for s=1, frames do

        self._delta = self._delta - actualInterval

        -- 更新角色buff
        for i=1, #self._knights do
            for key, knight in pairs(self._knights[i]) do
                -- 更新角色本身
                knight:update()
                -- buff特效
--                knight:updateBuff()
                -- 怒气特效
--                knight:updateAnger()
            end
        end

        -- 更新战宠
        for k, v in pairs(self._pets) do
            v:update()
        end

        if self._entryQueue:isDone() then

            for i=1, #self._knights do
                for key, knight in pairs(self._knights[i]) do
                    knight:delAllBuffs()
                end
            end
            
            self._isFinish = true
            self:_stopUpdate()
            
            uf_eventManager:dispatchEvent(BattleLayer.BATTLE_FINISH, nil, false, self)

            -- 调用战斗结束后回调
            self:dispatchEvent(BattleLayer.BATTLE_FINISH)

            G_MemoryUtils:forceGC()
--            print("BATTLE FINISH LUA VM MEMORY USED: "..collectgarbage("count"))

            break
        end

        -- 更新队列
        self._entryQueue:updateEntry()

    end
end

function BattleLayer:_restartBattle()
    -- 清理上一波残留的敌军数据(因为复活技能的关系，现在武将死了不会立马清除，战斗结束才清除)
    self:_removeAllEnemies()
    
    uf_eventManager:dispatchEvent(BattleLayer.BATTLE_START, nil, false, self)
    
    self:dispatchEvent(BattleLayer.BATTLE_OPENING_FINISH)
    
    local bouts = self._message.bouts
    
    -- 初始化战斗数据（Entry）
    local BoutEntry = require("app.scenes.battle.entry.BoutEntry")
    local boutIndex = 0
    local function nextBout()
        
        -- 开始呼吸动画
        for key, knight in pairs(self._knights[1]) do
            self:addEntryToSynchQueue(nil, function()
                knight:setBreathAniEnabled(true)
                return true
            end)
        end
        
        boutIndex = boutIndex + 1
        
        local boutData = bouts[boutIndex]
        if not boutData then return true end
        
        local bout = BoutEntry.new(boutData, self._knights, self, self._message, self._curWave or 1, self._waveCount, self._pack.battleType)
        self:addEntryToQueue(bout, bout.updateEntry, handler(self, self._onBattleEvent))
        
        self:addOnceEntryToQueue(nil, nextBout)
        return true
    end
    
    self:addOnceEntryToQueue(nil, nextBout)
    
    self:_startUpdate()
--    self._isFinish = false
    
end

function BattleLayer:_loadResPrevious()
    
    local message = self._message
    
    local plistLoad = require "app.scenes.battle.PlistLoader"
    plistLoad.clear()
    
--    local colorLoad = require "app.scenes.battle.ColorLoader"
--    colorLoad.clear()
    
    local fileUtils = CCFileUtils:sharedFileUtils()
    
    local records = {}
    
    local function _spPath(spName)
        return "battle/sp/"..spName.."/"..spName
    end
    
    local function _spBossPath(spBossName)
        return "battle/boss/"..spBossName.."/"..spBossName
    end
    
    local function _getSpPlist(spName)
        
        if records[spName] then return records[spName] end
                
        local plist = {}
        local spJson = decodeJsonFile(spName..".json")
        assert(spJson, "Could not decode the json: "..spName)
        if (spJson.png and spJson.png ~= "") or fileUtils:isFileExist(fileUtils:fullPathForFilename(spName..".png")) then
            plist[#plist+1] = spName..".png"
        end

        for k, v in pairs(spJson) do
            if v.sp then
                local _list = _getSpPlist(_spPath(v.sp))
                for i=1, #_list do
                    plist[#plist+1] = _list[i]
                end
            end
        end
        
        records[spName] = plist
        
        return plist
    end
    
    local function _getActionPlist(actionName)
        
        if records[actionName] then return records[actionName] end
        
--        print("_getActionPlist: "..actionName)
        local actionJson = decodeJsonFile(actionName)
        local plist = {}
        for key, v in pairs(actionJson) do
            if key == "sp_down_layer" or key == "sp_up_layer" or key == "sp_stage_center_layer" then
                if v.spId then
                    local _list = _getSpPlist(_spPath(v.spId))
                    for i=1, #_list do
                        plist[#plist+1] = _list[i]
                    end
                end
            end
        end
                
        records[actionName] = plist
        
        return plist
    end
    
    local function _getSpColor(spName)
--        print("_getSpColor: "..spName)
        local spJson = decodeJsonFile(spName..".json")
        local colors = {}
        for key, v in pairs(spJson) do
            if type(v) == "table" then
                for k, fx in pairs(v) do
                    if fx.start and fx.start.color then
                        local colorKey = fx.start.color.red.."_"..fx.start.color.green.."_"..fx.start.color.blue
                        if not colors[colorKey] then
                            colors[colorKey] = {fx.start.color.red, fx.start.color.green, fx.start.color.blue}
                        end
                    end
                end
            end
        end
        
        return colors
    end
    
    local function _getActionColor(actionName)
--        print("_getActionColor: "..actionName)
        local actionJson = decodeJsonFile(actionName)
        local colors = {}
        for key, v in pairs(actionJson) do
            if key == "sp_down_layer" or key == "sp_up_layer" or key == "sp_stage_center_layer" then
                if v.spId then
                    local _color = _getSpColor(_spPath(v.spId))
                    for ck, cv in pairs(_color) do
                        if not colors[ck] then colors[ck] = cv end
                    end
                end
            else
                for k, fx in pairs(v) do
                    if fx.start and fx.start.color then
                        local colorKey = fx.start.color.red.."_"..fx.start.color.green.."_"..fx.start.color.blue
                        if not colors[colorKey] then
                            colors[colorKey] = {fx.start.color.red, fx.start.color.green, fx.start.color.blue}
                        end
                    end
                end
            end
        end
        
        return colors
    end
    
    for i=1, #message.bouts do
        local bout = message.bouts[i]
        
        local ownTeamID = bout.own_team
        local enemyTeamID = bout.enemy_team
        
        local knights = {}
        knights[1] = {}
        knights[2] = {}
        
        for i=1, #message.own_teams[ownTeamID+1].units do
            local unit = message.own_teams[ownTeamID+1].units[i]
            knights[1][tostring(unit.position+1)] = unit
        end
        
        for i=1, #message.enemy_teams[enemyTeamID+1].units do
            local unit = message.enemy_teams[enemyTeamID+1].units[i]
            knights[2][tostring(unit.position+1)] = unit
            
            local role_info = message.tp == 1 and knight_info or monster_info
            local card = role_info.get(unit.id)
            assert(card, "Could not find the card with id: "..unit.id)
            
            if card.is_boss and card.is_boss ~= "0" then
               -- boss 资源也需要预加载
               plistLoad.add(_getSpPlist(_spBossPath(card.is_boss)))
            end
        end

        -- preload sp of pet buff
        if rawget(message.own_teams[bout.own_team + 1], "pet") or
           rawget(message.enemy_teams[bout.enemy_team + 1], "pet") then
            plistLoad.add(_getSpPlist(_spPath("sp_zc_jiacheng")))
        end
        
        for j=1, #bout.rounds do
            local round = bout.rounds[j]
            for s=1, #round.attacks do
                local attack = round.attacks[s]
                if rawget(attack, "skill_id") and round.type == ROUND_NORMAL then
                    
                    local attackers = {}
                    
                    local knight = knights[attack.identity][tostring(attack.position+1)]
                    attackers.release_knight = knight
                    
                    local skillConfig = skill_info.get(attack.skill_id)
                    assert(skillConfig, "Could not find the skill config with id: "..attack.skill_id)
                    if skillConfig.is_unite == 1 then -- 1表示是合击
                        
--                        local uniteSkillConfig = unite_skill_info.get(attack.skill_id)
--                        assert(uniteSkillConfig, "Could not find the uniteSkillConfig in unite_skill_info with id: "..attack.skill_id)
--                        
--                        -- 找出所有攻击者对象
--                        for k, v in pairs(knights[attack.identity]) do
--                            local _knight = v
--                            local knightId = (attack.identity == 2 and (message.tp == 1 and knight_info or monster_info) or knight_info).get(_knight.id).advance_code
--                            -- 登记可能的攻击者
--                            attackers.need_knight_1 = attackers.need_knight_1 or ((knightId == uniteSkillConfig.need_knight_1 and _knight) or nil)
--                            attackers.need_knight_2 = attackers.need_knight_2 or ((knightId == uniteSkillConfig.need_knight_2 and _knight) or nil)
--                            attackers.need_knight_3 = attackers.need_knight_3 or ((knightId == uniteSkillConfig.need_knight_3 and _knight) or nil)
--                            attackers.need_knight_4 = attackers.need_knight_4 or ((knightId == uniteSkillConfig.need_knight_4 and _knight) or nil)
--                        end
                        
                        -- 这里直接采用服务器发来的合击对象
                        local uniteIndexs = rawget(attack, 'unite_index') or {}
                        for i=1, #uniteIndexs do
                            attackers['need_knight_'..i] = knights[attack.identity][tostring(uniteIndexs[i]+1)]
                        end
                        
                    end
                    
                    for k, attacker in pairs(attackers) do
                        
                        local knightConfig = clone((attack.identity == 2 and (message.tp == 1 and knight_info or monster_info) or knight_info).get(attacker.id))
                        assert(knightConfig, "Could not find the knightConfig with attack.identity: "..attack.identity.." and attacker.id: "..attacker.id)
                        
                        local dress_id = rawget(attacker, "dress_id")
                        if dress_id and dress_id ~= 0 then
                            local dressInfo = dress_info.get(dress_id)
                            assert(dressInfo, "Could not find the dress info with id: "..dress_id)
                            knightConfig.play_group_id = dressInfo.play_group_id
                        end

                        local playInfo = play_info.get(knightConfig.play_group_id, attack.skill_id)
                        assert(playInfo, "Could not find playInfo with play_group_id("..knightConfig.play_group_id..") and skill_id("..attack.skill_id..") and identity("..attack.identity..")")

                        local attack_action_id = "battle/action/"..playInfo.attack_action_id..".json"
                        if attack.identity == 2 then
                            if fileUtils:isFileExist(fileUtils:fullPathForFilename("battle/action/"..playInfo.attack_action_id.."_r.json")) then
                                attack_action_id = "battle/action/"..playInfo.attack_action_id.."_r.json"
                            end
                        end

                        plistLoad.add(_getActionPlist(attack_action_id))
--                        colorLoad.add(_getActionColor(attack_action_id))

                        local defend_action_id = "battle/action/"..playInfo.defend_action_id..".json"
                        if attack.identity == 1 then
                            if fileUtils:isFileExist(fileUtils:fullPathForFilename("battle/action/"..playInfo.defend_action_id.."_r.json")) then
                                defend_action_id = "battle/action/"..playInfo.defend_action_id.."_r.json"
                            end
                        end

                        plistLoad.add(_getActionPlist(defend_action_id))
--                        colorLoad.add(_getActionColor(defend_action_id))
                        
                        if playInfo.us_defend_action_id ~= "0" then
                            local us_defend_action_id = "battle/action/"..playInfo.us_defend_action_id..".json"
                            plistLoad.add(_getActionPlist(us_defend_action_id))
                        end
                        
                        local bullet_sp_id = playInfo.bullet_sp_id
                        if bullet_sp_id ~= "" and bullet_sp_id ~= "0" then
--                            local spFilePath = 'battle/sp/'..bullet_sp_id.."/"..bullet_sp_id
--                            local spJson = decodeJsonFile(spFilePath..".json")
--                            if (spJson.png and spJson.png ~= "") or fileUtils:isFileExist(fileUtils:fullPathForFilename(spFilePath..".png")) then
--                                plistLoad.add(spFilePath..".png")
--                            end
                            plistLoad.add(_getSpPlist(_spPath(bullet_sp_id)))
--                            colorLoad.add(_getSpColor(_spPath(bullet_sp_id)))
                        end

                    end

                end

                if attack.buff_victims then
                    for i=1, #attack.buff_victims do
                        local victim = attack.buff_victims[i]
                        local buffSpId = nil 
                        if victim and victim.buff_id and buff_info.get(victim.buff_id) then
                            buffSpId = buff_info.get(victim.buff_id).res_id
                        else
                            dump(victim.buff_id)
                        end
                        if buffSpId and buffSpId ~= "" then
--                            local spFilePath = 'battle/sp/'..buffSpId.."/"..buffSpId
--                            local spJson = decodeJsonFile(spFilePath..".json")
--                            if (spJson.png and spJson.png ~= "") or fileUtils:isFileExist(fileUtils:fullPathForFilename(spFilePath..".png")) then
--                                plistLoad.add(spFilePath..".png")
--                            end
                            plistLoad.add(_getSpPlist(_spPath(buffSpId)))
--                            colorLoad.add(_getSpColor(_spPath(buffSpId)))
                        end
                    end
                end
            end
        end
    end
    
--    plistLoad.desc()
--    
--    -- 加载材质贴图
--    require("app.scenes.battle.LoadTexture").loadTextureAsync(plistLoad.getList())
--
--    colorLoad.desc()
--    
--    -- 加载颜色shader
--    G_ColorShaderManager:loadColors(colorLoad.getList())
    
end

function BattleLayer:_stopUpdate()
    self:unscheduleUpdate()
--    if self._updateHandler then
--        local scheduler = require "framework.scheduler"
--        scheduler.unscheduleGlobal(self._updateHandler)
--        self._updateHandler = nil
--        return true
--    end
end

function BattleLayer:_startUpdate()
    self:scheduleUpdate(handler(self, self._update), 0)
--    if not self._updateHandler then
--        local scheduler = require "framework.scheduler"
--        self._updateHandler = scheduler.scheduleGlobal(handler(self, self._update), CCDirector:sharedDirector():getAnimationInterval())
--        return true
--    end
end

function BattleLayer:_removeAllEnemies()
    for k, v in pairs(self._knights[2]) do
        self:_removeKnight(nil, v)
    end
end

function BattleLayer:_removeKnight(_, knight)
    local identity = knight:getIdentity()
    local position = knight:getLocation()
    knight:destroy()    -- 自定义的清理方法
    knight:removeFromParent()
    self._knights[identity][tostring(position)] = nil
    return true
end

function BattleLayer:_removePet(k, pet)
    pet:destroy()
    pet:removeFromParent()
    self._pets[k] = nil
end

function BattleLayer:_resetKnight(knight)
    
    knight:reset()
    knight:setHPVisible(true)
    knight:setNameVisible(true)
    knight:setAwakenStarVisible(true)
    knight:setAngerVisible(true)
--    knight:setBreathAniEnabled(true)
    knight:delAllBuffs()

    local LocationFactory = require "app.scenes.battle.Location"
    
    -- 位置
    local position = nil
    if knight:getIdentity()==1 then position = LocationFactory.getSelfPositionByIndex(knight:getLocation())
    elseif knight:getIdentity()==2 then position = LocationFactory.getEnemyPositionByIndex(knight:getLocation())
    end

    knight:setPosition(ccp(position[1], position[2]))
    -- order
    knight:setZOrder(position[2]*-1 - knight:getLocation()-1)
    if not knight.isBoss then
        knight:setScale(LocationFactory.getScaleByPosition(position))
    end
    
end

function BattleLayer:dispatchEvent(...)
    if self._eventHandler then
        self._eventHandler(...)
    end
end

function BattleLayer:_onBattleEvent(event, target, frameIndex)

    self:dispatchEvent(event)
end

function BattleLayer:getPackParams(key)
    return self._pack and self._pack[key] or nil
end

return BattleLayer