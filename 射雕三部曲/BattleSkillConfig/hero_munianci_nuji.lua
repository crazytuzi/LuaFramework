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
        bd.adapter.audio.playSound("hero_munianci_nuji.mp3")
    end

    if params.dmgTimes == 5 then

        local nodeParent = params.data:get_battle_layer().heroPlant
        local atkPos = bd.interface.getStandPos(14)

        atkPos.y = atkPos.y - 100*bd.ui_config.MinScale

        if params.from > 6 then
            atkPos.x = atkPos.x - 100*bd.ui_config.MinScale
        else
            atkPos.x = atkPos.x + 300*bd.ui_config.MinScale
        end
       
        local atkEffect = bd.interface.newEffect({
                parent = nodeParent,
                effectName = "effect_nujidilie",
                scale = bd.ui_config.MinScale*0.4,
                position3D = atkPos,
                endRelease = true,
                
            })
        atkEffect:setLocalZOrder(-atkPos.y - bd.ui_config.diffz)
    end
end

local skill = {
    zhua = true,
    res = { },
    audio = {"hero_munianci_nuji.mp3"},
    excute = function(params)
        skill_func(params)
    end,
    explode = function(params)
        skill_func(params)
    end,
    type = bd.CONST.SkillType.Class1,
}

return skill
