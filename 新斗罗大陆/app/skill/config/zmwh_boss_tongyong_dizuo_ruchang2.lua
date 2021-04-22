--斗罗SKILL 武魂底座入场2
--宗门武魂争霸
--id 51354
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
			OPTIONS = {effect_id = "zmwh_xuanwo_1", targetPosition = {x = 1200, y = 400}, ground_layer = true},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return zmwh_boss_tongyong_dizuo_ruchang

