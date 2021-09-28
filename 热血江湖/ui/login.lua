-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_login = i3k_class("wnd_login", ui.wnd_base)
--模型id
local piaoModelId = 305
local hehuaModelId = 423
local isFirst = true

function wnd_login:ctor()
	self._name = "";
	self._host = "";
	self._port = 0;
	self._serverId = 0
end

function wnd_login:configure(...)
	local btnLogin = self._layout.vars.btnLogin;
	btnLogin:onClick(self, self.confirmClick);

	-- self.piao_model = self._layout.vars.piao_model
	self.serverIP = self._layout.vars.serverIP
	self.userName = self._layout.vars.userName
	self.channel = self._layout.vars.channel
	self.gsID = self._layout.vars.gsID
	self.serverBtn = self._layout.vars.serverBtn
	self.serverLabel = self._layout.vars.serverLabel

	self.c_zi = self._layout.anis.c_zi
	self.serverBtn:onClick(self, self.onServerBtn)

	-- self.hehua_model = self._layout.vars.hehua_model
	self.game_notice_btn = self._layout.vars.game_notice_btn
	self.game_notice_btn:onClick(self,self.onGameNotice)
	self._layout.vars.agreement_img:onClick(self, self.onAgreement)
	self._layout.vars.userName:setMaxLength(i3k_db_common.inputlen.accountlen)
	self.selectAgreement = self._layout.vars.selectAgreement
	self.selectAgreement:onClick(self, self.onSelectAgreement)
	self.select_icon = self._layout.vars.select_icon
	
	self.clickServerCount = 0
	self.clickAnnouncementCount = 0
end

function wnd_login:onGameNotice(sender)
	self.clickAnnouncementCount = self.clickAnnouncementCount + 1
	if self.clickAnnouncementCount >= 3 then
		self.clickAnnouncementCount = 0
		g_i3k_game_handler:RefreshAnnouncement()
	end
	g_i3k_logic:OpenGameNoticeUI()
end

function wnd_login:refresh()
	i3k_update_msdk()
	local cfg = g_i3k_game_context:GetUserCfg();
	local recentServerList = cfg:GetRecentServerList()
	local serverInfo = {}
	serverInfo = i3k_get_recent_server_info(recentServerList)
	if serverInfo then
		self._serverId = serverInfo.serverId
	else
		serverInfo = {}
		serverInfo.addr = ""
		serverInfo.name = ""
	end
	if i3k_game_get_os_type() == eOS_TYPE_WIN32 then
		serverInfo = {}
		serverInfo.addr = cfg:GetRecentServerIp()
		serverInfo.name = cfg:GetRecentServerName()
		self._serverId = 1001
	end
	self:updateLabel(serverInfo, i3k_game_get_username(), i3k_game_get_channel_name())

--	if g_i3k_game_context then
--		g_i3k_game_context._onNetConnected = function(res)
--			self:OnNetConnected(res);
--		end
--	end
	self:updateModel()
	self:playAnimation()
	self.select_icon:setVisible(true)
end

function wnd_login:updateLabel(serverInfo, roleName, channelName)
	self.serverIP:setText(serverInfo.addr);
	self.userName:setText(roleName);
	self.channel:setText(channelName)
	self.serverLabel:setText(serverInfo.name)
	self.gsID:setText(self._serverId)

	self.userName:setVisible(i3k_game_get_os_type() == eOS_TYPE_WIN32)
	self.serverIP:setVisible(i3k_game_get_os_type() == eOS_TYPE_WIN32)
	self.channel:setVisible(i3k_game_get_os_type() == eOS_TYPE_WIN32)
	self.gsID:setVisible(i3k_game_get_os_type() == eOS_TYPE_WIN32)
	--[[self.userName:setVisible(true)
	self.serverIP:setVisible(true)
	self.channel:setVisible(true)
	self.gsID:setVisible(true)--]]
end

function wnd_login:updateServerLabel(serverIP, serverName, serverId)
	self.serverIP:setText(serverIP)
	self.serverLabel:setText(serverName)
	self.gsID:setText(serverId)
	self._serverId = serverId
end

function wnd_login:getLoginChannel()
	return i3k_game_get_os_type() == eOS_TYPE_WIN32 and self.channel:getText() or g_i3k_game_handler:GetChannelName()
end

function wnd_login:updateModel()
	local path = i3k_db_models[piaoModelId].path
	local uiscale = i3k_db_models[piaoModelId].uiscale
	-- self.piao_model:setSprite(path)
	-- self.piao_model:setSprSize(uiscale)
	-- self.piao_model:playAction("stand")

	local path = i3k_db_models[hehuaModelId].path
	local uiscale = i3k_db_models[hehuaModelId].uiscale
	-- self.hehua_model:setSprite(path)
	-- self.hehua_model:setSprSize(uiscale)
	-- self.hehua_model:playAction("stand")
end

function wnd_login:onHide()
	local hdr = i3k_game_get_lua_channel_handler(eNChannel_Login);
	if hdr then
		hdr._onProc = nil;
	end

