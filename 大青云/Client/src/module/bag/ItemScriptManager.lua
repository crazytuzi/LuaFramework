--[[
物品脚本管理器
lizhuangzhuang
2014年11月12日15:38:19
]]

_G.ItemScriptManager = {};

function ItemScriptManager:DoScript(bag,pos,name,param)
	if not ItemScriptCfg[name] then
		Debug("Error:没有找到物品脚本,name="..name);
		return;
	end
	local paramlist = nil;
	if param == "" then
		paramlist = {};
	else
		paramlist = split(param,",");
	end
	local script = ItemScriptCfg[name];
	local result = script.execute(bag,pos,unpack(paramlist));
	if not result then
		Debug("Error:物品脚本使用出错,name="..name);
	end
end
