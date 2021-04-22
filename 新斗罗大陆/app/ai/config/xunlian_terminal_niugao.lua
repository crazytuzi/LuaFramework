--斗罗AI：牛皋BOSS
--普通副本
--创建人：psf
--创建时间：2018-1-20
--id 3305  3--12
--直线冲撞击飞，群体护盾

local zudui_niugao = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
      
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 35,first_interval=5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53192},--牛头盾
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 35,first_interval=11},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53162},--牛头盾
                },
            },
        },
		-- {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 35,first_interval=13},
  --               },
  --               -- {
  --               --     CLASS = "action.QAIAttackEnemyOutOfDistance",  --选择一个多少距离之外的目标执行某个行为
  --               --     OPTIONS = {current_target_excluded = true},
  --               -- },
  --               {
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = },--牛头盾
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

return zudui_niugao