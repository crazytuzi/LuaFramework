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

    local p1, p2, _ = bd.func.getRow(params.to[1].posId)

    local zorderPos = bd.interface.getStandPos(p1)
    local f_pos = bd.interface.getStandPos(p2)

    f_pos.y = f_pos.y + 60 * bd.ui_config.MinScale

    local atkEffect = bd.interface.newEffect({
        parent = nodeParent,
        effectName = "effect_guojing_nuji",
        animation = "nuji",
        scale = bd.ui_config.MinScale*0.2,
        position3D = f_pos,
        endRelease = true,
        eventListener = function(p)
            local value = bd.interface.getActionValue_daji(p.event.stringValue)
            if value and params.attackCallback then
                params.attackCallback(value, af)
            end
        end,
    })
    atkEffect:setLocalZOrder(-zorderPos.y + 400)

    if params.from > 6 then
        atkEffect:setRotation3D(cc.vec3(0, 180, 0))
    end
end

local skillConfig = {
    res = {"effect_guojing_nuji", },
    audio = {"hero_guojing_nuji.mp3"},
    audiofunc = function()
        bd.adapter.audio.playSound("hero_guojing_nuji.mp3")
    end,
    excute = function(params)
        skill_func(params)
    end,
}

return skillConfig