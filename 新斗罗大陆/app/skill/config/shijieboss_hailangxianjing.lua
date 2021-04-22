local shijieboss_hailangxianjing = 
{
 	CLASS = "composite.QSBParallel",
 	ARGS = 
    {
    	{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
    	{
		 	CLASS = "composite.QSBSequence",
		 	ARGS = 
		    {
				{
	                CLASS = "action.QSBPlayAnimation",
	                OPTIONS = {animation = "attack14"},
	            },
	            {
                    CLASS = "action.QSBAttackFinish",
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
				 	CLASS = "composite.QSBParallel",
				 	ARGS = 
			    	{
			    		{
		                    CLASS = "composite.QSBSequence",
		                    ARGS = 
		                    {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 61/24 },
		                        },
		                        {
		                            CLASS = "action.QSBShakeScreen",
		                            OPTIONS = {amplitude = 10, duration = 0.4, count = 2,},
		                        },
		                    },
		                },
		                {
		                    CLASS = "composite.QSBSequence",
		                    ARGS = 
		                    {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 133/24 },
		                        },
		                        {
		                            CLASS = "action.QSBShakeScreen",
		                            OPTIONS = {amplitude = 10, duration = 0.4, count = 2,},
		                        },
		                    },
		                },
		                {
		                    CLASS = "composite.QSBSequence",
		                    ARGS = 
		                    {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 96/24 },
		                        },
		                        {
		                            CLASS = "action.QSBShakeScreen",
		                            OPTIONS = {amplitude = 10, duration = 0.4, count = 2,},
		                        },
		                    },
		                },
		                {
		                    CLASS = "composite.QSBSequence",
		                    ARGS = 
		                    {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 238/24},
		                        },
		                        {
		                            CLASS = "action.QSBShakeScreen",
		                            OPTIONS = {amplitude = 10, duration = 0.4, count = 2,},
		                        },
		                    },
		                },
		                {
		                    CLASS = "composite.QSBSequence",
		                    ARGS = 
		                    {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 225/24},
		                        },
		                        {
		                            CLASS = "action.QSBShakeScreen",
		                            OPTIONS = {amplitude = 10, duration = 0.4, count = 2,},
		                        },
		                    },
		                },
		        		{
		                    CLASS = "composite.QSBSequence",
		                    ARGS = 
		                    {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 216/24},
		                        },
		                        {
		                            CLASS = "action.QSBShakeScreen",
		                            OPTIONS = {amplitude = 10, duration = 0.4, count = 2,},
		                        },
		                    },
		                },
		                {
		                    CLASS = "composite.QSBSequence",
		                    ARGS = 
		                    {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 206/24},
		                        },
		                        {
		                            CLASS = "action.QSBShakeScreen",
		                            OPTIONS = {amplitude = 10, duration = 0.4, count = 2,},
		                        },
		                    },
		                },   
		                {
		                    CLASS = "composite.QSBSequence",
		                    ARGS = 
		                    {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 265/24},
		                        },
		                        {
		                            CLASS = "action.QSBShakeScreen",
		                            OPTIONS = {amplitude = 30, duration = 0.4, count = 5,},
		                        },
		                    },
		                },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 13 / 24 },
				                },
						        {
						            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuc1a"} ,
						        },
								{
								    CLASS = "action.QSBDelayTime",
								    OPTIONS = {delay_time = 48 / 24 },
						        },
							    {
								    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuc1a"} ,
								},
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 13 / 24 },
				                },
						        {
						            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuc2a"} ,
						        },
								{
								    CLASS = "action.QSBDelayTime",
								    OPTIONS = {delay_time = 48 / 24 },
						        },
							    {
								    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuc2a"} ,
								},
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 13 / 24 },
				                },
						        {
						            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyud1a"} ,
						        },
								{
								    CLASS = "action.QSBDelayTime",
								    OPTIONS = {delay_time = 48 / 24 },
						        },
							    {
								    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhud1a"} ,
								},
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time =  48/ 24 },
				                },
						        {
						            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyud2a"} ,
						        },
								{
								    CLASS = "action.QSBDelayTime",
								    OPTIONS = {delay_time = 48 / 24 },
						        },
							    {
								    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhud2a"} ,
								},
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
				                },
						        {
						            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyue1a"} ,
						        },
								{
								    CLASS = "action.QSBDelayTime",
								    OPTIONS = {delay_time = 48 / 24 },
						        },
							    {
								    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhue1a"} ,
								},
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
				                },
						        {
						           	CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyue2a"} ,
						        },
								{
								    CLASS = "action.QSBDelayTime",
								    OPTIONS = {delay_time = 48 / 24 },
						        },
							    {
								    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhue2a"} ,
								},
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 85 / 24 },
				                },
						        {
						            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuf1a"} ,
						        },
								{
								    CLASS = "action.QSBDelayTime",
								    OPTIONS = {delay_time = 48 / 24 },
						        },
							    {
								    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuf1a"} ,
								},
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 85 / 24 },
				                },
						        {
						            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuf2a"} ,
						        },
								{
								    CLASS = "action.QSBDelayTime",
								    OPTIONS = {delay_time = 48 / 24 },
						        },
							    {
								    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhfh2a"} ,
								},
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 85 / 24 },
				                },
						        {
						            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyug1a"} ,
						        },
								{
								    CLASS = "action.QSBDelayTime",
								    OPTIONS = {delay_time = 48 / 24 },
						        },
							    {
								    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhug1a"} ,
								},
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 188 / 24 },
				                },
						        {
						            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyui1a"} ,
						        },
								{
								    CLASS = "action.QSBDelayTime",
								    OPTIONS = {delay_time = 48 / 24 },
						        },
							    {
								    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhui1a"} ,
								},
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 188 / 24 },
				                },
						        {
						            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyui2a"} ,
						        },
								{
								    CLASS = "action.QSBDelayTime",
								    OPTIONS = {delay_time = 48 / 24 },
						        },
							    {
								    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhui2a"} ,
								},
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 188 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuj1a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuj1a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time =  177 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuj2a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuj2a"} ,
				                },
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 177 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuk1a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuk1a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 177 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuk2a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuk2a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 168 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyul1a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhul1a"} ,
				                },
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 168 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyul2a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhlh2a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 168 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyum1a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhum1a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 158 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyum2a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhum2a"} ,
				                },
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 158 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyun1a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhun1a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 158 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyun2a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhun2a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 217 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyui1a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhui1a"} ,
				                },
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 217 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyui2a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhui2a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 217 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuj1a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuj1a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time =  217 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuj2a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuj2a"} ,
				                },
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 217 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuk1a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuk1a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 217 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuk2a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuk2a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 217 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyul1a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhul1a"} ,
				                },
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 217 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyul2a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhlh2a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 217 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyum1a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhum1a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 217 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyum2a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhum2a"} ,
				                },
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 217 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyun1a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhun1a"} ,
				                },
				            }, 
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS =
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 217 / 24 },
				                },
				                {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyun2a"} ,
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 48 / 24 },
		                		},
			                    {
				                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
				                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhun2a"} ,
				                },
				            }, 
				        },
				    },
			    },

		    },
	    },
    },
}
return shijieboss_hailangxianjing

