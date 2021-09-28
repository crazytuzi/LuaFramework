WingManager = {};
require "Core.Info.WingInfo"
require "Core.Info.BaseAttrInfo"
WingManager.WINGMAXLEVEL = 10
WingManager.WINGMAXRANK = 10
WingManager.SHOWWINGLEVEL = 5
local _wingData = nil
local _curDressWingData = nil
local _wingConfig = nil
local _wingAdvanceInfo = nil
local _wingFashionConfigConfig = nil
local _wingFashionData = nil
local insert = table.insert
local _isUpdateWingAttr = false
local _allFashionAttr = nil
local _hadShow = false
WingManager.WingState =
{
	NotActive = 0,
	OverTime = 1,
	HadActive = 2
}

local _WingState = WingManager.WingState
function WingManager.Init(data, career)
	
	_hadShow = false
	_isUpdateWingAttr = false
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetFirstWing, WingManager.GetFirstWing);
	_wingData = nil
	_curDressWingData = nil
	_allFashionAttr = BaseAttrInfo:New()
	_wingFashionConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_WING_FASHION)
	
	_wingConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_WING_ATTR)
	
	if(data.id ~= 0) then
		_isUpdateWingAttr = true
		_wingData = WingInfo:New(data)
	end
	WingManager.SetUseWing(data.wid)
	
	WingManager._InitPreviewData(career, data.l)
	-- WingManager.InitWingMaxPower()	
end

function WingManager.GetHadShow()
	return _hadShow	
end

function WingManager.SetHadShow(v)
	_hadShow = v
end

function WingManager.GetShowRenewWingData()
	for k, v in ipairs(_wingFashionData) do
		if(v.is_hint == true and v.state == _WingState.OverTime) then
			_hadShow = true
			return v			
		end
	end
end

function WingManager.Dispose()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetFirstWing, WingManager.GetFirstWing);
end

function WingManager.SetUseWing(id)
	if(id ~= 0) then
		_curDressWingData = WingManager.GetFashionById(id)
	else
		_curDressWingData = nil
	end
end

function WingManager.GetCurDressWingId()
	return WingManager._curDressWingId
end

function WingManager.GetFirstWing(cmd, data)
	
	if(data.errCode == nil) then
		if data.id ~= 0 then
			_wingData = WingInfo:New(data)
		end
		WingManager.SetUseWing(data.wid)
		PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Wing)
	end
	
end

function WingManager.UpdateWing(data)
	local oldWingId = _wingData.id
	if(_wingData and _wingData.id == data.id and _wingData.lev == data.level) then
		_wingData.curExp = data.exp
	else
		_isUpdateWingAttr = true
		_wingData = WingInfo:New(data)
		PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Wing)
		ModuleManager.SendNotification(WingNotes.SHOW_WINGPANELEFFECT)		
	end
	
	--    if (oldWingId ~= data.id) then
	--        ModuleManager.SendNotification(WingNotes.OPEN_WINGADVANCESUCCEEDPANEL)
	--    end
end

function WingManager.GetWingConfigById(id, level)
	local index = id .. "_" .. level
	
	return _wingConfig[index]
end

--career:职业 l：初始化数据的列表 只有激活或激活过的有这个属性
function WingManager._InitPreviewData(career, l)
	_wingFashionData = {}
	local ids = {}
	for k, v in pairs(_wingFashionConfig) do
		if(v.career == career or v.career == 0) then
			
			local item = {}
			--ConfigManager.copyTo(v,item)
			setmetatable(item, {__index = v})
			item.power = CalculatePower(v, true)
			item.attr = BaseAttrInfo:New()
			item.attr:Init(v)
			item.state = _WingState.NotActive
			item.t = 0
			insert(_wingFashionData, item)
			ids[item.id] = #_wingFashionData
		end
	end
	
	if(l) then
		for k, v in ipairs(l) do				
			local item = _wingFashionData[ids[v.id]]	
			if(item.type == 1) then
				--成长类的翅膀有数据就标识已经激活
				item.state = _WingState.HadActive
			elseif item.type == 0 then
				--时装类的翅膀得按照时间来判断 如果时间为0的话就是永久激活
				if(v.t == 0) then
					item.state = _WingState.HadActive
				else					
					local t = GetTime()
					if(v.t > t) then
						item.state = _WingState.HadActive
					else
						item.state = _WingState.OverTime
					end
				end				
			end		
			item.t = v.t			
			-- _wingFashionData[ids[v.id]].state = v.state						
		end
	end
	
	WingManager.SortWing()
	_isUpdateWingAttr = true
end

