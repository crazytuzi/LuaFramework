-- 技能 BOSS唐晨大招连招
-- 技能ID 50819
-- 闪现  放死亡技 自杀
--[[
	boss 唐晨 
	ID:3676 副本14-8
	psf 2018-7-4
]]--

local zudui_boss_tangchen_zibao =  {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "boss_tangchen_bianshen", is_target = false},
        },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {buff_id = "dugubo_zhenji_die", remove_all_same_buff_id = true},
        -- },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return zudui_boss_tangchen_zibao