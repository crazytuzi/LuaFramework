
local anqi_tishenkuilei_chaofeng = {
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
	    {
		    CLASS = "composite.QSBSequence",
		    OPTIONS = {forward_mode = true},
		    ARGS = 
		    {
		        {
		            CLASS = "action.QSBManualMode",
		            OPTIONS = {enter = true, revertable = true},
		        },
		        {
		            CLASS = "action.QSBFlyAppear",
		            OPTIONS = {fly_animation = "attack21"},
		        },
		        {
		            CLASS = "action.QSBManualMode",
		            OPTIONS = {exit = true},
		        },
		    },
		},
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
		{
		    CLASS = "composite.QSBSequence",
		    ARGS = 
		    {
		    	{
		            CLASS = "action.QSBDelayTime",
		            OPTIONS = {delay_time = 1.2},
				},
				{
				    CLASS = "composite.QSBParallel",
				    ARGS = 
				    {
				        {
				            CLASS = "action.QSBPlayAnimation",
				            OPTIONS = {animation = "attack11", is_loop = true},
				        },
				        {
				            CLASS = "action.QSBActorKeepAnimation",
				            OPTIONS = {is_keep_animation = true},
				        },
				        {
				            CLASS = "action.QSBHitTimer",
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
					CLASS = "action.QSBOnMarked",
					OPTIONS = {on = true},
				},
				{
		            CLASS = "action.QSBDelayTime",
		            OPTIONS = {delay_time = 1},
				},
				{
					CLASS = "action.QSBOnMarked",
					OPTIONS = {on = true},
				},
				{
		            CLASS = "action.QSBDelayTime",
		            OPTIONS = {delay_time = 1},
				},
				{
					CLASS = "action.QSBOnMarked",
					OPTIONS = {on = true},
				},
				{
		            CLASS = "action.QSBDelayTime",
		            OPTIONS = {delay_time = 1},
				},
				{
					CLASS = "action.QSBOnMarked",
					OPTIONS = {on = true},
				},
				{
		            CLASS = "action.QSBDelayTime",
		            OPTIONS = {delay_time = 1},
				},
				{
					CLASS = "action.QSBOnMarked",
					OPTIONS = {on = true},
				},
				{
		            CLASS = "action.QSBDelayTime",
		            OPTIONS = {delay_time = 1},
				},
				{
					CLASS = "action.QSBOnMarked",
					OPTIONS = {on = true},
				},
				{
		            CLASS = "action.QSBDelayTime",
		            OPTIONS = {delay_time = 1},
				},
			},
		},
    },
}
return anqi_tishenkuilei_chaofeng

