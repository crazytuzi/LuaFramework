
local npc_boss_lady_anacondra = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {   -------------------------------------  安娜科德拉----------------------------------------------
        -- 免疫控制状态
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

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 1,to =0.52},               
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval=5}, 
                },
              

                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance", -- 选择一个距离之外的敌人作为目标，如果没有，默认选择一个最远的敌人作为目标。

                },
                -- {
                --     CLASS = "decorate.QAIInvert",                    如果200001技能没有在执行，则执行200312
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QAIIsUsingSkill",
                --             OPTIONS = {check_skill_id = 200001},
                --         },
                --     },
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200312},
                },
            },
        },

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {

                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 1,to =0.52},               
                },

                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval=10}, 
                },
           
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                    OPTIONS = {always = true}
                },

				{
                    CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200316},
                },
            },
        },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAIHealthSpan",
        --             OPTIONS = {from = 1,to =0.5},               
        --         },
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 14,first_interval = 16},
        --         },
        --         {
        --             CLASS = "action.QAIAttackEnemyOutOfDistance",
        --         },
        --         {
        --             CLASS = "decorate.QAIInvert",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QAIIsUsingSkill",
        --                     OPTIONS = {check_skill_id = 200001},
        --                 },
        --             },
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 200312},
        --         },
        --     },
        -- },

        -- 第二阶段，50%血以下释放召唤和狂暴
         {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.52},only_trigger_once = false},        -- 多少血量一下触发一次,only_trigger_once是否重复触发
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200003},          -- 召唤
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 0.59,to =0.52},               
                },

                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 5,first_interval=2}, 
                },

                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsUsingSkill",
                            OPTIONS = {check_skill_id = 200003,},
                        },
                    },
                },
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsUsingSkill",
                            OPTIONS = {check_skill_id = 200313,},
                        },
                    },
                },
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsUsingSkill",
                            OPTIONS = {check_skill_id = 200316,},
                        },
                    },
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200313},
                },
            },
        },
        
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {

                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 0.5,to =0},               
                },

                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1.5, first_interval=2.0, allow_frameskip = true}, 
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsUsingSkill",
                            OPTIONS = {check_skill_id = 200003,},
                        },
                    },
                },
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsUsingSkill",
                            OPTIONS = {check_skill_id = 200313,},
                        },
                    },
                },
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsUsingSkill",
                            OPTIONS = {check_skill_id = 200316,},
                        },
                    },
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                    OPTIONS = {always = true}
                },
                
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200316},
                },
            },
        },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --     	   {
        --             CLASS = "action.QAIHPLost",
        --             OPTIONS = {hp_less_then = {0.35}, only_trigger_once = true},
        --         },
        --         {
        --             CLASS = "action.QAIAttackEnemyOutOfDistance",
        --             OPTIONS = {current_target_excluded = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 200001},
        --         },
        --         {
        --             CLASS = "action.QAIIgnoreHitLog",
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --     	   {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 60,first_interval = 46},
        --         },
        --         {
        --             CLASS = "action.QAIAcceptHitLog",
        --         },
        --     },
        -- },
       
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

return npc_boss_lady_anacondra