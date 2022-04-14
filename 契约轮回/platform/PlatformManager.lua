--
-- @Author: LaoY
-- @Date:   2018-11-09 19:32:33
--
require('platform.SDKManager')
require('platform.NFTManager')
PlatformManager = PlatformManager or class("PlatformManager",BaseManager)

local json = require "cjson.safe"

PlatformManager.RuntimePlatform = {
	PC = 1,
	Android = 2,
	IOS = 3,
}

function PlatformManager:ctor()
	PlatformManager.Instance = self

	self.cur_platform_type = sdkMgr.platform
	
	self.platform = nil
	self.call_back_list = {}
	self.buy_data_list = {}
	
	self:checkInitSDK()
	self:Init()
	self:InifDeviceInfo()
	
end

function PlatformManager:InifDeviceInfo()
	self.device_info ={
		device_name = SystemInfo.deviceModel,
		os_type = self:IsIos() and "ios" or "android",
		net_type = (Util.NetAvailable and Util.IsWifi) and "wifi" or "4g",
		os_ver = SystemInfo.operatingSystem,
		ios_idfa = self:IsIos() and self:GetDeviceID() or "",
		android_imei = self:IsAndroid() and self:GetDeviceID() or "",
		package_name = Application.identifier,
		screen_width = DeviceResolutionWidth,
		screen_heigth = DeviceResolutionHeight,
	}

	DebugLog('--LaoY PlatformManager.lua,line 47--',Table2String(self.device_info))
end

function PlatformManager:Init()
	require('platform.Platform')
	if self.cur_platform_type == PlatformManager.RuntimePlatform.Android then
		require('platform.AndroidPlatform')
		self.platform = AndroidPlatform()
	elseif self.cur_platform_type == PlatformManager.RuntimePlatform.IOS then
		require('platform.IOSPlatform')
		self.platform = IOSPlatform()
	else
		require('platform.PCPlatform')
		self.platform = PCPlatform()
	end

	self:AddCallBack(self,"login",handler(self,self.loginCallBack))
	self:AddCallBack(self,"logout",handler(self,self.logoutCallBack))
	self:AddCallBack(self,"buy",handler(self,self.buyCallBack))
	self:AddCallBack(self,"exit",handler(self,self.exitCallBack))
	self:AddCallBack(self,"getPlayerInfo",handler(self,self.getPlayerInfoCallBack))
	self:AddCallBack(self,"GetPhoto",handler(self,self.GetPhoto))
	self:AddCallBack(self,"orientationChange",handler(self,self.orientationChange))

	self:AddCallBack(self,"shareResult",handler(self,self.FBshareCallBack))
	self:AddCallBack(self,"dzResult",handler(self,self.dzCallBack))
	self:AddCallBack(self,"bindingResult",handler(self,self.bindingCallBack))
	self:AddCallBack(self,"bindingStateResult",handler(self,self.bindingStateCallBack))
	self:AddCallBack(self,"getGiftBagResult",handler(self,self.getGiftBagCallBack))

	self:AddCallBack(self,"dentifyRealName",handler(self,self.identifyRealNameCallback))
	self:AddCallBack(self,"switchAccount",handler(self,self.switchAccountCallback))

	-- self:AddCallBack(self,"commentResult",handler(self,self.commentCallBack))


    if not self:IsMobile() then
        LuaResourceManager.ExecuteFrequence = 1;
        LuaResourceManager.LowExecuteFrequence = 1;
        LuaResourceManager.isMobile = false;
    else
        LuaResourceManager.isMobile = true;
    end

	-- DebugLog("===========PlatformManager.Init===========")
	-- DebugLog("=====DebugLog GetClipString",self:GetClipString())
	-- DebugLog("=====DebugLog GetBatteryState",self:GetBatteryState())
	-- self:SetClipString("Hello World!!!")

	-- DebugLog("===========PlatformManager.Init SDKManager.CallBack===========")
	-- SDKManager.CallBack("---------PlatformManager:Init()-----")

	local root_size = self:GetRootSize()
	DebugLog('--PlatformManager.lua,line 60--',root_size)
	local available_size = self:GetAvailableSize()
	DebugLog('--PlatformManager.lua,line 63--',available_size)

    DebugLog("=========channelID = ", self:GetChannelID())
    DebugLog("=========sdkChannelID = ", self:GetSdkChannelType())
end

