--斗罗AI：鬼虎BOSS
--普通副本
--创建人：fky
--创建时间：2018-1-20
--id 3306  3--16
--分身，飞扑（分身也扑），群体嗜血，影袭

local npc_boss_guihujingying = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
      
		--{
        --    CLASS = "composite.QAISequence",
        --    ARGS = 
          -- {
          --     {
          --         CLASS = "action.QAITimer",
          --         OPTIONS = {interval = 22,first_interval = 18},
          --     },
			--	{
          --         CLASS = "action.QAIAttackAnyEnemy",
          --         OPTIONS = {always = true},
          --     },
          --     {
          --         CLASS = "action.QAIUseSkill",
          --         OPTIONS = {skill_id = 50383},--召唤-1
          --     },
          -- },
			--{
          --     {
          --         CLASS = "action.QAITimer",
          --         OPTIONS = {interval = 22,first_interval = 18},
          --     },
			--	{
          --         CLASS = "action.QAIAttackAnyEnemy",
          --         OPTIONS = {always = true},
          --     },
          --     {
          --         CLASS = "action.QAIUseSkill",
          --         OPTIONS = {skill_id = 50386},--召唤-2
          --     },
          -- },
            {
            CLASS = "composite.QAISequence",
            ARGS = 
                {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30,first_interval = 8},
                },
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50521},--飞扑
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
                   OPTIONS = {interval = 30,first_interval = 11},
                   },
                   {
                   CLASS = "action.QAIUseSkill",
                   OPTIONS = {skill_id = 50519},--七连击
                   },
               },
            },
			{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30,first_interval=15},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
            },
			{
                   CLASS = "composite.QAISequence",
                   ARGS = 
               {
                  {
                   CLASS = "action.QAITimer",
                   OPTIONS = {interval = 80,first_interval = 19},
                   },
                   {
                   CLASS = "action.QAIUseSkill",
                   OPTIONS = {skill_id = 50095},--召唤-1
                   },
               },
            },
			{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                {
                   {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30,first_interval = 25},
                    },
                    {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50520},--聚怪
                    },
                },
            },
			{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                {
                    {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30,first_interval = 27},
                    },
                    {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50519},--七连击
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

return npc_boss_guihujingying