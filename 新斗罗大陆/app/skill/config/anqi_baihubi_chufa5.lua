	local anqi_xiehuoshuanglian_trigger_1 ={
	    CLASS = "composite.QSBSequence",
		OPTIONS = {forward_mode = true},
	    ARGS = {
	        {
                CLASS = "action.QSBRemoveBuff",
             	OPTIONS = {buff_id = "anqi_baihubi_buff5_3",remove_all_same_buff_id = true, enemies_except_target = true},
         	},
         	
	        {			
	            CLASS = "action.QSBArgsConditionSelector",
	            OPTIONS = {
	                failed_select = -1,
	                {expression = "self:is_pvp=true", select = 1},
	                {expression = "self:is_pvp=false", select = 2},

	            }
	        },
	        {
	            CLASS = "composite.QSBSelector",
	            ARGS = {
	                {
	                    CLASS = "composite.QSBSequence",
	                    ARGS = {
	                    	 {
					            CLASS = "action.QSBArgsConditionSelector",
					            OPTIONS = {
					                failed_select = 4,
					                {expression = "target:hp<target:max_hp*0.3", select = 1},
					                {expression = "target:hp<target:max_hp*0.7", select = 2},
					                {expression = "target:hp<target:max_hp*1.1", select = 3},
					            }
					        },
					        {
					            CLASS = "composite.QSBSelector",
					            ARGS = {
				                    {
				                        CLASS = "action.QSBHitTarget",
				                        OPTIONS = {damage_scale = 1,check_target_by_skill = true},
				                    },
				                    {
				                        CLASS = "action.QSBHitTarget",
				                        OPTIONS = {damage_scale = 2,check_target_by_skill = true},
				                    },
				                    {
				                        CLASS = "action.QSBHitTarget",
				                        OPTIONS = {damage_scale = 3,check_target_by_skill = true},
				                    },
				                    {
				                        CLASS = "action.QSBHitTarget",
				                        OPTIONS = {check_target_by_skill = true},
				                    },

					            },
					        },
                    		{
				                CLASS = "action.QSBApplyBuff",
				             	OPTIONS = {buff_id = "anqi_baihubi_buff5_3",is_target = true},
				         	},
					   --      {
						  --       CLASS = "action.QSBRemoveBuff",
						  --    	OPTIONS = {buff_id = "anqi_baihubi_buff1_chufa1_3",remove_all_same_buff_id = true, is_target = false},
						 	-- },	
						    -- {
						    --     CLASS = "action.QSBHitTarget",
						    --     OPTIONS = {check_target_by_skill = true},
						    -- },
					    },
		    		},
			        {
	                    CLASS = "composite.QSBSequence",
	                    ARGS = {
				 		 	{
				                CLASS = "action.QSBArgsConditionSelector",
				                OPTIONS = {
				                    failed_select = 1,
				                    {expression = "self:has_buff:anqi_baihubi_biaojibuff", select = 2},
				                }
				            },
				             {
				                CLASS = "composite.QSBSelector",
				                ARGS = {
			                		{
					                    CLASS = "composite.QSBSequence",
					                    ARGS = {
					            	        {
					            	            CLASS = "action.QSBArgsConditionSelector",
					            	            OPTIONS = {
					            	                failed_select = 4,
					            	                {expression = "target:hp<target:max_hp*0.3", select = 1},
					            	                {expression = "target:hp<target:max_hp*0.7", select = 2},
					            	                {expression = "target:hp<target:max_hp*1.1", select = 3},
					            	            }
					            	        },
					            	        {
					            	            CLASS = "composite.QSBSelector",
					            	            ARGS = {

					                                {
					                                    CLASS = "action.QSBHitTarget",
					                                    OPTIONS = {damage_scale = 1,check_target_by_skill = true},
					                                },
					                                {
					                                    CLASS = "action.QSBHitTarget",
					                                    OPTIONS = {damage_scale = 2,check_target_by_skill = true},
					                                },
					                                {
					                                    CLASS = "action.QSBHitTarget",
					                                    OPTIONS = {damage_scale = 3,check_target_by_skill = true},
					                                },
					                                {
					                                    CLASS = "action.QSBHitTarget",
					                                    OPTIONS = {check_target_by_skill = true},
					                                },
					            	            },
					            	        },
			            	            },
			            	        },

			            	        {
					                    CLASS = "composite.QSBSequence",
					                    ARGS = {
					                    	 {
				                                CLASS = "action.QSBArgsConditionSelector",
				                                OPTIONS = {
				                                    failed_select = 1,
				                                    {expression = "target:has_buff:pve_zuojia_shanghaibeishu", select = 2},
				                                }
				                            },
				                            {
								                CLASS = "composite.QSBSelector",
								                ARGS = {
							                		{
									                    CLASS = "composite.QSBSequence",
									                    ARGS = {
									                        {
									                            CLASS = "action.QSBArgsConditionSelector",
									                            OPTIONS = {
									                                failed_select = 4,
									                                {expression = "target:hp<target:max_hp*0.3", select = 1},
									                                {expression = "target:hp<target:max_hp*0.7", select = 2},
									                                {expression = "target:hp<target:max_hp*1.1", select = 3},
									                            }
									                        },
									                        {
									                            CLASS = "composite.QSBSelector",
									                            ARGS = {

									                                {
									                                    CLASS = "action.QSBHitTarget",
									                                    OPTIONS = {damage_scale = 3,check_target_by_skill = true},
									                                },
									                                {
									                                    CLASS = "action.QSBHitTarget",
									                                    OPTIONS = {damage_scale = 6,check_target_by_skill = true},
									                                },
									                                {
									                                    CLASS = "action.QSBHitTarget",
									                                    OPTIONS = {damage_scale = 9,check_target_by_skill = true},
									                                },
									                                {
									                                    CLASS = "action.QSBHitTarget",
									                                    OPTIONS = {check_target_by_skill = true},
									                                },
									                            },
									                        },
							                            },
							                        },
							                        {
									                    CLASS = "composite.QSBSequence",
									                    ARGS = {
									                        {
									                            CLASS = "action.QSBArgsConditionSelector",
									                            OPTIONS = {
									                                failed_select = 4,
									                                {expression = "target:hp<target:max_hp*0.3", select = 1},
									                                {expression = "target:hp<target:max_hp*0.7", select = 2},
									                                {expression = "target:hp<target:max_hp*1.1", select = 3},
									                            }
									                        },
									                        {
									                            CLASS = "composite.QSBSelector",
									                            ARGS = {

									                                {
									                                    CLASS = "action.QSBHitTarget",
									                                    OPTIONS = {damage_scale = 17,check_target_by_skill = true},
									                                },
									                                {
									                                    CLASS = "action.QSBHitTarget",
									                                    OPTIONS = {damage_scale = 18,check_target_by_skill = true},
									                                },
									                                {
									                                    CLASS = "action.QSBHitTarget",
									                                    OPTIONS = {damage_scale = 19,check_target_by_skill = true},
									                                },
									                                {
									                                    CLASS = "action.QSBHitTarget",
									                                    OPTIONS = {check_target_by_skill = true},
									                                },
									                            },
									                        },
									                    },
							                  		},
						                    	},
							                },
					                    },
					                },
		                    	},
			                },
                    		{
				                CLASS = "action.QSBApplyBuff",
				             	OPTIONS = {buff_id = "anqi_baihubi_hp_limit",is_target = false},
				         	},
					        {
						        CLASS = "action.QSBRemoveBuff",
						     	OPTIONS = {buff_id = "anqi_baihubi_buff1_chufa1_5",remove_all_same_buff_id = true, is_target = false},
						 	},	
						    -- {
						    --     CLASS = "action.QSBHitTarget",
						    --     OPTIONS = {check_target_by_skill = true},
						    -- },
					    },
		    		},
	            },
	        },
            {
	            CLASS = "action.QSBPlayMountSkillAnimation",
	        },
	    	{
	            CLASS = "action.QSBAttackFinish"
	        },
	    },
	}

return anqi_xiehuoshuanglian_trigger_1

