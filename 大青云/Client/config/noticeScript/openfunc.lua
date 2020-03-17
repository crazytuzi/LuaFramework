--[[
打开功能
参数：
@param funcId 功能id
lizhuangzhuang
2015年1月20日15:19:18
]]

NoticeScriptCfg:Add(
{
	name = "openfunc",
	execute = function(funcId)
		if not funcId then return false; end
		local funcId = toint(funcId);
		if not funcId then return false; end
		FuncManager:OpenFunc(funcId,false);
		return true;
	end
}
);