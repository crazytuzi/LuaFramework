--[[
hero = {
    NAId        普攻id
    RAId        怒技id
    BuffList
    KCIds
    IsBoss      是否是boss
    HeroModelId

    RACE = {
        ID      阵营id
        ADDR = {    伤害加成
            [raceId] = 123,
            ...
        },
        CUTR = {    伤害减免
            [raceId] = 123,
            ...
        }
    }
    ------------------------
    HP,         当前生命
    MHP,        总生命值
    AP,         攻击
    DEF,        防御
    RP,         怒气
    ------------------------
    HIT,        命中
    DOD,        闪避
    CRI         暴击
    TEN         韧性
    BLO         格挡
    BOG         破击
    CRID        必杀
    TEND        守护
    ------------------------
    DAM --伤害值
    CP --治疗值
    BCP --被治疗值
    CPR --治疗率%
    BCPR --被治疗率%
    DAMADD --伤害加成
    DAMCUT --伤害减免
    DAMADDR --伤害加成%
    DAMCUTR --伤害减免%
    BdCPR   --被动治疗率%
    ------------------------
    Pet = {
    }
    -------------------------
    辅助值，不需要传值
    APR     攻击加成
    HPR     血量加成
    DEFR    防御加成
    SHIELD    护盾值
    HPHOLE 治疗黑洞
    ---
    BanActR  抵抗眩晕几率
    BanRAR   抵抗沉默几率
    BanNAR   抵抗麻痹几率
    BanRPR   抵抗封怒几率
    BanHPR   抵抗封血几率
    HPDOTR   抵抗中毒几率

    dead_state    是否死亡
    lastHP,     上一次受伤害的生命值
}--]]

local LogicHero = class("Hero", function(params)
    local hero = clone(params.data)
    hero.idx = params.idx
    hero.battleData = params.battleData
    hero.SHIELD = 0
    hero.lastHP = hero.HP
    hero.HPHOLE = 0

    hero.APR = hero.APR or 0
    hero.HPR = hero.HPR or 0
    hero.DEFR = hero.DEFR or 0
    ---
    hero.BanActR = hero.BanActR or 0
    hero.BanRAR = hero.BanRAR or 0
    hero.BanNAR = hero.BanNAR or 0
    hero.BanRPR = hero.BanRP or 0
    hero.BanHPR = hero.BanHPR or 0
    hero.HPDOTR = hero.HPDOTR or 0
    hero.isHero = true
    hero.isPet = params.isPet
    hero.DODR = hero.DODR or 0
    hero.CRIR = hero.CRIR or 0
    hero.BLOR = hero.BLOR or 0
    hero.BdCPR = hero.BdCPR or 0

    hero.RADAMADDR = hero.RADAMADDR or 0
    hero.RBDAMADDR = hero.RBDAMADDR or 0
    hero.RCDAMADDR = hero.RCDAMADDR or 0
    hero.RADAMCUTR = hero.RADAMCUTR or 0
    hero.RBDAMCUTR = hero.RBDAMCUTR or 0
    hero.RCDAMCUTR = hero.RCDAMCUTR or 0

    hero.CON = hero.CON or 0
    hero.INTE = hero.INTE or 0
    hero.STR = hero.STR or 0
    hero.HITR = hero.HITR or 0
    hero.TENR = hero.TENR or 0
    hero.BOGR = hero.BOGR or 0
    hero.CRIDR = hero.CRIDR or 0
    hero.TENDR = hero.TENDR or 0
    hero.ADAMADDR = hero.ADAMADDR or 0
    hero.ADAMCUTR = hero.ADAMCUTR or 0

    return hero
end)

function LogicHero:getType( ... )
    return ld.getStandType(self.idx)
end

function LogicHero:checkAlive()
    if self.dead_state then
        return false
    end
    return true
end

