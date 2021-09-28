RegistModules("Login/LoginConst")
RegistModules("Login/Vo/Character")
RegistModules("Login/LoginModel")
RegistModules("Login/LoginView")
RegistModules("Login/View/RoleCreatePanel")
RegistModules("Login/View/RoleSelectPanel")
RegistModules("Login/View/ButtonProfessionItem")
RegistModules("Login/View/ButtonSkillItem")
RegistModules("Login/View/ListSkillPreview")
RegistModules("Login/View/LabelNameInput")
RegistModules("Login/View/ButtonRole")
RegistModules("Login/View/AccountContent")
RegistModules("Login/View/AccountItem")
RegistModules("Login/View/AccountManagerPanel")
RegistModules("Login/View/CreateAccountPanel")
RegistModules("Login/View/LoginPanel")
RegistModules("Login/View/PhoneBindPanel")
RegistModules("Login/View/LoginBGComp")
RegistModules("Login/View/LoginInfoItem")
RegistModules("Login/View/VisitorLoginPanel")
RegistModules("Login/View/BtnSelectServer")
RegistModules("Login/View/ResetPasswordPanel")

RegistModules("Tips/LoginNameTips")
RegistModules("Tips/RoleSkillTips")

--角色信息配置表

LoginController = BaseClass(LuaController)

-- 初始化使用 .New(...)
function LoginController:__init( ... )
	self.model = LoginModel:GetInstance()
	self.kickState = false -- 踢下线（后端通知）
	self:InitEvent()
	self:RegistProto()
	self:Config()

	self.view = LoginView.New()
	if not self.view.isSceneLoaded then
		self:LoadRoleCreateSelectScene(function ()
			print("先加载完成场景了")
		end)
	end
	if isSDKPlat then
		SceneLoader.Show(true, false, 100, 100, "", "")
		SceneLoader.ShowProgress(false)
		SceneLoader.ShowIcon("loader")
		sdkToIOS:OpenLogin()
	else
		self.model:SetLoginState(0)
	end
end
-- 初始化所有角色信息（从配置表中）
function LoginController:Config()
	local tmp = {}
	local cfg =	GetCfgData("newroleDefaultvalue")
	for i = 1, #cfg do
		local oneRoleInfo = cfg[i]
		tmp[i] = {}
		tmp[i].career = oneRoleInfo.career
		tmp[i].sex = oneRoleInfo.sex
		tmp[i].skillDisplay = oneRoleInfo.skillDisplay
	end
	self.model:SetAllRolesCfgInfo(tmp)
end

-- 更新 主要是心跳
function LoginController:Update()
	if not Network.IsConneted() then
		return
	end
	self:RequireSeverTime() -- - 心跳请求
	-- collectgarbage("collect") -- 回收内存
end

function LoginController:RequireSeverTime()
	local send = common_pb.C_GetServerTime()
	self:SendMsg("C_GetServerTime", send) -- 心跳请求
end

