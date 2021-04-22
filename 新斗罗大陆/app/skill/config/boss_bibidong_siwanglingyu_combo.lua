-- 技能 BOSS比比东 死亡领域连招
-- 技能ID 50816
-- 闪现  蛛网
--[[
	boss 比比东 
	ID:3681 副本14-16
	psf 2018-7-5
]]--

local boss_bibidong_siwanglingyu_combo = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBPlaySound"
		},
		{
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = true, revertable = true},
        },	
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},	
		{
			CLASS = "composite.QSBSequence",
			ARGS = {		
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBManualMode",
							OPTIONS = {enter = true, revertable = true},
						},
						{
							CLASS = "action.QSBActorStand",
						},
						{
							CLASS = "action.QSBPlayAnimation",
						},
						{
							CLASS = "action.QSBActorFadeOut",
							OPTIONS = {duration = 0.15, revertable = true},
						},
					},
				},
				{
				  CLASS = "action.QSBTeleportToTargetBehind",
				  OPTIONS = {verify_flip = true},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBPlayAnimation",
						},
						{
							CLASS = "action.QSBActorFadeIn",
							OPTIONS = {duration = 0.15, revertable = true},
						},
					},
				},
				{
					CLASS = "action.QSBManualMode",
					OPTIONS = {exit = true},
				},
				{
					CLASS = "action.QSBTriggerSkill",
					OPTIONS = { skill_id = 50832,wait_finish = true},
				},
				{
					CLASS = "action.QSBLockTarget",
					OPTIONS = {is_lock_target = false},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				},	
				{
					CLASS = "action.QSBAttackFinish"
				},
			},
		},
	},
}

return boss_bibidong_siwanglingyu_combo