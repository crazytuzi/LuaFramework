--斗罗AI 唐晨BOSS入场恐惧AI
--副本14-8
--[[
使玩家魂师恐惧,被替换成该AI
]]--
--创建人：庞圣峰
--创建时间：2018-7-11


local npc_boss_tangchen_ruchang_debuff_scared = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
    	{
    		CLASS = "composite.QAISequence",
    		ARGS = 
    		{
		    	{
		    		CLASS = "action.QAIReturnToAI",
					OPTIONS = {hp_above_for_melee = 0.0, wait_time_for_melee = 0.0},
		    	},
				{
					CLASS = "action.QAIStopMoving",
				},
				{
					CLASS = "composite.QAISelector",
					ARGS = 
					{
						{
							CLASS = "action.QAIIsRole",
							OPTIONS = {role = {"health"}}
						},
						{
							CLASS = "action.QAIAttackByStatus",
							OPTIONS = {is_team = false,status = "boss_special_mark"},
						},
					},
				},
		    	{
		    		CLASS = "action.QAIResult",
					OPTIONS = {result = false},
		    	},
    		},
    	},
    	{
    		CLASS = "composite.QAISelector",
    		ARGS = 
    		{
    			{
    				CLASS = "composite.QAISequence",
    				ARGS = 
    				{
	    				{
	    					CLASS = "action.QAITimeSpan",
	    					OPTIONS = {from = 0, to = 2.5, relative = true},
	    				},
	    				{
	    					CLASS = "action.QAIMoveAwayFromTarget",
	    					OPTIONS = {distance = 5},
	    				},
	    				{
	    					CLASS = "action.QAISelector",
	    					ARGS = 
	    					{
						    	{
						    		CLASS = "composite.QAISequence",
									ARGS = 
									{
										{
											CLASS = "action.QAITimer",
											OPTIONS = {interval = 999999, first_interval = 0},
										},
								    	{
								    		CLASS = "action.QAIStopMoving",
								    	},
									},
						    	},
						    	{
						    		CLASS = "action.QAIResult",
						    		OPTIONS = {result = true},
						    	},
	    					},
	    				},
    				},
    			},
		    	{
		    		CLASS = "composite.QAISelector",
		    		OPTIONS = {alternatively = true},
		    		ARGS = 
		    		{
				    	{
					    	CLASS = "composite.QAISequence",
					    	ARGS = 
					    	{
				            	{
					            	CLASS = "action.QAITimeSpan",
					            	OPTIONS = {from = 0.5, to = {1.2, 1.6}, relative = true},
				            	},
				            	{
				            		CLASS = "action.QAIMoveLineStrip",
				      				OPTIONS = {target_list = {{x = -1, y = 2}}, relative = true},
				            	},
					    	},
				    	},
				    	{
					    	CLASS = "composite.QAISequence",
					    	ARGS = 
					    	{
				            	{
					            	CLASS = "action.QAITimeSpan",
					            	OPTIONS = {from = 0.5, to = {1.2, 1.6}, relative = true},
				            	},
				            	{
				            		CLASS = "action.QAIMoveLineStrip",
				      				OPTIONS = {target_list = {{x = 1, y = -2}}, relative = true},
				            	},
					    	},
				    	},
		    		},
		    	},
    		},
    	},
    },
}

return npc_boss_tangchen_ruchang_debuff_scared