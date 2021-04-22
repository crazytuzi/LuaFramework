local npc_pozhiyizu_zhaohuanlaolong_10_16 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
     	{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "jinshu_diancihuan"},
		},
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "jinshu_diancihuan2"},
        },
		{
            CLASS = "action.QSBAttackFinish"
        },
	},
}
return npc_pozhiyizu_zhaohuanlaolong_10_16
