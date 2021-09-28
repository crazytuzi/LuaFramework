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

    -- 播放特效
    if params.dmgTimes == 2 then
        local nodeParent = params.data:get_battle_layer().heroPlant
        local atkPos = bd.interface.getStandPos(14)

        if params.from < 7 then
            atkPos.x = atkPos.x + 120 * bd.ui_config.MinScale
        else
            atkPos.x = atkPos.x + 80 * bd.ui_config.MinScale
        end

        atkPos.y = atkPos.y - 150 * bd.ui_config.MinScale
       
        local atkEffect = bd.interface.newEffect({
                parent = nodeParent,
                effectName = "effect_jiugongbaguazhang_nuji",
                scale = bd.ui_config.MinScale*0.25,
                position3D = atkPos,
                endRelease = true,
                
            })
        atkEffect:setLocalZOrder(-atkPos.y - bd.ui_config.diffz)
    end
end

local skill = {
    zhua = true,
    res = {"hero_jiugongbaguazhang", "effect_jiugongbaguazhang_nuji"},
    audio = {"hero_jiugongbaguazhang_nuji"},
    audiofunc = function()
        bd.adapter.audio.playSound("hero_jiugongbaguazhang_nuji.mp3")
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
