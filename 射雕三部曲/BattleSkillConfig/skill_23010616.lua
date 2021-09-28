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

    local f_pos = bd.interface.getStandPos(14)

    f_pos.y = f_pos.y - 100 * bd.ui_config.MinScale

    if params.from < 7 then
        f_pos.x = f_pos.x + 200 * bd.ui_config.MinScale
    end

    local atkEffect = bd.interface.newEffect({
        parent = nodeParent,
        effectName = "effect_wg_liuyangfentianjue",
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
    atkEffect:setRotation3D(cc.vec3(0, params.from < 7 and 0 or 180, 0))
    atkEffect:setLocalZOrder(bd.ui_config.diffz)

    bd.adapter.audio.playSound("skill_liuyangfentianjue.mp3")
end

local skillConfig = {
    zhua = true,
    res = {"effect_wg_liuyangfentianjue", },
    audio = {"skill_liuyangfentianjue.mp3"},    
    excute = function(params)
        skill_func(params)
    end,
}

return skillConfig