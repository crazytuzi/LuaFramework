
local cnxiaowu_zidong2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 50/24*30},
                -- },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 180,y = 80}},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return cnxiaowu_zidong2