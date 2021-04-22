
local qiandaoliu_zidong2 = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                },
             
                
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },


        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                 {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},

                 },
                 {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "qiandaoliu_attack14_2", is_hit_effect = false},
                 },

            },

        },
 
       {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },
                
                {
                    CLASS = "action.QSBHitTarget",
                },

                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "qiandaoliu_attack14_3", is_hit_effect = true},
                },

                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "qiandaoliu_attack14_3", is_hit_effect = true},
                },


            },
        },
         
    },
}
return qiandaoliu_zidong2