--[[
打开UI
参数：name,UI名字
lizhuangzhuang
2014年11月12日15:28:16
]]

ItemScriptCfg:Add(
{
	name = "openui",
	execute = function(bag,pos,name)
		if not name then return; end
		local ui = UIManager:GetUI(name);
		if not ui then return; end
		if not ui:IsShow() then
			ui:Show();
		end
		return true;
	end
}
);