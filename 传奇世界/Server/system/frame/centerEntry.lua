--centerEntry.lua
require "frame.mysql"
require "frame.serialize"

center_info = nil
mysql_center = nil

--逻辑数据
server_dbx_infos = {}
server_real_infos = {}
server_game_infos = {}
server_listen_infos = {}
server_channel_infos = {}
server_default_infos = {}

--在线情况
real_counts = {}
world_counts = {}

--入口函数
centerEntry = {}
function centerEntry.start(frame, configid)
	require "center_cfg"
	require "frame.center_frame"
	require "frame.packet_const"
	
	print("centerEntry.start", configid)
	--初始化mysql	
	local dsn, user, pwd, host, port = get_mysql_config(configid)
	print("centerEntry.mysql_init", dsn, user, pwd, host, port)
	mysql_center = mysql_init(dsn, user, pwd, host, port)
	if not mysql_center then
		return false
	end
	--创建服务器映射
	if not load_server_config(configid) then
		return false
	end
	--初始化全局变量
	g_configID = configid
	g_frame = tolua.cast(frame, "CenterFrame")
	g_luaBuffMgr = LuaEventManager:instance()
	--读取中心服务器配置
	if g_frame and g_luaBuffMgr then
		cjson.encode_sparse_array(true)
		center_info = get_center_config(configid)
		--推送服务器列表
		push_server_lists()
		return true
	end
	return false
end

--热更新
function centerEntry.hot_update()
	--清除包内容
	package.loaded["center_cfg"] = nil
	package.loaded["frame.center_frame"] = nil
	package.loaded["frame.packet_const"] = nil
	--重新加载
	require "center_cfg"
	require "frame.center_frame"
	require "frame.packet_const"
	
	center_info = get_center_config(g_configID)
	if center_info then
		--逻辑数据
		server_dbx_infos = {}
		server_real_infos = {}
		server_game_infos = {}
		server_listen_infos = {}
		server_channel_infos = {}
		server_default_infos = {}
		--创建服务器映射
		load_server_config(g_configID)
		--更新已连接的状态
		server_status_hot_update()
		--推送服务器列表
		push_server_lists()
	end
end

--后台指令处理
function centerEntry.server_command(resp, command_params, command_cls, command_content)
	local result = true
	local cmd_params = unserialize(command_params)	
	local cmdCls, serverID, opid = cmd_params.cmdCls, cmd_params.serverID, cmd_params.opid
	
	local response = tolua.cast(resp, "HTTPResponse")
	if cmdCls == eCUpdate then
		centerEntry.hot_update()
		response:addContent("code", "0")
		response:makeResponse(SC_OK)
	elseif cmdCls == eLUpdate then
		centerFrame.listen_update(response, cmdCls, serverID, opid, command_cls, command_content)
	elseif cmdCls == eLoading then
		centerFrame.server_loading(response, cmdCls, serverID, opid, command_cls, command_content)
	else
		result = centerFrame.server_command(response, cmdCls, serverID, opid, command_cls, command_content)
	end	
	return result
end

--后台指令处理
function centerEntry.server_data_packet(resp, opid, data_packet_string)
	local result = false
	local dataPackets = cjson.decode(data_packet_string)
	local response = tolua.cast(resp, "HTTPResponse")

	--先填充错误信息
	local error_resp = build_error_response_data(dataPackets, ERROR_EXEC_CODE_FIELD)
	response:addContents(error_resp)
	
	--处理数据包
	result = centerFrame.server_data_packet(response, opid, dataPackets)
	return result
end
