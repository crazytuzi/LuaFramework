-- 上报管理器
ReportManager = {
	agent_id = GLOBAL_CONFIG.package_info.config.agent_id,
	device_id = DeviceTool.GetDeviceID(),
	pkg_ver = GLOBAL_CONFIG.package_info.version,
	assets_ver = GLOBAL_CONFIG.assets_info.version,
}

-- 上报枚举
Report = {
	STEP_GAME_BEGIN						= 10000, -- 游戏开始，获取第一条PHP
	STEP_UPGRADE						= 10010, -- 游戏需要更新包
	STEP_REQUEST_REMOTE_MANIFEST		= 10020, -- 开始请求RemoteManifest
	STEP_REQUEST_REMOTE_MANIFEST_FAILED	= 10030, -- 请求RemoteManifest失败
	STEP_UPDATE_ASSET_BUNDLE			= 10040, -- 开始更新AssetBundle
	STEP_UPDATE_ASSET_BUNDLE_COMPLETE   = 10050, -- 更新AssetBundle完成
	STEP_REQUIRE_START					= 10060, -- 开始require列表
	STEP_REQUIRE_END					= 10070, -- require完成
	STEP_SHOW_LOGIN						= 10080, -- 显示登陆界面
	STEP_LOGIN_COMPLETE					= 10090, -- 登陆完成
	STEP_CLICK_START_GAME				= 10100, -- 点击开始游戏
	STEP_CONNECT_LOGIN_SERVER			= 10110, -- 开始连接登陆服务器
	STEP_LOGIN_SERVER_CONNECTED			= 10120, -- 登陆服连接上了
	STEP_LOGIN_SERVER_CONNECTED_FAILED	= 10130, -- 登陆服连接失败
	STEP_ROLE_LIST_MERGE_ACK			= 10140, -- 合并角色列表(合服之后)
	STEP_SEND_CREATE_ROLE				= 10150, -- 发送创建角色请求
	STEP_CREATE_ROLE_ACK				= 10160, -- 创建角色成功
	STEP_CREATE_ROLE_ACK_FAILED			= 10170, -- 创建角色失败
	STEP_ROLE_LIST_ACK					= 10180, -- 获得角色列表
	STEP_SEND_ROLE_REQUEST				= 10190, -- 请求登陆角色
	STEP_SEND_ROLE_REQUEST_CROSS		= 10200, -- 请求跨服登陆角色
	STEP_ON_LOGIN_ACK					= 10210, -- 收到登陆回复
	STEP_ON_LOGIN_ACK_FAILED			= 10220, -- 登陆回复失败
	STEP_CONNECT_GAME_SERVER			= 10230, -- 游戏服连接上了
	STEP_CONNECT_GAME_SERVER_FAILED		= 10240, -- 游戏服连接失败
	STEP_SEND_ENTER_GS					= 10250, -- 请求进入游戏服
	STEP_ENTER_GS_ACK					= 10260, -- 进入场景
	STEP_ENTER_GS_ACK_FAILED			= 10270, -- 进入场景失败
	STEP_CHANGE_SCENE_BEGIN				= 10280, -- 开始切换场景
	STEP_UPDATE_SCENE_BEGIN				= 10290, -- 更新场景开始
	STEP_UPDATE_SCENE_COMPLETE			= 10300, -- 更新场景完成
	STEP_CHANGE_SCENE_COMPLETE			= 10310, -- 切换场景完成

	STEP_DISCONNECT_LOGIN_SERVER		= 11010, -- 登陆服断线
	STEP_DISCONNECT_GAME_SERVER			= 11020, -- 游戏服断线
	STEP_DISCONNECT_SHOW				= 11030, -- 显示断线提示
	STEP_DISCONNECT_RETRY				= 11040, -- 提示后重试连接
	STEP_DISCONNECT_BACK				= 11050, -- 断线后返回登陆

	CHAT_PRIVATE                        = 20100, -- 私聊记录
}

