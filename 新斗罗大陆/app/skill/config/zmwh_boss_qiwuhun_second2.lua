--斗罗SKILL 魂力追踪
--宗门武魂争霸
--id 51342
--通用 主体/上下头
--[[
全身抱一抱,召唤Ghost61030
]]--
--创建人：庞圣峰
--创建时间：2019-1-2

local zmwh_boss_qiwuhun_third2 = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
    {

        {
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBArgsIsUnderStatus",
					OPTIONS = {is_attacker = true,status = "zmwh_boss"},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						----主体
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBPlayAnimation",
											-- OPTIONS = {animation = "attack08"},
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
											OPTIONS = {delay_frame = 100},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 61030 , life_span = 12,number = 1, appear_skill = 51368 , enablehp = true,
											hp_percent = 0.0000006 , absolute_pos = {x = 400, y = 300}, no_fog = false,is_attacked_ghost = true},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 61030 , life_span = 12,number = 1, appear_skill = 51368 , enablehp = true,
											hp_percent = 0.0000006 , absolute_pos = {x = 300, y = 150}, no_fog = false,is_attacked_ghost = true},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 61030 , life_span = 12,number = 1, appear_skill = 51368 , enablehp = true,
											hp_percent = 0.0000006 , absolute_pos = {x = 300, y = 450}, no_fog = false,is_attacked_ghost = true},
										},
										{
											CLASS = "action.QSBApplyBuff",
											OPTIONS = {buff_id = "zmwh_boss_qiwuhun_second2_buff"},
										}, 
									},
								},
							},
						},
						------
						----上下头
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBPlayAnimation",
									-- OPTIONS = {animation = "attack07"},
								},
								{
									CLASS = "action.QSBAttackFinish"
								},
							},
						},
						------
					},
				},
			},
		},
    },
}

return zmwh_boss_qiwuhun_third2