--	if g_i3k_game_context then
--		g_i3k_game_context._onNetConnected = nil;
--	end

	g_i3k_ui_mgr:CloseUI(eUIID_CSelectChar);
end

function wnd_login:onUpdate(dTime)
end

function wnd_login:confirmClick(sender)
	if not self.select_icon:isVisible() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16362))
		return
	end
	local serverName = self.serverLabel:getText()
	g_i3k_game_context:SetLoginServerName(serverName)
	local userName = self._layout.vars.userName;
	if userName then
		self._name = userName:getText();
	end
	local serverIP = self._layout.vars.serverIP;
	if serverIP then
		local host, port = i3k_get_host_port(serverIP:getText())
		self._host = host
		self._port = port
	end
	local namecount = i3k_get_utf8_len(self._name)
	--[[if self._name == "" then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1))
		return--]]
	if namecount > i3k_db_common.inputlen.accountlen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(234))
		return
	elseif self._host == "" or not self._port then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2))
		return
	else
		self:doLogin(self._host, self._port, self._name, self:getLoginChannel(), self._serverId)
	end
end

function wnd_login:autoUserLogin(name)
	self._layout.vars.userName:setText(name)
	self:doLogin(self._host, self._port, name, self:getLoginChannel(), self._serverId)
end

function wnd_login:doLogin(host, port, name, channel, serverId)
	if g_i3k_game_context then
		local recentServerName = self.serverLabel:getText()
		local recentServerId = self.serverIP:getText()
		local cfg = g_i3k_game_context:GetUserCfg()
		if cfg then
			if cfg:GetUserName() ~= name then-- 当同一个设备登陆了新用户时，重置设置
				cfg:restoreUserCfg()
			end
			if name ~= "" then
				cfg:SetUserName(name)
			end
			i3k_update_recent_server_list(serverId)
			cfg:SetRecentServerName(recentServerName)
			cfg:SetRecentServerIp(recentServerId)
			cfg:SetChannelName(channel)
		end
		i3k_game_set_login_server_id(tonumber(self.gsID:getText()))
		i3k_start_login(host, port, name, channel)
	end
end

function wnd_login:onServerBtn(sender)
	self.clickServerCount = self.clickServerCount + 1
	if self.clickServerCount >= 3 then
		self.clickServerCount = 0
		g_i3k_game_handler:RefreshServerlist()
		i3k_update_server_list_from_netwrok()
	end
	g_i3k_ui_mgr:OpenUI(eUIID_SelectServer)
	g_i3k_ui_mgr:RefreshUI(eUIID_SelectServer, self._serverId)
end

--function wnd_login:OnNetConnected(res)
--	if res then
--		g_i3k_game_context:DoLogin(self._name, self:getLoginChannel());
--	end
--end
function wnd_login:OnConfirm(suc, code)
	if suc then
		if code == eUSERLOGIN_OK then
			local logic = i3k_game_get_logic();
			if logic then
				logic:OnLogin();
			end
		elseif code == eUSERROLELOGIN_OK then
			local logic = i3k_game_get_logic();
			if logic then
				logic:OnPlay();
			end
			if g_i3k_game_context then
				g_i3k_game_context:OnLogined();
			end
		end
	elseif code == eUSERLOGIN_ROLE_BANNED then
	elseif code == eUSERLOGIN_USER_NOT_EXIST then
		self:hide();
		local sel_char = g_i3k_ui_mgr:OpenUI(eUIID_CSelectChar);
		if sel_char then
			sel_char.onNextStep = function(charType)
				self:OnSelectChar(charType);
			end
		end
	elseif code == eUSERLOGIN_CREATE_ROLE_NAME_USED then
	end
end
function wnd_login:OnSelectChar(charType)
	g_i3k_ui_mgr:CloseUI(eUIID_CSelectChar);
	self._cselCharType = charType;
	if create_char then
		create_char.onRegister = function(name, gender)
			self:OnCreateChar(name, gender);
		end
	end
end
function wnd_login:OnCreateChar(name, gender)
--	local login = i3k_sbean.user_login_req.new()
--	local loginData = g_i3k_game_context:GetLoginData();
--	login.openId = loginData.uname
--	login.channel = loginData.channel
--	local loginInfo = g_i3k_game_context:GetLoginInfo()
--	if loginInfo then
--		login.loginInfo = loginInfo
--		login.roleId = 0
--		login.roleName = name
--		login.classType = self._cselCharType
--		login.gender = gender--login.classType == 0 ? 0 : 1
--
--		i3k_game_send_str_cmd(login, i3k_sbean.user_login_res.getName())
--	else
--
--	end
end
function wnd_login:playAnimation()
	--if isFirst then
		self.c_zi.play()
	--end
	--isFirst = false
end

function wnd_login:onAgreement(sender)
	g_i3k_logic:OpenUserAgreementUI()
end

function wnd_login:onSelectAgreement(sender)
	local img = self._layout.vars.select_icon
	local aa = not img:isVisible()
	img:setVisible(not img:isVisible())
end

function wnd_create(layout)
	local wnd = wnd_login.new()
		wnd:create(layout)
	return wnd;
end
