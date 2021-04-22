-- 技能 BOSS唐晨死亡技- 召蝙蝠
-- 技能ID 50820
-- 给隐藏的蝙蝠加BUFF,使之被唤醒
--[[
	boss 唐晨 
	ID:3676 副本14-8
	psf 2018-7-4
]]--

local boss_tangchen_zhaohuanbianfu =  {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "boss_tangchen_bianfu_zhaohuan_buff", teammate = true},
		},
    },
}

return boss_tangchen_zhaohuanbianfu