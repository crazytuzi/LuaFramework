--斗罗SKILL 守卫入场
--宗门武魂争霸
--id 51367
--通用 守卫
--[[
入场,上守卫光环
]]--
--创建人：庞圣峰
--创建时间：2019-1-3

local zmwh_boss_tongyong_first2_appear = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
     	{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "zmwh_boss_shouwei_mark"},
        },
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "zmwh_boss_tongyong_first2_buff"},
        },
		{
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack21"},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return zmwh_boss_tongyong_first2_appear