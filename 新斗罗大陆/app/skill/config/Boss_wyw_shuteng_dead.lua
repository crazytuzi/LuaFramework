
local jinzhan_tongyong = {
     CLASS = "composite.QSBParallel",
     ARGS = {
              {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                           {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3_1"},
                                            }, 
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3_2"},
                                            }, 
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3_3"},
                                            },
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_11", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_12", is_hit_effect = false},
                                            },  

                                        },

                             },
       
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "dead", no_stand = true},

            
        },


        
        {
            CLASS = "action.QSBAttackFinish",
        },



    },
}

return jinzhan_tongyong