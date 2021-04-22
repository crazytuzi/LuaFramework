local boss_zhaowuji_zhonglijiya = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack12", is_loop = true, is_keep_animation = true},
                        },
                        {
                            CLASS = "action.QSBActorKeepAnimation",
                            OPTIONS = {is_keep_animation = true}
                        },
                    },
                },
                {
                    CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                    OPTIONS = { pos = {x=300,y=360} , move_time = 0.5},
                },
            },
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 12 / 24 },
        },
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}
return boss_zhaowuji_zhonglijiya