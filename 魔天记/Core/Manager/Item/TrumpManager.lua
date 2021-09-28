require "Core.Manager.Item.ProductsContainer";
require "Core.Info.TrumpInfo";
require "Core.Info.BaseAdvanceAttrInfo";

TrumpManager = {}
local _trumpConfig = nil
local _trumpExpConfig = nil
local _cauldronConfig = nil
local _trumpRefineConfig = nil
local _trumpCollectAreaData = {}
local _trumpEquipData = {}
local _trumpBagData = {}
local _nextQc = 0 -- 下一次炼制的品质
local _selectQc = 0
local _activeQcList = {}
local _collectQc = - 1
local _mainTrumpId = "0"
local _trumpCoin = 0
TrumpManager.TRUMPBAGMAXCOUNT = 20
TrumpManager.SelfTrumpFollow = "SELFTRUMPFOLLOW"
TrumpManager.TRUMPCOINCHANGE = "TRUMPCOINCHANGE"

-- TrumpManager._trumpBagContainer = ProductsContainer:New();
-- TrumpManager._trumpEquipContainer = ProductsContainer:New();
function TrumpManager.Init(data)
	
	--    TrumpManager._trumpBagContainer:SetItemClass(TrumpInfo)
	--    TrumpManager._trumpEquipContainer:SetItemClass(TrumpInfo)
	_trumpRefineConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TRUMPREFINED)
	_trumpConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TRUMP) [1]
	_trumpExpConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TRUMPEXP)
	_cauldronConfig = {}
	for i = 1, table.getCount(_trumpConfig.name) do
		_cauldronConfig[i] = {}
		--        _cauldronConfig[i].icon = tostring(_trumpConfig.icon[i])
		_cauldronConfig[i].cost = tostring(_trumpConfig.money[i])
		_cauldronConfig[i].name = tostring(_trumpConfig.name[i])
		_cauldronConfig[i].quality = i - 1
		
	end
	_trumpEquipData = {}
	for i = 1, table.getCount(_trumpConfig.req_lev) do
		_trumpEquipData[i] = {}
		_trumpEquipData[i].reqLev = _trumpConfig.req_lev[i]
		--        _trumpEquipData[i].idx = i - 1
	end
	
	
	TrumpManager.SetTrumpBagData(data.trump_bag)
	TrumpManager.SetTrumpEquipData(data.trump_equip)
	TrumpManager.SetMainTrumpId(data.trump_id)
	
	
end

function TrumpManager.GetTrumpRefineConfig(id, level)
	local index = id .. "_" .. level
	return _trumpRefineConfig[index]
end

function TrumpManager.GetCauldronConfig()
	return _cauldronConfig
end

function TrumpManager.UpdateTrumpCoin(coin)
	_trumpCoin = coin
	MessageManager.Dispatch(TrumpManager, TrumpManager.TRUMPCOINCHANGE)
end

function TrumpManager.GetTrumpExpConfigByQcAndLv(quality, level)
	local index = quality .. "_" .. level
	return _trumpExpConfig[index]
end

function TrumpManager.GetTrumpCoin()
	return _trumpCoin
end

function TrumpManager.SetCollectAreaData(data)
	if(data) then
		_trumpCollectAreaData = {}
		for i = 1, table.getCount(data) do
			if(_trumpCollectAreaData[i] == nil) then
				_trumpCollectAreaData[i] = TrumpInfo:New(data[i])
			end
		end
	end
end

function TrumpManager.GetCollectAreaData()
	return _trumpCollectAreaData
end

function TrumpManager.SetNextQc(qc)
	_nextQc = qc
	_selectQc = qc
end

function TrumpManager.GetNextQc()
	return _nextQc
end

function TrumpManager.SetQcList(qcl)
	_activeQcList = qcl
end

function TrumpManager.GetQcList(qcl)
	return _activeQcList
end

function TrumpManager.SetTrumpBagData(data)
	if(data) then
		_trumpBagData = {}
		for i = 1, table.getCount(data) do
			if(data[i].st == ProductManager.ST_TYPE_IN_TRUMPBAG) then
				if(_trumpBagData[data[i].idx + 1] == nil) then
					_trumpBagData[data[i].idx + 1] = {}
				end
				_trumpBagData[data[i].idx + 1].info = TrumpInfo:New(data[i])
			end
		end
	end
	--    if data == nil then
	--        data = { };
	--    end
	--    TrumpManager._trumpBagContainer:InitDatas(data, "idx");
end

function TrumpManager.GetTrumpBagData()
	return _trumpBagData
end

-- function TrumpManager.GetTrumpBagDataBySort()
--    local data = {}
--    return _trumpBagData
-- end
function TrumpManager.SetTrumpEquipData(data)
	if(data) then
		for i = 1, table.getCount(data) do
			if(data[i].st == ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG) then
				if(_trumpEquipData[data[i].idx + 1] ~= nil) then
					_trumpEquipData[data[i].idx + 1].info = TrumpInfo:New(data[i])
				end
			end
		end
		--    if data then
		--        TrumpManager._trumpEquipContainer:InitDatas(data, "idx");
		--    end
		--    end
	end
end

function TrumpManager.GetTrumpEquipData()
	return _trumpEquipData
end

function TrumpManager.SetSelectQc(qc)
	_selectQc = qc
end

function TrumpManager.SetCollectQc(qc)
	_collectQc = qc
end

function TrumpManager.GetCollectQc()
	return _collectQc
end

function TrumpManager.GetTrumpConfig()
	return _trumpConfig
end

