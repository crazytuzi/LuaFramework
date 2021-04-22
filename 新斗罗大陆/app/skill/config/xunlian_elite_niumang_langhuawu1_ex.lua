local boss_niumang_langhuawu1 = 
{
 	CLASS = "composite.QSBParallel",
 	ARGS = 
    {
    	{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "root_25s"},
		},
    	{
		 	CLASS = "composite.QSBParallel",
		 	ARGS = 
		    {
				{
	                CLASS = "action.QSBPlayAnimation",
	                OPTIONS = {animation = "attack13"},
	            },
	            {
		    		CLASS = "composite.QSBSequence",
		    		ARGS = 
		    		{
		                {
			                CLASS = "action.QSBDelayTime",
			                OPTIONS = {delay_time = 19 / 24 },
					    },					    
	            		{
                            CLASS = "action.QSBHitTarget",
                        },
                   	},
               	},
                {
		    		CLASS = "composite.QSBSequence",
		    		ARGS = 
		    		{
		                {
			                CLASS = "action.QSBDelayTime",
			                OPTIONS = {delay_time = 65 / 24 },
					    },
		    			{
		                    CLASS = "action.QSBActorFadeOut",
		                    OPTIONS = {duration = 0.3, revertable = true},
		                },
		                {
		            		CLASS = "action.QSBTeleportToAbsolutePosition",
		            		OPTIONS = {pos = {x = 655, y = 320}},
		        		},
		        		{
		                    CLASS = "action.QSBActorFadeIn",
		                    OPTIONS = {duration = 0.3, revertable = true},
		                },
		            },
        		},
    		},
		},
		{
    		CLASS = "composite.QSBSequence",
    		ARGS = 
    		{
			    {
				 	CLASS = "composite.QSBParallel",
				 	ARGS = 
			    	{
				        {
						 	CLASS = "composite.QSBParallel",
						 	ARGS = 
					    	{
					    	---6点陷阱
						        {
						            CLASS = "composite.QSBSequence",
						            ARGS = 
						            {
						                {
						                    CLASS = "action.QSBDelayTime",
						                    OPTIONS = {delay_time = 15 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua1"} ,
								                },
								                {
						    						CLASS = "composite.QSBSequence",
						    						ARGS = 
						    						{
										                {
										                    CLASS = "action.QSBDelayTime",
										                    OPTIONS = {delay_time = 72 / 24 },
								                		},
									                    {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua1"} ,
										                },
										            },
										        },
								            },
							            },
						            },
						        },
						        {
						            CLASS = "composite.QSBSequence",
						            ARGS =
						            {
						                {
						                    CLASS = "action.QSBDelayTime",
						                    OPTIONS = {delay_time = 30 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua2"} ,
								                },
								                {
						    						CLASS = "composite.QSBSequence",
						    						ARGS = 
						    						{
										                {
										                    CLASS = "action.QSBDelayTime",
										                    OPTIONS = {delay_time = 72 / 24 },
								                		},
									                    {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua2"} ,
										                },
										            },
										        },
								            },
							            },
						            }, 
						        },
						    },
					    },
				---4点陷阱
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 96 / 24 },
				                },
						 		{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 96 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyub1"} ,
										                },
										                {
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua00"} ,
												                },
												                {
										    						CLASS = "composite.QSBSequence",
										    						ARGS = 
										    						{
														                {
														                    CLASS = "action.QSBDelayTime",
														                    OPTIONS = {delay_time = 72 / 24 },
												                		},
													                    {
														                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
														                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua00"} ,
														                },
														            },
														        },
													        },
												        },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhub1"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 111 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyub2"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhub2"} ,
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
				----3点
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 192 / 24 },
				                },
								{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 177 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyuc1"} ,
										                },
										                {
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua00"} ,
												                },
												                {
										    						CLASS = "composite.QSBSequence",
										    						ARGS = 
										    						{
														                {
														                    CLASS = "action.QSBDelayTime",
														                    OPTIONS = {delay_time = 72 / 24 },
												                		},
													                    {
														                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
														                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua00"} ,
														                },
														            },
														        },
													        },
												        },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhuc1"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 192 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyuc2"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhuc2"} ,
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
				----2点
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 288 / 24 },
				                },
								{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 258 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyud1"} ,
										                },
										                {
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua00"} ,
												                },
												                {
										    						CLASS = "composite.QSBSequence",
										    						ARGS = 
										    						{
														                {
														                    CLASS = "action.QSBDelayTime",
														                    OPTIONS = {delay_time = 72 / 24 },
												                		},
													                    {
														                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
														                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua00"} ,
														                },
														            },
														        },
													        },
												        },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhud1"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 273 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyud2"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhud2"} ,
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
					     ----2点
					    {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 384 / 24 },
				                },
								{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 339 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua1a"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua1a"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 354 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua2a"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua2a"} ,
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
				---12点
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
						        {
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 15 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua1a"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua1a"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 30 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua2a"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua2a"} ,
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
				---4点陷阱
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				               	{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 96 / 24 },
				                },
						 		{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 96 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyub1a"} ,
										                },
										                {
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua00"} ,
												                },
												                {
										    						CLASS = "composite.QSBSequence",
										    						ARGS = 
										    						{
														                {
														                    CLASS = "action.QSBDelayTime",
														                    OPTIONS = {delay_time = 72 / 24 },
												                		},
													                    {
														                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
														                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua00"} ,
														                },
														            },
														        },
													        },
												        },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhub1a"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 111 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyub2a"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhub2a"} ,
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
				----3点
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 192 / 24 },
				                },
								{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 177 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyuc1a"} ,
										                },
										                {
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua00"} ,
												                },
												                {
										    						CLASS = "composite.QSBSequence",
										    						ARGS = 
										    						{
														                {
														                    CLASS = "action.QSBDelayTime",
														                    OPTIONS = {delay_time = 72 / 24 },
												                		},
													                    {
														                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
														                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua00"} ,
														                },
														            },
														        },
													        },
												        },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhuc1a"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 192 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyuc2a"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhuc2a"} ,
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
				----2点
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 288 / 24 },
				                },
								{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 258 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyud1a"} ,
										                },
										                {
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua00"} ,
												                },
												                {
										    						CLASS = "composite.QSBSequence",
										    						ARGS = 
										    						{
														                {
														                    CLASS = "action.QSBDelayTime",
														                    OPTIONS = {delay_time = 72 / 24 },
												                		},
													                    {
														                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
														                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua00"} ,
														                },
														            },
														        },
													        },
												        },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhud1a"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 273 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyud2a"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhud2a"} ,
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
				        ----2点
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 384 / 24 },
				                },
								{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 339 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua1"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua1"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 354 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua2"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua2"} ,
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
				    },
			    },
			    --第2轮
			    {
				 	CLASS = "composite.QSBParallel",
				 	ARGS = 
			    	{
					---4点陷阱
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 96 / 24 },
				                },
						 		{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 96 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyub1"} ,
										                },
										                {
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua00"} ,
												                },
												                {
										    						CLASS = "composite.QSBSequence",
										    						ARGS = 
										    						{
														                {
														                    CLASS = "action.QSBDelayTime",
														                    OPTIONS = {delay_time = 72 / 24 },
												                		},
													                    {
														                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
														                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua00"} ,
														                },
														            },
														        },
													        },
												        },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhub1"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 111 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyub2"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhub2"} ,
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
				----3点
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 192 / 24 },
				                },
								{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 177 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyuc1"} ,
										                },
										                {
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua00"} ,
												                },
												                {
										    						CLASS = "composite.QSBSequence",
										    						ARGS = 
										    						{
														                {
														                    CLASS = "action.QSBDelayTime",
														                    OPTIONS = {delay_time = 72 / 24 },
												                		},
													                    {
														                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
														                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua00"} ,
														                },
														            },
														        },
													        },
												        },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhuc1"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 192 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyuc2"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhuc2"} ,
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
				----2点
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 288 / 24 },
				                },
								{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 258 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyud1"} ,
										                },
										                {
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua00"} ,
												                },
												                {
										    						CLASS = "composite.QSBSequence",
										    						ARGS = 
										    						{
														                {
														                    CLASS = "action.QSBDelayTime",
														                    OPTIONS = {delay_time = 72 / 24 },
												                		},
													                    {
														                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
														                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua00"} ,
														                },
														            },
														        },
													        },
												        },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhud1"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 273 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyud2"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhud2"} ,
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
					     ----2点
					    {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 384 / 24 },
				                },
								{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 339 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua1a"} ,
										                },										                
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua1a"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 354 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua2a"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua2a"} ,
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
				---4点陷阱
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				               	{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 96 / 24 },
				                },
						 		{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 96 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyub1a"} ,
										                },
										                {
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua00"} ,
												                },
												                {
										    						CLASS = "composite.QSBSequence",
										    						ARGS = 
										    						{
														                {
														                    CLASS = "action.QSBDelayTime",
														                    OPTIONS = {delay_time = 72 / 24 },
												                		},
													                    {
														                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
														                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua00"} ,
														                },
														            },
														        },
													        },
												        },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhub1a"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 111 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyub2a"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhub2a"} ,
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
				----3点
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 192 / 24 },
				                },
								{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 177 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyuc1a"} ,
										                },
										                {
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua00"} ,
												                },
												                {
										    						CLASS = "composite.QSBSequence",
										    						ARGS = 
										    						{
														                {
														                    CLASS = "action.QSBDelayTime",
														                    OPTIONS = {delay_time = 72 / 24 },
												                		},
													                    {
														                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
														                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua00"} ,
														                },
														            },
														        },
													        },
												        },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhuc1a"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 192 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyuc2a"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhuc2a"} ,
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
				----2点
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 288 / 24 },
				                },
								{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 258 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyud1a"} ,
										                },
										                {
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua00"} ,
												                },
												                {
										    						CLASS = "composite.QSBSequence",
										    						ARGS = 
										    						{
														                {
														                    CLASS = "action.QSBDelayTime",
														                    OPTIONS = {delay_time = 72 / 24 },
												                		},
													                    {
														                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
														                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua00"} ,
														                },
														            },
														        },
													        },
												        },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhud1a"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 273 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyud2a"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhud2a"} ,
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
				        ----2点
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 384 / 24 },
				                },
								{
								 	CLASS = "composite.QSBParallel",
								 	ARGS = 
							    	{
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS = 
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 339 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua1"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua1"} ,
												                },
												            },
												        },
										            },
									            },
								            },
								        },
								        {
								            CLASS = "composite.QSBSequence",
								            ARGS =
								            {
								                {
								                    CLASS = "action.QSBDelayTime",
								                    OPTIONS = {delay_time = 354 / 24 },
								                },
								                {
								 					CLASS = "composite.QSBParallel",
								 					ARGS =
								 					{
										                {
										                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuiyua2"} ,
										                },
										                {
								    						CLASS = "composite.QSBSequence",
								    						ARGS = 
								    						{
												                {
												                    CLASS = "action.QSBDelayTime",
												                    OPTIONS = {delay_time = 72 / 24 },
										                		},
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xunlian_elite_niumang_shuizhua2"} ,
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
				    },
			    },	   
		    },
	    },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 80 / 24 },
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack14"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 90 / 24 },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 90 / 24 },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 81 / 24 },
                },
                -- {
                --     CLASS = "action.QSBPlayAnimation",
                --     OPTIONS = {animation = "attack14"},
                -- },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 48 / 24 },
                },
                {
 					CLASS = "composite.QSBParallel",
 					ARGS =
 					{
		                {
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
						},		               
	                },
                },
            },
        },
    },
}

return boss_niumang_langhuawu1

