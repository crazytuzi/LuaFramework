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
					OPTIONS = {animation = "attack13"},
				},
			},
		},
		-- {
  --           CLASS = "composite.QUIDBParallel",
  --           ARGS = 
  --           {                                
  --               {
  --                   CLASS = "action.QUIDBPlayEffect",
  --                   OPTIONS = {effect_id = "ui_sspbosaixi_attack13_1", is_hit_effect = false},
  --               },
  --               {
  --                   CLASS = "action.QUIDBPlayEffect",
  --                   OPTIONS = {effect_id = "ui_sspbosaixi_attack13_2", is_hit_effect = false},
  --               },
  --               {
  --                   CLASS = "action.QUIDBPlayEffect",
  --                   OPTIONS = {effect_id = "ui_sspbosaixi_attack13_3", is_hit_effect = false},
  --               },
  --           },
  --       },
	},
}

return common_ssmahongjun_atk11