--星罗枪骑兵 boss
--NPC原型 10017
--普攻ID:50300
--蓄力预警直线冲锋,冲锋后排,群体乱刺,单体乱刺,聚怪
--[[-----------------------------------------
	不要轻易修改,有特殊需求,尽量复制一份使用.
	避免影响其他同原型NPC!!!
]]-------------------------------------------
--创建人：庞圣峰
--创建时间：2018-3-21

local npc_qiangqibing_boss = {     
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
                    OPTIONS = {skill_id = 50098},          --免疫冲锋
                },
            },
        },
		-- {
            -- CLASS = "composite.QAISequence",
            -- ARGS = 
            -- {
                -- {
                    -- CLASS = "action.QAITimer",
                    -- OPTIONS = {interval = 25,first_interval = 0.5},
                -- },
				-- {
                    -- CLASS = "action.QAIAttackEnemyOutOfDistance",
                    -- OPTIONS = {current_target_excluded = true},
                -- },
                -- {
                    -- CLASS = "action.QAIUseSkill",
                    -- OPTIONS = {skill_id = 50301}, -- 蓄力冲撞
                -- },
            -- },
        -- },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval = 13.5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50423}, -- 聚怪
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval = 13.5},
                },
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50302}, -- 冲锋
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
                    OPTIONS = {interval = 50,first_interval = 15},
                },
				{
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50304}, -- 连刺AOE
                },
            },
        },
		
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 50,first_interval = 40},
                },
				{
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50303}, -- 连刺
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval =25,first_interval=18},
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
        
return npc_qiangqibing_boss