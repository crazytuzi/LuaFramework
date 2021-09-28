-- RoundEntry
local AttackEntry = require "app.scenes.battle.entry.AttackEntry"
local PetAttackEntry = require "app.scenes.battle.entry.PetAttackEntry"
local BattleFieldConst = require "app.scenes.battle.BattleFieldConst"

local RoundEntry = class("RoundEntry", require "app.scenes.battle.entry.Entry")

function RoundEntry:initEntry()
    
    RoundEntry.super.initEntry(self)
    
    local round = self._data
    local knights = self._objects
    local battleField = self._battleField

    if round.buff_victim and table.nums(round.buff_victim) > 0 then
        self:addOnceEntryToQueue(self, self.updateBuff)
    end
    
    local attackIndex = 0
    local function nextAttack()
        attackIndex = attackIndex + 1
        
        local attackData = round.attacks[attackIndex]
        if not attackData then return true end
        
        local roundType = rawget(round, "type") or BattleFieldConst.ROUND_NORMAL
        local attack = nil
        if roundType == BattleFieldConst.ROUND_NORMAL then
            attack = AttackEntry.new(attackData, knights, battleField)
            battleField:dispatchEvent(battleField.BATTLE_SOMEONE_ATTACK, attackData.identity, attackData.position+1, knights[attackData.identity][tostring(attackData.position+1)]:getCardConfig().id)
        else
            attack = PetAttackEntry.new(attackData, knights, battleField)
        end

        self:addEntryToQueue(attack, attack.updateEntry)
        self:addOnceEntryToQueue(nil, nextAttack)

        return true
    end
    
    self:addOnceEntryToQueue(nil, nextAttack)

end

-- @Deprecated Method

function RoundEntry:updateBuff()

    -- 这里主要以回合制buff为主
    local buffVictim = self._data.buff_victim
    for i=1, #buffVictim do
        local victim = buffVictim[i]
        local bbs = victim.bbs
        local target = self._objects[victim.identity][tostring(victim.position+1)]
        for j=1, #bbs do
            if bbs[j].count == 0 then
                target:delBuff(bbs[j].id)
            end
             
            local result = rawget(bbs, "result")
            if result then
                local buff_id = target:getBuff(bbs[j].id).buff_id
                require "app.cfg.buff_info"
                local buffConfig = buff_info.get(buff_id)
                assert(buffConfig, "Unknown buff id: "..buff_id)
                
                -- 1是扣血，2是加血
                local changeHp = 0
                if buffConfig.buff_affect_type == 1 then
                    changeHp = result * -1
                elseif buffConfig.buff_affect_type == 2 then
                    changeHp = result
                end
                
                -- 冒血
                local BuffDamageEntry = require "app.scenes.battle.entry.BuffDamageEntry"
                local tween = BuffDamageEntry.create(buffConfig, changeHp, victim, self._battleField)
                self._battleField:addEntryToSynchQueue(tween, tween.updateEntry)
            end
        end        
    end

    return true
end

return RoundEntry