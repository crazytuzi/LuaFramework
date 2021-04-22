--斗罗SKILL 禁锢牢笼入场
--宗门武魂争霸
--id 51369
--通用 牢笼
--[[
入场
]]--
--创建人：庞圣峰
--创建时间：2019-1-3

local zmwh_boss_tongyong_third1_appear = 
{
     CLASS = "composite.QSBParallel",
     ARGS = 
     {
     	{
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack21"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "zmwh_boss_laolong_mark"},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return zmwh_boss_tongyong_third1_appear