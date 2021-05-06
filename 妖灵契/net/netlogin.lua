module(..., package.seeall)

--GS2C--

function GS2CHello(pbdata)
	local time = pbdata.time
	--todo
	g_LoginCtrl:OnServerHello()
	g_TimeCtrl:ServerHelloTime(time)
end

function GS2CLoginError(pbdata)
	local pid = pbdata.pid
	local errcode = pbdata.errcode --1001  in_login 1002 in_logout
	--todo
	g_LoginCtrl:HideLoginTips()
	if errcode == 0 then
		return
	elseif errcode == 1 then
		g_NotifyCtrl:FloatMsg("登录失败")
	elseif errcode == 1001 then
		g_NotifyCtrl:FloatMsg("正在登录中...")
	elseif errcode == 1002 then
		g_NotifyCtrl:FloatMsg("离线了")
		g_NetCtrl:ReconnectConfirm()
	elseif errcode == 1003 then
		g_NotifyCtrl:FloatMsg("登录的角色不存在")
	elseif errcode == 1004 then
		g_NotifyCtrl:FloatMsg("角色名已存在")
	elseif errcode == 1005 then
		g_NotifyCtrl:FloatMsg("正在维护中")
		g_NetCtrl:ReconnectConfirm()
	elseif errcode == 1006 then
		main.ResetGame()
		local args ={
			title = "登录异常",
			msg = "你的帐号已在其他地方登录, 是否重新登录",
			okCallback = function() g_LoginCtrl:Logout() end,
			okStr = "重新登录",
			forceConfirm = true,
		}
		g_WindowTipCtrl:SetWindowConfirm(args)
	elseif errcode == 1008 then
		g_NotifyCtrl:FloatMsg("帐号角色已达上限")
	elseif errcode == 1011 then
		g_LoginCtrl:InitValue()
		g_NotifyCtrl:FloatMsg("帐号连接已失效, 正在重连...")
		if g_SdkCtrl:IsLogin() then
			g_SdkCtrl:Logout()
		else
			g_SdkCtrl:Login()
		end
	elseif errcode == 1012 then
		g_NotifyCtrl:FloatMsg("角色连接已失效, 正在重连...")
		g_LoginCtrl.m_LoginInfo["role_token"] = nil
		g_LoginCtrl.m_ReconnectInfo["role_token"] = nil
		g_LoginCtrl.m_LoginInfo["pid"] = nil
		g_LoginCtrl.m_ReconnectInfo["pid"] = nil
		g_LoginCtrl:Reconnect()
	elseif errcode == 1013 then
		g_NotifyCtrl:FloatMsg("服务器人数已满")
	elseif errcode == 1014 then
		g_NotifyCtrl:FloatMsg("游戏版本号过低，请更新")
	elseif errcode == 1015 then
		main.ResetGame()
		local args ={
			title = "登录异常",
			msg = "登录异常, 是否重新登录",
			okCallback = function() g_LoginCtrl:Logout() end,
			okStr = "重新登录",
			forceConfirm = true,
		}
		g_WindowTipCtrl:SetWindowConfirm(args)
	else
		local args ={
			title = "登录异常",
			msg = "登录异常, 返回码:"..tostring(errcode),
			okCallback = function()
				g_LoginCtrl:Logout()
			end,
			okStr = "重新登录",
			forceConfirm = true,
			hideCancel = true,
		}
		g_WindowTipCtrl:SetWindowConfirm(args)
	end
	print("Login err", pid, errcode)
end

function GS2CLoginErrorNotify(pbdata)
	local cmd = pbdata.cmd
	--todo
	local args ={
		title = "提示",
		msg = cmd,
		okCallback = function() end,
		okStr = "确定",
		forceConfirm = true,
		hideCancel = true
	}
	g_LoginCtrl:HideLoginTips()
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function GS2CLoginAccount(pbdata)
	local account = pbdata.account
	local role_list = pbdata.role_list
	local channel = pbdata.channel
	--todo
	g_LoginCtrl:LoginAccountSuccess(account, role_list)
end

