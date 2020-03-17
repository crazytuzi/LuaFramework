--[[
    Created by IntelliJ IDEA.
    User: Hongbin Yang
    Date: 2016/7/6
    Time: 15:02
   ]]

ItemScriptCfg:Add(
	{
		name = "openstove",
		execute = function(bag,pos, stoveType)
			if not FuncManager:GetFuncIsOpen(FuncConsts.XuanBing) then return; end
			UIBag:Hide();
			FuncManager:OpenFunc(FuncConsts.XuanBing, false, stoveType);
			return true;
		end
	}
);