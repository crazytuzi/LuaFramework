----------------------------------------------------------------
local require = require;

require("logic/state/i3k_logic_state");


------------------------------------------------------
i3k_logic_state_login = i3k_class("i3k_logic_state_login", i3k_logic_state);
function i3k_logic_state_login:ctor()
end

function i3k_logic_state_login:Do(fsm, evt)
	g_i3k_logic:OpenLoginUI()
	g_i3k_logic:OpenGameNoticeUI()
	
	local cfg = g_i3k_game_context:GetUserCfg()
	local isAgreement = cfg:GetIsAgreement()
	if not isAgreement then
		-- g_i3k_logic:OpenUserAgreementUI()
	end

	local sound = i3k_db_sound[i3k_db_common.login.bgm];
	if sound then
		i3k_game_play_bgm(sound.path, 1);
	end
	g_i3k_game_context:getInitNeedBanServices() -- 初始化下cfg中类型冲突的问题,并设置推送消息
	g_i3k_download_mgr:tryStartUpdate() -- 进入登录界面，然后就开始静默下载分包
	return true;
end

function i3k_logic_state_login:Leave(fsm, evt)
	g_i3k_ui_mgr:CloseUI(eUIID_Login);
end

function i3k_logic_state_login:OnUpdate(dTime)
	return true;
end

function i3k_logic_state_login:OnLogic(dTick)
	return true;
end
