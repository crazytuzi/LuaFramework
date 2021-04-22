-- 技能 宁荣荣 护盾触发治疗
-- 技能ID 306
-- 护盾消失时触发此技能, 治疗一下
--[[
	hero 宁荣荣
	ID:1027 
	psf 2018-9-10
]]--


local ningrongrong_beidong2_trigger = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = true},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
            },
        },
		{
            CLASS = "composite.QSBParallel",
            ARGS = {
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "fumo_pf_ningrongrong01_buff1"}
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "fumo_pf_ningrongrong01_buff2"}
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "fumo_pf_ningrongrong01_buff3"}
				},
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return ningrongrong_beidong2_trigger