-- 上报日志.
function ReportManager:Step(step, role_id, role_name, device_id, user_id, ...)
	if GameVoManager ~= nil and GameVoManager.Instance ~= nil then
		device_id = device_id or self.device_id
		local server_id = nil

		local user_vo = GameVoManager.Instance:GetUserVo()
		if user_vo ~= nil then
			if user_vo.plat_name ~= nil and user_vo.plat_name ~= "" then
				user_id = user_id or user_vo.plat_name
			end

			if user_vo.plat_server_id ~= nil and user_vo.plat_server_id ~= "" then
				server_id = user_vo.plat_server_id
			end
		end

		local main_role_vo =  GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo ~= nil then
			if main_role_vo.role_id ~= nil and main_role_vo.role_id ~= "" then
				role_id = role_id or main_role_vo.role_id
			end

			if main_role_vo.role_id ~= nil and main_role_vo.role_id ~= "" then
				role_name = role_name or main_role_vo.name
			end
		end

		if user_id ~= nil and server_id ~= nil and role_id ~= nil then
			ReportManager:Report(
				step,
				self.agent_id,
				device_id,
				self.pkg_ver,
				self.assets_ver,
				UnityEngine.Application.internetReachability,
				os.time(),
				user_id,
				server_id,
				role_id,
				role_name,
				...)
		elseif user_id ~= nil and server_id ~= nil then
			ReportManager:Report(
				step,
				self.agent_id,
				device_id,
				self.pkg_ver,
				self.assets_ver,
				UnityEngine.Application.internetReachability,
				os.time(),
				user_id,
				server_id,
				...)
		elseif user_id ~= nil then
			ReportManager:Report(
				step,
				self.agent_id,
				device_id,
				self.pkg_ver,
				self.assets_ver,
				UnityEngine.Application.internetReachability,
				os.time(),
				user_id,
				...)
		else
			ReportManager:Report(
				step,
				self.agent_id,
				device_id,
				self.pkg_ver,
				self.assets_ver,
				UnityEngine.Application.internetReachability,
				os.time(),
				...)
		end
	else
		ReportManager:Report(
			step,
			self.agent_id,
			device_id,
			self.pkg_ver,
			self.assets_ver,
			UnityEngine.Application.internetReachability,
			os.time(),
			...)
	end
end

function ReportManager:Report(...)
	local url = GLOBAL_CONFIG.param_list.report_url
	if url == nil or url == "" then
		url = "http://report.ug05.youyannet.com/report.php"
	end

	local args = nil
	for i=1, select("#", ...) do
		if args == nil then
			args = tostring(select(i, ...))
		else
			args = args .. "\t" .. tostring(select(i, ...))
		end
	end

	print_log("args: ", args)
	local request = string.format(
		"%s?data=%s", url, tostring(mime.b64(args)))
	UtilU3d.RequestGet(request)
	--print_log("request: ", request)
end

-- 上报事件
function ReportManager:ReportLoginEvent()
	local url = GLOBAL_CONFIG.param_list.event_url
	if url == nil or url == "" then
		url = "http://cls.ug14.youyannet.com/api/qzw/report_event.php"
	end

	url = url .. "?type=%s&spid=%s&user_id=%s&role_id=%s&server_id=%s&time=%s"
	local user_vo = GameVoManager.Instance:GetUserVo()
	local main_role_vo =  GameVoManager.Instance:GetMainRoleVo()

	url = string.format(url,
		1,
		GLOBAL_CONFIG.package_info.config.agent_id,
		user_vo.plat_name,
		main_role_vo.role_id,
		user_vo.plat_server_id,
		os.time())

	UtilU3d.RequestGet(url)
end

function ReportManager:ReportPay(money)
	local url = GLOBAL_CONFIG.param_list.pay_event_url
	if url == nil or url == "" then
		url = "http://cls.ug14.youyannet.com/api/qzw/report_event.php"
	end

	url = url .. "?type=%s&spid=%s&user_id=%s&role_id=%s&server_id=%s&data=%s&time=%s"
	local user_vo = GameVoManager.Instance:GetUserVo()
	local main_role_vo =  GameVoManager.Instance:GetMainRoleVo()

	url = string.format(url,
		2,
		GLOBAL_CONFIG.package_info.config.agent_id,
		user_vo.plat_name,
		main_role_vo.role_id,
		user_vo.plat_server_id,
		money,
		os.time())
	UtilU3d.RequestGet(url)
	--print_log("request pay: ", url)
