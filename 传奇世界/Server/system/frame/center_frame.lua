--center_frame.lua

------------------------------------------------------------------------------------
--若干全局函数
------------------------------------------------------------------------------------
function table_contains(tab, object)
	if tab and object then
		for field, value in pairs(tab) do
			if object == value then return true end
		end
	end
	return false
end

function table_deep_opy(source, destiny)
	local destiny = destiny or {}
	for key, value in pairs(source or table.empty) do
		if destiny[key] then
			table.insert(destiny,value)
		else
			if type(value) == "table" then
				destiny[key] = table_deep_opy(value)
			else
				destiny[key] = value
			end
		end
	end
	return destiny
end

--获取配置
function get_center_config(id)
	local group_info = 
	{
		url = center_config[id].url,
		id = center_config[id].game_id, 
		name = center_config[id].game_name, 
		secret = center_config[id].app_secret
	}
	return group_info
end

--构建返回消息数据
function build_response_data(packs, result, pbody)
	local response = {head = packs.head}	
	response.head.Result = result
	response.head.Cmdid = packs.head.Cmdid + 1
	response.head.RetErrMsg = ERROR_MESSAGE_LIST[result] or ""
	if result == 0 then response.body = pbody end
	return cjson.encode(response)
end

--构建返回消息数据
function build_error_response_data(packs, result)
	local response = {head = {}}	
	response.head.PacketLen = packs.head.PacketLen
	response.head.Seqid = packs.head.Cmdid
	response.head.ServiceName = packs.head.ServiceName
	response.head.SendTime = packs.head.SendTime
	response.head.Version = packs.head.Version
	response.head.Authenticate = packs.head.Authenticate
	response.head.Result = result	
	response.head.Cmdid = packs.head.Cmdid + 1
	response.head.RetErrMsg = ERROR_MESSAGE_LIST[result] or ""
	return cjson.encode(response)
end

--获取mysql配置
function get_mysql_config(id)
	return mysql_config[id].name, mysql_config[id].user, mysql_config[id].password, mysql_config[id].host, mysql_config[id].port
end

----------------------------------------------------------------------------------------
--加载服务器配置数据，并建立映射关系
----------------------------------------------------------------------------------------
--创建服务器映射
function load_server_config(config)	
	--------------------------------------------------------------------------------------
	--加载物理服务器配置
	local sql = string.format("select * from servers_real where ser_group = %d", config)
	local result, records = mysql_callSQL(mysql_center, sql)
	if not result then
		return false
	end
	for i, record in pairs(records or {}) do
		print("servers_real:", serialize(record))
		local realId = tonumber(record.ser_id)
		local listen_ip = record.ser_ip

		local server_status = tonumber(record.ser_status)
		if server_status <= 0 then
			server_status = 4
		end
		--服务器配置列表
		server_real_infos[realId] = 
		{
			ip = record.ser_ip, 
			big = tonumber(record.ser_big), 
			tick = tonumber(record.ser_time),
			rank = tonumber(record.ser_rank),
			create = tonumber(record.ser_create), 
			status = server_status, 
		}
		--监听服对应的数据库列表
		server_dbx_infos[listen_ip] = 
		{
			host = record.ser_dbx_host, 
			name = record.ser_dbx_name,
			psw = record.ser_dbx_psw, 
			user = record.ser_dbx_user, 
			port = tonumber(record.ser_dbx_port),
		}
		--监听服对应的服务器列表
		if not server_listen_infos[listen_ip] then
			server_listen_infos[listen_ip] = {}
		end
		server_listen_infos[listen_ip][realId] = 
		{
			big = tonumber(record.ser_big), 
			tick = tonumber(record.ser_time),
			rank = tonumber(record.ser_rank),
			status = server_status, 
		}
	end		
	--------------------------------------------------------------------------------------
	--加载推荐服务器配置
	local sql = string.format("select * from servers_channel where chn_group = %d", config)
	local result, records = mysql_callSQL(mysql_center, sql)
	if not result then
		return false
	end
	--加载渠道和默认服务器信息
	for i, record in pairs(records or {}) do
		print("servers_channel:", serialize(record))
		local realId = tonumber(record.realId)
		if not server_channel_infos[realId] then
			server_channel_infos[realId] = {}
		end
		--保存服务器和渠道的关系
		table.insert(server_channel_infos[realId], record.channel)		
		--保存默认服务器信息
		if not server_default_infos[record.channel] then
			server_default_infos[record.channel] = {}
		end
		if tonumber(record.default) > 0 then
			table.insert(server_default_infos[record.channel], record.realId)
		end
	end
	--------------------------------------------------------------------------------------
	--加载游戏服务器配置
	local sql = string.format("select * from servers_game where game_group = %d", config)
	local result, records = mysql_callSQL(mysql_center, sql)
	if not result then
		return false
	end
	for i, record in pairs(records or {}) do
		local realId = tonumber(record.game_real)
		local serverId = tonumber(record.game_id)
		local real_info = server_real_infos[realId]
		if real_info then
			--游戏服务器信息列表
			server_game_infos[serverId] = 
			{
				real = realId, 
				name = record.game_name,
				ip = real_info.ip, 
				big = real_info.big, 
				tick = real_info.tick,
				rank = real_info.rank,
				create = real_info.create, 
				status = real_info.status, 
				channel = server_channel_infos[realId]
			}	
			print("server_game_infos:", serverId, serialize(server_game_infos[serverId]))
		end
	end	
	return true
