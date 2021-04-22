local zhongzi_purple_shengzhang1 = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		-- {
		-- 	CLASS = "action.QSBSummonGhosts",
		--   	OPTIONS = {actor_id = 3583, life_span = 10.0, no_fog = false},
		-- },
		{
			CLASS = "action.QSBSummonMonsters",
			OPTIONS = {wave = -6},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return zhongzi_purple_shengzhang1