end

function ReportManager:ReportRoleInfo(server_id, role_name, role_id, role_level, create_time, rep_type)
	self:ReportUrlToSQ(server_id, role_name, role_id, role_level, create_time, rep_type)
end

-- 上报神起 角色数据
function ReportManager:ReportUrlToSQ(server_id, role_name, role_id, role_level, create_time, rep_type)
	local user_vo = GameVoManager.Instance:GetUserVo()
	local main_role_vo =  GameVoManager.Instance:GetMainRoleVo()

	local url_ip = "http://118.89.31.40:50086/UserCharacter/SaveUserCharacter"
	local CPSeriesId = "ug05"
	local key = "c5a88ed5a06ce1ea55cd4e04f333207f"
	local CPId = 1
	local agent_id = GLOBAL_CONFIG.package_info.config.agent_id
	local user_id = user_vo.plat_name
	local is_shenqi = GLOBAL_CONFIG.param_list.switch_list.is_shenqi

	if is_shenqi then
		-- print_error(">>>>>玩家数据上报测试", server_id, role_name, role_id, role_level, create_time, rep_type)
		local Sign = ""
		local signData = user_id .. server_id .. role_id .. role_level .. rep_type .. CPId .. key
		if MD52 ~= nil then
			Sign = string.upper(MD52.GetMD5(signData))
		else
			Sign = string.upper(MD5.GetMD5FromString(signData))
		end

		local url = string.format("%s?user_id=%s&server_id=%s&role_name=%s&role_id=%s&role_level=%s&create_time=%s&type=%s&CPId=%s&CPSeriesId=%s&Sign=%s",
			url_ip, user_id, server_id, HttpClient:UrlEncode(role_name), role_id, role_level, create_time, rep_type, CPId, CPSeriesId, Sign)
		local call_back = function (url, is_succ, data)

		end
		HttpClient:Request(url, call_back)
	end
end

function ReportManager:ReportChatMsgToSQ(server_id, role_name, role_id, role_level, role_glod, chat_type, chat_msg, chat_role)
	local user_vo = GameVoManager.Instance:GetUserVo()

	local url_ip = "http://118.89.31.40:50086/Chat/CreateChatInfo"
	local key = "c5a88ed5a06ce1ea55cd4e04f333207f"
	local CPSeriesId = "ug05"
	local CPId = 1
	local agent_id = GLOBAL_CONFIG.package_info.config.agent_id
	local is_shenqi = GLOBAL_CONFIG.param_list.switch_list.is_shenqi
	local user_id = user_vo.plat_name
	local chat_time = os.time()
	local ip_addr = ReportManager:GetIpAddress()
	local device_id = DeviceTool.GetDeviceID()

	if is_shenqi then
		-- print_error(">>>>>聊天上报测试", server_id, role_name, role_id, role_level, role_glod, chat_type, chat_msg, chat_role)
		local mySign = ""
		local signData = server_id .. user_id .. role_level .. chat_type .. key
		if MD52 ~= nil then
			mySign = string.upper(MD52.GetMD5(signData))
		else
			mySign = string.upper(MD5.GetMD5FromString(signData))
		end

		local url = string.format("%s?ip_addr=%s&device_id=%s&user_id=%s&server_id=%s&role_name=%s&role_id=%s&role_level=%s&role_glod=%s&chat_type=%s&chat_msg=%s&chat_role=%s&chat_time=%s&CPId=%s&CPSeriesId=%s&Sign=%s",
			url_ip, ip_addr, device_id, user_id, server_id, HttpClient:UrlEncode(role_name), role_id, role_level, role_glod, chat_type, HttpClient:UrlEncode(chat_msg), chat_role, chat_time, CPId, CPSeriesId, mySign)
		-- print("requrl ", url)
		local call_back = function (url, is_succ, data)

		end
		HttpClient:Request(url, call_back)
	end
