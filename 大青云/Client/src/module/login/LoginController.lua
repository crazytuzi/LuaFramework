--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/7/10
-- Time: 10:49
--
_G.LoginController = setmetatable({},{__index = IController});
LoginController.name = "LoginController"
LoginController.isAutoCreate = false
LoginController.preLoaderTimer = nil;

function LoginController:Create()
	MsgManager:RegisterCallBack(MsgType.LC_CONN_RESP,self,self.OnLoginResult)
	MsgManager:RegisterCallBack(MsgType.LC_CREATE_ROLE_RESP,self,self.OnCreateRoleResult);
	MsgManager:RegisterCallBack(MsgType.LC_ROLE_INFO,self,self.OnLoginRoleInfo);   --返回登录角色信息
	MsgManager:RegisterCallBack(MsgType.LC_COLSE_LINK,self,self.OnCloseLink);
	MsgManager:RegisterCallBack(MsgType.WC_MClientLoginUrl,self,self.OnMLoginUrl);
	MsgManager:RegisterCallBack(MsgType.WC_HeartBeat,self,self.OnHeartBeat);
	MsgManager:RegisterCallBack(MsgType.WC_ENTER_GAME,self,self.OnEnterGameRst);
	MsgManager:RegisterCallBack(MsgType.WC_ReEnterGame,self,self.OnReEnterGameRst);
	MsgManager:RegisterCallBack(MsgType.WC_ReEnterScene,self,self.OnReEnterSceneRst);

    --
    self.loginState = 1;  -- 1 prepared 2 connecting 3 connected
	--加载全局配置
	ConfigManager:Load();
	--print common prama
    Debug("_rd.animaBlendTime = ", _rd.animaBlendTime)
    Debug("_rd.lightFactor = ", _rd.lightFactor)
    Debug("_rd.shadowMode = ", _rd.shadowMode, _RenderDevice.ShadowMap1, _RenderDevice.ShadowMap2,
        _RenderDevice.ShadowMap3, _RenderDevice.ShadowMap4)
    Debug("_rd.shadowLength = ", _rd.shadowLength)
	Debug("_sys.cache = ", _sys.cache)
	Debug("_sys.currentFolder = ", _sys.currentFolder)
	Debug("_sys.catchResError = ", _sys.catchResError)
	Debug("_rd.mip = ", _rd.mip)
	Debug("_sys.macAddress = ", _sys.macAddress)
	Debug("_sys.mode = ", _sys.mode)
	local localIp = _hostips('*')
	self.localIp = getAddress(localIp)
	Debug("localIP = ", self.localIp)
end

--进入游戏
function LoginController:ExecuteEnterGame()
	if _sys:isFontExisting("黑体") then
		self:DoExecuteEnterGame();
		return;
	end
	UIFontInst:Show();
	local onFinish = function()
		_sys:installFont("resfile/font/simhei.ttf");
		UIFontInst:Hide();
		self:DoExecuteEnterGame();
	end;
	local onProgress = function(p)
		UIFontInst:ShowProgress(p);
	end
	UILoaderManager:LoadList({"resfile/font/simhei.ttf"},onFinish,onProgress);
end

function LoginController:DoExecuteEnterGame()

	if IsPlatform then
		self:Login();
	else
		UILogin:Show()  -- 默认显示登陆界面
	end
end

--请求登录
function LoginController:Login(accountID)
	--建立连接
    if self.loginState == 2 or ConnManager.gateServer ~= nil then return end;
	local function onInit(net)
        Debug("Login: gate Conn Init")
        self.loginState = 2;
    end

    local function onConn(net)
        Debug("Gate Server Connected")
		LogManager:Send(80);
        _G.ConnManager.connList[_G.GATEWAY_SERVER] = net
        ConnManager.gateServer = net;
        self.loginState = 3;
		LogManager:Send(90);
		Version:Login(accountID);
    end
	local function conn()
		local ip = GetIP(_G.gateServerAddress);
		if not ip then
			UIConfirm:Open(StrConfig['login43'],backLoginPage,backLoginPage);
			return;
		end
		print('do connect to server: ', ip);
		LogManager:Send(70);
		_G.ConnManager:connectServer(ip, onInit, onConn, true)
	end
	-- local allowedDomain={"dqy.g.yx%-g.cn","dqy.ate.cn","dqy.52xiyou.com"}
	--如果是中心服地址,到中心服取真正服务器地址
	if _G.gateServerAddress:lead("http") then
		print("请求服务器地址");
		local url = _G.gateServerAddress .."?sid=";
		if IsPlatform then
			url = url .. _G.loginInfo.skey;
		else
			url = url .. "1";
		end
		print(url);
		_sys:httpGet(url, function(data)
			if not data or data=="" then
				UIConfirm:Open(StrConfig['login44'],backLoginPage,backLoginPage);
				return;
			end
			print("获得服务器地址",data);
			_G.gateServerAddress = data;
			_G.isAllowDomain = false
			--防私服需求 临时屏蔽 @yantielei
			-- for _, domain in pairs(allowedDomain) do
				-- if _G.gateServerAddress:find(domain) then
					_G.isAllowDomain = true
					conn();
					-- break;
				-- end
			-- end
			if _G.isAllowDomain == false then
				UIConfirm:Open(StrConfig['login45'],backLoginPage,backLoginPage);
			end
		end) 
	else
		conn();
	end
