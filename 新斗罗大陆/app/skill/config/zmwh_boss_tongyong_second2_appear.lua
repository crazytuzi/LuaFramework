--斗罗SKILL 漂浮物入场
--宗门武魂争霸
--id 51368
--通用 漂浮物
--[[
入场
]]--
--创建人：庞圣峰
--创建时间：2019-1-3

local zmwh_boss_tongyong_second2_appear = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
     	{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "zmwh_boss_piaofuwu_mark"},
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
return zmwh_boss_tongyong_second2_appear