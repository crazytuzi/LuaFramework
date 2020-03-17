--[[
FumoUtil
chenyujia
2016-5-18
]]

_G.FumoUtil = {};

local sortFunc = function(t1, t2)
	return t1.map < t2.map
end

--- 是否整个大类可升级
function FumoUtil:isCanUpMap(nPage)
	local listFumo = FumoModel:GetFumoList(nPage)
	for k, v in pairs(listFumo) do
		for k1, v1 in pairs(v) do
			local bCanUp, oper = v1:bCanLvUp()
			if bCanUp then
				return true, oper
			end
		end
	end
	return false
end

function FumoUtil:GetShowList(nPage)
	local list = {}
	local listFumo = FumoModel:GetFumoList(nPage)

	for k, v in pairs(listFumo) do
		local vo = {}
		local bCanUp = false
		local value = 0
		local maxValue = 0
		for k1, v1 in pairs(v) do
			maxValue = maxValue + v1:GetMaxLv()
			value = value + v1:GetShowLv()

			if v1:bCanLvUp() then
				bCanUp = true
			end
		end
		for k1, v1 in pairs(t_fumobasic) do
			if v1.map == k then
				local mapCfg = t_map[v1.mapid]
				if toint(v1.belongTabs) == 3 then
					vo.lv = 1
				else
					vo.lv = mapCfg.limitLv
				end
				vo.map = k
				vo.headUrl = ResUtil:GetFumoIcon(v1.mapicon)
				vo.nameUrl = ResUtil:GetFumoIcon(v1.mapname)
				vo.nameStr = v1.mapname1
				vo.bCanUp = bCanUp
				vo.value = value
				vo.maxValue = maxValue
				vo.gress = math.floor(value * 100/maxValue) .. "%" --string.format(StrConfig["fumogress"], value, maxValue)
				table.push(list, vo)
				break
			end
		end
	end
	table.sort(list, sortFunc)
	return list
end

function FumoUtil:GetCanOperatePage()
	for i = 1, 3 do
		for k, v in pairs(FumoModel:GetFumoList(i)) do
			for k1, v1 in pairs(v) do
				if v1:bCanLvUp() then
					return i
				end
			end
		end
	end
	return 1
end

function FumoUtil:GetCanOperateIndex(nPage)
	local list = self:GetShowList(nPage)
	for k, v in pairs(list) do
		for k1, v1 in ipairs(FumoUtil:getMapListBymap(v.map)) do
			if v1:bCanLvUp() then
				if k < 7 then
					return 1, k
				elseif k <= #list - 5 then
					return k, 1
				else
					return #list - 5, 6 - (#list - k)
				end
			end
		end
	end
	return 1, 1
end

function FumoUtil:GetCanOperateOne(map)
	local list = FumoUtil:getMapListBymap(map)
	for k, v in ipairs(list) do
		if v:bCanLvUp() then
			if k < 5 then
				return 1
			elseif k < #list - 3 then
				return math.floor(k/3) * 4 + 1
			else
				return #list - 3
			end
		end
	end
	return 1
end

-- todo 属性这里暂时不做排序
function FumoUtil:GetAllPro()
	local list = {}
	local listFumo = FumoModel:GetFumoList()
	for k, v in pairs(listFumo) do
		for k1, v1 in pairs(v) do
			for k2, v2 in pairs(v1:GetPro()) do
				local bHave = false
				for k3, v3 in pairs(list) do
					if v3.type == v2.type then
						list[k3].val = list[k3].val + v2.val
						bHave = true
						break
					end
				end
				if not bHave then 
					table.push(list, v2)
				end
			end
		end
	end
	--- 要加上连锁属性。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。
	for k, v in pairs(FumoModel:GetFumoList()) do
		local id, pro = FumoUtil:GetLinkIdByMap(k)
		list = PublicUtil:GetFightListPlus(list, pro)
	end
	local id, pro = FumoUtil:GetLinkIdAll()
	list = PublicUtil:GetFightListPlus(list, pro)
	return list
end

function FumoUtil:GetProByMap(map)
	local list = {}
	for k, v in pairs(FumoModel:GetListByMap(map)) do
		for k2, v2 in pairs(v:GetPro()) do
			local bHave = false
			for k3, v3 in pairs(list) do
				if v3.type == v2.type then
					list[k3].val = list[k3].val + v2.val
					bHave = true
					break
				end
			end
			if not bHave then 
				table.push(list, v2)
			end
		end
	end
	return list
end

local sortFunc1 = function(t1, t2)
	-- if not t1:GetNextLvCfg() and not t2:GetNextLvCfg() then
	-- 	return t1.id < t2.id
	-- end
	-- if not t1:GetNextLvCfg() then
	-- 	return false
	-- end
	-- if not t2:GetNextLvCfg() then
	-- 	return true
	-- end
	-- if t1:bCanLvUp() and t2:bCanLvUp() then
		return t1.id < t2.id
	-- end
	-- return t1:bCanLvUp()
end

---根据图鉴类型获取具体图鉴表
function FumoUtil:getMapListBymap(map)
	local list = {}
	for k, v in pairs(FumoModel:GetListByMap(map)) do
		table.push(list, v)
	end
	table.sort(list, sortFunc1)
	return list
end

