--[[
	珍宝阁碎片变化
	2015年5月6日, AM 11:27:54
	wangyanwei
]]

ItemNumCScriptCfg:Add(
{
	name = "jewellerychange",
	execute = function(bag,pos,tid)
		if JewelleryUtil:CanFeed(JewelleryUtil:GetJewellery(tid)) ~= 1 then
			return
		end
		if JewelleryUtil:OnCanShowJewellery(tid) then
			UIItemGuide:Open(5);
		end
	end
}
);