-- 事件
function LoginController:InitEvent()
	local model = self.model
	self.handler1=GlobalDispatcher:AddEventListener(EventName.NET_CONNECTED, function () -- 成功连入[首次]网关|其他服务器
		if not model.isReLink then
			model.isReLink = true -- 回退到登录时，要把这个重置为false
			self:LoginGame()
		end
		RenderMgr.CreateCoTimer(function() self:Update() end,  GameConst.heartCD, -1, "Heart_Render")
		self.kickState = false
	end)
	self.handler2=GlobalDispatcher:AddEventListener(EventName.NET_RECONNECT, function () print("-- 重新成功连入网关")
		RenderMgr.CreateCoTimer(function() self:Update() end,  GameConst.heartCD, -1, "Heart_Render")
		model.isLogined = true
		self:C_LoginAgain()
		self.kickState = false
	end)

	local function reLink ()
		if self.kickState then return end
		GameLoader.LinkLoginSvr()
	end
	local function cancelLink()
		DelayCall(function ()
			if self.kickState then return end
			if model.isLogined then return end
			self.showAskRelogin()
		end, 5)
	end

	self.showAskRelogin = function ()
		if model:IsInGame() then
			if Network.againFailTimes >= 5 then
				UIMgr.Win_Confirm("提示", "您的网络已经断开\n是否重新连接游戏？", "重连", "否", reLink, cancelLink)
			else
				UIMgr.Win_FloatTip(StringFormat("您的网络已经断开,正在重新登录游戏({0}/5)!", Network.againFailTimes))
				self.kickState = true
				reLink()
			end
		else
			UIMgr.Win_FloatTip("您的网络已经断开,请重新登录游戏!")
			Network.ResetLinkTimes()
			model:SetLoginState(0)
		end
	end

	self.handler3=GlobalDispatcher:AddEventListener(EventName.NET_DISCONNECT, function ()
		RenderMgr.Realse("Heart_Render")
		if self.kickState then return end
		model.isLogined = false
		self.showAskRelogin()
	end)

	self.handler5 = model:AddEventListener(LoginConst.LOGIN_STATE_CHANGE, function () -- 根据状态开启登录界面
		local state = model:GetLoginState() print("登录状态改变", state)
		if state == 0 then								 -- 0 未登入用户
			if model.isExistRoleOnGame then
				model.isExistRoleOnGame = false
				print("重新角色上线,清除之前的数据!!!!")
				Message:GetInstance():Init()
				GlobalDispatcher:DispatchEvent(EventName.Player_AutoRunEnd)
				GlobalDispatcher:DispatchEvent(EventName.AutoFightEnd)
				GlobalDispatcher:DispatchEvent(EventName.RELOGIN_ROLE)
			end
			if not isSDKPlat then
				if model:IsHasAccount() then
					print("有账号用户－－－－－－－－－－－－－－－－＞")
					local lastAccountData = model:GetLastAccount()
					if not TableIsEmpty(lastAccountData) then
						if model:GetAutoHttpLogin() == false then
							local isVisitor = 0 
							local userName = lastAccountData.userName
							if lastAccountData.isVisitor then
								 isVisitor = 1  
								 userName = DeviceInfo:GetDeviceUID()
							end
							print("用户申请 登入账户  是否游客", isVisitor)
							self:ReqLoginAccount(userName, lastAccountData.passWord, isVisitor)
						else
							self:OpenVisitorLoginPanel(lastAccountData)
							local curPanel = self:GetCurPanel()
							if curPanel then curPanel:PopUpLoginNameTips() end
						end
					end
				else
					print("无账号用户－－－－－－－－－－－－－－－－＞")
					self:OpenAccountManagerPanel()
				end
			end
			
		elseif state == 1 then							 -- 1 用户登入成功
			self:Close()
			local roles = model:GetRoles()
			model:SortAllRolesInfo()
			local selectReady = function ()
				self:OpenRoleSelectPanel()
				if self.view ~= nil and self.view.curPanel then
					self.view.curPanel:SetOpenSource(LoginConst.PANEL_OPEN_SOURCE.LOGIN_PANEL)
				end
			end
			local createReady = function ()
				self:OpenRoleCreatePanel()
				if self.view ~= nil and self.view.curPanel then
					self.view.curPanel:SetOpenSource(LoginConst.PANEL_OPEN_SOURCE.LOGIN_PANEL)
				end
			end
			if #roles > 0 then
				if  self.view.isSceneLoaded then
					selectReady()
				else
					self:LoadRoleCreateSelectScene(selectReady)
				end
			else
				if self.view.isSceneLoaded then
					createReady()
				else
					self:LoadRoleCreateSelectScene(createReady)
				end
				
			end
		elseif state == 2 then									 -- 2 角色登入成功
			self:Close()
		end
	end)
end



-- 注册协议
	function LoginController:RegistProto()
		self:RegistProtocal("S_LoginGame")
		self:RegistProtocal("S_CreatePlayer")
		self:RegistProtocal("S_EnterGame")
		self:RegistProtocal("S_ExitGame")
		self:RegistProtocal("S_EnterComplete")
		self:RegistProtocal("S_Exception")
		self:RegistProtocal("S_Exception_Server")
		self:RegistProtocal("S_GetServerTime") -- (顺便心跳处理)获取服务器时间
		self:RegistProtocal("S_DeletePlayer")
		self:RegistProtocal("S_StopServer")
	end

