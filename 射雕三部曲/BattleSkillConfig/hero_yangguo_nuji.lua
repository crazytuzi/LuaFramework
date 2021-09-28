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

    if params.dmgTimes == 1 then
        bd.adapter.audio.playSound("hero_yangguo_nuji.mp3")

        local p1, p2, _ = bd.func.getRow(params.to[1].posId)
        local nodeParent = params.data:get_battle_layer().heroPlant

        local zorderPos = bd.interface.getStandPos(p1)
        local f_pos = bd.interface.getStandPos(p2)
        if p2 <= 6 then
            f_pos.x = f_pos.x + 300
        else
            f_pos.x = f_pos.x - 300
        end
        f_pos.y = f_pos.y + 200
        
        local atkEffect = bd.interface.newEffect({
            parent = nodeParent,
            effectName = "effect_yangguo_nuji",
            animation = "zi",
            scale = bd.ui_config.MinScale,
            position3D = f_pos,
            endRelease = true,
            
        })
        atkEffect:setLocalZOrder(bd.ui_config.zOrderScreen)
    end
end

local skill = {
    zhua = true,
    res = {"effect_yangguo_nuji",},
    audio = {"hero_yangguo_nuji.mp3"},
    excute = function(params)
        skill_func(params)
    end,
    explode = function(params)
        skill_func(params)
    end,
}

return skill
