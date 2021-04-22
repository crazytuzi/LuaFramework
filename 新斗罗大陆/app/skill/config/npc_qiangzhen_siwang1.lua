local qiangzhen_zibao = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
     	{
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "boss_changqianglaoyu1", multiple_target_with_skill = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return qiangzhen_zibao