function PlatformManager:checkInitSDK()
	if self:IsAndroid() then
		if AppConfig.JavaPath then
			sdkMgr:InitSdk(AppConfig.JavaPath)
		end
	elseif self:IsIos() then
		if not sdkMgr.IsInitedSDK and AppConfig.isOutServer then
			sdkMgr:InitSdk()
		end
	end
end

function PlatformManager.GetInstance()
	if PlatformManager.Instance == nil then
		PlatformManager()
	end
	return PlatformManager.Instance
end

--是否是手机平台
function PlatformManager:IsMobile()
	 return self:IsAndroid() or self:IsIos()
end

function PlatformManager:IsAndroid()
	return self.cur_platform_type == PlatformManager.RuntimePlatform.Android
end

function PlatformManager:IsIos()
	return self.cur_platform_type == PlatformManager.RuntimePlatform.IOS
end

function PlatformManager:Java2Lua(json_params)
	DebugLog('--LaoY PlatformManager:Java2Lua,line--',params)
	local params = json.decode(json_params)
	dump(params,"params")
	if not table.isempty(self.call_back_list[params.func_name]) then
		for k,v in pairs(self.call_back_list[params.func_name]) do
			if not v.cls.is_dctored then
				v.func(params)
			end
		end
	end
end

function PlatformManager:Oc2Lua(json_params)
	DebugLog('-- PlatformManager:Oc2Lua,line--',json_params)

	local params = json.decode(json_params)

	dump(params,"params")

	if not table.isempty(self.call_back_list[params.func_name]) then
		for k,v in pairs(self.call_back_list[params.func_name]) do
			if not v.cls.is_dctored then
				v.func(params)
			end
		end
	end
end
--[[
	@author LaoY
	@des	需要用到SDK回调的地方，必须先添加回调
	@param1 cls 		引用类
	@param2 func_name 	比如需要用到登录回调,为login 与PlatformManager持有的方法名字相同(同一个方法同一个类不支持多个回调)
	@param3 func 		移除回调
--]]
function PlatformManager:AddCallBack(cls,func_name,func)
	if not self:IsinList(cls,func_name) then
		self.call_back_list[func_name] = self.call_back_list[func_name] or {}
		table.insert(self.call_back_list[func_name],{cls = cls,func_name = func_name,func = func})
	end
end

function PlatformManager:IsinList(cls,func_name)
	if table.isempty(self.call_back_list[func_name]) then
		return false
	end
	for k,v in pairs(self.call_back_list[func_name]) do
		if v.cls == cls then
			return true
		end
	end
	return false
end

--[[
	@author LaoY
	@des	
	@param1 cls 			引用类
	@param2 func_name		方法名字
--]]
function PlatformManager:RemoveCallBack(cls,func_name)
	if table.isempty(self.call_back_list[func_name]) then
		return false
	end
	for k,v in pairs(self.call_back_list[func_name]) do
		if v.cls == cls then
			table.remove(list,k)
			break
		end
	end
end

-- SDK相关
--[[
	@author LaoY
	@des	

	-- 
	@param url 服务端验证地址
--]]
function PlatformManager:login()
	-- if self:IsAndroid() then
	-- 	local url =  AppConfig.Url .. "api/junhai/login"
	-- 	local data = {
	-- 		url = url,
	-- 	}
	-- 	self:CalljavaV("login",data)

	-- elseif self:IsIos() then
	-- 	self:CallocV("login");
	-- end

	lua_panelMgr:GetPanelOrCreate(NftLoginPanel):Open()
end

--请求游戏服务器验证登录
function PlatformManager:reqGameServerVertifyLogin(params)

	local function call_back(statusCode)
		local sdkInfo = {}
		sdkInfo.loginInfo = {}
		sdkInfo.loginInfo.uid = params.userId
		sdkInfo.loginInfo.channel_id = params.channelId
		sdkInfo.loginInfo.game_channel_id = params.channelId
		sdkInfo.loginInfo.token = params.userToken

		sdkInfo.loginInfo.game_id = "217"

		dump(sdkInfo.loginInfo, "sdkInfo.loginInfo")

		if true then
			LoginModel:GetInstance():SetSDKLoginInfo(sdkInfo)
			GlobalEvent:Brocast(EventName.SDKLoginSucess)
		end
	end

	call_back()

	--local url =  AppConfig.Url .. "api/junhai/login" -- 参数
	--HttpManager:GetInstance():ResponseGet(url, call_back)
end

