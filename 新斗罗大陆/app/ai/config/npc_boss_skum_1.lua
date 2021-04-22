
local npc_boss_skum = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
       ---------------------------------   斯卡姆     -------------------------------------------


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

       

       ---------------------------            冲锋        ------------------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval=12},
                },
				
				{
                    CLASS = "action.QAIAttackByRole",
                    OPTIONS = {role = "dps", ranged=true},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200309},
				},
            },
        },


    ------------------------------             践踏          ------------------------------------
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 18,first_interval=18},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200315},
				},
            },
        },

       
------------------------------------------      狂暴           ---------------------------------------
       {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.40}, only_trigger_once = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200313},
                },
            },
        },

    -----------------------------------         召唤         -----------------------------------------
    
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAIHPLost",
        --             OPTIONS = {hp_less_then = {0.5},only_trigger_once = false},        -- 多少血量一下触发一次,only_trigger_once是否重复触发
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 200003},          -- 召唤
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

return npc_boss_skum