local LogicProcess = class("LogicProcess" , function(data)
    return {
        data = data,    --LogicData
        seq = nil,      --LogicSeq
        target = nil,   --LogicTarget
        buff = nil,
    }
end)

function LogicProcess:ctor( ... )
    self.seq = require("ComLogic.LogicSeq").new(self.data)
    self.calc = require("ComLogic.LogicCalc").new(self.data)
    self.data.calcTarget = self.calc
    --self.buff = require("ComLogic.LogicBuff").new(self.data)
    self.buff = self.data.buffTarget
    self.seq:init()
end

function LogicProcess:init( ... )
    --计算开场宠物技
    local function excuteBuff(etype)
        if self.data.PetList2 then
            for p , q in ld.pairsByKeys(self.data.PetList2) do
                if next(q) ~= nil then
                    if ld.getStandType(p) == etype then
                        for i , v in ipairs(q.BuffList) do
                            local buff = clone(ld.getBuff(v))
                            buff.extend = {isPet = true}
                            buff.fromPos = p
                            --立即触发
                            self.buff:calcBuff({
                                posId = p,
                                buff = buff,
                                extend = {
                                    obj_self = q,
                                }
                            })
                        end
                    end
                end
            end
        end
    end

    --记录步骤数
    local tmpRecord = self.data:getRecord():addAtom("Pet2")
    self.data:pushRecord(tmpRecord)
    if self.seq:firstPriority(self.data.params.TeamData) then
        --我方先出手
        excuteBuff(ld.HeroStandType.eTeammate)
        excuteBuff(ld.HeroStandType.eEnemy)
    else
        excuteBuff(ld.HeroStandType.eEnemy)
        excuteBuff(ld.HeroStandType.eTeammate)
    end
    self.data:popRecord()

    --计算开场buff
    local function beforebattle(etype)
        for i , v in ld.pairsByKeys(self.data:getHeroList()) do
            if v:getType() == etype then
                self.buff:calc({
                    posId = i,
                    point = ld.BuffCalcPoint.eBattleStart,
                    extend = {
                        obj_self = i,
                    }
                })
            end
        end
    end

    if self.seq:firstPriority(self.data.params.TeamData) then
        --我方先出手
        beforebattle(ld.HeroStandType.eTeammate)
        beforebattle(ld.HeroStandType.eEnemy)
    else
        beforebattle(ld.HeroStandType.eEnemy)
        beforebattle(ld.HeroStandType.eTeammate)
    end

    --判断战斗结束
    local result = self.data:checkResult()
    if result ~= nil then
        self.data:getRootRecord():set("FightResult" , result)
    end

    return self.data:popRecord(true)
end

--[[
    params:
        posId,
        manual,
        autoPlay
    return:
        bool
]]
function LogicProcess:checkActionType(params)
    local ret = {
        attackType = nil,
        skillId = nil
    }
    local hero = self.data:getHero(params.posId)
    local function normalAttack( ... )
        if self.data:checkNAEnable(params.posId) then
            ret.skillId = hero.NAId
            ret.attackType = ld.AttackType.eNormal
            return true
        end
        return false
    end
    local function skillAttack(forceSkill)
        if self.data:checkRAEnable(params.posId) or forceSkill == true then
            if self.data:checkCombo(params.posId) then
                ret.skillId = self.data:checkCombo(params.posId)
                ret.attackType = ld.AttackType.eSkill
            else
                ret.skillId = hero.RAId
                ret.attackType = ld.AttackType.eSkill
            end
            return true
        end
        return false
    end
    if params.forceNormal then
        --连击普攻模式
        normalAttack()
        return ret
    end
    -- 强制使用怒技
    if params.forceSkill then
        --连击怒技模式
        skillAttack(params.forceSkill)
        return ret
    end
    --手动使用技能
    if params.manual then
        if not skillAttack() then
            dump("手动技能不满足释放条件")
        end
    else
        -- if self.data.params.ProjectName == "project_shediao" then
        --     --判断是否托管
        --     if (not params.autoPlay) and (ld.getStandType(params.posId) == ld.HeroStandType.eTeammate)
        --         and self.data:checkCombo(params.posId) then
        --         --非托管状态下，我方只有合体技的人只能普攻
        --         normalAttack()
        --     else
        --         --托管状态优先使用怒技
        --         if not skillAttack() then
        --             normalAttack()
        --         end
        --     end
        -- else
            --判断是否托管
            if (not params.autoPlay) and (ld.getStandType(params.posId) == ld.HeroStandType.eTeammate) then
                --非托管状态下，我方只使用普攻
                normalAttack()
            else
                --托管状态优先使用怒技
                if not skillAttack() then
                    normalAttack()
                end
            end
        --end
    end

    return ret
