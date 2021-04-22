local zhongzi_purple_shengzhang1 = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		-- {
		-- 	CLASS = "action.QSBSummonGhosts",
		--   	OPTIONS = {actor_id = 3543, life_span = 10.0, no_fog = false},
		-- },
		{
			CLASS = "action.QSBSummonMonsters",
			OPTIONS = {wave = -9},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return zhongzi_purple_shengzhang1