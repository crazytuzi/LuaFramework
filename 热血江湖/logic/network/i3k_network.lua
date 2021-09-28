----------------------------------------------------------------
local require = require

require("logic/network/i3k_network_def");
require("i3k_sbean");
require("i3k_sbean_fast");


----------------------------------------------------------------
local g_i3k_iosExamineServer		= false;
local g_i3k_net_channel_hdr_map		= { };
local g_i3k_net_last_sync_cmd		= { valid = false, type = 1, cmd = nil, layer = 1 }; -- type[1: normal, 2:normal ext, 3:list]
local g_i3k_sync_str_bean			= { req = nil, res_name = nil, resend = true };--

----------------------------------------------------------------
--register lua network channel handler
function i3k_game_network_init()
	--require("logic/network/channel/i3k_channel_buy_coin")
	require("logic/network/channel/i3k_channel_activity")
	require("logic/network/channel/i3k_protocol_login")
	require("logic/network/channel/i3k_protocol_role")
	require("logic/network/channel/i3k_protocol_notify")
	require("logic/network/channel/i3k_protocol_skill")
	require("logic/network/channel/i3k_protocol_spirit")
	require("logic/network/channel/i3k_protocol_weapon")
	require("logic/network/channel/i3k_protocol_item")
	require("logic/network/channel/i3k_protocol_pet")
	require("logic/network/channel/i3k_protocol_task")
	require("logic/network/channel/i3k_protocol_dynamic_cfg")
	require("logic/network/channel/i3k_protocol_team")
	require("logic/network/channel/i3k_protocol_room")
	require("logic/network/channel/i3k_protocol_mapcopy")
	require("logic/network/channel/i3k_protocol_other")
	require("logic/network/channel/i3k_protocol_pay")
	require("logic/network/channel/i3k_protocol_faction")
	require("logic/network/channel/i3k_protocol_clan")
	require("logic/network/channel/i3k_protocol_arena")
	require("logic/network/channel/i3k_protocol_map_broadcast")
	require("logic/network/channel/i3k_protocol_map_uicast")
	require("logic/network/channel/i3k_protocol_map_sync")
	require("logic/network/channel/i3k_protocol_email")
	require("logic/network/channel/i3k_protocol_auction")
	require("logic/network/channel/i3k_protocol_steed")
	require("logic/network/channel/i3k_protocol_friend")
	require("logic/network/channel/i3k_protocol_treasure")
	require("logic/network/channel/i3k_protocol_team_arena")
	require("logic/network/channel/i3k_protocol_longyin")
	require("logic/network/channel/i3k_protocol_taoist")
	require("logic/network/channel/i3k_protocol_experience")
	require("logic/network/channel/i3k_protocol_fengce")
	require("logic/network/channel/i3k_protocol_roll_notice")
	require("logic/network/channel/i3k_protocol_ranking_list")
	require("logic/network/channel/i3k_protocol_fiveUnique")
	require("logic/network/channel/i3k_protocol_forcewar")
	require("logic/network/channel/i3k_protocol_schedule")
	require("logic/network/channel/i3k_protocol_multiply_horse")
	require("logic/network/channel/i3k_protocol_under_wear")
	require("logic/network/channel/i3k_protocol_marry")
	require("logic/network/channel/i3k_protocol_hug")
	require("logic/network/channel/i3k_protocol_grab_red_envelope")
	require("logic/network/channel/i3k_protocol_demonhole")
	require("logic/network/channel/i3k_protocol_fight_npc")
	require("logic/network/channel/i3k_protocol_legend")
	require("logic/network/channel/i3k_protocol_towerdefence")
	require("logic/network/channel/i3k_protocol_master")
	require("logic/network/channel/i3k_protocol_exptree")
	require("logic/network/channel/i3k_protocol_fashion")
	require("logic/network/channel/i3k_protocol_qiecuo")
    require("logic/network/channel/i3k_protocol_spring")
	require("logic/network/channel/i3k_protocol_weapon_soul")
	require("logic/network/channel/i3k_protocol_callback")
	require("logic/network/channel/i3k_protocol_factionSalary")
	require( "logic/network/channel/i3k_protocol_fight_team")
	require("logic/network/channel/i3k_protocol_xinghun")
	require("logic/network/channel/i3k_protocol_dengmi")
	require("logic/network/channel/i3k_protocol_bagua")
	require("logic/network/channel/i3k_protocol_home_land")
	require("logic/network/channel/i3k_protocol_world_cup")
	require("logic/network/channel/i3k_protocol_xinjue")
	require("logic/network/channel/i3k_protocol_hideWeapon")
	require("logic/network/channel/i3k_protocol_spirit_boss")
	require("logic/network/channel/i3k_protocol_partner")
	require("logic/network/channel/i3k_protocol_equip_temper")
	require("logic/network/channel/i3k_protocol_timingactivity")
	require("logic/network/channel/i3k_protocol_battle_desert")
	require("logic/network/channel/i3k_protocol_sworn_friends")
	require("logic/network/channel/i3k_protocol_metamorphosis")
	require("logic/network/channel/i3k_protocol_battle_maze")
	require("logic/network/channel/i3k_protocol_princessMarry")	
	require("logic/network/channel/i3k_protocol_jubilee_activity")
	require("logic/network/channel/i3k_protocol_magic_machine")
	require("logic/network/channel/i3k_protocol_homeland_guard")
	require("logic/network/channel/i3k_protocol_feisheng")
	require("logic/network/channel/i3k_protocol_array_stone")
	require("logic/network/channel/i3k_protocol_war_zone")
	require("logic/network/channel/i3k_protocol_longevity_pavilion")
	require("logic/network/channel/i3k_protocol_spy_story")
