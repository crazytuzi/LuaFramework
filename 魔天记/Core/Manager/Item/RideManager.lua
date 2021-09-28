require "Core.Info.RideInfo"
require "Core.Info.BaseAttrInfo"
require "Core.Info.RideBaseInfo"
RideManager = {}
local _rideConfig = nil
local _rideData = {}
local _currentRideId = - 1
local _isRideUse = false
local _rideFeedConfig = nil
local _rideFeedExpConfig = nil
--是否有坐骑过期
local _isRideExpired = false
local _expiredRideInfo = nil
local _isRideBecomeExpired = false
local _becomeExpiredRideInfo = nil
local _isUpdate = true
local _rideFeedData = nil
local _nextLevelFeedAttr = nil
local idAndIndex = nil
RideManager.RideUseState = "RideUseState"
RideManager.RideDownOrOn = "RideDownOrOn"
local remove = table.remove
-- data:[{id:坐骑id,st:1使用,rt：剩余时间毫秒 0表示永久},..]
function RideManager.Init(data, feed_data)
	_isRideUse = false
	_isRideExpired = false
	_isRideBecomeExpired = false
	_expiredRideInfo = nil
	_becomeExpiredRideInfo = nil
	_isUpdate = true
	_rideConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_RIDE)
	_rideFeedConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_RIDE_FEED)
	_rideFeedExpConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_RIDE_FEED_EXP)
	RideManager._InitRideData(data)	
	
	RideManager._SetFeedData(feed_data)
	-- RideManager._SetFeedData({lv = 1, exp = 50})	
end

function RideManager.UpdateFeedData(data)
	if(data) then
		if(data.lv == _rideFeedData.lev) then
			_rideFeedData.curExp = data.exp
		else
			RideManager._SetFeedData(data)
		end
	end
end

