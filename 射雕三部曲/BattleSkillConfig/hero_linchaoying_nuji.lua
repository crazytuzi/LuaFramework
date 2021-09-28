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
    params.attackCallback(1)

    local tmpShake = {0, -15, 0, 1}
    --仅仅执行页面抖动
    bd.interface.shakeTimes({node = bd.layer,
        time = 3,
        direction = cc.vec3(rotationY and -tonumber(tmpShake[1]) or tonumber(tmpShake[1]), rotationX and -tonumber(tmpShake[2]) or tonumber(tmpShake[2]), tonumber(tmpShake[3])),
        duration = 0.1
    })

    local nodeParent = params.data:get_battle_layer().heroPlant

    local f_pos = bd.interface.getStandPos(14)

    f_pos.y = f_pos.y - 100*bd.ui_config.MinScale


    if params.dmgTimes == 2 then
        local dimianEffect = bd.interface.newEffect({
            parent = nodeParent,
            zorder = -1,
            effectName = "effect_linchaoying_nuji",
            animation = "dilie1",
            scale = bd.ui_config.MinScale,
            position3D = f_pos,
            endRelease = true,
        })
        dimianEffect:setRotation3D(cc.vec3(0, params.from >= 7 and 180 or 0, 0))
        dimianEffect:setLocalZOrder(-f_pos.y)
    elseif params.dmgTimes == 3 then
        local dimianEffect = bd.interface.newEffect({
            parent = nodeParent,
            zorder = -1,
            effectName = "effect_linchaoying_nuji",
            animation = "dilie2",
            scale = bd.ui_config.MinScale,
            position3D = f_pos,
            endRelease = true,
        })
        dimianEffect:setRotation3D(cc.vec3(0, params.from >= 7 and 180 or 0, 0))
        dimianEffect:setLocalZOrder(-f_pos.y)
    end
end

local skill = {
    zhua = true,
    res = { },
    audio = {"hero_linchaoying_nuji.mp3"},
    audiofunc = function()
        bd.adapter.audio.playSound("hero_linchaoying_nuji.mp3")
    end,
    excute = function(params)
        skill_func(params)
    end,
    explode = function(params)
        skill_func(params)
    end,
    type = bd.CONST.SkillType.Class1,
}

return skill