end

--------------------------------------------------------------------------------------
--推送服务器列表
function push_server_lists()
	--[[
	local def_channel = nil
	local server_info = {}
	for serverId, record in pairs(server_game_infos) do
		for i, channel in pairs(record.channel or {}) do
			def_channel = channel
			if not server_info[channel] then
				local default_sers = server_default_infos[channel] or {}
				server_info[channel] = {ips = {}, servers = {}, default = default_sers}
			end
			server_info[channel].servers[serverId] = {name = record.name, real = record.real, status = tostring(record.status)}
			server_info[channel].ips[record.real] = record.ip
		end
	end
	if not server_info.default then
		server_info.default = server_info[def_channel]
	end
	
	--推送给地址服务器
	local serverinfo = cjson.encode(server_info)
	local http_helper = HttpRequestHelper:create()
	http_helper:EncodeParams("m", "update")
	http_helper:EncodeParams("a", "servers")
	http_helper:EncodeParams("game", center_info.name)
	http_helper:EncodeParams("app_id", center_info.id)
	http_helper:EncodeParams("servers", serverinfo)
	local signstr = string.format("a=servers&app_id=%s&game=%s&m=update&servers=%s&app_secret=%s", center_info.id, center_info.name, serverinfo, center_info.secret)
	local sign = http_helper:MD5Encode(signstr)
	http_helper:EncodeParams("sign", sign)
	local code = http_helper:PostHttpRequest(center_info.url, 5)
	HttpRequestHelper:release(http_helper)]]
end

--关服务器操作
function server_open_close(listen_ip, realId, contents)
	--发送具体操作指令
	local lua_buff = g_luaBuffMgr:getLuaEvent(MANAGER_ML_MANGER)
	lua_buff:pushShort(eStatus)
	lua_buff:pushChar(1)
	lua_buff:pushString(contents.contents)
	g_frame:send2Listener(listen_ip, 0, lua_buff)

	--推送状态消息
	push_server_lists()
end

--子服务器状态改变
function server_status_change(listen_ip, realId, contents)	
	local notify = false	
	local serverId = contents.worldId
	print("server_status_change: ", listen_ip, realId, contents)
	if contents.attrType == 1 then
		if contents.attrValue > 0 then
			--服务器状态修改
			notify = true
			server_listen_infos[listen_ip][realId].status = contents.attrValue
			for i, info in pairs(server_game_infos) do
				if info.real == realId then
					info.status = contents.attrValue
				end
			end
			local sql = string.format([[update servers_real set ser_status=%d where ser_id=%d and ser_group=%d]], contents.attrValue, realId, g_configID)
			mysql_callSQL(mysql_center, sql)
		end
	elseif contents.attrType == 2 then
		--开服时间修改
		notify = true
		server_listen_infos[listen_ip][realId].tick = contents.attrValue
		for i, info in pairs(server_game_infos) do
			if info.real == realId then
				info.tick = contents.attrValue
			end
		end
		local sql = string.format([[update servers_real set ser_time=%d where ser_id=%d and ser_group=%d]], contents.attrValue, realId, g_configID)
		mysql_callSQL(mysql_center, sql)
	elseif contents.attrType == 3 then
		--排队人数修改
		notify = true
		server_listen_infos[listen_ip][realId].rank = contents.attrValue
		for i, info in pairs(server_game_infos) do
			if info.real == realId then
				info.rank = contents.attrValue
			end
		end
		local sql = string.format([[update servers_real set ser_rank=%d where ser_id=%d and ser_group=%d]], contents.attrValue, realId, g_configID)
		mysql_callSQL(mysql_center, sql)
	elseif contents.attrType == 4 then
		--服务器名字修改
		server_game_infos[serverId].name = contents.attrValue
		local sql = string.format([[update servers_game set game_name='%s' where game_id=%d and game_group=%d]], contents.attrValue, serverId, g_configID)
		mysql_callSQL(mysql_center, sql)
	elseif contents.attrType == 5 then
		--推荐服修改
		for i, channel in pairs(server_channel_infos[realId]) do
			for i, value in pairs(server_default_infos[channel]) do
				if value == realId  then
					table.remove(server_default_infos[channel], i)
				end
			end
			if contents.attrValue > 0 then
				table.insert(server_default_infos[channel], realId)
			end
		end	
		local sql = string.format([[update servers_channel set `default`=%d where realId=%d and chn_group=%d]], contents.attrValue, realId, g_configID)
		mysql_callSQL(mysql_center, sql)
	end
	if notify then
		--发送修改操作指令
		local lua_buff = g_luaBuffMgr:getLuaEvent(MANAGER_ML_MANGER)
		lua_buff:pushShort(eStatus)
		lua_buff:pushChar(2)
		lua_buff:pushInt(realId)
		lua_buff:pushInt(contents.attrType)
		lua_buff:pushInt(contents.attrValue)
		g_frame:send2Listener(listen_ip, 0, lua_buff)
	end	
	--推送状态消息
	push_server_lists()
end

