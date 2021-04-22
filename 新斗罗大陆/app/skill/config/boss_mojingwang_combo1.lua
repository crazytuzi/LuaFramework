-- 技能 魔鲸王连招1
-- 技能ID 50879
-- 由下到上激光
--[[
	boss 魔鲸王
	ID:3699 3700
	psf 2018-7-19
]]--

local boss_mojingwang_combo1 =                                       
{
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				---闪现到下面
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBActorStand",
								},
								{
									CLASS = "action.QSBActorFadeOut",
									OPTIONS = {duration = 0.15, revertable = true},
								},
							},
						},
						{
							CLASS = "action.QSBTeleportToAbsolutePosition",
							OPTIONS = {pos={x = 1200,y = 200},verify_flip = true},
						},
						{
							CLASS = "action.QSBRoledirection",
							OPTIONS = {direction = "left"},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true},
								},
								{
									CLASS = "action.QSBActorFadeIn",
									OPTIONS = {duration = 0.15, revertable = true},
								},
							},
						},
					},
				},	
				-- 放激光
				{
					CLASS = "action.QSBTriggerSkill",
					OPTIONS = {skill_id = 50878, wait_finish = true},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				---闪现到中间
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBActorStand",
								},
								{
									CLASS = "action.QSBActorFadeOut",
									OPTIONS = {duration = 0.15, revertable = true},
								},
							},
						},
						{
							CLASS = "action.QSBTeleportToAbsolutePosition",
							OPTIONS = {pos={x = 1200,y = 325},verify_flip = true},
						},
						{
							CLASS = "action.QSBRoledirection",
							OPTIONS = {direction = "left"},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true},
								},
								{
									CLASS = "action.QSBActorFadeIn",
									OPTIONS = {duration = 0.15, revertable = true},
								},
							},
						},
					},
				},	
				-- 放激光
				{
					CLASS = "action.QSBTriggerSkill",
					OPTIONS = {skill_id = 50878, wait_finish = true},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				---闪现到上间
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBActorStand",
								},
								{
									CLASS = "action.QSBActorFadeOut",
									OPTIONS = {duration = 0.15, revertable = true},
								},
							},
						},
						{
							CLASS = "action.QSBTeleportToAbsolutePosition",
							OPTIONS = {pos={x = 1200,y = 450},verify_flip = true},
						},
						{
							CLASS = "action.QSBRoledirection",
							OPTIONS = {direction = "left"},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true},
								},
								{
									CLASS = "action.QSBActorFadeIn",
									OPTIONS = {duration = 0.15, revertable = true},
								},
							},
						},
					},
				},	
				-- 放激光
				{
					CLASS = "action.QSBTriggerSkill",
					OPTIONS = {skill_id = 50878, wait_finish = true},
				},
			},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "boss_mojingwang_qianghua_buff"},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
	},
}

return boss_mojingwang_combo1