--斗罗AI 水冰儿BOSS
--智慧试炼
--id 3176  
--[[
普攻减攻速
召唤冰鸟武魂
暴风雪
冰冻激光上
冰冻激光下
]]--
--创建人：庞圣峰
--创建时间：2018-5-30

local npc_boss_shuibinger_wisdom_test= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
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
                    OPTIONS = {skill_id = 50098},
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
                    OPTIONS = {interval = 2.5,first_interval = 5.5},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50657},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50658},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50659},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50660},
                }, 
				{
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.8},only_trigger_once = true},
                },
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50659},--冰霜激光up
                },
            },
        },
		{
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 2.35,first_interval = 20},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50657},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50658},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50659},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50660},
                }, 
				{
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.6},only_trigger_once = true},
                },
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50660},--冰霜激光down
                },
            },
        },
		{
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 2.2,first_interval = 40},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50657},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50658},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50659},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50660},
                }, 
				{
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.4},only_trigger_once = true},
                },
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50659},--冰霜激光up
                },
            },
        },
		{
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 2.05,first_interval = 70},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50657},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50658},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50659},
                }, 
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 50660},
                }, 
				{
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.2},only_trigger_once = true},
                },
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50660},--冰霜激光down
                },
            },
        },
---------------------------------------------------

-------------------常规技能-----------------------		
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval= 2},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50657},--点名冰鸟
                },
            },
        },
		
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval= 9},
                },
				{
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50658},--暴风雪
                },
            },
        },	
---------------------------------------------------
		
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
        
return npc_boss_shuibinger_wisdom_test