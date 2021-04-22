--斗罗SKILL 终极技能
--宗门武魂争霸
--id 51405
--通用 主体/上下头
--[[
持续施法,召唤头61034到场上
]]--
--创建人：庞圣峰
--创建时间：2019-1-2

local zmwh_boss_qiwuhun_dazhao = 
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
											OPTIONS = {animation = "attack11"},
										},
										{
											CLASS = "action.QSBAttackFinish"
										},
									},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										-- {
											-- CLASS = "action.QSBArgsPosition",
											-- OPTIONS = {x=300,y=200},
										-- },
										-- {
											-- CLASS = "action.QSBDelayTime",
											-- OPTIONS = {delay_frame = 10, pass_key = {"pos"}},
										-- },
										{
											CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
											OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "zmwh_boss_dazhao_hongquan", pos = {x=350,y=200}--[[pass_key = {"pos"}]]} ,
										},
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 30--[[pass_key = {"pos"}]]},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 61043 , life_span = 10,number = 1, appear_skill = 51378 , enablehp = true,
											hp_percent = 0.0008 , no_fog = false,is_attacked_ghost = true, absolute_position = {x=300,y=200} --[[args_translate = {pos = "absolute_pos"}]]},
										},
									},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 2},
										},
										-- {
											-- CLASS = "action.QSBArgsPosition",
											-- OPTIONS = {x=600,y=450},
										-- },
										-- {
											-- CLASS = "action.QSBDelayTime",
											-- OPTIONS = {delay_frame = 10, pass_key = {"pos"}},
										-- },
										{
											CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
											OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "zmwh_boss_dazhao_hongquan", pos = {x=650,y=450}--[[pass_key = {"pos"}]]} ,
										},
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 30--[[pass_key = {"pos"}]]},
										},
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 61043 , life_span = 10,number = 1, appear_skill = 51378 , enablehp = true,
											hp_percent = 0.0008 , no_fog = false,is_attacked_ghost = true,absolute_position = {x=600,y=450} --[[args_translate = {pos = "absolute_pos"}]]},
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
									OPTIONS = {no_stand = true,animation = "attack11_1"},
								},
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {no_stand = true,animation = "attack11_2", is_loop = true},
								},
								{
									CLASS = "action.QSBActorKeepAnimation",
									OPTIONS = {is_keep_animation = true}
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 8},
								},
								{
									CLASS = "action.QSBActorKeepAnimation",
									OPTIONS = {is_keep_animation = false}
								},
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {no_stand = true,animation = "attack11_3"},
								},
								{
									CLASS = "action.QSBActorStand",
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

return zmwh_boss_qiwuhun_dazhao