local zudui_bajiaohanbingcao_zhaohuan = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBSummonMonsters",
            OPTIONS = {wave = -1,attacker_level = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return zudui_bajiaohanbingcao_zhaohuan