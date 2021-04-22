
local common_cnxiaowu_atk11 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
    	{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
				{
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 30 / 24 * 30},
                },
				{
					CLASS = "composite.QUIDBParallel",
					ARGS = {
						{
							CLASS = "action.QUIDBPlayAnimation",
							OPTIONS = {animation = "attack11_1"},
						},
						{
							CLASS = "action.QUIDBPlayLoopEffect",
							OPTIONS = {effect_id = "chengnianxiaowu_attack11_5", duration = 2},
						},
					},
				},
			},
		},
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 36 / 24 * 30},
                },			
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {effect_id = "chengnianxiaowu_attack11_6"},
				},
			},
		},
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 42 / 24 * 30},
                },			
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {effect_id = "chengnianxiaowu_attack11_7"},
				},
			},
		},
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 48 / 24 * 30},
                },			
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {effect_id = "chengnianxiaowu_attack11_8"},
				},
			},
		},
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 54 / 24 * 30},
                },			
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {effect_id = "chengnianxiaowu_attack11_9"},
				},
			},
		},
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 60 / 24 * 30},
                },			
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {effect_id = "chengnianxiaowu_attack11_10"},
				},
			},
		},
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 66 / 24 * 30},
                },			
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {effect_id = "chengnianxiaowu_attack11_11"},
				},
			},
		},
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 72 / 24 * 30},
                },			
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {effect_id = "chengnianxiaowu_attack11_12"},
				},
			},
		},
		-- {
		-- 	CLASS = "composite.QUIDBSequence",
		-- 	ARGS = {
  --               {
  --                   CLASS = "action.QUIDBDelayTime",
  --                   OPTIONS = {delay_frame = 110 / 24 * 30},
  --               },			
		-- 		{
		-- 			CLASS = "action.QUIDBPlayEffect",
		-- 			OPTIONS = {effect_id = "chengnianxiaowu_attack11_13"},
		-- 		},
		-- 	},
		-- },
		-- {
		-- 	CLASS = "composite.QUIDBSequence",
		-- 	ARGS = {
  --               {
  --                   CLASS = "action.QUIDBDelayTime",
  --                   OPTIONS = {delay_frame = 120 / 24 * 30},
  --               },			
		-- 		{
		-- 			CLASS = "action.QUIDBPlayEffect",
		-- 			OPTIONS = {effect_id = "chengnianxiaowu_attack11_14"},
		-- 		},
		-- 	},
		-- },
		-- {
		-- 	CLASS = "composite.QUIDBSequence",
		-- 	ARGS = {
  --               {
  --                   CLASS = "action.QUIDBDelayTime",
  --                   OPTIONS = {delay_frame = 48 / 24 * 30},
  --               },			
		-- 		{
		-- 			CLASS = "action.QUIDBPlayAnimation",
		-- 			OPTIONS = {animation = "stand"},
		-- 		},
		-- 	},
		-- },
    },
}



return common_cnxiaowu_atk11