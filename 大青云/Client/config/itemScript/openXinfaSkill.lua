--[[
    Created by Sublime
    User: houxudong
    Date: 2016年11月27日
    Time: 15:58:23
   ]]

ItemScriptCfg:Add(
	{
		name = "openXinfa",
		execute = function(bag,pos, skillType)
			if not FuncManager:GetFuncIsOpen(FuncConsts.MagicSkill) then return; end
			UIBag:Hide();
			FuncManager:OpenFunc(FuncConsts.MagicSkill, false, skillType);
			return true;
		end
	}
);