--[[
打开珍宝阁
参数：index,索引 0-8
lizhuangzhuang
2015年6月3日23:09:35
]]

ItemScriptCfg:Add(
{
	name = "openjewellery",
	execute = function(bag,pos,index)
		if not JewelleryUtil:OnCanOpenJewellery(index + 1) then
			FloatManager:AddNormal( StrConfig["jewellery666"] );
			return true;
		end
		
		if not index then return; end
		local index = toint(index);
		if not index then return; end
		FuncManager:OpenFunc(FuncConsts.ZhanBaoGe,false,index);
		return true;
	end
}
);