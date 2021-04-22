--斗罗AI 唐晨BOSS红蝙蝠
--副本14-8
--id 3678
--[[
闪现 喷火
]]--
--创建人：庞圣峰
--创建时间：2018-7-3

local zudui_tangchen_hongbianfu= {     
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
                    OPTIONS = {skill_id = 50099},
                },
            },
        },
		-- {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 500, first_interval = 0.5},
  --               },
  --               {
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = 51766},	--入场
  --               },
  --           },
  --       },
		
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 7,first_interval=6},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51776},          --蝙蝠喷火
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 7,first_interval=4},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51777},          --蝙蝠闪现
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
            },
        },
		-- {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 1,first_interval=20.6},
  --               },
		-- 		{
  --                   CLASS = "action.QAIIsUsingSkill",
  --                   OPTIONS = {reverse_result = true , check_skill_id = 51767},
  --               }, 
  --               {
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = 51767},          --退场
  --               },
  --           },
  --       },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval=9},
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
    }
}
        
return zudui_tangchen_hongbianfu