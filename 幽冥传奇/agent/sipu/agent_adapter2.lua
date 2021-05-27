local agent_helper = require("scripts/agent/agent_helper")

AgentAdapter = {
	is_init = false,
	is_login_verify_ing = false,
	login_callback = nil,
	force_logout = false,

    login_verify_url = "http://tlzjapi.6pmgame.com/agent/sipu/login_verify.php",
    pay_verify_url = "http://tlzjapi.6pmgame.com/agent/sipu/pay_verify.php",
	uid = "",
	token = "",
}

--初始化
function AgentAdapter:Init()

	if self.is_init then return end
	self.uid = string.gsub((AdapterToLua:getInstance():getDataCache("PRVE_ACCOUNT_NAME") or ""), self:GetSpid() .. "_", "")
	self.is_init = true
	AgentMs:InitLocalPush()
	--浮标里按“切换账号”
	PlatformBinder:JsonBind("call_agent_logout", function(arg)
		self:LogoutCallback(arg)
		return true
	end)
end

-- 平台ID
function AgentAdapter:GetSpid()
	return "sipu"
end
-- 平台帐号唯一标识
function AgentAdapter:GetOpenId()
	return self.uid
end

-- 加前辍的平台帐号，全平台唯一
function AgentAdapter:GetPlatName()
	return self.GetSpid().."_".. self.uid
end

function AgentAdapter:GetPhonePlat()
	local plat = "android"
	if cc.PLATFORM_OS_IPHONE == PLATFORM or cc.PLATFORM_OS_IPAD == PLATFORM then
		plat = "ios"
	end
	return plat
end
--获得游戏名字
function AgentAdapter:GetGameName()
	return "屠龙战记"
end

--获得logo资源名
function AgentAdapter:GetLogoResName()
	return "agentres/logo.png"
end

function AgentAdapter:Login(callback, arg)
	if self.is_login_verify_ing then
		SysMsgCtrl.Instance:ErrorRemind("正在登录验证中，请稍等...", true)
		return
	end
	self.login_callback = callback
	agent_helper:Login(LUA_CALLBACK(self, self.LoginCallback), arg)--设置登陆回调 
	--PlatformBinder:JsonBind("call_agent_switch_account", function(arg) self:SwitchAccount(arg) end)
end

function AgentAdapter:OnClickBackLogin()
	PlatformBinder:JsonCall("call_agent_switch_account")
	AgentLoginView:OnClickBtnLogin()--重新调出登陆界面
end
function AgentAdapter:SwitchAccount(result)
	AdapterToLua:getInstance():setDataCache("SWITCH_ACCOUNT_DATA", result)
	ReStart()	
	return true
end

function AgentAdapter:LoginCallback(result)--登陆后回调
	Log("result_===" .. result)

	local json_obj = cjson.decode(result)	

	if nil == json_obj or 
		nil == json_obj.userId  or 
		nil == json_obj.token 
		then return end

	local userId = json_obj.userId
	local token = json_obj.token
	local verify_callback = function(url, arg, data, size)
		self.is_login_verify_ing = false
		if size <= 0 then
			return
		end
		
		local ret_t = cjson.decode(data)
		if nil == ret_t or 0 ~= ret_t.ret or nil == ret_t.user then
			return
		end
		self.uid = ret_t.user.uid
		self.token = ret_t.user.token
		LoginController.Instance:SetLoginUserData(self:GetPlatName(), ret_t.user)
		self.login_callback(self:GetPlatName())
	end
	
	self.is_login_verify_ing = true
	local now_server_time = math.floor(GLOBAL_CONFIG.server_info.server_time + (Status.NowTime - GLOBAL_CONFIG.client_time))
	local real_url = string.format("%s?spid=%s&userId=%s&token=%s&device=%s", self.login_verify_url, self:GetSpid(), userId, token, tostring(PlatformAdapter.GetPhoneUniqueId()))
	Log("log_real_url==" .. real_url)
	HttpClient:Request(real_url, "", verify_callback)

	return false
end


function PlatformAdapter:OpenExitDialog()
	--self:OpenAlertDialog()
	local callback = function(result)
		AdapterToLua:endGame()--sdk

		-- 	local format = { title = "退出", message = "退出游戏?", positive = "确定", negative = "取消", }
		-- 	self:OpenAlertDialog(format, function (result) if "positive" == result then 
		-- 		AdapterToLua:endGame()
		-- 	end end)
		-- end
		return true
	end
	agent_helper:Exit(callback)
end

--当首次进入游戏场景时（即玩家第一次看到游戏地图时）
function AgentAdapter:OnFirstEnterGameScene()
	PlatformBinder:JsonCall("call_agent_request_mid") -----------出包后再打开
end

function AgentAdapter:LogoutCallback(result)--注销回调
	self:SubmitInfo(4)
	self.uid = ""
	if not LoginController.Instance:AgentLoginViewIsOpen() then
		ReStart()
	end
	return true
