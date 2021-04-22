-- 技能 马红俊普攻回怒
-- 技能ID 190181
-- 自己回怒,去掉一层BUFF
--[[
	hero 马红俊
	ID:1016 
	psf 2018-11-20
]]--

local mahongjun_zidong1_plus_trigger = {
     CLASS = "composite.QSBSequence",
     ARGS = {
		{
			CLASS = "action.QSBChangeRage",
			OPTIONS = {rage_value = 30},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "mahongjun_zidong1_plus_buff"},
		},
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return mahongjun_zidong1_plus_trigger