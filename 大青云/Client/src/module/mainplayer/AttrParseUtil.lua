--[[
util,解析配表中的属性列
lizhuangzhuang
2014年8月18日16:30:59
]]
_G.AttrParseUtil = {};

--配表属性映射
AttrParseUtil.AttMap = {
	["hl"] = enAttrType.eaHunLi,
	["sf"] = enAttrType.eaShenFa,
	["js"] = enAttrType.eaJingShen,
	["tp"] = enAttrType.eaTiPo,
	--
	["hp"] = enAttrType.eaMaxHp,
	["mp"] = enAttrType.eaMaxMp,
	["sp"] = enAttrType.eaMaxTiLi,
	["fhp"] = enAttrType.eaHp,
	["fmp"] = enAttrType.eaMp,
	["fsp"] = enAttrType.eaTiLi,
	["hpre"] = enAttrType.eaHpReback,
	["mpre"] = enAttrType.eaMpReback,
	["spre"] = enAttrType.eaTiLiReback,
	--
	["att"] = enAttrType.eaGongJi,
	["def"] = enAttrType.eaFangYu,

	["defjiansu"] = enAttrType.eaDefJianSu,
	["defxuanuun"] = enAttrType.eaDefXuanYun,
	["defchenmo"] = enAttrType.eaDefChenMo,
	["defdingshen"] = enAttrType.eaDefDingShen,
	["defYuLiu"] = enAttrType.eaDefYuLiu,

	["hit"] = enAttrType.eaMingZhong,
	["dodge"] = enAttrType.eaShanBi,
	["cri"] = enAttrType.eaBaoJi,
	["defcri"] = enAttrType.eaRenXing,
	["crivalue"] = enAttrType.eaBaoJiHurt,
	["subcri"] = enAttrType.eaBaoJiDefense,
	["absatt"] = enAttrType.eaChuanCiHurt,
	["parryvalue"] = enAttrType.eaGeDang, --dongtu 2016/6/2
	["defparry"] = enAttrType.eaChuanTou, --dongtu 2016/6/2
	["adddamage"] = enAttrType.eaHurtAdd,
	["subdamage"] = enAttrType.eaHurtSub,
	["attspeed"] = enAttrType.eaGongJiSpeed,
	["movespeed"] = enAttrType.eaMoveSpeed,
	["subdef"] = enAttrType.eaSubdef,
	--
	["killhp"] = enAttrType.eaKillHp,
	["killmp"] = enAttrType.eaKillMp,
	["hithp"] = enAttrType.eaHitHp,
	["shpre"] = enAttrType.eaShpre,
	["golddrop"] = enAttrType.eaGoldDrop,
	["itemdrop"] = enAttrType.eaItemDrop,
	["extradamage"] = enAttrType.eaExtraDamage,
	["extrasubdamage"] = enAttrType.eaExtraSubDamage,
	["super"] = enAttrType.eaSuper,
	["superx"] = enAttrType.eaSuperX,
	["supervalue"] = enAttrType.eaSuperValue,
	--
	["hpx"] = enAttrType.eaHpX,
	["mpx"] = enAttrType.eaMpX,
	["attx"] = enAttrType.eaAtkX,
	["defx"] = enAttrType.eaDefX,
	["absattx"] = enAttrType.eaAbsAttX,
	["subdefx"] = enAttrType.eaSubDefX,
	["adddamagemon"] = enAttrType.eaAdddamagemon,
	["adddamagemonx"] = enAttrType.eaAdddamagemonx,
	["adddamageboss"] = enAttrType.eaAdddamageboss,
	["adddamagebossx"] = enAttrType.eaAdddamagebossx,
	["hit_rate"] = enAttrType.eaHitRate,            --dongtu 2016/6/2
	["dodge_rate"] = enAttrType.eaDodgeRate,
	["cri_rate"] = enAttrType.eaCriRate,            --dongtu 2016/6/2
	["defcri_rate"] = enAttrType.eaDefCriRate,      --dongtu 2016/6/2
	["parry_rate"] = enAttrType.eaParryRate,        --dongtu 2016/6/2
	["defparry_rate"] = enAttrType.eaDefParryRate,  --dongtu 2016/6/2
	["att_level"] = enAttrType.eaAttLvl,
	["reflex"] = enAttrType.eaReflex,
	["igdef"] = enAttrType.eaIgdef,
	["shenwei"] = enAttrType.eaShenwei,
	--
	["horsesknattx"] = enAttrType.eaHorsesknattx,
	["horseskndefx"] = enAttrType.eaHorseskndefx,
	["horsesknhpx"] = enAttrType.eaHorsesknhpx,
	["horseskncrix"] = enAttrType.eaHorseskncrix,
	["horseskndefcrix"] = enAttrType.eaHorseskndefcrix,
	["horseskndodgex"] = enAttrType.eaHorseskndodgex,
	["horsesknhitx"] = enAttrType.eaHorsesknhitx,
	["horsesknx"] = enAttrType.eaHorsesknx,
	["lingshousknattx"] = enAttrType.eaLingshousknattx,
	["lingshouskndefx"] = enAttrType.eaLingshouskndefx,
	["lingshousknhpx"] = enAttrType.eaLingshousknhpx,
	["lingshouskncrix"] = enAttrType.eaLingshouskncrix,
	["lingshouskndefcrix"] = enAttrType.eaLingshouskndefcrix,
	["lingshouskndodgex"] = enAttrType.eaLingshouskndodgex,
	["lingshousknhitx"] = enAttrType.eaLingshousknhitx,
	["lingshousknx"] = enAttrType.eaLingshousknx,
	--
	["gold"] = enAttrType.eaAttrGold,
	["wood"] = enAttrType.eaAttrWood,
	["water"] = enAttrType.eaAttrWater,
	["fire"] = enAttrType.eaAtteFire,
	["soil"] = enAttrType.eaAttrSoil,
}

if isDebug then
	local meta = {};
	meta.__index = function(table,key)
		_debug:throwException("Error:错误的属性类型."..key);
		_debug:throwException(debug.traceback());
	end
	setmetatable(AttrParseUtil.AttMap, meta);
end

--属性类型,属性值#属性类型,属性值
function AttrParseUtil:Parse(str)
	local list = {};
	local t = split(str,'#');
	for i=1,#t do
		local t1 = split(t[i],',');
		if self.AttMap[t1[1]] then
			local vo = {};
			vo.type = self.AttMap[t1[1]];
			vo.name = t1[1];
			vo.val = tonumber(t1[2]);
			table.push(list,vo);
		else
			Error('Error:属性配表错误.name='..t1[1]..".Str="..str);
		end
	end
	return list;
end

--str:属性类型,属性值#属性类型,属性值
function AttrParseUtil:ParseAttrToMap(str)
	local map = {};
	local t = split(str,'#');
	for i = 1, #t do
		local t1 = split(t[i],',');
		map[ t1[1] ] = tonumber(t1[2]);
	end
	return map;
end

--- 根据配置字符串获取类型
function AttrParseUtil:getType(atr)
	return self.AttMap[atr]
end

--- 根据配置字符串获取enAttrType中的key
function AttrParseUtil:GetTypeStr(atr)
	local nType = self.AttMap[atr]
	for k, v in pairs(enAttrType) do
		if v == nType then
			return k
		end
	end
end

--- 根据类型获取配置表中原始字符串
function AttrParseUtil:GetCfgStr(key)
	for k,v in pairs(self.AttMap) do
		if v == key then
			return k
		end
	end
end