
local npc_boss_kresh = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {    -------------------------------  永生者沃尔丹  ------------------------------------------------

             ------------------------------       免疫控制状态        -----------------------------------
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
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10},
                },
                {
                    CLASS = "action.QAIAttackByRole",
					OPTIONS = {role = "health", exclusive = true},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200306},        ----------------缠绕
				},
                {
                    CLASS = "action.QAIAttackByHitlog",
                },
            },
        },

		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200311},      -----------------顺劈斩
				},
            },
        },
       
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200321},     -------------------冲锋
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",  -------------------使得ai忽略仇恨列表，锁定攻击当前目标（除非当前目标死了）
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 29},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",  --------------------取消忽略仇恨列表
                },
            },
        },
       
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

return npc_boss_kresh