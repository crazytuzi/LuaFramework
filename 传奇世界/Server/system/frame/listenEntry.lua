--listenEntry.lua
require "frame.time"
require "frame.mysql"
require "frame.protobuf"
require "frame.serialize"

mysql_game = nil
g_configid = nil
listen_world_id = 0
listen_servers = {}
real_counts = {}
world_counts = {}
listen_start_tick = os.time()

--入口函数
listenEntry = {}
function listenEntry.start(frame, configid)
	require "listen_cfg"
	require "frame.packet_const"
	require "frame.listen_tool"
	require "frame.listen_frame"	
	require "frame.listen_packet"
	
	--注册pb
	local proto = io.open("dbbuff.pb","rb")
	buffer = proto:read("*a")
	protobuf.register(buffer)
	proto:close()

	--初始化mysql
	g_configid = configid
	server_start_tick = time.totime(server_start_date)
	g_frame = tolua.cast(frame, "ListenFrame")
	g_luaBuffMgr = LuaEventManager:instance()
	if g_frame and g_luaBuffMgr then
		cjson.encode_sparse_array(true)
		init_config_proto()
	end
end

--热更新
function listenEntry.hot_update()
	--清除数据
	clear_listen_frame()
	--清除包内容
	package.loaded["listen_cfg"] = nil
	package.loaded["frame.listen_tool"] = nil
	package.loaded["frame.listen_frame"] = nil
	package.loaded["frame.listen_packet"] = nil
	package.loaded["frame.packet_const"] = nil
	--重新加载
	require "listen_cfg"
	require "frame.packet_const"
	require "frame.listen_tool"
	require "frame.listen_frame"
	require "frame.listen_packet"

	--注册pb
	local proto = io.open("dbbuff.pb","rb")
	buffer = proto:read("*a")
	protobuf.register(buffer)
	proto:close()
	
	--物品原型
	server_start_tick = time.totime(server_start_date)
	init_config_proto()

	--检查mysql
	listenFrame.mysql_check()
end

--后台指令处理
function dealCommand(msgId, luabuff)
	local buff = tolua.cast(luabuff, "LuaMsgBuffer")
	if msgId == MANAGER_ML_MANGER then
		local cmdCls = buff:popShort()
		if cmdCls == eLUpdate then
			listenEntry.hot_update()
		else 
			listenFrame.server_status(cmdCls, buff)
		end
	elseif msgId == MANAGER_ML_RECORD then
		listenFrame.query_record(buff)
	elseif msgId == MANAGER_SL_COMMAND then
		listenFrame.server_result(buff)
	elseif msgId == MANAGER_ML_REPORT then	
		listenFrame.server_report(buff)
	end
end