function PlatformManager:loginCallBack(params)
	DebugLog('--ffh PlatformManager.lua,line 231--')
	dump(params,"tab")
	DebugLog('--ffh PlatformManager.lua,line 233--')

	DebugLog('--ffh params.retCode ', params.retCode)

	if params.retCode == "info" then

	elseif params.retCode == "success" then
		DebugLog('--LaoY PlatformManager.lua,line 145--')
		if self:IsIos() then
			self:reqGameServerVertifyLogin(params)
		else
			DebugLog('--LaoY PlatformManager.lua,line 145--')
			LoginModel:GetInstance():SetSDKLoginInfo(params)
			GlobalEvent:Brocast(EventName.SDKLoginSucess)
		end
	elseif params.retCode == "fail" then
		Notify.ShowText("Login failed, please try again")
		local function step()
			self:login()
		end
		-- GlobalSchedule:StartOnce(step,0)
	elseif params.retCode == "null" then
		local function step()
			self:login()
		end
		-- GlobalSchedule:StartOnce(step,0)
	elseif params.retCode == "switch" then
		if self:IsAndroid() then
			LoginController.GetInstance():RequestLeaveGame(true)
			LoginModel:GetInstance():SetSDKLoginInfo(params)
			local panel = lua_panelMgr:GetPanel(LoginPanel)
			if panel then
				if panel.is_loaded then
					GlobalEvent:Brocast(EventName.SDKLoginSucess)
				else
					panel.auto_login = true
				end
			else
				lua_panelMgr:GetPanelOrCreate(LoginPanel):Open(true)
			end
		end
	end
end

--sdk实名认证返回
function PlatformManager:identifyRealNameCallback(params)
	local status = tonumber(params.status)

	if self:IsAndroid() then

	elseif self:IsIos() then
		--[[
		--local params = {
		--	"age": "17", 玩家年龄。如果获取不到数据就为空串。
		--	"is_adult": "false", 玩家是否成年，true表示成年，false表示未成年。如果获取不到数据就为空串。注意是字符串类型。
		--	"real_name_authentication": "false", 玩家是否实名制，true表示完成了实名制，false表示没有完成实名制。如果获取不到数据就为空串。注意是字符串类型。
		--	"mobile": "", 玩家手机号码。如果获取不到数据就为空串。
		--	"real_name": "", 玩家真实姓名。如果获取不到数据就为空串。
		--	"id_card":"" 玩家身份证号码。如果获取不到数据就为空串。
		--}
		* Constants.ErrorCode.AUTHENTICATION_OK 41，表示渠道SDK有实名制且能够获取实名制结果，研发只需要通过data获取验证结果，然后实现防沉迷功能
		* Constants.ErrorCode.AUTHENTICATION_UNKNOWN,40，表示渠道SDK有实名制但不能获取实名制结果，研发不需要实现实名制功能，但是需要实现防沉迷功能
		* Constants.ErrorCode.AUTHENTICATION_NEVER,42，表示渠道SDK没有实名制功能，研发需要自行实现实名制功能，并实现防沉迷功能
		* Constants.ErrorCode.ANTI_INDULGENCE_REALIZED,43，表示渠道有实名制功能，且实现了防沉迷功能，研发收到该回调后应关闭游戏内实名认证与防沉迷功能
		*]]
		local data = {
			age = "",
			mobile = "",
			real_name = "",
			id_card = "",
			retCode = "AUTHENTICATION_OK"
		}
		if status == 0 then
			--0：未进行实名认证
			data.real_name_authentication = "false"
			data.is_adult = ""
		elseif status == 1 then
			--1：已实名认证且满18周岁
			data.real_name_authentication = "true"
			data.is_adult = "true"
		elseif status == 2 then
			--2：已实名认证未满18周岁
			data.real_name_authentication = "true"
			data.is_adult = "false"
		end


		DebugLog("identifyRealNameCallback")
		DebugLog(Table2String(params))
		GlobalEvent:Brocast(EventName.SDKPlayerInfo,params)
	end
end

--切换账号返回
function PlatformManager:switchAccountCallback(params)
	local token = params.userToken
	local userId = params.userId
	local channelId = params.channelId
	DebugLog("switchLoginCallback = ", Table2String(params))

	if self:IsAndroid() then

	elseif self:IsIos() then
		LoginController.GetInstance():RequestLeaveGame(true)
		GlobalEvent:Brocast(EventName.SDKLogOut)

		local function step()
			self:reqGameServerVertifyLogin(params)
		end
		GlobalSchedule:StartOnce(step,1.0)
	end
