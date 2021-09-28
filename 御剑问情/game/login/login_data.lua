LoginData = LoginData or BaseClass()

-- 服id分段
local show_1500 = 1500
local show_1600 = 1600
local show_2000 = 2000

function LoginData:__init()
	if LoginData.Instance then
		print_error("[LoginData] Attemp to create a singleton twice !")
	end
	LoginData.Instance = self

	self.role_list_ack_info = {
		result = 0,
		count = 0,
		role_list = {}
	}

	self.curr_select_role_id = -1				-- 当前选择角色的ID
	self.combine_data = {}
end

function LoginData:__delete()
	LoginData.Instance = nil
end

function LoginData:SetRoleListAck(protocol)
	self.role_list_ack_info.result = protocol.result or 0
	self.role_list_ack_info.count = protocol.count

	local role_list = protocol.role_list or protocol.combine_role_list
	self.role_list_ack_info.role_list = role_list

	-- 设置用户数据
	local user_vo = GameVoManager.Instance:GetUserVo()
	user_vo:ClearRoleList()
	for i = 1, protocol.count do
		user_vo:AddRole(
			role_list[i].role_id,
			role_list[i].role_name,
			role_list[i].avatar,
			role_list[i].sex,
			role_list[i].prof,
			role_list[i].country,
			role_list[i].level,
			role_list[i].create_time,
			role_list[i].last_login_time,
			role_list[i].wuqi_id,
			role_list[i].shizhuang_wuqi,
			role_list[i].shizhuang_body,
			role_list[i].wing_used_imageid,
			role_list[i].halo_used_imageid)
	end
end

function LoginData:GetRoleListAck()
	return self.role_list_ack_info
end

function LoginData:SetCurrSelectRoleId(role_id)
	self.curr_select_role_id = role_id
end

function LoginData:GetCurrSelectRoleId()
	return self.curr_select_role_id
end

--根据type, index获取服装的配置
function LoginData:GetFashionConfig(part_type, index)
	local fashion_cfg_list = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg
	for k, v in pairs(fashion_cfg_list) do
		if v.part_type == part_type and index == v.index then
			return v
		end
	end
	return nil
end

function LoginData:GetLastLoginServer()
	local last_server = UnityEngine.PlayerPrefs.GetString("PRVE_SRVER_ID")

	if nil == last_server or "" == last_server then
		last_server = GLOBAL_CONFIG.server_info.last_server
	end

	if nil ~= last_server and "" ~= last_server then
		if not self:CheckServerExist(tonumber(last_server)) then
			last_server = self:GetNewServer()
		end
	else
		last_server = self:GetNewServer()
	end

	return tonumber(last_server)
end

-- 检查服务器是否存在
function LoginData:CheckServerExist(server_id)
	local show_list = self:GetShowServerList()
	local has_find = false
	for k,v in pairs(show_list) do
		if tonumber(v.id) == server_id then
			has_find = true
			break
		end
	end
	return has_find
end

function LoginData:GetNewServer()
	local server_id = 1
	local show_list = self:GetShowServerList()
	for k,v in pairs(show_list) do
		local id = tonumber(v.id)
		if id > server_id and id < show_1500 then
			server_id = id
		end
	end
	return server_id
end

-- 获得服务器表
function LoginData:GetShowServerList()
	local server_offset = GLOBAL_CONFIG.server_info.server_offset or 0 --偏移id
	if server_offset >= 1500 then
		server_offset = 0
	end

	-- 过滤要显示的服
	local show_list = {}
	local server_list = GLOBAL_CONFIG.server_info.server_list
	local plat_account_type = GameVoManager.Instance:GetUserVo().plat_account_type

	-- ------ test-------------
	-- for k,v in pairs(server_list) do
	-- 	if v.id == 7 then
	-- 		v.flag = 4
	-- 		v.open_time = 1511330990
	-- 	end
	-- end

	-- for i=1,102 do
	-- 	local t = TableCopy(server_list[1])
	-- 	t.id = #server_list + 1
	-- 	table.insert(server_list, t)
	-- end
	-- -----------------------
	for _, v in pairs(server_list) do
		if (PLAT_ACCOUNT_TYPE_TEST == plat_account_type or 4 ~= v.flag) and v.id > server_offset then	-- 非测试号屏蔽测试服且大于偏侈值的
			table.insert(show_list, v)
		end
	end

	table.sort(show_list, function (a, b)
		return a.id < b.id
	end)

	return show_list
end

-- 是否可登陆指定的服务器
function LoginData:IsCanLoginServer(server_id, now_server_time)
	local user_vo = GameVoManager.Instance:GetUserVo()
	local server_vo = self:GetServerVoById(server_id)
	if nil == server_vo then
		return false, Language.Login.ServerNotExist
	end

	local client_time = GLOBAL_CONFIG.client_time and tonumber(GLOBAL_CONFIG.client_time) or 0
	now_server_time = now_server_time or GLOBAL_CONFIG.server_info.server_time + (Status.NowTime - client_time)

	if PLAT_ACCOUNT_TYPE_COMMON == user_vo.plat_account_type and nil ~= server_vo.open_time and nil ~= server_vo.ahead_time
		and now_server_time < server_vo.open_time - server_vo.ahead_time then
			return false, Language.Login.ServerOpenTips2
	end

	if PLAT_ACCOUNT_TYPE_COMMON == user_vo.plat_account_type and nil ~= server_vo.pause_time and 0 < server_vo.pause_time
		and now_server_time < server_vo.pause_time then
			return false, Language.Login.ServerOpenTips3
	end

	return true
