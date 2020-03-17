--[[
道具推荐使用
需求：在主界面右下角弹出提醒UI，提醒玩家当前有礼包可以使用，点击后直接使用
lizhuangzhuang
2015年5月5日16:33:25
]]

ItemNumCScriptCfg:Add(
{
	name = "itemguideuse",
	execute = function(bag,pos,tid)
		local bagVO = BagModel:GetBag(bag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(pos);
		if not item then return; end
		--如果达到每日上限,不提醒
		if BagModel:GetItemCanUseNum(tid) == 0 then
			return;
		end
		UIItemGuideUse:Open(item:GetId());
	end
}
);