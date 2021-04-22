-- 技能 擎天枪伤害
-- 技能ID 2020108

local sq_qingtianqiang_shanghaizhi2 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsPosition",
                    OPTIONS = {is_attackee = true},
                },
                {
                    CLASS = "action.QSBDragActor",
                    OPTIONS = {pos_type = "fix" , pos = {x = 0,y = 0} , duration = 0.1, flip_with_actor = true },
                },
            },
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            { 
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_qingtianqiang_shanghaizhi2