end

function LoginData:GetShowServerNameById(server_id)
	return self:GetShowServerName(self:GetServerVoById(server_id))
end

-- 获得要显示的服务器名字
function LoginData:GetShowServerName(server_vo)
	if nil == server_vo then
		return "undefind"
	end

	local show_server_id = server_vo.id
	-- 处理0 - 1500内的服
	local server_offset = GLOBAL_CONFIG.server_info.server_offset or 0
	if server_offset >= 1500 then
		server_offset = 0
	end
	if show_server_id <= show_1500 and show_server_id > server_offset then 	--偏移id
		show_server_id = show_server_id - server_offset
	end

	-- 处理1500 - 1600内的服
	if show_server_id > show_1500 and show_server_id <= show_1600 then
		show_server_id = show_server_id - show_1500
	end

	-- 处理1600 - 2000的服
	if show_server_id > show_1600 and show_server_id < show_2000 then
		show_server_id = show_server_id - show_1600
	end

	local show_server_name = ""
	if show_2000 == show_server_id then
		show_server_name = server_vo.name
		local open_tips = self:GetShowServerOpenTips(server_vo)
		if "" ~= open_tips then
			show_server_name = show_server_name .. "\n" .. open_tips
		end
	else
		-- 分服 A B C D
		if 1 == GLOBAL_CONFIG.server_info.server_zone_flag then
			if GLOBAL_CONFIG.server_info.server_zone_subscript ~= nil  then
				local zone_subscript_t = Split(GLOBAL_CONFIG.server_info.server_zone_subscript, "_")
				if nil ~= next(zone_subscript_t) then
					show_server_id = GetRightServerAndPrefix(show_server_id, zone_subscript_t)
				end
			end
		end

		show_server_name = show_server_id .. Language.Login.Fu .. "-" .. server_vo.name
		local open_tips = self:GetShowServerOpenTips(server_vo)
		if "" ~= open_tips then
			show_server_name = show_server_name .. "\n" .. open_tips
		end
	end

	return show_server_name
end

-- 服务器的开启提示
function LoginData:GetShowServerOpenTips(server_vo)
	if nil == server_vo then
		return "undefind"
	end

	local open_tips = ""
	local client_time = GLOBAL_CONFIG.client_time and tonumber(GLOBAL_CONFIG.client_time) or 0
	local now_server_time = GLOBAL_CONFIG.server_info.server_time + (Status.NowTime - client_time)

	-- 开服时间
	if nil ~= server_vo.open_time and now_server_time < server_vo.open_time then
		local t_time = os.date("*t", server_vo.open_time)
		open_tips = string.format(Language.Login.ServerOpenTips, t_time.month, t_time.day, t_time.hour, t_time.min)

	-- 维护时间
	elseif nil ~= server_vo.pause_time and now_server_time < server_vo.pause_time then
		local t_time = os.date("*t", server_vo.pause_time)
		open_tips = string.format(Language.Login.ServerOpenTips, t_time.month, t_time.day, t_time.hour, t_time.min)
	end

	return open_tips
end

function LoginData:GetRightServerAndPrefix(server_id, zone_subscript_t)
	local pre_subscript = 0
	local cur_subscript = 0
	local minus_pre_subscript = false
	for k,v in pairs(zone_subscript_t) do
		cur_subscript = tonumber(v)
		if server_id > pre_subscript and server_id <= cur_subscript then
			server_id = server_id - pre_subscript
			minus_pre_subscript = true
			break
		end
		pre_subscript = cur_subscript
	end
	local max_subscript = tonumber(zone_subscript_t[#zone_subscript_t])
	if not minus_pre_subscript and server_id > max_subscript then
		server_id = server_id - max_subscript
	end
	return server_id
end

function LoginData:GetServerVoById(server_id)
	local server_list = GLOBAL_CONFIG.server_info.server_list
	for k,v in pairs(server_list) do
		if v.id == server_id then
			return v
		end
	end

	return nil
end

function LoginData:GetServerFlag(server_id)
	local vo = self:GetServerVoById(server_id)
	return vo and vo.flag or 0
end

function LoginData:GetGetServerIP(server_id)
	local vo = self:GetServerVoById(server_id)
	return vo and vo.ip or ""
end

function LoginData:GetGetServerPort(server_id)
	local vo = self:GetServerVoById(server_id)
	return vo and vo.port or 0
end

function LoginData:GetServerName(server_id)
	local vo = self:GetServerVoById(server_id)
	return vo and vo.name or ""
end

function LoginData:SetCombineData(protocol)
	self.combine_data.count = protocol.count
	self.combine_data.combine_role_list = protocol.combine_role_list
end

function LoginData:GetCombineData()
	return self.combine_data
end

-- 进入正常服务器后清除合服数据，避免从合服切换到正常服出bug
function LoginData:ClearCombineData()
	self.combine_data = {}
end

-- 是否是封测服
function LoginData:IsClosedTest()
  	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
  	return main_role_vo.server_id and main_role_vo.server_id > show_1600 or false
end