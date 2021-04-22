

local shengzhu_bingdong1 = {
     CLASS = "composite.QSBParallel",
     ARGS = {
		-- {
  --           CLASS = "composite.QSBSequence",
  --           ARGS = {
		-- 		{
  --                   CLASS = "action.QSBDelayTime",
  --                   OPTIONS = {delay_frame = 19},
  --               },
		-- 		{
		-- 			CLASS = "action.QSBPlayEffect",
		-- 			OPTIONS = {is_hit_effect = false},
		-- 		},
  --           },
  --       },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },     
    },
}

return shengzhu_bingdong1

