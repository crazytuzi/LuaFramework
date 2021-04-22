--斗罗AI：朱竹青（鬼虎BOSS分身）
--普通副本
--创建人：psf
--创建时间：2018-1-20
--id 3306  3--16
--分身，飞扑（分身也扑），群体嗜血，影袭

local npc_boss_zhuzhuqing = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {   
        -- {
            -- CLASS = "composite.QAISequence",
            -- ARGS = 
            -- {
                -- {
                    -- CLASS = "action.QAITimer",
                    -- OPTIONS = {interval = 300,first_interval = 0},
                -- },
				-- {
                    -- CLASS = "action.QAIAttackAnyEnemy",
                    -- OPTIONS = {always = true},
                -- },
                -- {
                    -- CLASS = "action.QAIUseSkill",
                    -- OPTIONS = {skill_id = 50177},--分身状态BUFF
                -- },
            -- },
        -- },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 18,first_interval = 4},
                },
				{
                    CLASS = "action.QAIAttackByHatred",
                    OPTIONS = {is_get_max = false},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50176},--飞扑（分身版）
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
                    OPTIONS = {interval = 18,first_interval=7},
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

return npc_boss_zhuzhuqing