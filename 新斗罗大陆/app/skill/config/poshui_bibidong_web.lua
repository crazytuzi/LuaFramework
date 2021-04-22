-- 技能 BOSS比比东 蛛网
-- 技能ID 50832
--[[
	boss 比比东 
	ID:3681 副本14-16
	psf 2018-7-5
]]--

local boss_bibidong_web = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBPlayAnimation",
			ARGS = 
			{
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false},
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
					OPTIONS = {delay_time = 1.4},
				},
				{
					CLASS = "action.QSBTrap",
					OPTIONS = {
						trapId = "poshui_bibidong_web_trap",
						args = {{delay_time = 0 , relative_pos = { x = 0, y = 0}}},
					},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.4},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return boss_bibidong_web