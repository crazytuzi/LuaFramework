-- 补给舰相关技能逻辑
local tenderSkill = {
    data = nil,
    -- 客户端战前播放的技能,加入到bfs中返给客户端
    preSkillsCfg = {
        cb=true,cc=true,cd=true,cg=true,ch=true
    }
}

-- 补给舰的技能的配置(加了个方法是为了开发时代码检测能过)
local tenderSkillCfg
local function getTenderSkillCfg()
    if not tenderSkillCfg then
        tenderSkillCfg = getConfig("tenderSkill").skill
    end
    return tenderSkillCfg
end

--[[
    计算攻击方部队的补给舰技能加成,这里只会调用攻击方在开火前需要实时计算的技能
    param attackTroop 开火的部队
    param targetTroop 被攻击的部队
    param attackTroops 开火方的所有部队
    param targetTroops  被攻击方的所有部队
    param attackerSlot  开火的部队所在的槽位
    param targetSlot    被攻击的槽位
    param round  当前回合数
    param targets 本次开火部队的所有目标槽位
]]
function tenderSkill.skill(attackTroop,targetTroop,attackTroops,targetTroops,attackerSlot,targetSlot,round,targets)
    if attackTroop.tenderSkill and attackTroop.tenderSkill ~= 0 then
        local skillCfg = tenderSkillCfg[attackTroop.tenderSkill]
        if tenderSkill[skillCfg.ability] then
            tenderSkill.data = {
                attackTroop = attackTroop,
                targetTroop = targetTroop,
                attackTroops = attackTroops,
                targetTroops = targetTroops,
                attackerSlot = attackerSlot,
                targetSlot = targetSlot,
                targets = targets,
                round = round,
            }
            tenderSkill[skillCfg.ability](tenderSkill,skillCfg)
            tenderSkill.data = nil
        end
    end
end

-- 格式化补给舰技能的战报格式
-- 技能,回合,位置(*是全体),敌我(0是无死亡,我方是1,敌是2),5死亡的位置
function tenderSkill.formatReport( ... )
    return table.concat({...},"-")
end

--[[
    补给舰技能显示战报
    有些技能生效时同时影响一批/全部,单独拎出来放在这了
    param report 战报
    param sid 技能id
    param attackTroops 我方的所有部队
    param oriAttackTroops 我方的原始部队数据
    param targetTroops 敌对方的所有部队
    param round 当前回合
    param diedSlot 战斗死亡位置
]]
function tenderSkill.report(report,sid,attackTroops,oriAttackTroops,targetTroops,round,diedSlot)
    local skillCfg = tenderSkillCfg[sid]
    if not skillCfg then return end

    diedSlot = diedSlot or 0

    -- cf 敌方未上阵{11}或该类型战舰被击毁时，己方{10}的{1}提升{2}。
    if skillCfg.ability == "cf" then
        -- 只要生效后就一直生效,所以这里判断report[1]是否存在
        if not report[1] then   
            for k,v in pairs(targetTroops) do
                if v.num and v.num > 0 and v.type == skillCfg.enemyType then return end
            end

            local showPos = 0
            for k,v in pairs(attackTroops) do
                if v.num and v.num > 0 and v.type == skillCfg.tankType then
                    showPos = bit32.bor(showPos,bit32.lshift(1,k-1))
                end
            end

            report[1] = tenderSkill.formatReport(string.upper(skillCfg.ability),round,showPos,2,diedSlot)
        end

    -- 己方部队增加已被消灭部队数量*V%的XX属性。
    elseif skillCfg.ability == "ci" then
        -- 只要生效后就一直生效,所以这里判断report[1]是否存在
        if not report[1] then
            for k,v in pairs(oriAttackTroops) do
                if v.num and v.num > 0 and attackTroops[k].num == 0 then
                    report[1] = tenderSkill.formatReport(string.upper(skillCfg.ability),round,"*",1,diedSlot)
                end
            end
        end

    -- 己方部队存在全部类型船时，全体部队获得V1%*最低船数量/V2的XX属性。
    elseif skillCfg.ability == "cj" then
        local n = 0
        for k,v in pairs(attackTroops) do
            if v.num and v.num > 0 then n = bit32.bor(n,v.type) end
        end

        if n == 15 then
            if not report[1] then
                report[1] = tenderSkill.formatReport(string.upper(skillCfg.ability),round,"*",1,diedSlot)
            end
        else
            if report[1] then
                report[2] = tenderSkill.formatReport(skillCfg.ability,round,"*",1,diedSlot)
            end
        end

    -- 己方全体部队增加V1%*XX类型船中最低船数量/V2的XX属性。
    elseif skillCfg.ability == "ck" then
        local hasType
        for k,v in pairs(attackTroops) do
            if v.num and v.num > 0 and v.type == skillCfg.tankType then
                hasType = true
                break
            end
        end

        if hasType then
            if not report[1] then
                report[1] = tenderSkill.formatReport(string.upper(skillCfg.ability),round,"*",1,diedSlot)
            end
        else
            if report[1] then
                report[2] = tenderSkill.formatReport(skillCfg.ability,round,"*",1,diedSlot)
            end
        end
    -- 己方全体部队增加V1%*XX类型船中最低船数量/V2的XX属性。
    elseif skillCfg.ability == "co" then
        if not report[1] then
            report[1] = tenderSkill.formatReport(string.upper(skillCfg.ability),round,"*",0,diedSlot)
        end
    end
end

-- 计算加成的属性值
-- return value1, reCalcHp 是否需要刷新总血量
function tenderSkill.calcAttr(baseValue,attrValue,attrName)
    if attrName == 'dmg' then
        return baseValue * (1 + attrValue)
    elseif attrName == 'dmg_reduce' then 
        return baseValue * (1/(1+attrValue))
    elseif attrName == "maxhp" then
        return math.floor(baseValue * (1 + attrValue)), true
    else
        return baseValue + attrValue
    end
end

-- 计算减少的属性值
-- 不支持减伤操作
function tenderSkill.calcDeAttr(baseValue,attrValue,attrName)
    local val
    if attrName == 'dmg' then
        val =  baseValue * (1 - attrValue)
    else
        val = baseValue - attrValue
    end

    if val < 0 then val = 0 end

    return val
end

-- 获取攻击部队(本次开火的部队)
function tenderSkill:getAttackTroop()
    return self.data.attackTroop
end

-- 获取目标部队(本次被攻击的)
function tenderSkill:getTargetTroop()
    return self.data.targetTroop
end

-- 首轮开始增加己方部队伤害，前N轮分别对应N个值。
function tenderSkill:cb(skillCfg)
    local round = self.data.round
    if round <= skillCfg.turn and skillCfg.value[round] then
        local troop = self:getAttackTroop()
        troop.dmg = troop.dmg * (1 + skillCfg.value[round])
    end
end

-- 提高己方部队XX类型船对敌方部队XX类型船的伤害V%。
function tenderSkill:ce(skillCfg)
    local attackTroop = self:getAttackTroop()
    local targetTroop = self:getTargetTroop()
    if attackTroop.type == skillCfg.tankType and targetTroop.type == skillCfg.enemyType then
        attackTroop.dmg = attackTroop.dmg * (1+skillCfg.value)
    end
end

-- 当敌方部队没有XX类型船时，己方部队XX类型船增加攻击V%。
-- 当已方有部队被击杀为0时，刷一下对方的(全场共12只部队,最多刷11次)
function tenderSkill:buffCf(sid,attackTroops,targetTroops)
    local skillCfg = tenderSkillCfg[sid]
    if not skillCfg or skillCfg.ability ~= "cf" then
        return
    end

    -- 敌方是否有该类坦克
    for k,v in pairs(targetTroops) do
        if v.num and v.num > 0 and v.type == skillCfg.enemyType then return end
    end

    for k,v in pairs(attackTroops) do
        if v.num and v.num > 0 and v.type == skillCfg.tankType then
            v.dmg = v.dmg * (1+skillCfg.value)
        end
    end
end

-- 己方部队首轮减少XX属性V1%，从第二轮开始XX属性增加V2%，持续N轮。
function tenderSkill:cg(skillCfg)
    if self.data.round <= skillCfg.turn then
        local troop = self:getAttackTroop()
        if self.data.round == 1 then
            if troop[skillCfg.attType[1]] then
                troop[skillCfg.attType[1]] = tenderSkill.calcDeAttr(troop[skillCfg.attType[1]],skillCfg.value[1],skillCfg.attType[1])
            end
        else
            if troop[skillCfg.attType[2]] then
                troop[skillCfg.attType[2]] = self.calcAttr(troop[skillCfg.attType[2]],skillCfg.value[2],skillCfg.attType[2])
            end
        end
    end
end

-- 己方部队首轮增加XX属性V1%，从第二轮开始XX属性减少V2%，持续N轮。
function tenderSkill:ch(skillCfg)
    if self.data.round <= skillCfg.turn then
        local troop = self:getAttackTroop()
        if self.data.round == 1 then
            if troop[skillCfg.attType[1]] then
                troop[skillCfg.attType[1]] = self.calcAttr(troop[skillCfg.attType[1]],skillCfg.value[1],skillCfg.attType[1])
            end
        else
            if troop[skillCfg.attType[2]] then
                troop[skillCfg.attType[2]] = self.calcDeAttr(troop[skillCfg.attType[2]],skillCfg.value[2],skillCfg.attType[2])
            end
        end
    end
end

-- 己方部队增加已被消灭部队数量*V%的XX属性。
-- 增加的属性是永久性的，当我方部队死亡时，调此方法一次即可
function tenderSkill:buffCi(sid,troops,oriTroops)
    local skillCfg = tenderSkillCfg[sid]
    if not skillCfg or skillCfg.ability ~= "ci" then
        return
    end

    local n = 0
    for k,v in pairs(oriTroops) do
        if v.num and v.num > 0 then
            if troops[k].num == 0 then
                n = n + 1
            end
        end
    end

    -- 所有部队增加n倍的属性
    if n > 0 then
        for k,v in pairs(troops) do
            if v[skillCfg.attType] then
                v[skillCfg.attType] = self.calcAttr(v[skillCfg.attType],skillCfg.value*n,skillCfg.attType)
            end
        end
    end
end

--己方部队存在全部类型船时，全体部队获得V1%*最低船数量/V2的XX属性。
function tenderSkill:cj(skillCfg)
    local n = 0
    local m
    for k,v in pairs(self.data.attackTroops) do
        if v.num and v.num > 0 then
            n = bit32.bor(n,v.type)
            if not m or (v.num < m) then
                m = v.num
            end
        end
    end

    if n == 15 and m then
        local troop = self:getAttackTroop()
        if troop[skillCfg.attType] then
            local value = skillCfg.value[1] * m / skillCfg.value[2]
            troop[skillCfg.attType] = self.calcAttr(troop[skillCfg.attType],value,skillCfg.attType)
        end
    end
end

--己方全体部队增加V1%*XX类型船中最低船数量/V2的XX属性。
function tenderSkill:ck(skillCfg)
    local m
    for k,v in pairs(self.data.attackTroops) do
        if v.num and v.num > 0 and v.type == skillCfg.tankType then
            if not m or v.num < m then
                m = v.num
            end
        end
    end

    if m then
        local troop = self:getAttackTroop()
        if troop[skillCfg.attType] then
            local value = skillCfg.value[1] * m / skillCfg.value[2]
            troop[skillCfg.attType] = self.calcAttr(troop[skillCfg.attType],value,skillCfg.attType)
        end
    end
end

-- 己方XX类型船的首个目标（其实就是给潜艇做的）船数大于自己的船数时，增加V%的XX属性
function tenderSkill:cl(skillCfg)
    local attackTroop = self:getAttackTroop()
    if attackTroop.type == skillCfg.tankType then
        local targetTroop = self:getTargetTroop()
        if targetTroop.num and targetTroop.num > attackTroop.num then
            attackTroop[skillCfg.attType] = self.calcAttr(attackTroop[skillCfg.attType],skillCfg.value,skillCfg.attType)
        end
    end
end

--己方XX类型船的对位船数小于自己船数时，增加V%的XX属性
function tenderSkill:cm(skillCfg)
    local attackTroop = self:getAttackTroop()
    if attackTroop.type == skillCfg.tankType then
        local targetTroop = self.data.targetTroops[self.data.attackerSlot]

        -- 对位无部队时直接触发/对位部队小于自己
        if not targetTroop.num or targetTroop.num < attackTroop.num then
            attackTroop[skillCfg.attType] = self.calcAttr(attackTroop[skillCfg.attType],skillCfg.value,skillCfg.attType)
        end
    end
end

--己方XX类型船的目标船数之和小于自己船数时，增加V%的XX属性
function tenderSkill:cn(skillCfg)
    local attackTroop = self:getAttackTroop()
    if attackTroop.type == skillCfg.tankType then
        local n = 0
        for k,v in pairs(self.data.targets) do
            if self.data.targetTroops[k] and self.data.targetTroops[k].num then
                n = n + self.data.targetTroops[k].num
            end
        end

        if attackTroop.num > n then
            if attackTroop[skillCfg.attType] then
                attackTroop[skillCfg.attType] = self.calcAttr(attackTroop[skillCfg.attType],skillCfg.value,skillCfg.attType)
            end
        end
    end
end

--增加己方前排部队XX属性，增加己方后排部队XX属性。
function tenderSkill:buffCo(sid,troops)
    local skillCfg = tenderSkillCfg[sid]
    if not skillCfg or skillCfg.ability ~= "co" then
        return
    end

    local isHp
    for k,v in pairs(troops) do
        if v.num and v.num > 0 then
            if k <= 3 then
                v[skillCfg.attType[1]],isHp = tenderSkill.calcAttr(v[skillCfg.attType[1]],skillCfg.value[1],skillCfg.attType[1])
            else
                v[skillCfg.attType[2]],isHp = tenderSkill.calcAttr(v[skillCfg.attType[2]],skillCfg.value[2],skillCfg.attType[2])
            end

            if isHp then
                v.hp = v.maxhp * v.num  --重算最大血量
            end
        end
    end
end

--------------------------------------------------------

--[[
    attacker 进攻者
    defender 防守方
    attSeq 攻击秩序 1是防守者先攻击, 扩展 11是不通过先手值计算直接指定防守方先攻击(10是攻击方)
    attPropsConsume 攻击者的道具消耗品

    return 
        self.report     战报
        result  战争结果,相对于进攻方而言
        self.attacker 攻击方剩余部队情况
        self.defender 防守方剩余部队情况
--]]

