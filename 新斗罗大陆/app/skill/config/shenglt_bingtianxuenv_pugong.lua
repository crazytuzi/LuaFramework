-- 技能 冰天雪女普攻
-- 技能ID 53316
-- 冰极无双：随机多子弹技能，有概率给目标上一层【冰锁】状态，降低目标回怒速度，持续X秒（冰锁最多可叠加3层）
--[[
	翠魔鸟王 4125
	升灵台
	psf 2020-4-13
]]--


local shenglt_bingtianxuenv_pugong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {--[[effect_id = "bingtianxuenv_attack01_1",]] is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 111,y = 100},},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 25},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {target_random = true, start_pos = {x = 111,y = 100},},
				},
            },
        },
    },
}

return shenglt_bingtianxuenv_pugong