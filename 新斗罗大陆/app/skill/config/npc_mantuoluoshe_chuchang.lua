local tank_chongfeng = 
{
    CLASS = "composite.QSBSequence",
    -- OPTIONS = {forward_mode = true},
    ARGS = 
    {
        {
            CLASS = "action.QSBManualMode",     --进入手动模式
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBStopMove",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        -- {
                        --     CLASS = "action.QSBPlayAnimation",
                        --     OPTIONS = {animation = "attack15_1", reload_on_cancel = true, revertable = true},       --对于会涉及隐身的animation，需要在QSBPlayAnimation中加入选项,reload_on_cancel = true,revertable = true
                        -- },
                        -- {
                        --     CLASS = "action.QSBActorFadeOut",
                        --     OPTIONS = {duration = 0.1, revertable = true},
                        -- },
                        {
                            CLASS = "action.QSBPlayLoopEffect",
                            OPTIONS = {effect = "qianxinggongji", is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "action.QSBHeroicalLeap",
                    OPTIONS = {speed = 300 ,move_time = 2.5}
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2.4 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack15", reload_on_cancel = true, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBStopLoopEffect",
                                    OPTIONS = {effect_id = "qianxinggongji"},
                                },
                                {
                                    CLASS = "action.QSBActorFadeIn",
                                    OPTIONS = {duration = 0.1, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBReloadAnimation",
                                },
                                {
                                    CLASS = "action.QSBActorStand",
                                },
                                {
                                    CLASS = "action.QSBAttackFinish"
                                },
                            },
                        },                    
                        -- {
                        --     CLASS = "action.QSBApplyBuff",
                        --     OPTIONS = {buff_id = "chongfeng_tongyong_xuanyun", is_target = true},
                        -- },
                        {
                            CLASS = "action.QSBManualMode",
                            OPTIONS = {exit = true},
                        },
                    },
                },
            },
        },
    },
}

return tank_chongfeng