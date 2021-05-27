AgentMs = {}
function AgentMs:Init()
	AgentMs.REPORT_EVENT_LOGIN_GAME = 1				-- 登录
end

function AgentMs:RegisterEvents()
	-- GlobalEventSystem:Bind(OtherEventType.SEND_CHAT_DATA, BindTool.Bind(self.OnSendChatData, self))
	GlobalEventSystem:Bind(OtherEventType.CREATE_ROLE_SUCC, BindTool.Bind(self.OnCreateRoleSucc, self))
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	GlobalEventSystem:Bind(OtherEventType.MAIN_ROLE_LEVEL_CHANGE, BindTool.Bind(self.OnMainRoleLevelChange, self))
	GlobalEventSystem:Bind(OtherEventType.MAIN_ROLE_CHANGE_NAME, BindTool.Bind(self.OnMainRoleChangeName, self))
end

-- 上报事件
function AgentMs:ReportEvent(event)
	local url = GLOBAL_CONFIG.param_list.event_url
	if nil == url or "" == url then
		-- --Log("请设置上报事件地址")
		return
	end

	url = url .. "?type=%s&spid=%s&user_id=%s&role_id=%s&server_id=%s&time=%s&sign=%s"
	local user_vo = GameVoManager.Instance:GetUserVo()
	local role_vo =  GameVoManager.Instance:GetMainRoleVo()
	local spid = AgentAdapter:GetSpid()
	local pname = AgentAdapter:GetPlatName()
	local now_time = os.time()
	local sign = UtilEx:md5Data(event .. spid .. pname .. role_vo.role_id .. user_vo.plat_server_id .. now_time .. "c8cae60e3fd8586258c1ea0c3ee00950") 

	url = string.format(url, event, spid, pname, role_vo.role_id, user_vo.plat_server_id, now_time, sign)
	print("EventReport, url=" .. url)
	HttpClient:Request(url, "")
end

-- 联系GM
function AgentMs:ContactGm(issue_type, issue_subject, issue_content)
	local url_str = GLOBAL_CONFIG.param_list.gm_report_url
	if nil ~= url_str and "" ~= url_str then
		local verify_callback = function(url, arg, data, size)
			local ret_t = cjson.decode(data)
			if nil == ret_t or 0 ~= ret_t.ret then
				SysMsgCtrl.Instance:ErrorRemind(Language.Setting.SendFail)
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.Setting.SendSucc)
			end
		end

		local user_vo = GameVoManager.Instance:GetUserVo()
		local role_vo =  GameVoManager.Instance:GetMainRoleVo()

		if user_vo and role_vo then
			local zone_id = AgentAdapter:GetSpid()
			local server_id = user_vo.plat_server_id
			local user_id = AgentAdapter:GetPlatName()
			local role_id =	role_vo.role_id
			local role_name = role_vo.name
			local role_level = role_vo.level
			local role_gold = 0
			local role_scene = role_vo.scene_id
			issue_subject = HttpClient:UrlEncode(issue_subject)		--问题标题 url_encode
			issue_content = HttpClient:UrlEncode(issue_content)		--问题正文
			
			url_str = url_str .. "?" ..
					"zone_id=" .. zone_id ..
					"&server_id=" .. server_id ..
					"&user_id=" .. user_id ..
					"&role_id=" .. role_id ..
					"&role_name=" .. zone_id ..
					"&role_level=" .. role_level ..
					"&role_gold=" .. role_gold ..
					"&role_scene=" .. role_scene ..
					"&issue_subject=" .. issue_subject ..
					"&issue_content=" .. issue_content
			HttpClient:Request(url_str, "", verify_callback)
		end
	end
end

--超级vip信息（界面资源id， 功能是否开启，开启的充值元宝需求）
function AgentMs:SVIPInfoRequest()
	local url_str = "http://l.cqtest.jianguogame.com:88/api/vip_open.php"
	local key = "hdISla9sjXphPqEoE8lZcg=="

	local user_vo = GameVoManager.Instance:GetUserVo()
	local role_vo =  GameVoManager.Instance:GetMainRoleVo()

	local plat_id = AgentAdapter:GetSpid()
	local server_id = user_vo.real_server_id
	local user_id = user_vo.account_id
	local role_id =	user_vo.cur_role_id
	local role_name = role_vo.name
	local role_level = role_vo[OBJ_ATTR.CREATURE_LEVEL]
	local time = os.time()
	local sign = UtilEx:md5Data(plat_id .. time .. key)

	url_str = url_str .. "?" ..
		"spid=" .. plat_id ..
		"&time=" .. time ..
		"&sign=" .. sign

	local verify_callback = function(url, arg, data, size)
		local ret_t = cjson.decode(data)
		if ret_t then
			if ret_t.ret == 0 and ret_t.data then
				SVipData.Instance:SetSVipInfo(ret_t.data)
			end
		end
	end

	HttpClient:Request(url_str, "", verify_callback)
