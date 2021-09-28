NewEquipStrongManager = {}
require "Core.Info.EquipNewStrongInfo"
require "Core.Info.ProductAttrInfo"

NewEquipStrongManager.MaxStrongLevel = 15
NewEquipStrongManager.ZhufushiAdd = {{[352001] = 0, [352002] = 0, [352003] = 0}}

local _promoteRateConfig = {}
local _promotePlusConfig = {}
local _promotePositionConfig = {}
local _equipmentStrongRatioConfig = {}
local _promotePlusData = {}
local _promoteRateData = {}
local _promotePositionData = {}
local _equipmentStrongRatioData = {}
local _zhufushi = {} --祝福石数据
local _lastPlusIndex = 0
local _equipStrongData = {}
local _plusId = 0
local _promoteEffectConfig = {}
local _promoteColor = {}
local _isShowNotice = true
--data 装备强化相关数据  plus_id现有套装Id
function NewEquipStrongManager.Init(data, plus_id)
	_autoConfirm = false
	_isShowNotice = true
	_zhufushi = {}
	_zhufushi[1] = ProductManager.GetProductById(352001)
	_zhufushi[2] = ProductManager.GetProductById(352002)
	_zhufushi[3] = ProductManager.GetProductById(352003)
	NewEquipStrongManager.ZhufushiAdd[352001] = tonumber(_zhufushi[1].fun_para[1])
	NewEquipStrongManager.ZhufushiAdd[352002] = tonumber(_zhufushi[2].fun_para[1])
	NewEquipStrongManager.ZhufushiAdd[352003] = tonumber(_zhufushi[3].fun_para[1])
	
	
	_promoteRateConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PROMOTE_RATE)
	_promotePlusConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PROMOTE_PLUS)
	_promotePositionConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PROMOTE_POSITION)
	_equipmentStrongRatioConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_EQUIPMENT_PROMOTE_RATIO)
	_promoteEffectConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PROMOTE_EFFECT)
	_promoteColor = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PROMOTE_COLOR)
	
	_promotePlusData = {}
	for k, v in ipairs(_promotePlusConfig) do
		v = ConfigManager.TransformConfig(v)
		_promotePlusData[k] = {}
		_promotePlusData[k].id = v.id
		_promotePlusData[k].item_num = v.item_num
		_promotePlusData[k].min_lev = v.min_lev
		_promotePlusData[k].desc = v.desc		
		_promotePlusData[k].open_desc = v.open_desc
		_promotePlusData[k].attr = EquipNewStrongInfo:New()
		_promotePlusData[k].attr:Init(v)
	end
	_lastPlusIndex = table.getCount(_promotePlusData)
	_promoteRateData = {}
	local count = table.getCount(_promoteRateConfig)
	
	for k = 0, count - 1 do	
		local v = _promoteRateConfig[k]	
		_promoteRateData[k] = {}
		setmetatable(_promoteRateData[k], {__index = v})
		-- _promoteRateData[k].id = v.id
		-- _promoteRateData[k].attribute_per = v.attribute_per
		-- _promoteRateData[k].rate = v.rate
		-- _promoteRateData[k].lucky_level = v.lucky_level
		-- _promoteRateData[k].lucky_limit = v.lucky_limit
		-- _promoteRateData[k].promote_lev = v.promote_lev
		if(v.protect_id ~= 0) then
			_promoteRateData[k].protectItem = ProductManager.GetProductById(v.protect_id)
		end
		
		if(v.promote_res ~= "") then
			local temp = ConfigSplit(v.promote_res)
			_promoteRateData[k].promoteItem = ProductManager.GetProductById(tonumber(temp[1]))
			_promoteRateData[k].promoteItemCount = tonumber(temp[2])
		else
			_promoteRateData[k].promoteItemCount = 0
		end
		
	end
	
	
	NewEquipStrongManager.InitEquipStrongData(data)
	NewEquipStrongManager.SetPlusId(plus_id)
end

function NewEquipStrongManager.GetZhufuShi()
	return _zhufushi
end

function NewEquipStrongManager.GetZhufushiByIndex(index)
	return _zhufushi[index]
end

function NewEquipStrongManager.HasZhufushi(index)
	return BackpackDataManager.GetProductTotalNumBySpid(_zhufushi[index].id) > 0
end

function NewEquipStrongManager.InitEquipStrongData(data)
	_equipStrongData = {}
	for k, v in ipairs(data) do
		NewEquipStrongManager._SetOneEquipStrongData(v)		
	end
