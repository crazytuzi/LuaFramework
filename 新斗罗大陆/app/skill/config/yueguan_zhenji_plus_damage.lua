-- 技能 月关 异茸伤害百分比扣血
-- ID 190086
-- 真技强化后,异茸BUFF周期触发该技能,造成百分比伤害.(判断施法者状态区分)
--[[
	hero 月关
	ID:1018
	psf 2018-11-19
]]--

local yueguan_zhenji_plus_damage = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
			CLASS = "composite.QSBParallel",
			ARGS = {
				{
					CLASS = "action.QSBActorStatus",
					OPTIONS = 
					{
					   { "self:role==boss_or_elite_boss","self:decrease_hp:maxHp*0.02","not_under_status"},
					}
				},
				
			},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return yueguan_zhenji_plus_damage