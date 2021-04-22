
local prologue_boss_guimei_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.2},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "prologue_guimei_guiyingtunshi_debuff"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlaySound",
                                    OPTIONS = {sound_id ="guimei_xuzhang1",is_loop = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 1.5},
                                }, 
                                {
                                    CLASS = "action.QSBStopSound",
                                    OPTIONS = {sound_id ="guimei_xuzhang1"},
                                }, 
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlaySound",
                                    OPTIONS = {sound_id ="xuzhang_guimei_gyts",is_loop = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 4},
                                }, 
                                {
                                    CLASS = "action.QSBStopSound",
                                    OPTIONS = {sound_id ="xuzhang_guimei_gyts"},
                                }, 
                            },
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack66"},
                            ARGS = {
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {is_target = true, buff_id = "prologue_guimei_guiyingtunshi_debuff"},
                },
            },
        },
    },
}

return prologue_boss_guimei_dazhao
