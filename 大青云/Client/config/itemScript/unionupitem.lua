--[[
使用帮派令牌
lizhuangzhuang
2015年11月3日23:59:30
]]

ItemScriptCfg:Add(
{
	name = "unionupitem",
	execute = function(bag,pos)
		local bagVO = BagModel:GetBag(bag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(pos);
		if not item then return; end
		local msg = ReqExtendGuildMsg:new();
		msg.itemid = item:GetId();
		MsgManager:Send(msg);
		return true;
	end
}
);