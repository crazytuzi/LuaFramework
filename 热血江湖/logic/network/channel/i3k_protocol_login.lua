------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------
function i3k_sbean.user_role_list.handler(bean)
	if not g_i3k_game_context then return false; end
	local roles = bean.roles
	local csize = #roles

	g_i3k_ui_mgr:CloseAllOpenedUI(eUIID_CSelectChar, eUIID_CCreateChar, eUIID_SelChar)

	if csize and csize > 0 then
		g_i3k_game_context:ClearRoleList()
		for i = 1, csize do
			local _char = { }
			local roleOverview = roles[i].overview
			local roleModel = roles[i].model

			_char._id		= roleOverview.id
			_char._name		= roleOverview.name
			_char._bwType 	= roleOverview.bwType
			_char._type		= roleOverview.type
			_char._gender	= roleOverview.gender
			_char._level	= roleOverview.level
			_char._headBorder	= roleOverview.headBorder
			_char._face	    = roleModel.face
			_char._hair	    = roleModel.hair
			_char._equips	= roleModel.equips
			_char._heirloom	= roleModel.heirloom
			_char._fashions	= roleModel.curFashions
			_char._isfashionShow	= roleModel.showFashionTypes
			_char._equipParts 	= roleModel.equipParts
			_char._weaponSoulShow = roleModel.weaponSoulShow
			_char._armor = roleModel.armor.id~=0 and {id = roleModel.armor.id, stage = roleModel.armor.rank, hideEffect = 0 } or {id = 0, stage = 0, hideEffect = 0}
			_char._soaringDisplay = roleModel.soaringDisplay
			g_i3k_game_context:AddRoleList(_char);
		end

	end

	local cfg = g_i3k_game_context:GetUserCfg()
	local roleInfo = g_i3k_game_context:GetRoleList()
	local lastRoleIdx =  cfg:GetSelectRole()

	if csize and csize == 0 then
		local logic = i3k_game_get_logic()
		logic:onFirstCreateRole()
		logic:OnClearRole()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SelChar, "createChar")
		g_i3k_game_context:setFirstCreateRoleFlag(true)
		return
	end

	local logic = i3k_game_get_logic()
	if logic then
		if not i3k_get_is_use_short_cut() or not roleInfo[lastRoleIdx] then
			logic:OnCharList()
			logic:OnClearRole()
		end
	end
end