end

--[[
    params:
        autoPlay        是否是自动战斗
        skill           使用技能的位置
        multi           连续使用几个技能
    return:
        FightRetData
]]
function LogicProcess:excute(params)
    --创建返回值记录结果
    self.data:pushRecord(require("ComLogic.LogicRet").new())
    --记录回合数
    self.data:getRecord():set("Round" , self.data.round)
    --记录步骤数
    self.data:getRecord():set("Step" , self.data.step)

    --判断战斗结束
    local result = self.data:checkResult()
    if result ~= nil then
        self.data:getRootRecord():set("FightResult" , result)
        return self.data:popRecord(true)
    end

    -- 没有出手记录, 表示回合开始
    if self.seq:getShenShouAttack() == true then
        local tmpRecord = self.data:getRecord():addAtom("Pet3")
        self.data:pushRecord(tmpRecord)
        self:excutePet3()
        -- 下一个行动的是否是珍兽
        tmpRecord:set("nextPet3", self.seq:getShenShouAttack())
        self.data:popRecord()

        --判断战斗结束
        local result = self.data:checkResult()
        if result ~= nil then
            self.data:getRootRecord():set("FightResult" , result)
        end
        return self.data:popRecord(true)
    end

    local tmpRecord = self.data:getRecord():addAtom("FightAtom")
    self.data:pushRecord(tmpRecord)

    --获取出手人位置
    local posId = params.skill or self.seq:getNext()
    if not params.skill then
        --主动放技能不处理。因为每个人物每回合都会有一次检查机会
        --处理部分buff生命周期
        self.buff:calcLifeSpecial(posId)
    end
    --目标不存在，表示回合结束
    if not posId then
        self.data:popRecord()
        self:excutePet()
        --判断战斗结束
        local result = self.data:checkResult()
        if result ~= nil then
            self.data:getRootRecord():set("FightResult" , result)
            return self.data:popRecord(true)
        end
        --回合结束
        self.data:pushRecord(tmpRecord)
        self:roundOver()
        self.data:popRecord()
        --设置回合结束标志
        self.data:getRootRecord():set("RoundEnding" , true)
        return self.data:popRecord(true)
    end

    --判断能否行动。主动技能不受此限制
    if not params.skill then
        if not self.seq:checkAction(posId) then
            self:stepOver(posId)
            self.data:popRecord()
            return self.data:popRecord(true)
        end
    end

    --判断是否死亡
    local hero = self.data:getHero(posId)
    if not hero:checkAlive() then
        self:stepOver(posId)
        self.data:popRecord()
        return self.data:popRecord(true)
    end

    --如果眩晕，标记为行动成功
    if self.data:checkState({posId = posId , state = ld.BuffState.eBanAct}) then
        self.seq:markSuccess(posId)
    end
    --如果冰冻，标记为行动成功
    if self.data:checkState({posId = posId , state = ld.BuffState.eFreeze}) then
        self.seq:markSuccess(posId)
    end
    --判断攻击方式
    local attackType = self:checkActionType({posId = posId , manual = params.skill , autoPlay = params.autoPlay})
    --是否能攻击
    if attackType.skillId then
        --标记行动成功
        self.seq:markSuccess(posId)
        --记录是否过载
        self.seq:markAction(posId)
        --单次攻击模型
        self:attack({
            posId = posId,
            skillId = attackType.skillId,
            attackType = attackType.attackType,
            multi = params.multi,
        })

        --判断战斗结束
        --判断是否死亡
        local hero = self.data:getHero(posId)
        if self.data:checkResult() == nil and hero:checkAlive() then
            --触发连击
            while(true) do
                local finish = true
                if self.data:checkState({posId = posId , state = ld.BuffState.eReAttack2}) then
                    local tmpList = clone(self.data.BuffState[posId][ld.BuffState.eReAttack2])
                    for i , v in ipairs(tmpList) do
                        self.data:deleteBuff({
                            point = v.point,
                            posId = posId,
                            buffId = v.buffId,
                            uniqueId = v.uniqueId,
                        })
                    end
                    --判断攻击方式
                    local attackType = self:checkActionType({posId = posId , manual = false , autoPlay = false , forceSkill = true})
                    --是否能攻击
                    if attackType.skillId then
                        --单次攻击模型
                        self:attack({
                            posId = posId,
                            skillId = attackType.skillId,
                            attackType = attackType.attackType,
                        })
                    end
                    if self.data:checkResult() == nil then
                        finish = false
                    end
                end
                if self.data:checkState({posId = posId , state = ld.BuffState.eReAttack}) then
                    local tmpList = clone(self.data.BuffState[posId][ld.BuffState.eReAttack])
                    for i , v in ipairs(tmpList) do
                        self.data:deleteBuff({
                            point = v.point,
                            posId = posId,
                            buffId = v.buffId,
                            uniqueId = v.uniqueId,
                        })
                    end
                    --判断攻击方式
                    local attackType = self:checkActionType({posId = posId , manual = false , autoPlay = params.autoPlay})
                    --是否能攻击
                    if attackType.skillId then
                        --单次攻击模型
                        self:attack({
                            posId = posId,
                            skillId = attackType.skillId,
                            attackType = attackType.attackType,
                        })
                    end
                    if self.data:checkResult() == nil then
                        finish = false
                    end
                end
                if self.data:checkState({posId = posId , state = ld.BuffState.eReNA}) then
                    local tmpList = clone(self.data.BuffState[posId][ld.BuffState.eReNA])
                    for i , v in ipairs(tmpList) do
                        self.data:deleteBuff({
                            point = v.point,
                            posId = posId,
                            buffId = v.buffId,
                            uniqueId = v.uniqueId,
                        })
                    end
                    --判断攻击方式
                    local attackType = self:checkActionType({posId = posId , manual = false , autoPlay = false , forceNormal = true})
                    --是否能攻击
                    if attackType.skillId then
                        --单次攻击模型
                        self:attack({
                            posId = posId,
                            skillId = attackType.skillId,
                            attackType = attackType.attackType,
                        })
                    end
                    if self.data:checkResult() == nil then
                        finish = false
                    end
                end
                if finish then
                    break
                end
            end
        end
    end

    --步骤结束
    self:stepOver(posId)

    --判断战斗结束
    local result = self.data:checkResult()
    if result ~= nil then
        self.data:getRootRecord():set("FightResult" , result)
    end

    self.data:popRecord()
    return self.data:popRecord(true)
