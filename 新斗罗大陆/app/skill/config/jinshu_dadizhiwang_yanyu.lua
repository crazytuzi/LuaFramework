local jinshu_dadizhiwang_jinshu_yanyu = 
{
 	CLASS = "composite.QSBParallel",
 	ARGS = 
    {
    	{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
		----3次动作+震屏
    	{
		 	CLASS = "composite.QSBParallel",
		 	ARGS = 
		    {
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
				                    OPTIONS = {delay_time = 20 / 24 },
				                },
				                {
				                    CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 20, duration = 0.35, count = 1,},
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
				                    CLASS = "action.QSBPlayAnimation",
				                    OPTIONS = {animation = "attack13"},
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
						                    CLASS = "action.QSBShakeScreen",
						                    OPTIONS = {amplitude = 20, duration = 0.35, count = 1,},
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
		                    OPTIONS = {delay_time = 100 / 24 },
		                },
		                {
						 	CLASS = "composite.QSBParallel",
						 	ARGS = 
						    {
				                {
				                    CLASS = "action.QSBPlayAnimation",
				                    OPTIONS = {animation = "attack11"},
				                },
				                {
						            CLASS = "composite.QSBSequence",
						            ARGS = 
						            {
						            	{
						                    CLASS = "action.QSBDelayTime",
						                    OPTIONS = {delay_time = 22 / 24 },
						                },
						                {
						                    CLASS = "action.QSBShakeScreen",
						                    OPTIONS = {amplitude = 10, duration = 0.25, count = 7,},
						                },						              
						            },
					            },
				            },
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
		},
		-----聚拢生成
		{
    		CLASS = "composite.QSBSequence",
    		ARGS = 
    		{
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 9 / 24 },
			    },
			    {
				 	CLASS = "composite.QSBParallel",
				 	ARGS = 
			    	{
				        {
						 	CLASS = "composite.QSBParallel",
						 	ARGS = 
					    	{
					    	---6点
						        {
						            CLASS = "composite.QSBSequence",
						            ARGS = 
						            {
						                {
						                    CLASS = "action.QSBDelayTime",
						                    OPTIONS = {delay_time = 14 / 24 },
						                },
						                {
						 					CLASS = "composite.QSBParallel",
						 					ARGS =
						 					{
						 					---=预警圈
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_6a6"} ,
								                },
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_9a8"} ,
								                },
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_12a5"} ,
								                },
								            ---12,6点预警圈
								                {
						    						CLASS = "composite.QSBSequence",
						    						ARGS = 
						    						{
										                {
										                    CLASS = "action.QSBDelayTime",
										                    OPTIONS = {delay_time = 3 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_6a5"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_12a5"} ,
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
										                    OPTIONS = {delay_time = 6 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_6a4"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_12a4"} ,
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
										                    OPTIONS = {delay_time = 9 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_6a3"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_12a3"} ,
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
										                    OPTIONS = {delay_time = 12 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_6a2"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_12a2"} ,
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
										                    OPTIONS = {delay_time = 16 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_6a1"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_12a1"} ,
												                },
											                },
										                },
										            },
										        },
										        ----9,3点预警圈
										        {
						    						CLASS = "composite.QSBSequence",
						    						ARGS = 
						    						{
										                {
										                    CLASS = "action.QSBDelayTime",
										                    OPTIONS = {delay_time = 4 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_9a8"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_3a8"} ,
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
										                    OPTIONS = {delay_time = 6 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_9a7"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_3a7"} ,
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
										                    OPTIONS = {delay_time = 8 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_9a6"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_3a6"} ,
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
										                    OPTIONS = {delay_time = 10 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_9a5"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_3a5"} ,
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
										                    OPTIONS = {delay_time = 12 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_9a4"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_3a4"} ,
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
										                    OPTIONS = {delay_time = 14 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_9a3"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_3a3"} ,
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
										                    OPTIONS = {delay_time = 16 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_9a2"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_3a2"} ,
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
										                    OPTIONS = {delay_time = 18 / 24 },
								                		},
								                		{
										 					CLASS = "composite.QSBParallel",
										 					ARGS =
										 					{
											                    {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_9a1"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_3a1"} ,
												                },
											                },
										                },
										            },
										        },
										        ----中心预警+旋涡
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
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_a0"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_a0"} ,
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
----旋涡扩散
		{
    		CLASS = "composite.QSBSequence",
    		ARGS = 
    		{
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 73 / 24 },
			    },
				{
				 	CLASS = "composite.QSBParallel",
				 	ARGS = 
			    	{					  
			            {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_6a1"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_12a1"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_9a2"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_3a2"} ,
		                },
-- --6,12旋涡
					    {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
					            {
					                CLASS = "action.QSBDelayTime",
					                OPTIONS = {delay_time = 2 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_6a2"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_12a2"} ,
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
					                OPTIONS = {delay_time = 5 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_6a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_12a3"} ,
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
					                OPTIONS = {delay_time = 8 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_6a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_12a4"} ,
						                },
					                },
					            },
					        },
				        },
----9,3旋涡
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
					            {
					                CLASS = "action.QSBDelayTime",
					                OPTIONS = {delay_time = 2 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_9a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_3a3"} ,
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
					                OPTIONS = {delay_time = 5 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_9a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_3a4"} ,
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
					                OPTIONS = {delay_time = 8 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_9a5"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_3a5"} ,
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
					                OPTIONS = {delay_time = 11 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_9a6"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_3a6"} ,
						                },
					                },
					            },
					        },
					    },
				    },
			    },
		    },
	    },