--[[
    params:
        type
        value
        fromTarget
        noView
    return:
        dead
]]
function LogicHero:addValue(params)
    if not params.value then
        error(TR("数值变化值不能为空"))
    end
    if self.isPet then
        --宠物没有怒气变化
        return false
    end
    if params.type == "HP" then
        params.value = math.floor(params.value)
        self.battleData:getRecord():set("orghp" ,params.value)
        --记录伤害前的血量
        self.lastHP = self.HP

        if params.value > 0 then
            --治疗时触发
            local atom_back = self.battleData:getRecord()
            self.battleData:popRecord()
            self.battleData.buffTarget:calc({
                posId = self.idx,
                point = ld.BuffCalcPoint.eHealed,
                extend = {
                    --attackType = ld.AttackType.eSpecial,
                    obj_attacker = params.fromTarget,
                    obj_defender = self.idx,
                    obj_target = params.fromTarget,
                    obj_self = self.idx,
                    damage = params.value,
                }
            })
            self.battleData:pushRecord(atom_back)
            if self.newCalcDamage ~= nil then
                params.value = math.ceil(self.newCalcDamage)
                self.battleData:getRecord():set("orghp" ,params.value)
            end
        end

        if self.battleData:checkState({posId = self.idx , state = ld.BuffState.eBanHP}) then
            --封血状态，只能减不能加
            if params.value >= 0 then
                return false
            end
        end

        if self.battleData:checkState({posId = self.idx , state = ld.BuffState.eUnHurt}) then
            --免疫伤害
            if params.value <= 0 then
                return false
            end
        end

        if self.battleData:checkState({posId = self.idx , state = ld.BuffState.eShield})
            and params.value < 0 then
            --护盾状态
            self.SHIELD = self.SHIELD + params.value
            if self.SHIELD < 0 then
                --护盾破损，去除buff
                local atom_back = self.battleData:getRecord()
                self.battleData:popRecord()
                local tmp = clone(self.battleData.BuffState[self.idx][ld.BuffState.eShield])
                for i , v in ipairs(tmp) do
                    self.battleData:deleteBuff({
                        point = v.point,
                        posId = self.idx,
                        buffId = v.buffId,
                        uniqueId = v.uniqueId,
                    })
                end
                self.battleData:pushRecord(atom_back)

                self.HP = self.HP + self.SHIELD
                self.HP = math.min(self.HP , self.MHP)
                self.HP = math.max(self.HP , 0)
                local ret = self.SHIELD
                self.SHIELD = 0
                self.battleData:getRecord():set("hp" ,ret)
                self:addValue({type = "RP" , value = self.battleData.calcTarget:calcRP_to(self , math.abs(self.lastHP - self.HP))})
                --checkDead必须在setHP之后
                local s_dead = self:checkDead(ret , params.fromTarget)
                return s_dead
            else
                return false
            end
        end

        if params.value < 0 then
            local atom_back = self.battleData:getRecord()
            self.battleData:popRecord()
            self.battleData.buffTarget:calc({
                posId = self.idx,
                point = ld.BuffCalcPoint.eHurt,
                extend = {
                    --attackType = ld.AttackType.eSpecial,
                    obj_attacker = params.fromTarget,
                    obj_defender = self.idx,
                    obj_target = params.fromTarget,
                    obj_self = self.idx,
                    damage = params.value,
                }
            })
            self.battleData:pushRecord(atom_back)
            if self.newCalcDamage ~= nil then
                params.value = math.ceil(self.newCalcDamage)
                self.battleData:getRecord():set("orghp" ,params.value)
            end
        end

        if self.battleData:checkState({posId = self.idx , state = ld.BuffState.eHPHole})
            and params.value > 0 then
            --治疗黑洞
            self.HPHOLE = self.HPHOLE - params.value
            if self.HPHOLE < 0 then
                local atom_back = self.battleData:getRecord()
                self.battleData:popRecord()
                local tmp = clone(self.battleData.BuffState[self.idx][ld.BuffState.eHPHole])
                for i , v in ipairs(tmp) do
                    self.battleData:deleteBuff({
                        point = v.point,
                        posId = self.idx,
                        buffId = v.buffId,
                        uniqueId = v.uniqueId,
                    })
                end
                self.battleData:pushRecord(atom_back)

                self.HP = self.HP - self.HPHOLE
                self.HP = math.min(self.HP , self.MHP)
                self.HP = math.max(self.HP , 0)
                self.battleData:getRecord():set("hp" ,-self.HPHOLE)
                self.HPHOLE = 0
            end
            return false
        end

        self.HP = self.HP + params.value
        self.HP = math.min(self.HP , self.MHP)
        self.HP = math.max(self.HP , 0)
        self.battleData:getRecord():set("hp" , self.HP - self.lastHP)
        if self.lastHP > self.HP then
            self:addValue({type = "RP" , value = self.battleData.calcTarget:calcRP_to(self , math.abs(self.lastHP - self.HP))})
        end
        local s_dead = self:checkDead(params.value , params.fromTarget)
        return s_dead
    elseif params.type == "RP" then
        if self.battleData:checkState({posId = self.idx , state = ld.BuffState.eBanRP}) then
            --封怒状态，只能减不能加
            if params.value >= 0 then
                return
            end
        end

        self.RP = self.RP + params.value
        self.RP = math.min(self.RP , ld.MaxRP)
        self.RP = math.max(self.RP , 0)
        if not params.noView then
            self.battleData:getRecord():set("rp" ,params.value)
        end
    elseif params.type == "BdCPR" then
        self.BdCPR = self.BdCPR + params.value
        self.BdCPR = math.min(self.BdCPR, 10000)
        self.BdCPR = math.max(self.BdCPR, -9000)
    else
        self[params.type] = self[params.type] + params.value
    end
end

--[[
    params:
        type
        value
        fromTarget
    return:
        displayValue
]]
function LogicHero:setValue(params)
    if not params.value then
        error(TR("数值变化值不能为空"))
    end

    if params.type == "HP" then
        local fixValue = params.value - self.HP
        return self:addValue({type = params.type , value = fixValue , fromTarget = params.fromTarget})
    elseif params.type == "RP" then
        local fixValue = params.value - self.RP
        return self:addValue({type = params.type , value = fixValue , fromTarget = params.fromTarget})
    else
        local out
        if self[params.value] then
            out = params.value - self[params.type]
        else
            out = params.value
        end
        self[params.type] = params.value
        return out
    end
