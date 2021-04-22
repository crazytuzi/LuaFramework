-- 技能 宁荣荣 附魔判断职业
-- 技能ID 180113
-- target(攻击者)是BOSS就触发技能
--[[
	hero 宁荣荣
	ID:1027 
	psf 2018-9-10
]]--


local ningrongrong_fumo3_trigger = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "target:role==boss_or_elite_boss","target:trigger_skill_as_target:280116","under_status"},
			}
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return ningrongrong_fumo3_trigger