-- 接收执行协议
	-- 系统消息提示
	function LoginController:S_Exception_Server( buff )
		local msg = self:ParseMsg(exception_pb.S_Exception_Server(), buff)
		if msg and msg.msg then
			UIMgr.Win_FloatTip(tostring(msg.msg))
		end
	end
	-- 错误码表
	function LoginController:S_Exception( buff )
		local model = self.model
		local msg = self:ParseMsg(exception_pb.S_Exception(), buff)
		local code = tonumber(msg.code)
		local em = model:GetSrvExecptionCfg( code ) or {}
		local msg = em.exceptionMsg or "[LoginController:S_Exception] "..(code or "nil")

		if msg then
			if code == 1309 then
				if (model:GetDropItemErrorCodeCnt() % 200) == 0 then
					UIMgr.Win_FloatTip(msg)
				end
				model:SetDropItemErrorCodeCnt()
			elseif code == 1113 then
				UIMgr.Win_Confirm("温馨提示", "元宝不足，是否前往充值", "确认", "取消", 
					function() 
						MallController:GetInstance():OpenMallPanel(nil, 2, nil, function() end)
					end, 
					function() 

					end)
			else
				UIMgr.Win_FloatTip(msg)
			end
		end
		GlobalDispatcher:DispatchEvent(EventName.SERVER_EXCEPTION, code)
		print(string.format("【x】 后端返回(%s)错误: %s", code,  msg))
	end
	-- 服务器心跳及时间返回
	function LoginController:S_GetServerTime( buff )
		local msg = self:ParseMsg(common_pb.S_GetServerTime(), buff)
		if not msg then return end
		local serverTime = toLong(msg.serverTime)
		if serverTime then self.model:SetServerTime(serverTime, true) end
	end
	-- 登录游戏
	function LoginController:S_LoginGame(buff)
		local msg = self:ParseMsg(login_pb.S_LoginGame(), buff)		
		local playerMsgs = msg.playerMsgs
		local model = self.model
		if playerMsgs then
			model:CleanRoles()
			for i=1,#playerMsgs do
				local vo = {}
				local protoVo = playerMsgs[i]
				vo.playerId = protoVo.playerId				
				vo.playerName = protoVo.playerName
				vo.career = protoVo.career
				vo.level = protoVo.level
				vo.dressStyle = protoVo.dressStyle
				vo.wingStyle = protoVo.wingStyle
				vo.weaponEquipmentId = protoVo.weaponStyle
				vo.loginTime = protoVo.loginTime
				vo.createTime = protoVo.createTime
				
				local cfg = GetCfgData("equipment"):Get(vo.weaponEquipmentId)
				if cfg then
					vo.weaponStyle = cfg.weaponStyle
				end	
				local c = Character.New(vo)
				model:AddRole( c )
			end
		end
		model:SetLoginState(1)
	end
	-- 创建角色成功
	function LoginController:S_CreatePlayer(buff)
		local msg = self:ParseMsg(login_pb.S_CreatePlayer(), buff)
		local role = msg.playerMsg
		local c = Character.New(role)
		local model = self.model
		model:AddRole(c)
		print("进入游戏, 玩家id：", role.playerId)
		model:SetLastRole(role.playerId)
		self:UploadRoleInfo(0)
		self:C_EnterGame( role.playerId ) -- 直接进入游戏不用CG
	end
	-- 进入游戏获取角色基础信息
	function LoginController:S_EnterGame(buff)
		local msg = self:ParseMsg(login_pb.S_EnterGame(), buff)
		local info = msg.loginMsg
		local comm = info.playerCommonMsg
		local character = nil
		local model = self.model
		if comm.guid then
			character = model:GetLoginRole()
			if character then
				character:SetMapId(info.mapId)
				local serverTime = toLong(info.serverTime)
				character:SetServerTime(serverTime, true)
				model:SetServerTime(serverTime or os.time()*1000, true)
				character:SetPlayerCommonMsg(comm)
				print("角色入场信息：", character:ToString())
				model.loginServerNo = character.severNo or model.loginServerNo
				model:SetLoginRole( character )
				
				self:UploadRoleInfo(1)

				AfterLoginRequire()
				if info.mapId then
					SceneController:GetInstance():C_EnterScene(info.mapId, 0)
					RenderMgr.DoNextFrame(function ()
						self:C_EnterComplete() -- 发给服务器拿数据
					end)
				end
				model:SetLoginState(2)
			end
		end
	end

	-- 上传信息到sdk平台
	function LoginController:UploadRoleInfo(state)
		if isSDKPlat then
			local model = self.model
			local character = model:GetLoginRole()
			local svrId = model.loginServerNo or "0"
			local svrName = model.loginServerNo or "0"
			local role = character or {}
			local rId = role.playerId or ""
			local rName = role.name or ""
			local lv = role.level or 0
			print("上传角色信息：",rId, rName, lv, "svrNo=", svrId, "svrName=", svrName)
			sdkToIOS:UploadRoleInfo(svrId, rId, svrName, rName, lv, state)
		end
	end


	-- 退出游戏(顶号或封号)
	function LoginController:S_ExitGame(buff)
		if self.kickState then return end
		RenderMgr.Realse("Heart_Render")
		if buff then
			local msg = self:ParseMsg(login_pb.S_ExitGame(), buff)
			print("退出游戏(顶号或封号):", msg.msg)
		end
		self.kickState = true
		if Network.IsConneted() then -- 这里处理有点问题的，东西没重置好@@@后期得改动
			Network.CloseSocket()
		end
		DelayCall(function ()
			UIMgr.Win_Confirm("安全提示", "            您的账号在其他地方登陆，        请检查账号安全！", "重新登录", "退出游戏", 
			function()
				SceneModel:GetInstance():Clear()
				local scene = SceneController:GetInstance():GetScene()
				self.kickState = false
				if scene then
					scene:Clear()
				end
				Network.ResetLinkTimes()
				self.model:SetLoginState(0)
			end,
			function()
				UnityEngine.Application.Quit()
			end)
		end, 0.5)
	end

	-- 退出游戏(玩家退出登录)
	function LoginController:UserExitGame()
		self.kickState = true
		-- if Network.IsConneted() then
		Network.CloseSocket()
		-- end
		RenderMgr.Realse("Heart_Render")
		SceneModel:GetInstance():Clear()
		local scene = SceneController:GetInstance():GetScene()
		self.kickState = false
		if scene then
			scene:Clear()
		end
		Network.ResetLinkTimes()
		self.model:SetLoginState(0)
		SettingCtrl:GetInstance().view = nil
	end
	
	-- 进入游戏完成后 拿取数据
	function LoginController:S_EnterComplete(buff)
		local msg = self:ParseMsg(login_pb.S_EnterComplete(), buff)
		print(" 外挂开关  开启", msg.testSwitch, "游戏数据初始---------------------->>")
		self.model:SetEnterData(msg) -- 事件 EventName.ENTER_DATA_INITED
		soundMgr:StopEffect()
		soundMgr:DestroyLoginAudioListener()
	end

	--收到删除角色回包
	function LoginController:S_DeletePlayer(buff)
		local msg = self:ParseMsg(login_pb.S_DeletePlayer(), buff)
		local model = self.model
		if msg.playerId ~= 0 then -- print("======== 收到删除角色回包：", msg.playerId)
			model:DeleteRole(msg.playerId)
			model:CleanLastRole(msg.playerId)
			GlobalDispatcher:DispatchEvent(EventName.DELETE_ROLE, msg.playerId)
		end
	end

	function LoginController:S_StopServer(buff)
		if self.kickState then return end
		RenderMgr.Realse("Heart_Render")
		self.kickState = true
		if Network.IsConneted() then
			Network.CloseSocket()
		end

		local msg = self:ParseMsg(login_pb.S_StopServer(), buff)
		if msg.endStopTime ~= 0 then
			if self.model:IsInGame() then
				local diffTime = TimeTool.GetDiffTime(msg.endStopTime)
				local strTips = ""
				local strDiffTime = 0
				if diffTime > 0 then
					 strDiffTime = TimeTool.GetTimeDHM(diffTime)
				else
					strDiffTime = LoginConst.DefaultMainTainTimeContent
				end
				strTips = StringFormat("十分抱歉，游戏已停服维护，您被强迫下线。请在约{0}后重试。", strDiffTime)
				self:PopUpReStartTips(strTips)
			end
		end
	end

