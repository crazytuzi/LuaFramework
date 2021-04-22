
local team_npc_boss_zoemulladon= {
    CLASS = "composite.QAISelector",
    ARGS =
	{
        -----免疫冲锋-------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201103},
                },
            },
        },
        -------祖穆拉恩骷髅暗影箭------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 1,to =0.5},               
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 22,first_interval=7},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 203614},
                },
            },
        },
        -------祖穆拉恩骷髅暗影箭雨-------（读条地上有圈的）
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 1,to =0.5},               
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 22,first_interval=15},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 203613},
                },
            },
        },
        -------祖穆拉恩骷髅暗影箭------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 1,to =0.5},               
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 22,first_interval=22},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 203614},
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
                    OPTIONS = {interval = 24,first_interval=5},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 203614},
                },
            },
        },
        -------祖穆拉恩骷髅暗影箭雨-------（读条地上有圈的）
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
                    OPTIONS = {interval = 24,first_interval=10},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 203613},
                },
            },
        },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAIHealthSpan",
        --             OPTIONS = {from = 0.5,to =0},               
        --         },
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 24,first_interval=15},
        --         },
        --         {
        --             CLASS = "action.QAIAttackAnyEnemy",
        --             OPTIONS = {always = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 203613},
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAIHealthSpan",
        --             OPTIONS = {from = 0.5,to =0},               
        --         },
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 24,first_interval=17},
        --         },
        --         {
        --             CLASS = "action.QAIAttackAnyEnemy",
        --             OPTIONS = {always = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 203613},
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
	}
}
        
return team_npc_boss_zoemulladon
