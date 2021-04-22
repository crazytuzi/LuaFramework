-- 技能 海神侍女治疗
-- ID 50904
-- 治疗自己三下
--[[
	海神侍女
	ID:3711 3712
	psf 2018-7-26
]]--


local npc_haishenshinv_zhiliao = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
		{
            CLASS = "composite.QSBSequence",
             ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 26},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 4},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 4},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
            },
        },
    },
}

return npc_haishenshinv_zhiliao