-- 请求协议
	-- 断线重连  返回 S_EnterGame
	function LoginController:C_LoginAgain()
		local msg = login_pb.C_LoginAgain()
		local model = self.model
		if not TableIsEmpty(model.loginAccountData) then
			msg.userId = model.loginAccountData.userId
			msg.key = model.loginAccountData.key
			msg.time = model.loginAccountData.time
			msg.sign = model.loginAccountData.sign
			msg.playerId = model.loginPlayerId
			msg.serverNo = model.loginServerNo

			self:SendMsg("C_LoginAgain", msg)
			if NewbieGuideController then
				NewbieGuideController:GetInstance():ReStartCurGuide()
			end
		end
	end

	-- 登录游戏
	function LoginController:C_LoginGame(data)
		if data == nil then return end
		local model = self.model
		model.loginAccountData = data
		model.isReLink = false
		model.loginUseName = data.userName
		model.loginUsePwd = data.passWord
		model.userId = data.userId
		model.telePhone = data.telePhone or 0

		if not Network.IsConneted() then	-- 没新增账号 --model:AddAccountCountNum()
			GameLoader.LinkLoginSvr()
		else
			self:LoginGame() -- 旧账号登录
		end	
	end
	function LoginController:LoginGame()
		local msg = login_pb.C_LoginGame()
		local model = self.model
		local data = model.loginAccountData
		if not TableIsEmpty(data) then
			msg.userId = data.userId
			msg.key = data.key
			msg.time = tostring(data.time)
			msg.sign = data.sign
			local no = model:GetLastServerNo()
			msg.serverNo = no
			model.loginServerNo = no
			self:SendMsg("C_LoginGame", msg)
		end
	end
	-- 创建角色
	function LoginController:C_CreatePlayer(career, name)
		local msg = login_pb.C_CreatePlayer()
		msg.career = career
		msg.playerName = name
		local model = self.model
		local no = model.loginServerNo
		msg.serverNo = no
		msg.telePhone = toLong(model.telePhone)
		
		self:SendMsg("C_CreatePlayer", msg)
	end
	-- 进入游戏 key:随机秘钥
	function LoginController:C_EnterGame(playerId)-- 设置当前登录的角色
		local model = self.model
		local role =model:GetRoleByPlayerId( playerId )
		model:SetLoginRole(role)
		local msg = login_pb.C_EnterGame()
		msg.playerId = playerId
		model.loginPlayerId = playerId
		model.isLogined = true
		msg.telePhone = toLong(model.telePhone)
		
		self:SendMsg("C_EnterGame", msg)
	end
	-- 进入游戏完成后 拿取数据
	function LoginController:C_EnterComplete()
		local msg = login_pb:C_EnterComplete()
		self:SendMsg("C_EnterComplete", msg)
	end

	--删除角色
	function LoginController:C_DeletePlayer(playerId)
		if playerId then
			local msg = login_pb.C_DeletePlayer()
			msg.playerId = playerId
			self:SendMsg("C_DeletePlayer", msg)
		end
	end

