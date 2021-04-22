local npc_boss_renmianmozhu = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval = 4},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51216},
                },
            },
        },
		-- {
  --           CLASS = "action.QAIAttackByHitlog",
  --       },
  --       {
  --           CLASS = "composite.QAISelector",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAIIsAttacking",
  --               },
  --               {
  --                   CLASS = "action.QAIBeatBack",
  --               },
  --               {
  --                   CLASS = "action.QAIAttackClosestEnemy",
  --               },
  --           },
  --       },
    },
}

return npc_boss_renmianmozhu