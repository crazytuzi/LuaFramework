local npc_pozhiyizu_zhaohuanlaolong_10_16 = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
     	{
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack21"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return npc_pozhiyizu_zhaohuanlaolong_10_16