end

--[[
    params:
        posId
        skillId
        attackType
        multi
    return:
        NULL
]]
function LogicProcess:attack(params)
    local skill = ld.getSkill(params.skillId)
    --技能附加buff
    local skillBuffList = {}
    if skill and skill.buffList and skill.buffList ~= "" then
        for m , n in ipairs(ld.split(skill.buffList , ",")) do
            local tmp = self.data:addBuff({posId = params.posId , buffId = tonumber(n) , fromPos = params.posId})
            if tmp then
                table.insert(skillBuffList , tmp)
            end
        end
    end

    --获取打击目标
    local targetFunc = require("ComLogic.LogicTarget").new({data = self.data})
    local target = targetFunc:getTarget({
        posId = params.posId ,      --攻击者位置
        extend = skill.targetNum ,
        type1 = skill.targetCampEnum,
        type2 = skill.targetEnum,
        target = {},
        viewSkill = params.skillId
    })
    if #target ~= 0 then
        --创建数据副本
        self.data:pushHeroList()
        local diffList = {}
        --伤害计算之前的buff计算(攻击者的)
        self.buff:calc({
            posId = params.posId,
            point = ld.BuffCalcPoint.eBefore_all,
            extend = {
                attackType = params.attackType,
                obj_attacker = params.posId,
                --这里defender经过商议不能用
                --obj_defender = target,
                obj_target = target,
                obj_self = params.posId,
            }
        })
        if not self.data:getHero(params.posId):checkAlive() then
            --例如中毒死亡，之后不再执行攻击动作
            self.data:fixHeroList({self.data:popHeroList()})
            return
        end
        local atom = self.data:getRecord():addAtom()
        self.data:pushRecord(atom)
        atom:set("fromPos" , params.posId)
        atom:set("skillId" , params.skillId)
        atom:set("atomType" , ld.FightAtomType.eATTACK)
        local to_atom = self.data:getRecord():addAtom("to")
        self.data:pushRecord(to_atom)
        local damageInfo = {}
        for i , v in ipairs(target) do
            local p_atom = self.data:getRecord():addAtom()
            self.data:pushRecord(p_atom)
            --备份数据
            self.data:pushHeroList()
            --伤害计算之前的buff计算(攻击者)
            self.buff:calc({
                posId = params.posId,
                point = ld.BuffCalcPoint.eBefore_one,
                extend = {
                    attackType = params.attackType,
                    obj_attacker = params.posId,
                    obj_defender = v,
                    obj_target = v,
                    obj_self = params.posId,
                },
            })

            --伤害计算之前的buff计算(被攻击者)
            self.buff:calc({
                posId = v,
                point = ld.BuffCalcPoint.eBefore_one,
                extend = {
                    attackType = params.attackType,
                    obj_attacker = params.posId,
                    obj_defender = v,
                    obj_target = params.posId,
                    obj_self = v,
                },
            })

            local toHero = self.data:getHero(v)
            local hero = self.data:getHero(params.posId)

            --计算打击伤害
            local e_type , hp = self.calc:calcHP({
                hero_from = hero,
                hero_to = toHero,
                skillId = params.skillId,
                multi = params.multi,
            })
            hp = hp or 0
            table.insert(damageInfo , {hp = hp , type = e_type})
            --local rp = (hp and (hp < 0)) and self.calc:calcRP_to(toHero , -hp) or 0
            --修改血量
            local tmpAtom = self.data:getRecord():addAtom()
            self.data:pushRecord(tmpAtom)
            local dead = toHero:addValue({type = "HP" , value = hp or 0 , fromTarget = hero})
            --toHero:addValue({type = "RP" , value = rp})
            tmpAtom:set("effet" , e_type)
            tmpAtom:set("toPos" , v)
            tmpAtom:set("atomType" , ld.FightAtomType.eVALUE)
            self.data:popRecord()

            --伤害计算之后的buff计算（被攻击者）
            self.buff:calc({
                posId = v,
                point = ld.BuffCalcPoint.eAfter_one,
                extend = {
                    damage = hp,
                    e_type = e_type,
                    dead = dead,

                    attackType = params.attackType,
                    obj_attacker = params.posId,
                    obj_defender = v,
                    obj_target = params.posId,
                    obj_self = v,
                }
            })

            --伤害计算之后的buff计算（攻击者）
            self.buff:calc({
                posId = params.posId,
                point = ld.BuffCalcPoint.eAfter_one,
                extend = {
                    damage = hp,
                    e_type = e_type,
                    dead = dead,

                    attackType = params.attackType,
                    obj_attacker = params.posId,
                    obj_defender = v,
                    obj_target = v,
                    obj_self = params.posId,
                }
            })

            --弹出缓存的角色队列
            table.insert(diffList , self.data:popHeroList())

            self.data:popRecord()
        end
        self.data:popRecord()
        if params.attackType == ld.AttackType.eSkill then
            --使用怒技，怒气清零
            self.data:getHero(params.posId):setValue({type = "RP" , value = 0})
        end

        local calcFromRP = false
        local totalDamage = 0
        local stateList = {}
        for i , v in ipairs(damageInfo) do
            --普攻，且不是闪避，则增加怒气
            if (not calcFromRP) and (params.attackType == ld.AttackType.eNormal) and (v.type ~= ld.LogicEffectType.eDodge) then
                calcFromRP = true
                local hero = self.data:getHero(params.posId)
                local from_rp = self.calc:calcRP_from(hero)
                --修改怒气
                hero:addValue({type = "RP" , value = from_rp})
            end
            totalDamage = totalDamage + v.hp
            stateList[v.type] = true
        end
        self.data:popRecord()

        --写入副本数据
        self.data:fixHeroList(diffList)

        --伤害计算之后的buff计算(攻击者)
        self.buff:calc({
            posId = params.posId,
            point = ld.BuffCalcPoint.eAfter_all,
            extend = {
                damage = totalDamage,
                e_type = stateList,

                attackType = params.attackType,
                obj_attacker = params.posId,
                --这里defender经过商议不能用
                --obj_defender = target,
                obj_target = target,
                obj_self = params.posId,
            }
        })

        --将最终数据，写入cache
        self.data:fixHeroList({self.data:popHeroList()})

        --清理技能附带的buff
        if skillBuffList then
            for i , v in ipairs(skillBuffList) do
                --从列表中删除
                self.data:deleteBuff({
                    point = v.calcPoint,
                    posId = params.posId,
                    buffId = v.ID,
                    uniqueId = v.uniqueId,
                })
            end
        end

        --反击
        if self.data:getHero(params.posId):checkAlive() then
            for i , v in ipairs(target) do
                if self.data:getHero(v):checkAlive()
                    and self.data:checkState({posId = v , state = ld.BuffState.eBeatBack}) then
                    self:beatBack({
                        posId = v,
                        targetId = params.posId,
                    })
                end
            end
        end
    else
        error(TR("找不到目标！"))
    end
