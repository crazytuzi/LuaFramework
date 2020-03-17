--[[
打开指定层数斗破
lizhuangzhuang
2015年9月19日23:03:15
]]

NoticeScriptCfg:Add(
{
	name = "openbabel",
	execute = function(index)
		if not FuncManager:GetFuncIsOpen(FuncConsts.Babel) then return false; end
		UIBabel:Show(toint(index));
		return true;
	end
}
);