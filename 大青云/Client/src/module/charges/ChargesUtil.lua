--[[
	2015年12月25日16:48:22
	wangyanwei
]]

_G.ChargesUtil = {};

function ChargesUtil:OnWarningPass(funcType)
	if funcType == ChargesConsts.MagicWeapon then --神兵
		local magicWeaponLevel = MagicWeaponModel:GetLevel();
		if not magicWeaponLevel or magicWeaponLevel == 0 then return false end
		local magicWeaponCfg = t_shenbing[magicWeaponLevel];
		if not magicWeaponCfg then return false end
		if magicWeaponCfg.is_wishclear and MagicWeaponModel:GetBlessing() ~= 0 then
			return true
		end
		return false
	elseif funcType == ChargesConsts.Spirits then
		local spiritsLevel = SpiritsModel:GetLevel();
		if not spiritsLevel or spiritsLevel == 0 then return false end
		local wuhunId = SpiritsModel.currentWuhun.wuhunId;
		local wuhunWish = SpiritsModel.currentWuhun.wuhunWish
		if not wuhunId or wuhunId == 0 then return false end
		if not wuhunWish then return false end
		local magicWeaponCfg = t_wuhun[wuhunId]
		if not magicWeaponCfg then return false end
		if magicWeaponCfg.is_wishclear and wuhunWish ~= 0 then
			return true
		end
		return false
	end
	return false
end