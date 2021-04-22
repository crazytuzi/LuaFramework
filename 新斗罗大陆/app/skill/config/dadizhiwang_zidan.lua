
local dadizhiwang_zidan = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS ={
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                             {
                                   CLASS = "action.QSBPlayAnimation",
                             },
                             {
                                  CLASS = "composite.QSBSequence",
                                  ARGS = {
                                           {
                                             CLASS = "action.QSBDelayTime",
                                             OPTIONS = {delay_time = 30/24},
                                           },
                                           {
                                             CLASS = "action.QSBHitTarget",
                                           },
                                           {
                                             CLASS = "action.QSBBullet",
                                             OPTIONS = {flip_follow_y = true},
                                           },
                                         },                                  
                             },
                             {
                                 CLASS = "action.QSBAttackFinish",
                             },
                           },
                   },
       },
   }
}

return dadizhiwang_zidan

