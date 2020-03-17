--[[
打开UI
参数：name,UI名字
lizhuangzhuang
2014年11月12日15:28:16
]]

ItemScriptCfg:Add(
{
	name = "openFirstChargePanel",
	execute = function(bag,pos,name)
		-- local func = function ()
			-- if not OperActivity1Btn:IsShow() then
				-- return
			-- end
		if OperActivity1Btn:IsShow() then
			OperActUIManager:ShowHideOperActUI(OperactivitiesConsts.iconShouchong)
		else
			FPrint('首冲未开启')
		end
		-- end
	
		-- UIConfirm:Open(StrConfig['operactivites8'],func);		
		return true;
	end
}
);