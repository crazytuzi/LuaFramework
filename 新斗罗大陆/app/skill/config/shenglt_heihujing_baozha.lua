-- 技能 黑鲸自爆炸白鲸
-- 技能ID 53284
--[[
	黑化虎鲸 4104
	升灵台
	psf 2020-4-13
]]--

local shenglt_heihujing_baozha = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 3},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    	{
    		CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 18},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "shuibinger_attack12_3"},
                }, 
        	},
    	},
    },
}

return shenglt_heihujing_baozha
