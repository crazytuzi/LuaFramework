
local duguyan_bilinglvdu = {
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
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="duguyan_blzd_zd"},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
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
                    OPTIONS = {delay_frame = 25},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "duguyan_attack13_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {  
                {
                     CLASS = "action.QSBDelayTime",
                     OPTIONS = {delay_frame = 25},
                },
                {
                     CLASS = "action.QSBBullet",
                     OPTIONS = {is_tornado = true, tornado_size = {width = 180, height =150}, effect_id = "duguyan_attack13_2", speed = 750},               
                },
            },
        },
    },
}

return duguyan_bilinglvdu