end

-- idx:装备部位 0到7
-- plv:强化（新）等级
-- plck:幸运值
-- plck_id:幸运值上限对应的id
-- plus_id:套装属性id
function NewEquipStrongManager.SetOneEquipStrongData(data)
	NewEquipStrongManager._SetOneEquipStrongData(data)	
	NewEquipStrongManager.SetPlusId(data.plus_id)
end

--客户端存储从1开始
function NewEquipStrongManager._SetOneEquipStrongData(data)
	if(_equipStrongData[data.idx + 1] == nil) then
		_equipStrongData[data.idx + 1] = {}
	end
	_equipStrongData[data.idx + 1].level = data.plv
	_equipStrongData[data.idx + 1].luck = data.plck
	_equipStrongData[data.idx + 1].luckId = data.plck_id
end

function NewEquipStrongManager.SetPlusId(plus_id)
	_plusId = plus_id
end

function NewEquipStrongManager.GetPlusId()
	return _plusId
end

function NewEquipStrongManager.GetPlusDataById(id)
	return _promotePlusData[id]
end

function NewEquipStrongManager.GetEquipStrongDataByIdx(idx)
	return _equipStrongData[idx]
end

--根据职业和加成等级
function NewEquipStrongManager.GetPromotePositionData(career, level)
	local index = career .. "_" .. level
	if(_promotePositionData[index] == nil) then
		_promotePositionData[index] = ProductAttrInfo:New()
		_promotePositionData[index]:Init(_promotePositionConfig[index])
	end
	return _promotePositionData[index]
end

--根据品质和部位获取强化加成比例
function NewEquipStrongManager.GetEquipmentStrongRatioData(quality, kind)
	local index = quality .. "_" .. kind
	
	if(_equipmentStrongRatioData[index] == nil) then
		_equipmentStrongRatioData[index] = ProductAttrInfo:New()
		_equipmentStrongRatioData[index]:Init(_equipmentStrongRatioConfig[index])
		
		for k, v in pairs(_equipmentStrongRatioData[index]) do			
			_equipmentStrongRatioData[index] [k] = _equipmentStrongRatioData[index] [k] * 0.001
		end
	end
	
	return _equipmentStrongRatioData[index]
end

function NewEquipStrongManager.GetPromoteRateConfigByLevel(level)
	return _promoteRateData[level]
end

--获取当前套装属性
function NewEquipStrongManager.GetCurPlusAttr()	
	return NewEquipStrongManager.GetPlusAttrById(_plusId)
end

--根据等级获取套装属性
function NewEquipStrongManager.GetPlusAttrById(id)
	if(id == 0) then
		return {}
	end
	return NewEquipStrongManager.GetPlusDataById(id).attr
end

function NewEquipStrongManager.IsLastPlusId(id)
	return _lastPlusIndex == id
end

function NewEquipStrongManager.GetAllSuiteCountByLevel(level)
	local count = 0
	for k, v in ipairs(_equipStrongData) do
		if(v.level >= level) then
			count = count + 1
		end
	end	
	return count
end


--根据位置和强化等级获取加成属性(界面显示数据)
function NewEquipStrongManager.GetEquipStrongAttrByIdx(idx)
	local equipInfo = EquipDataManager.GetProductByIdx(idx)
	if(equipInfo) then
		local strongInfo = NewEquipStrongManager.GetEquipStrongDataByIdx(idx + 1)	
		local curRate = NewEquipStrongManager.GetPromoteRateConfigByLevel(strongInfo.level)
		local luckInfo = NewEquipStrongManager.GetPromoteRateConfigByLevel(strongInfo.luckId)	
		local luckInfoNext = NewEquipStrongManager.GetPromoteRateConfigByLevel(strongInfo.luckId + 1)	
		
		
		local nextRate
		if(luckInfo.lucky_limit > 0 and strongInfo.luck == luckInfo.lucky_limit) then
			nextRate = luckInfoNext
		else
			nextRate = NewEquipStrongManager.GetPromoteRateConfigByLevel(strongInfo.level + 1)
		end
		
		local career = equipInfo:GetBaseConfig().career
		local quality = equipInfo:GetBaseConfig().quality
		local kind = equipInfo:GetBaseConfig().kind
		
		local property = equipInfo:GetBaseAttr():GetPropertyAndDes()
		local tempPromotePositionData1 = NewEquipStrongManager.GetPromotePositionData(career, curRate.promote_lev)	
		local tempEquipStrongData = NewEquipStrongManager.GetEquipmentStrongRatioData(quality, kind)
		
		for k, v in ipairs(property) do				
			v.curAdd = math.floor((v.property * curRate.attribute_per / 100) + tempPromotePositionData1[v.key] * tempEquipStrongData[v.key])
			if(nextRate) then
				local tempPromotePositionData2 = NewEquipStrongManager.GetPromotePositionData(career, nextRate.promote_lev)
				v.nextAdd = math.floor((v.property * nextRate.attribute_per / 100) + tempPromotePositionData2[v.key] * tempEquipStrongData[v.key])
			end			
		end		
		return property
	end
	return {}
