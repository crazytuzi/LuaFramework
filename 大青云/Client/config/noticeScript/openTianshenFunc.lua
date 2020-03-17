--[[

]]

NoticeScriptCfg:Add(
{
	name = "openTianshen",
	execute = function()
		if not FuncManager:GetFuncIsOpen(FuncConsts.NewTianshen) then return true; end  
			FuncManager:OpenFunc(FuncConsts.NewTianshen);
		return true;
	end
}
);