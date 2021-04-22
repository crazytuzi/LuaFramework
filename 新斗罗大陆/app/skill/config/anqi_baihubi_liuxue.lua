	local anqi_xiehuoshuanglian_trigger_1 ={
	    CLASS = "composite.QSBSequence",
        OPTIONS = {forward_mode = true},
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
                                        OPTIONS = {damage_scale = 1},
                                    },
                                    {
                                        CLASS = "action.QSBHitTarget",
                                        OPTIONS = {damage_scale = 1.5},
                                    },
                                    {
                                        CLASS = "action.QSBHitTarget",
                                        OPTIONS = {damage_scale = 2},
                                    },
                                    {
                                        CLASS = "action.QSBHitTarget",
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
                                        OPTIONS = {damage_scale = 8},
                                    },
                                    {
                                        CLASS = "action.QSBHitTarget",
                                        OPTIONS = {damage_scale = 10},
                                    },
                                    {
                                        CLASS = "action.QSBHitTarget",
                                        OPTIONS = {damage_scale = 12},
                                    },
                                    {
                                        CLASS = "action.QSBHitTarget",
                                    },
                                },
                            },
                        },
                    },
                },
            },
	    	{
	            CLASS = "action.QSBAttackFinish"
	        },
	    },
	}

return anqi_xiehuoshuanglian_trigger_1