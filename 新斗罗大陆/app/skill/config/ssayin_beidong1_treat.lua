local common_xiaoqiang_victory = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {target_teammate_lowest_hp_percent = true},
                },                
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },     
    },
}

return common_xiaoqiang_victory