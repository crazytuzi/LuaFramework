--[[
打开组队经验之战界面
参数:FuncConsts.teamExper  123
houxudong
2016年11月6日23:48:25
]]

NoticeScriptCfg:Add(
{
	name = "openzdsj",
	execute = function()
		if not FuncManager:GetFuncIsOpen(FuncConsts.Dungeon) then return true; end  
			FuncManager:OpenFunc(FuncConsts.Dungeon, false, FuncConsts.teamExper);
		return true;
	end
}
);