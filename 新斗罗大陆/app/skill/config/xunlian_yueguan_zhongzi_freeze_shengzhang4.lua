local zhongzi_freeze_shengzhang = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		-- {
		-- 	CLASS = "action.QSBSummonGhosts",
		--   	OPTIONS = {actor_id = 3584, life_span = 10.0, no_fog = false},
		-- },
		{
			CLASS = "action.QSBSummonMonsters",
			OPTIONS = {wave = -14},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return zhongzi_freeze_shengzhang