end

function LogicHero:clone2Buff( ... )
    local tmp = self.battleData
    self.battleData = nil
    local ret = clone(self)
    self.battleData = tmp
    ret.battleData = tmp
    return ret
end

function LogicHero:checkDead(hpValue , fromTarget)
    --没有死亡才需要判断
    if (not self.dead_state) and (self.HP <= 0) then
        if not self.battleData:checkState({posId = self.idx , state = ld.BuffState.eUnDead}) then
            if not self.battleData:checkState({posId = self.idx , state = ld.BuffState.eLastHurt}) then
                --非不死状态
                self.dead_state = true
                if self.battleData:checkState({posId = self.idx , state = ld.BuffState.eRebirth}) then
                    --复活
                    local atom_back = self.battleData:getRecord()
                    self.battleData:popRecord()
                    self.battleData.buffTarget:calc({
                        posId = self.idx,
                        point = ld.BuffCalcPoint.eDeadTime,
                        special = ld.BuffState.eRebirth,
                        extend = {
                            attackType = ld.AttackType.eSpecial,
                            obj_attacker = fromTarget,
                            obj_defender = self.idx,
                            obj_target = fromTarget,
                            obj_self = self.idx,
                            damage = hpValue,
                            dead = true,
                        }
                    })
                    self.battleData:pushRecord(atom_back)
                    --复活
                    self.dead_state = false
                    self.battleData:getRecord():set("rebirth" , true)
                    return false
                end
                local tid = nil
                if type(fromTarget) == "number" then
                    tid = fromTarget
                elseif type(fromTarget) == "table" then
                    if not fromTarget.isPet then
                        tid = fromTarget.idx
                    end
                end
                if tid then
                    local tmp = self.battleData:getHero(tid)
                    local kill_rp = require("ComLogic.LogicCalc"):calcRP_kill(tmp)
                    tmp:addValue({type = "RP" , value = kill_rp , noView = true})
                    self.battleData:getRecord():addDead({from = tid , rp = kill_rp})
                else
                    self.battleData:getRecord():addDead({})
                end
                --死亡buff结算
                local atom_back = self.battleData:getRecord()
                self.battleData:popRecord()
                self.battleData.buffTarget:calc({
                    posId = self.idx,
                    point = ld.BuffCalcPoint.eDeadTime,
                    extend = {
                        obj_attacker = fromTarget,
                        obj_defender = self.idx,
                        obj_target = fromTarget,
                        obj_self = self.idx,
                        damage = hpValue,
                        dead = true,
                    }
                })

                --清除buff
                for point , posList in ld.pairsByKeys(self.battleData.BuffCache) do
                    if posList[self.idx] then
                        for buffid , buffList in ld.pairsByKeys(posList[self.idx]) do
                            for i , buff in ld.pairsByKeys(buffList) do
                                self.battleData:deleteBuff({
                                    point = point,
                                    posId = self.idx,
                                    buffId = buffid,
                                    uniqueId = i,
                                })
                            end
                        end
                    end
                end
                self.battleData:pushRecord(atom_back)
                return true
            else
                --抵挡致命伤害
                local atom_back = self.battleData:getRecord()
                self.battleData:popRecord()
                self.battleData.buffTarget:calc({
                    posId = self.idx,
                    point = ld.BuffCalcPoint.eDeadTime,
                    special = ld.BuffState.eLastHurt,
                    extend = {
                        attackType = ld.AttackType.eSpecial,
                        obj_attacker = fromTarget,
                        obj_defender = self.idx,
                        obj_target = fromTarget,
                        obj_self = self.idx,
                        damage = hpValue,
                        dead = true,
                    }
                })
                self.battleData:pushRecord(atom_back)
                self.HP = self.lastHP
                self.battleData:getRecord():set("hp" , 0)
                --抵挡致命伤害
                self.battleData:getRecord():set("zhiming" , true)
            end
        else
            --不死
            local atom_back = self.battleData:getRecord()
            self.battleData:popRecord()
            self.battleData.buffTarget:calc({
                posId = self.idx,
                point = ld.BuffCalcPoint.eDeadTime,
                special = ld.BuffState.eUnDead,
                extend = {
                    attackType = ld.AttackType.eSpecial,
                    obj_attacker = fromTarget,
                    obj_defender = self.idx,
                    obj_target = fromTarget,
                    obj_self = self.idx,
                    damage = hpValue,
                    dead = true,
                }
            })
            self.battleData:pushRecord(atom_back)
            --触发不死
            self.battleData:getRecord():set("unDead" , true)
            self.HP = 1
            self.battleData:getRecord():set("hp" , self.HP - self.lastHP)
        end
    end
    return false
end

return LogicHero