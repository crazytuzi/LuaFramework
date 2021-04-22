--斗罗AI 比比东BOSS
--副本14-16
--id 3681
--[[
毒液喷涌
死亡领域连招
连招闪现
连招蛛网
变蜘蛛,踩地板,上变身BUFF
]]--
--创建人：庞圣峰
--创建时间：2018-7-3

local npc_boss_bibidong = {
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
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50830},
                },
            },
        },
		
--------------掉血释放大招-------------		
		{
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 2.6,first_interval = 16},
                },
				{
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.65},only_trigger_once = false},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50831},--变身
                },
            },
        },
		{
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1.6,first_interval = 8},
                },
				{
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.4},only_trigger_once = false},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50831},--变身
                },
            },
        },
		{
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 0.7,first_interval = 3},
                },
				{
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.17},only_trigger_once = false},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50831},--变身
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
                    OPTIONS = {interval = 15, first_interval = 5},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50829},
                }, 
                {
                    CLASS = "action.QAIIsAttacking",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50829},     --毒液喷涌
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15, first_interval = 15},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50829},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50831},
                }, 
				{
					CLASS = "action.QAITeleport",
					OPTIONS = {interval = 15.0},
				}, 
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50832},    --死亡领域蛛网
                },
            },
        },
--------------------------------------------------
			
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

return npc_boss_bibidong