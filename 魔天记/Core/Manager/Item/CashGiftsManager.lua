CashGiftsManager = {}
local _cashGiftConfig = nil
local _todayConfig = nil
local _chargeTime = nil
function CashGiftsManager.Init()
	_cashGiftConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CASHGIFTS)
end

function CashGiftsManager.SetCashGiftsInfo(data)
	if(data) then
		_chargeTime = {}
		for k, v in pairs(data) do
			_chargeTime[v.rid] = v.time
		end
	end
end

--9999标识已购买
function CashGiftsManager.GetTimeByChargeId(rid)
	return _chargeTime and _chargeTime[rid] or 9999
end

function CashGiftsManager.GetTodayConfig()
	local _insert = table.insert
	local config = TimeLimitActManager.GetAct(SystemConst.Id.CashGift)
	if(_todayConfig) then		
		if(_todayConfig.id ~= config.id) then
			_todayConfig = nil
		end
	end
	
	if(_todayConfig == nil) then
		_todayConfig = {}
		_todayConfig.rechargeItem = {}
		setmetatable(_todayConfig, {__index = config})
		local count = 0
		for k, v in ipairs(_cashGiftConfig) do
			if(v.yunying_id == config.id) then
				count = count + 1
				local item = {}
				setmetatable(item, {__index = v})
				local temp = ConfigSplit(v.show)
				item.showItem = {}
				setmetatable(item.showItem, {__index = ProductManager.GetProductById(tonumber(temp[1]))})
				item.showItem.num =	tonumber(temp[2])
				_insert(_todayConfig.rechargeItem, item)
			end
			
			if(count >= 3) then
				break
			end
		end
	end
	
	return _todayConfig
end 