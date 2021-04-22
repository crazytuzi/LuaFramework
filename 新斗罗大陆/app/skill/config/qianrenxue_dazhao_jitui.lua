-- 技能 千仞雪大招击退
-- 技能ID 289
-- 击退
--[[
	hero 千仞雪
	ID:1027 
	psf 2018-4-27
]]--

local qianrenxue_dazhao_jitui = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
			CLASS = "action.QSBPlayAnimation",
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 16},
				},
				{
					CLASS = "action.QSBDragActor",
					OPTIONS = {pos_type = "self" , pos = {x = 300,y = 0} , duration = 0.4, flip_with_actor = true },
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 34},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
    },
}

return qianrenxue_dazhao_jitui