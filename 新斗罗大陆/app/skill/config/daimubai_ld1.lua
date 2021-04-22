local daimubai_ld1 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
          CLASS = "composite.QSBParallel",
          ARGS = {
            {
              CLASS = "composite.QSBSequence",
              ARGS = {
                {
                    CLASS = "action.QSBRoledirection",
                    OPTIONS = {direction = "right"},
                },
                {
                  CLASS = "composite.QSBParallel",
                  ARGS = {
                    {
                        CLASS = "action.QSBPlayAnimation",
                        OPTIONS = {animation = "atk12_1"},
                    },
                    {
                      CLASS = "composite.QSBSequence",
                      ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 36},
                        },
                        {
                            CLASS = "action.QSBActorFadeOut",
                            OPTIONS = {duration = 0.01, revertable = true},
                        },
                      },
                    },
                  },
                },
                {
                    CLASS = "action.QSBTeleportToAbsolutePosition",
                    OPTIONS = {pos = {x = 850,y = 350}},
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 1},
                -- },
              },
            },
            {
              CLASS = "composite.QSBSequence",
              ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 56},
                },
                {
                    CLASS = "action.QSBRoledirection",
                    OPTIONS = {direction = "left"},
                },
                {
                  CLASS = "composite.QSBParallel",
                  ARGS = {
                    {
                      CLASS = "action.QSBActorFadeIn",
                      OPTIONS = {duration = 0.01, revertable = true},
                    },
                    {
                        CLASS = "action.QSBPlayAnimation",
                        OPTIONS = {animation = "atk12_2"},
                    },
                  },
                },
              },
            },
            {
              CLASS = "composite.QSBSequence",
              ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 67},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
              },
            },
            {
               CLASS = "composite.QSBSequence",
               ARGS = 
               {
                    {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 41},
                    },
                    {
                      CLASS = "action.QSBTrap",  
                      OPTIONS = 
                      { 
                          trapId = "daimubai_liuxinghuoyu",
                          args = 
                          {
                              {delay_time = 20 / 24 , pos = { x = 430, y = 150}} ,
                              {delay_time = 20 / 24 , pos = { x = 1100, y = 325}} ,
                              {delay_time = 22 / 24 , pos = { x = 850, y = 600}} ,
                              -- {delay_time = 24 / 24 , pos = { x = 340, y = 350}} ,
                              {delay_time = 26 / 24 , pos = { x = 150, y = 550}} ,
                              {delay_time = 26 / 24 , pos = { x = 1300, y = 400}} ,
                              {delay_time = 26 / 24 , pos = { x = 700, y = 185}},
                              {delay_time = 32 / 24 , pos = { x = 200, y = 282}} ,
                              {delay_time = 32 / 24 , pos = { x = 500, y = 555}},
                              -- {delay_time = 32 / 24 , pos = { x = 1120, y = 477}} ,
                              -- {delay_time = 34 / 24 , pos = { x = 640, y = 235}} ,
                              -- {delay_time = 36 / 24 , pos = { x = 100, y = 446.8}} ,
                              -- {delay_time = 38 / 24 , pos = { x = 370, y = 246}} ,
                              -- {delay_time = 38 / 24 , pos = { x = 1250, y = 100}} ,
                              -- {delay_time = 38 / 24 , pos = { x = 580, y = 290}} ,
                              -- {delay_time = 40 / 24 , pos = { x = 770, y = 335.4}},
                              -- {delay_time = 44 / 24 , pos = { x = 420, y = 500}} ,
                              -- {delay_time = 44 / 24 , pos = { x = 950, y = 355}},
                              -- {delay_time = 44 / 24 , pos = { x = 700, y = 385.4}},
                              -- {delay_time = 44 / 24 , pos = { x = 540, y = 292}} ,
                          },
                      },
                   },
               },
            },
            {
              CLASS = "composite.QSBSequence",
              ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 80},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "atk12_5", is_loop = true , is_keep_animation = true},
                },
              },
            },
            {
              CLASS = "composite.QSBSequence",
              ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 104},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "atk12_5", is_loop = false , is_keep_animation = false},
                },
              },
            },
            {
              CLASS = "composite.QSBSequence",
              ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 126},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "atk12_3"},
                },
              },
            },
            {
              CLASS = "composite.QSBSequence",
              ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 159},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "atk12_4", is_loop = true , is_keep_animation = true},
                },
              },
            },
            {
              CLASS = "composite.QSBSequence",
              ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 241},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "atk12_4", is_loop = false , is_keep_animation = false},
                },
              },
            },
            {
              CLASS = "composite.QSBSequence",
              ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 141},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "tangsan_laolong", is_target = false},
                },
              },
            },
          },
        },
            -- -- {
        -- --     CLASS = "action.QSBRemoveBuff",
        -- --     OPTIONS = {buff_id = "dugubo_zhenji_die", remove_all_same_buff_id = true},
        -- -- },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return daimubai_ld1