-- 关掉登录(完成登录，进入游戏)
function LoginController:CloseLoginPanel()
	self.model:SetLoginState(2)
	AfterLoginRequire()
end
function LoginController:Open( t )
	if self.view == nil then return end
	self.view:OpenPanelByType(t)
end

--注册账号http请求
function LoginController:ReqRegistAccount(userName, passWord, isVisitor)
	if userName and passWord and isVisitor ~= nil then
		local timeStamp = os.time()
		local compStr = StringFormat("{0}{1}{2}{3}", userName, passWord, timeStamp, LoginConst.LoginKey)
		local signMD5 = Util.md5(compStr)
		local registURL = GameConst.RegistURL
		
		networkMgr:HttpRequest( 1, registURL ,{ "userName", userName ,
			"passWord", passWord,
			"time", timeStamp,
			"sign", signMD5
		}, function (state, contentJson)
			
			self:HandleReqRegistAccount(state, contentJson)
		end)

		self.model:SetCurRegistAccount(userName, passWord, isVisitor)
	end
end

--注册账号http请求回调
function LoginController:HandleReqRegistAccount(state, contentJson)
	if state == 1 then
		local data = JSON:decode(contentJson)
		if data.result ~= 0 and LoginConst.RegistServerTips[tostring(data.result)] then
			UIMgr.Win_FloatTip(LoginConst.RegistServerTips[tostring(data.result)])
		end

		if data.result == 0 then
			local model = self.model
			model:SetCurRegistAccountUid(data.userId)
			model:SetAccountByRegist()
			local accountData = model:GetAccountByUid(data.userId)
			if not TableIsEmpty(accountData) then
				local isVisitor = 0
				local userName = accountData.userName
				if accountData.isVisitor then
					isVisitor = 1
					userName = DeviceInfo:GetDeviceUID()
				end
				self:ReqLoginAccount(userName, accountData.passWord, isVisitor)
			end
		end
	end	
