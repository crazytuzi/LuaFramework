local xunlian_elite_niumang_shuipaosiwang1 = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "xunlina_shuipao_dingshendebuff1", multiple_target_with_skill = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return xunlian_elite_niumang_shuipaosiwang1