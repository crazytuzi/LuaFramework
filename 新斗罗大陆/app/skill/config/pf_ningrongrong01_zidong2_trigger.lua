-- 技能 宁荣荣 九宝有名触发治疗
-- 技能ID 305
-- 在九宝有名BUFF下 每次普攻触发该技能,加一次血
--[[
	hero 宁荣荣
	ID:1027 
	psf 2018-9-10
]]--


local ningrongrong_zidong2_trigger = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = true},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return ningrongrong_zidong2_trigger