--序章比比东AI
--创建人：张义
--创建时间：2018年4月9日18:29:58
--修改时间：



local prologue_npc_bibidong = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		-- {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 5,first_interval=2},
  --               },
  --               {
  --                   CLASS = "action.QAIAttackAnyEnemy",
  --                   OPTIONS = {always = true},
  --               },
  --               {
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = 50238}, 
  --               },
  --           },
  --       },
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

return prologue_npc_bibidong