end

function LoginController:OnLoginResult(msg)

	-- _G.StepRecord(false);
	-- _G.StepRecord(true);

	MainPlayerModel.guid = msg.guid
	Debug("log:uid",msg.guid,msg.accountID);
	ClickLog:SetCid(msg.guid);
    UILogin:Hide();
	SetServerTime(msg.serverTime)
	--预加载进内存
	UILoadingScene:Show();
	UILoadingScene:Hide();
	if msg.resultCode == -1 then--未创角
		LogManager:Send(100);
		-- UICreateRole.AutoCreateTime = Version:GetAutoCreateTime();
		CLoginScene:Create()
		UICreateRole:Show();
		CLoginScene:EnterScene(nil)
		self:HeartBeat();
		--预加载二包
		LoginController.preLoaderTimer = TimerManager:RegisterTimer(function()
			UILoaderManager:LoadGroup("v_xxsc_dixin01",true);
			UILoaderManager:LoadGroup("pack2",true);
		end,5000,1);
	elseif msg.resultCode == 0 then
		LogManager:Send(100);

		self:HeartBeat();
	else
		Debug("Login Error,resultCode:", msg.resultCode)
		if msg.resultCode == -2 then--时间戳错误
			backLoginPage();
		elseif msg.resultCode == -3 then--签名不匹配
			UIConfirm:Open(StrConfig['login7'],backLoginPage,backLoginPage);
		elseif msg.resultCode == -4 then--账号被封停	
			local day,hour,min = CTimeFormat:sec2formatEx(msg.forbbidenTime);
			local str = string.format(StrConfig['login9'],day,hour,min);
			UIConfirm:Open(str,backLoginPage,backLoginPage);
		elseif msg.resultCode == -5 then--协议不一致
			UIConfirm:Open(StrConfig['login46'],backLoginPage,backLoginPage);
		elseif msg.resultCode == -6 then--MAC封禁
			UIConfirm:Open(StrConfig['login47'],backLoginPage,backLoginPage);
		elseif msg.resultCode == -7 then--连接数据库失败
			UIConfirm:Open(StrConfig['login57'],backLoginPage,backLoginPage);
		else
			UIConfirm:Open(StrConfig['login8'],backLoginPage,backLoginPage);
		end
		print('Login Failed code:'..tostring(msg.resultCode));
	end
end

--主动退出 连接服务器上保持会话
function LoginController:logout()
	MainPlayerController:InitSelfState()
	MainPlayerController:GetPlayer():InitBuffInfo() --进跨服清掉出跨服不清
	ConnManager.showPopUp = false
	ConnManager:close() --释放gateServer
	self.loginState = 1
end

--恢复到连接服务的会话
function LoginController:ResetSession(sign)
	--建立连接
    if self.loginState == 2 or ConnManager.gateServer ~= nil then return end;
	local function onInit(net)
        Debug("ResetSession: gate Conn Init")
        self.loginState = 2;
    end

    local function onConn(net)
        Debug("Gate Server Connected")
		_G.ConnManager.connList[_G.GATEWAY_SERVER] = net
        ConnManager.gateServer = net;
        self.loginState = 3;
		ConnManager.showPopUp = true
		--恢复
		local msg = ReqReEnterGameMsg:new()
		msg.guid = MainPlayerModel.guid
		msg.sign = sign
		msg.accountID = MainPlayerModel.accountID
		MsgManager:Send(msg)

    end
	local function conn()
		local ip = GetIP(_G.gateServerAddress);
		if not ip then
			UIConfirm:Open(StrConfig['login48'],backLoginPage,backLoginPage);
			return;
		end
		print('do connect to server: ', ip);
		_G.ConnManager:connectServer(ip, onInit, onConn, true)
	end
		
	conn();
	