end

--登录账号http请求
--isVisitor 为0 表示是正常账号登录，账号名和密码都是正常账号和正常密码
--isVisitor 为1 表示是游客账号登录，账号名为设备唯一id，密码统一为123456
function LoginController:ReqLoginAccount( ... )
	local args = {...}
	print("请求登入用户url ", GameConst.LoginURL)
	print("参数列表==>", "arg1 ", args[1], " |||args2 ", args[2], "args3 ", args[3], "args4 ", args[4], "args5 ", args[5])

	local key = LoginConst.LoginKey
	local reqHttpData = nil
	
	local appid=""
	local userId=""
	local userName=""
	local passWord=""
	local tourist=""
	local token=""
	local time=os.time()
	local sign=""

	if isSDKPlat then
		local data = GetIOSData(args[1]) -- 转成table数据
		if data.code and tonumber(data.code) ~= 0 then UIMgr.Win_FloatTip("登录失败！"..data.code) return end -- 个别平台sdk返回code,非0表示登录失败

		GameConst.GId = data.gid or GameConst.GId
		GameConst.SId = data.subid or GameConst.SId

		appid = data.appid or ""
		userId = data.userId or ""
		userName = data.userName or ""
		passWord = data.passWord or ""
		tourist = data.tourist or ""
		token = data.token or ""
		time = data.time or time

		print("来自sdk数据", GameConst.GId, GameConst.SId)
		sign = Util.md5( StringFormat("{0}{1}{2}{3}{4}{5}{6}{7}", appid, userId, userName, passWord, tourist, token, time, key) )
		reqHttpData = {"appid",appid, "userId",userId, "userName",userName, "passWord",passWord, "tourist",tourist, "token",token, "time",time, "sign", sign}

	else --原原生开发登录
		print("来自本地数据")
		userName = args[1]
		passWord = args[2]
		tourist = args[3]
		sign = Util.md5( StringFormat("{0}{1}{2}{3}{4}{5}{6}{7}", appid, userId, userName, passWord, tourist, token, time, key) )
		reqHttpData = {"appid",appid, "userId",userId, "userName",userName, "passWord",passWord, "tourist",tourist, "token",token, "time",time, "sign", sign}
	end
	local s = StringFormat("appid={0}&userId={1}&userName={2}&passWord={3}&tourist={4}&token={5}&time={6}&key={7}", appid, userId, userName, passWord, tourist, token, time, key)
	print(GameConst.LoginURL.."/?"..s)
	networkMgr:HttpRequest(1, GameConst.LoginURL, reqHttpData, function (state, js) self:HandleReqLoginAccount(state, js) end)
end

--登录账号http请求回调
function LoginController:HandleReqLoginAccount(state, js)
	print(">>>>>>HandleReqLoginAccount>>>>> ", state, js)
	if state == 1 then
		local data = JSON:decode(js)
		local result = data.result
		if result ~= 0 and LoginConst.LoginServerTips[tostring(result)] then
			UIMgr.Win_FloatTip(LoginConst.LoginServerTips[tostring(result)])
		end
		
		if result == 0 then
			local model = self.model
			model:SetAccountByLogin(data)
			model:SetServerList(data.serverList)
			model:UpdateLastServer()
			model:GetAccountList()
			local accountData = model:GetAccountByUid(data.userId)
			if not TableIsEmpty(accountData) then
				model:SetLastAccount(accountData)
				self:OpenVisitorLoginPanel(accountData)
				local curPanel = self:GetCurPanel()
				if curPanel then curPanel:PopUpLoginNameTips() end
				model:SetAutoHttpLogin(true)
			end
			if isSDKPlat then
				SceneLoader.Show(false)
			end
		else
			if result == 1 then --账号为空（该账号相关数据被服务器清除掉了,客户端也做数据清除，服务器清除前，请发邮件通知玩家）
				UnityEngine.PlayerPrefs.DeleteAll()
				self:OpenLoginPanel()	
			end
			
		end
	end
