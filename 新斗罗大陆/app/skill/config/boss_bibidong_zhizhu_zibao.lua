-- 技能 BOSS比比东 蜘蛛自爆
-- 技能ID 50838
-- 自爆AOE 目标中毒
--[[
	boss 比比东 
	ID:3681 副本14-16
	psf 2018-7-5
]]--

local boss_bibidong_zhizhu_zibao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
	    {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 1.2},
				},
				{
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "renmianmozhu3_dead_3_035" , is_hit_effect = false },
                        },
                    },
                },
				{
					CLASS = "action.QSBAttackFinish"
				},
            },
        },
    },
}

return boss_bibidong_zhizhu_zibao