end
--返回玩家登陆信息
function LoginController:OnLoginRoleInfo(msg)
	CLoginScene:Create()
	FTrace(msg,'返回玩家登陆信息')
	if not MainPlayerController:IsEnterGame() then
		UILoginWait:Show();
	end
	CLoginScene:EnterScene(msg)
	UILoginWait:SetRoleInfo(msg);
end

--请求进入游戏
function LoginController:EnterGame()

	TimerManager:UnRegisterTimer(LoginController.preLoaderTimer);

	local msg = ReqEnterGameMsg:new();
	msg.ltype = _G.ismclient and 1 or 0;
	msg.mac = _sys.macAddress
	msg.channel  = Version:GetChannel();
	Debug("_sys.macAddress = ", msg.mac)
	MsgManager:Send(msg);
	
	-- _G.StepRecord(false);
	-- _G.StepRecord(true);
	
end


--请求进入游戏错误返回
function LoginController:OnEnterGameRst(msg)
	if msg.reason == 1 then
		UIConfirm:Open(StrConfig["login49"]);
	elseif msg.reason == 2 then
		UIConfirm:Open(StrConfig["login50"]);
	else
		UIConfirm:Open(StrConfig["login51"]..msg.reason);
	end
	
end

--会话恢复
function LoginController:OnReEnterGameRst(msg)
	Debug("OnReEnterGameRst: ", Utils.dump(msg))
	local result = msg.result
	local lineid = msg.lineid
	if result == 0 then
		--CPlayerMap:SetCurLineID(lineid)
	end


	if msg.result == 0 then
		local msg = ReqReEnterSceneMsg:new();
		MsgManager:Send(msg);
	end
end

function LoginController:OnReEnterSceneRst(msg)
	Debug("OnReEnterSceneRst: ", Utils.dump(msg))
end

--请求创建角色
function LoginController:CreateRole(name,prof,headIcon)
	local msg = ReqCreateRoleMsg:new();
	msg.roleName = name;
	msg.roleProf = prof;
	msg.iconID = headIcon;
	--tod uf
	LogManager:Send(110);
	MsgManager:Send(msg);
end

--创建角色返回
function LoginController:OnCreateRoleResult(msg)
	self.isAutoCreate = false
	if msg.resultCode == -1 then--名字冲突
		UIConfirm:Open(StrConfig['login4']);
		Notifier:sendNotification(NotifyConsts.CreateRoleBtnStateChanged);
		return;
	end
	if msg.resultCode == -2 then--名字不合法
		UIConfirm:Open(StrConfig['login2']);
		Notifier:sendNotification(NotifyConsts.CreateRoleBtnStateChanged);
		return;
	end
	if msg.resultCode == 0 then
		LoginModel.isPlayBornStory = true
		LogManager:Send(120);
		if self.isAutoCreate then
			FPrint('自动创建成功')
			ClickLog:Send(ClickLog.T_AutoCreateSucc)--自动创建成功
		end
		-- UICreateRole:Hide();
		-- CLoginScene:Clear()
		Version:DuoWanUserCreate(msg.roleName);
		for i=1,4 do
			UILoaderManager:RemoveLoadGroup("createprof"..i);
		end
		self:EnterGame();
	else
		Debug('create role Error.code:'..msg.resultCode);
		UIConfirm:Open(StrConfig['login5']);
		Notifier:sendNotification(NotifyConsts.CreateRoleBtnStateChanged);
		return;
	end
end