end


--local g_i3k_net_status_cb = nil;
function i3k_game_network_connect(host, port)--, cb)
	if g_i3k_rpc_manager then
		--g_i3k_net_status_cb = cb;
		i3k_log("@@@ net connect to server " .. host .. ":" .. port)
		local net_log = i3k_get_net_log()
		net_log:Add("i3k_game_network_connect")
		--g_i3k_rpc_manager:Resume();
		g_i3k_rpc_manager:Connect(host, port);
	end
end

function i3k_game_network_disconnect()
	if g_i3k_rpc_manager then
		i3k_log("@@@ net disconnect ...")
		local net_log = i3k_get_net_log()
		net_log:Add("i3k_game_network_disconnect")
		g_i3k_rpc_manager:Close();
		--g_i3k_rpc_manager:Pause();
	end
end

function i3k_game_network_reset()
	if g_i3k_rpc_manager then
		i3k_log("@@@ net  reset ...")
		local net_log = i3k_get_net_log()
		net_log:Add("i3k_game_network_reset")
		g_i3k_rpc_manager:Pause()
		g_i3k_rpc_manager:Resume()
		g_i3k_sync_str_bean.req = nil
		g_i3k_sync_str_bean.res_name = nil
		--i3k_on_connection_closed()
--		if g_i3k_net_status_cb then
--			g_i3k_net_status_cb:OnNetClosed()
--		end
	end
end

function i3k_game_on_server_open(res)
	i3k_log("@@@ net on session open ... " .. res)
	local net_log = i3k_get_net_log()
	net_log:Add("i3k_game_on_server_open")
	if res == 1 then -- open success
		i3k_on_connection_open_success()
--		if g_i3k_net_status_cb then
--			g_i3k_net_status_cb:OnNetConnected(true);
--		end
--		g_i3k_ui_mgr:CloseUI(eUIID_Wait);
	else
		i3k_on_connection_open_failed()
--		if g_i3k_game_handler:IsQuit() then
--			return;
--		end
--
--		if g_i3k_net_status_cb then
--			g_i3k_net_status_cb:OnNetConnected(false);
--		end
	end
end

function i3k_game_on_server_close()
	i3k_log("@@@ net on session close ... ")
	local net_log = i3k_get_net_log()
	net_log:Add("i3k_game_on_server_close")
	i3k_on_connection_closed()
--	if g_i3k_game_handler:IsQuit() then
--		return;
--	end

	--g_i3k_ui_mgr:PopupWait()
--	i3k_game_clear_user_data();
--	i3k_game_clear_cache_data();

--	if g_i3k_net_status_cb then
--		g_i3k_net_status_cb:OnNetClosed();
--	end
end

function i3k_game_get_challenge_key_arg()
	return "abcd1234efgh5678";
end

