--横排攻击带特效
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

    -- local p1, p2, _ = bd.func.getRow(params.to[1].posId)

    local zorderPos = bd.interface.getStandPos(14)
    local f_pos = bd.interface.getStandPos(14)

    f_pos.y = f_pos.y + 60 * bd.ui_config.MinScale

    if params.from > 6 then
        f_pos.x = f_pos.x + 200 * bd.ui_config.MinScale
    else
        f_pos.x = f_pos.x - 200 * bd.ui_config.MinScale
    end

    local atkEffect = bd.interface.newEffect({
        parent = nodeParent,
        effectName = "effect_wg_jinggangzhang",
        scale = bd.ui_config.MinScale*1.7,
        position3D = f_pos,
        endRelease = true,
        eventListener = function(p)
            local value = bd.interface.getActionValue_daji(p.event.stringValue)
            if value and params.attackCallback then
                params.attackCallback(value, af)
            end
        end,
    })
    atkEffect:setLocalZOrder(-zorderPos.y + 1)

    if params.from > 6 then
        atkEffect:setRotation3D(cc.vec3(0, 180, 0))
    end

    bd.adapter.audio.playSound("skill_jinggangzhang.mp3")
end

local skillConfig = {
    zhua = true,
    res = {"effect_wg_jinggangzhang", },
    audio = {"skill_jinggangzhang.mp3"},    
    excute = function(params)
        skill_func(params)
    end,
}

return skillConfig