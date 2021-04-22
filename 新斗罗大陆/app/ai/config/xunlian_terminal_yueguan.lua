--斗罗AI 7-4BOSS
--普通副本
--character_id 3581
--创建人：刘悦璘
--创建时间：2018-6-1

local xunlian_terminal_yueguan = {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 52134},
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 110, first_interval = 12},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53202},      --第一波召唤
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 110, first_interval = 36},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53203},      --第二波召唤
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 110, first_interval = 50},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53218},      --闪现
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 110, first_interval = 60},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53203},      --第二波召唤
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 110, first_interval = 84},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53202},      --第一波召唤
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 110, first_interval = 98},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53219},      --闪现
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 110, first_interval = 15.5},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 4},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53205},      --种子机关枪
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 110, first_interval = 39.5},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 4},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53205},      --种子机关枪
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 110, first_interval = 63.5},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 4},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53205},      --种子机关枪
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 110, first_interval = 87.5},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 4},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53205},      --种子机关枪
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
    }
}
        
return xunlian_terminal_yueguan