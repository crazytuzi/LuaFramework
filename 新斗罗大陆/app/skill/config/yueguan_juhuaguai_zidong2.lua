-- 技能 菊花怪 菊花残
-- ID 172
-- 菊花怪给它分株出来的GHOST加buff
--[[
	hero 月关
	ID:1018
	psf 2018-7-24
]]--
local yueguan_juhuaguai_zidong2 =  {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
			CLASS = "action.QSBGhostApplyBuff",
			OPTIONS = {buff_id = "yueguan_zidong2_buff;y",no_cancel = true},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return yueguan_juhuaguai_zidong2

