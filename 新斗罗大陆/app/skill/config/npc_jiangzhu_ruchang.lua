local xiaohua_ruchang = 
{
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = 
    {
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS =
            {
                {
                    CLASS = "action.QSBJumpAppear",
                    OPTIONS = { jump_animation = "attack21"},
                },
                {
                    CLASS = "composite.QSBSequence",    -- 入场魂环
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 61/24 },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "tongyongzihunhuan_soul_2" , is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 4/24 },
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="fulande2_stand_1"},
                        },    
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 7/24 },
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="jiangzhu_cheer"},
                        },    
                    },
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 36/24 },
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",     
                            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 36/24 },
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "jiangzhu_chuxian"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 5/24 },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "boss_jiangzhu_ruchang" , is_hit_effect = false},
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 10/24 },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return xiaohua_ruchang