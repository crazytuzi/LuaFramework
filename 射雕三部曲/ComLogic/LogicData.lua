--[[
    LogicData = {
        params
        HeroCache = {
            [1] = {...},
            ....
        },
        HeroStorage_enemey = {}
        HeroStorage_teammate = {}
        BuffCache = {
            [buff执行时刻] = {
                [buff所在位置] = {
                    [buffId] = {
                        [buff唯一Id] = {
                            buff结构,...
                        }
                    }
                }
            },
        }
        BuffState = {
            [buff所在的位置] = {
                [buff类型] = {
                    buff唯一id,...
                }
            }
        }
        BuffLinked = {
            [技能发起者的位置] = {
                关联的buff位置,...
            }
        }
        uniqueId buff唯一id
        round   回合数
        step    步骤数据
        finish = false,
        recordList = {}  logicRet对象的缓存栈
        buffTarget      buff对象
        calcTarget      计算公式
        HeroCacheList   HeroCache表的缓存队列
        friendAttr      我方总属性
        enemeyAttr      敌方总属性
        PetList = {
            [1] = {
                pet
            },
            [2] = {

            },...
        }
        PetList2 = {
            [1] = {
                pet
            },
            [2] = {

            },...
        }
        PetList3 = {
            [1] = {pet},
            [2] = {pet},
        }
    }
    开场技：人物属性KCIds中的buffID，引用人物属性
    回合宠物技：PetList中的宠物技能，引用宠物属性，索引表示回合数
    开场宠物技：PetList2中的宠物技能，引用宠物属性，索引表示站位
]]
local LogicData = class("LogicData" , function(params)
    return {
        HeroCache = {} ,
        BuffCache = {},
        BuffState = {},
        BuffLinked = {},
        round = 1 ,
        step = 1 ,
        params = params,
        uniqueId = 1,
        recordList = {},
        HeroStorage_enemey = {},
        HeroStorage_teammate = {},
        HeroCacheList = {},
        PetList = {},--回合结束执行的宠物技
        PetList2 = {},--战斗开始前执行的宠物技
        PetList3 = {}, -- 每回合开始前执行的宠物技能
    }
end)
---------------------------------------------------
function LogicData:pushRecord(record)
    table.insert(self.recordList , record)
end

