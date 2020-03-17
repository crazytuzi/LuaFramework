--[[
发送喇叭
lizhuangzhuang
2014年11月12日14:57:48
]]

ItemScriptCfg:Add(
{
	name = "hornsend",
	execute = function(bag,pos)
		if not bag then return; end
		if not pos then return; end
		UIChatHornSend:Open(bag,pos);
		return true;
	end
}
);