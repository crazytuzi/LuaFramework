local qianrenxue_zhenji_plus_trigger = {
     CLASS = "composite.QSBSequence",
     ARGS = {
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "target:hp_percent>0","target:decrease_hp:self:maxHp*0.015","under_status"},
			   { "self:hp_percent>0","self:increase_hp:self:maxHp*0.015","under_status"},
			}
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return qianrenxue_zhenji_plus_trigger