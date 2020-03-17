--[[
	2015年10月13日, PM 11:20:19
	wangyanwei
	礼包提醒提醒manager
]]

_G.UIGiftsManager = {};

function UIGiftsManager:OpenStoneNotice(itemID)
	if itemID ~= GiftsConsts.GiftsBoxID then return end
	local byVip = VipController:IsSupremeVip();
	if byVip then return end
	local useNum = BagModel:GetItemCanUseNum(itemID);
	if useNum > 0 then return end
	UIUpgradeStoneNotice:Open();
end