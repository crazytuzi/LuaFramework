--普攻和技攻统一处理

local BattleAtom = {}

--[[
    params:
        <atoms>         -- 需要执行的atom
        <battleData>    --
        [callback]

        [other]         -- 其他输入参数
    return:
        NULL
]]
function BattleAtom.execute(params)
    local done_ = params.callback or function() end

    local atoms = params.atoms
    if (not atoms) or (next(atoms) == nil) then
        return done_()
    end

    local battleData = params.battleData

    -- 顺序执行每一个atom
    bd.func.eachSeries(atoms, function(cont, atom)
        -- 人物攻击（技能、普攻）
        if atom.type == bd.adapter.config.atomType.eATTACK then
            BattleAtom.executeAttack(atom, battleData, params.other, function()
                cont()
            end)

        -- BUFF效果
        elseif atom.type == bd.adapter.config.atomType.eSTATE then
            BattleAtom.executeState(atom, battleData, params.other, function()
                cont()
            end)

        -- 数值变化
        elseif atom.type == bd.adapter.config.atomType.eVALUE then
            BattleAtom.executeValue(atom, battleData, params.other, function()
                cont()
            end)
        end
    end, done_)
end

function BattleAtom.executeAtom(cont, atom, battleData, params)
    -- 人物攻击（技能、普攻）
    if atom.type == bd.adapter.config.atomType.eATTACK then
        BattleAtom.executeAttack(atom, battleData, params.other, function()
            cont()
        end)

    -- BUFF效果
    elseif atom.type == bd.adapter.config.atomType.eSTATE then
        BattleAtom.executeState(atom, battleData, params.other, function()
            cont()
        end)

    -- 数值变化
    elseif atom.type == bd.adapter.config.atomType.eVALUE then
        BattleAtom.executeValue(atom, battleData, params.other, function()
            cont()
        end)
    end
end


-- 攻击动作atom
local AttackAtom = require("ComBattle.Atom.AttackAtom")
function BattleAtom.executeAttack(attack, battleData, params, cb)
    return BattleAtom.doExecuteAtom(AttackAtom, attack, battleData, params, cb)
end


-- 状态变化atom
local StateAtom = require("ComBattle.Atom.StateAtom")
function BattleAtom.executeState(state, battleData, params, cb)
    return BattleAtom.doExecuteAtom(StateAtom, state, battleData, params, cb)
end


-- 数值变化atom
local ValueAtom = require("ComBattle.Atom.ValueAtom")
function BattleAtom.executeValue(value, battleData, params, cb)
    return BattleAtom.doExecuteAtom(ValueAtom, value, battleData, params, cb)
end


function BattleAtom.doExecuteAtom(atomExecuter, atom, battleData, params, cb)
    local before_, on_, after_
    if atom.beforeExec and next(atom.beforeExec) then
        before_ = function(cont, params)
            BattleAtom.execute({
                atoms      = atom.beforeExec,
                other      = params,
                battleData = battleData,
                callback   = cont,
            })
        end
    end

    if atom.onExec and next(atom.onExec) then
        on_ = function(cont, params)
            BattleAtom.execute({
                atoms      = atom.onExec,
                other      = params,
                battleData = battleData,
                callback   = cont,
            })
        end
    end

    if atom.afterExec and next(atom.afterExec) then
        after_ = function(cont, params)
            BattleAtom.execute({
                atoms      = atom.afterExec,
                other      = params,
                battleData = battleData,
                callback   = cont,
            })
        end
    end

    -- 开始执行
    return atomExecuter.execute({
        atom       = atom,
        battleData = battleData,
        callback   = cb,
        other      = params,
        beforeExec = before_,
        onExec     = on_,
        afterExec  = after_,
    })
end



-- @执行单个死亡动作
function BattleAtom.dead(battleData, dead, cb)
    local node = battleData:getHeroNode(dead.to)
    if node then
        node.isDead_ = true
        node:action_death({
            hitcallback = dead.rp and function()
                battleData:fixRP({
                    posId = dead.from,
                    value = dead.rp,
                    type = true,
                })
            end,
            callback = function()
                battleData:emit(bd.event.eHeroDeadActionEnd, dead.to, dead)
                return cb and cb()
            end,
        })
    else
        bd.log.debug(TR("<act dead>(%d->%d) 无法找到目标(%d)", dead.from, dead.to, dead.to))
    end

    -- 触发死亡事件
    battleData:emit(bd.event.eHeroDead, dead.to, dead)
end


return BattleAtom
