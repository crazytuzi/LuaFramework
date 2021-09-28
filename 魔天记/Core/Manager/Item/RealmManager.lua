local RealUpgradeCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_REALM);
local RealmCompactCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_REALM_COMPACT);
local RealmFairyCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FAIRY);
local RealmAttrInfo = require "Core.Info.RealmAttrInfo"
RealmFairyCfg = ConfigManager.SortForField(RealmFairyCfg, 'num')
RealmCompactCfg = ConfigManager.SortForField(RealmCompactCfg, 'career', 'num')

RealmManager = {}
local _realmLevel = 0;
local _compactLevel = 0;
local _currTheurgy = 1;
RealmManager._attributes = {"hp_max", "phy_att", "phy_def", "hit", "eva", "crit", "tough", "fatal", "block"}
RealmManager._skills = {{0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0}}

local pairs = pairs
local find = string.find

function RealmManager.Init(data)
	if(data) then
		_realmLevel = data.rlv or 0;
		_compactLevel = data.clv or 0;
		_currTheurgy = data.idx or 1;
		if(data.rsk) then
			RealmManager._skills[1] = ConfigManager.Clone(data.rsk);
		end
		if(data.rsk1) then
			RealmManager._skills[1] = ConfigManager.Clone(data.rsk1);
		end
		if(data.rsk2) then
			RealmManager._skills[2] = ConfigManager.Clone(data.rsk2);
		end
	end
end

function RealmManager.CanRealm()
	return RealmManager.CanUpgrade() or RealmManager.CanCompact();
end

function RealmManager.CanUpgrade()
	if SystemManager.IsOpen(SystemConst.Id.REALM) then
		local info = RealmManager.GetUpgradeInfoByLevel(_realmLevel + 1);
		if(info) then
			if(info.req_item[1] ~= nil and info.req_item[1] ~= "") then
				local tmp = string.split(info.req_item[1], "_");
				local id = tonumber(tmp[1]);
				local total = tonumber(tmp[2]);
				if(BackpackDataManager.GetProductTotalNumBySpid(id) >= total) then
					return PlayerManager.power >= info.req_fighting
				end
				return false
			end
			return PlayerManager.power >= info.req_fighting
		end
	end
	return false
end

function RealmManager.CanCompact()
	if(SystemManager.IsOpen(SystemConst.Id.JingJieNinLian)) then
		if(_realmLevel > 0) then
			local info = RealmManager.GetCompactInfoByLevel(_compactLevel + 1);
			if(info) then
				--                local blCan = true;
				--                for i, v in pairs(info.compact_consume) do
				--                    local p = string.split(v, "_");
				--                    local num = BackpackDataManager.GetProductTotalNumBySpid(tonumber(p[1]));
				--                    local needNum = tonumber(p[2]);
				--                    blCan = blCan and (num >= needNum);
				--                end
				--                return blCan;
				local n = info.num
				local ceng = RealmProxy.GetXLTier()
				return ceng >= n
			end
		end
	end
	return false
end

function RealmManager.GetCompactAddAttribute(cInfo, nInfo)
	if(cInfo and nInfo) then
		for i, v in pairs(RealmManager._attributes) do
			if(cInfo[v] ~= nInfo[v]) then
				return LanguageMgr.Get("attr/" .. v), nInfo[v];
			end
		end
	end
	if(nInfo ~= nil) then
		local name = RealmManager._attributes[1];
		return LanguageMgr.Get("attr/" .. name), nInfo[name];
	end
	return "", ""
end

function RealmManager.SetTheurgy(id)
	_currTheurgy = id;
end

function RealmManager.GetTheurgy()
	return _currTheurgy;
end

function RealmManager.SetRealmSkill(layer, skill, theurgy)
	if(skill and layer and layer > 0 and layer <= 7) then
		local index = theurgy or _currTheurgy
		RealmManager._skills[index] [layer] = skill;
	end
end

function RealmManager.GetRealmSkill(layer, theurgy)
	local index = theurgy or _currTheurgy
	return RealmManager._skills[index] [layer];
end

function RealmManager.GetRealmSkills(theurgy)
	local index = theurgy or _currTheurgy
	return RealmManager._skills[index];
end

-- 设置境界等级
function RealmManager.SetRealmLevel(level)
	_realmLevel = level or _realmLevel;
	PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Realm);
end
-- 获取境界等级
function RealmManager.GetRealmLevel()
	return _realmLevel;
end

-- 设置凝练等级
function RealmManager.SetCompactLevel(level)
	_compactLevel = level or _compactLevel;
	PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Realm);
end
-- 获取凝练等级
function RealmManager.GetCompactLevel()
	return _compactLevel;
end

function RealmManager.GetUpgradeInfoByLevel(level, kind)
	local lv = level or _realmLevel;
	local k = kind or PlayerManager.GetPlayerKind()
	local rc = RealUpgradeCfg[k .. "_" .. lv]
	return rc;
end

function RealmManager.GetCompactInfoByLevel(level)
	local lv = level or _compactLevel;
	--    local hInfo = PlayerManager.hero.info;
	--    return RealmCompactCfg[hInfo.kind .. "_" .. lv];
	local kind = PlayerManager.GetPlayerKind()
	local cs = RealmCompactCfg
	local len = #cs
	for i = 1, len do
		local c = cs[i]
		if c.compact_lev == lv and c.career == kind then
			return c
		end
	end
	return nil
end

