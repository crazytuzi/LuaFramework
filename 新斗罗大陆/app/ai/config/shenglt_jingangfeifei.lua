--斗罗AI：金刚狒狒
--升灵台
--id 4101
--[[
投石车
被强化后全屏随机放红圈
]]
--psf 2020-4-14

local shenglt_jingangfeifei = 
{
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 0},
                },
				-- {
                --     CLASS = "action.QAIIsUsingSkill",
                --     OPTIONS = {reverse_result = true , check_skill_id = 53274},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53278},
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

return shenglt_jingangfeifei