----------------------------------------------------
function i3k_sbean.user_login_res.handler(bean, req)
	local res = bean.errCode
	if req then
		local username = req.openId
		local channel = req.channel
	end
	local arg = bean.arg
	g_i3k_game_context:ResetLeadMode()
	if res == eUSERLOGIN_OK or res == eUSERROLELOGIN_OK then
		i3k_game_reset_click_data()
		i3k_on_authed_success()
		if res == eUSERLOGIN_OK then
			local cfg = g_i3k_game_context:GetUserCfg()
			local roleInfo = g_i3k_game_context:GetRoleList()
			local lastRoleIdx =  cfg:GetSelectRole()
			if not i3k_get_is_use_short_cut() or not roleInfo[lastRoleIdx] then
				i3k_on_user_login_ok()
			else
				i3k_do_role_login(roleInfo[lastRoleIdx]._id)
			end
		elseif res == eUSERROLELOGIN_OK then
			i3k_on_role_login_ok(arg == 0)
		end
	else
		if res == eUSERLOGIN_NOT_INSERVICE then
			g_i3k_ui_mgr:PopupTipMessage("服务器正在维护,请稍后重试")
		elseif res == eUSERLOGIN_ID_INVALID then
			g_i3k_ui_mgr:PopupTipMessage("用户帐号非法")
		elseif res == eUSERLOGIN_VERIFY_FAILED then
			g_i3k_ui_mgr:PopupTipMessage("登入验证失败")
		elseif res == eUSERLOGIN_ALREADY_LOGIN then
			g_i3k_ui_mgr:PopupTipMessage("正在登入中")
		elseif res == eUSERLOGIN_LOGIN_KEY_EXPIRED then
			g_i3k_ui_mgr:PopupTipMessage("登录过期请退出重新登录")
		elseif res == eUSERLOGIN_LOAD_USER_FAILED then
			if arg == eUSERLOGIN_USER_KEY_TOKEN_EXPIRED then
				g_i3k_ui_mgr:PopupTipMessage("帐号key过期")
				g_i3k_game_handler:ReturnInitView(false)
			else
				g_i3k_ui_mgr:PopupTipMessage("读取帐号资料失败")
			end
		elseif res == eUSERLOGIN_LOCK_BUSY then
			g_i3k_ui_mgr:PopupTipMessage("相同帐号当前正在登入中")
		elseif res == eUSERLOGIN_ROLE_BANNED then
			local leftTime = bean.arg
			local reason = bean.reason
			local leftTimeStr = math.modf(leftTime / 60)
			local msg = "帐号异常，请联系客服人员"
			leftTimeStr = leftTimeStr == 0 and 1 or leftTimeStr
			if reason ~= nil and reason ~= "" and leftTime ~= 0 then
				msg = leftTime > 0 and string.format("帐号被封禁，距离解封还剩%d%s",leftTimeStr,"分钟") or "帐号永久封禁"
				msg = reason..msg..",请联系客服人员"
			end
			g_i3k_ui_mgr:PopupTipMessage(msg)
			i3k_on_connection_force_close(-1)
		elseif res == eUSERLOGIN_LOAD_ROLE_FAILED then
			g_i3k_ui_mgr:PopupTipMessage("读取角色数据失败")
		elseif res == eUSERLOGIN_CLASSTYPE_INVALID then
			g_i3k_ui_mgr:PopupTipMessage("创建角色职业类型非法")
		elseif res == eUSERLOGIN_ROLENAME_INVALID then
			g_i3k_ui_mgr:ShowMessageBox1("您的名字中有非法字元，请重新命名")
		elseif res == eUSERLOGIN_RECONNECT_CREATE_INVALID then
			g_i3k_ui_mgr:PopupTipMessage("创建角色性别类型非法")
		elseif res == eUSERLOGIN_CREATE_ROLE_NAME_USED then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3));
		elseif res == eUSERLOGIN_CREATE_ROLE_FAILED then
			g_i3k_ui_mgr:PopupTipMessage("创建角色失败")
		elseif res == eUSERLOGIN_USER_NAME_EMPTY then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Login, "autoUserLogin", i3k_get_auto_user_name(arg))
		elseif res == eUSERLOGIN_ZONE_ID_INVALID then
			g_i3k_ui_mgr:PopupTipMessage("服务器id非法")
		elseif res == eUSERLOGIN_GAME_CHANNEL_INVALID then
			g_i3k_ui_mgr:PopupTipMessage("管道名非法")
		elseif res == eUSERLOGIN_NEED_VERIFY_REGISTER then
			g_i3k_ui_mgr:OpenUI(eUIID_Invite)
			g_i3k_ui_mgr:RefreshUI(eUIID_Invite)
		elseif res == eUSERLOGIN_VERIFY_REGISTER_FAILED then
			if arg == eUSERLOGIN_ACTIVE_KEY_INVALID then
				g_i3k_ui_mgr:PopupTipMessage("您输入的邀请码非法")
			elseif arg == eUSERLOGIN_ACTIVE_KEY_BATCHID_INVALID then
				g_i3k_ui_mgr:PopupTipMessage("您输入的邀请码批次非法")
			elseif arg == eUSERLOGIN_ACTIVE_KEY_DB_ERROR then
				g_i3k_ui_mgr:PopupTipMessage("资料库繁忙")
			elseif arg == eUSERLOGIN_ACTIVE_KEY_DB_NOT_CONTAIN_KEY then
				g_i3k_ui_mgr:PopupTipMessage("您输入的邀请码不存在")
			elseif arg == eUSERLOGIN_ACTIVE_KEY_DB_KEY_UESD then
				g_i3k_ui_mgr:PopupTipMessage("您输入的邀请码已被被使用过")
			end
			g_i3k_ui_mgr:OpenUI(eUIID_Invite)
			g_i3k_ui_mgr:RefreshUI(eUIID_Invite, req.loginInfo.arg.exParam)
		elseif res == eUSERLOGIN_ONLINE_ROLE_FULL then
			--g_i3k_ui_mgr:PopupTipMessage("服务器人数已满，请稍后重试")
			i3k_sbean.query_loginqueue()
		elseif res == eUSERLOGIN_QUEUE_ROLE_FULL then
			g_i3k_ui_mgr:PopupTipMessage("当前服务器排队已满，请稍后重试")
		elseif res == eUSERLOGIN_DENY_CREATE_USER then
			g_i3k_ui_mgr:PopupTipMessage("禁止创建账号")
		elseif res == eUSERLOGIN_DENY_CREATE_ROLE then
			g_i3k_ui_mgr:PopupTipMessage("禁止创建角色")
		end
		if req and req.roleId == 0 then
			if not req.createParam then
				g_i3k_game_handler:RoleBreakPoint("Game_Role_Login_Fail", "")
			else
				g_i3k_game_handler:RoleBreakPoint("Game_Create_Role_Fail", "")
			end
		else
			g_i3k_game_handler:RoleBreakPoint("Game_User_Login_Fail", "")
		end
	end
