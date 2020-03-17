--[[
打开UI
参数:
@param name UI名字
lizhuangzhuang
2015年1月20日15:21:12
]]

NoticeScriptCfg:Add(
{
	name = "openui",
	execute = function(name)
		if not name then return false; end
		local ui = UIManager:GetUI(name);
		if not ui then return; end
		if not ui:IsShow() then
			ui:Show();
		end
		return true;
	end
}
);