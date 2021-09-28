--全体攻击带特效
--[[
    params:
        layer           数据源
        data            战斗数据
        attackCallback  伤害结算函数
        event           动作数据
        count           执行次数
    return:
        NULL
]]
local function skill_func(params)
    local nodeParent = params.data:get_battle_layer().heroPlant

    local f_pos = nil
    local zorderpos = nil

    if bd.interface.isEnemy(params.from) then
        --敌方放技能。
        f_pos = bd.interface.getStandPos(5)
        zorderpos = bd.interface.getStandPos(4)
    else
        f_pos = bd.interface.getStandPos(8)
        zorderpos = bd.interface.getStandPos(7)
    end

    local atkEffect = bd.interface.newEffect({
        parent = nodeParent,
        effectName = "effect_wg_shaolinquan",
        scale = bd.ui_config.MinScale,
        position3D = f_pos,
        endRelease = true,
        eventListener = function(p)
            local value = bd.interface.getActionValue_daji(p.event.stringValue)
            if value and params.attackCallback then
                params.attackCallback(value, af)
            end
        end,
    })
    atkEffect:setLocalZOrder(-zorderpos.y + 1)

    bd.adapter.audio.playSound("skill_shaolinquan.mp3")
end

local skillConfig = {
    res = {"effect_wg_shaolinquan", },
    audio = {"skill_shaolinquan.mp3"},    
    excute = function(params)
        skill_func(params)
    end,
}

return skillConfig