-- 技能 胭脂软筋蟒大招触发技
-- 技能ID 35007
-- 判断是否中毒上不同魅惑DEBUFF
--[[
	hunling 胭脂软筋蟒
	ID:2002
	psf 2019-6-10
]]--

local hl_yanzrjm_dazhao_trigger = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "self:fear","self:apply_buff:hl_yanzrjm_dazhao_trigger_debuff2;y","under_status"},
			   { "self:fear","self:apply_buff:hl_yanzrjm_dazhao_trigger_debuff1;y","not_under_status"},
			},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "hl_yanzrjm_dazhao_debuff"},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return hl_yanzrjm_dazhao_trigger