end


--[[
    params:
        posId
        targetId
    return:
        NULL
]]
function LogicProcess:beatBack(params)
    --创建数据副本
    self.data:pushHeroList()
    local diffList = {}
    --伤害计算之前的buff计算(攻击者的)
    self.buff:calc({
        posId = params.posId,
        point = ld.BuffCalcPoint.eBefore_all,
        extend = {
            attackType = ld.AttackType.eSpecial,
            obj_attacker = params.posId,
            --这里defender经过商议不能用
            --obj_defender = params.targetId,
            obj_target = params.targetId,
            obj_self = params.posId,
        }
    })
    local atom = self.data:getRecord():addAtom()
    self.data:pushRecord(atom)
    atom:set("fromPos" , params.posId)
    atom:set("skillId" , self.data:getHero(params.posId).NAId)
    atom:set("atomType" , ld.FightAtomType.eATTACK)
    local to_atom = self.data:getRecord():addAtom("to")
    self.data:pushRecord(to_atom)

        local p_atom = self.data:getRecord():addAtom()
        self.data:pushRecord(p_atom)
        --备份数据
        self.data:pushHeroList()
        --伤害计算之前的buff计算(攻击者)
        self.buff:calc({
            posId = params.posId,
            point = ld.BuffCalcPoint.eBefore_one,
            extend = {
                attackType = ld.AttackType.eSpecial,
                obj_attacker = params.posId,
                obj_defender = params.targetId,
                obj_target = params.targetId,
                obj_self = params.posId,
            },
        })

        --伤害计算之前的buff计算(被攻击者)
        self.buff:calc({
            posId = params.targetId,
            point = ld.BuffCalcPoint.eBefore_one,
            extend = {
                attackType = ld.AttackType.eSpecial,
                obj_attacker = params.posId,
                obj_defender = params.targetId,
                obj_target = params.posId,
                obj_self = params.targetId,
            },
        })

        local toHero = self.data:getHero(params.targetId)
        local hero = self.data:getHero(params.posId)
        --计算打击伤害
        local tmpState = self.data.BuffState[params.posId][ld.BuffState.eBeatBack][1]
        local buff_bb = self.data:getBuff({
            point = tmpState.point,
            posId = params.posId,
            buffId = tmpState.buffId,
            uniqueId = tmpState.uniqueId,
        })
        local e_type , hp = self.calc:calcHP({
            hero_from = hero,
            hero_to = toHero,
            skillId = hero.NAId,
            newfactor = buff_bb.addition2,
        })
        hp = hp or 0
        --local rp = (hp and (hp < 0)) and self.calc:calcRP_to(toHero , -hp) or nil
        --修改血量
        local tmpAtom = self.data:getRecord():addAtom()
        self.data:pushRecord(tmpAtom)
        local dead = toHero:addValue({type = "HP" , value = hp , fromTarget = hero})
        --toHero:addValue({type = "RP" , value = rp})
        tmpAtom:set("effet" , e_type)
        tmpAtom:set("toPos" , params.targetId)
        tmpAtom:set("atomType" , ld.FightAtomType.eVALUE)
        self.data:popRecord()

        --伤害计算之后的buff计算(被攻击者)
        self.buff:calc({
            posId = params.targetId,
            point = ld.BuffCalcPoint.eAfter_one,
            extend = {
                damage = hp,
                e_type = e_type,
                dead = dead,

                attackType = ld.AttackType.eSpecial,
                obj_attacker = params.posId,
                obj_defender = params.targetId,
                obj_target = params.posId,
                obj_self = params.targetId,
            }
        })

        --伤害计算之后的buff计算(攻击者)
        self.buff:calc({
            posId = params.posId,
            point = ld.BuffCalcPoint.eAfter_one,
            extend = {
                damage = hp,
                e_type = e_type,
                dead = dead,

                attackType = ld.AttackType.eSpecial,
                obj_attacker = params.posId,
                obj_defender = params.targetId,
                obj_target = params.targetId,
                obj_self = params.posId,
            }
        })

        table.insert(diffList , self.data:popHeroList())

        self.data:popRecord()

    self.data:popRecord()
    self.data:popRecord()

    --写入副本数据
    self.data:fixHeroList(diffList)

    --伤害计算之后的buff计算(攻击者)
    self.buff:calc({
        posId = params.posId,
        point = ld.BuffCalcPoint.eAfter_all,
        extend = {
            damage = hp,
            e_type = e_type,

            attackType = ld.AttackType.eSpecial,
            obj_attacker = params.posId,
            --这里defender经过商议不能用
            --obj_defender = params.targetId,
            obj_target = params.targetId,
            obj_self = params.posId,
        }
    })

    --将最终数据，写入cache
    self.data:fixHeroList({self.data:popHeroList()})

    --清除反击buff
    self.data:deleteBuff({
        point = tmpState.point,
        posId = params.posId,
        buffId = tmpState.buffId,
    })
