-- 技能 BOSS唐晨大招连招
-- 技能ID 50819
-- 闪现  放死亡技 自杀
--[[
	boss 唐晨 
	ID:3676 副本14-8
	psf 2018-7-4
]]--

local boss_tangchen_zibao =  {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "action.QSBUncancellable",
        },
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_shanghai"},
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "boss_tangchen_xueji_full_buff"},
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
							OPTIONS = {pos={x = 625,y = 350},verify_flip = true},
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
				-- 自爆
				{
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
									OPTIONS = {no_stand = true},
									ARGS = {
										{
											CLASS = "action.QSBHitTarget",
										},
									},
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "mianyi_suoyou_shanghai"},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 40},
								},
								{
									CLASS = "action.QSBTriggerSkill",
									OPTIONS = {skill_id = 50820,wait_finish = true},--召唤蝙蝠
								},
								{
									CLASS = "action.QSBPlayMonsterString",
									OPTIONS = {monster_string_id = 1031},--弹tips
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 10},
								},
								{
									CLASS = "action.QSBImmuneCharge",
									OPTIONS = {enter = true},
								},
								{
									CLASS = "action.QSBActorFadeOut",
									OPTIONS = {duration = 0.2},
								},
								{
									CLASS = "action.QSBSuicide",
								},
								{
									CLASS = "action.QSBAttackFinish",
								},
							},
						},
					},
				},
			},
		},
    },
}

return boss_tangchen_zibao