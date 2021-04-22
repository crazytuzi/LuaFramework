-- 技能 菊花怪 菊花分株
-- ID 50905
-- 恐惧周围, 治疗自己
--[[
	BOSS 幻境泰坦巨猿
	ID:3708
	psf 2018-7-26
]]--


local boss_taitanjuyuan_chuixionghou = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 6, duration = 0.1, count = 5,},
                                },
                            },
                        },
                    },
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
					OPTIONS = {delay_frame = 26},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_taitanjuyuan_zhiliao_buff", is_target = false},
				},
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}

return boss_taitanjuyuan_chuixionghou