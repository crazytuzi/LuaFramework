-- 技能 宁荣荣 附魔受击判定
-- 技能ID 180111
-- 中了附魔大的人,受击时触发, 若攻击者为BOSS, 释放技能180114
--[[
	hero 宁荣荣
	ID:1027 
	psf 2018-9-10
]]--


local ayin_zhenji_zhiliao = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "ayin_zhenji_huifu_buff"}
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return ayin_zhenji_zhiliao