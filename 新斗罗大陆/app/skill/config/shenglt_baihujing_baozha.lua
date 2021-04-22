-- 技能 白鲸自爆炸黑鲸10%
-- 技能ID 53285
--[[
	黑化虎鲸 4105
	升灵台
	psf 2020-4-13
]]--

local shenglt_baihujing_baozha = {
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

return shenglt_baihujing_baozha
