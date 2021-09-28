local table_insert = table.insert
local table_sort   = table.sort
local pairs        = pairs
local ipairs       = ipairs
local next         = next


local BattleParse = class("BattleParse", function()
    return {}
end)

function BattleParse:ctor(params)
    --重置统计计算
    self.layer = params.battleLayer
    self.data = params.battleData
end


-- @获取关卡数据初始化逻辑中心
function BattleParse:coreInit(params)
    local battleData = self.data

    -- 初始化逻辑计算中心
    local core = require("ComBattle.Process.BattleCalc").new({
        battleLayer = battleData:get_battle_layer(),
        thread      = bd.CONST.thread,
    })
    battleData:set_battle_LogicCore(core)

    core:init(params.data, function(result)
        bd.log.debug(result, "core[init]")

        result.FightAtom = self:loadFightAtom(result)
        result.RoundPet  = self:loadPetAtom(result.Pet)
        result.StartPet  = self:loadFightAtom(result.Pet2)

        if result.Pet3 then
            result.ZhenShou = self:loadPet3Atom(result.Pet3)
        end

        result.Pet = nil
        result.Pet2 = nil
        result.Pet3 = nil

        params.callback(result)
    end)
end


-- @逻辑计算下一步数据
--[[
    params:
        posId       使用技能的位置id
        callback    完成回调
    return:
        NULL
]]
function BattleParse:coreNext(params)
    local tmp = {
        autoPlay = params.autoPlay,
        skill    = params.skill,
        multi    = params.multi,
    }

    self.data:get_battle_LogicCore():calc(tmp, function(result)
        bd.log.debug(result, "core[calc]")


        result.FightAtom = self:loadFightAtom(result.FightAtom)
        result.RoundPet = self:loadPetAtom(result.Pet)
        result.StartPet = self:loadFightAtom(result.Pet2)

        if result.Pet3 then
            result.ZhenShou = self:loadPet3Atom(result.Pet3)
        end

        result.Pet = nil
        result.Pet2 = nil
        result.Pet3 = nil

        params.callback(result)
    end)
end


-- @解析数据
function BattleParse:loadFightAtom(atoms)
    if not atoms or (not next(atoms)) then
        return nil
    end

    local result = {}
    for k, v in ipairs(atoms) do
        if next(v) then
            if v.atomType == bd.adapter.config.atomType.eATTACK then
                result[k] = self:loadAttackAtom(v)
            elseif v.atomType == bd.adapter.config.atomType.eSTATE then
                result[k] = self:loadStateAtom(v)
            elseif v.atomType == bd.adapter.config.atomType.eVALUE then
                bd.log.dataerr("There is a value-type atom in FightAtom.")
            end
        else
            bd.log.dataerr("There is an empty atom.")
        end
    end

    return next(result) and result
end



-- @解析攻击动作数据
function BattleParse:loadAttackAtom(atom)
    local result = {
        type    = atom.atomType,
        skillId = atom.skillId,
        from    = { posId = atom.fromPos },
        to      = {},
        onExec  = {},
    }

    if atom.rp then
        -- 一般为普攻后增长怒气
        if atom.rp > 0 then
            table_insert(result.onExec, {
                type  = bd.adapter.config.atomType.eVALUE,
                rp    = atom.rp,
                toPos = atom.fromPos,
            })

        -- 一般为施法时，怒气减少
        elseif atom.rp < 0 then
            result.rp = {
                type  = bd.adapter.config.atomType.eVALUE,
                rp    = atom.rp,
                toPos = atom.fromPos,
            }
        end
    end

    -- 遍历每个目标
    for k, targetAtoms in ipairs(atom.to) do
        -- 目标的响应事件
        local to = {}
        local toBeforeExec, toOnExec, toAfterExec = self:loadToList(targetAtoms, to)

        if to.value then
            to.value = to.value[1]
        end

        to.posId      = to.value.posId
        to.beforeExec = next(toBeforeExec) and toBeforeExec
        to.onExec     = next(toOnExec) and toOnExec
        to.afterExec  = next(toAfterExec) and toAfterExec

        table_insert(result.to, to)
    end

    return result
end


