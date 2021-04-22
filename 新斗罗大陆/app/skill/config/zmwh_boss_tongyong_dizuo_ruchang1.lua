--斗罗SKILL 武魂底座入场1
--宗门武魂争霸
--id 51353
--通用 底座
--创建人：庞圣峰
--创建时间：2019-1-12

local zmwh_boss_tongyong_dizuo_ruchang = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "dizuotexiao_1"},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return zmwh_boss_tongyong_dizuo_ruchang