--服务器断开连接
function LoginController:OnCloseLink(msg)
	print("CLOSE LINK.CODE:",msg.reason);
	if msg.reason == 1 then--异地登录
		UIConfirm:Open(StrConfig['login21'],backLoginPage,backLoginPage);
	elseif msg.reason == 2 then--封停
		local day,hour,min = CTimeFormat:sec2formatEx(msg.param);
		local str = string.format(StrConfig['login22'],day,hour,min);
		UIConfirm:Open(str,backLoginPage,backLoginPage);
	elseif msg.reason == 3 then--GM踢人
		UIConfirm:Open(StrConfig['login23'],backLoginPage,backLoginPage);
	elseif msg.reason == 4 then
		local day,hour,min = CTimeFormat:sec2formatEx(msg.param);
		local str = string.format(StrConfig['login24'],day,hour,min);
		UIConfirm:Open(str);
		-- 5，数据错误，6，场景服务器崩溃;
	elseif msg.reason == 5 then
		UIConfirm:Open(StrConfig['login25'])
	elseif msg.reason == 6 then
		UIConfirm:Open(StrConfig['login26'])
	elseif msg.reason == 7 then--服务器已满
		UIServerFull:Show();
		ConnManager:close();
	elseif msg.reason == 8 then
		UIConfirm:Open(StrConfig['login52'],backLoginPage,backLoginPage);
	elseif msg.reason == 11 then
		if msg.param > 0 then
			local day,hour,min = CTimeFormat:sec2formatEx(msg.param);
			local str = string.format(StrConfig['login56'],day,hour,min);
			UIConfirm:Open(str,backLoginPage,backLoginPage);
		else
			UIConfirm:Open(StrConfig['login55'],backLoginPage,backLoginPage);
		end
	elseif msg.reason==9 or msg.reason==10 or msg.reason==12 or msg.reason==13 or msg.reason==14 then
		UIConfirm:Open(StrConfig['login27'],backLoginPage,backLoginPage);
	end
end

--推荐下载微端
function LoginController:NoticeMClient()
	if Version:IsHideMClient() then return; end
	if _G.ismclient then return; end
	local mclienturl = _sys:getGlobal("mclienturl");
	local mchecksum = _sys:getGlobal("mchecksum");
	print(mclienturl,"mclienturl");
	print(mchecksum,"mchecksum");
	if (not mclienturl) or (not mchecksum) then
		mclienturl = Version:GetMClientURL();
		mchecksum = Version:GetMChecksum();
	end
	print(mclienturl,"mclienturl");
	print(mchecksum,"mchecksum");
	if mclienturl and mchecksum then
		UIMClientNotice:Show();
	end
end

--请求微端登录url
function LoginController:GetMLoginUrl()
	print("请求微端登录url");
	local msg = ReqMClentLoginUrlMsg:new();
	MsgManager:Send(msg);
end

--返回微端登录url
function LoginController:OnMLoginUrl(msg)
	print("返回微端登录url",msg.url);
	_sys:notifyMicroClient(msg.url, false, 'mc_box.png', 'mc_close.png', 'mc_close_h.png', true)
end


--请求心跳
function LoginController:HeartBeat()
	self.beatOpen = true;
end

--返回心跳
function LoginController:OnHeartBeat(msg)
	self.beatState = 0;
end

--是否开启心跳
LoginController.beatOpen = false;
--上次心跳发送时间
LoginController.lastBeatSend = 0;
--心跳状态(0等待发送,1等待返回)
LoginController.beatState = 0;

function LoginController:Update(dwInterval)
	if not self.beatOpen then return; end
	if GetCurTime() - self.lastBeatSend > 3000 then
		if self.beatState == 0 then
			local msg = ReqHeartBeatMsg:new();
			msg.time = GetCurTime();
			MsgManager:Send(msg);
			self.lastBeatSend = GetCurTime();
			self.beatState = 1;
		else
			self.lastBeatSend = self.lastBeatSend + 3000;
			print("Error:心跳超时");
			UIChat:ClientText("<font color = '#ff0000'>" .. "！！！心跳超时！！！" .. "</font>");
			-- if IsPlatform then
				-- ConnManager:close();
				-- self.beatOpen = false;
			-- end
		end
		
	end
	if _G.isDebug then
		self:CheckNetStatus()
	end
end

LoginController.lastCheckTime = 0
local f = nil;
if isDebug then
	f = _File.new()
	f:create("kbps.log",'w')
end
function LoginController:CheckNetStatus()
	if not f then
		return;
	end
	
	if GetCurTime() - self.lastCheckTime > 1000 then
		local tmp = ('%.02fkb'):format((_G.netSended-_G.lastCheckNetSended)*8/1000/1)
		Debug("up stream: ", tmp)
		f:write(tmp .. '\r\n')
		tmp = ('%.02fkb'):format((_G.netRecved-_G.lastCheckNetRecved)*8/1000/1)
		Debug("down stream: ", tmp)
		f:write(tmp .. '\r\n')
		_G.lastCheckNetSended = _G.netSended
		_G.lastCheckNetRecved = _G.netRecved
		self.lastCheckTime = GetCurTime()
	end
end