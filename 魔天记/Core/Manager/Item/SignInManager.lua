SignInManager = {}
local signConfig = {}
local signData = {}
local signMonthData = {}
local weal = {}
local dailySignInData = {}
local resignExpendConfig = {}
local revertConfig = {};

SignInManager.canRevertAward = false;  -- 是否能找回奖励.

function SignInManager.Init()
	signMonthData = {}
	signData = {}
	signConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SIGNIN)
	resignExpendConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_RESIGNSPEND)
	weal = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_WEAL)
	revertConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_OFFLINE_REWARD)
	
	local now = GetOffsetTime() - 18000
	local year = tonumber(os.date("%Y", now))
	local isLeapYear =((year % 4 == 0) and(year % 100 ~= 0)) or(year % 400 == 0)
	
	for k, v in ipairs(signConfig) do
		if(signMonthData[v.month] == nil) then
			signMonthData[v.month] = {}
		end
		
		if(not isLeapYear and(v.month == 2) and(v.order >= 29)) then
			
		else
			if(signMonthData[v.month] [v.order] == nil) then
				signMonthData[v.month] [v.order] = {}
				signMonthData[v.month] [v.order].day = v.order
				signMonthData[v.month] [v.order].vip_limit = v.vip_limit
				signMonthData[v.month] [v.order].vip_title = v.vip_title
				signMonthData[v.month] [v.order].reward = {}
				local temp = ConfigSplit(v.show_item)
				signMonthData[v.month] [v.order].reward.data = ProductManager.GetProductById(tonumber(temp[1]))
				signMonthData[v.month] [v.order].reward.num = tonumber(temp[2])
			end
		end
	end
	canRevertAward = false;
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetSignData, SignInProxy.SendGetSignDataCallBack);
	SignInProxy.SendGetSignData() -- 红点要用
end

function SignInManager.GetReSignSpendConfig(t)
	return resignExpendConfig[t]
end

function SignInManager.GetMonthSignInConfig()
	local today = GetOffsetTime() - 18000
	local month = tonumber(os.date("%m", today))
	return signMonthData[month]
end

function SignInManager.GetToday()
	return GetToday()
end

function SignInManager.GetCurMonth()
	local now = GetOffsetTime() - 18000
	local month = tonumber(os.date("%m", now))
	return month
end
local insert = table.insert

function SignInManager.GetWealTypeData()
	local temp = {}
	local info = PlayerManager.GetPlayerInfo()
	
	for k, v in ipairs(weal) do
		if((info.level >= v.openVal) and v.isOpen) then
			
			if v.code_id == 5 then
				local b = Login7RewardManager.HasGetAllAward();
				
				if not b then
					insert(temp, v);
				end
			elseif v.code_id == 4 then
				-- 升级赠礼
				-- http://192.168.0.8:3000/issues/1968
				local b = KaiFuManager.KaiFuIsOver(1);
				if not b then
					insert(temp, v);
				end
			elseif v.code_id == 3 then
				-- 奖励找回， 开放第二天才开始 显示
				if KaiFuManager.kaifudate > 1 then
					insert(temp, v);
				end
				
			else
				insert(temp, v);
			end
			
		end
	end
	
	return temp
end

function SignInManager.CheckIsShowTb(code_id)
	
	local list = SignInManager.GetWealTypeData();
	
	for k, v in pairs(list) do
		if v.code_id == code_id then
			
			return true;
		end
	end
	
	return false;
end




function SignInManager.SetDailySignInData(data)
	dailySignInData = data
end

function SignInManager.GetDailySignInData()
	return dailySignInData
end

function SignInManager.GetSignCount()
	if(dailySignInData) then
		return dailySignInData.n + dailySignInData.bn
	end
	
	return 0
end

function SignInManager.GetReSignCount()
	if(dailySignInData) then
		return dailySignInData.bn
	end
	
	return 0
end

function SignInManager.GetTodayReSignCount()
	local today = SignInManager.GetToday()
	if(SignInManager.GetIsSignToday()) then
		return today - SignInManager.GetSignCount()
	else
		return today - SignInManager.GetSignCount() - 1
	end
	
end
function SignInManager.GetCanSignToday()
	if(dailySignInData and dailySignInData.f) then
		return dailySignInData.f ~= 1
	end
	return false
end
function SignInManager.GetIsSignToday()
	if(dailySignInData) then
		return dailySignInData.f == 1
	end
	
	return true
	
end

function SignInManager.CanRevertAward()
	return SignInManager.canRevertAward;
end
function SignInManager.SetCanRevertAward(v)
	SignInManager.canRevertAward = v
	--Warning(tostring(v))
	ModuleManager.SendNotification(SignInNotes.UPDATE_SIGNINPANELTIP);
end

function SignInManager.GetRevertCfgById(id)
	return revertConfig[id];
end 