end

function LogicProcess:roundOver()
    --处理回合结束的buff
    for i , v in ld.pairsByKeys(self.data:getHeroList()) do
        self.buff:calc({
            posId = i,
            point = ld.BuffCalcPoint.eRoundOver,
            extend = {
                obj_self = i,
            }
        })
    end

    --结算buff生命周期
    self.buff:calcLifeRound()

    self.data.round = self.data.round + 1
    self.data.step = 1
    self.seq:init()
end

function LogicProcess:stepOver(posId)
    self.data.step = self.data.step + 1

    --攻击结算buff计算
    self.buff:calc({
        posId = posId,
        point = ld.BuffCalcPoint.eAttackOver,
        extend = {
            obj_self = i,
        }
    })

    local function storage_checkAlive(list)
        for i , v in ipairs(list) do
            if not v.switchIdx then
                return i
            end
        end
        return nil
    end

    --替换死掉的人物
    for i , v in ld.pairsByKeys(self.data.HeroCache) do
        if not v:checkAlive() then
            if v:getType() == ld.HeroStandType.eEnemy
            and storage_checkAlive(self.data.HeroStorage_enemey) then
                local idx = storage_checkAlive(self.data.HeroStorage_enemey)
                local tmp = self.data.HeroCache[i]
                tmp.switchIdx = i
                self.data.HeroCache[i] = self.data.HeroStorage_enemey[idx]
                self.data.HeroCache[i].idx = i
                self.data.HeroStorage_enemey[idx] = tmp
                self.data:initSingleHero(self.data.HeroCache[i])
                local atom = self.data:getRecord():addAtom()
                atom:set("addIn" , {toPos = i , idx = idx})
            elseif v:getType() == ld.HeroStandType.eTeammate
            and storage_checkAlive(self.data.HeroStorage_teammate) then
                local idx = storage_checkAlive(self.data.HeroStorage_teammate)
                local tmp = self.data.HeroCache[i]
                tmp.switchIdx = i
                self.data.HeroCache[i] = self.data.HeroStorage_teammate[idx]
                self.data.HeroCache[i].idx = i
                self.data.HeroStorage_teammate[idx] = tmp
                self.data:initSingleHero(self.data.HeroCache[i])
                local atom = self.data:getRecord():addAtom()
                atom:set("addIn" , {toPos = i , idx = idx})
            end
        end
    end