end


function PlatformManager:uploadUserDataByRoleData(data,state)
	local serverName = data.serverName or data.suid
	local role_create_time = data.ctime
	if data.ctime and data.ctime == 0 then
		role_create_time = os.time()
	end
	local role_update_time = os.time()
	-- if state == 1 then
	-- 	role_update_time = os.time()
	-- elseif state == 3 then
	-- 	role_update_time = os.time()
	-- else
	-- 	role_update_time = os.time()
	-- end	
	self:uploadUserData(data.suid,serverName,data.id,data.name,data.level,data.viplv,data.gold,data.gname,data.wake,role_create_time,role_update_time,state)
end

--[[
	@author LaoY
	@des
	/*其他参数说明 略*/
	@param role_create_time/role_update_time 其他时候默认是-1
	@param state 1是创建角色 2进入服务器 3升级 4 退出游戏 5选择服务器
--]]
function PlatformManager:uploadUserData(serverID,serverName,role_id,role_name,level,vip,gold,guild,wake,role_create_time,role_update_time,state)
    DebugLog("=================uploadUserDataByRoleData=========",state)
	if not guild or guild == "" then
		guild = "unknown"
	end
	role_create_time = role_create_time or -1
	role_update_time = role_update_time or -1
	
	local data = {
		serverID = serverID or LoginModel.ZoneID or "",
		serverName = serverName,
		role_id = role_id,
		role_name = role_name,
		level = level,
		vip = vip,
		gold = gold,
		guild = guild,
		wake = wake,
		role_create_time = role_create_time,
		role_update_time = role_update_time,
		state = state,
		-- guild_id = guild_id,
		-- gender = gender,
		-- career = career,
		-- career_name = career_name,
		-- power = power,
	}
	local roleInfoModel = RoleInfoModel:GetInstance()
	data.remainCoin = roleInfoModel:GetRoleValue(Constant.GoldType.Gold) or 0
	data.serverName = LoginModel.ZoneName or serverName

	local uid
	local sdkInfo = LoginModel:GetInstance():GetSDKLoginInfo()
	if sdkInfo then
		uid = sdkInfo.uid
		DebugLog("sdkInfo = ", Table2String(sdkInfo))
	end
	DebugLog("payData = ", Table2String(data))

	if self:IsAndroid() then
		self:CalljavaV("uploadUserData",data)
	elseif self:IsIos() then
		data.uid = uid
		self:CallocV("reportRoleInfo", data)
	end

end

function PlatformManager:logout()
	if self:IsAndroid() then
		self:CalljavaV("logout")
	elseif self:IsIos() then
		self:CallocV("loginout");
	end
end

function PlatformManager:logoutCallBack(params)
	DebugLog('--LaoY PlatformManager.lua,line 200--',params)
	dump(params,"params")

	-- 登录侦听的回调 
	-- logout 这里是退出成功
	if params.retCode == "login" then
		-- GlobalEvent:Brocast(EventName.SDKLogOut)
		-- local panel = lua_panelMgr:GetPanel(LoginPanel)
		if not LoginModel.GetInstance().to_login then
			LoginController.GetInstance():RequestLeaveGame(true)
		end
		GlobalEvent:Brocast(EventName.SDKLogOut)

	-- 退出登录 成功回调
	elseif params.retCode == "success" then
		-- if self:IsAndroid() then
		-- 	if not LoginModel.GetInstance().to_login then
		-- 		LoginController.GetInstance():RequestLeaveGame(true)
		-- 		GlobalEvent:Brocast(EventName.SDKLogOut)
		-- 		return
		-- 	end
		-- end

		-- if self:IsIos() then
		-- 	if not LoginModel.GetInstance().to_login then
		-- 		LoginController.GetInstance():RequestLeaveGame(true)
		-- 		GlobalEvent:Brocast(EventName.SDKLogOut)
		-- 		return
		-- 	end
		-- end
		-- 贪玩SDK，在sdk切换账号会走两次这里
		if not self:IsCN() and self:IsAndroid() and params.type == "SwitchAccount" then
			local panel = lua_panelMgr:GetPanel(LoginPanel)
			if panel then
				return
			end
		end
		if not LoginModel.GetInstance().to_login then
			LoginController.GetInstance():RequestLeaveGame(true)
			-- GlobalEvent:Brocast(EventName.SDKLogOut)
			-- return
		end

		--local function step()
		--	PlatformManager:GetInstance():login()
		--end
		-- GlobalSchedule:StartOnce(step,1.0)
		GlobalEvent:Brocast(EventName.SDKLogOut)
		local panel = lua_panelMgr:GetPanel(LoginPanel)
	-- 退出登录 失败回调
	elseif params.retCode == "fail" then

	end
