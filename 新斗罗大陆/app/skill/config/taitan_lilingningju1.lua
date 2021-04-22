
local taitan_liliangniju1 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
       
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },      
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "taitan_attack13_1b",is_hit_effect = false},
                },
               
                {
                   
                    CLASS = "composite.QSBSequence",
                    ARGS = {  
                        {
                         CLASS = "action.QSBDelayTime",
                         OPTIONS = {delay_frame = 4},
                        },  
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                         CLASS = "action.QSBDelayTime",
                         OPTIONS = {delay_frame = 4},
                        },  
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                         CLASS = "action.QSBDelayTime",
                         OPTIONS = {delay_frame = 4},
                        },  
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                         CLASS = "action.QSBDelayTime",
                         OPTIONS = {delay_frame = 4},
                        },  
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                         CLASS = "action.QSBDelayTime",
                         OPTIONS = {delay_frame = 4},
                        },  
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                         CLASS = "action.QSBDelayTime",
                         OPTIONS = {delay_frame = 4},
                        },  
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                         CLASS = "action.QSBDelayTime",
                         OPTIONS = {delay_frame = 4},
                        },  
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                         CLASS = "action.QSBDelayTime",
                         OPTIONS = {delay_frame = 4},
                        },  
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
    },
}

return taitan_liliangniju1