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
                },  
                {
                  CLASS = "action.QSBAttackFinish",
                },         
            },
        },
    },
}

return common_xiaoqiang_victory