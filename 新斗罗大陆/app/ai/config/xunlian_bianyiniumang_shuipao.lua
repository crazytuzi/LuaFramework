

local npc_boss_yangwudi_qiangzhen= 
{     
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
              OPTIONS = {skill_id = 52134},
          },
      },
    },
    {
      CLASS = "composite.QAISequence",
      ARGS = 
      {
          {
              CLASS = "action.QAITimer",
              OPTIONS = {interval = 500,first_interval= 500},
          },
          {
              CLASS = "action.QAIUseSkill",
              OPTIONS = {skill_id = 53015}, --自爆
          },
      },
    },
  },
}
        
return npc_boss_yangwudi_qiangzhen