end

--找回密码Http请求
-- 参数：
-- userName: 账号
-- telePhone: 绑定的手机号码
-- time：当前时间戳
-- sign：MD5(userName+telePhone+time)
function LoginController:ReqGetbackPassword(strTelePhone)
	if strTelePhone then
		local timeStamp = os.time()
		local strTelePhone = strTelePhone
		local lastAccountData = self.model:GetLastAccount()
		local userName = ""
		if not TableIsEmpty(lastAccountData) then
			if lastAccountData.isVisitor then
				userName = DeviceInfo:GetDeviceUID()
			else
				userName = lastAccountData.userName
			end
		end
		
		local compStr = StringFormat("{0}{1}{2}", userName, strTelePhone, timeStamp)
		local signMD5 = Util.md5(compStr)
		local getbackPasswordURL = GameConst.GetbackPasswordURL
		
		networkMgr:HttpRequest( 1, getbackPasswordURL, {"userName", userName,
			"telePhone", strTelePhone,
			"time", timeStamp,
			"sign", signMD5
		}, function (state, contentJson)
			
			self:HandleReqGetbackPassword(state, contentJson)
		end)
	end
end

--找回密码Http请求回调
--返回json：result 0：找回成功  1：参数有误  2：电话号码有误  3：账号有误 4：找回密码短信发送有误
function LoginController:HandleReqGetbackPassword(state, contentJson)
	if state == 1 then
		local data = JSON:decode(contentJson)
		
		if LoginConst.GetbackPasswordTips[tostring(data.result)] then
			UIMgr.Win_FloatTip(LoginConst.GetbackPasswordTips[tostring(data.result)])
		end

		if data.result == 0 then
			GlobalDispatcher:DispatchEvent(EventName.GetBackPassword)
		end
	end
end


--游戏绑定(游客账号转为正式账号)http请求
function LoginController:ReqVisitorBind(userName, passWord)
	if userName and passWord then
		local timeStamp = os.time()
		local deviceUID = DeviceInfo:GetDeviceUID()
		local compStr = StringFormat("{0}{1}{2}{3}{4}", deviceUID, userName, passWord, timeStamp, LoginConst.LoginKey)
		local signMD5 = Util.md5(compStr)
		local visitorBindURL = GameConst.VisitorBindURL
		networkMgr:HttpRequest( 1, visitorBindURL, { "userName", deviceUID, 
			"newUserName", userName, "newPassWord", passWord, "time", timeStamp, "sign", signMD5
		}, function(state, contentJson)
			self:HandleReqVisitorBind(state, contentJson)
		end)
	end
end

--游戏绑定(游客账号转为正式账号)http请求回调
function LoginController:HandleReqVisitorBind(state, contentJson)
	if state == 1 then
		local data = JSON:decode(contentJson)
		if LoginConst.VisitorBindTips[tostring(data.result)] then
			UIMgr.Win_FloatTip(LoginConst.VisitorBindTips[tostring(data.result)])
		end

		if data.result == 0 then
			local model = self.model
			model:SetVisitorAccount()
			--local accountData = model:GetAccountByUid(model:GetVisitorUID())
			local accountKey, accountData = model:GetVisitorAccount()
			if not TableIsEmpty(accountData) then
				model:SetLastAccount(accountData)
				self:OpenVisitorLoginPanel(accountData)
				local curPanel = self:GetCurPanel()
				if curPanel then curPanel:PopUpLoginNameTips() end
			end
		end
	end
end

--重置密码http请求
-- 参数：
-- userName: 账号
-- oldPwd: 旧密码
-- newPwd：新密码
-- sign：MD5(userName+oldPwd+newPwd)

