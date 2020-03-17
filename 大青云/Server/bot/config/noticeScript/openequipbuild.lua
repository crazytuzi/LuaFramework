--[[
打开打造
参数:
@param id	打造id
@param isVip 是否是VIP打造
lizhuangzhuang
2015年9月5日17:32:12
]]

NoticeScriptCfg:Add(
{
	name = "openequipbuild",
	execute = function(id,isVip)
		if not id then return false; end
		local id = toint(id);
		local isVip = isVip=="1";
		UIEquipBuildMain:Show(FuncConsts.EquipBuild,id,isVip);
		return true;
	end
}
);