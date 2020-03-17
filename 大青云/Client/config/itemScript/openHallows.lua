--[[
	2016年1月5日22:05:44
	wangyanwei
	圣灵镶嵌
]]

ItemScriptCfg:Add(
{
	name = "openHallows",
	execute = function()
		if not FuncManager:GetFuncIsOpen(FuncConsts.Hallows) then
			FloatManager:AddNormal(FuncManager:GetFuncUnOpenTips(FuncConsts.Hallows))
			return true
		end
		BingHunMainUI:Open('shengling');
		return true
	end
}
);