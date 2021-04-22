	local anqi_shenpanzhijian_debuff_cf0 ={
	    CLASS = "composite.QSBSequence",
      	    ARGS = {
			  {
				  CLASS = "action.QSBExpression",
				  OPTIONS = {
					  expStr = "value = {16.2*self:attack_f}",
					  set_black_board = {value = "value"},
				  }, -- 取攻击力的百分比
			  },
			  {
				  CLASS = "action.QSBArgsSelectTarget",
				  OPTIONS = {just_hero = true, under_status = "heianzhili", set_black_board = {selectTarget = "selectTarget"},},
			  },
			  {
				  CLASS = "action.QSBDecreaseAbsorbByProp",
				  OPTIONS = {
					  get_black_board = {value = "value", selectTarget = "selectTarget"},
					  -- attacker_max_hp_percent_limit = 0.3, -- 消减护盾不超过攻击者最大血量的30%,可以不要
					  debug = true,
				  },
			  },
			{
				CLASS = "action.QSBAttackFinish"
			},
		},
	}

return anqi_shenpanzhijian_debuff_cf0