-- 处理法宝容器改变  {"m":[{"st":3,"pt":"10100354","id":"102591","idx":0},{"st":4,"pt":"10100354","id":"0","idx":0}]}
function TrumpManager.MoveTrump(data)
	local item1 = {}
	local item2 = {}
	if(data[1].st == ProductManager.ST_TYPE_IN_TRUMPBAG and data[2].st == ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG) then
		item1 = data[1]
		item2 = data[2]
		TrumpManager.SwapInfo(_trumpBagData, _trumpEquipData, item2, item1)
	elseif(data[1].st == ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG and data[2].st == ProductManager.ST_TYPE_IN_TRUMPBAG) then
		item1 = data[2]
		item2 = data[1]
		TrumpManager.SwapInfo(_trumpBagData, _trumpEquipData, item2, item1)
	else
		
	end
end

function TrumpManager.SwapInfo(c1, c2, data1, data2)
	local other_container_key = data1.idx;
	local self_key = data2.idx;
	
	local item1 = c2[data1.idx + 1]
	local item2 = c1[data2.idx + 1]
	
	local change1 = nil
	local change2 = nil
	if(item1 and item1.info) then
		change1 = item1.info.baseData
		change1.idx = data2.idx;
		change1.st = data2.st;
		change1.pt = data2.pt;
		change1.id = data2.id;
		if change1.id == 0 then
			change1 = nil;
		end
	end
	
	if(item2 and item2.info) then
		change2 = item2.info.baseData
		change2.idx = data1.idx;
		change2.st = data1.st;
		change2.pt = data1.pt;
		change2.id = data1.id;
		if change2.id == 0 then
			change2 = nil;
		end
	end
	
	if(c2[data1.idx + 1] == nil) then
		c2[data1.idx + 1] = {}
	end
	
	if(c1[data2.idx + 1] == nil) then
		c1[data2.idx + 1] = {}
	end
	
	if(change2) then
		c2[data1.idx + 1].info = TrumpInfo:New(change2)
	else
		c2[data1.idx + 1].info = nil
	end
	
	if(change1) then
		c1[data2.idx + 1].info = TrumpInfo:New(change1)
	else
		c1[data2.idx + 1].info = nil
	end
end



-- 处理本身发生改变的法宝
function TrumpManager.ChangeTrump(data)
	for i, v in ipairs(data) do
		if(data[i].st == ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG) then
			if(data[i].am == 0) then
				_trumpEquipData[data[i].idx + 1].info = nil
			else
				_trumpEquipData[data[i].idx + 1].info = TrumpInfo:New(data[i])
			end
		elseif(data[i].st == ProductManager.ST_TYPE_IN_TRUMPBAG) then
			if(data[i].am == 0) then
				_trumpBagData[data[i].idx + 1].info = nil
			else
				_trumpBagData[data[i].idx + 1].info = TrumpInfo:New(data[i])
			end
		end
	end
end

-- 处理添加的法宝
function TrumpManager.AddTrump(data)
	if(data) then
		for i, v in ipairs(data) do
			if(data[i].st == ProductManager.ST_TYPE_IN_EQUIPBAG) then
				if(_trumpEquipData[data[i].idx + 1] ~= nil) then
					_trumpEquipData[data[i].idx + 1].info = TrumpInfo:New(data[i])
				end
			elseif(data[i].st == ProductManager.ST_TYPE_IN_TRUMPBAG) then
				if(_trumpBagData[data[i].idx + 1] == nil) then
					_trumpBagData[data[i].idx + 1] = {}
				end
				
				_trumpBagData[data[i].idx + 1].info = TrumpInfo:New(data[i])
			end
		end
	end
end

function TrumpManager.GetTrumpByQc(qc)
	local result = {}
	for k, v in pairs(_trumpBagData) do
		if(v.info and v.info.configData.quality <= qc) then
			table.insert(result, v)
		end
	end
	return result
end

function TrumpManager.GetTrumpEquipEmptyPos()
	local index = - 1
	for k, v in ipairs(_trumpEquipData) do
		if(v.info == nil) then
			index = k - 1
			break
		end
	end
	return index
end

function TrumpManager.GetTrumpBagEmptyPos()
	local index = - 1
	for i = 1, TrumpManager.TRUMPBAGMAXCOUNT do
		if(_trumpBagData[i] == nil or _trumpBagData[i].info == nil) then
			index = i - 1
			break
		end
	end
	return index
end

function TrumpManager.GetFirstTrumpData()
	for k, v in ipairs(_trumpEquipData) do
		if(v.info ~= nil) then
			return v
		end
	end
	return nil
end

function TrumpManager.GetTrumpEquipDataBySId(id)
	-- if(not isClone) then isClone = true end
	for k, v in ipairs(_trumpEquipData) do
		if(v.info and v.info.id == id) then
			-- if(isClone) then
			-- 	return ConfigManager.Clone(v)
			-- else
			return v
			-- end
		end
	end
	
	return nil
end

function TrumpManager.SetMainTrumpId(id)
	_mainTrumpId = id
end

function TrumpManager.GetMainTrumpId()
	return _mainTrumpId
end

function TrumpManager.GetMainTrumpData()
	if(_mainTrumpId) then
		for k, v in ipairs(_trumpEquipData) do
			if(v.info and v.info.id == _mainTrumpId) then
				return v
			end
		end
	end
	
	return nil
end

function TrumpManager.GetAllAttrs()
	local baseAttrInfo = BaseAdvanceAttrInfo:New()
	for k, v in ipairs(_trumpEquipData) do
		if(v.info) then
			local p = v.info:GetAllProperty()
			for k1, v1 in pairs(baseAttrInfo) do
				if(p[k1] ~= nil) then
					baseAttrInfo[k1] = baseAttrInfo[k1] + p[k1]
				end
			end
		end
	end
	return baseAttrInfo
end
