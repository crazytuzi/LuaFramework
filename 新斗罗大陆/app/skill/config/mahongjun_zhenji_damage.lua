-- 技能 火种爆炸
-- ID 190179
-- 自爆
--[[
	马红俊火种
	ID:40006
	psf 2018-11-20
]]--
local mahongjun_zhenji_damage = {
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "composite.QSBSequence",
			ARGS = { 
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 6},
				},
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "dead",no_stand = true},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 6.3},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "mahongjun_zhenji_damage_buff"},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
				{
					CLASS = "action.QSBArgsIsUnderStatus",
					OPTIONS = {is_attacker = true,status = "mahongjun_zhenji"},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {enemy = true, buff_id = "mahongjun_zhenji_plus_debuff"},
						},
					},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "mahongjun_zhenji_damage_buff"},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.38},
				},
				{
					CLASS = "action.QSBSuicide",
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
			},
		},
	},
}




return mahongjun_zhenji_damage