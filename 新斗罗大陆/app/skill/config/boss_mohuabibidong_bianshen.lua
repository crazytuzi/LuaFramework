-- 技能 BOSS比比东 变身
-- 技能ID 50833
-- 变回来, 如果血量少于15%  用50834
--[[
	boss 比比东 
	ID:3681 副本14-16
	psf 2018-7-5
]]--

local boss_mohuabibidong_bianshen = 
{
	CLASS = "composite.QSBSequence",
	ARGS = 
	{		
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "self:hp_percent<0.18","self:apply_buff:boss_bibidong_bianshen_zisha_buff","under_status"},
			}
		},
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attacker = true,reverse_result = true, status = "zisha_mark"},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = 
			{
				----没有自杀标记时
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						
						{
							CLASS = "action.QSBPlaySound"
						},
						{
							CLASS = "action.QSBPlayAnimation",
							OPTIONS = { animation = "attack11" }
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 2.2},
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "boss_bibidong_jianta_buff"},
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "boss_mohuabibidong_bianshen_3682_buff",no_cancel = true},
								},
								{
									CLASS = "action.QSBAttackFinish",
								},
							},
						},
					},
				},
				------有自杀标记时
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
									CLASS = "action.QSBHitTarget",
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
			},
		},
		
	},
}

return boss_mohuabibidong_bianshen