end

--[[
	@author LaoY
	@des	
	@param1 	orderId 订单号，必传。
	@param2 	roleID 	
	@param3 	roleName 	
	@param4 	serverId 	
	@param5 	productName 	
	@param6 	productID 	
	@param7 	payInfo 		-- 商品描述信息，必传。
	@param8 	productCount 	
	@param9 	realPayMoney 	-- 支付金额，单位为分，必传。
	@param10 	notifyUrl 	
	@param11 	diamand_num	  
--]]
function PlatformManager:buy(orderId, roleId, roleName, serverId, productName, productID, payInfo, productCount, realPayMoney, notifyUrl, diamand_num, appstoreProductId, goods_id)
	if self:IsXw() then
		local url = "http://www.woaiwangame.com:8002/?amount=%s&orderno=%s&userid=%s&productname=%s&notifyurl=http://admin.xwen.xwangame.com:10000/api/xwen/pay"
		local price = string.format("%.02f",diamand_num/10)
		url = string.format(url,price,orderId,roleId,productName)
		local function call_back(text)
			DebugLog("==============PlatformManager:buy end=========",text)
		end
		-- HttpManager:GetInstance():ResponseGetText(url, call_back)
		-- Util.OpenUrl(url)
		SDKManager.CallVoid("OpenUrl",url)
		DebugLog("================PlatformManager:buy start===========",url)
		return
	end

	local roleInfoModel = RoleInfoModel:GetInstance()
	--local roleId = roleInfoModel:GetMainRoleId()
	--local roleName = roleInfoModel:GetMainRoleData().name
	--local serverId = roleInfoModel:GetMainRoleData().suid
	local roleLv = roleInfoModel:GetMainRoleLevel()
	local vipLv = roleInfoModel:GetMainRoleVipLevel()
	local guild = roleInfoModel:GetRoleValue("guild") or ""
	local ctime = roleInfoModel:GetRoleValue("ctime") or ""

	local uid
	local sdkInfo = LoginModel:GetInstance():GetSDKLoginInfo()
	if sdkInfo then
		uid = sdkInfo.uid
	end

	local serverName = LoginModel.ZoneName
	if serverName == "" then
		serverName = nil
	end
	local data = {
		orderId = orderId,
		roleID = roleId,
		roleName = roleName,
		serverId = serverId,
		productName = productName,
		productID = productID,
		payInfo = payInfo,
		productCount = productCount,
		realPayMoney = realPayMoney * 100, -- 支付金额，单位为分，必传。
		notifyUrl = notifyUrl,
		diamand_num = diamand_num,		--鑽石數量
		AppStoreid = appstoreProductId,		-- 谷歌商店和蘋果商店支付id
		level = roleLv,
		serverName = serverName,
		vipLv = vipLv,
		ctime = ctime, 		--创建角色的时间
	}

	data.realymon = realPayMoney * 100 -- 支付金額，單位為分，必傳。,
	data.roleID = roleId 				-- role id
	data.serverId = serverId 			-- serverId
	data.serverName = LoginModel.ZoneName
	data.productName = productName
	data.productID = appstoreProductId
	data.id = productID
	data.goodsID = goods_id
	data.roleLv = roleLv
	data.vipLv = vipLv
	data.oId = orderId
	data.remainCoin = roleInfoModel:GetRoleValue(Constant.GoldType.Gold) or 0
	data.uid = uid
	data.guild = guild

	self.buy_data_list[data.orderId] = data
	
	local extra = self:GetChannelID() .. "|" .. roleId .. "|" .. goods_id .. "|" .. serverId .. "|" .. orderId
	data.extra = extra
	data.extra1 = extra
	data.extra2 = ""
	data.extra3 = ""
	data.extra4 = ""
	data.extra5 = ""

	DebugLog("payData = ", Table2String(data))
	
	if self:IsAndroid() then
		self:CalljavaV("buy",data)
	elseif self:IsIos() then
		self:CallocV("checkadd", data);
	end
end

function PlatformManager:GetBuyData(orderId)
	return self.buy_data_list[orderId]
end

