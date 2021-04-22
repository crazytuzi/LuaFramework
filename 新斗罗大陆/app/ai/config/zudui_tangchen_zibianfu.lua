--斗罗AI 唐晨BOSS绿蝙蝠
--副本14-8
--id 3677
--[[
闪现\群体恐惧
]]--
--创建人：庞圣峰
--创建时间：2018-7-3

local zudui_tangchen_zibianfu= {     
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
                    OPTIONS = {interval = 10,first_interval=10},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51778},          --群体恐惧
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval=7},
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
  --                   OPTIONS = {interval = 1,first_interval=20.3},
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
        
return zudui_tangchen_zibianfu