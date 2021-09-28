----------------------------------------------------------------
local require = require;

require("logic/state/i3k_logic_state");


------------------------------------------------------
i3k_logic_state_shortcut = i3k_class("i3k_logic_state_shortcut", i3k_logic_state);

function i3k_logic_state_shortcut:ctor()
end

function i3k_logic_state_shortcut:Do(fsm, evt)
	g_i3k_logic:OpenLoginUI()
	local logic = i3k_game_get_logic();
	local cfg = g_i3k_game_context:GetUserCfg();
	local userName = cfg:GetUserName()
	if userName ~= "" then
		local sound = i3k_db_sound[i3k_db_common.login.bgm];
		if sound then
			i3k_game_play_bgm(sound.path, 1);
		end
		local data = g_i3k_game_context:getPushServiceData()
		g_i3k_game_handler:SetPushServiceData(data)
		
		local serverList = cfg:GetRecentServerList()
		local host, port = i3k_get_host_port(cfg:GetRecentServerIp())
		local channelName = i3k_game_get_channel_name()
		i3k_game_set_login_server_id(serverList[1])
		i3k_start_login(host, port, userName, channelName)
	else
		i3k_set_short_cut_type(0)
		logic:OnShortCutToLogin()
	end
	return true;
end

function i3k_logic_state_shortcut:Leave(fsm, evt)
	local logic = i3k_game_get_logic();
	if logic then
		logic:OnLeaveShortCut()
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Login);
end

function i3k_logic_state_shortcut:OnUpdate(dTime)
	return true;
end

function i3k_logic_state_shortcut:OnLogic(dTick)
	return true;
end
