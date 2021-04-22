-- 技能 暗器 一千零一夜 扎针伤害
-- 技能ID 40306~40310
-- 造成伤害并扎入针刺BUFFanqi_yiqianlingyiye_debuff
--[[
	暗器 一千零一夜
	ID:1520
	psf 2019-2-16
]]--

local anqi_yiqianlingyiye_damage = {
     CLASS = "composite.QSBSequence",
     ARGS = {
		{
			CLASS = "action.QSBHitTarget",
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return anqi_yiqianlingyiye_damage