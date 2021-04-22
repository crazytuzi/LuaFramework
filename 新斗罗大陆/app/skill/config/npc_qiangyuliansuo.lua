local npc_pozhiyizu_zhaohuanlaolong_10_16 = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
     	{
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack21"},
        },
        -- {
			-- CLASS = "action.QSBApplyBuff",
			-- OPTIONS = {buff_id = "qiangzhen_baozhayujing"},
		-- },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return npc_pozhiyizu_zhaohuanlaolong_10_16