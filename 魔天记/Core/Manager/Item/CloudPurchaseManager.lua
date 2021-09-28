CloudPurchaseManager = {}

local _curMyBuyCount = 0
local _curAllBuyCount = 0
local _state = 0
local _buyRecorders = nil --所有人的购买记录
local _rewardRecorders = nil --获奖的人的记录
local _insert = table.insert
local _rewardState = 0--领奖状态
local _hadRedPoint = true
local _cloudPurchaseConfig = nil
local _todayConfig = nil
CloudPurchaseManager.RedPointChange = "RedPointChange"
function CloudPurchaseManager.Init()
	_todayConfig = nil
	_hadRedPoint = true
	_cloudPurchaseConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CLOUDPURCHASE)
end

function CloudPurchaseManager.SetCloudPurchaseInfo(data)
	if(data) then
		_curMyBuyCount = data.t
		_curAllBuyCount = data.tt
		_state = data.s
		_buyRecorders = {}
		local _insert = table.insert
		for k, v in ipairs(data.l) do			
			_insert(_buyRecorders, CloudPurchaseManager.HandleBuyRecoder(v))
		end
		_rewardRecorders = {}
		for k, v in ipairs(data.l2) do			
			_insert(_rewardRecorders, CloudPurchaseManager.HandleRewardRecoder(v))
		end
		
		_rewardState = data.rs
	end
end

function CloudPurchaseManager.HandleBuyRecoder(v)
	return LanguageMgr.Get("CloudPurchasePanel/buyRecorder", {name = v.name, num = v.t})
end

function CloudPurchaseManager.HandleBuyRecoders(data)
	if(data and #data > 0) then
		_buyRecorders = {}
		local _insert = table.insert
		for k, v in ipairs(data) do			
			_insert(_buyRecorders, CloudPurchaseManager.HandleBuyRecoder(v))
		end
	end
end

function CloudPurchaseManager.HandleRewardRecoder(v)
	return LanguageMgr.Get("CloudPurchasePanel/rewardRecorder", {name = v.name, num = v.t, item = CloudPurchaseManager.GetCareerConfig(v.k).name})	
end

-- function CloudPurchaseManager.AddBuyRecorder(data)
-- 	if(data) then
-- 		if(_buyRecorders == nil) then
-- 			_buyRecorders = {}
-- 		end
-- 		_insert(_buyRecorders, data)
-- 	end	
-- end
function CloudPurchaseManager.GetBuyRecorders()
	return _buyRecorders or {}
end

function CloudPurchaseManager.GetRewardRecorders()
	return _rewardRecorders	
end

function CloudPurchaseManager.SetRewardState(v)
	_rewardState = v
end

function CloudPurchaseManager.GetRewardState()
	return _rewardState
end

function CloudPurchaseManager.SetBuyCount(myBuyCount, allBuyCount)
	_curMyBuyCount = myBuyCount or _myBuyCount
	_curAllBuyCount = allBuyCount or _curAllBuyCount	
end

function CloudPurchaseManager.GetPurchaseState()
	return _state
end

function CloudPurchaseManager.GetRedPoint()
	return _hadRedPoint
end

function CloudPurchaseManager.SetRedPoint(v)
	_hadRedPoint = v
	MessageManager.Dispatch(CloudPurchaseManager,CloudPurchaseManager.RedPointChange)
end

function CloudPurchaseManager.GetAllBuyCount()
	return _curAllBuyCount
end

function CloudPurchaseManager.GetMyBuyCount()
	return _curMyBuyCount
end

function CloudPurchaseManager.GetTodayConfig()
	local kaifu = KaiFuManager.GetKaiFuHasDate()
	if(_todayConfig and _todayConfig.days ~= kaifu) then
		_todayConfig = nil
	end
	
	if(_todayConfig == nil) then
		local config = nil
		for k, v in ipairs(_cloudPurchaseConfig) do
			if(v.days == kaifu) then
				config = v
				break
			end
		end
		local _ConfigSplit = ConfigSplit
		
		if(config) then
			local _insert = table.insert
			_todayConfig = {}
			setmetatable(_todayConfig, {__index = config})
			_todayConfig.rewards = {}
			
			for k, v in ipairs(config.reward) do
				local temp = _ConfigSplit(v)			 
				local item = {}
				setmetatable(item, {__index = ProductManager.GetProductById(tonumber(temp[1]))})			
				item.num = tonumber(temp[2])
				_insert(_todayConfig.rewards, item)
			end
			
			_todayConfig.allcareerReward = {}
			local myCareer = PlayerManager.GetPlayerKind()
			for k, v in ipairs(config.career_award) do
				local temp = _ConfigSplit(v)
				local item = {}
				
				setmetatable(item, {__index = ProductManager.GetProductById(tonumber(temp[1]))})
				item.num = tonumber(temp[2])
				if(tonumber(temp[3]) == myCareer) then
					_todayConfig.careerReward = item
				end
				
				_todayConfig.allcareerReward[tonumber(temp[3])] = item
			end
			_todayConfig.yunyingConfig = TimeLimitActManager.GetAct(SystemConst.Id.CloudPurchase)
		end
	end
	return _todayConfig
end

function CloudPurchaseManager.GetCareerConfig(career)
	local config = CloudPurchaseManager.GetTodayConfig()	
	return _todayConfig and _todayConfig.allcareerReward[career] or nil
end 