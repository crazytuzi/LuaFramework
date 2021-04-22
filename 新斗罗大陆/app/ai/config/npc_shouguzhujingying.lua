--斗罗AI：瘦孤竹精英
--普通副本


--创建人：樊科远
--创建时间：2018-3-31

local npc_shouguzhujingying = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
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
							OPTIONS = {interval = 10, first_interval=4},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50007},
						},
					},
				},
				{
					CLASS = "composite.QAISequence",
					ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 10, first_interval=20},
						},
						{
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
						{
							CLASS = "action.QAIUseSkill",
							OPTIONS = {skill_id = 50382},--闪电陷阱
						},
					},
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

return npc_shouguzhujingying