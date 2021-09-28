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
    local tmpShake = {0, -15, 0, 1}
    --仅仅执行页面抖动
    bd.interface.shakeTimes({node = bd.layer,
        time = 3,
        direction = cc.vec3(rotationY and -tonumber(tmpShake[1]) or tonumber(tmpShake[1]), rotationX and -tonumber(tmpShake[2]) or tonumber(tmpShake[2]), tonumber(tmpShake[3])),
        duration = 0.1
    })

    local nodeParent = params.data:get_battle_layer().heroPlant

    local zorderPos = bd.interface.getStandPos(14)
    local f_pos = bd.interface.getStandPos(14)

    f_pos.y = f_pos.y + 60 * bd.ui_config.MinScale
    f_pos.x = f_pos.x + 100 * bd.ui_config.MinScale

    local atkEffect = bd.interface.newEffect({
        parent = nodeParent,
        effectName = "effect_jinlinghualong_nuji",
        animation = "nuji",
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
    atkEffect:setLocalZOrder(bd.ui_config.diffz)

    if params.from > 6 then
        atkEffect:setRotation3D(cc.vec3(0, 180, 0))
    end
end

local skill = {
    zhua = true,
    res = {"effect_jinlinghualong_nuji"},
    audio = {"hero_jinlinghualong_nuji.mp3"},
    audiofunc = function()
        bd.adapter.audio.playSound("hero_jinlinghualong_nuji.mp3")
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