function i3k_game_on_server_challenge(istate, sstate, flag)
	if istate == 1 then
		g_i3k_iosExamineServer = true;
	end

	return 1;
end

function i3k_game_on_server_response(res)
	i3k_log("on server response, res=" .. res);
	i3k_on_connection_challenge_ok()
	--i3k_game_login();
end

function i3k_game_on_server_challenge_null()
	i3k_on_connection_challenge_ok()
	--i3k_game_login();
end

function i3k_game_is_IOS_examine_server()
	return g_i3k_iosExamineServer;
end

function i3k_game_unpack_package(str, d)
	if d == nil then
		d = "|";
	end

	local lst = { };

	local i = 1;
	while true do
		local start = i + 1;
		i = string.find(str, d, start); -- find 'next' 0
		if i == nil then
			break;
		end
		table.insert(lst, string.sub(str, start, i - 1));
	end

	return lst;
end

function i3k_game_lua_channel_handler_reg(handler)
	g_i3k_net_channel_hdr_map[handler:GetChannelName()] = handler;
end

function i3k_game_get_lua_channel_handler(channel)
	return g_i3k_net_channel_hdr_map[channel];
end

function i3k_game_lua_channel(data)
	local lst = i3k_game_unpack_package(data);

	i3k_game_lua_channel_list(lst);
end

function i3k_game_str_channel(data)
	local recorder = require("i3k_recorder")
	if recorder.isRecording() then
		recorder.recordPacket(data)
	end
	i3k_game_str_channel_process(data)
end

function i3k_game_str_channel_process(data)
	--i3k_log("<--recv str channel: " .. data)
	if i3k_game_is_pause() then
		return ;
	end
	local packet_name = i3k_sstream.detectPacketName(data)
	if packet_name then
		if not i3k_game_filter_packet(packet_name) then
			local packet_class = i3k_sbean[packet_name]
			if packet_class then
				local packet_req = nil
				if g_i3k_sync_str_bean.res_name == packet_name then
					packet_req = g_i3k_sync_str_bean.req
					g_i3k_sync_str_bean.res_name = nil
					i3k_on_recv_sync_response()
				end
				local callok, packet = pcall(i3k_sstream.decode, data, packet_class)
				if callok and packet then
					if packet_class.handler then
						packet_class.handler(packet, packet_req)
					end
				else
					if i3k_game_get_os_type() == eOS_TYPE_WIN32 then
						error(data)
					else
						i3k_log("decode string channel packet (" .. data .. ") failed !")
					end
				end
			end
		end
	end
end

local before_logined_allowed_beans = 
{
	["keep_alive"] = true,
	["user_login_req"] = true,
	["query_loginqueue_pos"] = true,
	["cancel_loginqueue"] = true,
}
function i3k_game_send_str_bean(bean)
	--i3k_log("send bean")
	if i3k_is_role_logined() or before_logined_allowed_beans[bean.getName()] then
		local cmd = i3k_sstream.encode(bean)
		--i3k_log("-->send str channel: " .. cmd)
		g_i3k_rpc_manager:StrChannel(cmd)

		return true;
	end

	return false;
end

function i3k_game_send_str_cmd(bean, res_bean_name, no_resend)
	if res_bean_name then
		if g_i3k_sync_str_bean.res_name then
			i3k_log("!!!!! drop sync cmd  " .. bean.getName() .. " for waiting res " .. g_i3k_sync_str_bean.res_name)
			return false
		end
		g_i3k_sync_str_bean.req = bean
		g_i3k_sync_str_bean.res_name = res_bean_name
		g_i3k_sync_str_bean.resend = not no_resend
		if bean.getName() ~= "user_login_req" then
			i3k_on_send_sync_request()
		end
	end

	return i3k_game_send_str_bean(bean)
end

local g_lua_channel2_data = { };
function i3k_game_lua_channel2_start()
	g_lua_channel2_data = { };
end

function i3k_game_lua_channel2_data(data)
	table.insert(g_lua_channel2_data, data);
end

function i3k_game_lua_channel2_end()
	i3k_game_lua_channel_list(g_lua_channel2_data);
end