function PlatformManager:buyCallBack(params)
	-- 充值返回 客户端不用管，等服务端返回才是正确的
	DebugLog('--LaoY PlatformManager.lua,line 238--',Table2String(params))
	
	if params.retCode == "success" then
	elseif params.retCode == "fail" then
	end
end

function PlatformManager:exit()
	if self:IsAndroid() and not AppConfig.Debug then
		self:CalljavaV("exit")

	elseif self:IsIos() and not AppConfig.Debug then

	else
		local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
		if main_role_data then
			PlatformManager:GetInstance():uploadUserDataByRoleData(main_role_data, 4)
		end
		Application.Quit()
	end
end

function PlatformManager:exitCallBack(params)
	DebugLog('--LaoY PlatformManager.lua,line 250--')
	dump(params,"params")

	local function exit()
		local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
		if main_role_data then
			PlatformManager:GetInstance():uploadUserDataByRoleData(main_role_data,4)
		end
	end
	if params.retCode == "EXIT_NO_UI" then
		local function ok_func()
			exit()
			Application.Quit()
		end
		local message = "Exit game?"
		Dialog.ShowTwo('Tip',message,'Confirm',ok_func,nil,'Cancel',nil,nil,nil)
	elseif params.retCode == "EXIT_WITH_UI" then
		-- Application.Quit()
		local function ok_func()
			exit()
			Application.Quit()
		end
		local message = "Exit game?"
		Dialog.ShowTwo('Tip',message,'Confirm',ok_func,nil,'Cancel',nil,nil,nil)
	end
end

function PlatformManager:buyItem(cost_gold,cost_bgold,gold,bgold,num,name)

end


--[[
 * retCode说明：
 * Constants.ErrorCode.AUTHENTICATION_OK 41，表示渠道SDK有实名制且能够获取实名制结果，研发只需要通过data获取验证结果，然后实现防沉迷功能
 * Constants.ErrorCode.AUTHENTICATION_UNKNOWN,40，表示渠道SDK有实名制但不能获取实名制结果，研发不需要实现实名制功能，但是需要实现防沉迷功能
 * Constants.ErrorCode.AUTHENTICATION_NEVER,42，表示渠道SDK没有实名制功能，研发需要自行实现实名制功能，并实现防沉迷功能
 * Constants.ErrorCode.ANTI_INDULGENCE_REALIZED,43，表示渠道有实名制功能，且实现了防沉迷功能，研发收到该回调后应关闭游戏内实名认证与防沉迷功能
 *
 返回的数据为json对象，直接从data里获取
 研发拿到这些数据后，根据需要进行实名制和防沉迷等逻辑操作。
 返回的数据格式如下：
 {
 "age": "17", 玩家年龄。如果获取不到数据就为空串。
 "is_adult": "false", 玩家是否成年，true表示成年，false表示未成年。如果获取不到数据就为空串。注意是字符串类型。
 "real_name_authentication": "false", 玩家是否实名制，true表示完成了实名制，false表示没有完成实名制。如果获取不到数据就为空串。注意是字符串类型。
 "mobile": "", 玩家手机号码。如果获取不到数据就为空串。
 "real_name": "", 玩家真实姓名。如果获取不到数据就为空串。
 "id_card":"" 玩家身份证号码。如果获取不到数据就为空串。
 }
 --]]
function PlatformManager:getPlayerInfo()
	if self:IsAndroid() then
		self:CalljavaV("getPlayerInfo")
	elseif self:IsIos() then
        if self:checkChannelID(114138) then
            --鹏超越狱渠道
            self:checkAntiAddiction();
        else
		    self:CallocV("identifyRealName")
        end
	end
	--测试代码
	--local data = {}
	--data["age"] = "17"
	--data["is_adult"] = "false"
	--data["real_name_authentication"] = "true"
	--data["mobile"] = "18565435805"
	--data["real_name"] = "少聪小JB"
	--data["id_card"]  = "220822200505297334"
	--data["retCode"] = "AUTHENTICATION_NEVER"
	--GlobalEvent:Brocast(EventName.SDKPlayerInfo,data)
end

