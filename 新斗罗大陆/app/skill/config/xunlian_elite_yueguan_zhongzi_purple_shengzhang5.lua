local zhongzi_purple_shengzhang5 = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		-- {
		-- 	CLASS = "action.QSBSummonGhosts",
		--   	OPTIONS = {actor_id = 3583, life_span = 50.0, no_fog = false},
		-- },
		{
			CLASS = "action.QSBSummonMonsters",
			OPTIONS = {wave = -10},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return zhongzi_purple_shengzhang5