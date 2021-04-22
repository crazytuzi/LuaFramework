local boss_chaoxuemuzhu_chanrao = 
{
     CLASS = "composite.QSBParallel",
     ARGS = 
     {
        {
                CLASS = "action.QSBPlayAnimation",
                OPTIONS = {animation = "attack21"},
        },

        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                    {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 190},
                    },

                     {
                        CLASS = "action.QSBPlayEffect",
                        OPTIONS = {effect_id = "wyw_ruchang01", is_hit_effect = false},
                    }, 
                    {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 50},
                    }, 
                    {
                            CLASS = "action.QSBAttackFinish",
                    },


            },
        },











        -- {
        --  CLASS = "action.QSBRemoveBuff",
        --  OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        -- },
    },
}

return boss_chaoxuemuzhu_chanrao