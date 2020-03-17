--[[
道具卡
wangyanwei
2015年10月19日16:59:21
]]

ItemScriptCfg:Add(
{
	name = "openItemCardChange",
	execute = function(bag,pos,str)
		if not str then return; end
		local strCfg = split(str,'#');
		if #strCfg ~= 2 then return end		
		UIUpGradeStoneCard:Open(toint(strCfg[1]),toint(strCfg[2]),pos);
		return true
	end
}
);