end

-- 超级vip接口type为0是提交vip信息,type为1是查询是否提交过信息
function AgentMs:SVIPRequest(type, qq_id, mobile, birth, sex, name)
	-- type = type or 0
	-- qq_id = qq_id or "0"
	-- mobile = mobile or "0"
	-- birth = birth or "0"
	-- sex = sex or "0"
	-- name = name or "0"

	-- local url_str = "http://cls.cq13.huguangame.com/api/qzw/fetch_qq_gift.php"
	-- local key = "hdISla9sjXphPqEoE8lZcg=="

	-- local user_vo = GameVoManager.Instance:GetUserVo()
	-- local role_vo =  GameVoManager.Instance:GetMainRoleVo()

	-- local plat_id = AgentAdapter:GetSpid()
	-- local server_id = user_vo.real_server_id
	-- local user_id = user_vo.account_id
	-- local role_id =	user_vo.cur_role_id
	-- local role_name = role_vo.name
	-- local role_level = role_vo[OBJ_ATTR.CREATURE_LEVEL]
	-- local time = os.time()
	-- local sign = UtilEx:md5Data(plat_id .. server_id .. user_id .. role_id .. role_name .. time .. key)

	-- url_str = url_str .. "?" ..
	-- 	"plat_id=" .. plat_id ..
	-- 	"&server_id=" .. server_id ..
	-- 	"&user_id=" .. user_id ..
	-- 	"&role_id=" .. role_id ..
	-- 	"&role_name=" .. role_name ..
	-- 	"&role_level=" .. role_level ..
	-- 	"&qq_id=" .. qq_id ..
	-- 	"&mobile=" .. mobile ..
	-- 	"&birth=" .. birth ..
	-- 	"&sex=" .. sex ..
	-- 	"&name=" .. name ..
	-- 	"&time=" .. time ..
	-- 	"&sign=" .. sign ..
	-- 	"&type=" .. type

	-- local verify_callback = function(url, arg, data, size)
	-- 	local ret_t = cjson.decode(data)
	-- 	if ret_t then
	-- 		if ret_t.ret == 0 then			-- 提交成功
	-- 			SVipData.Instance:SetSVipRecFlag(true)
	-- 		elseif ret_t.ret == 1 then		-- 已经提交过
	-- 			SVipData.Instance:SetSVipRecFlag(true)
	-- 		elseif ret_t.ret == 2 then
	-- 			SVipData.Instance:SetSVipRecFlag(false)
	-- 		else
	-- 		end
	-- 	end
	-- end

	-- HttpClient:Request(url_str, "", verify_callback)
end

-- 初始化本地推送
function AgentMs:InitLocalPush()
	PlatformBinder:JsonCall("call_agent_clear_all_notification")

	local game_name = Language.Common.GameName[1]
	if nil ~= AgentAdapter.GetGameName then
		game_name = AgentAdapter:GetGameName()
	end

	local date_t = Split(os.date("%w-%H-%M-%S", os.time()), "-")
	local today_s = date_t[2] * 3600 + date_t[3] * 60 + date_t[4]
	local offset_1 = 12 * 3600 + 00 * 60 - today_s
	local offset_2 = 19 * 3600 + 00 * 60 - today_s
	local offset_3 = 19 * 3600 + 30 * 60 - today_s

	local function create_local_notification(id, weekday, content, delay)
		if delay <= 0 then delay = delay + 7 * 86400 end
		local arg_t = {
			["id"] = 586000 + weekday * 100 + id,
			["title"] = game_name,
			["content"] = content,
			["delay"] = delay,
			["type"] = "week",
		}

		PlatformBinder:JsonCall("call_agent_create_local_notification", cjson.encode(arg_t))
	end

	for i = 0, 6 do
		local weekday = math.mod(date_t[1] + i, 7)
		create_local_notification(1, weekday, Language.Push[1], offset_1 + i * 86400)
		create_local_notification(2, weekday, Language.Push[2], offset_2 + i * 86400)
		if 2 == weekday or 4 == weekday or 6 == weekday then
			create_local_notification(3, weekday, Language.Push[3], offset_3 + i * 86400)
		end
	end
	create_local_notification(4, 8, Language.Push[4], 48 * 3600)
