local boss_chaoxuemuzhu_chanrao = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_target = false, effect_id = "wyw_story_01"},
        }, 
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 10}
        },
        {
            CLASS = "action.QSBPlayLoopEffect",
            OPTIONS = {effect_id = "wyw_story_02", is_target = false},
        },




        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 0.5},
        },  


       {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_target = false, effect_id = "wyw_story_03"},--闪光
        }, 
         {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 10},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_target = false, effect_id = "wyw_story_05"},--聚气
        },
         {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 10},
        },                   

        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_target = false, effect_id = "wyw_story_06"},--子弹
        },
         {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 15},
        },

        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_target = false, effect_id = "wyw_story_07"},
        },


        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 1},
        },


        {
            CLASS = "composite.QSBParallel",
            ARGS = {


                        {
                            CLASS = "action.QSBStopLoopEffect",
                            OPTIONS = {effect_id = "wyw_story_02", is_target = false},
                        },

                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_target = false, effect_id = "wyw_story_04"},
                        },                                              
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {is_target = false, effect_id = "wyw_story_05"},
                        -- }, 
                                             


                    },

         },

       --  -- {
       --  --     CLASS = "action.QSBPlayEffect",
       --  --     OPTIONS = {is_target = false, effect_id = "wyw_story_03"},
       --  -- }, 
       --  --  {
       --  --     CLASS = "action.QSBDelayTime",
       --  --     OPTIONS = {delay_frame = 1},
       --  -- },
       --  -- {
       --  --     CLASS = "action.QSBPlayEffect",
       --  --     OPTIONS = {is_target = false, effect_id = "wyw_story_05"},--聚气
       --  -- },
       --  --  {
       --  --     CLASS = "action.QSBDelayTime",
       --  --     OPTIONS = {delay_frame = 10},
       --  -- },        
       --  {
       --      CLASS = "action.QSBPlayEffect",
       --      OPTIONS = {is_target = false, effect_id = "wyw_story_06"},
       --  },
       --   {
       --      CLASS = "action.QSBDelayTime",
       --      OPTIONS = {delay_frame = 15},
       --  },

       --  {
       --      CLASS = "action.QSBPlayEffect",
       --      OPTIONS = {is_target = false, effect_id = "wyw_story_07"},
       --  },








        {
            CLASS = "action.QSBAttackFinish",
        },
        -- {
        --  CLASS = "action.QSBRemoveBuff",
        --  OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        -- },
    },
}

return boss_chaoxuemuzhu_chanrao