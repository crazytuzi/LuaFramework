-- 技能 BOSS唐晨蝙蝠入场
-- 技能ID 50821
-- 如果身上有zhaohuan_buff,就播入场动作正常入场,
-- 否则给自己上zhaohuan_debuff
--[[
	boss 唐晨蝙蝠 
	ID:3777 3678 3679 副本14-8
	psf 2018-7-4
]]--

local boss_tangchen_bianfu_ruchang ={
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
            CLASS = "action.QSBUncancellable",
        },
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attacker = true,reverse_result = false, status = "tc_zhaohuan"},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = 
			{
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
								},
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
													CLASS = "action.QSBPlayEffect",
													OPTIONS = {is_hit_effect = false},
												},
												{
													CLASS = "action.QSBActorFadeIn",
													OPTIONS = {duration = 0.15, revertable = true},
												},
											},
										},									
										-- {
								  --           CLASS = "action.QSBHeroicalLeap",
								  --           OPTIONS = {damage_once = -2250 ,move_time = 0.1 ,outside = true},
								  --       },
										{
											CLASS = "action.QSBTeleportToAbsolutePosition",
											OPTIONS = {pos = {x = 625,y = 350}, verify_flip = true},
										},
										{
											CLASS = "action.QSBForbidNormalAttack",
											OPTIONS = {forbid = false},
										},
									},
								},
								{
									CLASS = "action.QSBRemoveBuff", --去掉蝙蝠tc_zhaohuan标记
									OPTIONS = {buff_id = "boss_tangchen_bianfu_zhaohuan_buff"},
								},
								{
									CLASS = "action.QSBRemoveBuff", --去掉应该应该加给唐晨替身的BUFF
									OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_buff",remove_all_same_buff_id = true},
								},
							},
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
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
						},
						{
							CLASS = "action.QSBTriggerSkill",
							OPTIONS = {skill_id = 51008,wait_finish = true},--蝙蝠隐藏
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
			},
		},
    },
}

return boss_tangchen_bianfu_ruchang