-- 返回json：result 0：成功  1: 参数有误 2：账号有误  3：旧密码有误 4：新密码不合法
function LoginController:ReqResetPassword(userName, oldPassword, newPassword)
	if userName and oldPassword and newPassword then
		local compStr = StringFormat("{0}{1}{2}", userName, oldPassword, newPassword)
		local signMD5 = Util.md5(compStr)
		local resetPasswordURL = GameConst.ResetPasswordURL
		networkMgr:HttpRequest( 1, resetPasswordURL, { "userName", userName, "oldPwd", oldPassword, "newPwd", newPassword, "sign", signMD5 
		}, function(state, contentJson)
			self:HandleReqResetPassword(state ,contentJson)
		end
		)
	end
end

--重置密码http请求回调
function LoginController:HandleReqResetPassword(state, contentJson)
	if state == 1 then
		local data = JSON:decode(contentJson)
		if LoginConst.ResetPasswordTips[tostring(data.result)] then
			UIMgr.Win_FloatTip(LoginConst.ResetPasswordTips[tostring(data.result)])
		end

		if data.result == 0 then
			local model = self.model
			model:ResetPassword()
			local newAccountInfo = model:GetCurResetPasswordInfo()
			if not TableIsEmpty(newAccountInfo) then
				model:SetCurRegistAccount(newAccountInfo.userName, newAccountInfo.newPassword , false)
				self:ReqLoginAccount(newAccountInfo.userName, newAccountInfo.newPassword, 0)
			end
			model:CleanCurResetPasswordInfo()
			GlobalDispatcher:DispatchEvent(EventName.ResetPassword, 0)
		end
	end
end

function LoginController:PopUpMaintainTips(str)
	if self.view then
		self.view:PopUpMaintainTips(str)
	end
end

function LoginController:PopUpReStartTips(str)
	if self.view then
		self.view:PopUpReStartTips(str)
	end
end

function LoginController:GetView()
	return self.view
end

function LoginController:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	self.model:RemoveEventListener(self.handler5)
	RenderMgr.Realse("Heart_Render")
	self.kickState = false
	if self.model then
		self.model:Destroy()
	end
	if self.view then
		self.view:Destroy()
	end
	LoginController.inst = nil
end

-- 新版角色创建和选择界面
function LoginController:OpenRoleCreatePanel()
	if self.view == nil then return false end
	self.view:OpenRoleCreatePanel()
	return true
end

function LoginController:OpenRoleSelectPanel()
	if self.view == nil then return false end
	self.view:OpenRoleSelectPanel()
	return true
end

function LoginController:OpenLoginPanel()
	if self.view == nil then return false end
	self.view:OpenLoginPanel()
	return true
end

function LoginController:OpenCreateAccountPanel(isVisitorBind)
	if self.view == nil then return false end
	self.view:OpenCreateAccountPanel(isVisitorBind)
	return true
end

function LoginController:OpenPhoneBindPanel()
	if self.view == nil then return false end
	self.view:OpenPhoneBindPanel()
	return true
end

function LoginController:OpenAccountManagerPanel()
	if self.view == nil then return false end
	self.view:OpenAccountManagerPanel()
	return true
end

function LoginController:OpenVisitorLoginPanel(accountData)
	if self.view == nil then return false end
	self.view:OpenVisitorLoginPanel(accountData)
	return true
end

function LoginController:OpenServerSelectPanel(accountData)
	if self.view == nil then return false end
	self.view:OpenServerSelectPanel(accountData)
	return true
end

function LoginController:OpenResetPasswordPanel(accountData)
	if self.view == nil then return false end
	self.view:OpenResetPasswordPanel(accountData)
	return true
end

function LoginController:LoadRoleCreateSelectScene(callback)
	if self.view == nil then return end
	self.view:LoadRoleCreateSelectScene(callback)
end

function LoginController:OpenLoginNameTips(accountData)
	if self.view == nil then return end
	self.view:Win_FloatTip(accountData)
end

function LoginController:GetCurPanel()
	return self.view.curPanel
end

function LoginController:Close()
	if self.view == nil then return end
	self.view:Close()
end
function LoginController:GetInstance()
	if LoginController.inst == nil then
		LoginController.inst = LoginController.New()
	end
	return LoginController.inst
end