end

----------------------------------------------------
-- 客户端通知服务器要退出到选人界面
function i3k_sbean.role_logout()
	local data = i3k_sbean.role_logout_req.new()
	i3k_game_send_str_cmd(data, "role_logout_res")
end

function i3k_sbean.role_logout_res.handler(bean)
	if bean.ok == 1 then
		g_i3k_game_context:SetSuperOnHookValid(false)
		g_i3k_game_context:clearItemCheckList()
		g_i3k_game_context:EscortCarMoveSync()
		g_i3k_game_context:stopRoleNameInvalidRemind()
		i3k_game_reset_click_data()
		i3k_on_role_logout_ok()
		g_i3k_ui_mgr:CloseAllOpenedUI()
		local logic = i3k_game_get_logic()
		if logic then
			logic:OnRelogin()
		end
		i3k_do_user_login()
--		local login = i3k_sbean.user_login_req.new()
--		local loginData = g_i3k_game_context:GetLoginData();
--		login.openId = loginData.uname
--		login.channel = loginData.channel
--		local loginInfo = g_i3k_game_context:GetLoginInfo()
--		if loginInfo then
--			login.loginInfo = loginInfo
--			login.roleId = 0
--			login.roleName = ""
--			login.classType = 0
--			login.gender = 0
--			login.logout = true
--			i3k_game_send_str_cmd(login, "user_login_res")
--		end
		DCAccount.logout()
	end
end

----------------------------------------------------
function i3k_sbean.server_echo.handler(bean)
	i3k_log("recv server echo:" .. bean.stamp)
end

function i3k_sbean.server_info.handler(bean)
	i3k_game_reset_time(bean.now)
	i3k_game_set_server_id(bean.id)
	i3k_game_set_server_open_day(bean.openDay)
	i3k_game_set_server_open_time(bean.openTime)

	-- local ping = i3k_sbean.client_ping.new()
	-- ping.stamp = 1105
	-- i3k_game_send_str_cmd(ping)
end

function i3k_sbean.game_sync.handler(bean)
	i3k_on_role_begin_login()
	g_i3k_game_context:SyncGameInfo(bean.refreshDay)
end


function i3k_sbean.user_force_close.handler(bean)
--	if g_i3k_game_context then
--		g_i3k_game_context:forceClose(bean.errCode)
--	end
	i3k_on_connection_force_close(bean.errCode)
--	local errcode = bean.errCode
--	if errcode == eFCLOSE_DIS_CONNECT then
--		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(4))
--	elseif errcode == eFCLOSE_USER_LOGIN then
--		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(5))
--	elseif errcode == eFCLOSE_UPDATE_INS then
--		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(6))
--	elseif errcode == eFCLOSE_UPDATE_HOT then
--		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(7))
--	end
end

-- 客户端查询排队位置
function i3k_sbean.query_loginqueue()
	local data = i3k_sbean.query_loginqueue_pos.new()
	i3k_game_send_str_cmd(data)
end

-- 客户端查询排队位置
function i3k_sbean.role_loginqueue_pos.handler(bean)
	if bean.pos ~= 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_ServerLineUp)
		g_i3k_ui_mgr:RefreshUI(eUIID_ServerLineUp, bean.pos)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_ServerLineUp)
	end
	g_i3k_game_context:SetLoginQueuePos(bean.pos)
end

-- 一天首次登陆会收到此协议，打开福利界面
function i3k_sbean.day_first_login.handler(bean)
	g_i3k_game_context:setDayFirstLogin(true)
end
function i3k_sbean.sync_first_access_info.handler(res)
	g_i3k_game_context:setFirstClearInfo(res.info)
end
