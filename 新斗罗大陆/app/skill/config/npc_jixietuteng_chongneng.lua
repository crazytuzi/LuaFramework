local npc_pozhiyizu_zhaohuanlaolong_10_16 = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "jinshu_diandun" , is_target = false},
		},
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return npc_pozhiyizu_zhaohuanlaolong_10_16