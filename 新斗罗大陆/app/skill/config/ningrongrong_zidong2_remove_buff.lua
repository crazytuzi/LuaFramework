-- 技能 宁荣荣 附魔受击判定
-- 技能ID 180111
-- 中了附魔大的人,受击时触发, 若攻击者为BOSS, 释放技能180114
--[[
	hero 宁荣荣
	ID:1027 
	psf 2018-9-10
]]--


local ningrongrong_fumo1_trigger = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "ningrongrong_zidong2_buff2"}
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return ningrongrong_fumo1_trigger