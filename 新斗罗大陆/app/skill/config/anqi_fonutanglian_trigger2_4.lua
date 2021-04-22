-- 技能 暗器 佛怒唐莲爆发
-- 技能ID 40419~40423
-- 以敌方为中心释放AOE.
--[[
	暗器 佛怒唐莲
	ID:1525
	psf 2019-8-12
]]--

local anqi_fonutanglian_trigger2 = 
{
	 CLASS = "composite.QSBSequence",
	 ARGS = 
	 {
		{
			CLASS = "action.QSBArgsSelectTarget",
			OPTIONS = {under_status = "fonutanglian_debuff"},
		},
		{
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attackee = true, status = "fonutanglian_debuff", reverse_result = true},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
				{
					CLASS = "action.QSBArgsSelectTarget",
					OPTIONS = {min_distance = true,change_all_node_target = true},
				},
            },
        },
		{
			CLASS = "action.QSBDecreaseHpByAbsorb",
			OPTIONS = {buff_id = "anqi_fonutanglian_buff_4", coefficient = 0.575},
		},
		--为解决连续释放问题,将BUFF叠加设为2层,当2层时会先删除老的BUFF
		{
			CLASS = "action.QSBRemoveBuff",	
			OPTIONS = {buff_id = "anqi_fonutanglian_buff_4"} 
		},
		{
			CLASS = "action.QSBRemoveBuff",	
			OPTIONS = {buff_id = "anqi_fonutanglian_trigger_buff_4"} 
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_fonutanglian_trigger2