end

function AgentMs:ReportChatAndMailMsgToYooXun(role_id, role_name, name, server_id, type, msg, genre)
	local report_url = "http://api.yooxun.com/mobilechat.php"
	local plat_id = ""
	local user_id = ""
	local time = os.time()

	if AgentAdapter.is_yooxun_url then
		report_url = AgentAdapter.is_yooxun_url
		-- --Log("change_url=" .. report_url)
	end

	if AgentAdapter.GetSpid then
		plat_id = AgentAdapter:GetSpid()
		--Log("plat_id=" .. plat_id)
	end

	if AgentMs:IsYXGame(plat_id) ~= nil and AgentMs:IsYXKey(plat_id) ~= nil then
		if AgentAdapter.GetOpenId then
			user_id = AgentAdapter:GetOpenId()
			--Log("user_id=" .. user_id)
		end
		
		if type == 1 then
			chat_type = "世界"
		elseif type == 2 then
			chat_type = "阵营"
		elseif type == 3 then
			chat_type = "仙盟"
		elseif type == 4 then
			chat_type = "组队"
		elseif type == 5 then
			chat_type = "私聊"
		elseif type == 6 then
			chat_type = "同屏"
		elseif type == 7 then
			chat_type = "喇叭"
		else
			chat_type =type
		end

		local game = AgentMs:IsYXGame(plat_id)
		local key = AgentMs:IsYXKey(plat_id)
		--Log("game=" .. game)
		--Log("key=" .. key)
		local sign = UtilEx:md5Data(game .. user_id .. time .. key)
		local url = string.format("%s?genre=%s&game=%s&uid=%s&mid=%s&time=%s&chat=%s&uame=%s&mame=%s&server=%s&type=%s&body=%s&sign=%s",
			report_url, genre, game, user_id, role_id, time, time, role_name, name, tostring(server_id), chat_type, msg, sign)
		print("requrl ", url)
		HttpClient:Request(url, "", nil)
	end
end

function AgentMs:IsYXGame(spid)
	local yx_games = {
		["ayx"] = 92,
		["lyx"] = 93,
		["ay7"] = 99,
		["ly7"] = 100,
		-- ["dev"] = 999,
	}

	if yx_games[spid] ~= nil then
		return yx_games[spid]
	end
	--Log("not is_yooxun_game")
	return AgentAdapter.is_yooxun_game
end

function AgentMs:IsYXKey(spid)
	local yx_keys = {
		["ayx"] = "92765924e973501b93102d4e04f6cd0e",
		["lyx"] = "cc38378b609f5e6536187e2ef8c89a38",
		["ay7"] = "73daf32dcbc17de4aecbff7c560e3ff8",
		["ly7"] = "777190a6ac17767cc5470cdfe5f139b2",
		-- ["dev"] = "ddd",
	}

	if yx_keys[spid] ~= nil then
		return yx_keys[spid]
	end
	--Log("not is_yooxun_key")
	return AgentAdapter.is_yooxun_key
end

function AgentMs:ReportUrl(server_id, role_name, role_id, role_level, create_time, type)
	local url_ip = "http://l.cqtest.jianguogame.com:88/asq/report_event.php"
	local plat_id = ""
	local user_id = ""

	if AgentAdapter.GetSpid then
		plat_id = AgentAdapter:GetSpid()
		--Log("plat_id=" .. plat_id)
	end

	if AgentAdapter.GetPlatName then
		user_id = AgentAdapter:GetPlatName()
		--Log("user_id=" .. user_id)
	end
	
	local url = string.format("%s?user_id=%s&plat_id=%s&server_id=%s&role_name=%s&role_id=%s&role_level=%s&create_time=%s&type=%s",
		url_ip, user_id, plat_id, server_id, role_name, role_id, role_level, create_time, type)
	print("requrl ", url)
	HttpClient:Request(url, "", nil)
end

