

local boss_chaoxuemuzhu_chaoraozibaoAI= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
		 {
       CLASS = "composite.QAISequence",
       ARGS = 
      {
        {
          CLASS = "action.QAITimer",
          OPTIONS = {interval = 500,first_interval = 1},
        },
        {
          CLASS = "action.QAIUseSkill",
          OPTIONS = {skill_id = 53375 },  --钢甲
        },
      },
    },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 120,first_interval= 15},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 56014 }, --自爆
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
        
return boss_chaoxuemuzhu_chaoraozibaoAI