--热更新状态改变
function server_status_hot_update()
	for listen_ip, listen_info in pairs(server_listen_infos) do
		for realId, server_info in pairs(listen_info) do
			local lua_buff = g_luaBuffMgr:getLuaEvent(MANAGER_ML_MANGER)
			lua_buff:pushShort(eStatus)
			lua_buff:pushChar(2)
			lua_buff:pushInt(realId)
			lua_buff:pushInt(server_info.tick)
			lua_buff:pushInt(server_info.rank)
			lua_buff:pushInt(server_info.status)
			g_frame:send2Listener(listen_ip, 0, lua_buff)	
		end
	end
end

------------------------------------------------------------------------------------
--若干框架函数
------------------------------------------------------------------------------------
centerFrame = {}

--监听服务器连接成功
function centerFrame.listener_connected(listen_ip)
	local lua_buff = g_luaBuffMgr:getLuaEvent(MANAGER_ML_REPORT)
	local serverInfo = server_listen_infos[listen_ip]
	local dbxInfo = server_dbx_infos[listen_ip]
	lua_buff:pushString(serialize(serverInfo))
	lua_buff:pushString(serialize(dbxInfo))	
	print("centerFrame.listener_connected", listen_ip, serialize(serverInfo), serialize(dbxInfo))	
	g_frame:send2Listener(listen_ip, 0, lua_buff)
end

--充值
function centerFrame.user_charge(serverId, userID, ingot, order_no, ext_info)
	print(string.format("user_charge:serId=%d,uid:%d,ingot:%d,oms_id:%s,payid:%s", serverId, userID, ingot, order_no, ext_info))	
	if server_game_infos[serverId] then
		local listen_ip = server_game_infos[serverId].ip
		if listen_ip then
			local realId = server_game_infos[serverId].real
			local lua_buff = g_luaBuffMgr:getLuaEvent(MANAGER_MS_COMMAND)
			lua_buff:pushShort(eCharge)
			lua_buff:pushInt(userID)
			lua_buff:pushInt(ingot)
			lua_buff:pushString(order_no)
			lua_buff:pushString(ext_info)
			return g_frame:send2Listener(listen_ip, realId, lua_buff)
		end
	end	
	return false
end

--热更新监听服
function centerFrame.listen_update(response, cmdCls, serverID, opid, command_cls, command_content)
	local listen_ip = server_real_infos[serverID].ip
	local lua_buff = g_luaBuffMgr:getLuaEvent(MANAGER_ML_MANGER)
	lua_buff:pushShort(eLUpdate)
	g_frame:send2Listener(listen_ip, 0, lua_buff)
	--准备返回参数
	response:addContent("code", "0")
	response:makeResponse(SC_OK)
end

--加载服务器列表
function centerFrame.server_loading(response, cmdCls, serverID, opid, command_cls, command_content)
	local result = {servers = server_game_infos, default = server_default_infos}
	response:addContents(cjson.encode(result))
	response:makeResponse(SC_OK)
end

--后台指令处理，返回值为true表示同步操作，处理完之后会立即关闭连接
function centerFrame.server_command(response, cmdCls, serverID, opid, command_cls, command_content)
	print(" centerFrame.server_command: ", cmdCls, serverID, opid, command_cls, command_content)
	local listen_ip = server_real_infos[serverID] and server_real_infos[serverID].ip
	if listen_ip or serverID == 999999 then
		if cmdCls == eStatus then
			local contents = unserialize(command_content)			
			if command_cls == "1" then
				server_open_close(listen_ip, serverID, contents)
			elseif command_cls == "2" then
				server_status_change(listen_ip, serverID, contents)
			end
			--准备返回参数
			response:addContent("code", "0")
			response:makeResponse(SC_OK)
		elseif cmdCls == eCommand then		
			local lua_buff = g_luaBuffMgr:getLuaEvent(MANAGER_MS_COMMAND)
			lua_buff:pushShort(cmdCls)
			lua_buff:pushString(command_cls)
			lua_buff:pushString(command_content)
			if serverID == 999999 then
				if command_cls == "1" or command_cls == "3" or command_cls == "4" then
					for _serId, _lisen_info in pairs(server_real_infos) do
						g_frame:send2Listener(_lisen_info.ip, _serId, lua_buff)
					end
				end
			else
				g_frame:send2Listener(listen_ip, serverID, lua_buff)
			end
			--准备返回参数
			response:addContent("code", "0")
			response:makeResponse(SC_OK)
		elseif cmdCls == eQuery then
			local lua_buff = g_luaBuffMgr:getLuaEvent(MANAGER_ML_RECORD)
			lua_buff:pushShort(cmdCls)
			lua_buff:pushInt(opid)
			lua_buff:pushString(command_cls)
			lua_buff:pushString(command_content)
			g_frame:send2Listener(listen_ip, 0, lua_buff)
			return false
		elseif cmdCls == eOnline then
			local lua_buff = g_luaBuffMgr:getLuaEvent(MANAGER_MS_COMMAND)
			lua_buff:pushShort(cmdCls)
			lua_buff:pushInt(opid)
			lua_buff:pushString(command_cls)
			lua_buff:pushString(command_content)
			g_frame:send2Listener(listen_ip, serverID, lua_buff)
			return false
		elseif cmdCls == eCount then
			local result = {code = 0}
			if tonumber(command_cls) == 1 then
				result.real = real_counts
			else
				result.world = world_counts
			end
			response:addContents(cjson.encode(result))
			response:makeResponse(SC_OK)
		end
	else
		local result = {code = 1, info = "serverID error!"}
		response:addContents(cjson.encode(result))
		response:makeResponse(SC_OK)
	end
	return true	