function RealmManager.GetNameAndQualityByLevel(realmLevel)
	local rlv = realmLevel or 0;
	if(rlv > 0) then
		local rInfo = RealmManager.GetUpgradeInfoByLevel(rlv);
		if(rInfo) then
			return rInfo.realm_name, math.ceil(rlv / 9);
		end
	end
	return nil;
end

function RealmManager.GetNextUpgradeAttrs()
	local info = RealmManager.GetUpgradeInfoByLevel(RealmManager.GetRealmLevel() + 1)
	local attrs = nil
	if(info) then
		attrs = RealmAttrInfo:New()
		attrs:Init(info) 
	end
	return attrs
end

function RealmManager.GetUpgradeAttrs()
	local info = RealmManager.GetUpgradeInfoByLevel();
	local attrs = RealmAttrInfo:New() 
	if(info) then
		attrs:Init(info)
	else
		attrs:Reset()		
	end
	return attrs
end

function RealmManager.GetAllAttrs()
	local info = RealmManager.GetCompactInfoByLevel();
	local attrs = RealmManager.GetUpgradeAttrs();
	if(info) then
		local rate = info.plus_rate / 100;
		for i, v in pairs(attrs) do
			attrs[i] = v * rate
			if(info[i]) then
				attrs[i] = attrs[i] + info[i]
			end
		end
	end
	
	return attrs
end
--返回神通配置,t类型,i第一个还是第二个
function RealmManager.GetFairy(t, i)
	local key = t .. "_" .. i
	local cs = RealmFairyCfg
	local len = #cs
	for i = 1, len do
		local c = cs[i]
		if c.key == key then
			return c
		end
	end
	return nil
end

--返回当前层提升神通(1还是凝练(2,还是没有提升(0
function RealmManager.GetMagicOrComPact(ceng)
	if RealmManager.GetComPactConfig(ceng) then return 1
	elseif RealmManager.GetMagicConfig(ceng) then return 2
	end
	return 0
end
--返回当前层凝练名
function RealmManager.GetComPactName(ceng)
	local t = RealmManager.GetComPactConfig(ceng)
	if t then return t.quality_title end
	return ""
end
--返回当前层神通名,技能名
function RealmManager.GetMagicNameAndSkillName(ceng)
	local t = RealmManager.GetMagicConfig(ceng)
	if t then
		local sn = SkillManager:GetSkillById(t.skill)
		return t.name, sn.name
	end
	return "", ""
end
--返回返回当前层或下一层神通层数,-1没有了
function RealmManager.GetMagicConfigOrNext(ceng)
	local cs = RealmFairyCfg
	local len = #cs
	local f
	for i = 1, len do
		local c = cs[i]
		if c.num >= ceng then
			return(i == len and c.num == ceng) and - 1 or c.num --满级判断
		end
	end
	return - 1
end
--返回返回当前层或下一层凝练层数,-1没有了
function RealmManager.GetComPactConfigOrNext(ceng)
	local kind = PlayerManager.GetPlayerKind()
	local cs = RealmCompactCfg
	local len = #cs
	local kindLen = len / 4
	--Warning(len .. '___' .. kindLen)
	local n = 0
	for i = 1, len do
		local c = cs[i]
		if c.career == kind then
			n = n + 1
			if c.num >= ceng then			
				return(n == kindLen and c.num == ceng) and - 1 or c.num--满级判断
			end
		end
	end
	return - 1
end
--返回返回上一层凝练层数
function RealmManager.GetLastComPactConfig(ceng)
	local kind = PlayerManager.GetPlayerKind()
	local cs = RealmCompactCfg
	local len = #cs
	local kcs = {}
	for i = 1, len do
		local c = cs[i]
		if c.career == kind then
			table.insert(kcs, c)
		end
	end
	local kindLen = #kcs
	for i = kindLen, 1, - 1 do
		local c = kcs[i]
		if c.num < ceng then		
			return c
		end
	end
	return kcs[1]
end

function RealmManager.GetMagicConfig(ceng)
	local cs = RealmFairyCfg
	local len = #cs
	for i = 1, len do
		local c = cs[i]
		if c.num == ceng then
			return c
		end
	end
	return nil
end
function RealmManager.GetComPactConfig(ceng)
	local kind = PlayerManager.GetPlayerKind()
	local cs = RealmCompactCfg
	local len = #cs
	for i = 1, len do
		local c = cs[i]
		if c.num == ceng and c.career == kind then
			return c
		end
	end
	return nil
end
function RealmManager:GetHeroSkillById(id)
	local heroInfo = PlayerManager.hero.info;
	if(heroInfo) then
		local skill = heroInfo:GetSkill(id, true);
		if(skill) then
			return skill
		end
	end
	return SkillManager:GetSkillById(id)
end

local xlt_ceng
function RealmManager.GetMagicPower()
	--Warning(tostring(xlt_ceng))
	local p = 0
	if not xlt_ceng then return p end
	local ceng = xlt_ceng
	local cs = RealmFairyCfg
	local len = #cs
	for i = 1, len do
		local c = cs[i]
		if c.num <= xlt_ceng then
			local sk = RealmManager:GetHeroSkillById(c.skill)	
			p = p + sk.zdl_value
		end
	end
	return p
end
function RealmManager.OnXLTChange(ceng)
	xlt_ceng = ceng
	--Warning("ceng=" .. ceng ..',magicPower='.. RealmManager.GetMagicPower())
	PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.None, true)
end

