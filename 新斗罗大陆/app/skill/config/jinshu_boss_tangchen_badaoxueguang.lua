-- 技能 BOSS唐晨霸道血光
-- 技能ID 50816
-- 砍一刀
--[[
	boss 唐晨 
	ID:3676 副本14-8
	psf 2018-7-4
]]--

local boss_tangchen_badaoxueguang = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
		{
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 1.8},
				},
				{
					CLASS = "action.QSBDragActor",
					OPTIONS = {pos_type = "self" , pos = {x = 275,y = 0} , duration = 0.2, flip_with_actor = true },
				},
			},
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS =
        	{
        		{
					CLASS = "action.QSBPlayAnimation",
					ARGS = 
					{
						{
							CLASS = "action.QSBHitTarget",
						},
					},
				},
        		{
            		CLASS = "action.QSBAttackFinish",
    			},
    		},	
    	},
	},   
}

return boss_tangchen_badaoxueguang