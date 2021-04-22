
local boss_bosaixi_langji = {

CLASS = "composite.QSBParallel",
    ARGS = {
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 24},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "bosaixi_attack13_3", pos  = {x = 550 , y = 340},front_layer= true},
                },
            },
        },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 44},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}
return boss_bosaixi_langji
