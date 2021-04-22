local baihe_longjuanfeng = {
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
                                OPTIONS = {delay_frame = 25},
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
                                 OPTIONS = {delay_frame = 25},
                            },
                            {
                                 CLASS = "action.QSBBullet",
                                 OPTIONS = {effect_id = "baihe_atk13_2",is_tornado = true, tornado_size = {width = 115, height =140}, speed = 750},               
                            },
                        },
                },

        },

}
       
return baihe_longjuanfeng