function RideManager.GetRideFeedMaterials()
	local mat = BackpackDataManager.GetProductsByTypes({7})
	if(#mat > 0) then
		local count = #mat		
		for i = count, 1, - 1 do			
			local item = _rideFeedExpConfig[mat[i].spId]
			
			if(item == nil) then
				remove(mat, i)
			else
				local ride = RideManager.GetRideDataById(item.ride_id)
				if(not ride.info:GetIsActivate()) then
					remove(mat, i)
				end
			end
		end
	end
	return mat
end

function RideManager.GetRideFeedExpConfigById(id )
	return _rideFeedExpConfig[id]
end


function RideManager._SetFeedData(data)
	_rideFeedData = nil
	_nextLevelFeedAttr = nil
	if(data) then
		local item = RideManager.GetRideFeedConfigByLevel(data.lv)		
		local nextItem = RideManager.GetRideFeedConfigByLevel(data.lv + 1)		
		if(item) then
			_rideFeedData = {}
			_rideFeedData.curExp = data.exp
			_rideFeedData.maxExp = item.feed_exp
			_rideFeedData.lev = data.lv
			_rideFeedData.attr = BaseAttrInfo:New()	
			_rideFeedData.attr:Init(item)
			
			if(nextItem) then
				_nextLevelFeedAttr = BaseAttrInfo:New()
				_nextLevelFeedAttr:Init(nextItem)
			end
			
			-- _rideFeedData.attr.phy_att = 0
			-- if(_nextLevelFeedAttr) then
			-- 	_nextLevelFeedAttr.phy_att = 0
			-- end
			-- local dmgType = PlayerManager.GetMyCareerDmgType()	
			-- if(dmgType == 1) then
			-- 	_rideFeedData.attr.mag_att = 0
			-- 	if(_nextLevelFeedAttr) then
			-- 		_nextLevelFeedAttr.mag_att = 0
			-- 	end
			-- else
			-- 	_rideFeedData.attr.phy_att = 0
			-- 	if(_nextLevelFeedAttr) then
			-- 		_nextLevelFeedAttr.phy_att = 0
			-- 	end
			-- end
		end
	end	
end

function RideManager.GetFeedData()
	return _rideFeedData
end

function RideManager.GetNextFeedAttr()
	return _nextLevelFeedAttr
end


function RideManager.SetIsRideExpired(v, ride)
	_isRideExpired = v
	_expiredRideInfo = ride
end

function RideManager.GetRideFeedConfigByLevel(lv)
	return _rideFeedConfig[lv]
end

function RideManager.GetExpiredRideInfo()
	return _expiredRideInfo
end

function RideManager.GetIsRideExpired()
	return _isRideExpired
end

function RideManager.SetIsRideBecomeExpired(v, ride)	
	_isRideBecomeExpired = v
	_becomeExpiredRideInfo = ride
end

function RideManager.GetIsRideBecomeExpired()
	return _isRideBecomeExpired
end

function RideManager.GetBecomeExpiredInfo()
	return _becomeExpiredRideInfo
end

function RideManager._InitRideData(data)
	local index = 1
	_rideData = {}
	for k, v in pairs(_rideConfig) do
		_rideData[index] = {}
		_rideData[index].info = RideInfo:New(v)
		if(data and table.getCount(data)) then
			for k1, v1 in ipairs(data) do
				if(v1.id == v.id) then
					_rideData[index].info:SetServerInfo(v1.st, v1.rt)
					
					if(_rideData[index].info.is_hint) then
						local leftTime = _rideData[index].info:GetTimeLimit()
						if(leftTime < 0) then
							RideManager.SetIsRideExpired(true, _rideData[index].info)						
						elseif leftTime < 1800000 and leftTime > 0 then
							RideManager.SetIsRideBecomeExpired(true, _rideData[index].info)
						end	
					end					
					
					if(v1.st == 1) then
						_currentRideId = v1.id
						RideManager.SetIsRideUse(true)
						
					end
				end
			end
		end
		
		index = index + 1
	end
	RideManager.SortRide()
end



function RideManager.GetRideDataById(id)	
	return _rideData[idAndIndex[id]]
	-- 	for k, v in ipairs(_rideData) do
	-- 		if(v.info.id == id) then		
	-- 		return v			
	-- 	end
	-- end
end


function RideManager.SortRide()
	if(_rideData and table.getCount(_rideData) > 0) then
		table.sort(_rideData, function(a, b)
			local tempA = 0
			local tempB = 0
			
			tempA =(a.info:GetIsActivate()) and 0 or 1
			tempB =(b.info:GetIsActivate()) and 0 or 1
			if(tempA > tempB) then--A为未激活,B激活
				result = BackpackDataManager.GetProductTotalNumBySpid(a.info.synthetic.itemId) >= a.info.synthetic.itemCount	
			elseif tempB > tempA then--B为未激活,A激活
				result = not(BackpackDataManager.GetProductTotalNumBySpid(b.info.synthetic.itemId) >= b.info.synthetic.itemCount)					
			else--A,B同状态
				--两个都是未激活
				if(tempA > 0) then
					local resultA =(BackpackDataManager.GetProductTotalNumBySpid(a.info.synthetic.itemId) >= a.info.synthetic.itemCount) and 1 or 0
					local resultB =(BackpackDataManager.GetProductTotalNumBySpid(b.info.synthetic.itemId) >= b.info.synthetic.itemCount) and 1 or 0
					if(resultA == resultB) then
						result = a.info.order < b.info.order
					else
						result =(resultA - resultB) > 0
					end	
				else
					result = a.info.order < b.info.order
				end				
			end
			return result
		end
		)
	end
	
	if(_currentRideId == - 1 and table.getCount(_rideData) > 0) then
		_currentRideId = _rideData[1].info.id
	end
	
	idAndIndex = {}
	for k, v in ipairs(_rideData) do
		idAndIndex[v.info.id] = k
	end
	
end

function RideManager.GetAllRideData()
	return _rideData
end

function RideManager.SetRideUsed(id)
	RideManager.SetIsRideUse(true)	
	for k, v in ipairs(_rideData) do
		v.info:SetIsUse(v.info.id == id)
	end	
end

function RideManager.SetRideActive(data)
	_isUpdate = true
	local rideData = RideManager.GetRideDataById(data.id)
	rideData.info:SetServerInfo(data.st, data.rt)	
end	

function RideManager.SetRideUnActivate(id)
	_isUpdate = true
	for k, v in ipairs(_rideData) do
		if(v.info.id == id) then
			if(v.info:GetIsUse()) then
				RideManager.SetIsRideUse(false)			
			end
			v.info:SetIsActivate(false)
			break
		end
	end
end

function RideManager.SetRideUnUsed()
	for k, v in ipairs(_rideData) do
		v.info:SetIsUse(false)
	end
	RideManager.SetIsRideUse(false)
	
end

local insert = table.insert
local allRideAttr
-- 获取所有可用坐骑的属性
function RideManager.GetAllRideProperty()
	
	if(_isUpdate) then
		_isUpdate = false
		local availableRide = {}
		if(table.getCount(_rideData) > 0) then
			for k, v in ipairs(_rideData) do
				if(v.info:GetIsActivate()) then
					insert(availableRide, v.info)
				end
			end
		end
		
		allRideAttr = RideBaseInfo:New()
		if(table.getCount(availableRide) > 0) then
			for k, v in ipairs(availableRide) do
				allRideAttr.hp_max = allRideAttr.hp_max + v.hp_max
				allRideAttr.phy_att = allRideAttr.phy_att + v.phy_att
				-- allRideAttr.mag_att = allRideAttr.mag_att + v.mag_att
				allRideAttr.phy_def = allRideAttr.phy_def + v.phy_def
				-- allRideAttr.mag_def = allRideAttr.mag_def + v.mag_def
				allRideAttr.hit = allRideAttr.hit + v.hit
				allRideAttr.eva = allRideAttr.eva + v.eva
				allRideAttr.crit = allRideAttr.crit + v.crit
				allRideAttr.tough = allRideAttr.tough + v.tough
				allRideAttr.fatal = allRideAttr.fatal + v.fatal
				allRideAttr.block = allRideAttr.block + v.block
				allRideAttr.exp_per = allRideAttr.exp_per + v.exp_per
				allRideAttr.dmg_rate = allRideAttr.dmg_rate + v.dmg_rate
			end
		end
	end
	return allRideAttr
end

function RideManager.SetAllRidePropertyUpdate(v)
	_isUpdate = v
end

function RideManager.GetRideFeedAttr()
	return _rideFeedData.attr
end

function RideManager.GetExpPer()
	return RideManager.GetAllRideProperty().exp_per
end

function RideManager.SetCurrentRideId(id)
	_currentRideId = id
end

function RideManager.ResetCurrentRideId()
	_currentRideId = - 1
	RideManager.SortRide()
end

function RideManager.GetCurrentRideId()
	return _currentRideId
end

function RideManager.GetCurrentRideData()
	for k, v in ipairs(_rideData) do
		if(v.info.id == _currentRideId) then
			return ConfigManager.Clone(v)
		end
	end
end

-- 是否坐骑激活
function RideManager.GetCanActive()
	for k, v in ipairs(_rideData) do
		if(v.info and v.info:GetCanActive()) then
			return true
		end
	end
	
	return false
end

function RideManager.GetIsRideUse()
	return _isRideUse
end

function RideManager.SetIsRideUse(v)
	_isRideUse = v	
	MessageManager.Dispatch(RideManager, RideManager.RideUseState, _isRideUse)
end



