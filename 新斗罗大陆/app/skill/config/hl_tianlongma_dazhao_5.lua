-- 技能 天龙马大招
-- 技能ID 35051~55
-- 雷霆之怒：召唤审判之雷，攻击单体目标，造成大量伤害，若其他目标身上有静电标记，则审判之雷会传导到目标身上，造成真实伤害（伤害=主目标伤害X%）
-- 并天龙马会吸收掉静电标记，强化自身获得攻击加成以及大招能量（每个标记伤害提升X%，回复15%大招能量）；
--[[
	hunling 天龙马
	ID:2008
	psf 2019-6-14
]]--

local hl_tianlongma_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 68},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },

            },
        },
        {               --竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 68},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },

            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {--[[effect_id = "tianlongma_attack11_1",]] is_hit_effect = false, haste = true},
                },
            },
        },
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 104},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 73},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
							CLASS = "action.QSBHitTarget",
						},
						{
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = { is_hit_effect = true},
                        },
						{
							CLASS = "action.QSBTriggerSkill",
							OPTIONS = {skill_id = 35060, target_type = "skill_target", wait_finish = true},
						},
						{
							CLASS = "action.QSBAttackByBuffNum",
							OPTIONS = { buff_id = "hl_tianlongma_pugong_debuff",num_pre_stack_count = 1,attackMaxNum = 4, trigger_skill_id = 35075,target_type = "enemy" }
						},
                    },
                },
				
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "hl_tianlongma_pugong_debuff",enemy = true},
				},
            },
        },
    },
}

return hl_tianlongma_dazhao