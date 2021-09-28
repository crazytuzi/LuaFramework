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

    -- 播放音效
    if params.dmgTimes == 2 then
        local nodeParent = params.data:get_battle_layer().heroPlant
        local atkPos = bd.interface.getStandPos(14)
        
        atkPos.x = atkPos.x + 50 * bd.ui_config.MinScale
        atkPos.y = atkPos.y - 120 * bd.ui_config.MinScale
        
        local atkEffect = bd.interface.newEffect({
                parent = nodeParent,
                effectName = "effect_bihaichaoshenqu_nuji",
                animation = "nuji",
                scale = 0.8,
                position3D = atkPos,
                endRelease = true,
                
            })
        atkEffect:setLocalZOrder(-atkPos.y - bd.ui_config.diffz)

        if params.from > 6 then
            atkEffect:setRotation3D(cc.vec3(0, 180, 0))
        end
    end
end

local skill = {
    zhua = true,
    res = {"effect_bihaichaoshenqu_nuji"},
    audio = {"hero_bihaichaoshenqu_nuji.mp3"},
    audiofunc = function()
        bd.adapter.audio.playSound("hero_bihaichaoshenqu_nuji.mp3")
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
