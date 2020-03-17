
_G.CrossFightController = setmetatable({},{__index=IController})
CrossFightController.name = "CrossFightController"

function CrossFightController:Create()
	MsgManager:RegisterCallBack(MsgType.WC_CrossFightInfo,self,self.OnWC_CrossFightInfo);  --Cross Server pull MainPlayer
	MsgManager:RegisterCallBack(MsgType.RC_ConCrossFightResult,self,self.OnRC_ConCrossFightResult); --start fight
	MsgManager:RegisterCallBack(MsgType.RC_EndCrossFight,self,self.OnRC_EndCrossFight); --fight end
	self.loginState = 1;  -- 1 prepared 2 connecting 3 connected

end

function CrossFightController:Destroy()
end

function CrossFightController:Update(dwInterval)
end

function CrossFightController:OnWC_CrossFightInfo(msg)
	GameController:BeforeEnterCross();
	Debug("OnWC_CrossFightInfo: ", Utils.dump(msg))
	local sign = msg.sign
	local conid = msg.congroupid
	LoginController:logout()
	self:Login(conid, sign)
end

function CrossFightController:OnRC_ConCrossFightResult(msg)
	Debug("OnRC_ConCrossFightResult: ", Utils.dump(msg))
	if msg.result == 0 then
		local msg = ReqEnterCrossFightMsg:new();
		MsgManager:Send(msg);
		
		
		UIManager:HideLayerBeyond("interserver","float","loading","highTop","scene","storyBottom");
		MainPlayerController:SetInterServerState(true);
	end
end

--请求登录跨服代理
function CrossFightController:Login(conid, sign)
	--建立连接
    if self.loginState == 2 or ConnManager.gateServer ~= nil then return end;
	local function onInit(net)
        Debug("CrossFightController: gate Conn Init")
        self.loginState = 2;
    end

    local function onConn(net)
        Debug("CrossFightController Gate Server Connected")
        _G.ConnManager.connList[_G.GATEWAY_SERVER] = net
        ConnManager.gateServer = net;
        self.loginState = 3;
		ConnManager.showPopUp = true
		--请求登录
		local msg = ReqConCrossFightMsg:new();
		msg.guid = MainPlayerModel.guid
		msg.sign = sign
		msg.accountID = MainPlayerModel.accountID
		MsgManager:Send(msg);
    end
	local function conn()
		local ip = GetIP(_G.crossTrueAddress);
		if not ip then
			UIConfirm:Open(StrConfig['login48'],backLoginPage,backLoginPage);
			return;
		end
		Debug('CrossFightController do connect to server: ', ip);
		_G.ConnManager:connectServer(ip, onInit, onConn, true)
	end

	--如果是中心服地址,到中心服取真正服务器地址
	if _G.crossGateServerAddres:lead("http") then
		print("请求跨服服务器地址");
		local url = _G.crossGateServerAddres .."?sid=" .. conid;
		print(url);
		_sys:httpGet(url, function(data)
			if not data or data=="" then
				UIConfirm:Open(StrConfig['login44'],backLoginPage,backLoginPage);
				return;
			end
			print("获得跨服服务器地址",data);
			_G.crossTrueAddress = data;
			conn();
		end) 
	else
		_G.crossTrueAddress = crossGateServerAddres;
		conn();
	end
end

function CrossFightController:Logout()
	MainPlayerController:InitSelfState()
	BuffController:ClearCrossBuff() --出跨服清掉跨服的buff
	ConnManager.showPopUp = false
	ConnManager:close() --释放crossGateServer
	self.loginState = 1
end

function CrossFightController:OnRC_EndCrossFight(msg)
	self:Logout()
	Debug("OnRC_EndCrossFight: ", Utils.dump(msg))
	local sign = msg.sign
	self:ResetSession(sign)	
	
	TimerManager:RegisterTimer(function()
		UIManager:RecoverAllLayer();
		MainPlayerController:SetInterServerState(false);
	end,2000,1);
end
--请求恢复与连接服务器的会话
function CrossFightController:ResetSession(sign)
	LoginController:ResetSession(sign)
end