end

function NewEquipStrongManager.GetEquipStrongAttrByIdx1(idx)
	local equipInfo = EquipDataManager.GetProductByIdx(idx)
	
	if(equipInfo) then
		local strongInfo = NewEquipStrongManager.GetEquipStrongDataByIdx(idx + 1)
		local curRate = NewEquipStrongManager.GetPromoteRateConfigByLevel(strongInfo.level)		
		local career = equipInfo:GetBaseConfig().career
		local quality = equipInfo:GetBaseConfig().quality
		local kind = equipInfo:GetBaseConfig().kind
		local tempPromotePositionData1 = NewEquipStrongManager.GetPromotePositionData(career, curRate.promote_lev)	
		local tempEquipStrongData = NewEquipStrongManager.GetEquipmentStrongRatioData(quality, kind)
		local result = ProductAttrInfo:New()
		result:Init(equipInfo:GetBaseAttr())
		
		for k, v in pairs(result) do
			if(result[k] ~= 0) then
				result[k] = math.floor(result[k] * curRate.attribute_per / 100 + tempPromotePositionData1[k] * tempEquipStrongData[k])
			end
		end
		-- result:Mul(curRate.attribute_per / 100)
		return result		
	end		
	return nil	
end

--根据productInfo获取附加属性
function NewEquipStrongManager.GetEquipAttrByInfo(info)	
	
	local kind = info:GetBaseConfig().kind
	local strongInfo = NewEquipStrongManager.GetEquipStrongDataByIdx(kind)
	local curRate = NewEquipStrongManager.GetPromoteRateConfigByLevel(strongInfo.level)		
	local career = info:GetBaseConfig().career
	local quality = info:GetBaseConfig().quality
	
	local tempPromotePositionData1 = NewEquipStrongManager.GetPromotePositionData(career, curRate.promote_lev)	
	local tempEquipStrongData = NewEquipStrongManager.GetEquipmentStrongRatioData(quality, kind)
	local result = ProductAttrInfo:New()
	result:Init(info:GetBaseAttr())
	
	for k, v in pairs(result) do
		if(result[k] ~= 0) then
			result[k] = math.floor(result[k] * curRate.attribute_per / 100 + tempPromotePositionData1[k] * tempEquipStrongData[k])
		end
	end
	return result		
end

function NewEquipStrongManager.GetAllEquipStrongAttr()
	local result = ProductAttrInfo:New()
	for i = 1, 8 do
		local attr = NewEquipStrongManager.GetEquipStrongAttrByIdx1(i - 1)
		if(attr) then
			result:Add(attr)
		end
	end
	return result
end

function NewEquipStrongManager.GetAllStrongLevel()
	local level = 0
	for k, v in ipairs(_equipStrongData) do
		level = level + v.level
	end
	return level
end

function NewEquipStrongManager.GetCanStrongByIdx(idx)
	local eq = EquipDataManager.GetProductByKind(idx);
	if eq then
		local strongInfo = NewEquipStrongManager.GetEquipStrongDataByIdx(idx)	
		local curRate = NewEquipStrongManager.GetPromoteRateConfigByLevel(strongInfo.level)
		
		if(curRate.promoteItem) then
			return BackpackDataManager.GetProductTotalNumBySpid(curRate.promoteItem.id) >= curRate.promoteItemCount
		end		
	end
	return false;
end

function NewEquipStrongManager.GetPromoteEffectByName(name)
	return _promoteEffectConfig[name]
end

function NewEquipStrongManager.GetPromoteColorByLevel(level)
	return _promoteColor[level]
end

function NewEquipStrongManager.GetAutoConfirm()
	return _autoConfirm
end

function NewEquipStrongManager.SetAutoConfirm(v)
	_autoConfirm = v
end

function NewEquipStrongManager.GetIsShowNotice()
	return _isShowNotice
end

function NewEquipStrongManager.SetIsShowNotice(v)
	_isShowNotice = v
end 