function AgentMs:ReportCreateRoleInfo(role_id)
	local url = "http://l.cqtest.jianguogame.com:88/api/create_role_limit.php"
	local plat_id = ""
    local device_id = ""
	if AgentAdapter.GetSpid then
		plat_id = AgentAdapter:GetSpid()
		--Log("plat_id=" .. plat_id)
	end

--	if AgentAdapter.GetPlatName then
--		user_id = AgentAdapter:GetPlatName()
--		--Log("user_id=" .. user_id)
--	end
	
    if cc.PLATFORM_OS_ANDROID == PLATFORM then
		device_id = PlatformAdapter.GetPhoneUniqueIMEI()
	elseif cc.PLATFORM_OS_IPHONE == PLATFORM 
	or cc.PLATFORM_OS_IPAD == PLATFORM 
	or cc.PLATFORM_OS_MAC == PLATFORM then
		device_id = PlatformAdapter.GetPhoneUniqueId()
	end

	local report = string.format("%s?plat_id=%s&role_id=%s&device=%s",
		url, plat_id, role_id, device_id)
	HttpClient:Request(report, "", nil)
end
function AgentMs:InitLimitInfo()
	local key = "hdISla9sjXphPqEoE8lZcg=="
	local spid = AgentAdapter:GetSpid()
	local now_time = os.time()
	local sign = UtilEx:md5Data(spid .. now_time .. key)  
	local limit_url = "http://l.cqtest.jianguogame.com:88/api/ban_register.php?spid=%s&time=%s&sign=%s&type=0"
	limit_url = string.format(limit_url,spid,now_time,sign)
	local verify_callback = function(url, arg, data, size)
		local ret_t = cjson.decode(data)
		if ret_t and 0 == ret_t.ret and ret_t.data then
			local user_vo = GameVoManager.Instance:GetUserVo()
			user_vo.create_role_limit_day = tonumber(ret_t.data.open_day) or 0
			user_vo.create_role_limit_level = tonumber(ret_t.data.level) or 0
--            GLOBAL_CONFIG.param_list.switch_list.open_CharacterCreation  限制创角天数
			-- print("数据返回:",user_vo.create_role_limit_day,user_vo.create_role_limit_level)
		end
	end
	HttpClient:Request(limit_url, "", verify_callback)
end	

function AgentMs:GetShiPoInfo(spid)
	local shipo_info = {
		["asp"] = {app_id = 10014, app_key = "616e6440a675c5756084af04a249c47e"},
		["isp"] = {app_id = 10014, app_key = "616e6440a675c5756084af04a249c47e"},
		["dev"] = {app_id = 10014, app_key = "616e6440a675c5756084af04a249c47e"},
	}

	if shipo_info[spid] then
		return shipo_info[spid]
	end
end

function AgentMs:ReportChatMsgToShiPo(server_id, role_name, role_id, role_level, role_gold, chat_type, chat_msg, chat_role, chat_role_name)
	local url_ip = "http://om.tiziyouxi.net/api/chat_log"
	local plat_id = AgentAdapter.GetSpid and AgentAdapter:GetSpid() or ""
	local user_id = AgentAdapter.GetPlatName and AgentAdapter:GetPlatName() or ""
	local chat_time = os.time()
	local ip_addr = PlatformAdapter.GetIpAddress()
	local device_id = tostring(PlatformAdapter.GetPhoneUniqueId())
	local app_id = ""
	local app_key = ""

	local app_info = AgentMs:GetShiPoInfo(plat_id)
	if nil ~= app_info then
		app_id = app_info.app_id
		app_key = app_info.app_key
	else
		AgentMs.ReportChatMsgToShiPo = nil
		return
	end

	server_id = server_id or 0
	role_name = role_name or ""
	role_id = role_id or ""
	role_level = role_level or ""
	role_gold = role_gold or ""
	chat_type = chat_type or ""
	chat_msg = chat_msg or ""
	chat_role = chat_role or ""
	chat_role_name = chat_role_name or ""

	local url_format = "%s?app_id=%s&ip_addr=%s&plat_id=%s&device_id=%s&server_id=%s&role_id=%s&user_id=%s&role_level=%s&role_gold=%s&chat_type=%s&chat_msg=%s&chat_role=%s&chat_time=%s&role_name=%s"
	local url = string.format(url_format, url_ip, app_id, ip_addr, plat_id, device_id, server_id, role_id, user_id, role_level, role_gold, chat_type, HttpClient:UrlEncode(chat_msg), HttpClient:UrlEncode(chat_role_name), chat_time, HttpClient:UrlEncode(role_name))
	-- print("url--->", url)
	HttpClient:Request(url, "", nil)
