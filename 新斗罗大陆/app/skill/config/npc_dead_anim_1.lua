-- 技能 死亡动作 dead_1 吹飞
--[[
	技能ID：
	psf 2018-3-8
]]--
local npc_dead_anim_1 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {   
            CLASS = "action.QSBDeadPlayAnimation",
			OPTIONS = {animation = "dead_1"}
		},
    },
}

return npc_dead_anim_1