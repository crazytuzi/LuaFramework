--[[
	首冲道具变化
]]

ItemNumCScriptCfg:Add(
{
	name = "firstChargeItemChange",
	execute = function(bag,pos,tid)
		if not OperActivity1Btn:IsShow() then
			FPrint(StrConfig['operactivites37'])
			return
		end
		
		
		if t_consts[124] then
			local itemId = t_consts[124].val1
			if tid == itemId then
				OperActUIManager:ShowHideOperActUI(OperactivitiesConsts.iconShouchong)
			end			
		end
	end
}
);