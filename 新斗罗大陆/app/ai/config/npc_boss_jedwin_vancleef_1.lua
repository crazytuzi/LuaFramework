
local npc_boss_jedwin_vancleef = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {

--------------------------------       范克里夫        ---------------------------------------


--------------------------------       免疫控制状态        -----------------------------------
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 500,first_interval=0},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 201103},
        --         },
        --     },
        -- },
        

        ---------------------------       暗影步       -----------------------------------
       {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 16,first_interval=6},
                },
                -- {
                --     CLASS = "action.QAIAttackAnyEnemy",
                --     OPTIONS = {always = true},
                -- },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                     CLASS = "action.QAIUseSkill",
                     OPTIONS = {skill_id = 200001},
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
            },
        },

       {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 16,first_interval=9},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
        },
        ----------------------------------         重伤        -----------------------------------------

        
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 16,first_interval=8},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200511},             -----重伤
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12,first_interval=46},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200511},
                },
            },
        },


       -----------------------          毒药        --------------------------------------

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                -- {
                --     CLASS = "action.QAIHPLost",
                --     OPTIONS = {hp_less_then = {0.4},only_trigger_once = false},        -- 多少血量一下触发一次,only_trigger_once是否重复触发
                -- },
                -- {
                --     CLASS = "action.QAIHealthSpan",
                --     OPTIONS = {from = 0.45,to =0.3,only_trigger_once = false},               
                -- },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval=41},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200187},
                },
            },
        },
 





 

 -------------------------------         召唤         -----------------------------------------
    
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.5},only_trigger_once = false},        -- 多少血量一下触发一次,only_trigger_once是否重复触发
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200003},          -- 召唤
                },
            },
        },
 




      
 
 
 -- ---------------------------------         暗影步         ----------------------------------------
--         {
--             CLASS = "composite.QAISequence",
--             ARGS = 
--             {
--                 {
--                     CLASS = "action.QAIHPLost",
--                     OPTIONS = {hp_less_then = {0.45}, only_trigger_once = true},
--                 },
--                 {
--                     CLASS = "action.QAIAttackEnemyOutOfDistance",
--                     OPTIONS = {current_target_excluded = true},
--                 },
--                 {
--                     CLASS = "action.QAIUseSkill",
--                     OPTIONS = {skill_id = 200001},
--                 },
--                 {
--                     CLASS = "action.QAIIgnoreHitLog",
--                 },
--             },
--         },
--         {
--             CLASS = "composite.QAISequence",
--             ARGS = 
--             {
--                 {
--                     CLASS = "action.QAITimer",
--                     OPTIONS = {interval = 60,first_interval = 46},
--                 },
--                 {
--                     CLASS = "action.QAIAcceptHitLog",
--                 },
--             },
--         },
        
------------------------------------------------------------------------------------------

        {
            CLASS = "action.QAIAttackByHitlog",
        },
        {
            CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAIBeatBack",
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
            },
        },
    },
}

return npc_boss_jedwin_vancleef