function GS2CLoginRole(pbdata)
	local account = pbdata.account
	local pid = pbdata.pid
	local role = pbdata.role
	local role_token = pbdata.role_token
	local is_gm = pbdata.is_gm
	local channel = pbdata.channel
	local xg_account = pbdata.xg_account --信鸽注册帐号
	--todo
	local xg_token = C_api.XinGeSdk.RegisterWithAccount(xg_account)
	netother.C2GSSendXGToken(xg_token)
	if is_gm == 1 then
		Utils.IsDevUser = function() return true end
		local oView = CNotifyView:GetView()
		if oView then
			oView.m_OrderBtn:SetActive(true)
		end
		Utils.UpdateLogLevel()
	end
	if C_api.Utils.GetUpdateMode() ~= enum.UpdateMode.Update then
		Utils.UpdateLogLevel()
	end
	if g_CreateRoleCtrl:IsInCreateRole() then
		g_MagicCtrl:Clear("createrole")
		g_MapCtrl:AddLoadDoneCb(function()
			local oCam = g_CameraCtrl:GetMainCamera()
			if oCam:GetActive() then
				CMainMenuView:ShowView()
			end
		end)
		g_CreateRoleCtrl:EndCreateRole()
	else
		CMainMenuView:ShowView()
		g_LoginCtrl:ShowLoginTips("加载地图中")
	end
	g_LoginCtrl:UpdateLoginInfo({["token"]=g_LoginCtrl.m_VerifyInfo.token ,["account"]= account, ["role_token"]=role_token, ["pid"]=pid})
	local dAttr = {}
	if role then
		local dDecode = g_NetCtrl:DecodeMaskData(role, "role")
	table.update(dAttr, dDecode)
	end
	dAttr.pid = pid
	local sTitle = g_ServerCtrl:GetCurServerName().." 帐号:"..account
	Utils.SetWindowTitle(sTitle)
	g_AttrCtrl:ResetAll()
	g_AttrCtrl:UpdateAttr(dAttr)
	g_TimeCtrl:StartBeat()
	g_ChatCtrl:StartHelpTip()
	g_ChatCtrl:InitAudioFilter()
	g_TeamCtrl:InitTeamSetting()
	g_TitleCtrl:LoginInit()
	g_CameraCtrl:InitCtrl()
	g_LoginCtrl:LoginRoleSuccess(pid)
	g_ScheduleCtrl:AutoCheckRegionSchedule()
	g_WarCtrl.m_AnimSpeed = IOTools.GetRoleData("war_speed") or 1

	if Utils.IsAndroid() then
		C_api.TalkingData.SetupAccount(tostring(pid))
	end
	Utils.AddTimer(function() g_NotifyCtrl:HideConnect() end, 0, 0)
end

function GS2CCreateRole(pbdata)
	local account = pbdata.account
	local role = pbdata.role
	local channel = pbdata.channel
	--todo
	g_LoginCtrl:CreateRoleSuccess(account, role)
end

function GS2CCheckInviteCodeResult(pbdata)
	local result = pbdata.result --0为没有有效邀请码，1为有
	local msg = pbdata.msg
	--todo
	g_LoginCtrl:CheckInviteCodeResult(result, msg)
end

function GS2CSetInviteCodeResult(pbdata)
	local result = pbdata.result --0为没有有效邀请码，1为有
	local msg = pbdata.msg
	--todo
	g_LoginCtrl:SetInviteCodeResult(result, msg)
end

function GS2CQueryLogin(pbdata)
	local delete_file = pbdata.delete_file --删除的导表资源文件名字
	local res_file = pbdata.res_file --新增或者改变的资源文件信息
	local code = pbdata.code --客户端在线更新代码
	--todo
	print("netlogin.GS2CQueryLogin-->")
	DataTools.UpdateData(delete_file, res_file)
	g_LoginCtrl:OnDataUpdateFinished()
	Utils.UpdateCode(code)
end


--C2GS--

function C2GSLoginAccount(account, token, device, platform, mac, client_svn_version, client_version, os, udid, imei, is_qrcode)
	local t = {
		account = account,
		token = token,
		device = device,
		platform = platform,
		mac = mac,
		client_svn_version = client_svn_version,
		client_version = client_version,
		os = os,
		udid = udid,
		imei = imei,
		is_qrcode = is_qrcode,
	}
	g_NetCtrl:Send("login", "C2GSLoginAccount", t)
end

function C2GSLoginRole(account, pid, scene_model)
	local t = {
		account = account,
		pid = pid,
		scene_model = scene_model,
	}
	g_NetCtrl:Send("login", "C2GSLoginRole", t)
end

function C2GSCreateRole(account, role_type, name)
	local t = {
		account = account,
		role_type = role_type,
		name = name,
	}
	g_NetCtrl:Send("login", "C2GSCreateRole", t)
end

function C2GSReLoginRole(pid, role_token, scene_model)
	local t = {
		pid = pid,
		role_token = role_token,
		scene_model = scene_model,
	}
	g_NetCtrl:Send("login", "C2GSReLoginRole", t)
end

function C2GSSetInviteCode(invitecode)
	local t = {
		invitecode = invitecode,
	}
	g_NetCtrl:Send("login", "C2GSSetInviteCode", t)
end

function C2GSLogoutByOneKey()
	local t = {
	}
	g_NetCtrl:Send("login", "C2GSLogoutByOneKey", t)
end

function C2GSChangeAccount()
	local t = {
	}
	g_NetCtrl:Send("login", "C2GSChangeAccount", t)
end

function C2GSQueryLogin(res_file_version)
	local t = {
		res_file_version = res_file_version,
	}
	g_NetCtrl:Send("login", "C2GSQueryLogin", t)
end