end

--获得当前ip地址
function ReportManager.GetIpAddress()
	-- return PlatformBinder:JsonCall("call_get_ip_address")
	if nil ~= GLOBAL_CONFIG.param_list and nil ~= GLOBAL_CONFIG.param_list.client_ip then
		return GLOBAL_CONFIG.param_list.client_ip
	end

	return "0.0.0.0"
end

function ReportManager:ReportMessage(server_id, role_name, role_id, role_level, role_gold, chat_type, chat_msg, chat_role, to_role_name, to_role_level, device_code, ip, uid)
	-- 上报聊天信息
	self:ReportChatMsg(server_id, role_name, role_id, role_level, role_gold, chat_type, chat_msg, chat_role, to_role_name, to_role_level, device_code, ip, uid)
	-- 上报聊天信息给悠迅
	-- self:ReportChatMsgToYX(server_id, role_name, role_id, role_level, role_gold, chat_type, chat_msg, chat_role, to_role_name)
	-- 上报聊天信息给呆萌
	-- self:ReportChatMsgToDM(server_id, role_name, role_id, role_level, role_gold, chat_type, chat_msg, chat_role, to_role_name)
end

-- 上报聊天信息给悠迅
function ReportManager:ReportChatMsgToYX(server_id, role_name, role_id, role_level, role_gold, chat_type, chat_msg, chat_role, to_role_name)
	local is_youxun = GLOBAL_CONFIG.param_list.switch_list.is_youxun
	if is_youxun then
		local url_ip = "http://api.yooxun.com/mobilechat.php"
		local genre = 1

		local key = GLOBAL_CONFIG.param_list.switch_list.is_youxun_key or "6696d8615d08505bb3a019a59229489f"
		local game = GLOBAL_CONFIG.param_list.switch_list.is_youxun_game or 143

		-- local is_iphone = UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer
		-- if is_iphone then
		-- 	game = 144
		-- 	key = "14f29fdbabce2f5f9bdc71702d69ccad"
		-- end

		local uid = role_id
		local mid = chat_role
		if mid == "" or nil == mid then
			mid = 0
		end
		local time = os.time()
		local chat = os.time()
		local uame = role_name
		local mame = to_role_name or ""
		local server = server_id
		local _type = "世界"
		if chat_type == CHANNEL_TYPE.PRIVATE then
			_type = "私聊"
		elseif chat_type == CHANNEL_TYPE.GUILD or chat_type == CHANNEL_TYPE.GUILD_SYSTEM then
			_type = "仙盟"
		elseif chat_type == CHANNEL_TYPE.SPEAKER then
			_type = "喇叭"
		elseif chat_type == CHANNEL_TYPE.TEAM then
			_type = "队伍"
		elseif chat_type == CHANNEL_TYPE.CAMP then
			_type = "阵营"
		end
		local body = chat_msg
		local signData = game .. uid .. time .. key
		local sign = string.lower(MD52.GetMD5(signData))

		local url = string.format("%s?genre=%s&game=%s&uid=%s&mid=%s&time=%s&chat=%s&uame=%s&mame=%s&server=%s&type=%s&body=%s&sign=%s",
			url_ip, genre, game, uid, mid, time, chat, HttpClient:UrlEncode(uame), HttpClient:UrlEncode(mame),
			server, HttpClient:UrlEncode(_type), HttpClient:UrlEncode(body), sign)

		local call_back = function (url, is_succ, data)

		end
		HttpClient:Request(url, call_back)
	end
end

