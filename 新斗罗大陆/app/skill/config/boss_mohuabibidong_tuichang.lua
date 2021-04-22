-- 技能 BOSS比比东 离场死掉[暂弃]
-- 技能ID 50834
-- 离场死掉
--[[
	boss 比比东 
	ID:3681 副本14-16
	psf 2018-7-5
]]--

local boss_mohuabibidong_tuichang = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = { animation = "attack16" }
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 2.4},
				},
				{
					CLASS = "action.QSBSuicide",
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "boss_bibidong_jianta_buff"},
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return boss_mohuabibidong_tuichang