function battle(attacker,defender,attSeq,attPropsConsume,arguments)
    local string = string
    arguments = arguments or {}

    -- 攻击方标识
    local ATTACKER_FLAGS = 1
    -- 防守方标识
    local DEFENDER_FLAGS = 2
    -- 前排代号
    local FRONT_ROW = 1
    -- 后排代号
    local BACK_ROW = 2

    -- 所有要返的数据丢这里返回
    local rtnData = {}

    -- 飞机配置
    local planeCfg = nil
    local planeSkillCfg = nil

    local self = {
        attacker = attacker,
        defender = defender,
        originalAttacker={},
        originalDefender={},
        originalAttackerHpInfo={}, -- 存放原始血量信息(历史遗留问题,originalAttacker 没有记下血量信息,怕改出问题)
        originalDefenderHpInfo={},
        attSeq = attSeq,
        attSeqPoint = {first=0,antifirst=0},
        defSeqPoint = {first=0,antifirst=0},
        attPlane = nil,
        defPlane = nil,
        -- 角色先手信息
        roleFirstAttackInfo = {},
        attPropsConsume=attPropsConsume or {},
        round = 1,
        roundEvade = false,        
        report={},
        fjreport={},
        debug={},
        deBossHp=0,  -- boss 损失的生命
        defenderLossHpCount = {0,0,0,0,0,0}, -- 防守方扣血统计
        relative={--兵种相克
            [1]={[1]=0,[2]=0,[4]=0,[8]=25,[10]=0,[12]=0,[14]=0,[16]=-15,[18]=15,[20]=0,[22]=0,[24]=0,[26]=0,[28]=0,[30]=-20,[32]=15,},
            [2]={[1]=25,[2]=0,[4]=-20,[8]=0,[10]=0,[12]=0,[14]=0,[16]=-15,[18]=0,[20]=0,[22]=0,[24]=15,[26]=0,[28]=0,[30]=25,[32]=0,},
            [4]={[1]=-20,[2]=25,[4]=0,[8]=0,[10]=0,[12]=0,[14]=0,[16]=-15,[18]=0,[20]=0,[22]=15,[24]=-20,[26]=0,[28]=15,[30]=0,[32]=0,},
            [8]={[1]=0,[2]=-20,[4]=25,[8]=0,[10]=0,[12]=0,[14]=0,[16]=-15,[18]=0,[20]=0,[22]=-20,[24]=0,[26]=0,[28]=-20,[30]=0,[32]=0,},
            [10]={[1]=0,[2]=0,[4]=0,[8]=0,[10]=0,[12]=50,[14]=0,[16]=0,[18]=0,[20]=0,[22]=15,[24]=-15,[26]=0,[28]=15,[30]=0,[32]=0,},
            [12]={[1]=25,[2]=25,[4]=25,[8]=25,[10]=-20,[12]=0,[14]=0,[16]=0,[18]=0,[20]=0,[22]=0,[24]=15,[26]=0,[28]=0,[30]=25,[32]=0,},
            [14]={[1]=0,[2]=0,[4]=0,[8]=0,[10]=0,[12]=0,[14]=0,[16]=50,[18]=0,[20]=0,[22]=15,[24]=-15,[26]=0,[28]=15,[30]=0,[32]=0,},
            [16]={[1]=0,[2]=0,[4]=0,[8]=0,[10]=0,[12]=0,[14]=-20,[16]=0,[18]=0,[20]=0,[22]=0,[24]=0,[26]=0,[28]=0,[30]=-20,[32]=0,},
            [18]={[1]=0,[2]=-15,[4]=25,[8]=0,[10]=0,[12]=0,[14]=0,[16]=0,[18]=0,[20]=0,[22]=-15,[24]=0,[26]=0,[28]=-15,[30]=0,[32]=0,},
            [20]={[1]=0,[2]=0,[4]=0,[8]=0,[10]=0,[12]=0,[14]=0,[16]=0,[18]=0,[20]=0,[22]=0,[24]=0,[26]=0,[28]=0,[30]=-20,[32]=0,},
            [22]={[1]=50,[2]=0,[4]=-15,[8]=0,[10]=-15,[12]=0,[14]=-15,[16]=35,[18]=0,[20]=0,[22]=0,[24]=35,[26]=0,[28]=0,[30]=25,[32]=0,},
            [24]={[1]=0,[2]=0,[4]=0,[8]=50,[10]=0,[12]=0,[14]=0,[16]=0,[18]=35,[20]=0,[22]=0,[24]=0,[26]=0,[28]=0,[30]=-20,[32]=35,},
            [26]={[1]=0,[2]=0,[4]=0,[8]=0,[10]=0,[12]=0,[14]=0,[16]=0,[18]=0,[20]=0,[22]=0,[24]=0,[26]=0,[28]=0,[30]=0,[32]=0,},
            [28]={[1]=25,[2]=0,[4]=-15,[8]=0,[10]=-15,[12]=0,[14]=-15,[16]=25,[18]=0,[20]=0,[22]=0,[24]=25,[26]=0,[28]=0,[30]=25,[32]=0,},
            [30]={[1]=25,[2]=-20,[4]=0,[8]=0,[10]=0,[12]=-20,[14]=0,[16]=25,[18]=0,[20]=0,[22]=-20,[24]=25,[26]=0,[28]=-20,[30]=-50,[32]=0,},
            [32]={[1]=0,[2]=-15,[4]=25,[8]=25,[10]=0,[12]=0,[14]=0,[16]=0,[18]=15,[20]=0,[22]=-15,[24]=0,[26]=0,[28]=-15,[30]=0,[32]=15,},
            },  
        baseMutualBuff={
            [1]={
            opponentType=0,--所有己方部队
            buff={"dmg"},--伤害增加
            },
            [2]={
            opponentType=0,--所有己方部队
            buff={"crit"},--暴击增加
            },
            [4]={
            opponentType=0,--所有敌方部队
            buff={"dmg_reduce"},--伤害减少
            },
            [8]={
            effectType=2,--1是作用于自己,2是作用于敌人
            opponentType={[8]=1},--敌方火箭车
            buff={"dmg_reduce"},--伤害减少
            },
            [10]={
            opponentType=0,--所有己方部队
            buff={"evade"},--闪避增加
            },
            [12]={
            opponentType=0,--所有己方部队
            buff={"accuracy"},--命中增加
            },
            [14]={
            opponentType=0,--所有己方部队
            buff={"arp"},--击破增加
            },
            [16]={
            opponentType=0,--所有己方部队
            buff={"armor"},--防护增加
            },
            [18]={
            opponentType=0,--所有敌方部队
            buff={"evade_reduce"},--闪避减少
            },
            [20]={
            opponentType=0,--所有己方部队
            buff={"anticrit"},--装甲增加
            },
            [22]={
            opponentType=0,--所有己方部队
            buff={"dmg"},--伤害增加
            },
            [24]={
            opponentType=0,--所有敌方部队
            buff={"dmg_reduce"},--伤害减少
            },
            [26]={--世界boss占位
            },
            [28]={
            effectType=1,--1是作用于自己,2是作用于敌人
            opponentType={[2]=1},--已方歼击车
            buff={"dmg"},--伤害增加
            },
            [30]={
            effectType=2,--1是作用于自己,2是作用于敌人
            opponentType={[1]=1},--敌方坦克车
            buff={"dmg_reduce"},--伤害增加
            },
            [32]={
            opponentType=0,--我方所有部队
            buff={"anticrit_reduce"},--敌方装甲减少
            },
        },


        abilityCfg = {},    -- 技能配置
        buffValueCfg={},    -- buff提供的加成值,a10032=0.1
        metric={}, -- 统计
        attackerBuff={aw={} }, -- 全局光环buff(aw=异星武器 每个回合刷新buff，可以统一放到这里) 
        defenderBuff={aw={} }, -- 全局光环buff
    }

    -- 配件技能属性加成
    local accessorySkillAttributeCfg = {
        aa = {"dmg_reduce"},
        ae = {"dmg"},
        ai = {"evade"},
        am = {"crit"},
    }

    -- 部队位置对应的排
    local troopSlotToRow = {[1]=FRONT_ROW,[2]=FRONT_ROW,[3]=FRONT_ROW,[4]=BACK_ROW,[5]=BACK_ROW,[6]=BACK_ROW}

    ------------------------------------------------------------------------------------------------------
    -- 异星科技会给原来没有坦克技能的一批坦克加上技能，
    -- 如果这个坦克的技能效果前端能直接展示,后端就没有在战斗数据中返回，
    -- 那么，需要单独告诉前端，哪些坦克会有这些额外技能
    local alienTechAddAbilityIdTanks = {
        a10073=true,a10082=true,a10093=true,a10133=true,a10143=true,a10163=true,
        --改造坦克
        a20073=true,a20082=true,a20093=true,a20133=true,a20143=true,
        --普通坦克 精英
        a50073=true,a50082=true,a50093=true,a50133=true,a50143=true,a50163=true,
        --改造坦克 精英
        a60073=true,a60082=true,a60093=true,a60133=true,a60143=true,
    }
    
    -- ability里有的技能显示逻辑放在前端自己处理,需要返加技能ID
    local reportAb
    -- 给客户端显示的飞机信息
    local planeForClient = nil
    -- 给客户端显示的补给舰信息
    local tenderInfo = {
        skill={
            [ATTACKER_FLAGS]=nil,
            [DEFENDER_FLAGS]=nil
        },
        ability={
            [ATTACKER_FLAGS]=nil,
            [DEFENDER_FLAGS]=nil
        },
        report={
            [ATTACKER_FLAGS]={},
            [DEFENDER_FLAGS]={}
        },
        info={
            [ATTACKER_FLAGS]=nil,
            [DEFENDER_FLAGS]=nil
        }
    }

    -- 统计信息(前端展示)
    local statsReport = {
        dmg={[ATTACKER_FLAGS]=0,[DEFENDER_FLAGS]=0}, -- 伤害值
        loss={}, -- 损失坦克数
    }

    -- 记录双方携带的
    local attackerDebuffs = {
        dedouble_hit = {},
    }
    local defenderDebuffs = {
        dedouble_hit = {},
    }

    --[[
        所有坦克按type归类后的数量
        某些技能的触发条件要求场上某类坦克数量达到一定值
    ]]
    local allTroopCount = {
        [ATTACKER_FLAGS]={},
        [DEFENDER_FLAGS]={},
    }

    --[[
        按type统计该type类型的组数(一共6组)
        某些技能的触发条件要求场上6组中坦克至少是该类型的达到多少组
    ]]
    local allTypeCount = {
        [ATTACKER_FLAGS]={},
        [DEFENDER_FLAGS]={},
    }

    local function setAllTroopCount(role,tType,count)
        allTroopCount[role][tType] = (allTroopCount[role][tType] or 0) + count
        if allTroopCount[role][tType] < 0 then allTroopCount[role][tType] = 0 end
    end

    local function getAllTroopCount(role,tType)
        return allTroopCount[role][tType] or 0
    end

    -- 根据角色(进攻/防守)获取对应的部队信息
    local function getTroopsInfoByRole(role)
        if role == ATTACKER_FLAGS then
            return self.attacker
        elseif role == DEFENDER_FLAGS then
            return self.defender
        end
    end

    -- 设置补给舰的相关信息
    local function setTenderInfo(role,info,skill)
        if not tenderInfo.info[role] then
            tenderInfo.info[role] = info or 0
            if skill and skill ~= 0 then
                -- 技能id
                tenderInfo.skill[role] = skill
                -- 技能对应的abilityId
                local tenderSkillCfg = getTenderSkillCfg()
                tenderInfo.ability[role] = tenderSkillCfg[skill].ability
            end
        end
    end

    -- 根据角色(进攻/防守)获取对应的原始部队信息
    local function getOriginalTroopsInfoByRole(role)
        if role == ATTACKER_FLAGS then
            return self.originalAttacker
        elseif role == DEFENDER_FLAGS then
            return self.originalDefender
        end
    end

    -- 记录当前回合的一些数据,每个回合开始之前必须清空
    local tmpRoundVars = {}

    -- 重置每回合的临时数据
    local function resetRoundVars()
        tmpRoundVars = {}
    end

    -- 按key存放回合数据
    local function setRoundVars(key,value)
        tmpRoundVars[key] = value
    end

    -- 获取回合数据中指定的key对应的数据
    local function getRoundVars(key,default)
        return tmpRoundVars[key] or default
    end

    -- 创建飞机信息
    local function createPlane(info,role,erole)
        if type(info) ~= "table" then return end

        if not planeCfg then
            planeCfg = getConfig("planeCfg")
            planeSkillCfg = planeCfg.skillCfg
        end

        if planeCfg.plane[info[1]] then
            if not planeForClient then 
                planeForClient = {{},{}}
            end

            planeForClient[role] = {info[1]}

            local skills = type(info[2]) == "table" and info[2] or {}

            for _,sid in pairs(skills) do
                if planeSkillCfg[sid].isPassive == 1 then
                    planeForClient[role][2] = sid
                end
            end

            return {
                id = info[1],
                skills = skills,
                dmg = 0,
                hp = 0,
                energy = 1,
                type = 16,
                atk = planeCfg.plane[info[1]].atk,
                role = role,
                erole = erole,
                isPlane = 1,
                level = info[3],--这是飞机等级
            }
        end
    end

    -- 设置飞机伤害值
    -- param int dmg 伤害值可以为正/负
    local function setPlaneDmg(plane,dmg)
        if plane then 
            plane.dmg = plane.dmg + math.floor(dmg * plane.atk)

            -- 这里的伤害修正值会在每次坦克数量减少时修正,防止减为0
            if plane.dmg <= 0 then plane.dmg = 1 end
        end
    end

    -- 设置飞机血量
    local function setPlaneHp(plane,hp)
        if plane then plane.hp = plane.hp + hp end
    end

    -- 设置飞机能量值
    -- param int energy 可以为正/负值
    local function setPlaneEnergy(plane,energy)
        if plane then 
            plane.energy = plane.energy + energy
            if plane.energy <= 0 then
                plane.energy = 0
            elseif plane.energy > planeCfg.plane[plane.id].energy then
                plane.energy = planeCfg.plane[plane.id].energy
            end
        end
    end

    local function setOriginalAttacker()
        local tmpAb = {}
        for k,v in pairs(self.attacker) do

            self.originalAttacker[k] = {}
            self.originalAttackerHpInfo[k] = {}
            if next(v) then
                for m,n in pairs(v) do
                    if m~='maxhp' and m~='hp' then
                        self.originalAttacker[k][m] = n
                    end
                end

                self.originalAttackerHpInfo[k].num = v.num

                if v.id then self.buffValueCfg[v.id] = v.buffvalue end

                -- 攻击方在右
                if alienTechAddAbilityIdTanks[v.id] and not tmpAb[v.id] and (tonumber(v.abilityLv) or 0) > 0  then 
                    if not reportAb then reportAb = {{},{}} end
                    if not reportAb[2][v.abilityID] then reportAb[2][v.abilityID] = {} end
                    table.insert(reportAb[2][v.abilityID],v.id)
                    tmpAb[v.id] = true
                end

                -- 新增的先手值属性,需要累加所有部队的先手值
                if (v.first or 0) > 0 then
                    self.attSeqPoint.first = self.attSeqPoint.first + v.first
                end
                if (v.antifirst or 0) > 0 then
                    self.attSeqPoint.antifirst = self.attSeqPoint.antifirst + v.antifirst
                end

                if v.num and v.num > 0 then
                    setAllTroopCount(ATTACKER_FLAGS,v.type,v.num)
                    allTypeCount[ATTACKER_FLAGS][v.type] =  (allTypeCount[ATTACKER_FLAGS][v.type] or 0) + 1

                    if type(v.plane) == "table" and not self.attPlane then
                        self.attPlane = createPlane(v.plane,ATTACKER_FLAGS,DEFENDER_FLAGS)
                    end

                    setPlaneDmg(self.attPlane,v.num * v.dmg)
                    setPlaneHp(self.attPlane,1)

                    setTenderInfo(ATTACKER_FLAGS,v.tenderInfo,v.tenderSkill)
                end
            end
        end
        tmpAb = nil
    end
    
    local function setOriginalDefender()
        local tmpAb = {}
        for k,v in pairs(self.defender) do
            self.originalDefender[k] = {}
            self.originalDefenderHpInfo[k] = {}

            if next(v) then
                for m,n in pairs(v) do
                    if m~='maxhp' and m~='hp' then
                        self.originalDefender[k][m] = n
                    end
                end

                self.originalDefenderHpInfo[k].hp = v.hp
                self.originalDefenderHpInfo[k].num = v.num

                if v.id then self.buffValueCfg[v.id] = v.buffvalue end

                -- 攻击方在右
                if alienTechAddAbilityIdTanks[v.id] and not tmpAb[v.id] and (tonumber(v.abilityLv) or 0) > 0  then 
                    if not reportAb then reportAb = {{},{}} end
                    if not reportAb[1][v.abilityID] then reportAb[1][v.abilityID] = {} end
                    table.insert(reportAb[1][v.abilityID],v.id)
                    tmpAb[v.id] = true
                end

                -- 新增的先手值属性,需要累加所有部队的先手值
                if (v.first or 0) > 0 then
                    self.defSeqPoint.first = self.defSeqPoint.first + v.first
                end
                if (v.antifirst or 0) > 0 then
                    self.defSeqPoint.antifirst = self.defSeqPoint.antifirst + v.antifirst
                end

                if v.num and v.num > 0 then
                    setAllTroopCount(DEFENDER_FLAGS,v.type,v.num)
                    allTypeCount[DEFENDER_FLAGS][v.type] =  (allTypeCount[DEFENDER_FLAGS][v.type] or 0) + 1

                    if type(v.plane) == "table" and not self.defPlane then
                        self.defPlane = createPlane(v.plane,DEFENDER_FLAGS,ATTACKER_FLAGS)
                    end

                    setPlaneDmg(self.defPlane,v.num * v.dmg)
                    setPlaneHp(self.defPlane,1)

                    setTenderInfo(DEFENDER_FLAGS,v.tenderInfo,v.tenderSkill)
                end
            end
        end
        tmpAb = nil
    end

    local function setTroopsAttributeByDebuffs(troops,debuffs)
        local debuff_value,dedouble_hit

        if debuffs.debuff_value and debuffs.debuff_value > 0 then
            debuff_value = debuffs.debuff_value
        end

        if type(debuffs.dedouble_hit) == 'table' and next(debuffs.dedouble_hit) then
            dedouble_hit = debuffs.dedouble_hit
        end

        if debuff_value or dedouble_hit then
            for k,v in pairs (troops) do
                if next(v) and v.num > 0 then
                    if debuff_value then
                        troops[k].buff_value = (troops[k].buff_value + 1) * debuff_value
                    end

                    if dedouble_hit[v.type] then
                        troops[k].double_hit = troops[k].double_hit - dedouble_hit[v.type]
                        if troops[k].double_hit < 0 then
                            troops[k].double_hit = 0
                        end
                    end
                end
            end
        end
    end

    -- 按防守方的相关减益buff设置攻击方的属性
    -- 连击和光环减少等,直接根据对方的减益值重新设置一次就行，不影响后面的逻辑
    local function setAttackerAttributeByDebuffs()
        setTroopsAttributeByDebuffs(self.attacker,defenderDebuffs)
        setTroopsAttributeByDebuffs(self.originalAttacker,defenderDebuffs)
    end

    local function setDefenderAttributeByDebuffs()
        setTroopsAttributeByDebuffs(self.defender,attackerDebuffs)
        setTroopsAttributeByDebuffs(self.originalDefender,attackerDebuffs)
    end

    -- 坦克技能配置
    local function setAbilityCfg()
        self.abilityCfg = getConfig("ability")
    end

    -- 英雄技能配置
    local function setHeroKillCfg()
        self.heroSkillCfg = getConfig("heroSkillCfg")
    end

    -- 设置伤害统计
    -- TODO 这个给前端纯展示用的,只是算上了开炮的伤害,燃烧效果没有加
    local function setDmgStats(dmg,role)
        statsReport.dmg[role] = statsReport.dmg[role] + dmg
    end

    -- 获取配件技能等级，要兼容跨服战等玩家已经保存好的老数据
    -- return abilityLv|nil 
    local function getAccessorySkillLevel(troopInfo,abilityId)
        return type(troopInfo.accessorySkill) == 'table' and troopInfo.accessorySkill[abilityId]
    end

    -- 获取用户新技能等级，要兼容跨服战等玩家已经保存好的老数据
    -- return abilityLv|nil 
    local function getPlayerSkillLevel(troopInfo,abilityId)
        return type(troopInfo.playerSkill) == 'table' and troopInfo.playerSkill[abilityId]
    end

    -- 损血统计
    local function countLoseHp()
        for k,v in pairs(self.defender) do
            if next(v) then
                local lossHp = (self.originalDefenderHpInfo[k].hp or 0) - (v.hp or 0)
                self.defenderLossHpCount[k] = self.defenderLossHpCount[k] + lossHp
            end
        end
    end

    -- 获取统计报告
    local function getStatsReport()
        -- 双方战损统计
        local a,d = 0,0
        for k,v in pairs(self.originalAttackerHpInfo) do
            if v.num then a = a + v.num - self.attacker[k].num end
        end

        for k,v in pairs(self.originalDefenderHpInfo) do
            if v.num then d = d + v.num - self.defender[k].num end
        end

        local dmg1 = statsReport.dmg[ATTACKER_FLAGS]
        local dmg2 = statsReport.dmg[DEFENDER_FLAGS]

        -- 先出手的放第1个位置
        if self.attSeq == 1 then
            statsReport.loss = {d,a}
            statsReport.dmg = {dmg2,dmg1}
        else
            statsReport.loss = {a,d}
            statsReport.dmg = {dmg1,dmg2}
        end

        return statsReport
    end

    -- 刷新世界BOSS的坦克数量
    -- 世界BOSS只有一管血，需要按血量计算出6个位置的血量
    local function refreshBossTankNum(target)
        local bosshp = math.floor(self.defender[target].hp)
        
        if bosshp>0 then 
            local troopNum = math.ceil(bosshp * 6  / self.defender[target].bossHp)
            
            if troopNum > 6 then troopNum = 6 end
            for i=1,6-troopNum do
                if arguments.diePaoTou[i] then
                    self.defender[arguments.diePaoTou[i]].hp = 0
                    self.defender[arguments.diePaoTou[i]].num = 0
                end
            end

            for k,v in pairs(self.defender) do
                if v.num > 0 then self.defender[k].hp = bosshp end
            end

            return 1
        else
            for k,v in pairs(self.defender) do
                self.defender[k].hp = 0
                self.defender[k].num = 0
            end

            return 0
        end
    end

    -- 如果是boss直接刷一下部队
    if arguments.boss then
        refreshBossTankNum(1)
    end

    -- 击杀赛地形影响克制关系
    if arguments.killrace then
        for k,v in pairs(arguments.killrace[1]) do
            if self.relative[v] then
                for m,n in pairs(self.relative[v]) do
                    if n > 0 then self.relative[v][m] = self.relative[v][m] * arguments.killrace[2] end
                end
            end
        end
    end

    -- 随机种子
    setRandSeed()
    setOriginalAttacker()
    setOriginalDefender()
    setAbilityCfg()
    setHeroKillCfg()
    getTenderSkillCfg()

    ------------------------------------------------------------------------------------------------------
    -- 英雄加成

    -- 地形对应的技能(conditionType)
    local landform2kill = {1,2,3,4,5,6}

    -- 部队类型对应的技能(conditionType)
    local tanktype2kill = {[1]=26,[2]=27,[4]=28,[8]=29}

    -- 部队产出（是否活动）对应的技能(conditionType)
    local special2kill = {34}

    -- 部队位置（按前后排）对应的技能(conditionType)
    local heroPos2kill = {21,21,21,22,22,22}

    -- 攻击方部队在回合中有效的技能加成属性
    local atkHeroSkillInRound = {dmg=1,accuracy=1,crit=1}

    -- 防守方部队在回合中有效的技能加成属性
    local defHeroSkillInRound = {dmg_reduce=1,evade=1,anticrit=1}

    -- local attType2attribute =  {
    --     [1] = 'first',
    --     [2] = 'antifirst',
    --     [102]='accuracy',
    --     [103]='evade',
    --     [104]='crit',
    --     [105]='anticrit',
    --     [106]='crit',
    --     [107]='anticrit',
    --     [100]='dmg',
    --     [108]='maxhp',
    --     [109]='dmg_reduce'
    -- }

    function self.getHeroSkillBuff(troops)
        local buff = {}
        local seqPoint={first=0,antifirst=0}
        local troopsSkill = {}

        for k,v in pairs(troops) do
            if next(v) and v.num > 0 and v.hero and next(v.hero) then
                troopsSkill[k] = v.hero
            end
        end

        for k,v in pairs(troopsSkill) do
            for _,sinfo in ipairs(v) do 
                local isSet = false            
                local skill = sinfo[1]
                local conditionType = tonumber(self.heroSkillCfg[skill].conditionType)            

                if tonumber(self.heroSkillCfg[skill].effectType) == 0 then
                    if  conditionType == 0 then
                        isSet = true
                    elseif landform2kill[troops[k].landform] == conditionType then
                        isSet = true
                    elseif tanktype2kill[troops[k].type] == conditionType then
                        isSet = true
                    elseif special2kill[troops[k].isSpecial] == conditionType then
                        isSet = true
                    elseif heroPos2kill[k] == conditionType then
                        isSet = true
                    end
                end

                if isSet then
                    if not buff[k] then buff[k] = {} end
                    if tonumber(self.heroSkillCfg[skill].isEffectAll) == 1 then
                        if self.heroSkillCfg[skill].attType == 'first' or self.heroSkillCfg[skill].attType == 'antifirst' then
                            seqPoint[self.heroSkillCfg[skill].attType] = seqPoint[self.heroSkillCfg[skill].attType] + sinfo[2] * self.heroSkillCfg[skill].attValuePerLv
                        else
                            for m,n in pairs(troops) do 
                                if (n.num or 0) > 0 then 
                                    if not buff[m] then buff[m] = {} end
                                    table.insert(buff[m],sinfo)
                                end
                            end
                        end
                    else
                        table.insert(buff[k],sinfo)
                    end
                end
            end
        end

        return buff,seqPoint
    end

    -- 英雄技能是否激活
    function self.heroSkillIsActive(conditionType,ackTroopsInfo,defTroopsInfo)
        local aPos = ackTroopsInfo[2]
        local dPos = defTroopsInfo[2]
        local aTroops = ackTroopsInfo[1]
        local dTroops = defTroopsInfo[1]

        if conditionType == 23 then 
            return self.round == 1 
        end

        if conditionType == 24 then 
            return self.round >= 2 and self.round <= 3  
        end

        if conditionType == 25 then 
            return self.round >= 4 
        end

        if conditionType == 30 then 
            local df = math.abs(aPos - dPos) 
            return df == 3 or df == 0
        end

        if conditionType == 31 then 
            local df = math.abs(aPos - dPos) 
            return df ~= 3 and df ~= 0
        end

        if conditionType == 32 then             
            return aTroops.num > dTroops.num
        end

        if conditionType == 33 then
            return aTroops.num < dTroops.num
        end

        if conditionType == 35 then
            return ((not dTroops.hero) or (not next(dTroops.hero)))
        end

    end

    -- 设置回合中的配件技能buff
    local function setAccessorySkillBuffInRound(troop,abilityBuff)
        if abilityBuff.debuff.ac then
            troop.dmg_reduce = troop.dmg_reduce * (1/(1+abilityBuff.debuff.ac))
        end

        if abilityBuff.buff.ad then
            troop.crit = troop.crit + abilityBuff.buff.ad
        end

        if abilityBuff.debuff.ak then
            troop.crit = troop.crit - abilityBuff.debuff.ak
            if troop.crit < 0 then
                troop.crit = 0
            end
        end

        if abilityBuff.buff.al then
            troop.dmg_reduce = troop.dmg_reduce * (1/(1+abilityBuff.buff.al))
        end

        if abilityBuff.debuff.ao then
            troop.critDmg = troop.critDmg - abilityBuff.debuff.ao
            if troop.critDmg < 0 then
                troop.critDmg = 0
            end
        end

        if abilityBuff.debuff.ap then
            troop.decritDmg = troop.decritDmg - abilityBuff.debuff.ap
            if troop.decritDmg < 0 then
                troop.decritDmg = 0
            end
        end
    end
    

    -- 按回合数获取新的属性效果，有的英雄属性加成只在特定回合后生效
    function self.initTroopsNewAttributeByRound(ackTroopsInfo,defTroopsInfo, isAttacter)
        local ackTroops = {}
        local defTroops = {}

        setmetatable(ackTroops, {__index = ackTroopsInfo[1]})
        setmetatable(defTroops, {__index = defTroopsInfo[1]})

        if ackTroopsInfo[1].hero and next(ackTroopsInfo[1].hero) then
            for _,skillInfo in pairs(ackTroopsInfo[1].hero) do
                local cfg = self.heroSkillCfg[skillInfo[1]]
                if cfg.effectType == 1 and atkHeroSkillInRound[cfg.attType] and self.heroSkillIsActive(cfg.conditionType,ackTroopsInfo,defTroopsInfo) then
                    local buffKey = cfg.attType
                    local buffRate = cfg.attValuePerLv * skillInfo[2]

                    if buffKey == 'dmg' then
                        ackTroops[buffKey] = ackTroops[buffKey] +  ackTroops[buffKey] * buffRate       
                    elseif buffKey == 'accuracy' and buffKey == 'crit' then                                
                        ackTroops[buffKey] = ackTroops[buffKey] + buffRate
                    end
                end 
            end
        end

        if defTroopsInfo[1].hero and next(defTroopsInfo[1].hero) then
            for _,skillInfo in pairs(defTroopsInfo[1].hero) do
                local cfg = self.heroSkillCfg[skillInfo[1]]
                if cfg.effectType == 1 and defHeroSkillInRound[cfg.attType] and self.heroSkillIsActive(cfg.conditionType,defTroopsInfo,ackTroopsInfo) then
                    local buffKey = cfg.attType
                    local buffRate = cfg.attValuePerLv * skillInfo[2]

                    if buffKey == 'dmg_reduce'  then                          
                        defTroops[buffKey] = defTroops[buffKey] * (1/(1+buffRate))
                    elseif buffKey == 'evade' and buffKey == 'anticrit' then                                
                        defTroops[buffKey] = defTroops[buffKey] + buffRate
                    end
                end 
            end
        end

        setAccessorySkillBuffInRound(ackTroops,ackTroopsInfo[4])
        setAccessorySkillBuffInRound(defTroops,defTroopsInfo[4])

        if ackTroopsInfo[1].anticrit_reduce and ackTroopsInfo[1].anticrit_reduce > 0 then
            defTroops.anticrit = (defTroops.anticrit or defTroopsInfo[1].anticrit) - ackTroopsInfo[1].anticrit_reduce
            if defTroops.anticrit < 0 then
                defTroops.anticrit = 0
            end
        end

        -- an技能使攻击方的暴伤增加
        if not ackTroops.critDmg then ackTroops.critDmg = ackTroopsInfo[1].critDmg end
        ackTroops.critDmg = self.triggerAbilityan(ackTroops.critDmg,ackTroopsInfo[1],ackTroopsInfo[3])

        -- 灵活转换
        local playerSkillLv = getPlayerSkillLevel(ackTroopsInfo[1],"aq")
        if playerSkillLv then
            ackTroops.crit = ackTroops.crit + self.playerSkillaq(ackTroopsInfo[3],playerSkillLv,ackTroops.accuracy,defTroops.evade,ackTroops.evade_reduce,ackTroopsInfo[1].num)
        end

        playerSkillLv = getPlayerSkillLevel(ackTroopsInfo[1],"au")
        if playerSkillLv then
            ackTroops.num = self.playerSkillau(ackTroopsInfo[3],playerSkillLv,ackTroopsInfo[1].num,ackTroopsInfo[2])
        end

        -- 异星武器技能
        ackTroops , defTroops = self.aweaponSkill(ackTroops, ackTroopsInfo, defTroops, defTroopsInfo, isAttacter)        

        -- 防守方的补给舰技能
        if tenderInfo.ability[defTroopsInfo[3]] then
            if tenderInfo.ability[defTroopsInfo[3]] == "cc" then
                self.tenderSkillcc(tenderInfo.skill[defTroopsInfo[3]],defTroops)
            elseif tenderInfo.ability[defTroopsInfo[3]] == "cd" then
                self.tenderSkillcd(tenderInfo.skill[defTroopsInfo[3]],defTroops)
            end
        end

        return ackTroops, defTroops
    end

    -- 异星武器技能(isAttacter ackTroops就是攻击方出击)
    function self.aweaponSkill(ackTroops, ackTroopsInfo, defTroops, defTroopsInfo, isAttacter)
        -- setmetatable(ackTroops, {__index = ackTroopsInfo[1]})
        -- setmetatable(defTroops, {__index = defTroopsInfo[1]})

        local function appendBuff(orgValue, buff, buffRate)
            if buff == 'dmg' then
                -- writeLog({ '==> appendBuff ', orgValue=orgValue, buff=buff, buffRate=buffRate, isAttacter=isAttacter, retValue=(orgValue + orgValue*buffRate)}, 'awskill')
                return orgValue + orgValue*buffRate -- 比例换算成数值 
            else
                -- writeLog({ '==> appendBuff ', orgValue=orgValue, buff=buff, buffRate=buffRate, isAttacter=isAttacter, retValue=(orgValue + buffRate)}, 'awskill')
                return orgValue + buffRate -- 加数值
            end
        end

        -- 生效对象是通过技能effect来看(普通技能)
        if ackTroopsInfo[1].aweapon and next(ackTroopsInfo[1].aweapon) then
            local nType = ackTroopsInfo[1].aweapon.type
            local buffKey = ackTroopsInfo[1].aweapon.attr
            local param = ackTroopsInfo[1].aweapon.param
            local effect = ackTroopsInfo[1].aweapon.effect
            local myPos, tarPos = ackTroopsInfo[2], defTroopsInfo[2]

            --判断生效条件需要的参数
            local extParm = {
                myself = {
                    pos = ackTroopsInfo[2] <= 3 and 0 or 1,
                    orgTroops = isAttacter and self.originalAttackerHpInfo[myPos] or self.originalDefenderHpInfo[myPos],
                    tankType=ackTroopsInfo[1].type,
                    troops=ackTroopsInfo[1],
                    n = ackTroopsInfo[2],
                },
                target = {
                    pos = defTroopsInfo[2] <= 3 and 0 or 1,
                    orgTroops = isAttacter and self.originalDefenderHpInfo[tarPos] or self.originalAttackerHpInfo[tarPos],
                    troops=defTroopsInfo[1],
                    tankType=defTroopsInfo[1].type,
                    n = defTroopsInfo[2],
                },
                buffKey=buffKey,
                isAttacter=isAttacter,
            }

            if effect == 1 then
                -- 自身有效
                local isActive, buffs = self.aweaponSkillIsActive(nType, param, extParm)
                if isActive then
                    for k, v in pairs(buffs) do
                        ackTroops[k] =  appendBuff(ackTroops[k], k, v)
                    end
                end
            elseif effect == 2 then
                -- 对方生效
                local isActive, buffs = self.aweaponSkillIsActive(nType, param, extParm)
                if isActive then
                    for k, v in pairs(buffs) do
                        defTroops[k] = appendBuff(defTroops[k], k, -v)
                    end
                end
            elseif effect == 3 then
                -- 双方都有效果 ...
                local isActive, buffs, tarBuffs = self.aweaponSkillIsActive(nType, param, extParm)
                if isActive then
                    for k, v in pairs(buffs) do
                        ackTroops[k] = appendBuff(ackTroops[k], k, v)
                    end
                    for k, v in pairs(tarBuffs) do
                        defTroops[k] = appendBuff(defTroops[k], k, -v)
                    end                                       
                end
            end

        end

        -- 光环技能
        local ackBuff = isAttacter and self.attackerBuff.aw or self.defenderBuff.aw 
        if next(ackBuff) then --
            for m, n in pairs(ackBuff) do
                local nType = n.type
                local buffKey = n.attr
                local param = n.param
                local effect = n.effect
                local myPos, tarPos = ackTroopsInfo[2], defTroopsInfo[2]

                --判断生效条件需要的参数
                local extParm = {
                    myself = {
                        pos = ackTroopsInfo[2] <= 3 and 0 or 1,
                        orgTroops = isAttacter and self.originalAttackerHpInfo[myPos] or self.originalDefenderHpInfo[myPos],
                        tankType=ackTroopsInfo[1].type,
                        troops=ackTroopsInfo[1],
                        n = ackTroopsInfo[2],
                    },
                    target = {
                        pos = defTroopsInfo[2] <= 3 and 0 or 1,
                        orgTroops = isAttacter and self.originalDefenderHpInfo[tarPos] or self.originalAttackerHpInfo[tarPos],
                        troops=defTroopsInfo[1],
                        tankType=defTroopsInfo[1].type,
                        n = defTroopsInfo[2],
                    },
                    buffKey=buffKey,
                    isAttacter=isAttacter,
                }                
                -- 有效光环
                if n.effect == 4 then
                    local isActive, buffs = self.aweaponSkillIsActive(nType, param, extParm)
                    if isActive then
                        for k, v in pairs(buffs) do
                            defTroops[k] = appendBuff(defTroops[k], k, -v)
                        end
                    end
                elseif n.effect == 5 then
                    local isActive, buffs = self.aweaponSkillIsActive(nType, param, extParm)
                    if isActive then
                        for k, v in pairs(buffs) do
                            ackTroops[k] = appendBuff(ackTroops[k], k, v)
                        end
                    end                    
                end -- end buff
            end -- end for
        end

        if defTroopsInfo[1].aweapon and next(defTroopsInfo[1].aweapon) then
            local nType = defTroopsInfo[1].aweapon.type
            local buffKey = defTroopsInfo[1].aweapon.attr
            local param = defTroopsInfo[1].aweapon.param
            local effect = defTroopsInfo[1].aweapon.effect
            local myPos, tarPos = defTroopsInfo[2], ackTroopsInfo[2]

            --判断生效条件需要的参数
            local extParm = {
                myself = {
                    pos = defTroopsInfo[2] <= 3 and 0 or 1,
                    orgTroops = isAttacter and self.originalAttackerHpInfo[myPos] or self.originalDefenderHpInfo[myPos],
                    tankType=defTroopsInfo[1].type,
                    troops=defTroopsInfo[1],
                    n=defTroopsInfo[2],
                },
                target = {
                    pos = ackTroopsInfo[2] <= 3 and 0 or 1,
                    orgTroops = isAttacter and self.originalDefenderHpInfo[tarPos] or self.originalAttackerHpInfo[tarPos],
                    troops=ackTroopsInfo[1],
                    tankType=ackTroopsInfo[1].type,
                    n=ackTroopsInfo[2],
                },
                buffKey=buffKey,
                isAttacter=isAttacter,
            }

            if effect == 1 then
                -- 自身有效
                local isActive, buffs = self.aweaponSkillIsActive(nType, param, extParm)
                if isActive then
                    for k, v in pairs(buffs) do
                        defTroops[k] =  appendBuff(defTroops[k], k, v)
                    end
                end
            elseif effect == 2 then
                -- 对方生效
                local isActive, buffs = self.aweaponSkillIsActive(nType, param, extParm)
                if isActive then
                    for k, v in pairs(buffs) do
                        ackTroops[k] = appendBuff(ackTroops[k], k, -v)
                    end
                end
            elseif effect == 3 then
                -- 双方都有效果 ...
                local isActive, buffs, tarBuffs = self.aweaponSkillIsActive(nType, param, extParm)
                if isActive then
                    for k, v in pairs(buffs) do
                        defTroops[k] = appendBuff(defTroops[k], k, v)
                    end
                    for k, v in pairs(tarBuffs) do
                        ackTroops[k] = appendBuff(ackTroops[k], k, -v)
                    end                                       
                end
            end      
        end

        local defBuff = isAttacter and self.defenderBuff.aw or self.attackerBuff.aw
        if next(defBuff) then --
            for m, n in pairs(defBuff) do
                local nType = n.type
                local buffKey = n.attr
                local param = n.param
                local effect = n.effect
                local myPos, tarPos = ackTroopsInfo[2], defTroopsInfo[2]

                --判断生效条件需要的参数
                local extParm = {
                    myself = {
                        pos = defTroopsInfo[2] <= 3 and 0 or 1,
                        orgTroops = isAttacter and self.originalAttackerHpInfo[myPos] or self.originalDefenderHpInfo[myPos],
                        tankType=defTroopsInfo[1].type,
                        troops=defTroopsInfo[1],
                        n=defTroopsInfo[2],
                    },
                    target = {
                        pos = ackTroopsInfo[2] <= 3 and 0 or 1,
                        orgTroops = isAttacter and self.originalDefenderHpInfo[tarPos] or self.originalAttackerHpInfo[tarPos],
                        troops=ackTroopsInfo[1],
                        tankType=ackTroopsInfo[1].type,
                        n=ackTroopsInfo[2],
                    },
                    buffKey=buffKey,
                    isAttacter=isAttacter,
                }
                -- 有效光环
                if n.effect == 4 then
                    local isActive, buffs = self.aweaponSkillIsActive(nType, param, extParm)
                    if isActive then
                        for k, v in pairs(buffs) do
                            ackTroops[k] = appendBuff(ackTroops[k], k, -v)
                        end
                    end
                elseif n.effect == 5 then
                    local isActive, buffs = self.aweaponSkillIsActive(nType, param, extParm)
                    if isActive then
                        for k, v in pairs(buffs) do
                            defTroops[k] = appendBuff(defTroops[k], k, v)
                        end
                    end                    
                end -- end buff
            end -- end for
        end

        return ackTroops, defTroops
    end

    -- 异星武器生效条件，生效后的数值
    function self.aweaponSkillIsActive(nType, conds, extConds)
        local isActive, buff = true, {}
        local extbuffs = {}
        -- writeLog({'in skill', nType=nType, conds=conds}, 'awskill')
        -- 激活条件
        if nType == 2 or nType == 17 then -- 当装配部队为潜艇时，额外增加装配部队的机动X%与防护X% -- 17 所装配部队为潜艇时增加装配部队攻击力X%\暴击X%
            isActive = extConds.myself.tankType == 2 

        elseif nType == 4 then -- 遭到攻击时,有X%几率降低敌方伤害Y%
            isActive = rand(1, 1000) < conds[1]*1000
            buff[extConds.buffKey] = conds[2]
        elseif nType == 5 or nType == 8 or nType==23 then -- 5 遭到航母攻击时,减少X%的伤害 -- 8装配部队未全灭时,降低敌方航母攻击力X%
            isActive = extConds.target.tankType == 8

        elseif nType == 7 then -- 增加装配部队装甲X%，此后每回合增加Y%，最高Z%
            local rate = conds[1] + (self.round - 1 ) * conds[2]
            rate = rate > conds[3] and conds[3] or rate
            buff[extConds.buffKey] = rate
        elseif nType == 10 then -- 装配部队攻击正面敌人造成额外伤害X%
            isActive = (extConds.target.pos == extConds.myself.pos) or (extConds.target.pos == (extConds.myself.pos + 3))

        elseif nType == 11 then -- 装配部队攻击敌方后排时增加伤害X%，降低目标机动Y%
            isActive = extConds.target.pos == 1 
            buff[extConds.buffKey[1]] = conds[1]
            extbuffs[extConds.buffKey[2]] = conds[2]
        elseif nType == 12 then -- 敌方每命中装配部队一次,该部队增加X%机动，该部队有效机动最多X%
            -- 需要统计每个位置被打的次数 ???
            local id = extConds.isAttacter and 'attacker' or 'defender'
            local slot = extConds.myself.n
            local attacked = self.getMetric(id, slot, 'attacked')
            local rate = (conds[1] * attacked) < conds[2] and (conds[1] * attacked) or conds[2]
            buff[extConds.buffKey] = rate

        elseif nType == 13 then -- 装配部队攻击时有X%几率无视对方装甲
            isActive = rand(1, 1000) < conds*1000
            buff[extConds.buffKey] = 1
        elseif nType == 15 then -- 降低敌方前排对己方的伤害X%
            isActive = extConds.target.pos == 0

        elseif nType == 16 then -- 先手值落后时，增加麾下部队防护X%
            isActive = false
            if (extConds.isAttacter and self.attSeq ==0) or (not extConds.isAttacter and self.attSeq==1) then
                isActive = true
            end

        elseif nType == 19 then -- 攻击前排时增加攻击力X%，攻击后排时增加暴击率X%
            local idx = extConds.target.pos == 0 and 1 or 2
            buff[extConds.buffKey[idx]] = conds[idx]
        elseif nType == 20 then -- 装配部队每损失X%则其攻击上涨Y%
            if not extConds.myself.troops.num or not extConds.myself.orgTroops.num then
                isActive = false
                buff[extConds.buffKey] = 0
            else
                local rate = 1 - math.ceil(10 * extConds.myself.troops.num / extConds.myself.orgTroops.num) / 10
                rate = conds[2] * rate / conds[1]
                buff[extConds.buffKey] = rate
            end
        elseif nType == 21 then -- 战斗首回合攻击命中时有X%几率造成所辖部队10倍攻击力的伤害(最多造成Y次伤害)
            local id = extConds.isAttacter and 'attacker' or 'defender'
            local slot = extConds.myself.n
            if self.round ~= 1 then
                isActive = false
            else
                isActive = rand(1, 1000) < conds[1]*1000
                local cnt = self.getMetric(id, slot, 'as21')
                if cnt >= conds[3] then
                    isActive = false
                end
                buff[extConds.buffKey] = conds[2]                
            end

            if isActive then
                self.regMetric({id=id, slot=slot, type="awskill"})
            end
        end

        -- 组装加成属性
        if not next(buff) then
            if type(extConds.buffKey) == 'table' then
                for k, v in pairs(extConds.buffKey) do
                    buff[v] = conds[k]
                end
            elseif type(extConds.buffKey) == 'string' then
                buff[extConds.buffKey] = conds
            end
        end
        -- writeLog({'return skill', isActive=isActive, buff=buff, extbuffs=extbuffs, 
        --    isAttacter=extConds.isAttacter, mypos=extConds.myself.n, tarpos=extConds.target.n }, 'awskill')

        return isActive, buff, extbuffs
    end

    -- 技能统计
    function self.regMetric(mParams)
        self.metric[mParams.id] = self.metric[mParams.id] or {}
        self.metric[mParams.id][mParams.slot] = self.metric[mParams.id][mParams.slot] or {}

        if mParams.type == 'attacked' then
            -- [双方id][位置].attacked 被攻击次数 [attacker][1].attacked=2
            self.metric[mParams.id][mParams.slot].attacked = (self.metric[mParams.id][mParams.slot].attacked or 0 ) + 1
        elseif mParams.type == 'awskill' then
            self.metric[mParams.id][mParams.slot].as21 = (self.metric[mParams.id][mParams.slot].as21 or 0) + 1
        end
    end

    -- 获取统计
    -- 参数  id 双方id ；slot 作战位置; attrName 统计属性
    function self.getMetric(id, slot, attrName)
        if not id then
            return self.metric
        end
        self.metric[id] = self.metric[id] or {}

        if not slot then
            return self.metric[id]
        end
        self.metric[id][slot] = self.metric[id][slot] or {}

        if not attrName then
            return self.metric[id][slot]
        end

        return self.metric[id][slot][attrName] or 0
    end

    -- 异星武器给对方造成的buff光环效果
    -- 根据当前部队troops 刷新光环技能,对整个部队生效
    function self.refreshAweaponBuff(troops, isAttacter)
        local awskill = {}
        for m, n in pairs(troops) do
            if next(n) and n.num > 0 and n.aweapon and next(n.aweapon) then
                if n.aweapon.effect == 4 or n.aweapon.effect == 5 then -- 光环技能
                    awskill[m] = n.aweapon
                end
            end
        end

        if isAttacter then
            self.attackerBuff.aw = awskill
        else
            self.defenderBuff.aw = awskill
        end
    end

    ------------------------------------------------------------------------------------------------------

    -- 获取当前产生buff效果的坦克id（按坦克级别算）
    function self.getMaxGradeTroops(attacker)
        local buff = {}
        for k,v in pairs(attacker) do
            if next(v) and v.num > 0 then
                if buff[v.buffType] then
                    if self.compareTroopId(v.id,buff[v.buffType]) then
                        buff[v.buffType] = v.id
                    end
                else
                    buff[v.buffType] = v.id
                end
            end
        end

        return buff
    end

    -- 比较坦克级别
    -- a10001,a10002 => 10001,10002比较
    -- 后边新加入a20001之后
    -- a20001,a10002=>0001,0002比较
    function self.compareTroopId(id1,id2)
        if id1 and id2 then
            id1 = tonumber(string.sub(id1, 3)) or 0
            id2 = tonumber(string.sub(id2, 3)) or 0

            return id1 > id2
        end
    end

    -- buff 提供的加成百分比数值
    function self.getBuffRate(aid)
        return aid and self.buffValueCfg[aid] or 0
    end

    -- 是否处于光环加成中
    function self.inMutualBuff(buffType,tankType)
        local flag = false
        if self.baseMutualBuff[buffType].opponentType == 0 then
            flag = true
        elseif type(self.baseMutualBuff[buffType].opponentType) == "table" and self.baseMutualBuff[buffType].effectType == 1 then
            for oType,_ in pairs(self.baseMutualBuff[buffType].opponentType) do
                if tankType == oType then
                    flag = true
                    break
                end
            end
        end
        return flag
    end

    -- 设置部队的buff属性加成
    -- params buff 产生buff光环的效果坦克id
    -- params troops 待设置buff的部队
    -- params  originalTroops 原始部队资料
    -- params heroSkill 英雄技能
    -- param table accessorySkill 配件技能
    function self.setBuff(buff,troops,originalTroops,heroSkill,isAttacter,accessorySkill)
        for m,n in pairs(troops) do
            -- 还原属性为原始值
            for k,v in pairs(originalTroops[m]) do
                if k ~= 'num' then
                    troops[m][k] = v
                end
            end

            -- 部队未阵亡的情况下,设置新的加成属性
            if next(n) and n.num > 0 then
                troops[m]['buff'] = buff

                for k,v in pairs(buff) do
                    if self.inMutualBuff(k,n.type) then
                        for _,buffKey in pairs(self.baseMutualBuff[k].buff) do
                            -- 当前有光环作用的坦克加成值
                            local buffRate = self.buffValueCfg[v] or 0  

                            -- buff_value 是军团的buff效果值,buffvalue是光环buff值
                            -- if troops[m].buff_value and troops[m].buff_value > 0 and buffRate > 0 then
                            if troops[m].buff_value and buffRate > 0 then
                                if buffKey == 'dmg' or buffKey == 'dmg_reduce' then
                                    buffRate = buffRate + buffRate * troops[m].buff_value
                                else
                                    buffRate = buffRate + troops[m].buff_value
                                end
                            end

                            -- 设置新的buff
                            if buffKey == 'dmg' then
                                troops[m][buffKey] = troops[m][buffKey] +  troops[m][buffKey] * buffRate
                            elseif buffKey == 'dmg_reduce' then
                                if buffRate > 0 then
                                    troops[m][buffKey] = troops[m][buffKey] * (1-buffRate)
                                end
                            else
                                troops[m][buffKey] = troops[m][buffKey] + buffRate
                            end
                        end
                    end
                end

                -- 英雄
                if heroSkill and heroSkill[m] then
                    for _,skillInfo in ipairs(heroSkill[m]) do
                        local buffKey = self.heroSkillCfg[skillInfo[1]].attType
                        local buffRate = self.heroSkillCfg[skillInfo[1]].attValuePerLv * skillInfo[2]

                        if buffKey == 'dmg' then
                            troops[m][buffKey] = troops[m][buffKey] +  troops[m][buffKey] * buffRate                                
                        elseif buffKey == 'dmg_reduce' then 
                            troops[m][buffKey] = troops[m][buffKey] * (1/(1+buffRate))
                        elseif buffKey ~= 'first' and buffKey ~= 'antifirst' then                                
                            troops[m][buffKey] = troops[m][buffKey] + buffRate
                        end
                    end
                end

                -- 配件科技技能加成accessoryTechSkill
                if type(accessorySkill) == 'table' then
                    for skillId,skillVal in pairs(accessorySkill) do
                        if accessorySkillAttributeCfg[skillId] then
                            for _,buffKey in pairs(accessorySkillAttributeCfg[skillId]) do
                                -- 加成数值是配置*叠加次数
                                local buffRate = self.abilityCfg[skillId][skillVal[1]].value1 * skillVal[2]
                                if buffKey == 'dmg' then
                                    troops[m][buffKey] = troops[m][buffKey] +  troops[m][buffKey] * buffRate
                                elseif buffKey == 'dmg_reduce' then 
                                    troops[m][buffKey] = troops[m][buffKey] * (1/(1+buffRate))
                                else                             
                                    troops[m][buffKey] = troops[m][buffKey] + buffRate
                                end
                            end
                        end
                    end
                end

                
            end
        end
        
        self.refreshAweaponBuff(troops, isAttacter)

        -- 补给舰技能
        local role = isAttacter and ATTACKER_FLAGS or DEFENDER_FLAGS
        if tenderInfo.ability[role] then
            if tenderInfo.ability[role] == "ci" then
                tenderSkill:buffCi(tenderInfo.skill[role],troops,originalTroops)
            elseif tenderInfo.ability[role] == "co" then
                tenderSkill:buffCo(tenderInfo.skill[role],troops)
            elseif tenderInfo.ability[role] == "cf" then
                local targetRole = role == ATTACKER_FLAGS and DEFENDER_FLAGS or ATTACKER_FLAGS
                tenderSkill:buffCf(tenderInfo.skill[role],troops, getTroopsInfoByRole(targetRole))
            end
        end
    end

    -- 刷新buff start --

    -- skillInfo key是技能id,1是技能等级，2是叠加次数
    -- 加成数值是配置中的value*叠加次数(例ae技能),skillType为1表示光环技能
    local function initAccessorySkill(troopsInfo)
        local skillInfo = {}

        for k,v in pairs(troopsInfo) do
            if next(v) and v.num > 0 and type(v.accessorySkill) == 'table' then
                for skillId,skillLv  in pairs(v.accessorySkill) do
                    if tonumber(self.abilityCfg[skillId][skillLv].skillType) == 1 then
                        if skillInfo[skillId] then
                            if self.abilityCfg[skillId][skillLv].superposition == 1 then
                                skillInfo[skillId][2] = skillInfo[skillId][2] + 1
                            end
                        else
                            skillInfo[skillId] = {skillLv,1}
                        end
                    end
                end
            end
        end

        return skillInfo
    end

    -- 补给舰战报 start --------------------------------------
    function self.setTenderReport(role,diedSlot)
        if role == ATTACKER_FLAGS then
            tenderSkill.report(tenderInfo.report[ATTACKER_FLAGS],tenderInfo.skill[ATTACKER_FLAGS],self.attacker,self.originalAttacker,self.defender,self.round,diedSlot)
        elseif role == DEFENDER_FLAGS then
            tenderSkill.report(tenderInfo.report[DEFENDER_FLAGS],tenderInfo.skill[DEFENDER_FLAGS],self.defender,self.originalDefender,self.attacker,self.round,diedSlot)
        end
    end

    function self.initTenderBuffReport(role)
        local skillId = tenderInfo.skill[role]
        if skillId and tenderSkillCfg[skillId] then
            self.setTenderReport(role)
        end
    end

    --[[
        战斗中的补给舰的战报
        param int diedSlot 死亡的槽位
            战斗过程中某个槽位被击毁时会刷新其它位置的部队BUFF
            即我方被击毁时会调用此方法，此时如果开炮方有可刷新的BUFF,也需要刷新
    ]]
    function self.tenderBattleReport(role,diedSlot)
        local skillId = tenderInfo.skill[role]
        if skillId and tenderSkillCfg[skillId] and tenderSkillCfg[skillId].ability ~= "cf" then
            self.setTenderReport(role,diedSlot)
        end

        local targetRole = role == ATTACKER_FLAGS and DEFENDER_FLAGS or ATTACKER_FLAGS
        skillId = tenderInfo.skill[targetRole]
        if skillId and tenderSkillCfg[skillId] and tenderSkillCfg[skillId].ability == "cf" then
            self.setTenderReport(targetRole,diedSlot)
        end
    end

    -- 补给舰战报 end --------------------------------------


    -- 刷新攻击方buff
    -- param bool init 初始化,只有第一次的时候会处理先手值与反先手值
    function self.refreshAttackerBuff(init)
        local aBuffTroops = self.getMaxGradeTroops(self.attacker)
        local heroSkill,attSeqPoint = self.getHeroSkillBuff(self.attacker)
        
        if init then
            self.attSeqPoint.first = self.attSeqPoint.first + attSeqPoint.first
            self.attSeqPoint.antifirst = self.attSeqPoint.antifirst + attSeqPoint.antifirst
            self.initTenderBuffReport(ATTACKER_FLAGS)
        end

        local accessorySkill = initAccessorySkill(self.attacker)

        self.setBuff(aBuffTroops,self.attacker,self.originalAttacker,heroSkill,true,accessorySkill)
    end

    -- 刷新防守方buff
    function self.refreshDefenderBuff(init)
        local aBuffTroops = self.getMaxGradeTroops(self.defender)
        local heroSkill,defSeqPoint = self.getHeroSkillBuff(self.defender)

        if init then
            self.defSeqPoint.first = self.defSeqPoint.first + defSeqPoint.first
            self.defSeqPoint.antifirst = self.defSeqPoint.antifirst + defSeqPoint.antifirst
            self.initTenderBuffReport(DEFENDER_FLAGS)
        end

        local accessorySkill = initAccessorySkill(self.defender)

        self.setBuff(aBuffTroops,self.defender,self.originalDefender,heroSkill,false,accessorySkill)
    end

    self.refreshAttackerBuff(true)
    self.refreshDefenderBuff(true)

    -- 刷新buff end --

    ------------------------------------------------------------------------------------------------------

    -- isDodge 0表示闪避不触发,1表示闪避触发
    local function isTriggerByDodge(isDodge)
        if isDodge == 0 then 
            if self.roundEvade then return false end
        -- elseif isDodge == 1 then
        --     return true
        end

        return true
    end

    -- 检查用户新技能是否有效(要求全场有指定数量的该类型坦克)
    function self.checkNewPlayerSkill(abilityId,abilityLv,role)
        local needType = self.abilityCfg[abilityId][abilityLv].tankType
        local needNum = self.abilityCfg[abilityId][abilityLv].tankNum
        
        return getAllTroopCount(role,needType) >= needNum
    end

    -- 触发技能 -------------------------------------------------
    -- 火力压制
    function self.setTroopsByAbilitya(troops,originalTroops,troopsInfo,config)
        if not isTriggerByDodge(config.isDodge) then return end

        local newOpen = {self={},target={}}
        local reset = false

        if troops.abilityInfo.debuff[config.abilityID] then
            if config.superposition == 1 then   -- 可叠加
                table.insert(troops.abilityInfo.debuff[config.abilityID],{
                    turn = config.turn,
                    value = config.value1,
                })
            elseif config.superposition == 0 then   -- 不可叠加
                reset = true
            end
        else
            reset = true
            table.insert(newOpen.target,string.upper(config.abilityID))
        end

        if reset then
            troops.abilityInfo.debuff[config.abilityID] = {
                {
                    turn = config.turn,
                    value = config.value1,
                },
            }
        end

        return newOpen
    end

    -- 电能护盾
    function self.setTroopsByAbilityb(troops,originalTroops,troopsInfo,config)
        if not isTriggerByDodge(config.isDodge) then return end

        local newOpen = {self={},target={}}
        local reset = false

        local value = math.abs(math.floor(originalTroops.dmg * config.value1 * troops.num))

        if troops.abilityInfo.buff[config.abilityID] then
            if config.superposition == 1 then   -- 可叠加
                table.insert(troops.abilityInfo.buff[config.abilityID],{
                    turn = config.turn,
                    value = value,
                })
            elseif config.superposition == 0 then   -- 不可叠加
                reset = true
            end
        else
            reset = true
            table.insert(newOpen.self,string.upper(config.abilityID))
        end

        if reset then
            troops.abilityInfo.buff[config.abilityID] = {
                {
                    turn = config.turn,
                    value = value,
                },
            }
        end

        return newOpen
    end

    -- 精准打击
    function self.setTroopsByAbilityc(troops,originalTroops,troopsInfo,config)
        if not isTriggerByDodge(config.isDodge) then return end

        local newOpen = {self={},target={}}
        local reset = false

        if troops.abilityInfo.debuff[config.abilityID] then
            if config.superposition == 1 then   -- 可叠加
                table.insert(troops.abilityInfo.debuff[config.abilityID],{
                    turn = config.turn,
                    value = config.value1,
                    value2 = config.value2,
                })
            elseif config.superposition == 0 then   -- 不可叠加
                reset = true
            end
        else
            reset = true
            table.insert(newOpen.target,string.upper(config.abilityID))
        end

        if reset then
            troops.abilityInfo.debuff[config.abilityID] = {
                {
                    turn = config.turn,
                    value = config.value1,
                    value2 = config.value2,
                },
            }
        end

        return newOpen
    end

    -- 燃烧攻击
    function self.setTroopsByAbilityd(troops,originalTroops,troopsInfo,config)
        if not isTriggerByDodge(config.isDodge) then return end

        if not troopsInfo.dmg or troopsInfo.dmg <= 0 then return end

        local newOpen = {self={},target={string.upper(config.abilityID)}}
        local reset = false

        local abDmg = {
            turn = config.turn,
            value = math.ceil(troopsInfo.dmg * config.value1),  -- 所受伤害折算比率
        }

        if troops.abilityInfo.debuff[config.abilityID] then
            if config.superposition == 1 then
                table.insert(troops.abilityInfo.debuff[config.abilityID],abDmg)
            elseif config.superposition == 0 then
                reset = true
            end
        else
            reset = true
        end

        if reset then
            troops.abilityInfo.debuff[config.abilityID] = {
                abDmg
            }
        end

        return newOpen
    end

    -- 反应力场
    function self.setTroopsByAbilitye(troops,originalTroops,troopsInfo,config,inBattleBfs)
        if not isTriggerByDodge(config.isDodge) then return end

        local newOpen = {self={},target={}}
        local reset = false
                
        -- 在战斗中刚解除这个效果
        if inBattleBfs and table.contains(inBattleBfs.target,'e') then
            return nil
        end

        local value = math.abs(math.floor(originalTroops.dmg * config.value1 * troops.num))

        -- 如果自身没有这个效果属性才触发        
        if troops.abilityInfo.buff[config.abilityID] then    
            troops.abilityInfo.buff[config.abilityID] = nil
        else        
            reset = true 
            table.insert(newOpen.target,string.upper(config.abilityID))
        end

        if reset then
            troops.abilityInfo.buff[config.abilityID] = {
                {
                    turn = config.turn,
                    value = config.value1,
                },
            }
        end

        return newOpen
    end

    -- 蓄能核芯
    function self.setTroopsByAbilityf(troops,originalTroops,troopsInfo,config,inBattleBfs)
        if not isTriggerByDodge(config.isDodge) then return end

        -- 闪避不触发此技能
        if self.roundEvade then return nil end

        local newOpen = {self={},target={}}
         
        if troops.abilityInfo.buff[config.abilityID] then    
            local maxVal = config.SpTop *  config.value1
            if troops.abilityInfo.buff[config.abilityID][1].value < maxVal then
                troops.abilityInfo.buff[config.abilityID][1].value = troops.abilityInfo.buff[config.abilityID][1].value + config.value1
            end
        else        
            troops.abilityInfo.buff[config.abilityID] = {
                {
                    turn = config.turn,
                    value = config.value1,
                },
            }
        end

        table.insert(newOpen.self,string.upper(config.abilityID))

        return newOpen
    end

    -- 聚裂打击,这是一个被动技能，如果被攻击方闪避，技能不触发
    function self.setTroopsByAbilityh(troops,originalTroops,troopsInfo,config,inBattleBfs)
        if not isTriggerByDodge(config.isDodge) then return end

        -- 闪避不触发此技能
        if self.roundEvade then return nil end

        local newOpen = {self={},target={}}
         
        if troops.abilityInfo.buff[config.abilityID] then
            troops.abilityInfo.buff[config.abilityID][1].spTop = (troops.abilityInfo.buff[config.abilityID][1].spTop or 0) + (self.battleCritFlag and 2 or 1)
            if troops.abilityInfo.buff[config.abilityID][1].spTop > config.SpTop then
                troops.abilityInfo.buff[config.abilityID][1].spTop = config.SpTop
            end

            troops.abilityInfo.buff[config.abilityID][1].value = troops.abilityInfo.buff[config.abilityID][1].spTop * config.value1
        else        
            local tmpSpTop = self.battleCritFlag and 2 or 1
            troops.abilityInfo.buff[config.abilityID] = {
                {
                    turn = config.turn,
                    spTop = tmpSpTop,
                    value = config.value1 * tmpSpTop,
                },
            }
        end

        -- table.insert(newOpen.target,string.upper(config.abilityID))

        return newOpen
    end

    -- 寻踪打击,这是一个主动技能，如果目标没有全部死亡，攻击次数必定达到6次，
    function self.triggerAbilityi(targets,troops,target,reset,hasTarget)
        if not self.abilityCountI then
            self.abilityCountI = {}
        end

        if reset then
            self.abilityCountI.attackNum = 0
            self.abilityCountI.lastTarget = #targets
            self.abilityCountI.targetNum = {}
            return true
        end

        if hasTarget then
            self.abilityCountI.attackNum = (self.abilityCountI.attackNum or 0) + 1
        else
            self.abilityCountI.lastTarget = self.abilityCountI.lastTarget -1
        end

        self.abilityCountI.targetNum[target] = (self.abilityCountI.targetNum[target] or 0) + 1
        
        -- 如果攻击次数是最后的目标，并且攻击次数没有达到6次，
        -- 检测是否还有活着的目标
        if self.abilityCountI.attackNum == self.abilityCountI.lastTarget and self.abilityCountI.attackNum < 6 then
            local appendTarget = {}
            local i = 6-self.abilityCountI.attackNum
            local n = 0

            for _,v in pairs(targets) do
                if troops[v].num > 0 then
                    table.insert(appendTarget,v)

                    self.abilityCountI.lastTarget = self.abilityCountI.lastTarget + 1
                    n = n + 1
                    if n == i then break end
                end
            end

            for _,v in pairs(appendTarget) do
                table.insert(targets,v)
            end
        end

        -- 如果目标被多次攻击,伤害会减少
        if self.abilityCountI.targetNum[target] > 1 then
            return self.abilityCountI.targetNum[target] - 1
        end
    end

    -- 坚忍不拔,这是一个被动技能，
    -- 每次受到攻击会累积能量层数，每层可减少S%的受到的伤害，被暴击将获得2层能量,部队攻击后能量清空
    function self.setTroopsByAbilityj(troops,originalTroops,troopsInfo,config,inBattleBfs)
        if not isTriggerByDodge(config.isDodge) then return end

        local newOpen = {self={},target={}}

        if troops.abilityInfo.buff[config.abilityID] then
            troops.abilityInfo.buff[config.abilityID][1].spTop = (troops.abilityInfo.buff[config.abilityID][1].spTop or 0) + (self.battleCritFlag and 2 or 1)
            if troops.abilityInfo.buff[config.abilityID][1].spTop > config.SpTop then
                troops.abilityInfo.buff[config.abilityID][1].spTop = config.SpTop
            end

            troops.abilityInfo.buff[config.abilityID][1].value = troops.abilityInfo.buff[config.abilityID][1].spTop * config.value1
        else     
            local tmpSpTop = self.battleCritFlag and 2 or 1
            troops.abilityInfo.buff[config.abilityID] = {
                {
                    turn = config.turn,
                    spTop = tmpSpTop,
                    value = config.value1 * tmpSpTop,
                },
            }
        end

        -- table.insert(newOpen.target,string.upper(config.abilityID))
        
        return newOpen
    end

    -- 乘胜追击,这是一个主动技能
    function self.triggerAbilityk(troops,nums)
        if troops.abilityID == 'k' and ( tonumber(troops.abilityLv) or 0 ) > 0 then
            if nums <= 0 then 
               return 'Y'
            end
        end
    end

    -- 军威震慑
    function self.setTroopsByAbilityl(troops,originalTroops,troopsInfo,config)
        if not isTriggerByDodge(config.isDodge) then return end

        local newOpen = {self={},target={}}
        
        if not troops.abilityInfo.debuff[config.abilityID] then
            table.insert(newOpen.target,string.upper(config.abilityID))
        end

        troops.abilityInfo.debuff[config.abilityID] = {
            {
                turn = config.turn,
                value = config.value1,
                value1 = config.value2,
            },
        }

        return newOpen
    end

    -- 酸性炸弹：
    -- 攻击并命中敌方时，使其减少x%的装甲，持续y回合
    -- 高级替换低级，已经有高级buff了，低级的没有效果
    function self.setTroopsByAbilityo(troops,originalTroops,troopsInfo,config)
        if not isTriggerByDodge(config.isDodge) then return end

        local newOpen = {self={},target={}}
        local resetFlag = false

        if troops.abilityInfo.debuff[config.abilityID] then
            if config.lvl > troops.abilityInfo.debuff[config.abilityID][1].lvl then
                resetFlag = true
            elseif config.lvl == troops.abilityInfo.debuff[config.abilityID][1].lvl then
                if troops.abilityInfo.debuff[config.abilityID][1].spTop < config.SpTop then
                    troops.abilityInfo.debuff[config.abilityID][1].spTop = troops.abilityInfo.debuff[config.abilityID][1].spTop + 1
                    newOpen.target = {string.upper(config.abilityID)}
                end

                troops.abilityInfo.debuff[config.abilityID][1].turn = config.turn
                troops.abilityInfo.debuff[config.abilityID][1].value = troops.abilityInfo.debuff[config.abilityID][1].spTop * config.value1
            end
        else
            resetFlag = true
        end

        if resetFlag then
             troops.abilityInfo.debuff[config.abilityID] = {
                {
                    turn = config.turn,
                    spTop = 1,
                    lvl=config.lvl,
                    value = config.value1,
                },
            }

            newOpen.target = {string.upper(config.abilityID)}
        end

        return newOpen
    end

    -- 迷彩装甲,这是一个被动技能，当成为对方一次多目标攻击的目标之一时，受到的伤害减少25%
    function self.triggerAbilitym(troops,targets)
        if troops.abilityID == 'm' and #targets > 1 then
             return tonumber(self.abilityCfg[troops.abilityID][troops.abilityLv].value1)
        end
    end

    -- 磁能过载,这是一个主动技能
    function self.triggerAbilityn(aTroops,dTroops)
        local randnum = rand(1,100)
        local config = self.abilityCfg[aTroops.abilityID][aTroops.abilityLv]
        
        if randnum <= config.value1 * 100 then
            dTroops.abilityInfo.debuff[aTroops.abilityID] = {
                {
                    turn = config.turn,
                    value = config.value1,
                },
            }
            return self.abilityCfg[aTroops.abilityID][aTroops.abilityLv].value2
        end
    end

    -- 电磁发射,攻击时无视目标X%防护值,最大减防护值为value2
    function self.triggerAbilitys(abilityLv,armorValue)
        local deValue = armorValue*self.abilityCfg["s"][abilityLv].value1
        if deValue > armorValue*self.abilityCfg["s"][abilityLv].value2 then
            deValue = armorValue*self.abilityCfg["s"][abilityLv].value2
        end
        return armorValue - deValue
    end

    -- 护盾屏蔽,攻击时无视目标X%装甲值,目标装甲最低为0
    function self.triggerAbilityt(abilityLv,anticritValue)
        anticritValue = anticritValue-self.abilityCfg["t"][abilityLv].value1
        if anticritValue < 0 then 
            anticritValue = 0 
        end
        return anticritValue
    end

    -- 毁灭之光,攻击目标中包含敌军后排部队时,伤害增加x%
    -- 4,5,6位置为后排
    function self.triggerAbilityu(targets,abilityLv,damageValue)
        for k,v in pairs(targets) do
            if v > 3 then
                return damageValue * (1+self.abilityCfg["u"][abilityLv].value1)
            end
        end
    end

    -- 动能武器,攻击时对敌军额外造成基于己方血量x%的伤害
    function self.triggerAbilityv(abilityLv,hpValue)
        return hpValue * self.abilityCfg["v"][abilityLv].value1
    end

    -- 伤害导向,受到令己方部队减员超过原始数量x%的伤害时，减少y%的伤害
    -- 减员不按单体血量计算,取实际剩余坦克数量与当前数量差,解决残血问题
    function self.triggerAbilityw(troopsInfo,damageValue,originalNum)
        local hp = troopsInfo.hp - damageValue
        local num = 0
        if hp > 0 then
            num = math.ceil(hp/troopsInfo.maxhp)
        end
        
        local diffNum = troopsInfo.num - num
        if (diffNum / originalNum) > self.abilityCfg["w"][troopsInfo.sw.w].value1 then
            return damageValue * (1-self.abilityCfg["w"][troopsInfo.sw.w].value2)
        end
    end

    -- 多层护盾,每次受到伤害增加x点防护值，持续到战斗结束，最多叠加y层
    -- 动画叠加层数效果由前端自己判断,后台不返
    function self.setTroopsByAbilityx(troops)
        local abilityID = "x"
        local config = self.abilityCfg[abilityID][troops.sw[abilityID]]
        local flag
         
        if troops.abilityInfo.buff[abilityID] then
            if (troops.abilityInfo.buff[abilityID][1].spTop or 0) < config.SpTop then
                troops.abilityInfo.buff[abilityID][1].spTop = (troops.abilityInfo.buff[abilityID][1].spTop or 0) + 1
                    troops.abilityInfo.buff[abilityID][1].value = troops.abilityInfo.buff[abilityID][1].spTop * config.value1
                    flag = true
            end
        else
            troops.abilityInfo.buff[abilityID] = {
                {
                    turn = config.turn,
                    spTop = 1,
                    value = config.value1,
                },
            }
            flag = true
        end

        return flag
    end

    -- 重点打击,该回合内攻击时如未打出任何暴击,下次攻击增加40%暴击
    -- 持续回合数直接写死为1
    function self.triggerAbilityz(troops)
        local abilityID = "z"
        local config = self.abilityCfg[abilityID][troops.sw[abilityID]]
        
        troops.abilityInfo.buff[abilityID] = {
            {
                turn = config.turn,
                spTop = 1,
                value = config.value1,
            },
        }
    end

    -- 急速破解,攻击前，清除自身的负面效果，必然清除1个效果，x%清除2个效果
    function self.triggerAbilityy(troops)
        local abilityID = "y"
        local config = self.abilityCfg[abilityID][troops.sw[abilityID]]
        local clearBuff = {}

        local debuffAbilityId = {}
        for k,v in pairs(troops.abilityInfo.debuff) do
            table.insert(debuffAbilityId,k)
        end

        -- 按技能字母顺序逐个清除
        if #debuffAbilityId > 1 then
            table.sort(debuffAbilityId)
        end

        -- 如果自身有多个debuff的话才触发
        local i = 1
        for _,k in pairs(debuffAbilityId) do
            if i < config.value2 then
                troops.abilityInfo.debuff[k] = nil
                table.insert(clearBuff,k)
            else
                local randnum = rand(1,100)
                if randnum <= config.value1*100 then
                    troops.abilityInfo.debuff[k] = nil
                    table.insert(clearBuff,k)
                end
            end
            i = i+1
        end

        if #clearBuff == 0 then
            clearBuff = nil
        end

        return clearBuff
    end

    -- 减少自身受到的伤害3%，该效果对(来自于)火箭车的效果加倍
    -- param int damage 本次受到的伤害值
    -- param table troops 受到攻击的部队信息
    -- param int attackerType 攻击者部队类型
    -- return int
    function self.triggerAbilityab(damage,troops,attackerType)
        local abilityID = "ab"
        local abilityLv = getAccessorySkillLevel(troops,abilityID)

        if abilityLv then 
            local config = self.abilityCfg[abilityID][abilityLv]
            if tonumber(attackerType) == 8 then
                damage = damage * (1-config.value1*2)
            else
                damage = damage * (1-config.value1) 
            end 
        end

        return damage
    end

    -- 在前排时减少自身受到伤害3%;在后排时增加自身造成伤害3%
    -- param int damage 本次的伤害值
    -- param table troops 部队信息
    -- param int slot 部队所在位置
    -- param int isAttack 是否进攻(1进攻|2防守)
    -- return int
    function self.triggerAbilityaf(damage,troops,slot,isAttack)
        local abilityID = "af"
        local abilityLv = getAccessorySkillLevel(troops,abilityID)

        if abilityLv then 
            local config = self.abilityCfg[abilityID][abilityLv]

            if isAttack == 2 then
                if troopSlotToRow[slot] == FRONT_ROW then
                    damage = damage * (1-config.value1) 
                end
            elseif isAttack == 1 then
                if troopSlotToRow[slot] == BACK_ROW then
                    damage = damage * (1+config.value1)
                end
            end
        end

        return damage
    end

    -- 攻击多个目标时，增加伤害3%
    -- param int damage 本次的伤害值
    -- param table troops 部队信息
    -- param table targets 本次攻击的所有目标
    -- return int
    function self.triggerAbilityaj(damage,troops,targets)
        local abilityID = "aj"
        local abilityLv = getAccessorySkillLevel(troops,abilityID)

        if abilityLv and #targets > 1 then 
            local config = self.abilityCfg[abilityID][abilityLv]
            damage = damage * (1+config.value1) 
        end

        return damage
    end

    -- 增加暴击时造成伤害的倍数10%，该效果在后手攻击的时候翻倍，可以直接在战斗前算出来
    -- param table troops 部队信息
    -- param int role 身份标识(攻击者|防守者)
    -- return int
    function self.triggerAbilityan(critDmg,troops,role)
        local abilityID = "an"
        local abilityLv = getAccessorySkillLevel(troops,abilityID)

        if abilityLv then 
            local config = self.abilityCfg[abilityID][abilityLv]
            if self.roleFirstAttackInfo[role] then
                critDmg = critDmg + config.value1
            else
                critDmg = critDmg + config.value1*2
            end
        end

        return critDmg
    end

    function self.triggerAbilityag(damage,agValue,troops)
        local abilityID = "ag"
        damage = damage * (1 - agValue)
        local clearBf = self.updateTroopsAbilityBuffValue(troops,{buff={[abilityID]=1}})

        return damage, abilityID
    end

    -- 受到伤害时，有3%几率无视该伤害的99%
    -- param int damage 受到的伤害
    -- param table troops 部队信息
    -- param int role 身份标识(攻击者|防守者)
    -- return int
    function self.triggerAbilityah(damage,troops)
        local abilityID = "ah"
        local abilityLv = getAccessorySkillLevel(troops,abilityID)
        local newOpen

        if abilityLv then 
            local config = self.abilityCfg[abilityID][abilityLv]
            local randnum = rand(1,100)
            if randnum <= (config.value1 * 100) then
                damage = damage * (1-config.value2)
                newOpen = string.upper(abilityID)
            end 
        end

        return damage,newOpen
    end

    -- 攻击时，使目标增加易伤，该效果每层提供1%的伤害（所有人），该效果最多持续3回合，增多叠加10层
    function self.accessorySkillac(abilityLv,attackTroop,targetTroop)
        local abilityID = "ac"
        local newOpen = {self={},target={}}
        local config = self.abilityCfg[abilityID][abilityLv]
         
        local currBuff = targetTroop.abilityInfo.debuff[abilityID]
        if currBuff then
            if currBuff[1].spTop < config.SpTop then
                currBuff[1].spTop = currBuff[1].spTop + 1
                table.insert(newOpen.target,string.upper(abilityID))
            end

            currBuff[1].value = currBuff[1].spTop * config.value1
            currBuff[1].turn = config.turn
        else
            targetTroop.abilityInfo.debuff[abilityID] = {
                {
                    turn = config.turn,
                    spTop = 1,
                    value = config.value1,
                },
            }
            table.insert(newOpen.target,string.upper(abilityID))
        end

        return newOpen
    end

    -- [被动技能]目标受到伤害时，增加目标暴击几率3%，持续1回合，最多叠加5层
    function self.accessorySkillad(abilityLv,attackTroop,targetTroop)
        local abilityID = "ad"
        local newOpen = {self={},target={}}
        local config = self.abilityCfg[abilityID][abilityLv]
         
        local currBuff = targetTroop.abilityInfo.buff[abilityID]
        if currBuff then
            if currBuff[1].spTop < config.SpTop then
                currBuff[1].spTop = currBuff[1].spTop + 1
                table.insert(newOpen.target,string.upper(abilityID))
            end
            currBuff[1].value = currBuff[1].spTop * config.value1
            currBuff[1].turn = config.turn
        else
            targetTroop.abilityInfo.buff[abilityID] = {
                {
                    turn = config.turn,
                    spTop = 1,
                    value = config.value1,
                },
            }
            table.insert(newOpen.target,string.upper(abilityID))
        end

        return newOpen
    end

    -- 攻击时，减少下3次自身受到的伤害3%（特殊，这个是次数，效果不影响）
    function self.accessorySkillag(abilityLv,attackTroop,targetTroop)
        local abilityID = "ag"
        local newOpen = {self={},target={}}
        local config = self.abilityCfg[abilityID][abilityLv]
        
        attackTroop.abilityInfo.buff[abilityID] = {
            {
                turn = config.turn,
                value = config.value1,
                value1 = config.value2,
            },
        }

        table.insert(newOpen.self,string.upper(abilityID))

        return newOpen
    end

    -- 攻击时，减少目标的暴击率3%，持续1回合，最多叠加5层
    function self.accessorySkillak(abilityLv,attackTroop,targetTroop)
        local abilityID = "ak"
        local newOpen = {self={},target={}}
        local config = self.abilityCfg[abilityID][abilityLv]
         
        local currBuff = targetTroop.abilityInfo.debuff[abilityID]
        if currBuff then
            if currBuff[1].spTop < config.SpTop then
                currBuff[1].spTop = currBuff[1].spTop + 1
                table.insert(newOpen.target,string.upper(abilityID))
            end
            currBuff[1].value = currBuff[1].spTop * config.value1
            currBuff[1].turn = config.turn
        else
            targetTroop.abilityInfo.debuff[abilityID] = {
                {
                    turn = config.turn,
                    spTop = 1,
                    value = config.value1,
                },
            }
            table.insert(newOpen.target,string.upper(abilityID))
        end

        return newOpen
    end

    -- [被动技能]受到伤害时，增加伤害减免效果3%，持续1回合，增多叠加3层
    function self.accessorySkillal(abilityLv,attackTroop,targetTroop)
        local abilityID = "al"
        local newOpen = {self={},target={}}
        local config = self.abilityCfg[abilityID][abilityLv]
         
        local currBuff = targetTroop.abilityInfo.buff[abilityID]
        if currBuff then
            if currBuff[1].spTop < config.SpTop then
                currBuff[1].spTop = currBuff[1].spTop + 1
                table.insert(newOpen.target,string.upper(abilityID))
            end
            currBuff[1].value = currBuff[1].spTop * config.value1
            currBuff[1].turn = config.turn
        else
            targetTroop.abilityInfo.buff[abilityID] = {
                {
                    turn = config.turn,
                    spTop = 1,
                    value = config.value1,
                },
            }
            table.insert(newOpen.target,string.upper(abilityID))
        end

        return newOpen
    end

    -- 攻击时，减少目标的暴击倍数X%，持续1回合，最多叠加3层
    function self.accessorySkillao(abilityLv,attackTroop,targetTroop)
        local abilityID = "ao"
        local newOpen = {self={},target={}}
        local config = self.abilityCfg[abilityID][abilityLv]
         
        local currBuff = targetTroop.abilityInfo.debuff[abilityID]
        if currBuff then
            if currBuff[1].spTop < config.SpTop then
                currBuff[1].spTop = currBuff[1].spTop + 1
                table.insert(newOpen.target,string.upper(abilityID))
            end
            currBuff[1].value = currBuff[1].spTop * config.value1
            currBuff[1].turn = config.turn
        else
            targetTroop.abilityInfo.debuff[abilityID] = {
                {
                    turn = config.turn,
                    spTop = 1,
                    value = config.value1,
                },
            }
            table.insert(newOpen.target,string.upper(abilityID))
        end

        return newOpen
    end

    -- 攻击时，减少目标的韧性x%,持续1回合，最多叠加3层。
    function self.accessorySkillap(abilityLv,attackTroop,targetTroop)
        local abilityID = "ap"
        local newOpen = {self={},target={}}
        local config = self.abilityCfg[abilityID][abilityLv]
         
        local currBuff = targetTroop.abilityInfo.debuff[abilityID]
        if currBuff then
            if currBuff[1].spTop < config.SpTop then
                currBuff[1].spTop = currBuff[1].spTop + 1
                table.insert(newOpen.target,string.upper(abilityID))
            end
            currBuff[1].value = currBuff[1].spTop * config.value1
        else
            targetTroop.abilityInfo.debuff[abilityID] = {
                {
                    turn = config.turn,
                    spTop = 1,
                    value = config.value1,
                },
            }
            table.insert(newOpen.target,string.upper(abilityID))
        end

        return newOpen
    end

        -- 新用户技能 ------------------------------------------------

    -- 灵活转换
    -- 攻击时命中几率必定命中时，X%冗余的命中将会转换为暴击率
    function self.playerSkillaq(role,abilityLv,attAccuracy,defEvade,attevade_reduce,tankNum)
        local addVal = 0
        local abilityID = "aq"

        if self.checkNewPlayerSkill(abilityID,abilityLv,role) then
            local config = self.abilityCfg[abilityID][abilityLv]
            if tankNum>=config.tankNum then
                defEvade = defEvade - (attevade_reduce or 0)
                if defEvade < 0 then defEvade = 0 end

                local dfVal = attAccuracy-defEvade
                if dfVal > 0 then
                    addVal = dfVal * config.value1
                end
            end  
        end

        return addVal
    end

    --[[
        倾斜装甲
        技能描述：受到攻击时，X%几率降低本次受到的伤害Y%
    ]]
    function self.playerSkillar(role,abilityLv,damage,tankNum)
        local abilityID = "ar"
        if self.checkNewPlayerSkill(abilityID,abilityLv,role) then
            local config = self.abilityCfg[abilityID][abilityLv]

            if tankNum>=config.tankNum then
                local randnum = rand(1,100)
                if randnum <= config.value1 * 100 then
                    damage = math.floor(damage * (1 - config.value2))
                end
            end
           
        end

        return damage
    end

    -- 威力压制
    -- 技能描述：攻击力比目标攻击力高时，伤害增加X%
    function self.playerSkillas(role,abilityLv,damage,targetDamage,tankNum)
        local abilityID = "as"
        if self.checkNewPlayerSkill(abilityID,abilityLv,role) then
            local dfVal = damage - targetDamage
            if dfVal > 0 then
                local config = self.abilityCfg[abilityID][abilityLv]
                if tankNum>= config.tankNum then
                    damage = damage * (1 + config.value1)
                end 
            end
        end

        return damage
    end

    -- 伙伴屏障 
    -- 技能描述：开始战斗时，为后排部队添加护盾，持续1回合，护盾数值取决于X%的前排对位部队数量和部队生命
    -- function self.playerSkillat(role,abilityLv,damage,targetSlot)
    --     local newOpen
    --     local abilityID = "at"

    --     if troopSlotToRow[targetSlot] == BACK_ROW and self.checkNewPlayerSkill(abilityID,abilityLv,role) then
    --         local troopsInfo = getTroopsInfoByRole(role)
    --         local frontSlot = targetSlot - 3
    --         if troopsInfo[frontSlot] and troopsInfo[frontSlot].num > 0 then
    --             local config = self.abilityCfg[abilityID][abilityLv]
    --             damage = math.ceil(damage - config.value1 * troopsInfo[frontSlot].hp)

    --             newOpen = string.upper(abilityID)
    --         end
    --     end

    --     return damage,newOpen
    -- end
    function self.playerSkillat(role,abilityLv,slot)
        local newOpen
        local abilityID = "at"

        if troopSlotToRow[slot] == BACK_ROW and self.checkNewPlayerSkill(abilityID,abilityLv,role) then
            local troopsInfo = getTroopsInfoByRole(role)
            local frontSlot = slot - 3
            local config = self.abilityCfg[abilityID][abilityLv]
            if troopsInfo[frontSlot] and next(troopsInfo[frontSlot]) and troopsInfo[frontSlot].num >= config.tankNum then
                troopsInfo[slot].abilityInfo.buff[abilityID] = {
                    {
                        turn = config.turn + 1,
                        value = math.floor(config.value1 * troopsInfo[frontSlot].hp),
                        -- 持续到的回合,此技能只在该回合生效,所以还要减1
                        lastTurn = self.round + config.turn - 1,
                    },
                }

                newOpen = string.upper(abilityID)
            end
        end

        return newOpen
    end

    -- 无畏之师
    -- 技能描述：受到部队数量减少而降低的攻击效果降低X%
    function self.playerSkillau(role,abilityLv,tankNum,slot)
        local abilityID = "au"
        --writeLog('无畏之师1','leaderskill')
        if self.checkNewPlayerSkill(abilityID,abilityLv,role) then
            local originalTroopsInfo = getOriginalTroopsInfoByRole(role)
            --writeLog('无畏之师1'..json.encode(originalTroopsInfo)..'slot='..slot,'leaderskill')
            local originalTankNum = originalTroopsInfo[slot].num
            
            local config = self.abilityCfg[abilityID][abilityLv]
            --writeLog('无畏之师1originalTankNum='..originalTankNum..'slot='..slot..'tankNum='..tankNum..'config='..json.encode(config),'leaderskill')
            if originalTankNum > tankNum and tankNum>=config.tankNum then
                
                --writeLog('无畏之师2config='..json.encode(config),'leaderskill')
                tankNum = math.floor( (originalTankNum - tankNum) * config.value1 + tankNum)
            end 
            --writeLog('无畏之师3tankNum='..tankNum,'leaderskill')
        end

        return tankNum
    end

    -- 量子装甲
    -- 技能描述：受到群体伤害的效果降低X%
    function self.playerSkillav(role,abilityLv,targets,damage,tankNum)
        local abilityID = "av"

        --writeLog('量子装甲1targets='..#targets..'damage='..damage,'leaderskill')
        --writeLog('量子装甲2targets='..json.encode(targets),'leaderskill')
        -- #targets 只有一队是不生效的
        if #targets > 1 and self.checkNewPlayerSkill(abilityID,abilityLv,role) then
            local config = self.abilityCfg[abilityID][abilityLv]
            --writeLog('量子装甲3config='..json.encode(config),'leaderskill')

            if tankNum>= config.tankNum then
                damage = damage * (1-config.value1)
            end
            
            --writeLog('量子装甲4config='..damage,'leaderskill')
        end

        return damage
    end

    -- 过载射击
    -- 技能描述：攻击时会额外造成1%~X%的额外伤害
    function self.playerSkillaw(role,abilityLv,damage,tankNum)
        local abilityID = "aw"
        if self.checkNewPlayerSkill(abilityID,abilityLv,role) then 
            local config = self.abilityCfg[abilityID][abilityLv]
            if tankNum>= config.tankNum then
                local randnum = rand(0,100)*0.01
                damage = damage * (1+config.value1*randnum)
            end
        end

        return damage
    end

    -- 先锋破坏
    -- 技能描述：减少敌人前排部队攻击力X%
    function self.playerSkillax(role,abilityLv,damage,slot,tankNum)
        local abilityID = "ax"
        --writeLog('先锋破坏tankNum='..tankNum,'leaderskill')
        if troopSlotToRow[slot] == FRONT_ROW and self.checkNewPlayerSkill(abilityID,abilityLv,role) then
            local config = self.abilityCfg[abilityID][abilityLv]
            --writeLog('先锋破坏'..json.encode(config)..'tankNum='..tankNum,'leaderskill')
            if tankNum >= config.tankNum then
                 damage = damage * (1-config.value1)
            end   
        end

        return damage
    end

    local function getRandSlot( troops )
        local r = rand(1,6)
        for i=0,5 do
            local slot = (r+i)%6
            if slot == 0 then slot = 6 end
            if self.slotHasTanks(troops,slot) then
                return slot
            end
        end
    end

    -- 随机清除敌方一个单位的所有增益属性
    function self.planeSkillba( plane )
        local troops = getTroopsInfoByRole(plane.erole)
        local slot = getRandSlot(troops)
        if slot then
            troops[slot].abilityInfo.buff = {}
            table.insert(self.fjreport,"@-0-0-BA-"..slot)
        else
            table.insert(self.fjreport,"@-0-0-0-0")
        end
    end

    -- 清除敌方全体的所有增益属性
    function self.planeSkillbb( plane )
        local troops = getTroopsInfoByRole(plane.erole)
        for k,v in pairs(troops) do
            if self.slotHasTanks(troops,k) then
                v.abilityInfo.buff = {}
            end
        end
    end

    -- 随机清除本方一个单位的所有减益属性
    function self.planeSkillbc( plane )
        local troops = getTroopsInfoByRole(plane.role)
        local slot = getRandSlot(troops)
        if slot then
            troops[slot].abilityInfo.debuff = {}
            table.insert(self.fjreport,"@-BC-"..slot.."-0-0")
        else
            table.insert(self.fjreport,"@-0-0-0-0")
        end
    end

    -- 清除本方全体的所有减益属性
    function self.planeSkillbd( plane )
        local troops = getTroopsInfoByRole(plane.role)
        for k,v in pairs(troops) do
            if self.slotHasTanks(troops,k) then
                v.abilityInfo.debuff = {}
            end
        end
    end

    -- 随机标记一个敌方单位，下回合这个单位受到加成伤害
    function self.planeSkillbe( plane,sid )
        local abilityID = "be"
        local troops = getTroopsInfoByRole(plane.erole)
        local slot = getRandSlot(troops)
        if slot then
            troops[slot].abilityInfo.debuff[abilityID] = {
                {
                    turn = planeSkillCfg[sid].buffCd,
                    value = planeSkillCfg[sid].buffValue,
                },
            }

            -- 给前端使用的固定格式
            table.insert(self.fjreport,"@-0-0-BE-"..slot)
        end
    end

    -- 随机眩晕一个敌方单位一个回合
    function self.planeSkillbf( plane,sid )
        local abilityID = "bf"
        local troops = getTroopsInfoByRole(plane.erole)
        local slot = getRandSlot(troops)
        if slot then
            troops[slot].abilityInfo.debuff[abilityID] = {
                {
                    turn = planeSkillCfg[sid].buffCd,
                    value = 0,
                }
            }

            -- 给前端使用的固定格式
            table.insert(self.fjreport,"@-0-0-BF-"..slot)
        end
    end

    -- 提升下回合本方部队对坦克的伤害加成
    function self.planeSkillbg(plane,sid)
        local abilityID = "bg"
        local troops = getTroopsInfoByRole(plane.role)
        for k,v in pairs(troops) do
            if self.slotHasTanks(troops,k) then
                v.abilityInfo.buff[abilityID] = {
                    {
                        turn = planeSkillCfg[sid].buffCd,
                        value = planeSkillCfg[sid].buffValue,
                    }
                }
            end
        end
    end

    -- 提升下回合本方部队对坦克的伤害加成
    function self.planeSkillbh(plane,sid)
        local abilityID = "bh"
        local troops = getTroopsInfoByRole(plane.role)
        for k,v in pairs(troops) do
            if self.slotHasTanks(troops,k) then
                v.abilityInfo.buff[abilityID] = {
                    {
                        turn = planeSkillCfg[sid].buffCd,
                        value = planeSkillCfg[sid].buffValue,
                    }
                }
            end
        end
    end

    -- 提升下回合本方部队对坦克的伤害加成
    function self.planeSkillbi(plane,sid)
        local abilityID = "bi"
        local troops = getTroopsInfoByRole(plane.role)
        for k,v in pairs(troops) do
            if self.slotHasTanks(troops,k) then
                v.abilityInfo.buff[abilityID] = {
                    {
                        turn = planeSkillCfg[sid].buffCd,
                        value = planeSkillCfg[sid].buffValue,
                    }
                }
            end
        end
    end

    -- 提升下回合本方部队对坦克的伤害加成
    function self.planeSkillbj(plane,sid)
        local abilityID = "bj"
        local troops = getTroopsInfoByRole(plane.role)
        for k,v in pairs(troops) do
            if self.slotHasTanks(troops,k) then
                v.abilityInfo.buff[abilityID] = {
                    {
                        turn = planeSkillCfg[sid].buffCd,
                        value = planeSkillCfg[sid].buffValue,
                    }
                }
            end
        end
    end

    -- 首轮开始己方部队获得伤害减免N回合，数值固定为V%。
    function self.tenderSkillcc(sid,troop)
        local skillCfg = tenderSkillCfg[sid]
        if skillCfg.ability == "cc" and self.round <= skillCfg.turn then
            troop.dmg_reduce = troop.dmg_reduce * (1/(1+skillCfg.value))
        end
    end

    -- 首轮开始己方获得伤害减免，前N轮分别对应N个值。
    function self.tenderSkillcd(sid,troop)
        local skillCfg = tenderSkillCfg[sid]
        local round = self.round
        if skillCfg.ability == "cd" and round <= skillCfg.turn and skillCfg.value[round] then
            troop.dmg_reduce = troop.dmg_reduce * (1/(1+skillCfg.value[round]))
        end
    end

    -- 技能end

    local function mergeNewOpenSkillId(t1,t2)
        for k,v in pairs(t2) do
            for _,n in pairs(v) do
                table.insert(t1[k],n)
            end
        end
    end

    -- 触发配件技能
    function self.triggerAccessorySkill(attackTroop,targetTroop)
        local triggeredSkillId = {self={},target={}}

        if type(attackTroop.accessorySkill) == 'table' then
            for skillId,skillLevel in pairs(attackTroop.accessorySkill) do
                if self.abilityCfg[skillId][skillLevel]['activate'] == 1 then
                    if isTriggerByDodge(self.abilityCfg[skillId][skillLevel]['isDodge']) then
                        local skillFunc = 'accessorySkill' .. skillId
                        if type(self[skillFunc]) == 'function' then
                            local newOpen = self[skillFunc](skillLevel,attackTroop,targetTroop)
                            mergeNewOpenSkillId(triggeredSkillId,newOpen)
                        end 
                    end
                end
            end
        end

        if type(targetTroop.accessorySkill) == 'table' then
            for skillId,skillLevel in pairs(targetTroop.accessorySkill) do
                if self.abilityCfg[skillId][skillLevel]['activate'] == 0 then
                    if isTriggerByDodge(self.abilityCfg[skillId][skillLevel]['isDodge']) then
                        local skillFunc = 'accessorySkill' .. skillId
                        if type(self[skillFunc]) == 'function' then
                            local newOpen = self[skillFunc](skillLevel,attackTroop,targetTroop)
                            mergeNewOpenSkillId(triggeredSkillId,newOpen)
                        end
                    end
                end
            end
        end

        return triggeredSkillId
    end

    -- 攻击方触发技能 
    -- param troopsInfo table 参数
    function self.triggerAttackerAbility(troopsInfo)
        local selfColumns = troopsInfo.selfColumns
        local targetColumns = troopsInfo.targetColumns
        local newOpen = {self={},target={}}

        if self.originalAttacker[selfColumns] then
            local abilityID = self.originalAttacker[selfColumns].abilityID
            local abilityLv = self.originalAttacker[selfColumns].abilityLv
            local cfg = self.abilityCfg[abilityID] and self.abilityCfg[abilityID][abilityLv]

            if not cfg then return end

            -- 如果是被动触发,不引发效果
            if cfg.activate and cfg.activate == 0 then return end

            cfg.abilityID = abilityID

            local tmpAbilityName = 'setTroopsByAbility' .. abilityID

            if type(self[tmpAbilityName]) == 'function' then
                -- 作用于自己
                if cfg.type == 0 then
                    newOpen = self[tmpAbilityName](self.attacker[selfColumns],self.originalAttacker[selfColumns],troopsInfo,cfg)

                    -- 作用于目标
                elseif cfg.type == 1 and self.originalDefender[targetColumns] and self.defender[targetColumns].num > 0 then
                    -- BOSS不受debuff的伤害
                    if not self.originalDefender[targetColumns].boss then
                        newOpen = self[tmpAbilityName](self.defender[targetColumns],self.originalDefender[targetColumns],troopsInfo,cfg)
                    end
                end
            end

        end

        return newOpen
    end

    -- 防守方触发技能
    function self.triggerDefenderAbility(troopsInfo)
        local selfColumns = troopsInfo.selfColumns
        local targetColumns = troopsInfo.targetColumns
        local newOpen = {self={},target={}}

        if self.originalDefender[selfColumns] then
            local abilityID = self.originalDefender[selfColumns].abilityID
            local abilityLv = self.originalDefender[selfColumns].abilityLv
            local cfg = self.abilityCfg[abilityID] and self.abilityCfg[abilityID][abilityLv]

            if not cfg then return end

            -- 如果是被动触发,不引发效果
            if cfg.activate and cfg.activate == 0 then return end

            cfg.abilityID = abilityID

            local tmpAbilityName = 'setTroopsByAbility' .. abilityID

            if type(self[tmpAbilityName]) == 'function' then
                -- 作用于自己
                if cfg.type == 0 then
                    newOpen = self[tmpAbilityName](self.defender[selfColumns],self.originalDefender[selfColumns],troopsInfo,cfg)
                    
                -- 作用于目标
                elseif cfg.type == 1 and self.originalDefender[targetColumns] and self.attacker[targetColumns].num > 0 then
                    newOpen = self[tmpAbilityName](self.attacker[targetColumns],self.originalDefender[targetColumns],troopsInfo,cfg)
                end
            end
        end

        return newOpen
    end

    -- 攻击方触发被动技能 
    -- param troopsInfo table 参数
    function self.triggerAttackerPassiveAbility(troopsInfo)           
        local selfColumns = troopsInfo.selfColumns
        local targetColumns = troopsInfo.targetColumns
        local newOpen = {self={},target={}}

        if self.originalAttacker[selfColumns] then
            local abilityID = self.originalAttacker[selfColumns].abilityID
            local abilityLv = self.originalAttacker[selfColumns].abilityLv
            local cfg = self.abilityCfg[abilityID] and self.abilityCfg[abilityID][abilityLv]

            if not cfg then return end

            -- 如果是主动触发,不引发效果
            if cfg.activate and cfg.activate == 1 then return end

            cfg.abilityID = abilityID

            local tmpAbilityName = 'setTroopsByAbility' .. abilityID
            
            if type(self[tmpAbilityName]) == 'function' then
                -- 作用于自己
                if cfg.type == 0 then
                    -- ptb:p(self.defender[targetColumns])
                    newOpen = self[tmpAbilityName](self.attacker[selfColumns],self.originalAttacker[selfColumns],troopsInfo,cfg,troopsInfo.inBattleBfs)

                    -- print("\r\n")      
                -- 作用于目标
                elseif cfg.type == 1 and self.originalDefender[targetColumns] and self.defender[targetColumns].num > 0 then                
                    newOpen = self[tmpAbilityName](self.defender[targetColumns],self.originalDefender[targetColumns],troopsInfo,cfg,troopsInfo.inBattleBfs)                                  
                end
            end
            
        end
        
        return newOpen
    end
    
    -- 防守方触发被动技能
    function self.triggerDefenderPassiveAbility(troopsInfo)
        local selfColumns = troopsInfo.selfColumns
        local targetColumns = troopsInfo.targetColumns
        local newOpen = {self={},target={}}

        if self.originalDefender[selfColumns] then
            local abilityID = self.originalDefender[selfColumns].abilityID
            local abilityLv = self.originalDefender[selfColumns].abilityLv
            local cfg = self.abilityCfg[abilityID] and self.abilityCfg[abilityID][abilityLv]

            if not cfg then return end

            -- 如果是主动触发,不引发效果
            if cfg.activate and cfg.activate == 1 then return end

            cfg.abilityID = abilityID

            local tmpAbilityName = 'setTroopsByAbility' .. abilityID
            
            if type(self[tmpAbilityName]) == 'function' then
                -- 作用于自己
                if cfg.type == 0 then
                    newOpen = self[tmpAbilityName](self.defender[selfColumns],self.originalDefender[selfColumns],troopsInfo,cfg,troopsInfo.inBattleBfs)

                -- 作用于目标
                elseif cfg.type == 1 and self.originalDefender[targetColumns] and self.attacker[targetColumns].num > 0 then
                    newOpen = self[tmpAbilityName](self.attacker[targetColumns],self.originalDefender[targetColumns],troopsInfo,cfg,troopsInfo.inBattleBfs)                    
                end
            end            
        end

        return newOpen
    end

    -- 刷新技能效果
    function self.refreshAbility(troops,role,slot)
        -- ability产生的效果数据（燃烧之类的）
        local info = {
            -- damage = nil,
            -- ability = nil,
        }

        -- 清除（发生变化的Ability,打开/关闭）
        local clearBf = {
            self = {},  -- 自己的
            target = {},    -- 对方的
        }

        if type(troops.abilityInfo) == "table" then
            for buffk,buffv in pairs(troops.abilityInfo) do
                -- 增益效果
                if buffk == 'buff' then
                    for abilityId , buffinfo in pairs(buffv) do
                        for k,v in pairs (buffinfo) do
                            -- 大于40表示无限回合目前有电能护盾
                            if v.turn < 40 then
                                v.turn = (v.turn or 0) - 1
                                if v.turn <= 0 then buffinfo[k] = nil end
                            end
                        end

                        if table.length(buffinfo) <= 0 then
                            table.insert(clearBf.self,abilityId)
                            buffv[abilityId] = nil
                        end
                    end

                -- 减益效果
                elseif buffk == 'debuff' and buffv then
                    for abilityId , buffinfo in pairs(buffv) do
                        -- 自己烧自己,需要考虑有盾的情况
                        -- 如果盾没了,需要给前台返标识
                        if abilityId == 'd' or abilityId == 'ay' then
                            local selfAbilityBuffValue = self.getTroopsAbilityBuffValue(troops)
                            local damage = selfAbilityBuffValue.debuff[abilityId]

                            if damage and damage > 0 and troops.hp > 0 then
                                local tmpdmg = 0
                                local abHp = selfAbilityBuffValue.buff.b -- 能量护盾的值

                                if abHp and abHp > 0 then
                                    tmpdmg = math.ceil(damage - abHp)
                                    if tmpdmg < 0 then
                                        abHp = damage
                                        damage = 0
                                    else
                                        damage = tmpdmg
                                    end

                                    local tmpClear = self.updateTroopsAbilityBuffValue(troops,{buff={b=abHp}})
                                    if tmpClear then
                                        table.insert(clearBf.self,'b')
                                    end
                                end

                                for k,v in pairs (buffinfo) do
                                    if v.turn < 40 then
                                        v.turn = (v.turn or 0) - 1
                                        if v.turn <= 0 then buffinfo[k] = nil end
                                    end
                                end

                                troops.hp = troops.hp - damage

                                if damage > 0 then
                                    if role == ATTACKER_FLAGS then
                                        self.refreshAttTankNum(slot)
                                    elseif role == DEFENDER_FLAGS then
                                        self.refreshDefTankNum(slot)
                                    end
                                end

                                table.insert(info,{
                                    damage = damage,
                                    ability = string.upper(abilityId),
                                    num = troops.num
                                })

                                -- info.damage = damage
                                -- info.ability = string.upper(abilityId)

                                if table.length(buffinfo) <= 0 then
                                    table.insert(clearBf.self,abilityId)
                                    buffv[abilityId] = nil
                                end
                            end
                        else
                            for k,v in pairs (buffinfo) do
                                if v.turn < 40 then
                                    v.turn = (v.turn or 0) - 1
                                    if v.turn <= 0 then buffinfo[k] = nil end
                                end
                            end

                            if table.length(buffinfo) <= 0 then
                                if abilityId ~= 'j' then
                                    table.insert(clearBf.self,abilityId)
                                end

                                buffv[abilityId] = nil
                            end
                        end
                    end
                end
            end
        end

        return info,clearBf
    end

    -- 刷新攻击方的技能
    function self.refreshAttackerAbility(target)
        local roundData,clearBf = self.refreshAbility(self.attacker[target],ATTACKER_FLAGS,target)
        if next(roundData) then
            local tmp = self.formatReport(roundData)
            if #tmp > 0 then
                table.insert(self.report,tmp)
            end
        end

        return clearBf
    end

    -- 刷新防守方的技能
    function self.refreshDefenderAbility(target)
        local roundData,clearBf = self.refreshAbility(self.defender[target],DEFENDER_FLAGS,target)
        if next(roundData) then
            local tmp = self.formatReport(roundData)
            if #tmp > 0 then
                table.insert(self.report,tmp)
            end
        end

        return clearBf
    end

    -- 获取技能buff作用后的加成与减益数值
    function self.getTroopsAbilityBuffValue(troop)
        local valueBuff = {
            buff = {},
            debuff = {},
        }

        for buffk,buffv in pairs(troop.abilityInfo) do
            if buffv then
                for abilityId,abilityInfo in pairs(buffv) do
                    if type(abilityInfo) == 'table' then
                        for attribute,attributeValue in pairs(abilityInfo) do
                            -- 持续到的回合
                            local lastTurn = tonumber(attributeValue.lastTurn) or 100
                            if attributeValue.turn and attributeValue.turn > 0 and (self.round <= lastTurn) then
                                valueBuff[buffk][abilityId] = (valueBuff[buffk][abilityId] or 0) + attributeValue.value

                                if attributeValue.value1 then 
                                    if not valueBuff[buffk].attribute then valueBuff[buffk].attribute = {} end
                                    valueBuff[buffk].attribute[abilityId] = {value1=attributeValue.value1}
                                    -- valueBuff[buffk].attribute = {
                                    --     [abilityId] = {value1=attributeValue.value1}
                                    -- }
                                end
                            end
                        end
                    end
                end
            end
        end

        if troop.abilityID == 'g' then
            valueBuff.buff[troop.abilityID] = self.abilityCfg[troop.abilityID][troop.abilityLv].value1
        end 

        return valueBuff
    end

    -- 更新技能buff值
    -- {buff={b=abHp}
    -- uk = buff , k = b v=abhp
    function self.updateTroopsAbilityBuffValue(troop,upinfo)
        local clearBf

        if type(upinfo) == 'table' then
            for uk,uv in pairs(upinfo) do
                if uv then
                    for k,v in pairs(uv) do
                        if troop and troop.abilityInfo[uk] and troop.abilityInfo[uk][k] then
                            for buffk,buffv in pairs(troop.abilityInfo[uk][k]) do
                                buffv.value = buffv.value - v
                                if buffv.value <= 0 then
                                    troop.abilityInfo[uk][k][buffk] = nil
                                    v = math.abs(buffv.value)
                                else
                                    break
                                end
                            end

                            if table.length(troop.abilityInfo[uk][k]) < 1 then
                                clearBf = k
                                troop.abilityInfo[uk][k] = nil
                            end
                        end
                    end
                end
            end
        end

        return clearBf
    end

    -- 技能 end---------------------------------------------

    ------------------------------------------------------------------------------------------------------

    function self.checkBattle()
        local attacker_stats=0
        local defender_stats=0
        local n

        n = 1
        while n<=6 do
            if next(self.attacker[n]) and self.attacker[n].num>0 then
                attacker_stats = 1
                break
            end
            n = n + 1
        end

        n = 1
        while n<=6 do
            if next(self.defender[n]) and self.defender[n].num>0 then
                defender_stats = 1
                break
            end
            n = n + 1
        end

        --print("attacker_stats"..attacker_stats.." defender_stats"..defender_stats)
        if attacker_stats>0 and defender_stats>0 then
            -- print("in round")
            return 0
        elseif attacker_stats>0 then
            -- print("win")
            return 1
        else
            -- print("loss")
            return -1
        end
    end

    -- 空中支援
    function self.airsupport(troops,isDef,rate,showKey)
        if self.checkBattle() == 0 then
            local roundData = {}
            isDef = isDef or 1
            local def="@"
            if rate~=nil then
                def="@1"
            end

            if showKey then def = showKey end

            local rate=rate or 0.1
            for k,v in pairs(troops) do
                if type(v) == 'table' and next(v) and (tonumber(v.num) or 0) > 0 then
                    local info = {}
                    local lossblood = math.ceil(troops[k].hp * rate )
                    troops[k].hp = troops[k].hp - lossblood
                    info.damage = lossblood

                    info.num = isDef == 1 and self.refreshDefTankNum(k) or self.refreshAttTankNum(k)
                    table.insert(roundData,info)
                end
            end

            local tmp = self.formatReport(roundData)
            if #tmp > 0 then
                table.insert(self.report,{def})
                table.insert(self.report,tmp)
            end
        end
    end

    -- 刷新攻击方坦克数量
    function self.refreshAttTankNum(target)
        local dnum = self.attacker[target].num
        if math.floor(self.attacker[target].hp)>0 then
            self.attacker[target].num = math.ceil(self.attacker[target].hp/self.attacker[target].maxhp)
        else
            self.attacker[target].hp = 0
            self.attacker[target].num = 0

            -- 防止刷新方法在坦克已经死掉的情况下被调用
            if dnum > 0 then
                self.refreshAttackerBuff()
                setPlaneHp(self.attPlane,-1)

                -- 补给舰
                self.tenderBattleReport(ATTACKER_FLAGS,target)
                if tenderInfo.ability[DEFENDER_FLAGS] == "cf" then
                    self.refreshDefenderBuff()
                end
            end
        end

        local troop = self.attacker[target]
        if self.attPlane and dnum > troop.num then
            local subNum = dnum - troop.num
            setPlaneDmg(self.attPlane,self.originalAttacker[target].dmg * -subNum)
        end

        return self.attacker[target].num
    end

    -- 刷新防守方坦克数量
    function self.refreshDefTankNum(target)
        if self.defender[target].boss then
            return refreshBossTankNum(target)
        end
        
        local dnum = self.defender[target].num
        if math.floor(self.defender[target].hp)>0 then
            self.defender[target].num = math.ceil(self.defender[target].hp/self.defender[target].maxhp)
        else
            self.defender[target].hp = 0
            self.defender[target].num = 0

            if dnum > 0 then
                self.refreshDefenderBuff()
                setPlaneHp(self.defPlane,-1)
                
                -- 补给舰
                self.tenderBattleReport(DEFENDER_FLAGS,target)
                if tenderInfo.ability[ATTACKER_FLAGS] == "cf" then
                    self.refreshAttackerBuff()
                end
            end
        end

        local troop = self.defender[target]
        if self.defPlane and dnum > troop.num then
            local subNum = dnum - troop.num
            setPlaneDmg(self.defPlane,self.originalDefender[target].dmg * -subNum)
        end

        return self.defender[target].num
    end

    --[[
        过滤掉相同的技能
        同一辆坦克在一回合中会多次开火,就会触发多次技能,只需要给前端标识一次
    ]]
    local function buffStringUnique(tt)
        local newtable = {}
        for ii,xx in ipairs(tt) do
            if not newtable[xx] then
              newtable[xx] = true
            else
                tt[ii] = ''
            end
        end
        newtable = nil
    end

    --[[
        老的技能标识串,用来判断是否是旧技能
        新添的技能用两个字母表示
    ]]
    local oldAbilityIds = {
        a=true,b=true,c=true,d=true,e=true,f=true,g=true,
        h=true,i=true,j=true,k=true,l=true,m=true,n=true,
        o=true,p=true,q=true,r=true,s=true,t=true,u=true,
        v=true,w=true,x=true,y=true,z=true,
        A=true,B=true,C=true,D=true,E=true,F=true,G=true,
        H=true,I=true,J=true,K=true,L=true,M=true,N=true,
        O=true,P=true,Q=true,R=true,S=true,T=true,U=true,
        V=true,W=true,X=true,Y=true,Z=true,
    }

    --[[
        设置战报中的技能部分
        老的技能全部按单个英文字母来标识,不够用了,扩展后的新技能用两个英文标识
        为了前端兼容,扩展后的战报技能部分由原来的report[3]变为report[3]和report[4]两部分表示,
        report[3]是老的技能,report[4]是新的技能

        param table battleBuffInfo 本次的触发的所有技能信息
        param table reportTable 完整的战报信息
        param bool selfFlag 技能是否作用于自己的标识,是自己技能串拼在暴击标识前,否则拼在暴击标识后
    ]]
    local function setAbilityReport(battleBuffInfo, reportTable, selfFlag)
        -- 处理重复的技能标识
        buffStringUnique(battleBuffInfo)

        local tmpTable = { {}, {} }
        for k, v in pairs(battleBuffInfo) do
            if oldAbilityIds[v] then
                table.insert(tmpTable[1], v)
            else
                table.insert(tmpTable[2], v)
            end
        end

        -- 技能串连接标识
        local glueStr = ''

        if #tmpTable[1] > 0 then
            local buffStr = table.concat(tmpTable[1], glueStr)
            if selfFlag then
                reportTable[3] = buffStr .. reportTable[3]
            else
                reportTable[3] = reportTable[3] .. buffStr
            end
        end

        if #tmpTable[2] > 0 then
            local buffStr = table.concat(tmpTable[2], glueStr)
            if selfFlag then
                reportTable[4] = buffStr .. reportTable[4]
            else
                reportTable[4] = reportTable[4] .. buffStr
            end
        end

        tmpTable = nil
    end

    -- 生成前端需要的战报格式
    function self.formatReport(roundData)
        local tmp = {}

        for k, v in pairs(roundData) do
            local strTab = { 0, 0, 0, 0 }

            -- 本轮伤害
            if v.damage then strTab[1] = v.damage end

            -- 如果伤害为-1,表示下一轮将暂停攻击,前端用*表示
            if strTab[1] == -1 then strTab[1] = '*' end

            -- 本轮剩余坦克数量
            if v.num then strTab[2] = v.num end

            -- 本轮是否暴击
            if v.crit then strTab[3] = v.crit end

            -- ability表示开火前有效果作用于自己(燃烧效果),加在第一个字串前
            if v.ability then strTab[1] = v.ability .. strTab[1] end

            if v.updateBfs then
                if type(v.updateBfs.self) == 'table' and #v.updateBfs.self > 0 then
                    setAbilityReport(v.updateBfs.self, strTab, true)
                end

                -- if strTab[2] ~= 0 and type(v.updateBfs.target) == 'table' and #v.updateBfs.target > 0 then
                -- 原先是,如果敌方死掉了,没有效果,现在有了g这个技能也要显示出来
                if type(v.updateBfs.target) == 'table' and #v.updateBfs.target > 0 then
                    setAbilityReport(v.updateBfs.target, strTab)
                end
            end

            if v.inBattleBfs then
                if type(v.inBattleBfs.self) == 'table' and #v.inBattleBfs.self > 0 then
                    setAbilityReport(v.inBattleBfs.self, strTab, true)
                end

                if strTab[2] ~= 0 and type(v.inBattleBfs.target) == 'table' and #v.inBattleBfs.target > 0 then
                    setAbilityReport(v.inBattleBfs.target, strTab)
                end
            end

            if strTab[1] == 0 and strTab[2] == 0 and strTab[3] == 0 and strTab[4] == 0 then
                strTab = { 0 }
            end

            -- 无暴击无技能
            if strTab[4] == 0 then strTab[4] = nil end
            if strTab[3] == 0 and not strTab[4] then strTab[3] = nil end

            local str = table.concat(strTab, '-')

            table.insert(tmp, str)
        end

        return tmp
    end

    -- AZ技能会在开炮后立即生成一批与本次开火无关的溅射伤害串
    function self.setAbilityazReport( data )
        for k,v in pairs(data) do
            if v.azReport then
                table.insert(v.azReport,1,"AZ")
                table.insert(self.report,v.azReport)
            end
        end
    end

    -- flag = 1 防守方开火
    function self.attack(n,flag)
        -- 回合数据
        local roundData = {}

        -- 连击回合的数据
        local doubleRoundData = {}

        -- 技能连击回合的数据
        local doubleByAbilityKRoundData = {}

        if flag>0 then

            --print("defense:"..n.." -> "..targets[1])
            --ptb:p(self.defender[targets[1]])

            local function exec(n,doubleHit)

                local targets = self.getDefenderTarget(n,self.defender[n].type,self.defender[n].salvo)
                local targetCount = #targets
                if targetCount < 1 then return end

                -- 自己的技能影响数值
                local selfAbilityBuffValue = self.getTroopsAbilityBuffValue(self.defender[n])
                
                -- 开火前自己的技能影响/刷新技能持续回合
                -- 刷新自己的buff效果,如果被烧死了,不开炮
                local updateBfs = {self = {}, target = {}}
                if not doubleHit then
                    updateBfs = self.refreshDefenderAbility(n)
                end
                
                -- 死了
                if self.defender[n].num <= 0 then
                    return
                end

                if selfAbilityBuffValue.debuff.bf then
                    table.insert(self.report,{"*-0-bf"})
                    return "-n"
                end

                -- 如果攻击者有i技能
                local triggerAbilityIFlag = false
                if self.defender[n].abilityID == "i" then
                    self.triggerAbilityi(targets,self.attacker,0,true)
                    triggerAbilityIFlag = true
                end

                for id,target in pairs(targets) do
                    local hasTarget = target and self.attacker[target] and self.attacker[target].num > 0

                    -- 技能i造成的伤害减免
                    local reduceRateByAbilityI

                    -- 如果攻击者有i技能
                    if triggerAbilityIFlag then
                        local attNum = self.triggerAbilityi(targets,self.attacker,target,false,hasTarget)
                        if attNum then 
                            reduceRateByAbilityI = math.pow(1-self.abilityCfg.i[self.defender[n].abilityLv].value1,attNum)
                        end
                    end

                    if hasTarget then
                        -- 初始化暴击标识
                        self.battleCritFlag = false
                        local isTriggerAbility = false
                        local info = {}
                        local inBattleBfs = {self={},target={}}
                        local empBuff =  (self.attPropsConsume.p18 and self.round == 1)

                        -- 受技能影响数值
                        local targetAbilityBuffValue = self.getTroopsAbilityBuffValue(self.attacker[target])

                        local inRoundDefender, inRoundAttacker = self.initTroopsNewAttributeByRound(
                            {self.defender[n],n,DEFENDER_FLAGS,selfAbilityBuffValue},
                            {self.attacker[target],target,ATTACKER_FLAGS,targetAbilityBuffValue}
                        )

                        -- 补给舰技能
                        if type(tenderSkill[tenderInfo.ability[DEFENDER_FLAGS]]) == "function" then
                            tenderSkill.skill(inRoundDefender,inRoundAttacker,self.defender,self.attacker,n,target,self.round,targets)
                        end

                        local tmpTargetEvade = inRoundAttacker.evade
                        if targetAbilityBuffValue.debuff.c and targetAbilityBuffValue.debuff.c > 0 then
                            tmpTargetEvade = tmpTargetEvade - tmpTargetEvade * targetAbilityBuffValue.debuff.c
                            if tmpTargetEvade < 0 then tmpTargetEvade = 0 end
                        end

                        -- 闪避/电磁干扰不造成伤害
                        if not self.isEvade(inRoundDefender.accuracy,tmpTargetEvade,self.defender[n].evade_reduce) and not empBuff then
                            self.planeRestrain(self.defPlane,inRoundDefender,inRoundAttacker)
                            self.triggerPlaneSkills(self.defPlane,inRoundDefender,inRoundAttacker,selfAbilityBuffValue)
                            self.triggerPlanePassiveBuffs(self.attPlane,inRoundDefender,inRoundAttacker,targetAbilityBuffValue)

                            local damage =  inRoundDefender.dmg * inRoundDefender.num

                            -- 连击伤害减半
                            if doubleHit then
                                local abilityKValue = 0.5
                                if doubleHit == 'k' then
                                    abilityKValue = self.abilityCfg.k[self.defender[n].abilityLv].value1
                                end
                                
                                damage = damage * abilityKValue
                            end

                            damage = inRoundAttacker.dmg_reduce * damage    -- 离子盾

                            if self.defender[n].type == 8 and self.attacker[target].buff[8] then
                                damage = damage - self.getBuffRate(self.attacker[target].buff[8]) * damage
                            end

                            -- 兵种相克,
                            damage = damage * self.getRelativeRate(self.defender[n].buffType,self.attacker[target].buffType)

                            -- 护甲与穿透 公式
                            -- 实际护甲 = 已方护甲 - 敌方穿甲
                            -- 实际护甲 > 0 时 实际受伤比为 1 - (实际护甲*0.8%)/(1+实际护甲*0.8%)
                            -- 实际护甲 < 0 时 实际受伤比为 1 + (实际护甲*0.8%)

                            local armorValue = inRoundAttacker.armor - inRoundDefender.arp                            
                            if armorValue >0 then
                                damage = damage * (1 - (armorValue*0.8/100)/(1+armorValue*0.8/100))
                            elseif armorValue < 0 then
                                damage = damage * (1 + math.abs(armorValue*0.8/100))
                            end

                            -- 自己有火力压制光环    
                            if selfAbilityBuffValue.debuff.a and selfAbilityBuffValue.debuff.a > 0 then
                                damage = damage - damage * selfAbilityBuffValue.debuff.a
                            end

                           -- 蓄力
                           if selfAbilityBuffValue.buff.f  and selfAbilityBuffValue.buff.f > 0 then
                                damage = damage + damage * selfAbilityBuffValue.buff.f
                            end

                            -- 敌方被精准打击光环笼罩
                            if self.defender[n].abilityID == 'c' and targetAbilityBuffValue.debuff.c and targetAbilityBuffValue.debuff.c > 0 then
                                damage = damage + damage * self.attacker[target].abilityInfo.debuff.c[1].value2
                            end

                            -- 火力集中,并且目标只有一人
                            if selfAbilityBuffValue.buff.g and targetCount == 1 then
                                damage = damage + damage * selfAbilityBuffValue.buff.g
                                table.insert(updateBfs.target,'g')
                                table.insert(updateBfs.self,'G')
                            end

                            -- 聚裂打击,连击的时候也要有这个效果
                            if selfAbilityBuffValue.buff.h then
                                damage = damage + damage * selfAbilityBuffValue.buff.h
                                table.insert(updateBfs.self,'h')        
                            end

                            damage = math.abs(math.ceil(damage))

                            local abilityLValue = nil 
                            local abilityLValue1 = nil
                            -- 自己有军威震慑的debuff
                            if selfAbilityBuffValue.debuff.l and selfAbilityBuffValue.debuff.l > 0 then
                                abilityLValue = selfAbilityBuffValue.debuff.l
                                abilityLValue1 = selfAbilityBuffValue.debuff.attribute.l.value1
                            end

                            -- 爆击
                            if self.isCrit(inRoundDefender.crit,inRoundAttacker.anticrit,abilityLValue) then
                                damage = damage * self.getCritDmg(inRoundDefender.critDmg,inRoundAttacker.decritDmg,abilityLValue1)
                                info.crit = 1
                            end

                            -- 目标有电能护盾效果
                            if targetAbilityBuffValue.buff.b and targetAbilityBuffValue.buff.b > 0 then
                                local abHp = targetAbilityBuffValue.buff.b
                                local tmpdmg = math.ceil(damage - abHp)
                                if tmpdmg < 0 then
                                    abHp = damage
                                    damage = 0
                                else
                                    damage = tmpdmg
                                end

                                local clearBf = self.updateTroopsAbilityBuffValue(self.attacker[target],{buff={b=abHp}})
                                if clearBf then
                                    table.insert(inBattleBfs.target,clearBf)
                                end
                            end

                            -- 目标有反应力场
                            if targetAbilityBuffValue.buff.e and targetAbilityBuffValue.buff.e > 0 then     
                                damage = damage * (1-targetAbilityBuffValue.buff.e)
                                local clearBf = self.updateTroopsAbilityBuffValue(self.attacker[target],{buff={e=100}})
                                if clearBf then
                                    table.insert(inBattleBfs.target,clearBf)
                                end
                            end

                            if reduceRateByAbilityI then
                                damage = damage * reduceRateByAbilityI
                            end

                            -- 目标有坚忍不拔
                            if targetAbilityBuffValue.buff.j and targetAbilityBuffValue.buff.j > 0 then 
                                damage = damage * (1-targetAbilityBuffValue.buff.j)
                            end

                            damage = self.getSuccinctAttributeValue(self.defender[n].asa,self.attacker[target].type,damage,true)
                            damage = self.getSuccinctAttributeValue(self.attacker[target].asa,self.defender[n].type,damage)

                            -- start 配件技能部分
                            damage = self.triggerAbilityab(damage,self.attacker[target],self.defender[n].type)
                            damage = self.triggerAbilityaf(damage,self.defender[n],n,1)
                            damage = self.triggerAbilityaf(damage,self.attacker[target],target,2)
                            damage = self.triggerAbilityaj(damage,self.defender[n],targets)

                            if targetAbilityBuffValue.buff.ag then
                                local damageAg,clearAg = self.triggerAbilityag(damage,targetAbilityBuffValue.buff.attribute.ag.value1,self.attacker[target])
                                damage = damageAg
                                if clearAg then
                                    table.insert(inBattleBfs.target,clearAg)
                                end
                            end

                            -- 被攻击方ah技能
                            local damageAh,openAh = self.triggerAbilityah(damage,self.attacker[target])
                            damage = damageAh
                            if openAh then
                                table.insert(inBattleBfs.target,openAh)
                            end

                            -- end 配件技能部分

                            -- start 新的指挥官技能部分
                            local playerSkillLv

                            playerSkillLv = getPlayerSkillLevel(self.attacker[target],"ar")
                            if playerSkillLv then 
                                damage = self.playerSkillar(ATTACKER_FLAGS,playerSkillLv,damage,self.attacker[target].num)
                            end

                            playerSkillLv = getPlayerSkillLevel(self.defender[n],"as")
                            if playerSkillLv then
                                local targetDamage = self.attacker[target].dmg * self.attacker[target].num
                                damage = self.playerSkillas(DEFENDER_FLAGS,playerSkillLv,damage,targetDamage,self.defender[n].num)
                            end

                            -- 目标有伙伴屏障
                            if targetAbilityBuffValue.buff.at and targetAbilityBuffValue.buff.at > 0 then
                                local atVal =    targetAbilityBuffValue.buff.at
                                local clearBf = self.updateTroopsAbilityBuffValue(self.attacker[target],{buff={at=damage}})
                                if clearBf then
                                    table.insert(inBattleBfs.target,clearBf)
                                end

                                damage = damage - atVal
                                if damage < 0 then damage = 0 end
                            end

                            playerSkillLv = getPlayerSkillLevel(self.attacker[target],"av")
                            if playerSkillLv then
                                damage = self.playerSkillav(ATTACKER_FLAGS,playerSkillLv,targets,damage,self.attacker[target].num)
                            end
                            
                            playerSkillLv = getPlayerSkillLevel(self.defender[n],"aw")
                            if playerSkillLv then
                                damage = self.playerSkillaw(DEFENDER_FLAGS,playerSkillLv,damage,self.defender[n].num)
                            end

                            playerSkillLv = getPlayerSkillLevel(self.attacker[target],"ax")
                            if playerSkillLv then
                                damage = self.playerSkillax(ATTACKER_FLAGS,playerSkillLv,damage,n,self.attacker[target].num)
                            end

                            playerSkillLv = nil

                            -- end 新的指挥官技能部分


                            damage = math.abs(math.ceil(damage))
                            
                            self.attacker[target].hp = self.attacker[target].hp - damage

                            info.damage = damage

                            -- 自身触发主动技能
                            local newbf = self.triggerDefenderAbility({selfColumns=n,targetColumns=target,dmg=damage})
                            isTriggerAbility = true                        

                            -- 被攻击方触发被动技能
                            local newbf1 = self.triggerAttackerPassiveAbility({selfColumns=target,targetColumns=n,inBattleBfs=inBattleBfs})

                            -- 触发配件技能
                            local newbf2 = self.triggerAccessorySkill(self.defender[n],self.attacker[target])

                            if newbf then table.merge(inBattleBfs,newbf) end
                            if newbf1 then table.merge(inBattleBfs,newbf1) end
                            if newbf2 then table.merge(inBattleBfs,newbf2) end

                            info.num = self.refreshAttTankNum(target)

                            -- 触发K技能
                            self.doubleHitByAbilityK = self.triggerAbilityk(self.defender[n],info.num)

                            -- 技能统计
                            self.regMetric({id='defender', slot=n, type='attacked'})
                            -- 伤害统计
                            setDmgStats(damage,DEFENDER_FLAGS)
                        end

                        --[[
                            如果是作用于自已（最终作用效果取决于己方属性）,每一个回合无论开多少炮,其实只需要刷新一次就行了
                            比如歼击车,给自己套上光环,但是它会开两炮,就没有必要开一次炮刷一次光环

                            这里如果是火箭车开炮,MISS情况下,没有做是否MISS的判断,仍然会触发燃烧技能,所以在最终实现方法中
                            要加上是否有具体伤害值来判断是否发生了燃烧事件

                            有时间了再做优化吧
                        ]]
                        if not isTriggerAbility and not empBuff then
                            -- 闪避了,自己的蓄力消失
                            if selfAbilityBuffValue.buff.f then
                                local clearBf = self.updateTroopsAbilityBuffValue(self.defender[n],{buff={f=100}})
                                if clearBf then
                                    table.insert(inBattleBfs.self,clearBf)
                                end
                            end

                            local newbf = self.triggerDefenderAbility({selfColumns=n,targetColumns=target})
                            if newbf then
                                table.merge(inBattleBfs,newbf)
                            end

                            -- 触发配件技能
                            local newbf2 = self.triggerAccessorySkill(self.defender[n],self.attacker[target])
                            if newbf2 then
                                table.merge(inBattleBfs,newbf2)
                            end
                        end

                        info.updateBfs = updateBfs
                        info.inBattleBfs = inBattleBfs

                        if doubleHit then
                            if doubleHit == 'k' then
                                table.insert(doubleByAbilityKRoundData,info)
                            else
                                table.insert(doubleRoundData,info)
                            end
                        else
                            table.insert(roundData,info)
                        end

                        inRoundDefender = nil
                        inRoundAttacker = nil

                    end -- 目标num>0 end

                end -- for target end

            end --exec end

            -- 触发k技能标识
            self.doubleHitByAbilityK = false

            local execRet = exec(n)

            local checkIsDouble = true
            if execRet == '-n' then
                checkIsDouble = false
            end

            while self.doubleHitByAbilityK do
                self.doubleHitByAbilityK = false
                checkIsDouble = false
                exec(n,'k')
            end

            -- 连击
            if checkIsDouble and self.isDoubleHit(self.defender[n].type,self.defender[n].double_hit) then
                self.doubleHitByAbilityK = false
                exec(n,true)
            end

            while self.doubleHitByAbilityK do
                self.doubleHitByAbilityK = false
                checkIsDouble = false
                exec(n,'k')
            end

            -- self.doubleHitByAbilityK = false
            -- exec(n)

            -- while true do
            --     if self.doubleHitByAbilityK then
            --         self.doubleHitByAbilityK = false
            --         exec(n,'k')
            --     -- 连击
            --     elseif self.isDoubleHit(self.defender[n].type,self.defender[n].double_hit) then
            --         self.doubleHitByAbilityK = false
            --         exec(n,true)
            --     else
            --         break
            --     end
            -- end

            -- 聚裂打击,在连击的时候也要生效，但是我们连击的时候不会再刷新技能回合数了，所以turn配成1的话
            -- 连击的时候就没有效果了，但是如果配成2，没有触发连击的情况下，靠刷新，只会把回合数刷掉1，还剩1
            -- 会带到下一回合，否则就要改刷新方法，加参数判断了，
            -- 所以直接在这里做，把回合数设高点，每一轮打完后，直接把buff拿掉
            -- 解除效果的显示前端直接做了，所以不用管清除的串
            if self.defender[n].abilityInfo.buff.h then
                self.updateTroopsAbilityBuffValue(self.defender[n],{buff={h=1000}})
            end

            -- table.insert(self.debug,{flag=flag,slot=n,targets=targets,record=roundData})

        else

            --print("attacker:"..n.." -> "..targets[1])

            local function exec(n,doubleHit)
                local targets = self.getAttackerTarget(n,self.attacker[n].type,self.attacker[n].salvo)
                local targetCount = #targets
                if targetCount < 1 then return end

                -- 自己的技能影响数值
                local selfAbilityBuffValue = self.getTroopsAbilityBuffValue(self.attacker[n])

                -- 开火前自己的技能影响/刷新技能持续回合
                -- 刷新自己的buff效果,如果被烧死了,不开炮
                local updateBfs = {self = {}, target = {}}
                if not doubleHit then
                    updateBfs = self.refreshAttackerAbility(n)
                end

                -- 死了
                if self.attacker[n].num <= 0 then
                    return
                end

                if selfAbilityBuffValue.debuff.bf then
                    table.insert(self.report,{"*-0-bf"})
                    return "-n"
                end

                -- 如果攻击者有i技能
                local triggerAbilityIFlag = false
                if self.attacker[n].abilityID == "i" then
                    self.triggerAbilityi(targets,self.defender,0,true)
                    triggerAbilityIFlag = true
                end
                
                for id,target in pairs(targets) do
                    local hasTarget = target and self.defender[target] and self.defender[target].num > 0

                    -- 技能i造成的伤害减免
                    local reduceRateByAbilityI

                    -- 如果攻击者有i技能
                    if triggerAbilityIFlag then
                        local attNum = self.triggerAbilityi(targets,self.defender,target,false,hasTarget)
                        if attNum then 
                            reduceRateByAbilityI = math.pow(1-self.abilityCfg.i[self.attacker[n].abilityLv].value1,attNum)
                        end
                    end
                    
                    if target and self.defender[target].num <= 0 and arguments.boss then
                        target = self.getBossTarget(target,targets)
                    end

                    if hasTarget then
                        -- 初始化暴击标识,这个是为了计算h技能的触发层数用的
                        self.battleCritFlag = false
                        local isTriggerAbility = false
                        local info = {}
                        local inBattleBfs = {self={},target={}}

                        -- 受技能影响数值
                        local targetAbilityBuffValue = self.getTroopsAbilityBuffValue(self.defender[target])

                        local inRoundAttacker, inRoundDefender = self.initTroopsNewAttributeByRound(
                            {self.attacker[n],n,ATTACKER_FLAGS,selfAbilityBuffValue},
                            {self.defender[target],target,DEFENDER_FLAGS,targetAbilityBuffValue},
                            true
                        )

                        -- 补给舰技能
                        if type(tenderSkill[tenderInfo.ability[ATTACKER_FLAGS]]) == "function" then
                            tenderSkill.skill(inRoundAttacker,inRoundDefender,self.attacker,self.defender,n,target,self.round,targets)
                        end

                        local tmpTargetEvade = inRoundDefender.evade
                        if targetAbilityBuffValue.debuff.c and targetAbilityBuffValue.debuff.c > 0 then
                            tmpTargetEvade = tmpTargetEvade - tmpTargetEvade * targetAbilityBuffValue.debuff.c
                            if tmpTargetEvade < 0 then tmpTargetEvade = 0 end
                        end
                        
                        if not self.isEvade(inRoundAttacker.accuracy,tmpTargetEvade,self.attacker[n].evade_reduce) then
                            self.planeRestrain(self.attPlane,inRoundAttacker,inRoundDefender)
                            self.triggerPlaneSkills(self.attPlane,inRoundAttacker,inRoundDefender,selfAbilityBuffValue)
                            self.triggerPlanePassiveBuffs(self.defPlane,inRoundAttacker,inRoundDefender,targetAbilityBuffValue)
                            -- TODO TEST
                            -- self.triggerPlaneSkill(inRoundAttacker,inRoundDefender)
                            
                            local damage = inRoundAttacker.dmg * inRoundAttacker.num
                            damage = inRoundDefender.dmg_reduce * damage    -- 离子盾
                            
                            -- 连击伤害减半
                            if doubleHit then
                                local abilityKValue = 0.5
                                if doubleHit == 'k' then
                                    abilityKValue = self.abilityCfg.k[self.attacker[n].abilityLv].value1
                                end

                                damage = damage * abilityKValue
                            end

                            if self.attacker[n].type == 8 and self.defender[target].buff[8] then
                                damage = damage - self.getBuffRate(self.defender[target].buff[8]) * damage
                            end

                            -- 兵种相克,
                            damage = damage * self.getRelativeRate(self.attacker[n].buffType,self.defender[target].buffType)

                            -- 护甲与穿透 公式
                            -- 实际护甲 = 已方护甲 - 敌方穿甲
                            -- 实际护甲 > 0 时 实际受伤比为 1 - (实际护甲*0.8%)/(1+实际护甲*0.8%)
                            -- 实际护甲 < 0 时 实际受伤比为 1 + (实际护甲*0.8%)

                            local armorValue = inRoundDefender.armor - inRoundAttacker.arp
                            if armorValue >0 then
                                damage = damage * (1 - (armorValue*0.8/100)/(1+armorValue*0.8/100))
                            elseif armorValue < 0 then
                                damage = damage * (1 + math.abs(armorValue*0.8/100))
                            end

                            -- 自己有火力压制光环
                            if selfAbilityBuffValue.debuff.a and selfAbilityBuffValue.debuff.a > 0 then
                                damage = damage - damage * selfAbilityBuffValue.debuff.a
                           end

                            -- 蓄力
                           if selfAbilityBuffValue.buff.f  and selfAbilityBuffValue.buff.f > 0 then
                                damage = damage + damage * selfAbilityBuffValue.buff.f
                            end


                            -- 敌方被精准打击光环笼罩
                            if self.attacker[n].abilityID == 'c' and targetAbilityBuffValue.debuff.c and targetAbilityBuffValue.debuff.c > 0 then
                                damage = damage + damage * self.defender[target].abilityInfo.debuff.c[1].value2
                            end
                            
                            -- 火力集中,并且目标只有一人
                            if selfAbilityBuffValue.buff.g and targetCount == 1 then
                                damage = damage + damage * selfAbilityBuffValue.buff.g
                                table.insert(updateBfs.target,'g')
                                table.insert(updateBfs.self,'G')
                            end

                            -- 聚裂打击,连击的时候也要有这个效果
                            if selfAbilityBuffValue.buff.h then
                                damage = damage + damage * selfAbilityBuffValue.buff.h
                                table.insert(updateBfs.self,'h')
                            end

                            damage = math.abs(math.ceil(damage))

                            local abilityLValue = nil 
                            local abilityLValue1 = nil
                            -- 自己有军威震慑的debuff
                            if selfAbilityBuffValue.debuff.l and selfAbilityBuffValue.debuff.l > 0 then
                                abilityLValue = selfAbilityBuffValue.debuff.l
                                abilityLValue1 = selfAbilityBuffValue.debuff.attribute.l.value1
                            end

                            -- 爆击
                            if self.isCrit(inRoundAttacker.crit,inRoundDefender.anticrit,abilityLValue) then
                                damage = damage * self.getCritDmg(inRoundAttacker.critDmg,inRoundDefender.decritDmg,abilityLValue1)
                                info.crit = 1
                            end

                            -- 目标有电能护盾效果
                            if targetAbilityBuffValue.buff.b and targetAbilityBuffValue.buff.b > 0 then
                                local abHp = targetAbilityBuffValue.buff.b
                                local tmpdmg = math.ceil(damage - abHp)
                                if tmpdmg < 0 then
                                    abHp = damage
                                    damage = 0
                                else
                                    damage = tmpdmg
                                end

                                local clearBf = self.updateTroopsAbilityBuffValue(self.defender[target],{buff={b=abHp}})
                                if clearBf then
                                    table.insert(inBattleBfs.target,clearBf)
                                end
                            end

                           -- 目标有反应力场
                           if targetAbilityBuffValue.buff.e and targetAbilityBuffValue.buff.e > 0 then     
                                damage = damage * (1-targetAbilityBuffValue.buff.e)
                                local clearBf = self.updateTroopsAbilityBuffValue(self.defender[target],{buff={e=100}})
                                if clearBf then
                                    table.insert(inBattleBfs.target,clearBf)
                                end
                           end

                            if reduceRateByAbilityI then
                                damage = damage * reduceRateByAbilityI
                            end

                            -- 目标有坚忍不拔
                            if targetAbilityBuffValue.buff.j and targetAbilityBuffValue.buff.j > 0 then 
                                damage = damage * (1-targetAbilityBuffValue.buff.j)
                            end
                            
                            damage = self.getSuccinctAttributeValue(self.attacker[n].asa,self.defender[target].type,damage,true)
                            damage = self.getSuccinctAttributeValue(self.defender[target].asa,self.attacker[n].type,damage)

                            -- start 配件技能部分
                            damage = self.triggerAbilityab(damage,self.defender[target],self.attacker[n].type)
                            damage = self.triggerAbilityaf(damage,self.attacker[n],n,1)
                            damage = self.triggerAbilityaf(damage,self.defender[target],target,2)
                            damage = self.triggerAbilityaj(damage,self.attacker[n],targets)

                            if targetAbilityBuffValue.buff.ag then
                                local damageAg,clearAg = self.triggerAbilityag(damage,targetAbilityBuffValue.buff.attribute.ag.value1,self.defender[target])
                                damage = damageAg
                                if clearAg then
                                    table.insert(inBattleBfs.target,clearAg)
                                end
                            end
                            
                            -- 被攻击方ah技能
                            local damageAh,openAh = self.triggerAbilityah(damage,self.defender[target])
                            damage = damageAh
                            if openAh then
                                table.insert(inBattleBfs.target,openAh)
                            end

                            -- end 配件技能部分

                             -- start 新的指挥官技能部分
                            local playerSkillLv

                            playerSkillLv = getPlayerSkillLevel(self.defender[target],"ar")
                            if playerSkillLv then 
                                damage = self.playerSkillar(DEFENDER_FLAGS,playerSkillLv,damage,self.defender[target].num)
                            end

                            playerSkillLv = getPlayerSkillLevel(self.attacker[n],"as")
                            if playerSkillLv then
                                local targetDamage = self.defender[target].dmg * self.defender[target].num
                                damage = self.playerSkillas(ATTACKER_FLAGS,playerSkillLv,damage,targetDamage,self.attacker[n].num)
                            end

                            -- 目标有伙伴屏障
                            if targetAbilityBuffValue.buff.at and targetAbilityBuffValue.buff.at > 0 then
                                local atVal =    targetAbilityBuffValue.buff.at
                                local clearBf = self.updateTroopsAbilityBuffValue(self.defender[target],{buff={at=damage}})
                                if clearBf then
                                    table.insert(inBattleBfs.target,clearBf)
                                end

                                damage = damage - atVal
                                if damage < 0 then damage = 0 end
                            end

                            playerSkillLv = getPlayerSkillLevel(self.defender[target],"av")
                            if playerSkillLv then
                                damage = self.playerSkillav(DEFENDER_FLAGS,playerSkillLv,targets,damage,self.defender[target].num)
                            end

                            playerSkillLv = getPlayerSkillLevel(self.attacker[n],"aw")
                            if playerSkillLv then
                                damage = self.playerSkillaw(ATTACKER_FLAGS,playerSkillLv,damage,self.attacker[n].num)
                            end

                            playerSkillLv = getPlayerSkillLevel(self.defender[target],"ax")
                            if playerSkillLv then
                                damage = self.playerSkillax(DEFENDER_FLAGS,playerSkillLv,damage,n,self.defender[target].num)
                            end

                            playerSkillLv = nil

                            -- end 新的指挥官技能部分

                            damage = math.abs(math.ceil(damage))

                            self.defender[target].hp = self.defender[target].hp - damage     

                            info.damage = damage
                            self.deBossHp = self.deBossHp + info.damage

                            -- 开火了,自身触发一下技能
                            local newbf = self.triggerAttackerAbility({selfColumns=n,targetColumns=target,dmg=damage})
                            isTriggerAbility = true

                            local newbf1 = self.triggerDefenderPassiveAbility({selfColumns=target,targetColumns=n,inBattleBfs=inBattleBfs})

                            -- 触发配件技能
                            local newbf2 = self.triggerAccessorySkill(self.attacker[n],self.defender[target])

                            if newbf then table.merge(inBattleBfs,newbf) end
                            if newbf1 then table.merge(inBattleBfs,newbf1) end
                            if newbf2 then table.merge(inBattleBfs,newbf2) end
                            
                            info.num = self.refreshDefTankNum(target)

                            -- 触发K技能
                            self.doubleHitByAbilityK = self.triggerAbilityk(self.attacker[n],info.num)

                            -- 异星武器技能统计
                            self.regMetric({id='attacker', slot=n, type='attacked'})
                            -- 伤害统计
                            setDmgStats(damage,ATTACKER_FLAGS)
                        end

                        if not isTriggerAbility then
                            -- 闪避了,自己的蓄力消失
                            if selfAbilityBuffValue.buff.f then
                                local clearBf = self.updateTroopsAbilityBuffValue(self.attacker[n],{buff={f=100}})
                                if clearBf then
                                    table.insert(inBattleBfs.self,clearBf)
                                end
                            end

                            local newbf = self.triggerAttackerAbility({selfColumns=n,targetColumns=target})
                            if newbf then
                                table.merge(inBattleBfs,newbf)
                            end

                            -- 触发配件技能
                            local newbf2 = self.triggerAccessorySkill(self.attacker[n],self.defender[target])
                            if newbf2 then
                                table.merge(inBattleBfs,newbf2)
                            end
                        end

                        info.updateBfs = updateBfs
                        info.inBattleBfs = inBattleBfs

                        if doubleHit then
                            if doubleHit == 'k' then
                                table.insert(doubleByAbilityKRoundData,info)
                            else
                                table.insert(doubleRoundData,info)
                            end
                        else
                            table.insert(roundData,info)
                        end

                        inRoundDefender = nil
                        inRoundAttacker = nil

                    end -- if self.defenr['target']
                end
            end

            self.doubleHitByAbilityK = false
            local execRet = exec(n)

            -- K技能是击杀目标后，会再次攻击下一目标，并且不会触发连击，连击会触发的K技能
            local checkIsDouble = true
            if execRet == "-n" then
                checkIsDouble = false
            end

            while self.doubleHitByAbilityK do
                self.doubleHitByAbilityK = false
                checkIsDouble = false
                exec(n,'k')
            end

            -- 连击
            if checkIsDouble and self.isDoubleHit(self.attacker[n].type,self.attacker[n].double_hit) then
                self.doubleHitByAbilityK = false
                exec(n,true)
            end

            while self.doubleHitByAbilityK do
                self.doubleHitByAbilityK = false
                checkIsDouble = false
                exec(n,'k')
            end

            -- 聚裂打击,在连击的时候也要生效，但是我们连击的时候不会再刷新技能回合数了，所以turn配成1的话
            -- 连击的时候就没有效果了，但是如果配成2，没有触发连击的情况下，靠刷新，只会把回合数刷掉1，还剩1
            -- 会带到下一回合，否则就要改刷新方法，加参数判断了，
            -- 所以直接在这里做，把回合数设高点，每一轮打完后，直接把buff拿掉
            if self.attacker[n].abilityInfo.buff.h then
                self.updateTroopsAbilityBuffValue(self.attacker[n],{buff={h=1000}})
            end

            -- table.insert(self.debug,{flag=flag,slot=n,targets=targets,record=roundData})
        end

        local tmp = self.formatReport(roundData)
        if #tmp > 0 then
            table.insert(self.report,tmp)
        end

        if type(doubleRoundData) == 'table' and next(doubleRoundData) then
            local dtmp = self.formatReport(doubleRoundData)
            if #dtmp > 0 then
                table.insert(self.report,{"$"})
                table.insert(self.report,dtmp)
            end
        end

        if type(doubleByAbilityKRoundData) == 'table' and next(doubleByAbilityKRoundData) then
            for _,v in ipairs(doubleByAbilityKRoundData) do
                local dtmp = self.formatReport({v})
                if #dtmp > 0 then
                    table.insert(self.report,{"$","K"})
                    table.insert(self.report,dtmp)
                end
            end
        end
    end

    function self.getAttackerSlot(n)
        while n<=6 do
            if next(self.attacker[n]) and self.attacker[n].num>0 then
                return n
            end
            n = n + 1
        end
        return 0
    end

    function self.getDefenderSlot(n)
        while n<=6 do
            if next(self.defender[n]) and self.defender[n].num>0 then
                return n
            end
            n = n + 1
        end
        return 0
    end

    function self.slotHasTanks(troops,slot)
        if type(troops[slot]) == "table" then
            return next(troops[slot]) and troops[slot].num>0
        end
    end


    -- 1  战列舰
    -- 2  潜艇
    -- 4 巡洋舰
    -- 8 航母
    function self.getAttackerTarget(slot,attackType,salvo)
        local targets = {}
        local i,currSlot
        local col = slot % 3

        if attackType<3 then
            -- 战列舰 潜艇
            if salvo>1 then
                for _,i in pairs({1,2,3}) do
                    if next(self.defender[i]) and self.defender[i].num>0 then
                        table.insert(targets,i)
                    elseif next(self.defender[i+3]) and self.defender[i+3].num>0 then
                        table.insert(targets,i+3)
                    end
                end
            else
                if col == 1 then
                    for _,i in pairs({1,2,3}) do
                        if #targets<salvo then
                            if next(self.defender[i]) and self.defender[i].num>0 then
                                table.insert(targets,i)
                            elseif next(self.defender[i+3]) and self.defender[i+3].num>0 then
                                table.insert(targets,i+3)
                            end
                        end
                    end
                elseif col == 2 then
                    for _,i in pairs({2,3,1}) do
                        if #targets<salvo then
                            if next(self.defender[i]) and self.defender[i].num>0 then
                                table.insert(targets,i)
                            elseif next(self.defender[i+3]) and self.defender[i+3].num>0 then
                                table.insert(targets,i+3)
                            end
                        end
                    end
                else
                    for _,i in pairs({3,2,1}) do
                        if #targets<salvo then
                            if next(self.defender[i]) and self.defender[i].num>0 then
                                table.insert(targets,i)
                            elseif next(self.defender[i+3]) and self.defender[i+3].num>0 then
                                table.insert(targets,i+3)
                            end
                        end
                    end
                end
            end

        elseif attackType==4 then
            -- 巡洋舰
            if col == 1 then
                for _,i in pairs({1,2,3}) do
                    if #targets<1 then
                        if next(self.defender[i]) and self.defender[i].num>0 then
                            table.insert(targets,i)
                        end
                        if #targets<salvo then
                            if next(self.defender[i+3]) and self.defender[i+3].num>0 then
                                table.insert(targets,i+3)
                            end
                        end
                    end
                end
            elseif col == 2 then
                for _,i in pairs({2,3,1}) do
                    if #targets<1 then
                        if next(self.defender[i]) and self.defender[i].num>0 then
                            table.insert(targets,i)
                        end
                        if #targets<salvo then
                            if next(self.defender[i+3]) and self.defender[i+3].num>0 then
                                table.insert(targets,i+3)
                            end
                        end
                    end
                end
            else
                for _,i in pairs({3,2,1}) do
                    if #targets<1 then
                        if next(self.defender[i]) and self.defender[i].num>0 then
                            table.insert(targets,i)
                        end
                        if #targets<salvo then
                            if next(self.defender[i+3]) and self.defender[i+3].num>0 then
                                table.insert(targets,i+3)
                            end
                        end
                    end
                end
            end
        else
            i=1
            while i<=6 do
                if next(self.defender[i]) and self.defender[i].num>0 then
                    table.insert(targets,i)
                end
                i = i + 1
            end
        end

        return targets
    end


    -- 1  战列舰
    -- 2  潜艇
    -- 4 巡洋舰
    -- 8 航母
    function self.getDefenderTarget(slot,attackType,salvo)
        local targets = {}
        local i,currSlot
        local col = slot % 3

        if attackType<3 then
            -- 战列舰 潜艇
            if salvo>1 then
                for _,i in pairs({1,2,3}) do
                    if next(self.attacker[i]) and self.attacker[i].num>0 then
                        table.insert(targets,i)
                    elseif next(self.attacker[i+3]) and self.attacker[i+3].num>0 then
                        table.insert(targets,i+3)
                    end
                end
            else
                if col == 1 then
                    for _,i in pairs({1,2,3}) do
                        if #targets<salvo then
                            if next(self.attacker[i]) and self.attacker[i].num>0 then
                                table.insert(targets,i)
                            elseif next(self.attacker[i+3]) and self.attacker[i+3].num>0 then
                                table.insert(targets,i+3)
                            end
                        end
                    end
                elseif col == 2 then
                    for _,i in pairs({2,3,1}) do
                        if #targets<salvo then
                            if next(self.attacker[i]) and self.attacker[i].num>0 then
                                table.insert(targets,i)
                            elseif next(self.attacker[i+3]) and self.attacker[i+3].num>0 then
                                table.insert(targets,i+3)
                            end
                        end
                    end
                else
                    for _,i in pairs({3,2,1}) do
                        if #targets<salvo then
                            if next(self.attacker[i]) and self.attacker[i].num>0 then
                                table.insert(targets,i)
                            elseif next(self.attacker[i+3]) and self.attacker[i+3].num>0 then
                                table.insert(targets,i+3)
                            end
                        end
                    end
                end
            end


        elseif attackType==4 then
            -- 巡洋舰
            if col == 1 then
                for _,i in pairs({1,2,3}) do
                    if #targets<1 then
                        if next(self.attacker[i]) and self.attacker[i].num>0 then
                            table.insert(targets,i)
                        end
                        if #targets<salvo then
                            if next(self.attacker[i+3]) and self.attacker[i+3].num>0 then
                                table.insert(targets,i+3)
                            end
                        end
                    end
                end
            elseif col == 2 then
                for _,i in pairs({2,3,1}) do
                    if #targets<1 then
                        if next(self.attacker[i]) and self.attacker[i].num>0 then
                            table.insert(targets,i)
                        end
                        if #targets<salvo then
                            if next(self.attacker[i+3]) and self.attacker[i+3].num>0 then
                                table.insert(targets,i+3)
                            end
                        end
                    end
                end
            else
                for _,i in pairs({3,2,1}) do
                    if #targets<1 then
                        if next(self.attacker[i]) and self.attacker[i].num>0 then
                            table.insert(targets,i)
                        end
                        if #targets<salvo then
                            if next(self.attacker[i+3]) and self.attacker[i+3].num>0 then
                                table.insert(targets,i+3)
                            end
                        end
                    end
                end
            end
        else
            i=1
            while i<=6 do
                if next(self.attacker[i]) and self.attacker[i].num>0 then
                    table.insert(targets,i)
                end
                i = i + 1
            end
        end

        return targets
    end

    -- 获取boss目标，当boss的炮头2受到最后一击时，死的是3炮头，
    -- 这个时候，如果有6号位，那么6号位要再受一炮，
    -- 如果是火箭车的话，本来6号就要受一炮，所以要检测原来的目标中，是否包含有这个新目标
    function self.getBossTarget(target,targets)
        if target <= 3 then
            local newTarget = target + 3
            if not table.contains(targets,newTarget) and self.defender[newTarget] and self.defender[newTarget].num > 0 then
                return newTarget
            end
        end 
    end

    -- 获取飞机技能功能目标
    function self.getPlaneTarget1(salvo,troops)
        local targets = {}
        for i=1,6 do
            if self.slotHasTanks(troops,i) then
                for j=1,salvo do
                    table.insert(targets,i)
                end
                break
            end
        end

        return targets
    end

    -- 获取飞机的普攻目标
    function self.getPlaneTarget2(salvo,troops)
        local targets = {}
        for i=1,salvo do
            if self.slotHasTanks(troops,i) then
                table.insert(targets,i)
            end
        end
        return targets
    end

    -- 是否发生暴击 暴击双倍伤害
    function self.isCrit(attackCrit,defendAnticrit,debuffValue)
        --当 Atk 暴击率 数值 < Def 免爆击率 时,则必然不暴击。

        if attackCrit <= defendAnticrit then
            self.battleCritFlag = false
            return false
        end

        --其他情况    Atk.暴击率 - Def.免爆击率 的最终值 作为随机,是的结果为暴击,否的结果为免爆击
        local crit = (attackCrit - defendAnticrit) * 100
        
        if debuffValue then 
            crit = math.ceil( (1-debuffValue) * crit) 
        end

        local randnum = rand(1,100)
        local ret = (randnum <= crit)

        self.battleCritFlag = ret

        return ret
    end

    function self.getCritDmg(attackCritDmg,defenderDeCritDmg,debuffValue)
        local minCritDmg = 1.5
        local maxCritDmg = 4
        attackCritDmg = tonumber(attackCritDmg)
        defenderDeCritDmg = tonumber(defenderDeCritDmg) or 0

        if defenderDeCritDmg < 0 then
            defenderDeCritDmg = 0
        end
        
        local critDmg = (attackCritDmg or 0) + 2 - (defenderDeCritDmg or 0)

        if debuffValue and debuffValue > 0 then
            critDmg = critDmg - debuffValue
        end

        if critDmg < minCritDmg then 
            critDmg = minCritDmg 
        end

        if critDmg > maxCritDmg then
            critDmg = maxCritDmg
        end

        return critDmg
    end

    -- 是否闪避
    -- params attAccuracy 进攻方的精准值
    -- params defEvade 防守方的闪避值
    -- params attevade_reduce 进攻方的减闪避值（减敌方）
    -- return boolean
    function self.isEvade(attAccuracy,defEvade,attevade_reduce)
        defEvade = defEvade - (attevade_reduce or 0)
        if defEvade < 0 then defEvade = 0 end

        if attAccuracy >= defEvade then
            self.roundEvade = false
            return false
        end

        local attSeedArr = {}

        local m = (defEvade - attAccuracy) * 100

        --实际闪避不能超过百分80
        if m>80  then
            m=80
        end

        local randnum = rand(1,100)
        local ret = (randnum <= m)

        self.roundEvade  = ret

        return ret
    end

    -- 是否连击
    function self.isDoubleHit(tankType,doubleHit)
        doubleHit = tonumber(doubleHit) or 0
        if doubleHit > 0 then
            local randnum = rand(1,100)
            return (randnum <= doubleHit)
        end

        return false
    end

    -- 兵种相克后的比率
    -- 航母 战列舰 巡洋舰 潜艇 boss船？
    -- 战列舰    resist="0,    0,         -20,    25,    0"
    -- 潜艇    resist="-20,    0,    25,    0,    0"
    -- 巡洋舰    resist="25,    0,    0,        -20,    0"
    -- 航母    resist="0,    25,    0,    0,    0"
    function self.getRelativeRate(attType,defType)
        return 1 + self.relative[attType][defType]/100
    end

    -- 211 对坦克伤害增加
    -- 212 对歼击车伤害增加
    -- 213 对自行火炮伤害增加
    -- 214 对火箭车伤害增加
    -- 221 受坦克伤害减少
    -- 222 受歼击车伤害减少
    -- 223 受自行火炮伤害减少
    -- 224 受火箭车伤害减少
    local succinctRelative1Cfg = {['211'] = 1,['212'] = 2,['213'] = 4,['214'] = 8,}
    local succinctRelative2Cfg = {['221'] = 1,['222'] = 2,['223'] = 4,['224'] = 8,}

    function self.getSuccinctAttributeValue(attributes,targetTankType,dmgValue,attackFlag)
        if type(attributes) == 'table' then
            if attackFlag then
                for attribute,attValue in pairs(attributes) do
                    if succinctRelative1Cfg[tostring(attribute)] == targetTankType then
                        dmgValue = math.ceil(dmgValue * ( 1 + attValue/100 ))
                        break
                    end
                end
            else
                for attribute,attValue in pairs(attributes) do
                    if succinctRelative2Cfg[tostring(attribute)] == targetTankType then
                        dmgValue = math.ceil(dmgValue / ( 1 + attValue/100 ))
                        break
                    end
                end
            end
        end

        return dmgValue
    end

    -- 开火前触发的技能处理 start

    local reportBeforeSkill

    local function addAbilityIdToBfSkill(role,slot,abilityID)
        if not reportBeforeSkill then reportBeforeSkill = {{},{}} end

        -- 防守方在左,攻击方在右
        local pos = role == ATTACKER_FLAGS and 2 or 1

        for i=1,slot do
            if not reportBeforeSkill[pos][i] then reportBeforeSkill[pos][i] = "" end
        end

        reportBeforeSkill[pos][slot] = reportBeforeSkill[pos][slot] .. tostring(abilityID)
    end

    function self.initPreBattleSkill(role,troops)
        local playerSkillLv

        for k,v in pairs(troops) do
            if next(v) then
                playerSkillLv = getPlayerSkillLevel(v,"at")
                if playerSkillLv then
                    local openId = self.playerSkillat(role,playerSkillLv,k)
                    if openId then
                       addAbilityIdToBfSkill(role,k,openId)
                    end
                end

                -- 补给舰战前技能展示
                if tenderInfo.ability[role] and tenderSkill.preSkillsCfg[tenderInfo.ability[role]] then
                    addAbilityIdToBfSkill(role,k,string.upper(tenderInfo.ability[role]))
                end
            end
        end
    end

    self.initPreBattleSkill(ATTACKER_FLAGS,self.attacker)
    self.initPreBattleSkill(DEFENDER_FLAGS,self.defender)

    -- 开火前触发的技能处理 end

    -- 飞机相关技能处理 start
    
    local function planeSkillTypeCheck( tankType,skillType )
        if tankType and skillType then
            return bit32.band(skillType,tankType) == tankType
        end
    end

    local function planeSkillValueAdd(plane,troop,skillAttackType,value)
        local attribute
        local n = skillAttackType % 1000
        if n == 1 then
            attribute = "dmg"
        elseif n == 2 then
            attribute = "dmg_reduce"
        end

        if attribute then
            if skillAttackType > 1000 then
                value = plane.energy * value
            end

            if attribute == "dmg_reduce" then
                troop[attribute] = troop[attribute] * (1 - value)
            else
                troop[attribute] = troop[attribute] * (1 + value)
            end

            if attribute == "dmg" then
                troop[attribute] = math.floor(troop[attribute])
            end
        end
    end

    -- 按回合验证技能是否生效
    local function planeCDCheck(startCD,skillCD)
        -- 起始回合生效设为0,起始回合不生效设置为1,
        local firstRoundStart = 0

        -- 技能CD生效后的回合数，
        local roundCd = self.round - startCD + firstRoundStart

        -- 当前回合未达到技能开始回合条件
        if roundCd < firstRoundStart then return false end

        -- 0表示无间隔持续生效
        -- 大于0表示为每次生效后间隔该值的回合数后才生效
        if skillCD > 0 then
            if roundCd % (skillCD + 1) ~= 0  then return false end
        end
        
        return true
    end

    -- 飞机压制
    function self.planeRestrain(plane,attackTroop,targetTroop)
        if plane and planeCfg.plane[plane.id].restrain == targetTroop.type and plane.level>0 then
             attackTroop.dmg = attackTroop.dmg * (1+planeCfg.plane[plane.id].restrainQue[plane.level])
        end
    end

    local function triggerPlaneSkill(plane,sid,attackTroop,targetTroop)
        -- 回合数验证
        if not planeCDCheck(planeSkillCfg[sid].CD,planeSkillCfg[sid].skillCD) then return end

        -- 处理对自己的加成
        if planeSkillTypeCheck(attackTroop.type,planeSkillCfg[sid].myTargetType) and planeSkillTypeCheck(targetTroop.type,planeSkillCfg[sid].enemyTargetType) then
            planeSkillValueAdd(plane,attackTroop,planeSkillCfg[sid].myAttackType,planeSkillCfg[sid].myValue)

            -- 处理对敌方的加成,暂时没有,以后可能会有
        end
    end 

    -- 坦克开火时飞机的技能
    function self.triggerPlaneSkills(plane,attackTroop,targetTroop,attackerBuffValue)
        if not plane then return end

        for _,sid in pairs(plane.skills) do
            if planeSkillCfg[sid].isPassive == 0 then
                triggerPlaneSkill(plane,sid,attackTroop,targetTroop)
            elseif planeSkillCfg[sid].isPassive == 1 then
                -- 如果攻击方是飞机,并且是触发了主动技能的攻击,伤害值需要乘以PlaneAtk配置
                if attackTroop.isPlane and attackTroop.isTriggerSkill then
                    attackTroop.dmg = attackTroop.dmg * planeSkillCfg[sid].planeAtk or 1
                end

                -- 如果攻击方有buff效果
                if attackerBuffValue and attackerBuffValue.buff[planeSkillCfg[sid].planeAnim] and targetTroop.type == planeSkillCfg[sid].buffEnemy then
                    attackTroop.dmg = attackTroop.dmg * (1 + attackerBuffValue.buff[planeSkillCfg[sid].planeAnim])
                end
            end
        end
    end

    local function triggerPlanePassiveBuff(plane,sid,attackTroop,targetTroop)
        -- 回合数验证
        if not planeCDCheck(planeSkillCfg[sid].CD,planeSkillCfg[sid].skillCD) then return end

        -- 坦克被动时只飞机buff
        if planeSkillTypeCheck(targetTroop.type,planeSkillCfg[sid].buffType) and planeSkillTypeCheck(attackTroop.type,planeSkillCfg[sid].buffEnemy) then
            planeSkillValueAdd(plane,targetTroop,planeSkillCfg[sid].buffAttackType,planeSkillCfg[sid].buffValue)
        end
    end

    -- 坦克被攻击时飞机的技能
    function self.triggerPlanePassiveBuffs(plane,attackTroop,targetTroop,targetAbilityBuffValue)
        if plane then
            for _,sid in pairs(plane.skills) do
                if planeSkillCfg[sid].isPassive == 2 then
                    triggerPlanePassiveBuff(plane,sid,attackTroop,targetTroop)
                end
            end
        end

        if targetAbilityBuffValue.debuff.be then
            attackTroop.dmg = attackTroop.dmg * (1+targetAbilityBuffValue.debuff.be)
        end
    end
    
    -- 飞机的主动buff只在飞机开火时触发,并且一次只会带一个主动BUFF技能
    function self.triggerPlaneBuffs(plane)
        if not plane then return end

        for _,sid in pairs(plane.skills) do
            if planeSkillCfg[sid].isPassive == 1 then
                if planeCDCheck(planeSkillCfg[sid].CD,planeSkillCfg[sid].skillCD) then
                    local skillFunc = "planeSkill"..tostring(planeSkillCfg[sid].planeAnim)
                    if type(self[skillFunc]) == "function" then
                        self[skillFunc](plane,sid)
                    end
                    return sid
                end
            end
        end
    end

    local function openFire(attPlane,defender,target)
        self.triggerPlaneSkills(attPlane,attPlane,defender)
        local damage = math.abs(math.ceil(attPlane.dmg))
        defender.hp = defender.hp - damage

        local num
        if attPlane.role == ATTACKER_FLAGS then
            num = self.refreshDefTankNum(target)
        elseif attPlane.role == DEFENDER_FLAGS then
            num = self.refreshAttTankNum(target)
        end
    
        return damage, num 
    end

    -- 飞机单次攻击
    function self.planeSingleAttack(attPlane,defender,targets,skillId)
        local roundData = {}

        for id,target in pairs(targets) do
            if not self.slotHasTanks(defender,target) then break end

            local mtAttPlane = setmetatable({}, {__index = attPlane})
            if skillId then
                mtAttPlane.isTriggerSkill=skillId 
            end

            local damage,num = openFire(mtAttPlane,defender[target],target)
            local info = {damage = damage,num = num}
            table.insert(roundData,info)
        end

        local tmp = self.formatReport(roundData)
        if #tmp > 0 then table.insert(self.fjreport,tmp) end
    end

    -- 飞机攻击
    function self.planeAttack(attPlane,defender)
        if attPlane.hp <= 0 then return end

        -- 普攻目标按能量找同一个
        local targets = self.getPlaneTarget1(attPlane.energy,defender)
        if #targets < 1 then return end
        self.planeSingleAttack(attPlane,defender,targets)

        -- 攻击的目标数取配置
        targets = self.getPlaneTarget1(1,defender)
        if #targets > 0 then 
            -- 飞机开火后触发的buff
            local sid = self.triggerPlaneBuffs(attPlane)
            if sid then 
                targets = self.getPlaneTarget2(planeSkillCfg[sid].atkNum,defender)
                self.planeSingleAttack(attPlane,defender,targets,sid)
            end
        end
    end

    -- 飞机相关技能处理 end

    function self.doRound()
        local cycle = 1
        local m = 1
        local n = 1
        local slot = 1
        -- 防守方先出手
        if self.attSeq == 1 then
            while cycle<=6 do

                slot = self.getDefenderSlot(n)
                if slot>0 then
                    self.attack(slot,1)
                    n = slot + 1
                end

                slot = self.getAttackerSlot(m)
                if slot>0 then
                    self.attack(slot,0)
                    m = slot + 1
                end

                cycle = cycle + 1
            end

            if self.defPlane then
                self.planeAttack(self.defPlane,self.attacker)
            end

            if self.attPlane then
                self.planeAttack(self.attPlane,self.defender)
            end
        else
            while cycle<=6 do

                slot = self.getAttackerSlot(m)
                if slot>0 then
                    self.attack(slot,0)
                    m = slot + 1
                end

                slot = self.getDefenderSlot(n)
                if slot>0 then
                    self.attack(slot,1)
                    n = slot + 1
                end

                cycle = cycle + 1
            end

            if self.attPlane then
                self.planeAttack(self.attPlane,self.defender)
            end

            if self.defPlane then
                self.planeAttack(self.defPlane,self.attacker)
            end            
        end

        if self.attPlane then
            setPlaneEnergy(self.attPlane,planeCfg.plane[self.attPlane.id].resetRate)
        end 

        if self.defPlane then
            setPlaneEnergy(self.defPlane,planeCfg.plane[self.defPlane.id].resetRate)
        end
    end

    function self.doRoundOfWorldBoss()
        local cycle = 1
        local m = 1
        local n = 1
        local slot = 1
        
        while cycle<=6 do

            slot = self.getAttackerSlot(m)
            if slot>0 then
                self.attack(slot,0)
                m = slot + 1
            end

            cycle = cycle + 1
        end
    end

    function self.setAttSeq()
        local minPoint = 1000
        local attFirst = minPoint + (self.attSeqPoint and self.attSeqPoint.first or 0)
        local defFirst = minPoint + (self.defSeqPoint and self.defSeqPoint.first or 0)

        local antiAttFirst = self.attSeqPoint and self.attSeqPoint.antifirst or 0
        local antiDefFirst = self.defSeqPoint and self.defSeqPoint.antifirst or 0

        attFirst = attFirst - antiDefFirst
        defFirst = defFirst - antiAttFirst

        if attFirst < minPoint then attFirst = minPoint end
        if defFirst < minPoint then defFirst = minPoint end

        if tonumber(self.attSeq) and tonumber(self.attSeq) >= 10 then
            -- 指定了先手方
            self.attSeq = tonumber(self.attSeq)%2 
        elseif attFirst > defFirst then
            self.attSeq = 0
        elseif attFirst < defFirst then
            self.attSeq = 1
        end

        if not self.attSeq then 
            self.attSeq = 0
        end

        -- 角色先手信息
        self.roleFirstAttackInfo = {
            [ATTACKER_FLAGS]=(self.attSeq == 0),
            [DEFENDER_FLAGS]=self.attSeq == 1,
        } 

        return {attFirst, defFirst}
    end

    ------------------------------------------------------------------------------------------------------

    -- 攻击方使用飞机支援
    if self.attPropsConsume.p17 and self.round == 1 then
        self.airsupport(self.defender)
    end

     -- 攻击方使用buff 按n%给部队扣血
    if arguments.delhp and self.round == 1 then
        if arguments.delhpShowKey == "@2" then
            self.airsupport(self.attacker,2,arguments.delhp, arguments.delhpShowKey)
        else
            self.airsupport(self.defender,1,arguments.delhp, arguments.delhpShowKey)
        end
    end

    local firstPoint = self.setAttSeq()

    local round,result = 1,-1

    if arguments.boss then
        self.doRoundOfWorldBoss()
    else
        local maxbattleround=40
        if arguments.maxbattleround~=nil and tonumber(arguments.maxbattleround)>0 then
             maxbattleround=arguments.maxbattleround
        end    
        while round<=maxbattleround do
            self.doRound()

            result = self.checkBattle()

            if (result>0 or result<1) and result ~= 0  then
                break
            end

            --ptb:e(self.report)

            round = round + 1

            self.round = round
        end
    end

    -- writeLog(json.encode(self.debug))

    -- 如果是平局,判断进攻者失败
    if result == 0 then result = -1 end

    -- ptb:e(self.report)
    
    local rtnReport = {
        ab = reportAb,
        d = self.report,
        stats = getStatsReport(),
        bfs = reportBeforeSkill,
        fd = self.fjreport,
        fj = planeForClient,
        tender = tenderInfo.info,
        tds = tenderInfo.report,
    }

    if arguments.boss then
        return rtnReport,math.floor(self.deBossHp)
    end

    -- 损血统计
    countLoseHp()
    rtnData.defenderLossHpCount = self.defenderLossHpCount

    return rtnReport,result,self.attacker,self.defender,self.attSeq,firstPoint,self.round,rtnData
end


--[[
num      数量
type     类型
maxhp    最大血量
hp       血量
dmg      伤害
arm      护甲
salvo    齐射
crit     爆击
accuracy 精准
evade    闪避
]]

-- local attacker = {}
-- attacker[1] = {num=0,type=1,maxhp=150,hp=1500,dmg=500,anticrit=10,salvo=1,crit=0,accuracy=0,evade=0}
-- attacker[2] = {num=1,type=2,maxhp=150,hp=150,dmg=500,anticrit=10,salvo=2,crit=0,accuracy=0,evade=0}
-- attacker[3] = {num=1,type=3,maxhp=150,hp=150,dmg=500,anticrit=10,salvo=6,crit=0,accuracy=0,evade=0}
-- attacker[4] = {num=1,type=0,maxhp=150,hp=150,dmg=500,anticrit=10,salvo=1,crit=0,accuracy=0,evade=0}
-- attacker[5] = {num=1,type=0,maxhp=150,hp=150,dmg=500,anticrit=10,salvo=3,crit=0,accuracy=0,evade=0}
-- attacker[6] = {num=1,type=0,maxhp=150,hp=150,dmg=500,anticrit=10,salvo=1,crit=0,accuracy=0,evade=0}

--attacker[2] = {num=10,type=2,maxhp=150,hp=1500,dmg=50,anticrit=10,salvo=2,crit=0,accuracy=0,evade=0}
--attacker[3] = {num=10,type=3,maxhp=150,hp=1500,dmg=50,anticrit=10,salvo=6,crit=0,accuracy=0,evade=0}
--attacker[4] = {num=10,type=0,maxhp=150,hp=1500,dmg=50,anticrit=10,salvo=1,crit=0,accuracy=0,evade=0}
--attacker[5] = {num=10,type=0,maxhp=150,hp=1500,dmg=50,anticrit=10,salvo=3,crit=0,accuracy=0,evade=0}
--attacker[6] = {num=10,type=0,maxhp=150,hp=1500,dmg=50,anticrit=10,salvo=1,crit=0,accuracy=0,evade=0}


-- local defender = {}
-- defender[1] = {num=10,type=1,maxhp=150,hp=1500,dmg=500,anticrit=10,salvo=1,crit=0,accuracy=0,evade=0}
-- defender[2] = {num=1,type=2,maxhp=150,hp=150,dmg=500,anticrit=10,salvo=2,crit=0,accuracy=0,evade=0}
-- defender[3] = {num=1,type=3,maxhp=150,hp=150,dmg=500,anticrit=10,salvo=6,crit=0,accuracy=0,evade=0}
-- defender[4] = {num=1,type=0,maxhp=150,hp=150,dmg=500,anticrit=10,salvo=1,crit=0,accuracy=0,evade=0}
-- defender[5] = {num=1,type=0,maxhp=150,hp=150,dmg=500,anticrit=10,salvo=3,crit=0,accuracy=0,evade=0}
-- defender[6] = {num=1,type=0,maxhp=150,hp=150,dmg=500,anticrit=10,salvo=1,crit=0,accuracy=0,evade=0}

--defender[2] = {num=10,type=2,maxhp=150,hp=1500,dmg=50,anticrit=10,salvo=2,crit=0,accuracy=0,evade=0}
--defender[3] = {num=10,type=3,maxhp=150,hp=1500,dmg=50,anticrit=10,salvo=6,crit=0,accuracy=0,evade=0}
--defender[4] = {num=10,type=0,maxhp=150,hp=1500,dmg=50,anticrit=10,salvo=1,crit=0,accuracy=0,evade=0}
--defender[5] = {num=10,type=0,maxhp=150,hp=1500,dmg=50,anticrit=10,salvo=3,crit=0,accuracy=0,evade=0}
--defender[6] = {num=10,type=0,maxhp=150,hp=1500,dmg=50,anticrit=10,salvo=1,crit=0,accuracy=0,evade=0}

--battle(attacker,defender)

--[[
    public function isMissed($targetId)
    {
        $battle = battle::getInstance();
        $target = $battle->getObject($targetId);
        
        if(isset($target->evade))
        {
            $hit = $this->accuracy * $target->evade;
        }
        else
        {
            $hit = $this->accuracy;
        }
        
        if($hit>1)
        {
            return 0;
        }
        else
        {
            $miss = 1 - $hit;
        }
        
        $setting = array($miss*100,$hit*100);
        if($this->random($setting)==0)
        {
            return 1;
        }
        
        return 0;
    }
]]