local str = "%s(%s)：(%s/%s)"
function FumoUtil:GetFinishList()
	local list = {}
	local listFumo = FumoModel:GetFumoList()
	for k, v in pairs(listFumo) do
		local vo = {}
		local nCur = -1
		local nMax = 0
		local mapCfg = nil
		for k1, v1 in pairs(v) do
			if not v1:GetNextLvCfg() then
				nCur = nCur > -1 and nCur + 1 or 1
			elseif v1:IsActive() then
				nCur = nCur ~= -1 and nCur or 0
			end
			if not mapCfg then
				mapCfg = t_map[v1:getMapID()]
			end
			nMax = nMax + 1
		end
		if nCur ~= -1 then
			vo.str = string.format(str, mapCfg.name, mapCfg.limitLv, nCur, nMax)
			table.push(list, vo)
		end
	end
	return list
end

--获取当前地图连锁等级
function FumoUtil:GetLinkIdByMap(map)
	local lv = 0
	for k, v in pairs(FumoModel:GetListByMap(map)) do
		if v.lv >= 0 then
			lv = lv + v:GetShowLv()
		end
	end
	for k, v in pairs(t_fumoliansuo) do
		if v.map == map and v.minlv <= lv and (v.maxlv > lv or v.maxlv == -1) then
			return v.maplv, AttrParseUtil:Parse(v.att), v.minlv
		end
	end
	return 0, {}
end

--获取当前地图连锁等级
function FumoUtil:GetLinkIdAll()
	local lv = 0
	for k, v in pairs(FumoModel:GetFumoList()) do
		for k1, v1 in pairs(v) do
			if v1.lv >= 0 then
				lv = lv + v1:GetShowLv()
			end
		end
	end
	for k, v in pairs(t_fumoliansuo) do
		if v.map == 0 and v.minlv <= lv and (v.maxlv > lv or v.maxlv == -1) then
			return v.maplv, AttrParseUtil:Parse(v.att), v.minlv
		end
	end
	return 0, {}
end

function FumoUtil:GetNextLinkCfg(map, id)
	for k, v in pairs(t_fumoliansuo) do
		if v.map == map and v.maplv == id + 1 then
			return v
		end
	end
end

function FumoUtil:GetProStr(pro)
	local str = ""
	local list = {}
	--- 这里对显示进行排序
	for k, v in pairs(PublicAttrConfig.pro) do
		for k1, v1 in pairs(pro) do
			if v == v1.name then
				table.push(list, v1)
				break
			end
		end
	end
	for i, v in ipairs(list) do
		str = str .. string.format(StrConfig['fumo1007'], PublicAttrConfig.proSpaceName[v.name], v.val) .. "\n"
	end
	return str
end

function FumoUtil:GetCurLinkStr(map)
	local str = ""
	local id, pro, lv = self:GetLinkIdByMap(map)
	local mapCfg
	for k, v in pairs(t_fumobasic) do
		if v.map == map then
			mapCfg = t_map[v.mapid]
			break
		end
	end
	if id == 0 then
		str = str .. string.format(StrConfig['fumo1002'], mapCfg.name) .. "\n"
	else
		str = str .. string.format(StrConfig['fumo1011'], mapCfg.name) .. string.format(StrConfig['fumo1010'], id) .. "\n"
		str = str .. string.format(StrConfig['fumo1011'], mapCfg.name) .. string.format(StrConfig['fumo1009'], lv) .. StrConfig["fumo1006"] .. "\n\n"
		str = str .. self:GetProStr(pro)
	end
	str = str .. "\n"
	str = str .. StrConfig['fumo1003'] .. "\n"
	local nextCfg = self:GetNextLinkCfg(map, id)
	if nextCfg then
		str = str .. string.format(StrConfig['fumo1011'], mapCfg.name) .. string.format(StrConfig['fumo1010'], nextCfg.maplv) .. "\n"
		str = str .. string.format(StrConfig['fumo1011'], mapCfg.name) .. string.format(StrConfig['fumo1009'], nextCfg.minlv) .. StrConfig["fumo1005"] .. "\n\n"
		str = str .. self:GetProStr(AttrParseUtil:Parse(nextCfg.att))
	else
		str = str .. StrConfig['fumo1004']
	end
	return string.format(StrConfig['fumo1000'], str)
end

function FumoUtil:GetAllLinkStr()
	local str = ""
	local id, pro, lv = self:GetLinkIdAll()

	if id == 0 then
		str = str .. StrConfig['fumo1001'] .. "\n"
	else
		str = str .. string.format(StrConfig['fumo1008'], id) .. "\n"
		str = str .. string.format(StrConfig['fumo1009'], lv) .. StrConfig["fumo1006"] .. "\n\n"
		str = str .. self:GetProStr(pro)
	end
	str = str .. "\n"
	str = str .. StrConfig['fumo1003'] .. "\n"
	local nextCfg = self:GetNextLinkCfg(0, id)
	if nextCfg then
		str = str .. string.format(StrConfig['fumo1008'], nextCfg.maplv) .. "\n"
		str = str .. string.format(StrConfig['fumo1009'], nextCfg.minlv) .. StrConfig["fumo1005"] .. "\n\n"
		str = str .. self:GetProStr(AttrParseUtil:Parse(nextCfg.att))
	else
		str = str .. StrConfig['fumo1004']
	end
	return string.format(StrConfig['fumo1000'], str)
end