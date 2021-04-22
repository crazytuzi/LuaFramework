local shijieboss_shuizhuxianijng = 
{
 	CLASS = "composite.QSBParallel",
 	ARGS = 
    {
    	{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
    	{
		 	CLASS = "composite.QSBParallel",
		 	ARGS = 
		    {
				{
	                CLASS = "action.QSBPlayAnimation",
	                OPTIONS = {animation = "attack14"},
	            },
	            {
		    		CLASS = "composite.QSBSequence",
		    		ARGS = 
		    		{				    
	            		{
                            CLASS = "action.QSBHitTarget",
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
	                OPTIONS = {delay_time = 36 / 24 },
			    },
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
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyua1"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhua1"} ,
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
						                    OPTIONS = {delay_time = 20 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyua2"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhua2"} ,
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
						 	CLASS = "composite.QSBParallel",
						 	ARGS = 
					    	{
						        {
						            CLASS = "composite.QSBSequence",
						            ARGS = 
						            {
						                {
						                    CLASS = "action.QSBDelayTime",
						                    OPTIONS = {delay_time = 25 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyub1"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhub1"} ,
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
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyub2"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhub2"} ,
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
						 	CLASS = "composite.QSBParallel",
						 	ARGS = 
					    	{
						        {
						            CLASS = "composite.QSBSequence",
						            ARGS = 
						            {
						                {
						                    CLASS = "action.QSBDelayTime",
						                    OPTIONS = {delay_time = 35 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuc1"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuc1"} ,
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
						                    OPTIONS = {delay_time = 40 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyuc2"} ,
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
										                    CLASS = "paction.QSBMultipleTrap", --连续放置多个陷阱
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhuc2"} ,
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
						 	CLASS = "composite.QSBParallel",
						 	ARGS = 
					    	{
						        {
						            CLASS = "composite.QSBSequence",
						            ARGS = 
						            {
						                {
						                    CLASS = "action.QSBDelayTime",
						                    OPTIONS = {delay_time = 45 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyud1"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhud1"} ,
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
						                    OPTIONS = {delay_time = 50 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyud2"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhud2"} ,
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
						 	CLASS = "composite.QSBParallel",
						 	ARGS = 
					    	{
						        {
						            CLASS = "composite.QSBSequence",
						            ARGS = 
						            {
						                {
						                    CLASS = "action.QSBDelayTime",
						                    OPTIONS = {delay_time = 55 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyua1a"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhua1a"} ,
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
						                    OPTIONS = {delay_time = 60 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyua2a"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhua2a"} ,
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
						 	CLASS = "composite.QSBParallel",
						 	ARGS = 
					    	{
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
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyub1a"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhub1a"} ,
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
						                    OPTIONS = {delay_time = 70 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuiyub2a"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shijie_hujing_shuizhub2a"} ,
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
            	-- {
             --        CLASS = "action.QSBDelayTime",
             --        OPTIONS = {delay_time = 80 / 24 },
             --    },
            	-- -- {
             -- --        CLASS = "action.QSBPlayAnimation",
             -- --        OPTIONS = {animation = "attack13"},
             -- --    },
             --    {
             --        CLASS = "action.QSBPlayAnimation",
             --        OPTIONS = {animation = "attack14"},
             --    },
             --    {
             --        CLASS = "action.QSBDelayTime",
             --        OPTIONS = {delay_time = 81 / 24 },
             --    },
             --    {
             --        CLASS = "action.QSBPlayAnimation",
             --        OPTIONS = {animation = "attack14"},
             --    },
             --    {
             --        CLASS = "action.QSBDelayTime",
             --        OPTIONS = {delay_time = 81 / 24 },
             --    },
             --    {
             --        CLASS = "action.QSBPlayAnimation",
             --        OPTIONS = {animation = "attack14"},
             --    },
             --    {
             --        CLASS = "action.QSBDelayTime",
             --        OPTIONS = {delay_time = 81 / 24 },
             --    },
             --    {
             --        CLASS = "action.QSBPlayAnimation",
             --        OPTIONS = {animation = "attack14"},
             --    },
             --    {
             --        CLASS = "action.QSBDelayTime",
             --        OPTIONS = {delay_time = 48 / 24 },
             --    },
                {
 					CLASS = "composite.QSBParallel",
 					ARGS =
 					{
		                {
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
						},
		                {
		                    CLASS = "action.QSBAttackFinish",
		                },
	                },
                },
            },
        },
    },
}

return shijieboss_shuizhuxianijng

