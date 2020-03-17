--[[
套装道具
lizhuangzhuang
2015年7月24日17:22:20
]]

ItemScriptCfg:Add(
{
	name = "equipgroup",
	execute = function(bag,pos)
		if not bag then return; end
		if not pos then return; end
		UIEquipGroup:Open(bag,pos);
		return true;
	end
}
);