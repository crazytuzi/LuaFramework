-- AttackEntry
require "app.cfg.buff_info"
require "app.cfg.play_info"
require "app.cfg.skill_info"
require "app.cfg.unite_skill_info"

local SoundManager = require "app.sound.SoundManager"
local BattleFieldConst = require "app.scenes.battle.BattleFieldConst"
local EntryWrapper = require "app.scenes.battle.entry.EntryWrapper"

local AttackEntry = class("AttackEntry", require "app.scenes.battle.entry.Entry")

function AttackEntry:initEntry()
        
    AttackEntry.super.initEntry(self)
    
    local attacks = self._data
    local knights = self._objects
    local battleField = self._battleField
    
    attacks.skill_victims = attacks.skill_victims or {}
    
    -- 这里有个坑爹的逻辑，在技能的受害者里可能含有同样的攻击对象，比如类似随机选取血最低的一个攻击，可能与已攻击的队员重复，导致逻辑错误
    -- 所以决定将同样的角色数值合并
    local targets = {}
    targets[1] = {}
    targets[2] = {}
    for i=1, #attacks.skill_victims do
        local skillVictim = attacks.skill_victims[i]
        local target = targets[skillVictim.identity][tostring(skillVictim.position+1)]
        if not target then
            target = clone(skillVictim)
        else
            -- 表示此攻击角色重复，则合并数据
            if rawget(skillVictim, "change_hp") then
                target.change_hp = rawget(target, "change_hp") or 0
                target.change_hp = target.change_hp + skillVictim.change_hp
            end
            
            -- 死亡
            target.state = target.state and skillVictim.state
            -- 暴击
            target.is_crit = target.is_crit or skillVictim.is_crit
            -- 闪避
            target.is_dodge = target.is_dodge and skillVictim.is_dodge
            -- 怒气
            local tAnger = rawget(target, "anger")
            local sAnger = rawget(skillVictim, "anger")
            target.anger = (tAnger and sAnger) and (tAnger + sAnger) or (tAnger or sAnger)
            
            -- 技能清除的buff
            skillVictim.clear_buff = skillVictim.clear_buff or {}
            target.clear_buff = rawget(target, "clear_buff") or {}
            for i=1, #skillVictim.clear_buff do
                target.clear_buff[#target.clear_buff+1] = skillVictim.clear_buff[i]
            end
            
            -- 死亡掉落
            skillVictim.awards = skillVictim.awards or {}
            target.awards = rawget(target, "awards") or {}
            for i=1, #skillVictim.awards do
                target.awards[#target.awards+1] = skillVictim.awards[i]
            end
            
        end
        targets[skillVictim.identity][tostring(skillVictim.position+1)] = target
    end
    
    attacks.skill_victims = {}
    for i=1, #targets do
        for k, v in pairs(targets[i]) do
            attacks.skill_victims[#attacks.skill_victims+1] = v
        end
    end
    
    attacks.anger_victims = attacks.anger_victims or {}
    attacks.buff_victims = attacks.buff_victims or {}
    attacks.cbuff_victims = attacks.cbuff_victims or {}
    
--    -- 保存血量
--    self._knightHPAmount = {}
--    for i=1, #knights do
--        self._knightHPAmount[i] = self._knightHPAmount[i] or {}
--        for k, v in pairs(knights[i]) do
--            self._knightHPAmount[i][k] = v:getHPAmount()
--        end
--    end
    
    -- 攻击者数组
    local attackers = {}
    self._attackers = attackers
    -- 主攻击者
    attackers.release_knight = knights[attacks.identity][tostring(attacks.position+1)]
    
    -- 下面添加的所有队列都需要绑定在指定攻击者身上
    
    -- buffs
    if attacks.buffs and #attacks.buffs > 0 then
        -- 插入buff处理函数
        self:addOnceEntryToQueue(self, self.updateBuff, nil, attackers.release_knight, attacks.buffs)
    end
    
    -- dead
    if not attacks.state then
        self:addOnceEntryToQueue(self, self.updateDead, nil, attackers.release_knight)
        return
    end
    
    if rawget(attacks, "skill_id") then
        
        local skillId = attacks.skill_id
        local skillConfig = skill_info.get(skillId)
        assert(skillConfig, "Could not find the skill config in skill_info with id: "..skillId)

        -- 检查是否是大招
        local skill_type = skillConfig.skill_type
        
        if attackers.release_knight.isBoss then
            
            if skill_type == 2 or skill_type == 4 then
                local check = attackers.release_knight:playCont(handler(self, self.onAttackerEvent))
                self:addEntryToQueue(nil, function(_, frameIndex)
                    return check(frameIndex)
                end, nil, attackers.release_knight)
            else
                local check = attackers.release_knight:playAttack(handler(self, self.onAttackerEvent))
                self:addEntryToQueue(nil, function(_, frameIndex)
                    return check(frameIndex)
                end, nil, attackers.release_knight)
            end
        else
            if skill_type == 4 then     -- 4表示是大招
                
                -- 登记一下，表示是大招，为了后面使用
                self._isSuperSkill = true
                
                local ActionEntry = require "app.scenes.battle.entry.ActionEntry"            
                -- 每一个攻击者的起手动作添加到一个新的队列，并且绑定在攻击者身上
                for k, attacker in pairs(attackers) do
                    local preplayEntry = ActionEntry.new(BattleFieldConst.action.CHAR_SKILLSTART, attacker, battleField)
                    if attacker == attackers.release_knight then
                        -- 音效，绑定在主攻击者身上
                        preplayEntry:addEntryToNewQueue(nil, function()
                            local skillSound = attackers.release_knight:getCardConfig().skill_sound ~= "0" and attackers.release_knight:getCardConfig().skill_sound or nil
                            if skillSound then
                                SoundManager:playSound(skillSound)
                            end
                            SoundManager:playSound(require("app.const.SoundConst").BattleSound.BATTLE_SKILL)
                            return true
                        end)
                    end
                    self:addEntryToQueue(preplayEntry, preplayEntry.updateEntry, nil, attacker)
                end

                if skillConfig.is_unite == 1 then -- 1表示是合击

--                    local uniteSkillConfig = unite_skill_info.get(skillId)
--                    assert(uniteSkillConfig, "Could not find the uniteSkillConfig in unite_skill_info with id: "..skillId)
--
--                    -- 找出所有攻击者对象
--                    for k, v in pairs(knights[attacks.identity]) do
--                        local knight = v
--                        local knightId = knight:getCardConfig().advance_code
--                        -- 登记可能的攻击者
--                        attackers.need_knight_1 = attackers.need_knight_1 or ((knightId == uniteSkillConfig.need_knight_1 and knight) or nil)
--                        attackers.need_knight_2 = attackers.need_knight_2 or ((knightId == uniteSkillConfig.need_knight_2 and knight) or nil)
--                        attackers.need_knight_3 = attackers.need_knight_3 or ((knightId == uniteSkillConfig.need_knight_3 and knight) or nil)
--                        attackers.need_knight_4 = attackers.need_knight_4 or ((knightId == uniteSkillConfig.need_knight_4 and knight) or nil)
--                    end
                    
                    -- 这里直接采用服务器发来的合击对象
                    local uniteIndexs = rawget(attacks, 'unite_index') or {}
                    for i=1, #uniteIndexs do
                        attackers['need_knight_'..i] = knights[attacks.identity][tostring(uniteIndexs[i]+1)]
                    end
                    
                    assert(table.nums(attackers) > 1, "The unite skill need more then two attackers at least !")

                    -- 合击需要把所有的攻击者与受击者统一提出来放到更高一级的图层里显示
                    self:addOnceEntryToQueue(nil, function()

                        -- 黑色背景
                        self._comboSkillBg = CCLayerColor:create(ccc4(0, 0, 0, 255 * 0.7), display.width, display.height + 30)
                        battleField:addToComboNode(self._comboSkillBg)
                        self._comboSkillBg:retain()

                        self._comboCardNode = display.newNode()
                        battleField:addToComboNode(self._comboCardNode)
                        self._comboCardNode:retain()

                        -- 移动攻击者
                        for k, attacker in pairs(attackers) do
                            attacker:retain()
                            local order = attacker:getZOrder()
                            attacker:removeFromParent()
                            self._comboCardNode:addChild(attacker, order)
                            attacker:release()
                        end

                        -- 受害者
                        for i=1, #attacks.skill_victims do
                            local skillVictim = attacks.skill_victims[i]
                            local victim = knights[skillVictim.identity][tostring(skillVictim.position+1)]
                            victim:retain()
                            local order = victim:getZOrder()
                            victim:removeFromParent()
                            self._comboCardNode:addChild(victim, order)
                            victim:release()
                        end

                        return true

                    end, nil, attackers.release_knight)

                    -- 合击文字提示
                    local ComboTipEntry = require "app.scenes.battle.entry.ComboTipEntry"
                    self._comboTipEntrySet = {}
                    for k, attacker in pairs(attackers) do
                        self._comboTipEntrySet[attacker] = ComboTipEntry.create(nil, attacker, battleField)
                        self._comboTipEntrySet[attacker]:retainEntry()
                        self:addEntryToNewQueue(self._comboTipEntrySet[attacker], self._comboTipEntrySet[attacker].updateEntry)
                    end

                    -- 大招拉幕动画
                    local attackerAmount = table.nums(attackers)
                    if attackerAmount == 1 then attackerAmount = "" end
                    local tweenJsonName = "battle/tween/tween_super"..attackerAmount.."F.json"

                    -- 拉幕动画绑定在主要攻击者身上
                    local SuperSkillEntry = require "app.scenes.battle.entry.SuperSkillEntry"
                    local superSkill = SuperSkillEntry.new(tweenJsonName, attacks, attackers, battleField)
                    self:addEntryToQueue(superSkill, superSkill.updateEntry, nil, attackers.release_knight)
                    local superSkillFrame = superSkill:getTotalFrame()

                    -- 其他人做延迟
                    for k, attacker in pairs(attackers) do
                        if k ~= "release_knight" then
                            self:addEntryToQueue(nil, function(_, frameIndex) return frameIndex == superSkillFrame end, nil, attacker)
                        end
                    end

                    -- 取消合击文字提示
                    self:addOnceEntryToQueue(nil, function()
                        for k, comboTipEntry in pairs(self._comboTipEntrySet) do
                            comboTipEntry:releaseEntry()
                        end
                        return true
                    end, nil, attackers.release_knight)

                end

            elseif skill_type == 2 then
                
                self._isSuperSkill = true
                
                -- 播放文字效果
                local CommonSkillEntry = require "app.scenes.battle.entry.CommonSkillEntry"
                local commonSkillEntry = CommonSkillEntry.create(attacks, attackers.release_knight, battleField)
                self:addEntryToQueue(commonSkillEntry, commonSkillEntry.updateEntry, nil, attackers.release_knight)

                -- 同时播放一个出招前的动画效果
                local ActionEntry = require "app.scenes.battle.entry.ActionEntry"
                local preplayEntry = ActionEntry.new(BattleFieldConst.action.CHAR_SKILLSTART, attackers.release_knight, battleField)
                preplayEntry:addEntryToNewQueue(nil, function()
                    local skillSound = attackers.release_knight:getCardConfig().skill_sound ~= "0" and attackers.release_knight:getCardConfig().skill_sound or nil
                    if skillSound then
                        SoundManager:playSound(skillSound)
                    end
                    SoundManager:playSound(require("app.const.SoundConst").BattleSound.BATTLE_SKILL)
                    return true
                end)
                self:addEntryToNewQueue(preplayEntry, preplayEntry.updateEntry)

            end

            -- 保存旧order
            self._oldOrder = {}
            for k, attacker in pairs(attackers) do
                self._oldOrder[attacker] = attacker:getZOrder()
            end

            -- 这个入口集合是专门为了合击的黑底去掉而准备的, 绑定在主攻击者的顺序之后
            local Entry = require("app.scenes.battle.entry.Entry")
            local entrySet = Entry.new()
            self:addEntryToQueue(entrySet, entrySet.updateEntry, nil, attackers.release_knight)

    --        -- 如果是敌方最后一人且攻击造成其死亡则镜头拉近
    --        if attacks.skill_victims[1] and not attacks.skill_victims[1].state and table.nums(knights[2]) == 1 then
    --            for k, knight in pairs(knights[2]) do
    --                if attacks.skill_victims[1].identity == knight:getIdentity() and attacks.skill_victims[1].position+1 == knight:getLocation() then
    --                    local positionX, positionY = knight:getPosition()
    --                    local rect = CCRectMake(positionX - math.min(positionX, display.width/2-math.min(display.width-positionX, display.width/4)), positionY - math.min(positionY, display.height/2-math.min(display.height-positionY, display.height/4)), display.width/2, display.height/2)
    --                    self._focusOn = require("app.common.action.Action").newFocusOn(6, rect)
    --                    entrySet:addEntryToNewQueue(nil, function()
    --                        if not self._focusOn:isRunning() then
    --                            self._focusOn:startWithTarget(battleField)
    --                        end
    --                        if not self._focusOn:isDone() then
    --                            self._focusOn:step(1)
    --                        end
    --                        return self._focusOn:isDone()
    --                    end)
    --                    break
    --                end
    --            end
    --        end

            -- 进攻开始
            for key, attacker in pairs(attackers) do

                local playGroupId = attacker:getCardConfig().play_group_id
                local playInfo = play_info.get(playGroupId, skillId)
                assert(playInfo, "Could not find the playInfo with play_group_id "..playGroupId.." and skill_id "..skillId)
                self._playInfo = playInfo

                -- 移动前先隐藏血条和怒气条
                -- 关闭呼吸动作
                entrySet:addOnceEntryToQueue(nil, function()
                    attacker:setHPVisible(false)
                    attacker:setNameVisible(false)
                    attacker:setAwakenStarVisible(false)
                    attacker:setAngerVisible(false)
                    if attacker.setBreathAniEnabled then attacker:setBreathAniEnabled(false) end
                    return true
                end, nil, attacker)

                -- 检查是否移动
                local startLocationType = playInfo.start_location_type
                local movePosition = nil
                -- 3表示移动到目标位置+偏移量
                if startLocationType == 3 then

                    local dstOffsetPosition = ccp(playInfo.x, playInfo.y)
                    if attacks.identity == 2 then dstOffsetPosition = ccpMult(dstOffsetPosition, -1) end

                    for i=1, #attacks.skill_victims do
                        local skillVictim = attacks.skill_victims[i]
                        if attacks.identity ~= skillVictim.identity then
                            local victim = knights[skillVictim.identity][tostring(skillVictim.position+1)]
                            movePosition = ccpAdd(ccp(victim:getPosition()), dstOffsetPosition)
                            movePosition = ccpSub(movePosition, ccp(attacker:getPosition()))
                            break
                        end
                    end

                -- 2表示移动到屏幕中间+偏移量
                elseif startLocationType == 2 then
                    
                    local dstOffsetPosition = ccp(playInfo.x, playInfo.y)
                    if attacks.identity == 2 then dstOffsetPosition = ccpMult(dstOffsetPosition, -1) end

                    movePosition = ccpAdd(ccp(display.cx, display.cy), dstOffsetPosition)
                    movePosition = ccpSub(movePosition, ccp(attacker:getPosition()))
                
                -- 我方2号位位置
                elseif startLocationType == 9 then
                    
                    local dstOffsetPosition = ccp(playInfo.x, playInfo.y)
                    local getPosition = require("app.scenes.battle.Location").getEnemyPositionByIndex
                    if attacks.identity == 2 then
                        dstOffsetPosition = ccpMult(dstOffsetPosition, -1)
                        getPosition = require("app.scenes.battle.Location").getSelfPositionByIndex
                    end
                    
                    local position = getPosition(2)
                    position = ccp(position[1], position[2])
                    movePosition = ccpAdd(position, dstOffsetPosition)
                    movePosition = ccpSub(movePosition, ccp(attacker:getPosition()))
                
                -- 敌方2号位位置
                elseif startLocationType == 10 then
                    
                    local dstOffsetPosition = ccp(playInfo.x, playInfo.y)
                    local getPosition = require("app.scenes.battle.Location").getSelfPositionByIndex
                    if attacks.identity == 2 then 
                        dstOffsetPosition = ccpMult(dstOffsetPosition, -1)
                        getPosition = require("app.scenes.battle.Location").getEnemyPositionByIndex
                    end
                    
                    local position = getPosition(2)
                    position = ccp(position[1], position[2])
                    movePosition = ccpAdd(position, dstOffsetPosition)
                    movePosition = ccpSub(movePosition, ccp(attacker:getPosition()))
                    
                elseif startLocationType ~= 1 then
                    -- 查找当前符合条件的位置
                    local position = nil
                    for i=1, #attacks.skill_victims do
                        if attacks.skill_victims[i].identity ~= attacks.identity then
                            if not position or position > attacks.skill_victims[i].position+1 then
                                position = attacks.skill_victims[i].position+1
                            end
                        end
                    end
                    assert(position, "There is not valid position with skill_id: "..attacks.skill_id)
                    
                    if position then
                        if startLocationType == 4 or startLocationType == 5 or startLocationType == 6 then
                            position = position <= 3 and startLocationType - 3 or startLocationType
                        elseif startLocationType == 7 then
                            position = position <= 3 and position or (position == 6 and 3 or position % 3)
                        elseif startLocationType == 8 then
                            position = position+3 > 6 and position or position+3
                        else
                            assert(false, "Unknown startLocationType: "..startLocationType)
                        end

                        assert(position >= 1 and position <= 6, "The startLocationType("..startLocationType..") position("..position..") is invalid !")

                        local dstOffsetPosition = ccp(playInfo.x, playInfo.y)
                        if attacks.identity == 2 then dstOffsetPosition = ccpMult(dstOffsetPosition, -1) end

                        local Location = require "app.scenes.battle.Location"
                        local getPosition = attacks.identity == 1 and Location.getEnemyPositionByIndex or Location.getSelfPositionByIndex

                        local positionInPoint = getPosition(position)
                        positionInPoint = ccp(positionInPoint[1], positionInPoint[2])

                        for i=1, #attacks.skill_victims do
                            if attacks.identity ~= attacks.skill_victims[i].identity then
                                movePosition = ccpAdd(positionInPoint, dstOffsetPosition)
                                movePosition = ccpSub(movePosition, ccp(attacker:getPosition()))
                                break
                            end
                        end
                    end
                end

                -- 添加移动entry
                if movePosition then
                    local MoveEntry = require "app.scenes.battle.entry.MoveEntry"
                    local moveEntry = MoveEntry.new(movePosition, attacker)
                    entrySet:addEntryToQueue(moveEntry, moveEntry.updateEntry, nil, attacker)
                end

                -- 攻击action, 这里只处理主要攻击者的action event
                local ActionEntry = require "app.scenes.battle.entry.ActionEntry"
                local eventHandler = nil
                if key == "release_knight" then
                    eventHandler = handler(self, self.onAttackerEvent)
                end

                local attack_action_id = "battle/action/"..playInfo.attack_action_id..".json"
                if attacks.identity == 2 then
                    local fileUtils = CCFileUtils:sharedFileUtils()
                    if fileUtils:isFileExist(fileUtils:fullPathForFilename("battle/action/"..playInfo.attack_action_id.."_r.json")) then
                        attack_action_id = "battle/action/"..playInfo.attack_action_id.."_r.json"
                    end
                end
                
                local attackEntry = ActionEntry.new(attack_action_id, attacker, battleField, eventHandler)
                attackEntry:addEntryToNewQueue(nil, function()
                    local attackSound = skill_info.get(skillId).start_sound ~= "0" and skill_info.get(skillId).start_sound or nil
                    if attackSound then
                        SoundManager:playSound(attackSound)
                    end
                    return true
                end)
                entrySet:addEntryToQueue(attackEntry, attackEntry.updateEntry, nil, attacker)

                -- 移动回来
                if movePosition then
                    -- 位置是相对值，所以直接反转
                    movePosition = ccpMult(movePosition, -1)

                    local MoveEntry = require "app.scenes.battle.entry.MoveEntry"
                    local moveEntry = MoveEntry.new(movePosition, attacker)
                    entrySet:addEntryToQueue(moveEntry, moveEntry.updateEntry, nil, attacker)
                end

                -- 是否有吸血？
                -- 计算一下吸收血量的总和
                local _suckHpSum = 0
                for i = 1, #attacks.skill_victims do
                    local skillVictim = attacks.skill_victims[i]
                    if skillVictim.identity ~= attacks.identity then
                        local suckHP = rawget(skillVictim, "life_drain") or 0
                        _suckHpSum = _suckHpSum + suckHP
                    end
                end

                -- 如果有吸血，回来后跳出吸血量
                if _suckHpSum > 0 then
                    local changeHp = _suckHpSum
                    local recipient = self._attackers.release_knight
                    self:addOnceEntryToQueue(nil, function()
                        -- 冒吸血数字
                        local DamageEntry = require "app.scenes.battle.entry.DamageEntry"
                        local tween = DamageEntry.create(changeHp, recipient, battleField)
                        battleField:addEntryToSynchQueue(tween, tween.updateEntry)

                        local DamageDescEntry = require "app.scenes.battle.entry.DamageDescEntry"
                        local descTween = DamageDescEntry.create(changeHp, recipient, battleField, false, false, false, false, false, true)
                        battleField:addEntryToSynchQueue(descTween, descTween.updateEntry)

                        return true
                    end, nil, recipient)
                end

                -- 恢复order
                -- 恢复呼吸动画
                -- 恢复血条显示
                -- 恢复怒气显示
                -- ...
                entrySet:addOnceEntryToQueue(nil, function()
                    attacker:getParent():reorderChild(attacker, self._oldOrder[attacker])
                    if attacker.setBreathAniEnabled then attacker:setBreathAniEnabled(true) end
                    attacker:setHPVisible(true)
                    attacker:setNameVisible(true)
                    attacker:setAwakenStarVisible(true)
                    attacker:setAngerVisible(true)
                    return true
                end, nil, attacker)

            end
            
        end
                
        -- 如果有镜头拉动则拉回来
        if self._focusOn then
            local reversed = false
            self:addEntryToQueue(nil, function()
                if not reversed then
                    reversed = true
                    self._focusOn = self._focusOn:reverse()
                end
                if not self._focusOn:isRunning() then
                    self._focusOn:startWithTarget(battleField)
                end
                if not self._focusOn:isDone() then
                    self._focusOn:step(1)
                end
                if self._focusOn:isDone() then
                    self._focusOn = nil
                    return true
                end
                return false
            end, nil, attackers.release_knight)
        end
        
        -- 如果是合击则去掉黑底，恢复卡牌的层级
        self:addOnceEntryToQueue(nil, function()
            
            if self._comboSkillBg then
                
                self._comboSkillBg:removeFromParent()
                self._comboSkillBg = nil
                
                -- 移动攻击者
                for k, attacker in pairs(attackers) do
                    attacker:retain()
                    local order = attacker:getZOrder()
                    attacker:removeFromParent()
                    battleField:addToCardNode(attacker, order)
                    attacker:release()
                end
                
                -- 受害者
                for i=1, #attacks.skill_victims do
                    local skillVictim = attacks.skill_victims[i]
                    local victim = knights[skillVictim.identity][tostring(skillVictim.position+1)]
                    if victim then
                        victim:retain()
                        local order = victim:getZOrder()
                        victim:removeFromParent()
                        battleField:addToCardNode(victim, order)
                        victim:release()
                    end
                end
                
                self._comboCardNode:removeFromParent()
                self._comboCardNode = nil
                
            end
            
            return true
            
        end, nil, attackers.release_knight)
        
        -- 给攻击方加血/buff/怒气
        local ActionEntry = require "app.scenes.battle.entry.ActionEntry"
        local Entry = require "app.scenes.battle.entry.Entry"
        local entrySet = Entry.new()

        local eventHandler = handler(self, self.onDefenderEvent)

        for i=1, #attacks.skill_victims do
            local skillVictim = attacks.skill_victims[i]
            if skillVictim.identity == attacks.identity then
                
                local defend_action_id = self._playInfo.us_defend_action_id ~= "0" and self._playInfo.us_defend_action_id or nil
                if not defend_action_id then defend_action_id = self._playInfo.defend_action_id end
                assert(defend_action_id, "The playInfo.defend_action_id could not be nil !")

                local changeHp = rawget(skillVictim, "change_hp")

                if changeHp then
                    local victim = knights[skillVictim.identity][tostring(skillVictim.position+1)]    
                    local action = ActionEntry.new("battle/action/"..defend_action_id..".json", victim, battleField, eventHandler)
                    eventHandler = nil
                    entrySet:addEntryToQueue(action, action.updateEntry, nil, victim)
                end
            end
        end
        
        -- 我方受反弹技能伤害？
        -- 先统计一下所有反弹伤害值（总和）
        local _hitBackDamage = 0
        for i=1, #attacks.skill_victims do
            local skillVictim = attacks.skill_victims[i]
            if skillVictim.identity ~= attacks.identity then
                local hitback = rawget(skillVictim, "hitback")
                if hitback and hitback > 0 then
                    _hitBackDamage = _hitBackDamage + hitback
                end
            end
        end
        
        -- 然后播放反弹伤害
        if _hitBackDamage > 0 then
            local changeHp = _hitBackDamage * -1
            local victim = self._attackers.release_knight
            self:addOnceEntryToQueue(nil, function()
                -- 反弹冒血
                local DamageEntry = require "app.scenes.battle.entry.DamageEntry"
                local tween = DamageEntry.create(changeHp, victim, battleField)
                battleField:addEntryToSynchQueue(tween, tween.updateEntry)

                local DamageDescEntry = require "app.scenes.battle.entry.DamageDescEntry"
                local descTween = DamageDescEntry.create(changeHp, victim, battleField, false, false, false, false, true)
                battleField:addEntryToSynchQueue(descTween, descTween.updateEntry)
                return true
            end, nil, victim) 
        end
        
        -- 被反弹伤害挂了？这里death_hitback为true表示挂了
        local death_hitback = rawget(attacks, "death_hitback")
        if death_hitback then
            self:addOnceEntryToQueue(self, self.updateDead, nil, attackers.release_knight)
            return
        end
        
        -- 添加buff
        for i=1, #attacks.buff_victims do
            local victim = attacks.buff_victims[i]
            if victim.identity == attacks.identity then
                local knight = knights[victim.identity][tostring(victim.position+1)]
                entrySet:addOnceEntryToQueue(nil, function()
                    knight:addBuff(victim)
                    return true
                end, nil, knight)
            end
        end
        
        -- 清理的buff
        for i=1, #attacks.cbuff_victims do
            local victim = attacks.cbuff_victims[i]
            if victim.identity == attacks.identity then
                local knight = knights[victim.identity][tostring(victim.position+1)]
                entrySet:addOnceEntryToQueue(nil, function()
                    
                    local bMatch = false
                    
                    for j=1, #victim.clear_buff do
                        local buff_id = knight:getBuff(victim.clear_buff[j]).buff_id
                        local buffInfo = buff_info.get(buff_id)
                        assert(buffInfo, "Could not find the buff info with id: "..tostring(buff_id))
                        -- 2表示减益buff，因为这里针对的是我方的那肯定是减益buff
                        bMatch = bMatch or buffInfo.buff_stype == 2
                        -- 最后才删除buff
                        knight:delBuff(victim.clear_buff[j])
                    end
                    
                    if bMatch then
                        -- 有buff要显示消除
                        local BuffDescEntry = require "app.scenes.battle.entry.BuffDescEntry"
                        local target = knights[victim.identity][tostring(victim.position+1)]
                        local buffDescEntry = BuffDescEntry.new(nil, nil, target, battleField, nil, nil, true)
                        battleField:addEntryToSynchQueue(buffDescEntry, buffDescEntry.updateEntry)
                    end
                    
                    return true
                end, nil, knight)
            end
        end
        
        -- 怒气值变化
        for i=1, #attacks.anger_victims do
            local victim = attacks.anger_victims[i]
            local anger = rawget(victim, 'anger')
            if anger and anger > 0 and victim.identity == attacks.identity then
                
                local knight = knights[victim.identity][tostring(victim.position+1)]
                anger = (attacks.identity == victim.identity) and anger or anger * -1
                
                entrySet:addOnceEntryToQueue(nil, function()
                    battleField:addEntryToSynchQueue(nil, function(_, frameIndex)
                        if victim.position ~= attacks.position then
                            knight:addAnger(anger)
                        end

                        -- 怒气变化动画
                        local AngerChangeEntry = require "app.scenes.battle.entry.AngerChangeEntry"
                        local angerChangeEntry = AngerChangeEntry.create(anger, knight, battleField)
                        battleField:addEntryToSynchQueue(angerChangeEntry, angerChangeEntry.updateEntry)

                        return true
                    end)
                    return true
                end, nil, knight)
            end
        end
        
        self:addEntryToQueue(entrySet, entrySet.updateEntry, nil, attackers.release_knight)
    
    -- 如果没有技能，这里怒气可能会变化所以需要处理
    else
        
        if rawget(attacks, "anger") then
            self._attackers.release_knight:resetAnger(attacks.anger)
        end
        
    end
    
    -- state_buffs
    if attacks.state_buffs and #attacks.state_buffs > 0 then
        -- 插入buff处理函数
        self:addOnceEntryToQueue(self, self.updateBuff, nil, attackers.release_knight, attacks.state_buffs)
    end
    
end

function AttackEntry:updateDead()
    
    local attacks = self._data
    local battleField = self._battleField
    
    -- 插入死亡处理函数
    local ActionEntry = require "app.scenes.battle.entry.ActionEntry"
    local target = self._attackers.release_knight
    -- 关闭血条，呼吸动作，以及buff
    target:setHPVisible(false)
    target:setNameVisible(false)
    target:setAwakenStarVisible(false)
    if target.setBreathAniEnabled then target:setBreathAniEnabled(false) end
    target:setAngerVisible(false)
    target:delAllBuffs()
    target:setIsDead()
    
    if target.isBoss then
        local check = nil
        self:addEntryToQueue(nil, function(_, frameIndex)
            if not check then check = target:playDead() end
            return check(frameIndex)
        end, nil, target)
    else
        local deadEntry = ActionEntry.new(BattleFieldConst.action.CHAR_DIE, target, battleField)
        -- 死亡音效
        deadEntry:addEntryToNewQueue(nil, function()
            local deadSound = target:getCardConfig().dead_sound ~= "0" and target:getCardConfig().dead_sound or nil
            if deadSound then
                SoundManager:playSound(deadSound)
            end
            SoundManager:playSound(require("app.const.SoundConst").BattleSound.BATTLE_DEAD)
            return true
        end)

        self:addEntryToQueue(deadEntry, deadEntry.updateEntry, nil, target)
    end
    
    -- 掉落动画
    -- 先判断类型
    local awardType = nil
    attacks.awards = attacks.awards or {}
    
    for i=1, #attacks.awards do
        local award = attacks.awards[i]
        local Goods = G_Goods
        if award.type == Goods.TYPE_MONEY or award.type == Goods.TYPE_GOLD or award.type == Goods.TYPE_ITEM or award.type == Goods.TYPE_WUHUN or award.type == Goods.TYPE_AWAKEN_ITEM or award.type == Goods.TYPE_SHENHUN then -- 道具
            awardType = 3
        elseif award.type == Goods.TYPE_FRAGMENT then       -- 卡牌/装备碎片
            local goods = fragment_info.get(award.value)
            if goods.fragment_type == 1 then
                awardType = 2
            elseif goods.fragment_type == 2 then
                awardType = 1
            else
                assert(false, "Unknown award type: "..award.type.." fragment type: "..goods.fragment_type)
            end
        elseif award.type == Goods.TYPE_KNIGHT then     -- 卡牌/卡牌碎片
            awardType = 2
        elseif award.type == Goods.TYPE_EQUIPMENT then     -- 卡牌/卡牌碎片
            awardType = 1
        elseif award.type == Goods.TYPE_TREASURE then -- 宝物
            awardType = 3
        else
            assert(false, "Unknown award type: "..award.type)
        end
        break
    end
    
    if awardType then
        
        -- 由于竞技场中可能出现莫名其妙的掉落情况，所以这里做下屏蔽，最好能够发个网络消息记录一下
        local boxNode = nil
        if awardType == 3 then boxNode = battleField:getItemBox()
        elseif awardType == 2 then boxNode = battleField:getKnightBox()
        elseif awardType == 1 then boxNode = battleField:getEquipBox()
        end
        
        if boxNode then
        
            -- 掉落动画
            self._awardEntry = self._awardEntry or {}

            local AwardEntry = require "app.scenes.battle.entry.AwardEntry"
            self._awardEntry[target] = AwardEntry.create(awardType, target, battleField)
            self._awardEntry[target]:addEntryToNewQueue(nil, function()
                SoundManager:playSound(require("app.const.SoundConst").BattleSound.BATTLE_BOX)
                return true
            end)
            self:addEntryToQueue(self._awardEntry[target], self._awardEntry[target].updateEntry, nil, target)
            -- 这里调用的动画需要保存起来，因为所创建的对象后面还要使用
            self._awardEntry[target]:retainEntry()

            local displayNode = nil
            local start = nil
            local distance = nil
            local scaleFactor = nil

            -- 掉落之后的移动
            self:addEntryToQueue(nil, function(_, frameIndex)

                if not displayNode then
                    displayNode = self._awardEntry[target]:getObject()
                    scaleFactor = boxNode:getScale()

                    start = displayNode:convertToWorldSpaceAR(ccp(0, 0))
                    local boxPosition = boxNode:convertToWorldSpace(ccp(boxNode:getContentSize().width/2, boxNode:getContentSize().height/2))
                    distance = ccpSub(boxPosition, start)
                end

--                displayNode:setPosition(displayNode:getParent():convertToNodeSpace(ccpAdd(start, ccpMult(distance, frameIndex / 8))))
                displayNode:setPositionXY(displayNode:getParent():convertToNodeSpaceXY(start.x + distance.x * frameIndex/8, start.y + distance.y * frameIndex/8))
                displayNode:setScale((scaleFactor - 1) * frameIndex / 8 + 1)

                if frameIndex == 8 then
                    self._awardEntry[target]:releaseEntry()
                    self._awardEntry[target] = nil

                    local awardCountNode = nil
                    if awardType == 3 then awardCountNode = battleField:getItemBoxCount()
                    elseif awardType == 2 then awardCountNode = battleField:getKnightBoxCount()
                    elseif awardType == 1 then awardCountNode = battleField:getEquipBoxCount()
                    end
                    
                    awardCountNode:setString(tostring(tonumber(awardCountNode:getString()) + 1))
                    awardCountNode:setScale(1 / scaleFactor)
                    awardCountNode:stopActionByTag(100)

                    local array = CCArray:create()
                    array:addObject(CCScaleBy:create(0.2, 2))
                    array:addObject(CCDelayTime:create(0.1))
                    array:addObject(CCScaleBy:create(0.2, 0.5))

                    local action = CCSequence:create(array)
                    action:setTag(100)
                    awardCountNode:runAction(action)
                    
                    return true
                end

                return false

            end, nil, target)
        end
    end
    
    self:addOnceEntryToQueue(battleField, battleField._removeKnight, nil, target, target)
    
    return true
    
end

function AttackEntry:updateBuff(_, buffs)

    local battleField = self._battleField
        
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    
    for i=1, #buffs do
        local attacker = self._attackers.release_knight
--        local changeHp = math.ceil(buffs[i].result - attacker:getHPAmount())

        local buff_id = attacker:getBuff(buffs[i].id).buff_id
        require "app.cfg.buff_info"
        local buffConfig = buff_info.get(buff_id)
        assert(buffConfig, "Unknown buff id: "..buff_id)

        -- 1是扣血，2是加血
        local changeHp = 0
        if buffConfig.buff_affect_type == 1 then
            changeHp = buffs[i].result * -1
        elseif buffConfig.buff_affect_type == 2 then
            changeHp = buffs[i].result
        end
        
        if changeHp ~= 0 then
            local BuffDamageEntry = require "app.scenes.battle.entry.BuffDamageEntry"
            local tween = BuffDamageEntry.create(buffConfig, changeHp, attacker, battleField)
            battleField:addEntryToSynchQueue(tween, tween.updateEntry)
        end
        
        if buffs[i].count == 0 then
            attacker:delBuff(buffs[i].id)
        end
    end
    
    return true
end

function AttackEntry:updateOrder(frameIndex, attacker)
    attacker:getParent():reorderChild(attacker, self._oldOrder[attacker])
    return true
end

-- 攻击者事件接受
-- 所有攻击者的事件如不意外都会抛到这里

function AttackEntry:onAttackerEvent(event, target, frameIndex)
       
    local attacks = self._data
    local knights = self._objects
    local playInfo = self._playInfo
    local battleField = self._battleField
    
    -- 事件如果为空？？则直接返回
    if not event then return end
    
    -- 统计攻击顺序使用，主要针对action中存在的hit_1, hit_2 ...
    local function _calcHitAndHurtCount(strings, base, offset, sequence)
        
        -- 如果没有受击序列则直接返回空表
        if sequence == "0" then return {} end
        
        -- sequence表示表里预定义的打击顺序，以"_"表示不同分组
	-- 首先切割sequence成二维数组
	local _seq = {container = {}}
	local _seqIndex = 1

	for i=1, string.len(sequence) do
            local ch = string.sub(sequence, i, i)
            if ch == "_" then
                _seq.container[#_seq.container+1] = {}
                _seqIndex = _seqIndex + 1
            end
            _seq.container[_seqIndex] = _seq.container[_seqIndex] or {}
            _seq.container[_seqIndex][#_seq.container[_seqIndex]+1] = tonumber(ch)
	end

	-- 根据所传位置返回所在数组
	_seq.contain = function(position)
            for i=1, #_seq.container do
                for j=1, #_seq.container[i] do
                    if _seq.container[i][j] == position then
                        return clone(_seq.container[i])
                    end
                end
            end
	end

	local counts = {}
        
	for k, str in pairs(strings) do
            -- 要过滤掉不符合条件的其他事件
            if string.match(str, base) then
                -- 取出每个事件(hit_x, hurt_x)所带的索引编号
                local strIndex = tonumber(string.sub(str, offset))

                local victimIndex = 1
                repeat
                    local victim = attacks.skill_victims[victimIndex]
                    if not victim then
                        break
                    end
                    if victim.identity ~= attacks.identity then
                        -- 我们认为服务器发来的受害者名单一定和某一组数据完全一致，所以一定在分组里
                        local positions = _seq.contain(victim.position+1) -- 服务器发来的position是从0开始算，我们是从1开始算
                        assert(positions, "There is not target with position("..(victim.position+1)..") and identity("..victim.identity..") in the playInfo.defend_list: "..sequence)

                        -- 找到所在分组后查看当前打击的序列是否在分组当中
                        assert(positions[strIndex], "Invalid event: "..string.format(base, strIndex).." with playInfo.defend_list: "..sequence)

                        counts[positions[strIndex]] = counts[positions[strIndex]] or 0
                        counts[positions[strIndex]] = counts[positions[strIndex]] + 1

                        victimIndex = victimIndex + 1
                        break
                    else
                        victimIndex = victimIndex + 1
                    end

                until not attacks.skill_victims[victimIndex]
            end
	end

	return counts
    end
    
    -- 开始分支事件，主要有hit(hit_1, hit_2, ...)受击 hurt(hurt_1, hurt_2, ...)受伤 shoot射击, bullet_hurt射击受伤, finish动作结束等
    if string.match(event, "hit") then
        
        local victims = {}
        local positions = not (self._attackers and self._attackers.release_knight.isBoss) and _calcHitAndHurtCount({event}, "hit_%d", 5, playInfo.defend_list) or {}
        if table.nums(positions) ~= 0 then
            for i=1, #attacks.skill_victims do
                local skillVictim = attacks.skill_victims[i]
                if positions[skillVictim.position+1] and skillVictim.identity ~= attacks.identity then
                    victims = {skillVictim}
                    break
                end
            end
        else
            for i=1, #attacks.skill_victims do
                local skillVictim = attacks.skill_victims[i]
                if skillVictim.identity ~= attacks.identity then
                    victims[#victims+1] = skillVictim
                end
            end
        end
        
        -- 震屏
        if self._isSuperSkill then
            local bMatch = false
            for i=1, #attacks.skill_victims do
                local skillVictim = attacks.skill_victims[i]
                if skillVictim.identity ~= attacks.identity then
                    -- 技能如果有施加在敌方的就震屏（包括供给敌方后给我方加血），否则（只给攻击方加血）就不震
                    bMatch = true
                end
            end
            if bMatch then
                if not self._shakeEntry then
                    self._shakeEntry = require("app.scenes.battle.entry.ShakeEntry").new(10, 0, 15, battleField)
                    battleField:addEntryToQueue(self._shakeEntry, self._shakeEntry.updateEntry, nil, "shake")
                    self._shakeEntry:retainEntry()
                else
                    if self._shakeEntry:isDone() then
                        battleField:addEntryToQueue(self._shakeEntry, self._shakeEntry.updateEntry, nil, "shake")
                    end
                    self._shakeEntry:initEntry()
                end
            end
        end

        local ActionEntry = require "app.scenes.battle.entry.ActionEntry"

        -- 受击动画
        for i=1, #victims do
            local skillVictim = victims[i]

            local victim = knights[skillVictim.identity][tostring(skillVictim.position+1)]
            if victim.setBreathAniEnabled then victim:setBreathAniEnabled(false) end
            
            if victim.isBoss then
                local check = victim:playHit()
                self:addEntryToQueue(nil, function(_, frameIndex)
                    return check(frameIndex)
                end, nil, victim)
            else
                
                if self._attackers and self._attackers.release_knight.isBoss then
                    
                    -- 受击action, 因为在一个受击action打击过程中如果又有一个打击，则需要重新开始受击动作
                    self._hitAction = self._hitAction or {}

                    if not self._hitAction[victim] then

                        local defend_action_id = "battle/action/action_3.json"

                        local hitEntry = ActionEntry.new(defend_action_id, victim, battleField)
                        hitEntry:addEntryToNewQueue(nil, function()
                            local hitSound = skill_info.get(attacks.skill_id).hit_sound ~= "0" and skill_info.get(attacks.skill_id).hit_sound or nil
                            if hitSound then
                                SoundManager:playSound(hitSound)
                            end
                            return true
                        end)
                        self:addEntryToQueue(hitEntry, hitEntry.updateEntry, nil, victim)

                        hitEntry:retainEntry()
                        self._hitAction[victim] = hitEntry
                    else
                        if self._hitAction[victim]:isDone() then
                            self:addEntryToQueue(self._hitAction[victim], self._hitAction[victim].updateEntry, nil, victim)
                        end
                        self._hitAction[victim]:initEntry()
                    end
                    
                else
                    if skillVictim.identity ~= attacks.identity then
                        -- 受击action, 因为在一个受击action打击过程中如果又有一个打击，则需要重新开始受击动作
                        self._hitAction = self._hitAction or {}

                        if not self._hitAction[victim] then

                            assert(playInfo.defend_action_id, "The playInfo.defend_action_id could not be nil !")

                            local defend_action_id = "battle/action/"..playInfo.defend_action_id..".json"
                            if skillVictim.identity == 1 then
                                local fileUtils = CCFileUtils:sharedFileUtils()
                                if fileUtils:isFileExist(fileUtils:fullPathForFilename("battle/action/"..playInfo.defend_action_id.."_r.json")) then
                                    defend_action_id = "battle/action/"..playInfo.defend_action_id.."_r.json"
                                end
                            end

                            local hitEntry = ActionEntry.new(defend_action_id, victim, battleField, nil, skillVictim.is_dodge)
                            hitEntry:addEntryToNewQueue(nil, function()
                                local hitSound = skill_info.get(attacks.skill_id).hit_sound ~= "0" and skill_info.get(attacks.skill_id).hit_sound or nil
                                if hitSound then
                                    SoundManager:playSound(hitSound)
                                end
                                return true
                            end)
                            
                            if skillVictim.is_dodge then
                                local dodge_action_id = BattleFieldConst.action.DODGE
                                if skillVictim.identity == 1 then
                                    local fileUtils = CCFileUtils:sharedFileUtils()
                                    if fileUtils:isFileExist(fileUtils:fullPathForFilename(BattleFieldConst.action.DODGE_R)) then
                                        dodge_action_id = BattleFieldConst.action.DODGE_R
                                    end
                                end

                                -- 闪避action，直接放到受击action里播
                                local dodgeEntry = ActionEntry.new(dodge_action_id, victim, battleField)
                                hitEntry:addEntryToNewQueue(dodgeEntry, dodgeEntry.updateEntry)
                            end
                            
                            self:addEntryToQueue(hitEntry, hitEntry.updateEntry, nil, victim)

                            hitEntry:retainEntry()
                            self._hitAction[victim] = hitEntry
                        else
                            if self._hitAction[victim]:isDone() then
                                self:addEntryToQueue(self._hitAction[victim], self._hitAction[victim].updateEntry, nil, victim)
                            end
                            self._hitAction[victim]:initEntry()
                        end
                    end
                end
            end
            
        end
        
    elseif event == "bullet_hurt" then
        
        local victim = target:getVictim()
        local changeHp = target:getChangeHp()
        local isCritical = target:getIsCritical()
        local isDodge = target:getIsDodge()
        local isDouble = target:getIsDouble()
        local isPierce = target:getIsPierce()
        
        self._combo = self._combo or 0
        self._combo = self._combo + 1
        
        -- 连击数显示
        if self._combo >= 2 then
            if not self._comboEntry then
                local ComboEntry = require "app.scenes.battle.entry.ComboEntry"
                self._comboEntry = ComboEntry.create(self._combo, nil, battleField)
                self:addEntryToNewQueue(self._comboEntry, self._comboEntry.updateEntry)
                self._comboEntry:retainEntry()
            else
                self._comboEntry:addCombo(1)
                if self._comboEntry:isDone() then
                    self:addEntryToNewQueue(self._comboEntry, self._comboEntry.updateEntry)
                end
                self._comboEntry:initEntry()
            end
        end
          
        assert(self._shoots and self._shoots[victim], "Shoots could not be nil !")
        
        if victim.isBoss then
            local check = victim:playHit()
            self._shootEntrySet[victim]:addEntryToQueue(nil, function(_, frameIndex)
                return check(frameIndex)
            end, nil, victim)
        else
            self._hitAction = self._hitAction or {}
            if not self._hitAction[victim] then

                assert(playInfo.defend_action_id, "The playInfo.defend_action_id could not be nil !")

                local defend_action_id = "battle/action/"..playInfo.defend_action_id..".json"
                if victim:getIdentity() == 1 then
                    local fileUtils = CCFileUtils:sharedFileUtils()
                    if fileUtils:isFileExist(fileUtils:fullPathForFilename("battle/action/"..playInfo.defend_action_id.."_r.json")) then
                        defend_action_id = "battle/action/"..playInfo.defend_action_id.."_r.json"
                    end
                end

                -- 受击动画
                local ActionEntry = require "app.scenes.battle.entry.ActionEntry"
                local hitEntry = ActionEntry.new(defend_action_id, victim, battleField, nil, isDodge)
                hitEntry:addEntryToNewQueue(nil, function()
                    local hitSound = skill_info.get(attacks.skill_id).hit_sound ~= "0" and skill_info.get(attacks.skill_id).hit_sound or nil
                    if hitSound then
                        SoundManager:playSound(hitSound)
                    end
                    return true
                end)
                
                if isDodge then
                    local dodge_action_id = BattleFieldConst.action.DODGE
                    if victim:getIdentity() == 1 then
                        local fileUtils = CCFileUtils:sharedFileUtils()
                        if fileUtils:isFileExist(fileUtils:fullPathForFilename(BattleFieldConst.action.DODGE_R)) then
                            dodge_action_id = BattleFieldConst.action.DODGE_R
                        end
                    end
                    
                    -- 闪避action，直接放到受击action里播
                    local dodgeEntry = ActionEntry.new(dodge_action_id, victim, battleField)
                    hitEntry:addEntryToNewQueue(dodgeEntry, dodgeEntry.updateEntry)
                end

                self._shootEntrySet[victim]:addEntryToQueue(hitEntry, hitEntry.updateEntry, nil, victim)
                if self._shoots[victim] > 1 then
                    hitEntry:retainEntry()
                end
                self._hitAction[victim] = hitEntry
            else
                if self._hitAction[victim]:isDone() then
                    self._shootEntrySet[victim]:addEntryToQueue(self._hitAction[victim], self._hitAction[victim].updateEntry, nil, victim)
                end
                self._hitAction[victim]:initEntry()

                if self._shoots[victim] == 1 then
                    self._hitAction[victim]:releaseEntry()
                end
            end

            -- 扣除一个shoot
            self._shoots[victim] = self._shoots[victim] - 1
            if self._shoots[victim] == 0 then self._shoots[victim] = nil end

        end
        
        -- 冒血
        local DamageEntry = require "app.scenes.battle.entry.DamageEntry"
        local tween = DamageEntry.create(changeHp, victim, battleField, isCritical, isDodge)
        battleField:addEntryToSynchQueue(tween, tween.updateEntry)

        if isCritical or isDouble or isPierce then
            local DamageDescEntry = require "app.scenes.battle.entry.DamageDescEntry"
            local criticalTween = DamageDescEntry.create(changeHp, victim, battleField, isCritical, isDouble, isPierce)
            battleField:addEntryToSynchQueue(criticalTween, criticalTween.updateEntry)
        end
        
    elseif string.match(event, "hurt") then

        local victims = {}
        local positions = not (self._attackers and self._attackers.release_knight.isBoss) and _calcHitAndHurtCount({event}, "hurt_%d", 6, playInfo.defend_list) or {}
        if table.nums(positions) ~= 0 then
            for i=1, #attacks.skill_victims do
                local skillVictim = attacks.skill_victims[i]
                if positions[skillVictim.position+1] and skillVictim.identity ~= attacks.identity then
                    victims = {skillVictim}
                    break
                end
            end
        else
            for i=1, #attacks.skill_victims do
                local skillVictim = attacks.skill_victims[i]

                -- 对于宠物技能，无论攻击还是加血都是在attack期间的"hurt"事件处理
                -- 对于武将，按原先这里的逻辑，加血都是在技能完毕之后
                if self._isPetAttack or skillVictim.identity ~= attacks.identity then
                    victims[#victims+1] = skillVictim
                end
            end
        end

        -- 连击数
        if #victims > 0 then
            self._combo = self._combo or 0
            self._combo = self._combo + 1

            -- 连击数显示
            if self._combo * #victims >= 2 then
                if not self._comboEntry then
                    local ComboEntry = require "app.scenes.battle.entry.ComboEntry"
                    self._comboEntry = ComboEntry.create(self._combo * #victims, nil, battleField)
                    self:addEntryToNewQueue(self._comboEntry, self._comboEntry.updateEntry)
                    self._comboEntry:retainEntry()
                else
                    self._comboEntry:addCombo(1 * #victims)
                    self._comboEntry:initEntry()
                    if self._comboEntry:isDone() then
                        self:addEntryToNewQueue(self._comboEntry, self._comboEntry.updateEntry)
                    end
                end
            end
        end
        
        -- 统计一下有几次hurts
        positions = not (self._attackers and self._attackers.release_knight.isBoss) and _calcHitAndHurtCount(target:getData().events, "hurt_%d", 6, playInfo.defend_list) or {}
        
        -- 冒血
        for i=1, #victims do
            
            -- 统计hurt次数
            local skillVictim = victims[i]
            local hurts = positions[victims[i].position+1]
            if not hurts then
                hurts = 0
                local events = target:getData().events
                if self._attackers and self._attackers.release_knight.isBoss then
                    
                    -- boss的events因为是分段的，所以我们也要在某个技能分段里找，这里简单处理，根据帧数分别向上和向下搜索, 直到找到不是hit或者hurt的事件
                    local function _findHurts(orientation)
                        local _hurts = 0
                        local _frame = frameIndex + orientation
                        local _curEvent = events[string.gsub("f0", "%d", _frame)]
                        -- 这里_curEvent可能是空的，理论上不存在的值都是空的，可能会死循环，但是按照设计hurt肯定是在某个攻击字段内，比如attack--attack_stop,否则就会是设计问题
                        while not _curEvent or _curEvent == "hit" or _curEvent == "hurt" do
                            if _curEvent == "hurt" then
                                _hurts = _hurts + 1
                            end
                            _frame = _frame + orientation
                            _curEvent = events[string.gsub("f0", "%d", _frame)]
                        end
                        return _hurts
                    end
                    -- 向上搜索
                    hurts = hurts + _findHurts(-1)
                    -- 然后向下
                    hurts = hurts + _findHurts(1)
                    -- 最后是自己本身
                    hurts = hurts + 1
                    
                else
                    for k, e in pairs(events) do
                        if e == "hurt" then hurts = hurts + 1 end
                    end
                end
            end

            local victim = knights[skillVictim.identity][tostring(skillVictim.position+1)]

            -- 如果有扣血的话
            local changeHp = rawget(skillVictim, "change_hp")
            if changeHp then

--                local HPAmount = self._knightHPAmount[skillVictim.identity][tostring(skillVictim.position+1)]
--                local changeHp = math.ceil((skillVictim.change_hp - HPAmount) / hurts)
                local skillConfig = skill_info.get(attacks.skill_id)
                local ret = 1
                -- 如果攻击方和受击方一致的情况下则默认是加血了
                if skillVictim.identity ~= attacks.identity then
                    ret = (((skillConfig.skill_affect_type_1 == 1 or skillConfig.skill_affect_type_2 == 1) and -1) or     -- 1是扣血2是加血
                        ((skillConfig.skill_affect_type_1 == 2 or skillConfig.skill_affect_type_2 == 2) and 1))
                end

                assert(ret, "Unknow skill type : skill_id: "..attacks.skill_id)

                changeHp = math.ceil(changeHp / hurts) * ret

                local DamageEntry = require "app.scenes.battle.entry.DamageEntry"
                local tween = DamageEntry.create(changeHp, victim, battleField, skillVictim.is_crit, skillVictim.is_dodge)
                battleField:addEntryToSynchQueue(tween, tween.updateEntry)

                local isDouble = rawget(skillVictim, "is_double")
                local isPierce = rawget(skillVictim, "is_pierce")
                
                if skillVictim.is_crit or isDouble or isPierce then
                    local DamageDescEntry = require "app.scenes.battle.entry.DamageDescEntry"
                    local criticalTween = DamageDescEntry.create(changeHp, victim, battleField, skillVictim.is_crit, isDouble, isPierce)
                    battleField:addEntryToSynchQueue(criticalTween, criticalTween.updateEntry)
                end
            else
                local clearBuff = skillVictim.clear_buff
                for i=1, #clearBuff do
                    victim:delBuff(clearBuff[i])
                end
            end
        end
    
    elseif event == "finish" then
        
        -- 这里主要是攻击者的finish，表示攻击者动作做完，则表示不会再有下一次攻击动作了
        
        -- 清理受击动作引用
        if self._hitAction then
            for victim in pairs(self._hitAction) do
                self:addOnceEntryToQueue(nil, function()
                    self._hitAction[victim]:releaseEntry()
                    self._hitAction[victim] = nil
                    return true
                end, nil, self._shootEntrySet and self._shootEntrySet[victim] or victim)
            end
        end
        
--        -- 统计一下有几次hurts
--        local events = target:getData().events
--        local hurts = 0
--        for k, v in pairs(events) do
--            if string.match(v, "hurt") then hurts = hurts + 1 end
--        end
                    
        -- 总伤害
        -- 先计算总共的伤害值
        -- 这里偷懒一下，如果有comboEntry则就现实总伤害
        local skillId = rawget(attacks, "skill_id")
        local skillConfig = skill_info.get(skillId)
        assert(skillConfig, "Could not find the skill config in skill_info with id: "..skillId)
        
        if self._comboEntry and (skillConfig.skill_type == BattleFieldConst.SKILL_KNIGHT_ACTIVE or
                                 skillConfig.skill_type == BattleFieldConst.SKILL_KNIGHT_COMBO or
                                 skillConfig.skill_type == BattleFieldConst.SKILL_PET_NORMAL or
                                 skillConfig.skill_type == BattleFieldConst.SKILL_PET_ACTIVE) then
            local totalDamage = 0
            for i=1, #attacks.skill_victims do
                local skillVictim = attacks.skill_victims[i]
                if skillVictim.identity ~= attacks.identity then
                    local changeHp = rawget(skillVictim, "change_hp")
                    if changeHp then
                        local skillConfig = skill_info.get(attacks.skill_id)
                        local ret = (((skillConfig.skill_affect_type_1 == 1 or skillConfig.skill_affect_type_2 == 1) and -1) or     -- 1是扣血2是加血
                            ((skillConfig.skill_affect_type_1 == 2 or skillConfig.skill_affect_type_2 == 2) and 1))
                        assert(ret, "Unknown skill affect type with id: "..attacks.skill_id)
                        changeHp = changeHp * ret
                        if changeHp < 0 then totalDamage = totalDamage + math.abs(changeHp) end
                    end
                end
            end
            
            if totalDamage > 0 then
                local TotalDamageEntry = require "app.scenes.battle.entry.TotalDamageEntry"
                local totalDamageEntry = TotalDamageEntry.create(totalDamage, nil, battleField)
                self:addEntryToNewQueue(totalDamageEntry, totalDamageEntry.updateEntry)
                totalDamageEntry:retainEntry()
                self._totalDamageEntry = totalDamageEntry
            end
        end
        
        -- 攻击完后需要加buff
        for i=1, #attacks.buff_victims do
            local victim = attacks.buff_victims[i]
            local is_resist = rawget(victim, "is_resist")
            if is_resist then
                -- buff表现文字
                local BuffDescEntry = require "app.scenes.battle.entry.BuffDescEntry"
                local target = knights[victim.identity][tostring(victim.position+1)]
                local buffDescEntry = BuffDescEntry.new(victim, nil, target, battleField, is_resist)
                battleField:addEntryToQueue(buffDescEntry, buffDescEntry.updateEntry, nil, "buff"..victim.identity..(victim.position+1))
            else
                if victim.identity ~= attacks.identity then
                    local knight = knights[victim.identity][tostring(victim.position+1)]
                    knight:addBuff(victim)
                end
            end
        end
        
        for i=1, #attacks.cbuff_victims do
            local victim = attacks.cbuff_victims[i]
            if victim.identity ~= attacks.identity then
                local bMatch = false
                for j=1, #victim.clear_buff do
                    local knight = knights[victim.identity][tostring(victim.position+1)]
                    
                    local buff_id = knight:getBuff(victim.clear_buff[j]).buff_id
                    local buffInfo = buff_info.get(buff_id)
                    assert(buffInfo, "Could not find the buff info with id: "..tostring(buff_id))
                    -- 1表示增益buff，因为这里针对的是对方的那肯定是增益buff
                    bMatch = bMatch or buffInfo.buff_stype == 1
                    
                    knight:delBuff(victim.clear_buff[j])
                end
                
                if bMatch then
                    -- 有buff要显示消除
                    local BuffDescEntry = require "app.scenes.battle.entry.BuffDescEntry"
                    local target = knights[victim.identity][tostring(victim.position+1)]
                    local buffDescEntry = BuffDescEntry.new(nil, nil, target, battleField, nil, true)
                    battleField:addEntryToSynchQueue(buffDescEntry, buffDescEntry.updateEntry)
                end
            end
        end
        
        -- 怒气值变化
        for i=1, #attacks.anger_victims do
            local victim = attacks.anger_victims[i]
            local anger = rawget(victim, 'anger')
            local knight = knights[victim.identity][tostring(victim.position+1)]
            if anger and anger > 0 and victim.identity ~= attacks.identity then

                anger = attacks.identity == victim.identity and anger or anger * -1

                -- 怒气变化动画
                local AngerChangeEntry = require "app.scenes.battle.entry.AngerChangeEntry"
                local angerChangeEntry = AngerChangeEntry.create(anger, knight, battleField)
                angerChangeEntry:retainEntry()
--                battleField:addEntryToSynchQueue(angerChangeEntry, angerChangeEntry.updateEntry)
                local bFirst = true

                -- 由于怒气变化显示是延迟的，在此期间武将的怒气可能已经变化，到时再直接作加减就可能出错
                -- 因此用另一个变量记录延迟的怒气值，若期间武将怒气值已被更新，则不再做加减
                knight:setAngerChangeDelay(anger)
                battleField:addEntryToSynchQueue(nil, function(_, frameIndex)
                    -- 延迟20帧
                    if frameIndex >= 20 then
                        if bFirst then
                            bFirst = false
                            if knight.addAngerChangeDelay then
                                knight:addAngerChangeDelay(anger)
                            else
                                print("Warning: This CardSprite(identity: "..victim.identity..", position: "..(victim.position+1)..") method addAnger is nil ????")
                                -- addAnger莫名被释放了?
                                angerChangeEntry:releaseEntry()
                                return true
                            end
                        end
                        local params = {angerChangeEntry:updateEntry()}
                        if params[1] then       -- finish
                            angerChangeEntry:releaseEntry()
                        end
                        return unpack(params)
                    end
                end)
            elseif anger and anger == 0 then
                local AngerChangeEntry = require "app.scenes.battle.entry.AngerChangeEntry"
                local angerChangeEntry = AngerChangeEntry.create(anger, knight, battleField, true)
                battleField:addEntryToSynchQueue(angerChangeEntry, angerChangeEntry.updateEntry)
            end
        end
        
        -- attack中的怒气值变化
        if rawget(attacks, "anger") and self._attackers then
            self._attackers.release_knight:resetAnger(attacks.anger)
        end

        for i=1, #attacks.skill_victims do

            local skillVictim = attacks.skill_victims[i]
            if skillVictim.identity ~= attacks.identity then
                local victim = knights[skillVictim.identity][tostring(skillVictim.position+1)]

                local ActionEntry = require "app.scenes.battle.entry.ActionEntry"
                local key = self._shootEntrySet and self._shootEntrySet[victim] or victim
                
                -- 是否回血（1.4新加被动技能），设定为在受击动作完成后延迟10帧播放
                local recover = rawget(skillVictim, "recover")
                if recover and recover > 0 then
                    
                    local victim = knights[skillVictim.identity][tostring(skillVictim.position+1)]
                    -- 加血
                    local DamageEntry = require "app.scenes.battle.entry.DamageEntry"
                    local damageEntry = DamageEntry.create(recover, victim, battleField)
                    -- 延迟10帧播放
                    battleField:addEntryToSynchQueue(damageEntry, EntryWrapper.entryDelay(10, damageEntry.updateEntry))

                    -- 生命之光
                    local DamageDescEntry = require "app.scenes.battle.entry.DamageDescEntry"
                    local criticalTween = DamageDescEntry.create(recover, victim, battleField, false, false, false, true)
                    battleField:addEntryToSynchQueue(criticalTween, EntryWrapper.entryDelay(10, criticalTween.updateEntry))
                end
                
                -- 死亡
                if not skillVictim.state then

                    self:addOnceEntryToQueue(nil, function()
                        -- 敌方挂了
                        -- 先隐藏血条
                        -- 再关闭呼吸动作
                        -- 删除所有的buff
                        victim:setIsDead()
                        victim:setHPVisible(false)
                        victim:setNameVisible(false)
                        victim:setAwakenStarVisible(false)
                        victim:setAngerVisible(false)
                        if victim.setBreathAniEnabled then victim:setBreathAniEnabled(false) end
                        victim:delAllBuffs()

                        return true

                    end, nil, key)
                    
                    if not victim.isBoss then
                        -- 再来是死亡动画
                        local deadEntry = ActionEntry.new(BattleFieldConst.action.CHAR_DIE, victim, battleField)

                        -- 音效
                        deadEntry:addEntryToNewQueue(nil, function()
                            local deadSound = victim:getCardConfig().dead_sound ~= "0" and victim:getCardConfig().dead_sound or nil
                            if deadSound then
                                SoundManager:playSound(deadSound)
                            end
                            SoundManager:playSound(require("app.const.SoundConst").BattleSound.BATTLE_DEAD)
                            return true
                        end)

                        self:addEntryToQueue(deadEntry, deadEntry.updateEntry, nil, key)
                    else
                        local check = nil
                        self:addEntryToQueue(nil, function(_, frameIndex)
                            if not check then check = victim:playDead() end
                            return check(frameIndex)
                        end, nil, key)
                    end
                    
                    -- 死亡通知
                    self:addOnceEntryToQueue(nil, function()
                        -- 抛事件出去
                        battleField:dispatchEvent(battleField.BATTLE_SOMEONE_DEAD, victim:getIdentity(), victim:getCardConfig().id)
                        return true
                    end, nil, key)
                    
                    -- 掉落动画
                    -- 先判断品质
                    local awardType = nil
                    skillVictim.awards = skillVictim.awards or {}
                    for i=1, #skillVictim.awards do
                        local award = skillVictim.awards[i]
                        local Goods = G_Goods
                        if award.type == Goods.TYPE_MONEY or award.type == Goods.TYPE_GOLD or award.type == Goods.TYPE_ITEM or award.type == Goods.TYPE_WUHUN or award.type == Goods.TYPE_AWAKEN_ITEM or award.type == Goods.TYPE_SHENHUN then -- 道具
                            awardType = 3
                        elseif award.type == Goods.TYPE_FRAGMENT then       -- 卡牌/装备碎片
                            local goods = fragment_info.get(award.value)
                            if goods.fragment_type == 1 then
                                awardType = 2
                            elseif goods.fragment_type == 2 then
                                awardType = 1
                            else
                                assert(false, "Unknown award type: "..award.type.." fragment type: "..goods.fragment_type)
                            end
                        elseif award.type == Goods.TYPE_KNIGHT then -- 卡牌
                            awardType = 2
                        elseif award.type == Goods.TYPE_EQUIPMENT then -- 装备
                            awardType = 1
                        elseif award.type == Goods.TYPE_TREASURE then -- 宝物
                            awardType = 3
                        else
                            assert(false, "Unknown award type: "..award.type)
                        end
                        break
                    end

                    if awardType then
                        
                        local boxNode = nil
                        if awardType == 3 then boxNode = battleField:getItemBox()
                        elseif awardType == 2 then boxNode = battleField:getKnightBox()
                        elseif awardType == 1 then boxNode = battleField:getEquipBox()
                        end
                        
                        if boxNode then

                            -- 掉落动画
                            self._awardEntry = self._awardEntry or {}

                            local AwardEntry = require "app.scenes.battle.entry.AwardEntry"
                            self._awardEntry[victim] = AwardEntry.create(awardType, victim, battleField)
                            self._awardEntry[victim]:addEntryToNewQueue(nil, function()
                                SoundManager:playSound(require("app.const.SoundConst").BattleSound.BATTLE_BOX)
                                return true
                            end)
                            self:addEntryToQueue(self._awardEntry[victim], self._awardEntry[victim].updateEntry, nil, key)
                            -- 这里调用的动画需要保存起来，因为所创建的对象后面还要使用
                            self._awardEntry[victim]:retainEntry()

                            local displayNode = nil                        
                            local start = nil
                            local distance = nil
                            local scaleFactor = nil

                            -- 掉落之后的移动
                            self:addEntryToQueue(nil, function(_, frameIndex)

                                if not displayNode then
                                    displayNode = self._awardEntry[victim]:getObject()
                                    scaleFactor = boxNode:getScale()

                                    start = displayNode:convertToWorldSpaceAR(ccp(0, 0))
                                    local boxPosition = boxNode:convertToWorldSpace(ccp(boxNode:getContentSize().width/2, boxNode:getContentSize().height/2))
                                    distance = ccpSub(boxPosition, start)
                                end

--                                displayNode:setPosition(displayNode:getParent():convertToNodeSpace(ccpAdd(start, ccpMult(distance, frameIndex / 8))))
                                displayNode:setPositionXY(displayNode:getParent():convertToNodeSpaceXY(start.x + distance.x * frameIndex/8, start.y + distance.y * frameIndex/8))
                                displayNode:setScale((scaleFactor - 1) * frameIndex / 8 + 1)

                                if frameIndex == 8 then
                                    self._awardEntry[victim]:releaseEntry()
                                    self._awardEntry[victim] = nil

                                    local awardCountNode = nil
                                    if awardType == 3 then awardCountNode = battleField:getItemBoxCount()
                                    elseif awardType == 2 then awardCountNode = battleField:getKnightBoxCount()
                                    elseif awardType == 1 then awardCountNode = battleField:getEquipBoxCount()
                                    end

                                    awardCountNode:setString(tostring(tonumber(awardCountNode:getString()) + 1))
                                    awardCountNode:setScale(1 / scaleFactor)
                                    awardCountNode:stopActionByTag(100)

                                    local array = CCArray:create()
                                    array:addObject(CCScaleBy:create(0.2, 2))
                                    array:addObject(CCDelayTime:create(0.1))
                                    array:addObject(CCScaleBy:create(0.2, 0.5))

                                    local action = CCSequence:create(array)
                                    action:setTag(100)
                                    awardCountNode:runAction(action)

                                    return true
                                end

                                return false

                            end, nil, key)
                        end
                    end

                    -- 然后移除英雄
                    self:addOnceEntryToQueue(battleField, battleField._removeKnight, nil, key, victim)

                else
                    -- 开启呼吸动画, 我自己则需要排除，因为可能有移动
                    if attacks.identity ~= skillVictim.identity or attacks.position ~= skillVictim.position then
                        self:addOnceEntryToQueue(nil, function()
                            if victim.setBreathAniEnabled then victim:setBreathAniEnabled(true) end
                            return true
                        end, nil, key)
                    end
                end

                if self._shootEntrySet and self._shootEntrySet[victim] then
                    self:addOnceEntryToQueue(nil, function()
                        self._shootEntrySet[victim]:releaseEntry()
                        self._shootEntrySet[victim] = nil
                        return true
                    end, nil, self._shootEntrySet[victim])
                end
            end
        end
        
    elseif event == "shoot" then
        
        -- 统计一下有几次shoot
        local events = target:getData().events
        local shoots = 0
        for k, v in pairs(events) do
            if v == "shoot" then shoots = shoots + 1 end
        end
        
        -- 保存在至成员对象中，受击动作中需要使用
        self._shoots = self._shoots or {}
        
        local BulletEntry = require "app.scenes.battle.entry.BulletEntry"
        local attacker = self._attackers.release_knight
        for j=1, #attacks.skill_victims do
            local skillVictim = attacks.skill_victims[j]
            if skillVictim.identity ~= attacks.identity then
                local victim = knights[skillVictim.identity][tostring(skillVictim.position+1)]
                -- 保存在至成员对象中，受击动作中需要使用
                self._shoots[victim] = self._shoots[victim] or shoots

                -- 这里之所以要有shootEntrySet是因为有可能有连续的shoot出现
                self._shootEntrySet = self._shootEntrySet or {}
                if not self._shootEntrySet[victim] then
                    self._shootEntrySet[victim] = require("app.scenes.battle.entry.Entry").new()
                    self:addEntryToQueue(self._shootEntrySet[victim], self._shootEntrySet[victim].updateEntry, nil, self._shootEntrySet[victim])
                    self._shootEntrySet[victim]:retainEntry()
                else
                    if self._shootEntrySet[victim]:isDone() then
                        self._shootEntrySet[victim]:initEntry()
                    end
                    self:addEntryToQueue(self._shootEntrySet[victim], self._shootEntrySet[victim].updateEntry, nil, self._shootEntrySet[victim])
                end

                local changeHp = rawget(skillVictim, "change_hp")
                if changeHp then
    --                local HPAmount = self._knightHPAmount[skillVictim.identity][tostring(skillVictim.position+1)]
    --                local changeHp = math.ceil((skillVictim.change_hp - HPAmount) / shoots)
                    local skillConfig = skill_info.get(attacks.skill_id)
                    local ret = (((skillConfig.skill_affect_type_1 == 1 or skillConfig.skill_affect_type_2 == 1) and -1) or     -- 1是扣血2是加血
                        ((skillConfig.skill_affect_type_1 == 2 or skillConfig.skill_affect_type_2 == 2) and 1))

                    assert(ret, "Unknow skill type : skill_id: "..attacks.skill_id)
                    assert(playInfo.bullet_sp_id and playInfo.bullet_sp_id ~= "0", "The playInfo("..playInfo.play_group_id..", "..playInfo.skill_id..").bullet_sp_id could not be nil or 0 !")

                    changeHp = math.ceil(changeHp / shoots) * ret

                    local bulletEntry = BulletEntry.new(playInfo.bullet_sp_id, attacker, victim, battleField, handler(self, self.onAttackerEvent), changeHp, skillVictim.is_crit, skillVictim.is_dodge, rawget(skillVictim, "is_double"), rawget(skillVictim, "is_pierce"))
                    bulletEntry:addEntryToNewQueue(nil, function()
                        local bulletSound = skillConfig.bullet_sound ~= "0" and skillConfig.bullet_sound or nil
                        if bulletSound then
                            SoundManager:playSound(bulletSound)
                        end
                        return true
                    end)
                    self._shootEntrySet[victim]:addEntryToNewQueue(bulletEntry, bulletEntry.updateEntry)
                else
                    local clearBuff = skillVictim.clear_buff
                    for i=1, #clearBuff do
                        victim:delBuff(clearBuff[i])
                    end
                end
            end
        end
    end
    
end

function AttackEntry:onDefenderEvent(event, target, frameIndex)
    
    local attacks = self._data
    local knights = self._objects
    local battleField = self._battleField
    
--    -- 保存血量
--    if not self._knightHPAmount then
--        self._knightHPAmount = {}
--        for i=1, #knights do
--            self._knightHPAmount[i] = self._knightHPAmount[i] or {}
--            for k, v in pairs(knights[i]) do
--                self._knightHPAmount[i][k] = v:getHPAmount()
--            end
--        end
--    end
    
    if event == "recover" then
        
        -- 统计一下有几次hurts
        local events = target:getData().events
        local hurts = 0
        for k, v in pairs(events) do
            if v == "recover" then hurts = hurts + 1 end
        end
        
        -- 冒血
        for i=1, #attacks.skill_victims do
            local skillVictim = attacks.skill_victims[i]
            if skillVictim.identity == attacks.identity then
                local victim = knights[skillVictim.identity][tostring(skillVictim.position+1)]

                local changeHp = rawget(skillVictim, "change_hp")
                if changeHp then
                    local ret = 1   -- 可以认为给自己一方的都是加血
                    changeHp = math.ceil(changeHp / hurts) * ret

                    local DamageEntry = require "app.scenes.battle.entry.DamageEntry"
                    local tween = DamageEntry.create(changeHp, victim, battleField, skillVictim.is_crit, skillVictim.is_dodge)
                    battleField:addEntryToSynchQueue(tween, tween.updateEntry)
                    
                    local isDouble = rawget(skillVictim, "is_double")
                    local isPierce = rawget(skillVictim, "is_pierce")
                    
                    if skillVictim.is_crit or isDouble or isPierce then
                        local DamageDescEntry = require "app.scenes.battle.entry.DamageDescEntry"
                        local criticalTween = DamageDescEntry.create(changeHp, victim, battleField, skillVictim.is_crit, isDouble, isPierce)
                        battleField:addEntryToSynchQueue(criticalTween, criticalTween.updateEntry)
                    end
                    
                end
                
                local clearBuff = skillVictim.clear_buff or {}
                for i=1, #clearBuff do
                    victim:delBuff(clearBuff[i])
                end

            end
        end
        
    end
    
end

function AttackEntry:destroyEntry()
    
    AttackEntry.super.destroyEntry(self)
--    collectgarbage("collect")
    
    if self._comboEntry then self._comboEntry:releaseEntry() end
    if self._totalDamageEntry then self._totalDamageEntry:releaseEntry() end
    
    -- 受击action
    if self._hitAction then
        for k, hitAction in pairs(self._hitAction) do
            hitAction:releaseEntry()
        end
        self._hitAction = nil
    end
    
    -- 子弹的entry set
    if self._shootEntrySet then
        for k, shootAction in pairs(self._shootEntrySet) do
            shootAction:releaseEntry()
        end
        self._shootEntrySet = nil
    end
    
    -- 震屏
    if self._shakeEntry then
        self._shakeEntry:releaseEntry()
        self._shakeEntry = nil
    end
    
    -- 镜头拉近
    if self._focusOn then
        self._focusOn:stop()
        self._focusOn = nil
    end
    
    -- 这里由于震屏和镜头拉近同样是利用拉伸和位移移动战场层，所以位置上可能会有冲突，这里先统一将战场层设置位置为0
    self._battleField:setPosition(ccp(0, 0))
    
    -- 合击提示文字
    if self._comboTipEntrySet then
        for k, comboTipEntry in pairs(self._comboTipEntrySet) do
            comboTipEntry:releaseEntry()
        end
        self._comboTipEntrySet = nil
    end
    
    -- 掉落宝箱
    if self._awardEntry then
        for k, award in pairs(self._awardEntry) do
            award:releaseEntry()
        end
    end
    
    -- 大招拉幕黑底等
    if self._comboSkillBg then
        if self._comboSkillBg:isRunning() then
            self._comboSkillBg:removeFromParent()
        end
        self._comboSkillBg:release()
        self._comboSkillBg = nil
        
        local attackers = self._attackers
        local battleField = self._battleField
        local attacks = self._data
        local knights = self._objects

        -- 移动攻击者
        for k, attacker in pairs(attackers) do
            attacker:retain()
            local order = attacker:getZOrder()
            attacker:removeFromParent()
            battleField:addToCardNode(attacker, order)
            attacker:release()
        end

        -- 受害者
        for i=1, #attacks.skill_victims do
            local skillVictim = attacks.skill_victims[i]
            local victim = knights[skillVictim.identity][tostring(skillVictim.position+1)]
            victim:retain()
            local order = victim:getZOrder()
            victim:removeFromParent()
            battleField:addToCardNode(victim, order)
            victim:release()
        end
        
        -- 这里comboCardNode要放到后面执行，因为上面的攻击者(attacker)会在大招的时候被放到此node中，放在他们前面会导致野指针
        if self._comboCardNode then
            if self._comboCardNode:isRunning() then
                self._comboCardNode:removeFromParent()
            end
            self._comboCardNode:release()
            self._comboCardNode = nil
        end
    end

end

return AttackEntry