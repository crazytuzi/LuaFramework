

local npc_boss_yangwudi_qiangzhen= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
		-- {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 0.7,first_interval= 0.8},
  --               },
  --               {
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = 50573}, --持续AOE
  --               },
  --           },
  --       },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval= 19},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50572}, --自爆
                },
            },
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
        
return npc_boss_yangwudi_qiangzhen