-- 上报聊天信息给呆萌
function ReportManager:ReportChatMsgToDM(server_id, role_name, role_id, role_level, role_gold, chat_type, chat_msg, chat_role, to_role_name)
	local is_daimeng = GLOBAL_CONFIG.param_list.switch_list.is_daimeng
	if is_daimeng then
		local url_ip = "http://open.1090.cn/cs/chat/log"
		local app_id = "10001"
		local app_key = "db73704ed542fcd93628706fa6d29d95"
		local time = os.time()

		local user_vo = GameVoManager.Instance:GetUserVo()
		local user_info = AgentAdapter.Instance:GetUserInfo()

		local plat_id = user_vo.plat_name
		local uid = user_info.UserID or 0
		if uid == "nil" then
			uid = 0
		end
		local server_id = server_id
		local role_id = role_id
		local role_name = role_name
		local role_level = role_level
		local role_gold = role_gold
		local _chat_type = DM_CHANNEL_TYPE[chat_type] or 0
		local chat_msg = chat_msg
		local chat_time = os.time()
		local chat_role = to_role_name or ""
		local ip = ReportManager:GetIpAddress()
		local device_code = self.device_id

		local data = string.format("[{\"chat_time\":%s,\"ip\":\"%s\",\"role_gold\":%s,\"role_level\":%s,\"chat_msg\":\"%s\",\"server_id\":%s,\"role_name\":\"%s\",\"chat_type\":%s,\"uid\":\"%s\",\"chat_role\":\"%s\",\"role_id\":\"%s\",\"device_code\":\"%s\",\"plat_id\":\"%s\"}]",
			chat_time, ip, role_gold, role_level, chat_msg, server_id, role_name, _chat_type, uid, chat_role, role_id, device_code, plat_id)

		data = mime.b64(data)

		local sign = string.lower(MD52.GetMD5(app_id .. data .. time .. app_key))   -- 签名
		data = HttpClient:UrlEncode(data)									-- 加密

		local url = string.format("%s?app_id=%s&data=%s&time=%s&sign=%s", url_ip, app_id, data, time, sign)

		local call_back = function (url, is_succ, data)

		end
		HttpClient:Request(url, call_back)
	end
end

-- 上报聊天信息
function ReportManager:ReportChatMsg(server_id, role_name, role_id, role_level, role_gold, chat_type, chat_msg, chat_role_id, to_role_name, to_role_level, device_code, ip, uid)
	local chat_report_url = GLOBAL_CONFIG.param_list.chat_report_url
	if chat_report_url and "" ~= chat_report_url then
		local url_ip = chat_report_url
		local time = os.time()

		local plat_id = ChannelAgent.GetChannelID()

		local user_vo = GameVoManager.Instance:GetUserVo()
		if user_vo then
			uid = uid or user_vo.plat_name or ""
		end

		local server_id = server_id
		local role_id = role_id
		local role_name = role_name
		local role_level = role_level
		local role_gold = role_gold
		local chat_msg = chat_msg
		local chat_time = os.time()
		chat_role_id = chat_role_id or 0
		to_role_name = to_role_name or ""
		device_code = device_code or self.device_id
		ip = ip or ReportManager:GetIpAddress()

		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local vip_level = main_role_vo.vip_level or 0
		to_role_level = to_role_level or 0

		-- local data = string.format("[{\"chat_time\":%s,\"client_ip\":\"%s\",\"role_gold\":%s,\"role_level\":%s,\"chat_msg\":\"%s\",\"server_id\":%s,\"role_name\":\"%s\",\"chat_type\":%s,\"uid\":\"%s\",\"chat_role\":\"%s\",\"role_id\":\"%s\",\"device_id\":\"%s\",\"plat_id\":\"%s\"}]",
		-- 	chat_time, ip, role_gold, role_level, chat_msg, server_id, role_name, _chat_type, uid, chat_role, role_id, device_code, plat_id)
		local data = string.format("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",
			plat_id, device_code, uid, server_id, role_id, role_name, role_level, role_gold, chat_type, chat_msg, chat_role_id, vip_level, to_role_name, to_role_level)

		data = mime.b64(data)

		local url = string.format("%s?game=ug05&data=%s", url_ip, data)

		local call_back = function (url, is_succ, data)
		end
		HttpClient:Request(url, call_back)
	end
end