end

function AgentMs:PushChatMsg(server_id,role_id,role_name,role_level,role_gold,chat_type,chat_msg,chat_role,role_vip,chat_role_name,chat_role_level)
	local url_ip = GLOBAL_CONFIG.param_list.chat_report_url
	local plat_id = AgentAdapter.GetSpid and AgentAdapter:GetSpid() or ""
	local user_id = AgentAdapter.GetPlatName and AgentAdapter:GetPlatName() or ""
	local device_id = tostring(PlatformAdapter.GetPhoneUniqueId())

	server_id = server_id or 0
	role_name = role_name or ""
	role_id = role_id or ""
	role_level = role_level or ""
	role_gold = role_gold or ""
	chat_type = chat_type or ""
	chat_msg = chat_msg or ""
	chat_role = chat_role or ""
	chat_role_name = chat_role_name or ""
	role_vip = role_vip or ""
	chat_role_level = chat_role_level or ""

	--mime.b64()
	--这里需要使用base64_encode来编码：在计算机中任何数据都是按ascii码存储的，而ascii码的128～255之间的值是不可见字符。
	--而在网络上交换数据时，比如说从A地传到B地，往往要经过多个路由设备，由于不同的设备对字符的处理方式有一些不同，
	--这样那些不可见字符就有可能被处理错误，这是不利于传输的。所以就先把数据先做一个Base64编码，统统变成可见字符，这样出错的可能性就大降低了。
	local urlData = string.format("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",tostring(plat_id),tostring(device_id),tostring(user_id),tostring(server_id),tostring(role_id),
		tostring(role_name),tostring(role_level),tostring(role_gold),tostring(chat_type),tostring(chat_msg),tostring(chat_role),tostring(role_vip),tostring(chat_role_name),tostring(chat_role_level))
	local game_name = 'cq20'
	local url = string.format("%s?game=%s&data=%s",tostring(url_ip),tostring(game_name),tostring(mime.b64(urlData)))
	HttpClient:Request(url, "", nil)
end

function AgentMs:IsShenQi(spid)
	local sq_spids = {
		["asq"] = 1,
		["asa"] = 1,
		["lsa"] = 1,
		["lsq"] = 1,
		-- ["dev"] = 1,
	}

	if sq_spids[spid] then
		return true
	end
	return false
end

function AgentMs.FormatUrl(url, param_t)
	return url .. "?" .. table.concat(param_t, "&")
end

function AgentMs:OnMainRoleChangeName(param)
	local change_name = param.change_name or ""

	self:ReportToSheQi("roleResetName", {role_name = change_name})
end

function AgentMs:OnMainRoleLevelChange()
	self:ReportToSheQi("levelChange")
end

function AgentMs:OnRecvMainRoleInfo()
	self:ReportToSheQi("login")

	self:ReportToYouXunLoginInfo()
end

function AgentMs:OnCreateRoleSucc()
	self:ReportToSheQi("createRole")
end

function AgentMs:ReportToYouXunLoginInfo()
	local plat_id = AgentAdapter.GetSpid and AgentAdapter:GetSpid() or ""
	if AgentMs:IsYXGame(plat_id) == nil then
		return
	end

	local user_id = AgentAdapter.GetOpenId and AgentAdapter:GetOpenId() or ""
	local user_vo = GameVoManager.Instance:GetUserVo()
	local server_id = user_vo.plat_server_id or 0
	local role_id = tostring(user_vo.cur_role_id)

	local param_t = {
		"plat_id=" .. plat_id,
		"user_id=" .. user_id,
		"role_id=" .. role_id,
		"server_id=" .. server_id,
	}
	local url = AgentMs.FormatUrl("http://l.cqtest.jianguogame.com:88/api/yooxun_info.php", param_t)
	HttpClient:Request(url, "", function(url, arg, data, size)
		-- print("--->>>ReportToYouXunLoginInfo", url, data)
	end)
end

