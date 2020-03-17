--[[
打开功能
参数：funcId,功能id
lizhuangzhuang
2014年11月12日14:57:48
]]

ItemScriptCfg:Add(
{
	name = "openfunc",
	execute = function(bag,pos,funcId)
		if not funcId then return; end
		local funcId = toint(funcId);
		if not funcId then return; end
		FuncManager:OpenFunc(funcId,false);
		return true;
	end
}
);