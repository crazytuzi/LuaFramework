local qiangzhen_zibao = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
     	{
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {multiple_target_with_skill = true, buff_id = "boss_changqianglaoyu3"},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return qiangzhen_zibao