end

function AgentAdapter:Pay(role_id, role_name, amount, server_id, callback)--购买

	if self.uid == "" then
		SysMsgCtrl.Instance:ErrorRemind("uid为空，请联系客服")
		return
	end


	local pay_verify_callback = function(url, arg, data, size)
		if size <= 0 then
			return
		end
		local ret_t = cjson.decode(data)
		if nil == ret_t or 0 ~= ret_t.ret then
			return
		end

		local param_obj = cjson.decode(arg)
		agent_helper:Pay(cjson.encode(param_obj))
		return true
	end

	local user_vo = GameVoManager.Instance:GetUserVo()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
    local orderid = server_id .. "_" .. user_vo.account_id .. "_" .. os.time() .. "_" .. role_id
	local param_obj = {}
	local rate = 10
	param_obj.userId = self.uid
	param_obj.token = self.token
	param_obj.amount = amount
	param_obj.order_id = orderid
	param_obj.server_id = server_id
	param_obj.role_id = role_id
	param_obj.role_name = role_name
	param_obj.server_name = server_id .. "服-" .. user_vo.plat_server_name --服务器id + 服务器名字
	param_obj.goods_desc = amount*rate .. "元宝"
	param_obj.goods_name = amount*rate .. "元宝"
	param_obj.count = amount*rate 
	param_obj.role_level = role_vo[OBJ_ATTR.CREATURE_LEVEL]
	param_obj.vip_level = tostring(role_vo[OBJ_ATTR.ACTOR_VIP_GRADE]) or "0"
	param_obj.plat = self:GetPhonePlat()
	param_obj.money_yb = role_vo[OBJ_ATTR.ACTOR_GOLD] or "0"

	if RoleData.Instance and RoleData.Instance.role_info then
		param_obj.party_name = RoleData.Instance.role_vo.guild_name or ""
	else
		param_obj.party_name = ""
	end
	Log("Pay_param_obj==" .. cjson.encode(param_obj))
	--game_orderid=abcd123456789&game_price=60.00&subject=60.00_60
	local real_url = string.format("%s?uid=%s&amount=%s&count=%s&orderid=%s&server_id=%s&good_name=%s&plat=%s&token=%s", self.pay_verify_url, self.uid,amount, param_obj.count,orderid, server_id, param_obj.goods_name,self:GetPhonePlat(),self.token)
	Log("Pay_real_url==" .. real_url)
	
	HttpClient:Request(real_url, cjson.encode(param_obj), pay_verify_callback)

	
end

function AgentAdapter:OnClickRestartGame()
   agent_helper:Logout()
end

-- 创建角色上报
function AgentAdapter:ReportOnCreateRole(role_name)
	self:SubmitInfo(1)
end


function AgentAdapter:SubmitRoleData(role_id, role_name, role_level, zone_id, zone_name, is)
	self:SubmitInfo(2)
end

--  升级上报
function AgentAdapter:ReportOnRoleLevUp(role_id, role_name, role_level, zone_id, zone_name)
	self:SubmitInfo(3)    
end

function AgentAdapter:SubmitInfo(type)
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local user_vo = GameVoManager.Instance:GetUserVo()

	if role_vo ~= nil and user_vo ~= nil then
		local info = {}
		info.zone_id = tostring(user_vo.plat_server_id)
		info.server_name = user_vo.plat_server_id .. "服-" .. user_vo.plat_server_name
		info.role_name = role_vo.name
		info.role_id = tostring(user_vo.cur_role_id)
		info.role_level = tostring(role_vo[OBJ_ATTR.CREATURE_LEVEL]) or "0"
		info.vip_level = tostring(role_vo[OBJ_ATTR.ACTOR_VIP_GRADE]) or "0"
		info.gender = Language.Common.SexName[role_vo[OBJ_ATTR.ACTOR_SEX]] or ""	--性别
		info.prof = role_vo[OBJ_ATTR.ACTOR_PROF]
		info.professional = Language.Common.ProfName[role_vo[OBJ_ATTR.ACTOR_PROF]] or ""	--职业
		info.money_yb = role_vo[OBJ_ATTR.ACTOR_GOLD] or "0"
		info.role_createtime = role_vo.create_time or 0
		--info.rolelevelMtime = "2"
		if RoleData.Instance and RoleData.Instance.role_info then
			info.party_name = RoleData.Instance.role_vo.guild_name or ""
			info.party_id = role_vo[OBJ_ATTR.ACTOR_GUILD_ID] or "0"
		else
			info.party_name = ""
			info.party_id = role_vo[OBJ_ATTR.ACTOR_GUILD_ID] or "0"
		end

		info.data_type = tostring(type)

		print(cjson.encode(info))
		PlatformBinder:JsonCall("send_user_info", cjson.encode(info))
	end
end

--是否支持动态下载
function AgentAdapter:IsDynamicDownloadRes()
	return true
end
