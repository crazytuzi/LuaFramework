-- 技能 宁荣荣 护盾触发治疗
-- 技能ID 306
-- 护盾消失时触发此技能, 治疗一下
--[[
	hero 宁荣荣
	ID:1027 
	psf 2018-9-10
]]--



local ningrongrong_beidong2_trigger = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
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

return ningrongrong_beidong2_trigger