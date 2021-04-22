--风尾鸡冠蛇
--普通副本
--id 3024  2-3
--[[
单体：眩晕
毒液陷阱
直线冲锋 带击飞和眩晕
召唤一次直线冲锋的小蛇（绿色换皮）
]]
--创建人：许成
--创建时间：2017-7-4
--迭代: 庞圣峰 2018-3-23

local npc_boss_mantuoluoshewang= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 25,first_interval=14},
                -- },
                -- {
                --     CLASS = "action.QAIAttackEnemyOutOfDistance",
                --     OPTIONS = {always = true},
                -- },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50190},          --冲锋
        --         },
        --         {
        --             CLASS = "action.QAIIgnoreHitLog",              --使得ai忽略仇恨列表，锁定攻击当前目标（除非当前目标死了）
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval =15,first_interval= 10},
                },
				-- {
    --                 CLASS = "action.QAIAttackClosestEnemy",
    --             },
                {
                   CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50191},          --毒潭
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval= 5},
                },
                {
                    CLASS = "action.QAIAttackByHitlog",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50033},          --毒蛇冲刺
                },
            },
        },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval =25,first_interval=20},
        --         },
        --         {
        --             CLASS = "action.QAIAcceptHitLog",
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval=15},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50192},          --召唤-1   3011
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
        
return npc_boss_mantuoluoshewang