function AgentMs:ReportToSheQi(rep_type, param)
	local plat_id = AgentAdapter.GetSpid and AgentAdapter:GetSpid() or ""
	if not self:IsShenQi(plat_id) then
		return
	end

	local user_vo = GameVoManager.Instance:GetUserVo()
	local role_vo =  GameVoManager.Instance:GetMainRoleVo()

	param = param or {}
	local rep_type = rep_type or ""
	local user_id = AgentAdapter.GetPlatName and AgentAdapter:GetPlatName() or ""
	local CPSeriesId = "cq20"
	local server_id = user_vo.plat_server_id or 0
	local role_id = tostring(user_vo.cur_role_id)
	local role_name = param.role_name or role_vo.name or ""
	local role_level = role_vo[OBJ_ATTR.CREATURE_LEVEL] or 0
	local CPId = 1
	local create_time = os.time()

	local key = "c5a88ed5a06ce1ea55cd4e04f333207f"
	local Sign = string.upper(UtilEx:md5Data(table.concat({user_id, server_id, role_id, role_level, rep_type, CPId, key})))

	local param_t = {
		"user_id=" .. user_id,
		"CPSeriesId=" .. CPSeriesId,
		"server_id=" .. server_id,
		"role_id=" .. role_id,
		"role_name=" .. HttpClient:UrlEncode(role_name),
		"role_level=" .. role_level,
		"create_time=" .. create_time,
		"type=" .. rep_type,
		"CPId=" .. CPId,
		"Sign=" .. Sign,
	}

	local url = AgentMs.FormatUrl("http://118.89.31.40:50086/UserCharacter/SaveUserCharacter", param_t)
	HttpClient:Request(url, "", function(url, arg, data, size)
	end)
end


--已有聊天推送，不用聊天监控
-- function AgentMs:OnSendChatData(chat_data)
-- 	if nil == chat_data then
-- 		return
-- 	end

-- 	-- 聊天数据
-- 	local chat_type = ChatData.UploadChannelType(chat_data.channel_type)
-- 	local chat_msg = chat_data.content or ""
-- 	local chat_role_name = chat_data.target_name or ""
-- 	local chat_role_id = chat_data.target_role_id or ""
-- 	local chat_time = os.time()

-- 	local user_vo = GameVoManager.Instance:GetUserVo()
-- 	local role_vo =  GameVoManager.Instance:GetMainRoleVo()

-- 	-- 其它参数
-- 	local plat_id = AgentAdapter.GetSpid and AgentAdapter:GetSpid() or ""
-- 	local user_id = AgentAdapter.GetPlatName and AgentAdapter:GetPlatName() or ""
-- 	local ip_addr = PlatformAdapter.GetIpAddress()
-- 	local device_id = tostring(PlatformAdapter.GetPhoneUniqueId())
-- 	local app_id = ""
-- 	local app_key = ""
-- 	local CPSeriesId = "cq13"
-- 	local server_id = user_vo.plat_server_id or 0
-- 	local role_name = role_vo.name or ""
-- 	local role_id = tostring(user_vo.cur_role_id)
-- 	local role_level = role_vo[OBJ_ATTR.CREATURE_LEVEL] or 0
-- 	local role_gold = role_vo[OBJ_ATTR.ACTOR_GOLD] or 0
-- 	local CPId = 1

-- 	if self:IsShenQi(plat_id) then
-- 		local key = "c5a88ed5a06ce1ea55cd4e04f333207f"
-- 		local Sign = string.upper(UtilEx:md5Data(table.concat({server_id, user_id, role_level, chat_type, key})))
-- 		local param_t = {
-- 			"CPSeriesId=" .. CPSeriesId,
-- 			"ip_addr=" .. ip_addr,
-- 			"device_id=" .. device_id,
-- 			"server_id=" .. server_id,
-- 			"role_id=" .. role_id,
-- 			"role_name=" .. HttpClient:UrlEncode(role_name),
-- 			"user_id=" .. user_id,
-- 			"role_level=" .. role_level,
-- 			"role_gold=" .. role_gold,
-- 			"chat_type=" .. chat_type,
-- 			"chat_msg=" .. HttpClient:UrlEncode(chat_msg),
-- 			"chat_role=" .. chat_role_id,
-- 			"chat_time=" .. chat_time,
-- 			"CPId=" .. CPId,
-- 			"Sign=" .. Sign,
-- 		}
-- 		local url = AgentMs.FormatUrl("http://118.89.31.40:50086/Chat/CreateChatInfo", param_t)
-- 		HttpClient:Request(url, "", function(url, arg, data, size)
-- 		end)
-- 	end
-- end

AgentMs:Init()