end

function LogicProcess:excutePet( ... )
    local function excuteBuff(posId)
        local atom = self.data:getRecord():addAtom()
        self.data:pushRecord(atom)
        if self.data.PetList[posId] then
            for i , v in ipairs(self.data.PetList[posId].BuffList) do
                local buff = clone(ld.getBuff(v))
                buff.extend = {isPet = true}
                buff.fromPos = posId
                --立即触发
                self.buff:calcBuff({
                    posId = posId,
                    buff = buff,
                    extend = {
                        obj_self = self.data.PetList[posId],
                    }
                })
            end
        end
        self.data:popRecord()
    end

    --记录步骤数
    local tmpRecord = self.data:getRecord():addAtom("Pet")
    self.data:pushRecord(tmpRecord)

    local round = self.data.round
    local first = nil
    local second = nil
    if round <= 6 then
        if self.seq:firstPriority(self.data.params.TeamData) then
            first = round
            second = round + 6
        else
            first = round + 6
            second = round
        end
    end
    if first then
        if logic_project_name == "project_xueying" then
            local pet = self.data.PetList[first]
            if pet then
                -- first表示回合数和宠物索引，不表示hero索引
                -- StationId表示阵容中站位ID，通过它获取hero索引
                local heroIdx = pet.StationId + (first > 6 and 6 or 0)
                local hero = self.data:getHero(heroIdx)
                if hero and hero:checkAlive() then
                    excuteBuff(first)
                end
            end
        elseif logic_project_name == "project_shediao" then
            local pet = self.data.PetList[first]
            if pet then
                -- first表示回合数和宠物索引，不表示hero索引
                -- StationId表示阵容中站位ID，通过它获取hero索引
                local heroIdx = pet.FormationId + (first > 6 and 6 or 0)
                local hero = self.data:getHero(heroIdx)
                if hero and hero:checkAlive() then
                    excuteBuff(first)
                end
            end
        else
            excuteBuff(first)
        end
    end
    if second then
        if logic_project_name == "project_xueying" then
            local pet = self.data.PetList[second]
            if pet then
                local heroIdx = pet.StationId + (second > 6 and 6 or 0)
                local hero = self.data:getHero(heroIdx)
                if hero and hero:checkAlive() then
                    excuteBuff(second)
                end
            end
        elseif logic_project_name == "project_shediao" then
            local pet = self.data.PetList[second]
            if pet then
                local heroIdx = pet.FormationId + (second > 6 and 6 or 0)
                local hero = self.data:getHero(heroIdx)
                if hero and hero:checkAlive() then
                    excuteBuff(second)
                end
            end
        else
            excuteBuff(second)
        end
    end

    self.data:popRecord()