function i3k_game_lua_channel_list(lst)
	local ptype = lst[1];

	if g_i3k_net_last_sync_cmd.valid then
		local match = true;

		if g_i3k_net_last_sync_cmd.type == 1 then
			match = (ptype == g_i3k_net_last_sync_cmd.cmd);
		else
			for k = 1, g_i3k_net_last_sync_cmd.layer do
				local c1 = g_i3k_net_last_sync_cmd.cmd[k];
				local c2 = lst[k];

				if c1 ~= nil and c2 ~= nil then
					if c1 ~= c2 then
						match = false;
					end
				else
					match = false;
				end
			end
		end

		if match then
			g_i3k_net_last_sync_cmd.valid = false;
		end
	end

	local hdr = g_i3k_net_channel_hdr_map[ptype];
	if hdr then
		local params = i3k_net_params.new(lst);
		params:pop();

		hdr:ProcCmd(params);
	end

	return 0;
end

function i3k_game_http_get_file(uid, url)
	if g_i3k_game_handler then
		g_i3k_game_handler:HttpGetFileRequest(uid, url)
	end
end

function i3k_game_on_http_get_file_response(uid, ecode, str)
	local http = require("i3k_httpclient")
	if http then
		http.onGetFileRes(uid, ecode, str)
	end
end

--function i3k_game_login()
--	--i3k_log("i3k_game_login ... 1")
--	if g_i3k_game_handler:IsQuit() then
--		return;
--	end
--	---i3k_log("i3k_game_login ... 2")
--	i3k_game_clear_user_data();
--	i3k_game_clear_cache_data();
--
--
--	local login = i3k_sbean.user_login_req.new()
--	local loginData = g_i3k_game_context:GetLoginData();
--	login.openId = loginData.uname
--	login.channel = loginData.channel
--
--	local loginInfo = g_i3k_game_context:GetLoginInfo()
--	if loginInfo then
--		login.loginInfo = loginInfo
--		login.roleId = 0
--		login.roleName = ""
--		login.classType = 0
--		login.gender = 0--login.classType == 0 ? 0 : 1
--
--		i3k_game_send_str_cmd(login, i3k_sbean.user_login_res.getName())
--		--i3k_log("i3k_game_login ... 3")
--	else
--
--	end
--	--[[local hdr = g_i3k_net_channel_hdr_map[eNChannel_Login];
--	if hdr then
--		hdr:SendCmd(true);
--	end--]]
--end

function i3k_game_send_cmd(cmd)
	g_i3k_rpc_manager:LuaChannel(cmd);
end

function i3k_game_send_cmd_sync(cmd, layer)
	if g_i3k_net_last_sync_cmd.valid then
		return false;
	end

	g_i3k_net_last_sync_cmd.valid	= true;
	g_i3k_net_last_sync_cmd.type	= 1;
	g_i3k_net_last_sync_cmd.cmd		= cmd;
	g_i3k_net_last_sync_cmd.layer	= layer or 1;

	i3k_game_send_cmd(cmd);

	return true;
end

function i3k_game_send_cmd_ex(cmd)
	local _cmd = ""
	for k, v in ipairs(cmd) do
		_cmd = _cmd .. v .. "|"
	end

	g_i3k_rpc_manager:LuaChannel(_cmd);
end

function i3k_game_send_cmd_sync_ex(cmd, layer)
	if g_i3k_net_last_sync_cmd.valid then
		return false;
	end

	g_i3k_net_last_sync_cmd.valid	= true;
	g_i3k_net_last_sync_cmd.type	= 2;
	g_i3k_net_last_sync_cmd.cmd		= cmd;
	g_i3k_net_last_sync_cmd.layer	= layer or 1;

	i3k_game_send_cmd_ex(cmd);

	return true;
end

function i3k_game_send_cmd2(cmd)
	local datas = Engine.StringVector();
	for k = 1, #cmd do
		datas:push_back(cmd[k]);
	end
	g_i3k_rpc_manager:LuaChannel2(datas);
end

function i3k_game_send_cmd2_sync(cmd, layer)
	if g_i3k_net_last_sync_cmd.valid then
		return false;
	end

	g_i3k_net_last_sync_cmd.valid	= true;
	g_i3k_net_last_sync_cmd.type	= 3;
	g_i3k_net_last_sync_cmd.cmd		= cmd;
	g_i3k_net_last_sync_cmd.layer	= layer or 1;

	i3k_game_send_cmd2(cmd);

	return true;
end