end

--人数上报
function centerFrame.report_count(worldInfo, realInfo)
	local world_infos = unserialize(worldInfo) or {}
	local real_infos = unserialize(realInfo) or {}
	for worldId, cout in pairs(world_infos) do	
		world_counts[worldId] = cout
	end
	for reaiId, cout in pairs(real_infos) do	
		real_counts[reaiId] = cout
	end
end

--处理图像数据包
function centerFrame.server_data_packet(response, opid, dataPackets)
	local cmdId = dataPackets.head.Cmdid
	local serverId = dataPackets.body.Partition
	if cmdId == IDIP_QUERY_AREA_ONLINE_NUM_REQ then
		--查询在线人数
		local result_resp = build_response_data(dataPackets, 0, {OnlineNum = real_counts[serverId] or 0})
		response:addContents(result_resp)
		response:makeResponse(SC_OK)
		return true
	elseif cmdId == IDIP_QUERY_HOUSE_LAMP_REQ then
		--查询走马灯
		centerFrame.queryHouse(cmdId, response, dataPackets)
	elseif cmdId == IDIP_QUERY_NOTICE_REQ then
		--查询公告
		centerFrame.queryNotice(cmdId, response, dataPackets)
	elseif cmdId == IDIP_QUERY_GAME_POPUP_REQ then
		--查询游戏弹窗
		centerFrame.queryPopup(cmdId, response, dataPackets)
	elseif cmdId == IDIP_QUERY_GROUP_SEND_MAIL_REQ then
		--查询群发邮件
		centerFrame.queryEmail(cmdId, response, dataPackets)	
	elseif cmdId == IDIP_QUERY_ACTIVITY_REQ then
		--查询活动
		centerFrame.queryActivity(cmdId, response, dataPackets)	
	elseif cmdId == IDIP_DO_SHOOT_FACE_NOTICE_REQ then
		--拍脸公告
		centerFrame.sendNotice(cmdId, response, dataPackets)	
	else	
		--处理一些全局消息
		centerFrame.dealGlobal(serverId, cmdId, dataPackets.body)
		--构建消息内容	
		local lua_buff = g_luaBuffMgr:getLuaEvent(MANAGER_ML_RECORD)
		lua_buff:pushShort(eDataPacket)
		lua_buff:pushInt(opid)
		lua_buff:pushString(serialize(dataPackets))
		lua_buff:pushString("")
		--处理消息
		local result, code = centerFrame.dealDataPacket(cmdId, serverId, lua_buff, dataPackets)
		if result then			
			local error_resp = build_response_data(dataPackets, code)	
			response:addContents(error_resp)
			response:makeResponse(SC_OK)
		end
		return result
	end
end

--处理相关内容
function centerFrame.dealDataPacket(cmdId, serverId, lua_buff, dataPackets)	
	if serverId == 0 then	
		if cmdId == IDIP_DO_ACTIVE_USR_REQ or cmdId == IDIP_DO_BAN_USR_REQ
				or cmdId == IDIP_DO_UNBAN_USR_REQ or cmdId == IDIP_DO_HOUSE_LAMP_REQ
				or cmdId == IDIP_DO_DEL_NOTICE_REQ or cmdId == IDIP_DO_GAME_POPUP_REQ
				or cmdId == IDIP_DO_UPDATE_ACTIVITY_REQ or cmdId == IDIP_DO_DEL_ACTIVITY_REQ
				or cmdId == IDIP_DO_GROUP_SEND_MAIL_REQ or cmdId == IDIP_DO_ADD_ACTIVITY_REQ then
			--所有区都执行		
			if #server_real_infos > 0 then
				for _serId, _lisen_info in pairs(server_real_infos) do
					g_frame:send2Listener(_lisen_info.ip, _serId, lua_buff)
				end
				return false
			else
				return true, ERROR_PARTITION_NOT_EXIST
			end
		else
			return true, ERROR_CMD_CANNOT_BOARDCAST
		end
	else
		--指定区执行，需要异步返回
		local listen_ip = server_real_infos[serverId] and server_real_infos[serverId].ip
		if listen_ip then				
			g_frame:send2Listener(listen_ip, serverId, lua_buff)	
			return false
		else
			return true, ERROR_PARTITION_NOT_EXIST
		end
	end	
end

--拍脸公告
function centerFrame.sendNotice(cmdId, response, dataPackets)	
	--发拍脸公告 存库处理
	body.EventId = NEW_GUID_STR(serverId, 4)
	local sql = string.format([[replace into servers_notice (EventId, BeginTime, EndTime, NoticeTitle, Content, Frequency, Priority, 
		Hyperlink, ButtonContent, NoticeType, `Partition`) value ('%s', %d, %d, '%s', '%s', %d, %d, '%s', '%s', %d, %d)]],
		body.EventId, body.BeginTime, body.EndTime, encodeURIValue(body.NoticeTitle), encodeURIValue(body.Content), body.Frequency,	
		body.Priority, body.Hyperlink, encodeURIValue(body.ButtonContent), body.NoticeType, body.Partition)
	mysql_callSQL(mysql_center, sql)
	
	local result_resp = build_response_data(dataPackets, 0, {result = 0, RetMsg = "success", EventId = body.EventId}})
	response:addContents(result_resp)
	response:makeResponse(SC_OK)