end

-- 
function LogicProcess:excutePet3( ... )
    -- 判断技能释放概率
    local function getSkillType(levelInfo, hero)
        local skillType = "none"
        local bufList = {}
        local skillId = 0

        local normalRnd = levelInfo.baseOddsR
        local skillRnd = levelInfo.baseOddsR + levelInfo.skillOddsR

        local rand = self.data.rand:random(1, 10000)

        if rand <= normalRnd then
            table.insert(bufList, levelInfo.baseAtkBuffID)

            local tmpList = ld.split(levelInfo.baseAtkEffectBuffID , ",")
            for m , n in ipairs(tmpList or {}) do
                table.insert(bufList , tonumber(n))
            end

            -- 替换属性
            hero[levelInfo.atkParamType] = hero.NAId

            skillType = "normal"

            skillId = levelInfo.baseAtkBuffID
        elseif rand <= skillRnd then
            table.insert(bufList, levelInfo.skillAtkBuffID)

            local tmpList = ld.split(levelInfo.skillAtkEffectBuffID , ",")
            for m , n in ipairs(tmpList or {}) do
                table.insert(bufList , tonumber(n))
            end

            -- 替换属性
            hero[levelInfo.atkParamType] = hero.RAId

            skillType = "skill"

            skillId = levelInfo.skillAtkBuffID
        end

        return skillType, bufList, skillId
    end

    --计算回合开始时宠物技
    local function excuteBuff(etype)
        if self.data.PetList3 then
            for p , q in ld.pairsByKeys(self.data.PetList3) do
                if next(q) ~= nil then
                    local petPos = p
                    if petPos > 1 then
                        petPos = petPos + 6
                    end
                    if ld.getPetStandType(petPos) == etype then
                        -- 根据等级获得技能相关概率
                        local zhenShouLevelInfo = self.data:getZhenShouLevelInfo(q.HeroModelId, q.Step)

                        local skillType, buffList, skillId = getSkillType(zhenShouLevelInfo, q)

                        if skillType ~= "none" then
                            local atom = self.data:getRecord():addAtom()
                            self.data:pushRecord(atom)
                            atom:set("fromPos" , petPos)
                            atom:set("skillId" , skillId)
                            atom:set("atomType" , ld.FightAtomType.eSTATE)

                            local to_atom = self.data:getRecord():addAtom("to")
                            self.data:pushRecord(to_atom)

                            for i , v in ipairs(buffList) do
                                local buff = clone(ld.getBuff(v))
                                buff.extend = {isPet = true}
                                buff.fromPos = petPos
                                --立即触发
                                self.buff:calcBuff({
                                    posId = petPos,
                                    buff = buff,
                                    extend = {
                                        obj_self = q,
                                    }
                                })
                            end
                            self.data:popRecord()
                            self.data:popRecord()
                        end
                    end
                end
            end
        end
    end

    --记录步骤数
    if self.seq:firstPriority(self.data.params.TeamData) then
        --我方先出手
        if self.seq:getShenShouTeamAttack() == true then
            excuteBuff(ld.HeroStandType.eTeammate)
            self.seq:setShenShouTeamAttack()
        else
            excuteBuff(ld.HeroStandType.eEnemy)
            self.seq:setShenShouEnemyAttack()
        end 
    else
        --我方先出手
        if self.seq:getShenShouEnemyAttack() == true then
            excuteBuff(ld.HeroStandType.eEnemy)
            self.seq:setShenShouEnemyAttack()
        else
            excuteBuff(ld.HeroStandType.eTeammate)
            self.seq:setShenShouTeamAttack()
        end 
    end
end

return LogicProcess
