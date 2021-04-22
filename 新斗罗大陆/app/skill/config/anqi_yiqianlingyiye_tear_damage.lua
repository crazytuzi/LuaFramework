-- 技能 暗器 一千零一夜 拔针伤害
-- 技能ID 40311~40315
-- 造成伤害并附加偷攻速BUFF anqi_yiqianlingyiye_steal_buff
--[[
	暗器 一千零一夜
	ID:1520
	psf 2019-2-16
]]--

local anqi_yiqianlingyiye_tear_damage = {
     CLASS = "composite.QSBSequence",
     ARGS = {
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
				{
					CLASS = "action.QSBPlayMountSkillAnimation",
				},
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return anqi_yiqianlingyiye_tear_damage