function LogicData:getRecord( ... )
    if #self.recordList ~= 0 then
        return self.recordList[#self.recordList]
    end
end

function LogicData:getRootRecord( ... )
    return self.recordList[1]
end

function LogicData:popRecord(last)
    if #self.recordList ~= 0 then
        if last and self.params.FullInfo then
            self.recordList[#self.recordList]:addCoreData(self:getHeroList() , self.HeroStorage_teammate , self.HeroStorage_enemey)
        end
        local out = self.recordList[#self.recordList]:getResult()
        table.remove(self.recordList , #self.recordList)
        return out
    end
end
---------------------------------------------------
function LogicData:pushHeroList()
    local function copyHero(list)
        local ret = {}
        for i , v in ld.pairsByKeys(list) do
            ret[i] = v:clone2Buff()
        end
        return ret
    end

    local tmp
    if #self.HeroCacheList ~= 0 then
        tmp = copyHero(self.HeroCacheList[#self.HeroCacheList])
    else
        tmp = copyHero(self.HeroCache)
    end
    table.insert(self.HeroCacheList , tmp)
    return tmp
end

function LogicData:getHeroList( ... )
    if #self.HeroCacheList ~= 0 then
        return self.HeroCacheList[#self.HeroCacheList]
    else
        return self.HeroCache
    end
end

function LogicData:popHeroList( ... )
    local function diffCopy(list1 , list2) --first, second
        local ret = {}
        for i , v in ld.pairsByKeys(list1) do
            ret[i] = {
                hp = list2[i].HP - v.HP,
                lasthp = list2[i].lastHP - v.lastHP,
                rp = list2[i].RP - v.RP,
                shield = list2[i].SHIELD - v.SHIELD,
                dead_state = list2[i].dead_state,
                hphole = list2[i].HPHOLE - v.HPHOLE,
            }
        end
        return ret
    end

    if #self.HeroCacheList ~= 0 then
        local new = self.HeroCacheList[#self.HeroCacheList]
        table.remove(self.HeroCacheList , #self.HeroCacheList)
        local old
        if #self.HeroCacheList ~= 0 then
            old = self.HeroCacheList[#self.HeroCacheList]
        else
            old = self.HeroCache
        end
        return diffCopy(old , new)
    end
    error(TR("弹出角色队列错误"))
end

function LogicData:fixHeroList(diffList)
    local function fixCopy(to , diffList)
        for n , diff in ld.pairsByKeys(diffList) do
            for i , v in ld.pairsByKeys(to) do
                v.HP = v.HP + diff[i].hp
                v.RP = v.RP + diff[i].rp
                v.SHIELD = v.SHIELD + diff[i].shield
                v.lastHP = v.lastHP + diff[i].lasthp
                v.HPHOLE = v.HPHOLE + diff[i].hphole
                if not v.dead_state then
                    v.dead_state = diff[i].dead_state
                end
            end
        end
    end
    if #self.HeroCacheList ~= 0 then
        fixCopy(self.HeroCacheList[#self.HeroCacheList] , diffList)
    else
        fixCopy(self.HeroCache , diffList)
    end
end
---------------------------------------------------
function LogicData:initSingleHero(v)
    --人物天赋
    for p , q in ipairs(v.BuffList) do
        self:addBuff({posId = v.idx , buffId = tonumber(q) , fromPos = v.idx})
    end
    --开场技能
    if v.KCIds then
        for p , q in ipairs(v.KCIds) do
            self:addBuff({posId = v.idx , buffId = tonumber(q) , fromPos = v.idx , extend = {isStart = true}})
        end
    end
    -- local nSkill = ld.getSkill(v.NAId)
    -- if nSkill and nSkill.buffList and nSkill.buffList ~= "" then
    --     for m , n in ipairs(ld.split(nSkill.buffList , ",")) do
    --         self:addBuff({posId = v.idx , buffId = tonumber(n) , fromPos = v.idx})
    --     end
    -- end
    -- local rSkill = ld.getSkill(v.RAId)
    -- if rSkill and rSkill.buffList and rSkill.buffList ~= "" then
    --     for m , n in ipairs(ld.split(rSkill.buffList , ",")) do
    --         self:addBuff({posId = v.idx , buffId = tonumber(n) , fromPos = v.idx})
    --     end
    -- end
end

function LogicData:ctor()
    self.buffTarget = require("ComLogic.LogicBuff").new(self)

    self:pushRecord(require("ComLogic.LogicRet").new())
    --初始化随机种子
    self.rand = require("ComLogic.LogicRand").new(self.params.RandSeed)
    --初始化人物列表
    for i , v in ld.pairsByKeys(self.params.HeroList) do
        if next(v) ~= nil then
            self.HeroCache[i] = require("ComLogic.LogicHero").new({data = v ,idx = i , battleData = self})
            self:initSingleHero(self.HeroCache[i])
        end
    end
    if self.params.PetList then
        --创建宠物对象
        for i , v in ld.pairsByKeys(self.params.PetList) do
            if next(v) ~= nil then
                self.PetList[i] = require("ComLogic.LogicHero").new({data = v ,idx = i , battleData = self , isPet = true})
            end
        end
    end
    if self.params.PetList2 then
        --创建宠物对象
        for i , v in ld.pairsByKeys(self.params.PetList2) do
            if next(v) ~= nil then
                self.PetList2[i] = require("ComLogic.LogicHero").new({data = v ,idx = i , battleData = self , isPet = true})
            end
        end
    end
    if self.params.PetList3 then
        --创建宠物对象
        for i , v in ld.pairsByKeys(self.params.PetList3) do
            if next(v) ~= nil then
                self.PetList3[i] = require("ComLogic.LogicHero").new({data = v ,idx = i , battleData = self , isPet = true})
            end
        end
    end

    self.finish = nil

    --初始化替换队列
    if self.params.StorageList then
        if self.params.StorageList.enemy then
            for i , v in ipairs(self.params.StorageList.enemy) do
                self.HeroStorage_enemey[i] = require("ComLogic.LogicHero").new({data = v , battleData = self})
            end
        end
        if self.params.StorageList.teammate then
            for i , v in ipairs(self.params.StorageList.teammate) do
                self.HeroStorage_teammate[i] = require("ComLogic.LogicHero").new({data = v , battleData = self})
            end
        end
    end

    --初始化总属性对象
    if self.params.TeamData.Friend.TotalHero then
        self.friendAttr = require("ComLogic.LogicHero").new({data = self.params.TeamData.Friend.TotalHero , battleData = self})
    end
    if self.params.TeamData.Enemy.TotalHero then
        self.enemeyAttr = require("ComLogic.LogicHero").new({data = self.params.TeamData.Enemy.TotalHero , battleData = self})
    end
end

function LogicData:getHero(idx)
    return self:getHeroList()[idx]
end

--[[
    params:
        NULL
    return:
        nil :为完成
        ture:胜利
        false:失败
]]
function LogicData:checkResult( ... )
    -- 记录血量
    require("ComLogic.StatisticsManager")
    for i , v in ld.pairsByKeys(self.HeroCache) do
         StatisticsManager.life(v)
    end

    local hero_type = nil
    for i , v in ld.pairsByKeys(self.HeroCache) do
        if v:checkAlive() then
            if not hero_type then
                hero_type = v:getType()
            elseif hero_type ~= v:getType() then
                if self.params.MaxRound < self.round then
                    return false
                else
                    return nil
                end
            end
        end
    end
    if hero_type == ld.HeroStandType.eEnemy then
        return false
    else
        return true
    end
end

function LogicData:getFinalState( ... )
    local ret = {}
    for i , v in ld.pairsByKeys(self.HeroCache) do
        ret[i] = {
            hp = v.HP,
            rp = v.RP,
        }
    end
    return ret
end

local function checkBuffPoint(point1 , point2 , buffId)
    if point1 == ld.TriggerPoint1.eNone then
        return ld.BuffCalcPoint.eNULL
    end
    --开场触发
    if point1 == ld.TriggerPoint1.eStartFighting then
        return ld.BuffCalcPoint.eBattleStart
    end
    --回合结束
    if point1 == ld.TriggerPoint1.eRoundOver then
        return ld.BuffCalcPoint.eRoundOver
    end
    --攻击结束
    if point1 == ld.TriggerPoint1.eAttackOver then
        return ld.BuffCalcPoint.eAttackOver
    end
    --死亡时触发
    if point1 == ld.TriggerPoint1.eDeadTime then
        return ld.BuffCalcPoint.eDeadTime
    end
    --被治疗
    if point1 == ld.TriggerPoint1.eHealed then
        return ld.BuffCalcPoint.eHealed
    end
    --附加时执行
    if point1 == ld.TriggerPoint1.eRightNow then
        return ld.BuffCalcPoint.eRightNow
    end
    if point1 == ld.TriggerPoint1.eHurt then
        return ld.BuffCalcPoint.eHurt
    end

----------------------------------------------
    local list1 = {
        ld.TriggerPoint1.eAttack, --攻击
        ld.TriggerPoint1.eNormalAttack,--普攻
        ld.TriggerPoint1.eSkillAttack,--技攻
    }
    local list2 = {
        ld.TriggerPoint2.eBeforeCalculation_all,--计算前(多人)
    }
    for i , v in ipairs(list2) do
        if point2 == v then
            for p , q in ipairs(list1) do
                if point1 == q then
                    return ld.BuffCalcPoint.eBefore_all
                end
            end
        end
    end
----------------------------------------------
    local list1 = {
        ld.TriggerPoint1.eAttack, --攻击
        ld.TriggerPoint1.eNormalAttack,--普攻
        ld.TriggerPoint1.eSkillAttack,--技攻
        ld.TriggerPoint1.eAttacked, --被攻击
        ld.TriggerPoint1.eNormalAttacked, --被普攻
        ld.TriggerPoint1.eSkillAttacked, --被技攻
    }
    local list2 = {
        ld.TriggerPoint2.eBeforeCalculation,--计算前（单人）
    }
    for i , v in ipairs(list2) do
        if point2 == v then
            for p , q in ipairs(list1) do
                if point1 == q then
                    return ld.BuffCalcPoint.eBefore_one
                end
            end
        end
    end
----------------------------------------------
    local list2 = {
        ld.TriggerPoint2.eAfterCalculation, --计算后
    }
    local list1 = {
        ld.TriggerPoint1.eAttack, --攻击
        ld.TriggerPoint1.eNormalAttack,--普攻
        ld.TriggerPoint1.eSkillAttack,--技攻
        ld.TriggerPoint1.eAttacked, --被攻击
        ld.TriggerPoint1.eNormalAttacked, --被普攻
        ld.TriggerPoint1.eSkillAttacked,--被技攻
    }
    for i , v in ipairs(list1) do
        if point1 == v then
            for p , q in ipairs(list2) do
                if point2 == q then
                    return ld.BuffCalcPoint.eAfter_one
                end
            end
        end
    end
----------------------------------------------
    local list1 = {
        ld.TriggerPoint1.eAttack, --攻击
        ld.TriggerPoint1.eNormalAttack,--普攻
        ld.TriggerPoint1.eSkillAttack,--技攻
        ld.TriggerPoint1.eAttacked, --被攻击
        ld.TriggerPoint1.eNormalAttacked, --被普攻
        ld.TriggerPoint1.eSkillAttacked,--被技攻
    }
    local list2 = {
        ld.TriggerPoint2.eAfterCalculation_all, --计算后
    }
    for i , v in ipairs(list2) do
        if point2 == v then
            for p , q in ipairs(list1) do
                if point1 == q then
                    return ld.BuffCalcPoint.eAfter_all
                end
            end
        end
    end

    error(string.format("not found buff exec point! %d %d %d" ,buffId or 0 , point1 , point2))
end

--[[
    params:
        posId
        buffId
        fromPos
        addition
        extend
    return:
        bool 是否添加成功
]]
function LogicData:addBuff(params)
    local buff = clone(ld.getBuff(params.buffId))
    if buff then
        local calcPoint = checkBuffPoint(buff.point1 , buff.point2 , buff.ID)
        self.BuffCache[calcPoint] = self.BuffCache[calcPoint] or {}
        self.BuffCache[calcPoint][params.posId] = self.BuffCache[calcPoint][params.posId] or {}
        self.BuffCache[calcPoint][params.posId][params.buffId] = self.BuffCache[calcPoint][params.posId][params.buffId] or {}
        local tmpTable = self.BuffCache[calcPoint][params.posId][params.buffId]
        --写入为一id
        buff.uniqueId = self.uniqueId
        self.uniqueId = self.uniqueId + 1
        buff.fromPos = params.fromPos
        buff.calcPoint = calcPoint

        if buff.overlayNum == -1 then
            --独立不相关、可以叠加无数次
            tmpTable[buff.uniqueId] = buff
        elseif buff.overlayNum == 0 then
            --覆盖
            self:deleteBuff({
                point = calcPoint,
                posId = params.posId,
                buffId = params.buffId,
            })
            tmpTable[buff.uniqueId] = buff
        else
            local count = 0
            for i , v in pairs(tmpTable) do
                count = count + 1
            end
            if count <= buff.overlayNum then
                tmpTable[buff.uniqueId] = buff
            else
                buff = nil
            end
        end

        if buff and buff.stateEnum ~= ld.BuffState.eNULL then
            self:addState({
                posId = params.posId ,
                state = buff.stateEnum ,
                uniqueId = buff.uniqueId ,
                buffId = buff.ID,
                point = calcPoint,
            })
            --记录影响的目标（状态buff用）
            self:addLink({
                posId = params.fromPos,
                ------------
                point = calcPoint,
                tpos = params.posId,
                buffId = params.buffId,
                uniqueId = buff.uniqueId,
            })
        end
        if buff then
            buff.extend = params.extend or {}
            --宠物技能在回合结束释放，所有延迟一回合
            if buff.extend.lifeRound_pet and buff.lifeRound > 0 then
                buff.lifeRound = buff.lifeRound + 1
            end
            local atom = self:getRecord():addAtom()
            atom:addBuff({
                buffId = params.buffId,
                uniqueId = buff.uniqueId,
                toPos = params.posId,
                fromPos = params.fromPos,
                type = ld.BuffDisplayState.eAttach,
                extend = buff.extend,
            })
            if params.addition then
                for i , v in ld.pairsByKeys(params.addition) do
                    buff["addition"..i] = v
                end
            end
            if calcPoint == ld.BuffCalcPoint.eRightNow then
                --立即触发
                self.buffTarget:calcBuff({
                    posId = params.posId,
                    buff = buff,
                    extend = {
                        --attackType = ld.AttackType.eSpecial,
                        obj_attacker = params.fromPos,
                        obj_defender = params.posId,
                        obj_target = params.fromPos,
                        obj_self = params.posId,
                    }
                })
                if buff and buff.stateEnum == ld.BuffState.eNULL then
                    --从列表中删除
                    self:deleteBuff({
                        point = buff.calcPoint,
                        posId = params.posId,
                        buffId = params.buffId,
                        uniqueId = buff.uniqueId,
                    })
                    buff = nil
                end
            end
        end
        return buff
    else
        --error(string.format("not found buffId：%d" , params.buffId))
    end
end

--[[
    params:
        point,
        posId,
        buffId
        uniqueId    确定关联的buff位置
    return:
        buff
]]
function LogicData:getBuff(params)
    if params.point then
        if self.BuffCache[params.point] then
            if params.posId then
                if self.BuffCache[params.point][params.posId] then
                    if params.buffId then
                        if self.BuffCache[params.point][params.posId][params.buffId] then
                            if params.uniqueId then
                                return self.BuffCache[params.point][params.posId][params.buffId][params.uniqueId]
                            else
                                return self.BuffCache[params.point][params.posId][params.buffId]
                            end
                        end
                    else
                        return self.BuffCache[params.point][params.posId]
                    end
                end
            else
                return self.BuffCache[params.point]
            end
        end
    end
end

--[[
    确定关联的buff位置
    params:
        point,  displayPoint
        posId,
        buffId
        uniqueId  不传uniqueId表示删除所有同类buff
    return:
        NULL
]]
function LogicData:deleteBuff(params)
    local o_buff = ld.getBuff(params.buffId)
    local buffPoint = checkBuffPoint(o_buff.point1 , o_buff.point2)
    if self.BuffCache[buffPoint] then
        if self.BuffCache[buffPoint][params.posId] then
            if self.BuffCache[buffPoint][params.posId][params.buffId] then
                if params.uniqueId then
                    if self.BuffCache[buffPoint][params.posId][params.buffId][params.uniqueId] then
                        if self.BuffCache[buffPoint][params.posId][params.buffId][params.uniqueId].stateEnum ~= ld.BuffState.eNULL then
                            self:deleteState({
                                posId = params.posId ,
                                state = self.BuffCache[buffPoint][params.posId][params.buffId][params.uniqueId].stateEnum,
                                uniqueId = params.uniqueId,
                                buffId = params.buffId
                            })
                            self:deleteLink({
                                posId = self.BuffCache[buffPoint][params.posId][params.buffId][params.uniqueId].fromPos,
                                uniqueId = params.uniqueId
                            })
                        end
                        local atom = self:getRecord():addAtom()
                        atom:addBuff({
                            buffId = params.buffId,
                            uniqueId = params.uniqueId,
                            toPos = params.posId,
                            fromPos = self.BuffCache[buffPoint][params.posId][params.buffId][params.uniqueId].fromPos,
                            type = ld.BuffDisplayState.eDisappear,
                            extend = self.BuffCache[buffPoint][params.posId][params.buffId][params.uniqueId].extend,
                        })
                    end
                    self.BuffCache[buffPoint][params.posId][params.buffId][params.uniqueId] = nil
                else
                    for i , v in ld.pairsByKeys(self.BuffCache[buffPoint][params.posId][params.buffId]) do
                        if v.stateEnum ~= ld.BuffState.eNULL then
                            self:deleteState({
                                posId = params.posId ,
                                state = v.stateEnum,
                                uniqueId = v.uniqueId,
                                buffId = params.buffId
                            })
                            self:deleteLink({
                                posId = v.fromPos,
                                uniqueId = v.uniqueId
                            })
                        end
                        local atom = self:getRecord():addAtom()
                        atom:addBuff({
                            buffId = params.buffId,
                            uniqueId = v.uniqueId,
                            toPos = params.posId,
                            fromPos = v.fromPos,
                            type = ld.BuffDisplayState.eDisappear,
                            extend = v.extend,
                        })
                    end
                    self.BuffCache[buffPoint][params.posId][params.buffId] = {}
                end
            end
        end
    end
end

--[[
    params:
        posId
        state
        uniqueId
        buffId
        point
    return:
        NULL
]]
function LogicData:addState(params)
    self.BuffState[params.posId] = self.BuffState[params.posId] or {}
    self.BuffState[params.posId][params.state] = self.BuffState[params.posId][params.state] or {}
    table.insert(self.BuffState[params.posId][params.state] , {
        uniqueId = params.uniqueId ,
        buffId = params.buffId,
        point = params.point
    })
end

--[[
    params:
        posId
        state
        uniqueId
        buffId
    return:
        NULL
]]
function LogicData:deleteState(params)
    if self.BuffState[params.posId] then
        if self.BuffState[params.posId][params.state] then
            for i , v in ipairs(self.BuffState[params.posId][params.state]) do
                if params.uniqueId == v.uniqueId then
                    table.remove(self.BuffState[params.posId][params.state] , i)
                    return
                end
            end
        end
    end
end

--[[
    params:
        posId
        state
    return:
        bool
]]
function LogicData:checkState(params)
    if self.BuffState[params.posId] and self.BuffState[params.posId][params.state] then
        return #self.BuffState[params.posId][params.state] > 0
    end
    return false
end

--检查人物能否普攻
function LogicData:checkNAEnable(posId)
    local hero = self:getHero(posId)
    --死亡
    if not hero:checkAlive() then
        return false
    end
    --晕眩
    if self:checkState({posId = posId , state = ld.BuffState.eBanAct}) then
        return false
    end
    --冰冻
    if self:checkState({posId = posId , state = ld.BuffState.eFreeze}) then
        return false
    end
    --麻痹
    if self:checkState({posId = posId , state = ld.BuffState.eBanNA}) then
        return false
    end
    return true
end

--检查人物能否技攻
function LogicData:checkRAEnable(posId)
    local hero = self:getHero(posId)
    --死亡
    if not hero:checkAlive() then
        return false
    end
    --晕眩
    if self:checkState({posId = posId , state = ld.BuffState.eBanAct}) then
        return false
    end
    --冰冻
    if self:checkState({posId = posId , state = ld.BuffState.eFreeze}) then
        return false
    end
    --沉默
    if self:checkState({posId = posId , state = ld.BuffState.eBanRA}) then
        return false
    end
    --怒气值足够
    local skill = ld.getSkill(self:checkCombo(posId) or hero.RAId)
    if hero.RP < skill.useRP then
        return false
    end
    return true
end

-- 查找幻化id
function LogicData:getIllusionModelId(figureName)
    require("Config.IllusionModel")
    require("Config.HeroFashionRelation")
    for _, v in pairs(IllusionModel.items) do
        if v.largePic == figureName then
            return v.modelId
        end
    end
    for _, v in pairs(HeroFashionRelation.items) do
        if v.largePic == figureName then
            return v.modelId
        end
    end
    return 0
end

-- 查找珍兽升级相关信息
function LogicData:getZhenShouLevelInfo(modelId, stepLevel)
    require("Config.ZhenshouStepupModel")

    local zhenShouData = ZhenshouStepupModel.items[modelId]

    if zhenShouData and zhenShouData[stepLevel] then
        return zhenShouData[stepLevel]
    end

    return nil
end

--检查人物是否满足合体技
function LogicData:checkCombo(posId)
    if self.params.ProjectName == "project_sanguo" or
        self.params.ProjectName == "project_shediao" then
        local hero = self:getHero(posId)
        require("Config.HeroModel")
        require("Config.HeroJointModel")
        require("Config.IllusionModel")
        
        hero.IllusionModelId = self:getIllusionModelId(hero.LargePic)
        -- 有幻化将时
        if hero and hero.IllusionModelId and hero.IllusionModelId ~= 0 then
            --是否有合体技
            if IllusionModel.items[hero.IllusionModelId] and IllusionModel.items[hero.IllusionModelId].jointID and IllusionModel.items[hero.IllusionModelId].jointID ~= 0 then
                local tmp = HeroJointModel.items[IllusionModel.items[hero.IllusionModelId].jointID]
                if tmp and tmp.mainHeroID == hero.IllusionModelId then
                    for i , v in pairs(self:getHeroList()) do
                        if (ld.getStandType(v.idx) == ld.getStandType(posId)) and v:checkAlive() then
                            v.IllusionModelId = self:getIllusionModelId(v.LargePic)
                            if tmp.aidHeroID == 0 then
                                --主角
                                if HeroModel.items[v.HeroModelId] and (HeroModel.items[v.HeroModelId].specialType == 255) then
                                    return tmp.jointSkillID
                                end
                            elseif v.IllusionModelId == tmp.aidHeroID then
                                return tmp.jointSkillID
                            end
                        end
                    end
                end
            end
        -- 正常
        elseif hero and HeroModel.items[hero.HeroModelId] then
            --是否有合体技
            if HeroModel.items[hero.HeroModelId].jointID ~= 0 then
                local tmp = HeroJointModel.items[HeroModel.items[hero.HeroModelId].jointID]
                if tmp and tmp.mainHeroID == hero.HeroModelId then
                    for i , v in pairs(self:getHeroList()) do
                        if (ld.getStandType(v.idx) == ld.getStandType(posId)) and v:checkAlive() then
                            if tmp.aidHeroID == 0 then
                                --主角
                                if HeroModel.items[v.HeroModelId] and (HeroModel.items[v.HeroModelId].specialType == 255) then
                                    return tmp.jointSkillID
                                end
                            elseif v.HeroModelId == tmp.aidHeroID and (not v.IllusionModelId or (v.IllusionModelId == 0)) then
                                return tmp.jointSkillID
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

--[[
    params:
        posId,当前位置
        ------------
        point,
        tpos
        buffId
        uniqueId    确定关联的buff位置
    return:
        NULL
]]
function LogicData:addLink(params)
    self.BuffLinked = self.BuffLinked or {}
    self.BuffLinked[params.posId] = self.BuffLinked[params.posId] or {}
    self.BuffLinked[params.posId][params.uniqueId] = clone(params)
end

--[[
    params:
        posId,
        uniqueId
    return:
        NULL
]]
function LogicData:deleteLink(params)
    if self.BuffLinked and self.BuffLinked[params.posId]
        and self.BuffLinked[params.posId][params.uniqueId] then
        self.BuffLinked[params.posId][params.uniqueId] = nil
    end
end

return LogicData