--state:状态 0未激活 ,1已过期,2已激活
function WingManager.SortWing()
	
	table.sort(_wingFashionData, function(a, b)	
		local tempA = 0
		local tempB = 0
		
		tempA =(a.state ~= _WingState.HadActive) and 1 or 0
		tempB =(b.state ~= _WingState.HadActive) and 1 or 0
		
		local result = false
		if(tempA > tempB) then --a为未激活 ,b为激活			 
			result =((a.active_cost ~= 0) and BackpackDataManager.GetProductTotalNumBySpid(a.active_cost) > 0)
		elseif(tempA < tempB) then--a为激活,b为未激活		
			result = not((b.active_cost ~= 0) and BackpackDataManager.GetProductTotalNumBySpid(b.active_cost) > 0)
		else	--状态相同,只看id
			if(tempA > 0) then
				local resultA =((a.active_cost ~= 0) and BackpackDataManager.GetProductTotalNumBySpid(a.active_cost) > 0) and 1 or 0
				local resultB =((b.active_cost ~= 0) and BackpackDataManager.GetProductTotalNumBySpid(b.active_cost) > 0) and 1 or 0
				if(resultA == resultB) then
					result = a.order < b.order
				else
					result =(resultA - resultB) > 0
				end	
			else
				result = a.order < b.order
			end
			
		end
		-- log(tempA .. ":" .. tempB)
		-- log(a.id .. ":" .. b.id .. "状态:" .. a.state .. ":" .. b.state .. "对比结果:" .. tostring(result))
		return result
	end)	
	
end

function WingManager.SetWingTime(id, t)
	for k, v in ipairs(_wingFashionData) do
		if(v.id == id) then
			v.t = t
			if(v.t == 0) then
				v.state = _WingState.HadActive
			else				
				local t = GetTime()
				if(v.t > t) then
					v.state = _WingState.HadActive
				else
					v.state = _WingState.OverTime
				end
			end				
		end
	end
	WingManager.SortWing()
	_isUpdateWingAttr = true
	PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.WingFashion)
end

function WingManager.SetWingState(id, state)
	for k, v in ipairs(_wingFashionData) do
		if(v.id == id) then
			v.state = state
		end
	end
	WingManager.SortWing()
	_isUpdateWingAttr = true
	PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.WingFashion)
end

-- function WingManager.InitWingMaxPower()
-- 	_wingAdvanceInfo = {}
-- 	for k, v in pairs(_wingConfig) do
-- 		if(v.lev == WingManager.WINGMAXLEVEL or
-- 		(v.rank < WingManager.WINGMAXRANK and v.lev ==(WingManager.WINGMAXLEVEL - 1))) then
-- 			if(_wingAdvanceInfo[v.career] == nil) then
-- 				_wingAdvanceInfo[v.career] = {}
-- 			end
-- 			_wingAdvanceInfo[v.career] [v.rank] = v
-- 			_wingAdvanceInfo[v.career] [v.rank].power = CalculatePower(v)
-- 		end
-- 	end
-- end
-- 通过职业获取所有进阶展示数据
-- function WingManager.GetConfigByKind(kindId)
-- 	return _wingAdvanceInfo[kindId]
-- end
function WingManager.GetFashionById(id)
	if(_wingFashionConfig == nil) then
		_wingFashionConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_WING_FASHION)
	end
	return _wingFashionConfig[id]
end

--根据职业返回对应的翅膀表
function WingManager.GetFashionByCareer()
	return _wingFashionData
end

function WingManager.GetFashionDataById(id)
	for k, v in ipairs(_wingFashionData) do
		if(v.id == id) then
			return v
		end
	end
end

function WingManager.GetNextStarConfig(id)
	
	local tempId
	local maxLevel = WingManager.WINGMAXLEVEL
	if(_wingData.rank ~= WingManager.WINGMAXRANK) then
		maxLevel = WingManager.WINGMAXLEVEL - 1
	end
	
	if(_wingData.lev >= maxLevel) then
		id = id + 1
		tempId = id .. "_" .. 0
	else
		tempId = id .. "_" .. tostring(_wingData.lev + 1)
	end
	return _wingConfig[tempId]
end

-- 用于获取当前翅膀属性的数据
function WingManager.GetCurrentWingData()
	return _wingData
end

-- -- 用于获取形象的数据
-- function WingManager.GetDressWingData()
-- 	return _curDressWingData
-- end
-- 用于获取当前实际穿着的翅膀的数据
function WingManager.GetCurDressWingData()
	return _curDressWingData
end

function WingManager.GetCurrentWingStar()
	return _wingData and _wingData.lev or 0
end

function WingManager.CanWingAdvance()
	
	if(not SystemManager.IsOpen(SystemConst.Id.WingUpdate)) then
		return false		
	end
	
	if(_wingData) then
		if(_wingData.rank == WingManager.WINGMAXRANK and _wingData.lev == WingManager.WINGMAXLEVEL) then
			return false
		else
			return BackpackDataManager.GetProductTotalNumBySpid(_wingData.needItem.itemId) >= _wingData.needItem.itemCount
		end
	end
	
	return false
end

function WingManager.GetAllFashionAttr()
	if(_isUpdateWingAttr) then
		_isUpdateWingAttr = false
		_allFashionAttr:Reset()
		for k, v in pairs(_wingFashionData) do
			if(v.state == _WingState.HadActive) then
				_allFashionAttr:Add(v.attr)
			end
		end
	end
	
	return _allFashionAttr
end 