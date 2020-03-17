--[[
戒指打开结婚
lizhuangzhuang
2015年12月29日20:08:18
]]

ItemScriptCfg:Add(
{
	name = "openmarry",
	execute = function(bag,pos)
		UIRole:Show(UIRole.MARRY);
		return true;
	end
}
);