--安卓
function PlatformManager:getPlayerInfoCallBack(params)
	if params.retCode == "AUTHENTICATION_OK" or params.retCode == 41 then
		params.retCode = "AUTHENTICATION_OK"
	elseif params.retCode == "AUTHENTICATION_UNKNOWN" or params.retCode == 40 then
		params.retCode = "AUTHENTICATION_UNKNOWN"
	elseif params.retCode == "AUTHENTICATION_NEVER" or params.retCode == 42 then
		params.retCode = "AUTHENTICATION_NEVER"
	elseif params.retCode == "ANTI_INDULGENCE_REALIZED" or params.retCode == 43 then
		params.retCode = "ANTI_INDULGENCE_REALIZED"
	end

	DebugLog("getPlayerInfoCallBack")
  	DebugLog(Table2String(params))
 	GlobalEvent:Brocast(EventName.SDKPlayerInfo,params)
end

-- SDK相关

function PlatformManager:CalljavaV(func_name,param)
	if not AppConfig.isOutServer then
		return
	end
	if not param or type(param) ~= "string" then
		if not param then
			param = {}
		end
		param.func_name = func_name
		param = json.encode(param)
	end
	DebugLog('--LaoY CalljavaV======>',func_name,param)
	SDKManager.CallVoid("UnityCallJava",param)
end

function PlatformManager:CallocV(func_name,param)
	if not AppConfig.isOutServer then
		return
	end
	if not param or type(param) ~= "string" then
		if not param then
			param = {}
		end
		--param.func_name = func_name
		param = json.encode(param)
	end

	--调用SDK相关的接口
	DebugLog('-- sdkMgr.OcCallSDKFunc =====>',func_name,param)

	sdkMgr.OcCallSDKFunc(func_name, param)
end

--[[
	@author LaoY
	@des	复制到剪切板
	@param1 string
--]]
function PlatformManager:SetClipString(str)
	self.platform:SetClipString(str)
end

--[[
	@author LaoY
	@des	获取剪切板内容
	@return string
--]]
function PlatformManager:GetClipString()
	return self.platform:GetClipString()
end

--[[
	@author LaoY
	@des	获取剩余电量 百分比
	@return float 0-1
--]]
function PlatformManager:GetBatteryState()
	-- return self.platform:GetBatteryState()
	return 100,1
end

function PlatformManager:SetBrightness(brightness)

	DebugLog("PlatformManager:SetBrightness = " )
	DebugLog(brightness)

	return self.platform:SetBrightness(brightness)
end

--[[
	@author LaoY
	@des	获取手机磁盘空间大小
--]]
function PlatformManager:GetRootSize()
	return self.platform:GetRootSize()
end

--[[
	@author LaoY
	@des	获取手机当前可以使用的磁盘空间大小
--]]
function PlatformManager:GetAvailableSize()
	return self.platform:GetAvailableSize()
end

function PlatformManager:GetDeviceID()
	return self.platform:GetDeviceID()
end

--[[
	@author LaoY
	@des	获取相册图片
	@param1 type 			1.照相 2.选择相片
	@param2 file_name		图片名字，带后缀
	@param3 width 			宽
	@param3 height 			高
--]]
function PlatformManager:TakePhoto(type,file_name,width,height,quality)
	-- if not self:IsMobile() then
	-- 	return
	-- end
	type = type == nil and 1 or type
	local type_name = type == 1 and "TakePhoto" or "SelectPhoto"
	quality = quality or 100
	local t = {
		type 		= type_name,
		file_path 	= AvatarManager.local_file_path,
		file_name 	= file_name,
		width 		= width or 0,
		height 		= height or 0,
		quality 	= quality,
	}

	local param = json.encode(t)
	SDKManager.CallVoid("TakePhoto",param)
end

function PlatformManager:GetPhoto(params)
	DebugLog('--LaoY PlatformManager.lua,line 440--',params)
	dump(params,"tab")
	local function step()
		GlobalEvent:Brocast(EventName.GetPhoto,params)
	end
	GlobalSchedule:StartOnce(step,0.04)
end

function PlatformManager:orientationChange(params)	
	dump(params,"ori")
	local function step()
		GlobalEvent:Brocast(EventName.UIOriChange,params)
	end
	GlobalSchedule:StartOnce(step,0.04)
end

function PlatformManager:GetChannelID()
	return SDKManager.CallString("GetChanelID")
end

--quicksdk 子渠道id
function PlatformManager:GetSdkChannelType()
    if self:IsAndroid() then

    elseif self:IsIos() then
       return self.platform:CallInt("getSdkChannelType");
    end
    return ""
end

function PlatformManager:checkChannelID(channelId)
    local _channelID = tostring(self:GetChannelID());
    return string.match(_channelID, tostring(channelId))
end

