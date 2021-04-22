-- 技能 擎天枪伤害
-- 技能ID 2020108

local sq_qingtianqiang_shanghaizhi = 
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
}

return sq_qingtianqiang_shanghaizhi

