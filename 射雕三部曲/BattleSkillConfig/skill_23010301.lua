--普通攻击带特效
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

    local actionArray = {}


    for i, af in ipairs(params.to) do
        table.insert(actionArray, cc.CallFunc:create(function()
            local atkPos = bd.interface.getStandPos(af.posId)
            local zorder = -atkPos.y + 1

            atkPos.y = atkPos.y + 100 * bd.ui_config.MinScale

            if params.from > 6 then
                atkPos.x = atkPos.x + 400 * bd.ui_config.MinScale
            else
                atkPos.x = atkPos.x - 400 * bd.ui_config.MinScale
            end

            local atkEffect = bd.interface.newEffect({
                parent = nodeParent,
                effectName = "effect_wg_huanyinzhi",
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

            if params.from > 6 then
                atkEffect:setRotation3D(cc.vec3(0, 180, 0))
            end

            bd.adapter.audio.playSound("skill_huanyinzhi.mp3")
        end))

        if #params.to > 3 then
            table.insert(actionArray , cc.DelayTime:create(0.14 * math.floor(i / 3) ))
        else
            table.insert(actionArray , cc.DelayTime:create(0.11))
        end
    end

    nodeParent:runAction(cc.Sequence:create(actionArray))
end

local skillConfig = {
    res = {"effect_wg_huanyinzhi", },
    audio = {"skill_huanyinzhi.mp3"},
    excute = function(params)
        skill_func(params)
    end,
}
return skillConfig