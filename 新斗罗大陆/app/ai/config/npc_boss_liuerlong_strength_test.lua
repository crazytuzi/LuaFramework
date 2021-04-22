--斗罗AI 柳二龙BOSS
--力量试炼
--id 3175 
--[[
普攻
暗影步
多重戳
龙爪手
火龙爆裂斩
火焰波动剑
]]--
--创建人：庞圣峰
--创建时间：2018-5-30

local npc_boss_liuerlong_strength_test = {
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
                    OPTIONS = {skill_id = 50098},
                },
            },
        },
		
--------------掉血释放大招-------------		
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 3, first_interval = 7.5},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50651},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50652},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50653},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50654},
                }, 
				{
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.8},only_trigger_once = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50654},    --火龙爆裂斩
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 3, first_interval = 18},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50651},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50652},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50653},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50654},
                }, 
                {
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.6},only_trigger_once = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50654},    --火龙爆裂斩
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 2.7, first_interval = 47},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50651},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50652},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50653},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50654},
                }, 
                {
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.4},only_trigger_once = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50654},    --火龙爆裂斩
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 2.4, first_interval = 76},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50651},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50652},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50653},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50654},
                }, 
                {
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.2},only_trigger_once = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50654},    --火龙爆裂斩
                },
            },
        },
--------------------------------------------------
		
		
--------------常规技能-----------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30.25, first_interval = 0.75},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50654},
                }, 
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",              --使得ai忽略仇恨列表，锁定攻击当前目标（除非当前目标死了）
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50651},     --暗影步
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15, first_interval = 5},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50654},
                }, 
                {
                    CLASS = "action.QAIIsAttacking",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50652},     --多重戳
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30, first_interval = 16},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50654},
                }, 
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {always = true},
                },
				{
                    CLASS = "action.QAIIgnoreHitLog",              --使得ai忽略仇恨列表，锁定攻击当前目标（除非当前目标死了）
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50653},    --龙爪手
                },
            },
        },
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 30, first_interval=10},
				},
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50654},
                }, 
				{
					CLASS = "action.QAIIsAttacking",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50655},--火焰波动剑
				},
			},
		},
--------------------------------------------------

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15, first_interval = 6},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
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

return npc_boss_liuerlong_strength_test