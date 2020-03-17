--[[
升阶石抽奖祭敖包
wangyanwei
2015年10月9日, PM 11:26:57
]]

ItemScriptCfg:Add(
{
	name = "openUpgradeStone",
	execute = function()
		if not UIUpgradeStone:IsShow() then
			UIUpgradeStone:Show();
		end
		return true
	end
}
);