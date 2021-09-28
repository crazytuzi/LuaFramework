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

    f_pos = bd.interface.getStandPos(14)
    zorderpos = bd.interface.getStandPos(14)

    local atkEffect = bd.interface.newEffect({
        parent = nodeParent,
        effectName = "effect_wg_yiyangzhi",
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

    if params.from > 6 then
        atkEffect:setRotation3D(cc.vec3(0, 180, 0))
    end

    bd.adapter.audio.playSound("skill_yiyangzhi.mp3")
end

local skillConfig = {
    res = {"effect_wg_yiyangzhi", },
    audio = {"skill_yiyangzhi.mp3"},    
    excute = function(params)
        skill_func(params)
    end,
}

return skillConfig