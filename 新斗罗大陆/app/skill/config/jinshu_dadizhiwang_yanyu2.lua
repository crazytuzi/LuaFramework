local boss_niumang_langhuawu1 = 
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
						                    OPTIONS = {amplitude = 10, duration = 0.25, count = 8,},
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
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_2a9"} ,
								                },
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_4a9"} ,
								                },
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_7a9"} ,
								                },
								                {
								                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
								                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_11a9"} ,
								                },
----2,4,7,11点预警圈
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
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_2a8"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_4a8"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_7a8"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_11a8"} ,
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
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_2a7"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_4a7"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_7a7"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_11a7"} ,
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
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_2a6"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_4a6"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_7a6"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_11a6"} ,
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
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_2a5"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_4a5"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_7a5"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_11a5"} ,
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
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_2a4"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_4a4"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_7a4"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_11a4"} ,
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
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_2a3"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_4a3"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_7a3"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_11a3"} ,
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
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_2a2"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_4a2"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_7a2"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_11a2"} ,
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
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_2a1"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_4a1"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_7a1"} ,
												                },
												                {
												                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
												                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_julong_11a1"} ,
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
--旋涡扩散
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
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_2a2"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_4a2"} ,
		                },		
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_7a2"} ,
		                },		
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_11a2"} ,
		                },						    
-- ----9,3旋涡
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_2a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_4a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_7a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_11a3"} ,
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_2a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_4a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_7a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_11a4"} ,
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_2a5"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_4a5"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_7a5"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_11a5"} ,
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_2a6"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_4a6"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_7a6"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_11a6"} ,
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
					                OPTIONS = {delay_time = 13 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_2a7"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_4a7"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_7a7"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_11a7"} ,
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
					                OPTIONS = {delay_time = 15 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_2a8"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_4a8"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_7a8"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_11a8"} ,
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
					                OPTIONS = {delay_time = 17 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_2a9"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_4a9"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_7a9"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_xuanwo_11a9"} ,
						                },
					                },
					            },
					        },
					    },					  
				    },
			    },
		    },
	    },
-- ---火柱
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
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_2a2"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_4a2"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_7a2"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_11a2"} ,
		                },
----2,4,7,11点火柱
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_2a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_4a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_7a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_11a3"} ,
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_2a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_4a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_7a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_11a4"} ,
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_2a5"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_4a5"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_7a5"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_11a5"} ,
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_2a6"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_4a6"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_7a6"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_11a6"} ,
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_2a7"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_4a7"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_7a7"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_11a7"} ,
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_2a8"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_4a8"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_7a8"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_11a8"} ,
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
					                OPTIONS = {delay_time = 25 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_2a9"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_4a9"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_7a9"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huozhu_11a9"} ,
						                },
					                },
					            },
					        },
					    },
			        },
			    },
		    },
	    },
-- ----火牢
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
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_2a2"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_4a2"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_7a2"} ,
		                },
		                {
		                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
		                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_11a2"} ,
		                },
----6,12点
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_2a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_4a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_7a3"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_11a3"} ,
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_2a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_4a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_7a4"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_11a4"} ,
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_2a5"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_4a5"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_7a5"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_11a5"} ,
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
					                OPTIONS = {delay_time = 16 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_2a6"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_4a6"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_7a6"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_11a6"} ,
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_2a7"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_4a7"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_7a7"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_11a7"} ,
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
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_2a8"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_4a8"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_7a8"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_11a8"} ,
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
					                OPTIONS = {delay_time = 28 / 24 },
					    		},
					    		{
									CLASS = "composite.QSBParallel",
									ARGS =
									{
					                    {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_2a9"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_4a9"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_7a9"} ,
						                },
						                {
						                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
						                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "jinshu_yanyu_huolao_11a9"} ,
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

return boss_niumang_langhuawu1
