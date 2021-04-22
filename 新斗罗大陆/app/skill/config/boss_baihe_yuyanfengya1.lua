
local boss_baihe_yuyanfengya1  = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
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
                OPTIONS = {delay_frame = 10},
            },
            {
                 CLASS = "action.QSBPlayEffect",
                                
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
                    OPTIONS = { is_hit_effect = true, effect_id = "baihe_shouji"},
                },
                {
                     CLASS = "action.QSBHitTarget",
                }


            },
        },
         {
            CLASS = "composite.QSBSequence",
            ARGS = 
            { 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 42},
                },

                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = { is_hit_effect = true, effect_id = "baihe_shouji"},
                },
                {
                     CLASS = "action.QSBHitTarget",
                }


            },
        },
         {
            CLASS = "composite.QSBSequence",
            ARGS = 
            { 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 54},
                },

                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = { is_hit_effect = true, effect_id = "baihe_shouji"},
                },
                {
                     CLASS = "action.QSBHitTarget",
                }


            },
        },
       
    },
}
return boss_baihe_yuyanfengya1

