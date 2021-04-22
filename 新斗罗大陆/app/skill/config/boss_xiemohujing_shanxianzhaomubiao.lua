
local boss_xiemohujing_shanxianzhaomubiao = {
           CLASS = "composite.QSBSequence",
           ARGS = {
                  {
              CLASS = "composite.QSBParallel",
              ARGS = {
                     {
                       CLASS = "action.QSBActorStand",
                     },
                     {
                       CLASS = "action.QSBActorFadeOut",
                       OPTIONS = {duration = 0.15, revertable = true},
                     },
                     },
              },
              {
              CLASS = "action.QSBTeleportToAbsolutePosition",
              OPTIONS = {pos={x = 1600,y = 900},verify_flip = true},
              },
              {
              CLASS = "composite.QSBParallel",
              ARGS = {
                     {
                       CLASS = "action.QSBPlayEffect",
                       OPTIONS = {is_hit_effect = true},
                     },
                     {
                       CLASS = "action.QSBActorFadeIn",
                       OPTIONS = {duration = 0.15, revertable = true},
                     },
                     },
              },
                           {
                            CLASS = "action.QSBAttackFinish"
                           },
                        },
}

return boss_xiemohujing_shanxianzhaomubiao