-- @解析BUFF动作数据
function BattleParse:loadStateAtom(atom)
    -- 响应事件
    local result = {
        type      = atom.atomType,
        stateType = atom.type,
        posId     = atom.toPos,
        buffId    = atom.buffId,
        uniqueId  = atom.uniqueId,
        toPos     = atom.toPos,
        fromPos   = atom.fromPos,
        start     = atom.isStart,
        -- pet       = atom.isPet,
    }

    if atom.type == bd.adapter.config.atomBuffType.eEXEC then
        result.beforeExec, result.onExec, result.afterExec
            = self:loadToList(atom.exec, result)

        result.beforeExec = next(result.beforeExec) and result.beforeExec
        result.onExec     = next(result.onExec) and result.onExec
        result.afterExec  = next(result.afterExec) and result.afterExec
    end

    return result
end


-- @解析数值atom
function BattleParse:loadValueAtom(atom)
    local value, dead = nil, nil

    -- 导致死亡
    if atom.dead then
        dead = {
            from = atom.dead.from,
            to   = atom.toPos,
            rp   = atom.dead.rp,
        }
    end

    -- 数值变化
    value = {
        type   = atom.atomType,
        effect = atom.effet
                or (atom.orghp and (atom.orghp < 0)
                    and bd.adapter.config.damageType.eNORMAL
                    or bd.adapter.config.damageType.eHEAL),
        hp     = atom.hp,
        orghp  = atom.orghp,
        rp     = atom.rp,
        posId  = atom.toPos,
        dead   = dead,

        -- 特殊状态
        unDead = atom.unDead,
        zhiming = atom.zhiming,
        rebirth = atom.rebirth,
    }

    return value
end


-- @解析一个atom的列表
function BattleParse:loadToList(atomList, result)
    -- 响应事件
    local beforeExec, onExec, afterExec = {}, {}, {}

    local stage = beforeExec
    for _, atom in ipairs(atomList) do
        -- 数值变化
        if atom.atomType == bd.adapter.config.atomType.eVALUE then
            stage = onExec
            if not result.value then
                result.value = {}
            end
            table_insert(result.value, self:loadValueAtom(atom))
            stage = afterExec
        -- BUFF改变
        elseif atom.atomType == bd.adapter.config.atomType.eSTATE then
            local atom = self:loadStateAtom(atom)
            table_insert(stage, atom)
        -- 攻击
        elseif atom.atomType == bd.adapter.config.atomType.eATTACK then
            table_insert(stage, self:loadAttackAtom(atom))
        end
    end

    return beforeExec, onExec, afterExec
end


-- @加载回合技数据（宠物）
function BattleParse:loadPetAtom(data)
    if not data then
        return nil
    end

    local result = {}
    for i, v in ipairs(data) do
        if next(v) then
            for j, atom in ipairs(v) do
                v[j] = self:loadStateAtom(atom)
            end
            table_insert(result, v)
        end
    end

    return next(result) and result or nil
end

function BattleParse:loadPet3Atom(data)
    if not data then
        return nil
    end

    local function fixPetFromPos(fromPos)
        if fromPos > 6 then
            fromPos = fromPos - 6
        end

        local  newPos = fromPos + bd.ui_config.petBase

        return newPos
    end

    local result = {}
    result.nextPet3 = data.nextPet3
    for i, v in ipairs(data) do
        result[i] = {
            isPet3  = true,
            skillId = v.skillId,
            type    = bd.adapter.config.atomType.eATTACK,
            from    = { posId = fixPetFromPos(v.fromPos) },
            to      = {},
            onExec  = {},
        }
        for k, v in ipairs(v.to) do
            local to = {}
            local toBeforeExec, toOnExec, toAfterExec = self:loadToList(v.exec, to)
            if to.value then
                to.value = to.value[1]
            end
            to.posId      = to.value and to.value.posId or (v.exec and v.exec[1] and v.exec[1].toPos)
            to.beforeExec = next(toBeforeExec) and toBeforeExec
            to.onExec     = next(toOnExec) and toOnExec
            to.afterExec  = next(toAfterExec) and toAfterExec

            if to.posId then
                table_insert(result[i].to, to)
            end
        end
    end

    return result
end


return BattleParse
