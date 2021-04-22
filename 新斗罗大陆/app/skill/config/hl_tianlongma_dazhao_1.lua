-- 技能 天龙马大招
-- 技能ID 35051~55
-- 召唤天雷对单体目标造成攻击235%的魔法伤害，并传导闪电攻击所有带有“静电”标记的敌方，造成攻击150%的无视魔防的魔法伤害。
-- 天龙马还将吸收所有敌方目标的“静电”标记，每个标记回复15%能量并提升5%攻击18秒。
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
							OPTIONS = {skill_id = 35056, target_type = "skill_target", wait_finish = true},
						},
						{
							CLASS = "action.QSBAttackByBuffNum",
							OPTIONS = { buff_id = "hl_tianlongma_pugong_debuff",num_pre_stack_count = 1,attackMaxNum = 4, trigger_skill_id = 35071,target_type = "enemy" }
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