-- 顯示用戶中心
function PlatformManager:ShowUserCenter()
	if self:IsAndroid() then
		SDKManager.CallVoid("ShowUserCenter")
	elseif self:IsIos() then
		self:CallocV("ShowUserCenter")
	end
end

-- 顯示客服中心
function PlatformManager:ShowCustomerService()
	if self:IsAndroid() then
		SDKManager.CallVoid("ShowCustomerService")
	elseif self:IsIos() then
		self:CallocV("ShowCustomerService")

	end
end

-- 進度條完成
function PlatformManager:LoadingComplete()
	if self:IsAndroid() then
		SDKManager.CallVoid("LoadingComplete")
	elseif self:IsIos() then
		self:CallocV("LoadingComplete")
	end
end

-- fb share
function PlatformManager:FBsharelink()
    if self:IsAndroid() then
        SDKManager.CallVoid("FBsharelink")
    elseif self:IsIos() then
        self:CallocV("FBsharelink")
    end

end

function PlatformManager:FBshareCallBack(param)
	logError(param.retCode)
	if param.retCode == "success" then
		GlobalEvent:Brocast(EventName.FbShareInfo,param)
	end
end

-- dz
function PlatformManager:dz()
    if self:IsAndroid() then
        SDKManager.CallVoid("dz")
    elseif self:IsIos() then
        self:CallocV("dz")
    end
end

function PlatformManager:dzCallBack(param)
	logError(param.retCode)
	if param.retCode == "success" then
		GlobalEvent:Brocast(EventName.DianZanInfo,param)
	end
end

-- 綁定
function PlatformManager:binding()
	if self:IsAndroid() then
		SDKManager.CallVoid("binding")
	elseif self:IsIos() then
		self:CallocV("binding")
	end
end
--绑定账号成功回调
function PlatformManager:bindingCallBack(param)
	--logError(param.retCode)
	if param.retCode == "success" then
		GlobalEvent:Brocast(EventName.BindEmailInfo,param)
	end
end
--查询第三方账号绑定状态回调
function PlatformManager:bindingStateCallBack(param)
	--if self:IsAndroid() then
		GlobalEvent:Brocast(EventName.BindEmailState,param.retCode)
	--end
end

-- 評論
function PlatformManager:comment()
	if self:IsAndroid() then
		HttpManager.OpenUrl("https://play.google.com/store/apps/details?id=com.fifun.qyen.an")
	elseif self:IsIos() then
		local APP_ID = "1500241765"
		if AppConfig.engineVersion >= 9 then
			local t = {
				appid = APP_ID,
			}
			local param = json.encode(t)
			SDKManager.CallVoid("ShowComment", param)
		else
			local url = string.format("itms-apps://itunes.apple.com/cn/app/id%s?mt=8&action=write-review", APP_ID)
			HttpManager.OpenUrl(url)
		end
	end
end

--領取禮包
-- 1 RewardTypeShare, 2 RewardTypeLike, 3 RewardTypeBind
function PlatformManager:getGiftBag(type)
	local data = {
		type = type,
	}

	if self:IsAndroid() then

	elseif self:IsIos() then
		self:CallocV("getGiftBag", data)
	end
end
function PlatformManager:getGiftBagCallBack(param)
	if self:IsAndroid() then

	elseif self:IsIos() then

	end
end


--防沉迷状态查询
function PlatformManager:checkAntiAddiction()
    if self:IsAndroid() then

    elseif self:IsIos() then
        self:CallocV("checkAntiAddiction")
    end
end

-- 是否为中文
function PlatformManager:IsCN()
	return false
end

-- 是否为繁体
function PlatformManager:IsFT()
	return AppConfig.region == 2
end

-- 是否为泰文
function PlatformManager:IsTW()
	return AppConfig.region == 3
end

-- 是否为英文
function PlatformManager:IsEN()
	return AppConfig.region == 5
end

--是否为韩文
function PlatformManager:IsKR()
	return AppConfig.region == 6
end

--是否为越南
function PlatformManager:IsYN()
	return AppConfig.region == 8
end

function PlatformManager:IsHaiwai()
	return self:IsFT() or 
	self:IsTW() or 
	self:IsEN() or 
	self:IsKR() or 
	self:IsYN()
end

function PlatformManager:IsXw()
	return AppConfig.region == 12
end

-- 沒有回調
-- function PlatformManager:commentCallBack(param)
-- 	if params.retCode == "success" then
-- 		--todo
-- 	end
-- end