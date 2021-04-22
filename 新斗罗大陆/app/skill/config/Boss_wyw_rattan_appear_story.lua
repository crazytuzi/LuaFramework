local boss_chaoxuemuzhu_chanrao = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
         {
            CLASS = "composite.QSBParallel",
            ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "wyw_attack11_25", is_hit_effect = false, ground_layer = true},
                        }, 
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "wyw_attack11_26", is_hit_effect = false, ground_layer = true},
                        },

                        {
                            CLASS = "action.QSBPlayLoopEffect",
                            OPTIONS = {effect_id = "wyw_attack11_6_1", is_hit_effect = false, ground_layer = true},
                        }, 
                        {
                            CLASS = "action.QSBPlayLoopEffect",
                            OPTIONS = {effect_id = "wyw_attack11_6_2", is_hit_effect = false, ground_layer = true},
                        }, 


                    },

                       

         },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 1.5},
         },
         {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "stand", is_loop = true},
        },


         {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 3.5},
         },
           {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "dead"},
        },

         {
            CLASS = "composite.QSBParallel",
            ARGS = {
                        {
                            CLASS = "action.QSBStopLoopEffect",
                            OPTIONS = {effect_id = "wyw_attack11_6_1"},
                        }, 
                        {
                            CLASS = "action.QSBStopLoopEffect",
                            OPTIONS = {effect_id = "wyw_attack11_6_2"},
                        }, 
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "wyw_attack11_29", is_hit_effect = false},
                        },                                             
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "wyw_attack11_30", is_hit_effect = false},
                        },  


                    },

         },





        {
            CLASS = "action.QSBAttackFinish",
        },
        -- {
        --  CLASS = "action.QSBRemoveBuff",
        --  OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        -- },
    },
}

return boss_chaoxuemuzhu_chanrao