---火柱
	    {
    		CLASS = "composite.QSBSequence",
    		ARGS = 
    		{
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 96 / 24 },
			    },
			    {
	                CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
	                OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_a0"} ,
	            },
            },
        },
	    {
    		CLASS = "composite.QSBSequence",
    		ARGS = 
    		{
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 100 / 24 },
			    },
			    {
				 	CLASS = "composite.QSBParallel",
				 	ARGS = 
			    	{					  
			            {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_6a1"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_12a1"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_9a2"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_3a2"} ,
		                },
----6,12点火柱
		                {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
					            {
					                CLASS = "action.QSBDelayTime",
					                OPTIONS = {delay_time = 8 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_6a2"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_12a2"} ,
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
					                OPTIONS = {delay_time = 16 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_6a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_12a3"} ,
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
					                OPTIONS = {delay_time = 24 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_6a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_12a4"} ,
						                },
					                },
					            },
					        },
				        },
------3,9点火柱
				        {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
					            {
					                CLASS = "action.QSBDelayTime",
					                OPTIONS = {delay_time = 6 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_9a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_3a3"} ,
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
					                OPTIONS = {delay_time = 12 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_9a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_3a4"} ,
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
					                OPTIONS = {delay_time = 18 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_9a5"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_3a5"} ,
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
					                OPTIONS = {delay_time = 24 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_9a6"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_3a6"} ,
						                },
					                },
					            },
					        },
					    },
			        },
			    },
		    },
	    },
----火牢
		{
    		CLASS = "composite.QSBSequence",
    		ARGS = 
    		{
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 143 / 24 },
			    },
			    {
	                CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
	                OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_a0"} ,
	            },
            },
        },
	    {
    		CLASS = "composite.QSBSequence",
    		ARGS = 
    		{
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 147 / 24 },
			    },
			    {
				 	CLASS = "composite.QSBParallel",
				 	ARGS = 
			    	{					  
			            {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_6a1"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_12a1"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_9a2"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_3a2"} ,
		                },
----6,12点
		                {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
					            {
					                CLASS = "action.QSBDelayTime",
					                OPTIONS = {delay_time = 8 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_6a2"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_12a2"} ,
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
					                OPTIONS = {delay_time = 16 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_6a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_12a3"} ,
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
					                OPTIONS = {delay_time = 24 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_6a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_12a4"} ,
						                },
					                },
					            },
					        },
					    },
------3,9点
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
					            {
					                CLASS = "action.QSBDelayTime",
					                OPTIONS = {delay_time = 6 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_9a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_3a3"} ,
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
					                OPTIONS = {delay_time = 12 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_9a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_3a4"} ,
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
					                OPTIONS = {delay_time = 18 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_9a5"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_3a5"} ,
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
					                OPTIONS = {delay_time = 24 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_9a6"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_3a6"} ,
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
}

return jinshu_dadizhiwang_jinshu_yanyu

