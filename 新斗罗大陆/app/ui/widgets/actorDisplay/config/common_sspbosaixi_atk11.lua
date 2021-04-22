local common_ssmahongjun_atk11 = 
{
	CLASS = "composite.QUIDBParallel",
	ARGS = 
	{
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "attack11"},
				},
			},
		},
		-- {
    --         CLASS = "composite.QUIDBSequence",
    --         ARGS = 
    --         {
    --             {
    --                 CLASS = "action.QUIDBDelayTime",
    --                 OPTIONS = {delay_frame = 6},
    --             },
				-- {
		  --           CLASS = "composite.QUIDBParallel",
		  --           ARGS = 
		  --           {                                
		  --               {
		  --                   CLASS = "action.QUIDBPlayEffect",
		  --                   OPTIONS = {effect_id = "ui_sspbosaixi_attack11_1", is_hit_effect = false},
		  --               },
		  --               {
		  --                   CLASS = "action.QUIDBPlayEffect",
		  --                   OPTIONS = {effect_id = "ui_sspbosaixi_attack11_2", is_hit_effect = false},
		  --               },
		  --               {
		  --                   CLASS = "action.QUIDBPlayEffect",
		  --                   OPTIONS = {effect_id = "ui_sspbosaixi_attack11_3", is_hit_effect = false},
		  --               },
		  --               {
		  --                   CLASS = "action.QUIDBPlayEffect",
		  --                   OPTIONS = {effect_id = "ui_sspbosaixi_attack11_4", is_hit_effect = false},
		  --               },
		  --           },
		  --       },
	   --      },
        -- },
	},
}

return common_ssmahongjun_atk11