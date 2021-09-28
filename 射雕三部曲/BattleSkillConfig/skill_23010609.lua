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

   local atkPos = bd.interface.getStandPos(14)

    atkPos.y = atkPos.y - 100 * bd.ui_config.MinScale

    if params.from < 7 then
        atkPos.x = atkPos.x + 200 * bd.ui_config.MinScale
    else
        atkPos.x = atkPos.x - 200 * bd.ui_config.MinScale
    end

    local atkEffect = bd.interface.newEffect({
        parent = nodeParent,
        effectName = "effect_wg_yiqihuasanqing",
        scale = bd.ui_config.MinScale,
        position3D = atkPos,
        eventListener = function(p)
            local value = bd.interface.getActionValue_daji(p.event.stringValue)
            if value and params.attackCallback then
                params.attackCallback(value, af)
            end
        end,
    })
    atkEffect:setLocalZOrder(bd.ui_config.diffz)

    bd.adapter.audio.playSound("skill_yiqihuasanqing.mp3")
end

local skillConfig = {
    zhua = true,
    res = {"effect_wg_yiqihuasanqing", },
    audio = {"skill_yiqihuasanqing.mp3"},
    excute = function(params)
        skill_func(params)
    end,
}
return skillConfig