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
					OPTIONS = {animation = "victory"},
				},
			},
		},
		-- {
  --           CLASS = "composite.QUIDBSequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QUIDBDelayTime",
  --                   OPTIONS = {delay_frame = 50},
  --               },
  --               {
  --                   CLASS = "action.QUIDBPlayEffect",
  --                   OPTIONS = {is_hit_effect = false, effect_id = "ui_sspbosaixi_shanxian03"},
  --               },
  --           },
  --       },
	},
}

return common_ssmahongjun_atk11