end

--查询活动
function centerFrame.queryActivity(cmdId, response, dataPackets)	
	local sql = ""
	local body = dataPackets.body
	if body.ActivityId and #body.ActivityId > 0 then
		sql = string.format([[SELECT * FROM servers_activity WHERE ActivityId = '%s']], body.ActivityId)
	else
		if body.Partition == 0 then
			sql = string.format([[SELECT * FROM servers_activity WHERE BeginTime >=  %d and BeginTime <= %d]],
				body.BeginTime or 0, body.EndTime or 0)
		else
			sql = string.format([[SELECT * FROM servers_activity WHERE BeginTime >=  %d and BeginTime <= %d and `Partition` = %d]], 
				body.BeginTime or 0, body.EndTime or 0, body.Partition)
		end
	end
	local ret_dates = {
		TotalPageNo = 0,
		ActivityList_count = 0,
		ActivityList = {},
	}
	local result, records =  mysql_callSQL(mysql_center, sql)
	if result and records then
		local j = 1
		ret_dates.TotalPageNo = math.ceil(#records / 5)
		for i, record in pairs(records) do
			if i > body.PageNo * 5 and j <= 5 then
				ret_dates.ActivityList[j] = unserialize(record.ActivityData)
				j = j + 1
			end
		end
		ret_dates.ActivityList_count = #ret_dates.ActivityList
	end
	local result_resp = build_response_data(dataPackets, 0, ret_dates)
	response:addContents(result_resp)
	response:makeResponse(SC_OK)
end

function centerFrame.queryHouse(cmdId, response, dataPackets)
	local sql = ""
	local body = dataPackets.body
	if body.Partition == 0 then
		sql = string.format([[SELECT * FROM servers_house WHERE BeginTime >= %d and BeginTime <= %d]],
			body.BeginTime or 0, body.EndTime or 0)
	else
		sql = string.format([[SELECT * FROM servers_house WHERE BeginTime >= %d and BeginTime <= %d and `Partition` = %d]], 
			body.BeginTime or 0, body.EndTime or 0, body.Partition)
	end
	local ret_dates = {
		TotalCount = 0,
		HouseLampList_count = 0,
		HouseLampList = {},
	}
	local result, records =  mysql_callSQL(mysql_center, sql)
	if result and records then
		local j = 1
		ret_dates.TotalCount = #records
		for i, record in pairs(records) do
			if i > body.PageNo * 20 and j <= 20 then
				ret_dates.HouseLampList[j] = {}
				ret_dates.HouseLampList[j].HouseId = record.HouseId
				ret_dates.HouseLampList[j].EndTime = tonumber(record.EndTime)
				ret_dates.HouseLampList[j].BeginTime = tonumber(record.BeginTime)
				ret_dates.HouseLampList[j].NoticeContent = record.NoticeContent
				ret_dates.HouseLampList[j].RollingIntervalTime = tonumber(record.RollingIntervalTime)
				j = j + 1
			end			
		end
		ret_dates.HouseLampList_count = #ret_dates.HouseLampList
	end
	local result_resp = build_response_data(dataPackets, 0, ret_dates)
	response:addContents(result_resp)
	response:makeResponse(SC_OK)
end

function centerFrame.queryNotice(cmdId, response, dataPackets)
	local sql = ""
	local body = dataPackets.body
	if body.EventId and #body.EventId > 0 then
		sql = string.format([[SELECT * FROM servers_notice WHERE EventId = '%s']], body.EventId)
	else
		if body.Partition == 0 then
			sql = string.format([[SELECT * FROM servers_notice WHERE BeginTime >= %d and BeginTime <= %d]],
				body.BeginTime or 0, body.EndTime or 0)
		else
			sql = string.format([[SELECT * FROM servers_notice WHERE BeginTime >= %d and BeginTime <= %d and `Partition` = %d]], 
				body.BeginTime or 0, body.EndTime or 0, body.Partition)
		end
	end
	local ret_dates = {
		TotalPageNo = 0,
		NoticeList_count = 0,
		NoticeList = {},
	}
	local result, records =  mysql_callSQL(mysql_center, sql)
	if result and records then
		local j = 1
		ret_dates.TotalPageNo = math.ceil(#records / 20)
		for i, record in pairs(records) do
			if i > body.PageNo * 20 and j <= 20 then
				ret_dates.NoticeList[j] = {}
				ret_dates.NoticeList[j].AreaId = body.AreaId
				ret_dates.NoticeList[j].PlatId = body.PlatId
				ret_dates.NoticeList[j].EventId = record.EventId	
				ret_dates.NoticeList[j].Content = record.Content		
				ret_dates.NoticeList[j].Partition = record.Partition
				ret_dates.NoticeList[j].Hyperlink = record.Hyperlink	
				ret_dates.NoticeList[j].NoticeType = record.NoticeType
				ret_dates.NoticeList[j].NoticeTitle = record.NoticeTitle
				ret_dates.NoticeList[j].ButtonContent = record.ButtonContent
				ret_dates.NoticeList[j].EndTime = tonumber(record.EndTime)
				ret_dates.NoticeList[j].Priority = tonumber(record.Priority)
				ret_dates.NoticeList[j].BeginTime = tonumber(record.BeginTime)
				ret_dates.NoticeList[j].Frequency = tonumber(record.Frequency)
				j = j + 1
			end			
		end
		ret_dates.NoticeList_count = #ret_dates.NoticeList
	end
	local result_resp = build_response_data(dataPackets, 0, ret_dates)
	response:addContents(result_resp)
	response:makeResponse(SC_OK)
end

function centerFrame.queryPopup(cmdId, response, dataPackets)
	local sql = ""
	local body = dataPackets.body
	if body.Partition == 0 then
		sql = string.format([[SELECT * FROM servers_popup WHERE BeginTime >= %d and BeginTime <= %d]],
			body.BeginTime or 0, body.EndTime or 0)
	else
		sql = string.format([[SELECT * FROM servers_popup WHERE BeginTime >= %d and BeginTime <= %d and `Partition` = %d]], 
			body.BeginTime or 0, body.EndTime or 0, body.Partition)
	end
	local ret_dates = {
		TotalCount = 0,
		PopupList_count = 0,
		PopupList = {},
	}
	local result, records =  mysql_callSQL(mysql_center, sql)
	if result and records then
		local j = 1
		ret_dates.TotalCount = #records
		for i, record in pairs(records) do
			if i > body.PageNo * 20 and j <= 20 then
				ret_dates.PopupList[j] = {}
				ret_dates.PopupList[j].PopupId = record.PopupId			
				ret_dates.PopupList[j].Hyperlink = record.Hyperlink	
				ret_dates.PopupList[j].PopupTitle = record.PopupTitle
				ret_dates.PopupList[j].PopupContent = record.PopupContent
				ret_dates.PopupList[j].ButtonContent = record.ButtonContent			
				ret_dates.PopupList[j].EndTime = tonumber(record.EndTime)
				ret_dates.PopupList[j].BeginTime = tonumber(record.BeginTime)
				ret_dates.PopupList[j].Frequency = tonumber(record.Frequency)
				ret_dates.PopupList[j].CustomFrequency = tonumber(record.CustomFrequency)
				j = j + 1
			end			
		end
		ret_dates.PopupList_count = #ret_dates.PopupList
	end
	local result_resp = build_response_data(dataPackets, 0, ret_dates)
	response:addContents(result_resp)
	response:makeResponse(SC_OK)
end

function centerFrame.queryEmail(cmdId, response, dataPackets)
	local sql = ""
	local body = dataPackets.body
	if body.Partition == 0 then
		sql = string.format([[SELECT * FROM servers_email WHERE SendTime >= %d and SendTime <= %d]],
			body.BeginTime or 0, body.EndTime or 0)
	else
		sql = string.format([[SELECT * FROM servers_email WHERE SendTime >= %d and SendTime <= %d and `Partition` = %d]], 
			body.BeginTime or 0, body.EndTime or 0, body.Partition)
	end
	local ret_dates = {
		TotalCount = 0,
		GroupSendMailList_count = 0,
		GroupSendMailList = {},
	}
	local result, records =  mysql_callSQL(mysql_center, sql)
	if result and records then
		local j = 1
		ret_dates.TotalCount = #records
		for i, record in pairs(records) do
			if i > body.PageNo * 20 and j <= 20 then
				ret_dates.GroupSendMailList[j] = {}
				ret_dates.GroupSendMailList[j].MailId = record.MailId
				ret_dates.GroupSendMailList[j].Hyperlink = record.Hyperlink
				ret_dates.GroupSendMailList[j].MailTitle = record.MailTitle
				ret_dates.GroupSendMailList[j].MailContent = record.MailContent
				ret_dates.GroupSendMailList[j].ButtonContent = record.ButtonContent
				ret_dates.GroupSendMailList[j].ItemList = record.ItemList
				ret_dates.GroupSendMailList[j].Type = tonumber(record.Type)
				ret_dates.GroupSendMailList[j].SendTime = tonumber(record.SendTime)
				ret_dates.GroupSendMailList[j].MinLevel = tonumber(record.MinLevel)
				ret_dates.GroupSendMailList[j].MaxLevel = tonumber(record.MaxLevel)
				j = j + 1
			end
		end
		ret_dates.GroupSendMailList_count = #ret_dates.GroupSendMailList
	end
	local result_resp = build_response_data(dataPackets, 0, ret_dates)
	response:addContents(result_resp)
	response:makeResponse(SC_OK)
end

function centerFrame.dealGlobal(serverId, cmdId, body)
	if cmdId == IDIP_DO_HOUSE_LAMP_REQ then
		--发走马灯 存库处理
		body.EventId = NEW_GUID_STR(serverId, 0)
		local sql = string.format([[replace into servers_house (HouseId, BeginTime, EndTime, `Partition`, 
			NoticeContent, RollingIntervalTime) value ('%s', %d, %d, %d, '%s', %d)]],
			body.EventId, body.BeginTime, body.EndTime, body.Partition, encodeURIValue(body.NoticeContent), body.RollingIntervalTime)
		mysql_callSQL(mysql_center, sql)
	elseif cmdId == IDIP_DO_GAME_POPUP_REQ then
		--发游戏弹窗 存库处理
		body.EventId = NEW_GUID_STR(serverId, 1)
		local sql = string.format([[replace into servers_popup (PopupId, BeginTime, EndTime, PopupTitle, PopupContent, 
			Frequency, CustomFrequency, Hyperlink, ButtonContent, `Partition`) value ('%s', %d, %d, '%s', '%s', %d, %d, '%s', '%s', %d)]],
			body.EventId, body.BeginTime, body.EndTime, encodeURIValue(body.PopupTitle), encodeURIValue(body.PopupContent), body.Frequency,
			body.CustomFrequency, body.Hyperlink, encodeURIValue(body.ButtonContent), body.Partition)
		mysql_callSQL(mysql_center, sql)	
	elseif cmdId == IDIP_DO_GROUP_SEND_MAIL_REQ then
		--发群发邮件，存库处理
		body.EventId = NEW_GUID_STR(serverId, 2)
		local sql = string.format([[replace into servers_email (MailId, SendTime, MailTitle, MailContent, Type,
			MinLevel, MaxLevel, ItemList, Hyperlink, ButtonContent, `Partition`) value ('%s', %d, '%s', '%s', %d, %d, %d, '%s', '%s', '%s', %d)]],
			body.EventId, body.SendTime, encodeURIValue(body.MailTitle), encodeURIValue(body.MailContent), body.Type, body.MinLevel, body.MaxLevel,
			serialize(body.ItemList), body.Hyperlink, encodeURIValue(body.ButtonContent), body.Partition)
		mysql_callSQL(mysql_center, sql)
	elseif cmdId == IDIP_DO_ADD_ACTIVITY_REQ then
		--添加活动
		body.ActivityId = NEW_GUID_STR(serverId, 3)	
	elseif cmdId == IDIP_DO_DEL_NOTICE_REQ then
		if body.Type == 1 then
			local sql = string.format("delete from servers_house where HouseId = '%s'", body.EventId or "")
			mysql_callSQL(mysql_center, sql)
		elseif body.Type == 2 then
			local sql = string.format("delete from servers_popup where PopupId = '%s'", body.EventId or "")
			mysql_callSQL(mysql_center, sql)
		elseif body.Type == 3 then
			local sql = string.format("delete from servers_email where MailId = '%s'", body.EventId or "")
			mysql_callSQL(mysql_center, sql)
		elseif body.Type == 4 then
			local sql = string.format("delete from servers_notice where EventId = '%s'", body.EventId or "")
			mysql_callSQL(mysql_center, sql)
		end
	end
end

--回调消息
function centerFrame.result_callback(resp, result)
	print("centerFrame.result_callback:", result, resp)
	local dataResp = cjson.decode(resp)
	if dataResp.body and dataResp.body.Result ~= 0 then
		print("centerFrame.result_callback operator failed, because: ", dataResp.body.RetMsg)
		return
	end
	local dataPackets = unserialize(result)
	if dataPackets and dataPackets.body then
		local body = dataPackets.body
		local cmdId = dataPackets.head.Cmdid
		if cmdId == IDIP_DO_ADD_ACTIVITY_REQ then
			--添加活动
			body.SysId_count = nil
			body.GoodList_count = nil
			body.ItemList1_count = nil
			body.NeedItemList_count = nil
			body.GivenItemList_count = nil
			body.Msg = encodeURIValue(body.Msg)
			body.Link = encodeURIValue(body.Link)
			body.Reason = encodeURIValue(body.Reason)
			body.ActivityTitle = encodeURIValue(body.ActivityTitle)
			body.ActivityContent = encodeURIValue(body.ActivityContent)
			body.SysId = encodeURIValue(parse_sysid_list(body.SysId or {}))
			body.GoodList = encodeURIValue(parse_good_list(body.GoodList or {}))
			body.ItemList1 = encodeURIValue(parse_item_list(body.ItemList1 or {}))
			body.NeedItemList = encodeURIValue(parse_need_list(body.NeedItemList or {}))
			body.GivenItemList = encodeURIValue(parse_given_list(body.GivenItemList or {}))
			body.Week = parse_week_list(body.Week or {})
			local sql = string.format([[replace into servers_activity (ActivityId, BeginTime, EndTime, ActivityData, `Partition`) 
			value ('%s', %d, %d, '%s', %d)]], body.ActivityId, body.BeginTime, body.EndTime, serialize(body), body.Partition)
			mysql_callSQL(mysql_center, sql)
		elseif cmdId == IDIP_DO_UPDATE_ACTIVITY_REQ then
			--修改活动
			body.SysId_count = nil
			body.GoodList_count = nil
			body.ItemList1_count = nil
			body.NeedItemList_count = nil
			body.GivenItemList_count = nil
			body.Msg = encodeURIValue(body.Msg)
			body.Link = encodeURIValue(body.Link)
			body.Reason = encodeURIValue(body.Reason)
			body.ActivityTitle = encodeURIValue(body.ActivityTitle)
			body.ActivityContent = encodeURIValue(body.ActivityContent)
			body.SysId = encodeURIValue(parse_sysid_list(body.SysId or {}))
			body.GoodList = encodeURIValue(parse_good_list(body.GoodList or {}))
			body.ItemList1 = encodeURIValue(parse_item_list(body.ItemList1 or {}))
			body.NeedItemList = encodeURIValue(parse_need_list(body.NeedItemList or {}))
			body.GivenItemList = encodeURIValue(parse_given_list(body.GivenItemList or {}))
			body.Week = parse_week_list(body.Week or {})
			local sql = string.format([[update servers_activity set BeginTime=%d, EndTime=%d, ActivityData='%s' 
				where ActivityId='%s']], body.BeginTime, body.EndTime, serialize(body), body.ActivityId)
			mysql_callSQL(mysql_center, sql)
		elseif cmdId == IDIP_DO_DEL_ACTIVITY_REQ then
			--删除活动
			local sql = string.format("delete from servers_activity where ActivityId = '%s'", body.ActivityId or "")
				mysql_callSQL(mysql_center, sql)
		end
	end	
end

--定时器操作
local lastTick = os.time()
local mysql_alive_tick = os.time()
function centerFrame.timer_check()	
	--垃圾回收
	local nowTick = os.time()
	if nowTick - lastTick >= 5 then
		collectgarbage("step")	
		lastTick = nowTick
	end
	if nowTick - 300 > mysql_alive_tick then
		centerFrame.mysql_check()
		mysql_alive_tick = nowTick
		--推送服务器列表
		push_server_lists()
	end
end

--检查mysql是否存活
function centerFrame.mysql_check()
	local sql = string.format("select now() as nowtick")
	local ret_center = mysql_callSQL(mysql_center, sql)
	if not ret_center then
		local dsn, user, pwd, host, port = get_mysql_config(g_configID)
		mysql_center = mysql_init(dsn, user, pwd, host, port)
	end
end

------------------------------------------------------------------------------------
--若干参数解析函数
------------------------------------------------------------------------------------
function parse_week_list(week)
	if type(itemlist) == "table" then
		local retstr = string.format("%d;", #week)
		for i, va in pairs(week) do
			retstr = string.format("%s%d;", retstr, va)
		end
		return retstr
	end
	return "0;"
end

function parse_item_list(itemlist)
	if type(itemlist) == "table" then
		local retstr = string.format("%d;", #itemlist)
		for i, item in pairs(itemlist) do
			if type(item) == "table" then
				retstr = string.format("%s%d-%d-%d-%d;", retstr, item.Arg or 0, item.ItemId or 0, item.IsBand or 0, item.ItemNum or 0)
			else
				retstr = string.format("%s%s;", retstr, tostring(item))
			end
		end
		return retstr
	end	
	return "0;"
end

function parse_good_list(good_list)
	if type(good_list) == "table" then
		local retstr = string.format("%d;", #good_list)
		for i, item in pairs(good_list) do
			if type(item) == "table" then
				retstr = string.format("%s%s-%d-%d-%d-%d-%d-%s-%d-%d-%d;", retstr, item.GroupName or "", item.GroupId or 0, item.OriginType or 0, 
					item.OriginPrice or 0, item.DiscountType or 0, item.DiscountPrice or 0, item.Discount or 0, item.ItemId or 0, item.ItemNum or 0, item.IsBand or 0)
			else
				retstr = string.format("%s%s;", retstr, tostring(item))
			end
		end
		return retstr
	end	
	return "0;"
end

function parse_sysid_list(sysid_list)
	if type(sysid_list) == "table" then
		local retstr = string.format("%d;", #sysid_list)
		for i, item in pairs(sysid_list) do
			if type(item) == "table" then
				retstr = string.format("%s%s-%d-%d-%d-%d-%d-%s-%d-%d-%d;", retstr, item.GroupName or "", item.GroupId or 0, item.OriginType or 0, 
					item.OriginPrice or 0, item.DiscountType or 0, item.DiscountPrice or 0, item.Discount or 0, item.ItemId or 0, item.ItemNum or 0, item.IsBand or 0)
			else
				retstr = string.format("%s%s;", retstr, tostring(item))
			end
		end
		return retstr
	end	
	return "0;"
end

function parse_need_list(need_list)
	if type(need_list) == "table" then
		local retstr = string.format("%d;", #need_list)
		for i, item in pairs(need_list) do
			if type(item) == "table" then
				retstr = string.format("%s%s-%d-%d-%d-%d;", retstr, item.SegmentName or "", item.GroupId or 0, item.Arg or 0, item.ItemId or 0, item.Num or 0)
			else
				retstr = string.format("%s%s;", retstr, tostring(item))
			end
		end
		return retstr
	end	
	return "0;"
end

function parse_given_list(given_list)
	if type(given_list) == "table" then
		local retstr = string.format("%d;", #given_list)
		for i, item in pairs(given_list) do
			if type(item) == "table" then
				retstr = string.format("%s%s-%d-%d-%d-%d-%d;", retstr, item.SegmentName or "", item.GroupId or 0, item.Arg or 0, item.ItemId or 0, item.Num or 0, item.IsBind or 0)
			else
				retstr = retstr .. tostring(item) .. ";"
			end
		end
		return retstr
	end	
	return "0;"
end
