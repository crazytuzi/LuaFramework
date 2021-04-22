local boss_xiaobai_shuizhuzheng = 
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
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 92 / 24 },
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
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyua1"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhua1"} ,
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
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyua2"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhua2"} ,
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
						                    OPTIONS = {delay_time = 96 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyub1"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhub1"} ,
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
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyub2"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhub2"} ,
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
						                    OPTIONS = {delay_time = 177 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyuc1"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhuc1"} ,
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
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyuc2"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhuc2"} ,
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
						                    OPTIONS = {delay_time = 258 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyud1"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhud1"} ,
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
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyud2"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhud2"} ,
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
						                    OPTIONS = {delay_time = 339 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyua1a"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhua1a"} ,
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
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyua2a"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhua2a"} ,
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
						                    OPTIONS = {delay_time = 420 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyub1a"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhub1a"} ,
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
						                    OPTIONS = {delay_time = 435 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyub2a"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhub2a"} ,
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
						                    OPTIONS = {delay_time = 501 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyuc1a"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhuc1a"} ,
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
						                    OPTIONS = {delay_time = 516 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyuc2a"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhuc2a"} ,
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
						                    OPTIONS = {delay_time = 582 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyud1a"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhud1a"} ,
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
						                    OPTIONS = {delay_time = 597 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyud2a"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhud2a"} ,
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
						                    OPTIONS = {delay_time = 663 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyua1"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhua1"} ,
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
						                    OPTIONS = {delay_time = 678 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuiyua2"} ,
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
										                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "xiaobai_shuizhua2"} ,
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
            	-- {
             --        CLASS = "action.QSBPlayAnimation",
             --        OPTIONS = {animation = "attack13"},
             --    },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack14"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 81 / 24 },
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack14"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 81 / 24 },
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack14"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 81 / 24 },
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack14"},
                },
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
		                {
		                    CLASS = "action.QSBAttackFinish",
		                },
	                },
                },
            },
        },
    },
}

return boss_xiaobai_shuizhuzheng

