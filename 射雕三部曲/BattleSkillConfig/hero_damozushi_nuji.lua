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
    -- 合体技时不释放特效
    if (params.from < 7) ~= (params.to[1].posId < 7) then
        for i, af in ipairs(params.to) do
            if params.attackCallback then
                params.attackCallback(1, af)
            end
        end
        return
    end

    local tmpShake = {0, -15, 0, 1}
    --仅仅执行页面抖动
    bd.interface.shakeTimes({node = bd.layer,
        time = 3,
        direction = cc.vec3(rotationY and -tonumber(tmpShake[1]) or tonumber(tmpShake[1]), rotationX and -tonumber(tmpShake[2]) or tonumber(tmpShake[2]), tonumber(tmpShake[3])),
        duration = 0.1
    })

    local nodeParent = params.data:get_battle_layer().heroPlant

    local atkPos = bd.interface.getStandPos(params.from)
    atkPos.x = atkPos.x + 60*bd.ui_config.MinScale
    atkPos.y = atkPos.y + 60*bd.ui_config.MinScale
   
    local atkEffect = bd.interface.newEffect({
            parent = nodeParent,
            effectName = "effect_damozushi_nuji",
            animation = "nuji",
            -- scale = bd.ui_config.MinScale*0.8,
            position3D = atkPos,
            endRelease = true,
            
        })
    atkEffect:setLocalZOrder(-atkPos.y - bd.ui_config.diffz)

    local actionArray = {}
    for i, af in ipairs(params.to) do
        table.insert(actionArray, cc.CallFunc:create(function()
            local atkPos = bd.interface.getStandPos(af.posId)
            local zorder = -atkPos.y + 1

            local atkEffect = bd.interface.newEffect({
                parent = nodeParent,
                effectName = "effect_zhiliao",
                animation = "shang",
                scale = bd.ui_config.MinScale,
                position3D = atkPos,
                eventListener = function(p)
                    local value = bd.interface.getActionValue_daji(p.event.stringValue)
                    if value and params.attackCallback then
                        params.attackCallback(value, af)
                    end
                end,
            })
            atkEffect:setLocalZOrder(zorder)

            local inciEffect = bd.interface.newEffect({
                parent = nodeParent,
                effectName = "effect_zhiliao",
                animation = "xia",
                scale = bd.ui_config.MinScale,
                position3D = atkPos,
            })
            inciEffect:setLocalZOrder(zorder - 2)
            
            bd.adapter.audio.playSound("common_zhiliao.mp3")
        end))

        if #params.to > 3 then
            table.insert(actionArray , cc.DelayTime:create(0.14 * math.floor(i / 3) ))
        else
            table.insert(actionArray , cc.DelayTime:create(0.11))
        end
    end

    nodeParent:runAction(cc.Sequence:create(actionArray))
end

local skill = {
    res = {"effect_zhiliao", "effect_damozushi_nuji" },
    audio = {"common_zhiliao.mp3"},
    excute = function(params)
        skill_func(params)
    end,
    explode = function(params)
        skill_func(params)
    end,
    type = bd.CONST.SkillType.Class1,
}

return skill
