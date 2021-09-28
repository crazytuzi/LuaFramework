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
    local f_pos = bd.interface.getStandPos(14)

    if p1 > 6 then
        f_pos.x = f_pos.x + 200 * bd.ui_config.MinScale
    else 
        f_pos.x = f_pos.x - 100 * bd.ui_config.MinScale
    end
    f_pos.y = f_pos.y - 60 * bd.ui_config.MinScale

    local atkEffect = bd.interface.newEffect({
        parent = nodeParent,
        effectName = "effect_zhangsanfeng_nuji",
        animation = "nuji",
        scale = bd.ui_config.MinScale,
        position3D = cc.p(f_pos.x, f_pos.y + 60 * bd.ui_config.MinScale),
        endRelease = true,
        eventListener = function(p)
            local value = bd.interface.getActionValue_daji(p.event.stringValue)
            if value and params.attackCallback then
                params.attackCallback(value, af)

                local endEffect = bd.interface.newEffect({
                    parent = nodeParent,
                    effectName = "effect_zhangsanfeng_nuji",
                    animation = "jingtou",
                    scale = bd.ui_config.MinScale,
                    position3D = cc.p(display.cx, display.cy),
                    endRelease = true
                    })
            end

        end,
    })
    atkEffect:setLocalZOrder(bd.ui_config.diffz)

    local atkEffect1 = bd.interface.newEffect({
        parent = nodeParent,
        effectName = "effect_zhangsanfeng_nuji",
        animation = "xiaceng",
        scale = bd.ui_config.MinScale,
        position3D = f_pos,
        endRelease = true
    })
    atkEffect1:setLocalZOrder(-zorderPos.y - bd.ui_config.diffz)

end

local skill = {
    zhua = true,
    res = {"effect_zhangsanfeng_nuji"},
    audio = {"hero_zhangsanfeng_nuji.mp3"},
    audiofunc = function ()
        bd.adapter.audio.playSound("hero_zhangsanfeng_nuji.mp3")
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
