local SdkMgr = luanet.import_type("SdkInterface");
local tbLogin = Ui:CreateClass("Login");

local STATE_UNLOGIN = 0;
local STATE_LOGINED = 1;

local GATEWAY_HANDE_SCUCESS = 0
local GATEWAY_HANDE_FAIL = 1
local GATEWAY_HANDE_BANED = 2

local NOTIFY_REG_OUT_TIME = 1
local NOTIFY_REG_LIMIT_COUNT = 2

--默认的排队速度2秒移动一位
local QUEUE_FORWARD_DEFAULT_SPEED = 3
--默认排队小于50人的时候就用真实位置显示了
local QUEUE_FORWARD_POS_LIMIT = 100

local function SetServrGridSprite(tbUi, szUiName, tbSerInfo)
	local szShowSprite;
	if tbSerInfo.nType == Login.SERVER_TYPE_NEW or tbSerInfo.nType == Login.SERVER_TYPE_RECOMMAND then
		szShowSprite = "ServerTag_01"
	end
	if szShowSprite then
		tbUi.pPanel:SetActive(szUiName, true);
		tbUi.pPanel:Sprite_SetSprite(szUiName, szShowSprite)
	else
		tbUi.pPanel:SetActive(szUiName, false);
	end
end

local function GetServerStateSprite(nStateType)
	if nStateType == Login.SERVER_TYPE_OFFLINE then

		return "Server_gray"
	elseif  nStateType == Login.SERVER_TYPE_NEW or
	 	nStateType == Login.SERVER_TYPE_RECOMMAND or
	 	 nStateType == Login.SERVER_TYPE_HOT then

	 	 return "Server_red"
	elseif nStateType == Login.SERVER_TYPE_BUSY  then

		return "Server_yellow"
	else
		return "Server_green"
	end
end

function tbLogin:OnOpen()
	self.bRequestedServerList = nil;
	local szDesc = self:GetVersionDesc();
	self.pPanel:Label_SetText("VersionNum", string.format("版本号 %s", szDesc))

	local tbServerMap = Client:GetDirFileData("pwd" .. Sdk:GetCurPlatform());
	self.InputAccount:SetText(tbServerMap["name"]);
	self.InputPassword:SetText(tbServerMap["pwd"]);
end

function tbLogin:OnOpenEnd()
	--if not version_xm then -- 新马的在登入后调用
		Ui:OpenWindow("NoticePanel");
	--end

	Login:CheckShowUserProtol()

	self.pPanel:SetActive("ServerSelectionWidget", false);
	self.pPanel:SetActive("Register&Entrance", true);
	self.nState = STATE_UNLOGIN;
	self.bGateHanded = false
	self:Update()
	Log("open login ui");

	-- self.pPanel:PlayUiAnimation("BgLogin", false, true, {});
	Login:PlaySceneSound();
	Ui:ShowNewPackTips();

	if version_vn then
		self.pPanel:SetActive("BtnHelp", false);
	end

	if version_xm and not tbLogin.bFirstOpen then
		tbLogin.bFirstOpen = true;
		Sdk:XGXMTrackEvent("EVENT_FINISH_LOADRING");
	end

	-- 国服iOS审核时屏蔽
	--self.pPanel:SetActive("BtnNotice", false);
end

function tbLogin:RequestServerList()
	self.bRequestedServerList = true; --上报操作需要
	RequestServerList();
	if not self.nRequestedServerListCheckTimer then
		self.nRequestedServerListCheckTimer = Timer:Register(Env.GAME_FPS * 4, function ()
			self.nRequestedServerListCheckTimer = nil;
			SdkMgr.ReportDataSelServer(Sdk:GetCurAppId(), tostring(SERVER_ID), "95002")
		end)
	end
end

function tbLogin:OnCreate()

end

function tbLogin:OnClose()
	-- self.pPanel:StopUiAnimation("BgLogin")
	if self.nConnectServerTimer then
		Timer:Close(self.nConnectServerTimer)
		self.nConnectServerTimer = nil;
	end

	if self.nRequestedServerListCheckTimer then
		Timer:Close(self.nRequestedServerListCheckTimer)
		self.nRequestedServerListCheckTimer = nil;
	end

	self.nSelPageIndex = nil;
	self:CloseQueueForwardTimer();
	self.nLastSyncPos = nil
	self.nLastSyncTime = nil
	self.nCurPos = nil
	Ui:CloseWindow("MessageBox")

	Login.tbAccSerInfo[GetAccountName()] = nil --返回登陆时重新更新账号信息
	--Sdk:TXLauncherStop();
end

local fnGetLastLoginInfo = function ()
	local szAccount =  GetAccountName();
	local tbLastLoginfo = Client:GetUserInfo("Login", -1)
	return tbLastLoginfo[szAccount]
end

function tbLogin:Update()
	if self.nState == STATE_UNLOGIN then
		self.pPanel:SetActive("RegisterWidget", true);
		self.pPanel:SetActive("EntranceWidget", false);

		local bMsdk = Sdk:IsMsdk();
		local bSdk = Sdk:Available();
		local bPCVersion = Sdk:IsPCVersion();
		if not bSdk then
			self.pPanel:SetActive("btnPassword", true);
			-- self.pPanel:SetActive("btnRegister", true);
			local ap = self.pPanel:GetPosition("InputAccount");
			self.pPanel:ChangePosition("btnPassword", ap.x+160+6, ap.y);
			self.pPanel:ChangeScale("btnPassword", 1.5, 1.5, 1.5);
		end
		self.pPanel:SetActive("LoginInputNode", not bSdk);
		--self.pPanel:SetActive("TouristEntrance", bSdk and IOS and bMsdk and not bPCVersion);
		--self.pPanel:SetActive("WeixinQQEntrance", bSdk and ANDROID and bMsdk and not bPCVersion);
		--self.pPanel:SetActive("PCEntrance", bSdk and bMsdk and bPCVersion);
		self.pPanel:SetActive("BtnSingleEnter", bSdk and not bMsdk);

		if bSdk and IOS and bMsdk then
			local bWXInstalled = Sdk:IsPlatformInstalled(Sdk.ePlatform_Weixin);
			self.pPanel:SetActive("BtnWeixin2", bWXInstalled);
		end

		if bSdk and Login:IsAutoLogin() then
			if version_xm then
				-- 新马的sdk会立即打开，导致后面的界面比较奇怪
				Timer:Register(2, function ()
					Sdk:LoginWithLocalInfo();
				end);
			else
				Sdk:LoginWithLocalInfo();
			end

			Ui:OpenWindow("LoadingTips", "自动登入中..", 5, function ()
				Ui:CloseWindow("LoadingTips");
			end);
		end
	else
		self.pPanel:SetActive("RegisterWidget", false)
		self.pPanel:SetActive("EntranceWidget", true)


		if Sdk:XGIsGuest() then
			self.pPanel:SetActive("BtnSwitchAccount", false);
			self.pPanel:SetActive("BtnLinkAccount", true);
		else
			self.pPanel:SetActive("BtnSwitchAccount", true);
			self.pPanel:SetActive("BtnLinkAccount", false);
		end

		----上次登录信息放到本地
		local tbMyLogin = fnGetLastLoginInfo()
		if tbMyLogin then
			--直接选择了对应的区服了
			self:SelectServer(tbMyLogin)
		else
			if self.bGateHanded then
				self:RequestServerList();
			else
				self.bWairtForShowSelServer = true
			end
		end
	end
end

function tbLogin:IsMyServerId(nServerId)
    --return (nServerId and nServerId >= 10025 and nServerId < 10050);
    return nServerId;
end

--在tbSerList 里的索引
function tbLogin:SelectServer(nIdxOrTb)

	local tbSerInfo = nIdxOrTb;
	if type(nIdxOrTb) == "number" then
		tbSerInfo = self.tbSerList[nIdxOrTb]
	end
	if not tbSerInfo then
		Log(debug.traceback())
		return
	end

	if tbSerInfo.nType == Login.SERVER_TYPE_OFFLINE then
		me.CenterMsg("该服正在维护，请选择其他服！")
		return
	end

	self.pPanel:SetActive("Register&Entrance", true);
	self.pPanel:SetActive("ServerSelectionWidget", false);

	self.tbSerInfo = tbSerInfo;

	self:UpdateSelSerInfo();

end

function tbLogin:UpdateSelSerInfo()
	if not self.tbSerInfo then
		--没有选中的状态
		self.pPanel:Label_SetText("lbNewSerName", "请选择区服");
		return
	end

	self.pPanel:Label_SetText("lbNewSerName", self.tbSerInfo.szName);
end

function tbLogin:ShowSelServer()
	self.pPanel:SetActive("Register&Entrance", false);
	self.pPanel:SetActive("ServerSelectionWidget", true);

	self:RequestServerList();
	if self.tbSerList then
		self:UpdateServerList();
	end
	 --根据这时的帐号请求帐号登录区服信息

	local tbAccSerInfo = Login:GetAccSerInfo()
	if not next(tbAccSerInfo)  then
		RequestAccSerInfo();
		Login.tbAccSerInfo[GetAccountName()] = {} --这样避免重复打开服列表重复调RequestAccSerInfo

	end
end


function tbLogin:UpdateServerList()
	if #self.tbSerList == 0 then
		self.ScrollView:Update(0);
		self.ScrollViewBtn:Update(0);
		return
	end

	--如果初次进没有选过服 ，优先选中 推荐，再是新服，再是正常的, 没有可用的则不选中
	if not self.tbSerInfo then
		local nRecmmandIndex = 1;
		local nRecmmandVal = 0;
		for i, v in ipairs(self.tbSerList) do
			local nTempVal = 0;
			if v.nType == Login.SERVER_TYPE_RECOMMAND then
				nTempVal = 3 + MathRandom(10)
			elseif v.nType == Login.SERVER_TYPE_NEW then
				nTempVal = 2
			elseif v.nType == Login.SERVER_TYPE_NORMAL then
				nTempVal = 1
			end
			if nTempVal > nRecmmandVal then
				nRecmmandVal = nTempVal
				nRecmmandIndex = i;
			end
		end
		if nRecmmandVal ~= 0 then
			 self.tbSerInfo = self.tbSerList[nRecmmandIndex];
		end
	else
		--已有的选服信息，区服信息在切大区后也可能是旧的，检查有效性
		local dwIndex = self.tbSerInfo.dwIndex
		self.tbSerInfo = nil;
		for i, v in ipairs(self.tbSerList) do
			if v.dwIndex == dwIndex then
				self.tbSerInfo = v;
				break;
			end
		end
	end

	self:UpdateSelSerInfo();
	if not self.pPanel:IsActive("ServerSelectionWidget") then
		return
	end

	local tbMyAccSerInfo = Login:GetAccSerInfo()

	-- 是按照3个作为一列更新的
	local tbSerGroupBefore = {}
	local tbCanReCommandPageBefore = {} -- 可以推荐的页 , 这里最终要改成倒过来的，要重新计算下
	local nLastCanUsePageBefore = 1;
	local tbHasLoginSer = {}--第一个为我登陆过的服务器

	--先按顺序放到 tbSerGroupBefore 里吧，后面再倒过来，因为互通服的显示是断开的
	local nLastServerId = self.tbSerList[1] and self.tbSerList[1].dwServerId; -- 互通服的服务器id是大于1000的
	local tbPage = {};
	local tbLine = {};
	local fnIsHuTongServer = function (nServerId)
		return (nServerId % 10000) > 1000
	end

	for _, v in ipairs(self.tbSerList) do
		if #tbPage == 5 or ( fnIsHuTongServer(v.dwServerId) and not fnIsHuTongServer(nLastServerId) )  then
			if next(tbLine) then
				table.insert(tbPage, tbLine)
			end
			if next(tbPage) then
				table.insert(tbSerGroupBefore, tbPage)
			end
			tbPage = {};
			tbLine = {};
		end

		table.insert(tbLine, v)
		if #tbLine == 2 then
			table.insert(tbPage, tbLine)
			tbLine = {};
		end
		if tbMyAccSerInfo[v.dwServerId] then
			table.insert(tbHasLoginSer, v)
		end
		if v.nType == Login.SERVER_TYPE_RECOMMAND then
			tbCanReCommandPageBefore[#tbSerGroupBefore + 1] = 1;
		elseif v.nType ~=  Login.SERVER_TYPE_OFFLINE then
			nLastCanUsePageBefore = #tbSerGroupBefore + 1;
		end

		nLastServerId = v.dwServerId
	end
	if next(tbLine) then
		table.insert(tbPage, tbLine)
	end
	if next(tbPage) then
		table.insert(tbSerGroupBefore, tbPage)
	end

	local tbCanReCommandPage = {} -- 可以推荐的页 , 这里最终要改成倒过来的，要重新计算下
	local nLastCanUsePage = #tbPage - nLastCanUsePageBefore + 1 + 1;
	local tbSerGroup = {}
	for k,v in pairs(tbCanReCommandPageBefore) do
		tbCanReCommandPage[ #tbPage - k + 1 + 1 ] = 1;
	end
	for i = #tbSerGroupBefore, 1, -1 do
		table.insert(tbSerGroup, tbSerGroupBefore[i])
	end

	local tbHasLoginSerGroup = {}
	for nGroup = 1,  math.ceil(#tbHasLoginSer / 2) do
		local tb = {
			[1] = tbHasLoginSer[1 + (nGroup - 1) * 2],
			[2] = tbHasLoginSer[2 + (nGroup - 1) * 2],
		}
		if next(tb) then
			table.insert(tbHasLoginSerGroup, tb)
		end
	end

	table.insert(tbSerGroup, 1, tbHasLoginSerGroup)


	self.nSelPageIndex = self.nSelPageIndex or 1;
	-- 如果是没有登陆过的
	if not next(tbMyAccSerInfo) then
		local nCPage, _ = next(tbCanReCommandPage)
		self.nSelPageIndex = nCPage or nLastCanUsePage;
	end

	local fnClickLeftItem = function (itemObj)
		local nIndex = itemObj.nIndex
		self.nSelPageIndex = nIndex;
		self:UpdateServerListScrollView(tbSerGroup[nIndex])
	end

	local nPage = #tbSerGroup
	local fnGetServerIndex = function (tbSerInfo)
		local nServerIndex = string.match(tbSerInfo.szName, ".-(%d+).*")
		if nServerIndex then
			return nServerIndex
		end
		return tbSerInfo.dwIndex
	end

	local fnSetLeftBnt = function (itemObj, nIndex)
		itemObj.nIndex = nIndex
		local tbPage = tbSerGroup[nIndex]

		if nIndex ~=  1 then
			local tbSerInfo1 = tbPage[1][1];
			local tbSerInfoLine2 = tbPage[#tbPage];
			local tbSerInfo2 = tbSerInfoLine2[#tbSerInfoLine2]
			local nFrom = fnGetServerIndex(tbSerInfo1)
			local nTo = fnGetServerIndex(tbSerInfo2)

			local szPrefix = fnIsHuTongServer(tbSerInfo1.dwServerId) and "互通" or "";
			itemObj.pPanel:Label_SetText("ServerName", string.format("%s%d~%d服", szPrefix, nFrom, nTo))
		else
			itemObj.pPanel:Label_SetText("ServerName", "我的服务器")
		end

		itemObj.pPanel:SetActive("NewTagNow", tbCanReCommandPage[nIndex] and true or false)

		itemObj.pPanel:Toggle_SetChecked("Main", self.nSelPageIndex == nIndex)

		itemObj.pPanel.OnTouchEvent = fnClickLeftItem;
	end

	self.ScrollViewBtn:Update(#tbSerGroup, fnSetLeftBnt)

	self:UpdateServerListScrollView(tbSerGroup[self.nSelPageIndex])
end

function tbLogin:UpdateServerListScrollView(tbPage)
	if not tbPage then
		self.ScrollView:Update(0);
		return
	end
	local tbMyAccSerInfo = Login:GetAccSerInfo()
	local fnSetServer = function (itemClass, nIndex)
		itemClass:SetData(self, tbPage[nIndex], nIndex, tbMyAccSerInfo)
	end

	self.ScrollView:Update(tbPage, fnSetServer);
end

tbLogin.tbOnClick = {
	BtnEnter = function (self, tbGameObj)
		if self.nState == STATE_UNLOGIN then
			local szAccount = self.InputAccount:GetText();
			if szAccount == "" then
				Ui:OpenWindow("MessageBox", "请输入账号")
				return
			end

			-- local NetworkSet = Login.ClientSet.Network;
			-- local szToken = Ui.FTDebug.szToken == "" and NetworkSet.Token or Ui.FTDebug.szToken;
			local szPassword = self.InputPassword:GetText()
			local tbAuthInfo = {
				account=szAccount,
				password=szPassword
			}

-----------------------------------------------------------
	local szServerMapName = "pwd" .. Sdk:GetCurPlatform();
	local tbServerMap = Client:GetDirFileData(szServerMapName);
	tbServerMap["name"] = szAccount
	tbServerMap["pwd"] = szPassword
	Client:SaveDirFileData(szServerMapName);
-----------------------------------------------------------

			local szToken = Ui.FTDebug.szToken == "" and Lib:Base64Encode(Lib:EncodeJson(tbAuthInfo)) or Ui.FTDebug.szToken
			Login:ConnectGateWay(szAccount, szToken);
		end
	end;

	lbChangeSer = function (self)
		SdkMgr.SetReportTime();
		if self.nConnectServerTimer then
			Ui:CloseWindow("LoadingTips")
			Timer:Close(self.nConnectServerTimer)
			self.nConnectServerTimer = nil;
		end
		self:ShowSelServer()
	end;

	BtnBack = function (self)
		self.pPanel:SetActive("Register&Entrance", true);
		self.pPanel:SetActive("ServerSelectionWidget", false);
	end;

	btnEntrance = function (self, szCallType)
		self.bGiveUpQueue = false

		if not self.tbSerInfo then
				Ui:OpenWindow("MessageBox", "请选择区服")
				return
			end

		if self.nConnectServerTimer then
			return
		end

		-- 如果免流量的回包还没到达, 则等待3秒, 仍无则直接进游戏
		if not Login:FreeFlowReceived() and szCallType ~= "IgnoreFreeFlow" then
			Ui:OpenWindow("LoadingTips", nil, 3, function ()
				self.tbOnClick.btnEntrance(self, "IgnoreFreeFlow");
				Ui:CloseWindow("LoadingTips");
			end)
			return;
		end

		ConnectServer(self.tbSerInfo.dwIndex)
		if not self.bRequestedServerList then
			SdkMgr.ReportDataSelServer(Sdk:GetCurAppId(), tostring(SERVER_ID), "0")
		end
		Ui:OpenWindow("LoadingTips")
		self.bServerConnectResponse = nil

		--因为serveri id 改了或已经不存在了连上次默认的就不会有ServerConnnectResult返回

		self.nConnectServerTimer = Timer:Register(Env.GAME_FPS * 20, function ()
			if not self.bServerConnectResponse then
				SdkMgr.ReportDataLoadRole("96002", Sdk:GetCurAppId(), tostring(SERVER_ID), "", 2)
				Ui:CloseWindow("LoadingTips")
				self.tbSerInfo = nil;
				self:NeedReturnToLogin()
			end
			self.nConnectServerTimer = nil;
		end)

		local tbLastLoginfo = Client:GetUserInfo("Login", -1)
		tbLastLoginfo[GetAccountName()] = self.tbSerInfo --TODO 新服信息还在这里
		Client:SaveUserInfo()  --将本帐号选择的区服信息保存到本地
	end;


	BtnHelp = function (self)
		--if Sdk:IsMsdk() then
		--	if IOS then
		--		Sdk:OpenUrl("https://kf.qq.com/touch/scene_faq.html?scene_id=kf1386");
		--	else
		--		Sdk:OpenUrl("https://kf.qq.com/touch/scene_faq.html?scene_id=kf1384");
		--	end
		--elseif version_xm then
		--	Sdk:OpenUrl("https://efunjxqy.efunen.com/event/client");
		--elseif version_kor then
		--	Sdk:OpenUrl("http://cafe.naver.com/clansmobile/7");
		--end
		Sdk:OpenUrl("http://www.jxqy.org");
	end;

	BtnNotice = function (self)
		Ui:OpenWindow("NoticePanel", true);
	end;

	BtnSwitchAccount = function (self)
		Sdk:Logout(true);
		self.nState = STATE_UNLOGIN;
		self.bGateHanded = false;
		Login:SetAutoLogin(false);
		self:Update();
		self:CloseQueueForwardTimer();
		self.nLastSyncPos = nil
		self.nLastSyncTime = nil
		self.nCurPos = nil
		Ui:CloseWindow("MessageBox")
	end;

	BtnLinkAccount = function (self)
		Sdk:XGBindAccount();
	end;
};

if version_tx or version_kor or version_vn then
	function tbLogin.tbOnClick:BtnAgreement()
		--if version_tx or version_vn then
			--Ui:OpenWindow("AgreementPanel");
		--else
			--Ui:OpenWindow("AgreementLargePanel");
		--end
	end
end

if version_xm then
	function tbLogin.tbOnClick:BtnService()
		Sdk:OpenUrl(Login.ClientSet.Url.ServiceUrl)
	end
	function tbLogin.tbOnClick:btnPassword()
		Sdk:OpenUrl(Login.ClientSet.Url.RegisterUrl)
	end
end

local tbSdkLoginBtn = {
	["BtnWeixin"] = Sdk.ePlatform_Weixin,
	["BtnWeixin2"] = Sdk.ePlatform_Weixin,
	["BtnQQ"] = Sdk.ePlatform_QQ,
	["BtnQQ2"] = Sdk.ePlatform_QQ,
	["BtnTourist"] = Sdk.ePlatform_Guest,
	["BtnWeixinIos"] = Sdk.ePlatform_Weixin,
	["BtnWeixinAndroid"] = Sdk.ePlatform_Weixin,
	["BtnQQIos"] = Sdk.ePlatform_QQ,
	["BtnQQAndroid"] = Sdk.ePlatform_QQ,
};

local tbForIOSServer = {
	["BtnQQIos"] = true,
	["BtnWeixinIos"] = true,
};

local fnConfirm = function ()
	Sdk:OpenUrlByOutsideWeb("http://www.jxqy.org")
	Sdk:DirectExit()
end

if Sdk:IsMsdk() then
	for szBtnName, nPlatform in pairs(tbSdkLoginBtn) do
		tbLogin.tbOnClick[szBtnName] = function (self)
			if Sdk:IsPCVersion() then
				local szEquipId = Ui.UiManager.GetEquipId()
				if not szEquipId or string.sub(szEquipId, 1, 5) ~= "66666" then
					Ui:OpenWindow("MessageBox", "您当前使用的模拟器不支持《剑侠情缘电脑版》，请在腾讯手游助手中安装。",
						{ {fnConfirm}  },
	 					{ "确定"})
					return;
				end
			end
			if self.nState == STATE_UNLOGIN then
				Sdk:Login(nPlatform, tbForIOSServer[szBtnName]);
			end
		end
	end
else
	tbLogin.tbOnClick.BtnSingleEnter = function (self)
		if self.nState == STATE_UNLOGIN then
			Sdk:Login();
		end
	end
end

function tbLogin:GatewayConnectResult(nResult)
	if nResult ~= 1 then
		Ui:CloseWindow("MessageBox")
		if ANDROID and GetTime() < Lib:GetDate2Time(201605311000) then
			--android不删档测试开服前临时提示
			Ui:OpenWindow("MessageBoxBig", string.format(XT([[      亲爱的少侠，当前服务器尚未开启。本次限量不删档测试开启时间，安卓版本：[FFFE0D]5月31日上午12点[-]；iOS版本：[FFFE0D]6月2日[-]。请到时再尝试登录抢注！如有疑问，欢迎通过官方QQ群或官方微信公众号进行反馈，《剑侠情缘》感谢您的支持！
      官方QQ群：174387680，119195846
      官方微信公众号：jianxqy
]]), szTimeDesc),
			{ {} },
	 		{"确定"}, 0)
	 	elseif IOS and GetTime() < Lib:GetDate2Time(201606021000) then
	 		--IOS不删档测试开服前临时提示
			Ui:OpenWindow("MessageBoxBig", string.format(XT([[      亲爱的少侠，当前服务器尚未开启。服务器开启时间：[FFFE0D]6月2日上午12点[-]。
      如有疑问，欢迎通过官方QQ群或官方微信公众号进行反馈，《剑侠情缘》感谢您的支持！
      官方QQ群：174387680，119195846
      官方微信公众号：jianxqy
]]), szTimeDesc),
			{ {} },
	 		{"确定"}, 0)
		else
			Ui:OpenWindow("MessageBox", "连接服务器失败")
		end
		Login:SetNextLoginTime()
	end
	--self:Update();
end

function tbLogin:GatewayConnectLost()
	Ui:OpenWindow("MessageBox", "与服务器断开连接")
	self.nState = STATE_UNLOGIN;
	Login:SetAutoLogin(false);
	self:Update();
	self.bGateHanded = false

	self:CloseQueueForwardTimer();
	self.nLastSyncPos = nil
	self.nLastSyncTime = nil
	self.nCurPos = nil
end

function tbLogin:ServerConnnectResult(nResult)
	if self.nConnectServerTimer then
		Ui:CloseWindow("LoadingTips")
		Timer:Close(self.nConnectServerTimer)
		self.nConnectServerTimer = nil;
	end

	if nResult ~= 1 then
		self:NeedReturnToLogin()
	end
end

function tbLogin:OnQueueNotify(nPos, nGiveUp)
	if self.nConnectServerTimer then
		Ui:CloseWindow("LoadingTips")
		Timer:Close(self.nConnectServerTimer)
		self.nConnectServerTimer = nil;
	end

	if nPos ~= 0 then
		if not self.bGiveUpQueue then
			self:OnShowQueuePos(nPos)
		else
			self:CloseQueueForwardTimer();
		end
	elseif nGiveUp == 1 then
		self:CloseQueueForwardTimer();
		self.nLastSyncPos = nil
		self.nLastSyncTime = nil
		self.nCurPos = nil
		Ui:CloseWindow("MessageBox")
	end
end

function tbLogin:OnShowQueuePos(nPos)
	self:CloseQueueForwardTimer();
	if nPos <= QUEUE_FORWARD_POS_LIMIT then
		self:ShowQueMsg(nPos);
		self:CloseQueueForwardTimer();
	else
		if not self.nCurPos then
			self:ShowQueMsg(nPos);
		end

		local nForwardInterval = QUEUE_FORWARD_DEFAULT_SPEED

		if self.nLastSyncPos and self.nLastSyncTime then
			local nPosDiff = self.nLastSyncPos - nPos
			local nTimeDiff = GetTime() - self.nLastSyncTime
			if nPosDiff ~= 0 then
				local nInterval = nTimeDiff / nPosDiff
				if self.nCurPos and self.nCurPos > nPos then
					--跑的慢了,速度增加50%
					nInterval = nInterval * 0.5;
				else
					--跑的快了,速度减少50%
					nInterval = nInterval * 1.5;
				end

				if nInterval > 0 then
					nForwardInterval = nInterval
				end
			else
				-- 位置没有变化,速度降低
				nForwardInterval = nForwardInterval * 5;
			end
		end

		--限制最大速度，2个/秒
		nForwardInterval = math.max(nForwardInterval, 0.5);

		self.nQueueTimer = Timer:Register(Env.GAME_FPS * nForwardInterval, function ()
			local nFakePos = self.nCurPos - 1;
			if nFakePos > 0 then
				self:ShowQueMsg(self.nCurPos - 1);
			end
			return true
		end)
	end

	self.nLastSyncPos = nPos
	self.nLastSyncTime = GetTime()
end

function tbLogin:CloseQueueForwardTimer()
	if not self.nQueueTimer then
		return
	end

	Timer:Close(self.nQueueTimer)
	self.nQueueTimer = nil
end

function tbLogin:OnHandShakeEnd(byRet)
	Log("Server OnHandShakeEnd", byRet);
	if byRet == 5 then
		Ui:ShowVersionTips();
	end
	self.bServerConnectResponse = true
	Ui:CloseWindow("LoadingTips")
	SdkMgr.SetReportTime();
end

function tbLogin:ShowQueMsg(nPos)
	self.nCurPos = nPos

	if self.nState == STATE_UNLOGIN then
		return
	end

	local szContent =  string.format("服务器排队中,前面还有 [FFFE0D]%d位[-]", nPos);

	if Ui:WindowVisible("MessageBox") then
		UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_MESSAGE_BOX, szContent);
		return
	end

	local fnNo = function ()
		GiveUpWaitQueue();
		self.bGiveUpQueue = true
		self:CloseQueueForwardTimer();
		self.nLastSyncPos = nil
		self.nLastSyncTime = nil
		self.nCurPos = nil
	end

	Ui:OpenWindow("MessageBox",
	  szContent,
	 { {fnNo}  },
	 { "放弃"});
end

function tbLogin:OnSyncServerListDone()
	if self.nRequestedServerListCheckTimer then
		Timer:Close(self.nRequestedServerListCheckTimer)
		self.nRequestedServerListCheckTimer = nil;
	end

	self.tbSerList   = {}
	local tbRawSerList = GetServerList()
	local nIndex = 0
	for i, v in ipairs(tbRawSerList) do
	    if (self:IsMyServerId(v.dwServerId)) then
		    nIndex = nIndex + 1
		    self.tbSerList[nIndex] = v;
		end
	end

	self:UpdateServerList();

	SdkMgr.ReportDataSelServer(Sdk:GetCurAppId(), tostring(SERVER_ID), "0")

	-- 此处将服务器列表存盘, 用于同玩好友显示
	local szServerMapName = "ServerMap" .. Sdk:GetCurPlatform();
	local tbServerMap = Client:GetDirFileData(szServerMapName);
	for _, tbServerInfo in ipairs(self.tbSerList) do
		tbServerMap[tbServerInfo.dwServerId] = tbServerInfo.szName;
	end
	Client:SaveDirFileData(szServerMapName);
end

function tbLogin:GatewayHandSuccess(nRetCode)
	if nRetCode ~= 0 then
		Ui:CloseWindow("LoadingTips")
		if nRetCode == GATEWAY_HANDE_FAIL then
			Ui:OpenWindow("MessageBox", XT("帐号或密码错误"));
		elseif nRetCode == GATEWAY_HANDE_BANED then
			Ui:OpenWindow("MessageBox", XT("此帐号已被冻结"));
		else
			Ui:OpenWindow("MessageBox", string.format("登入失败, 错误代码:%d", nRetCode));
		end

		Login:SetNextLoginTime();
		return;
	end



	--sdk帐号登录成功后请求平台好友数据
	if Sdk:IsMsdk() then
		Sdk:QueryFriendsInfo()
	end

	self.nState = STATE_LOGINED;
	self:Update();
	self.bGateHanded = true

	if self.bWairtForShowSelServer then
		self:RequestServerList();
		self.bWairtForShowSelServer = nil
	end

	Ui:CloseWindow("MessageBox");
	Ui:CloseWindow("LoadingTips");
	Login:ResetNextLoginTime();
	--Sdk:TXLauncherStart();
end

function tbLogin:OnNeedAccountActive(nRetCode)
	Ui:CloseWindow("LoadingTips")
	if nRetCode == 0 then
		local fnCallBack = function (szInputCode)
			if szInputCode == "" then
				return 1
			end
			RequestAccountActive(szInputCode)
		end
		Ui:OpenWindow("InputBox", "请输入激活码", fnCallBack)
	else
		Ui:OpenWindow("MessageBox", "激活码不正确")
	end
end

function tbLogin:OnNeedAccountReg(nRetCode)
	if nRetCode == NOTIFY_REG_OUT_TIME then
		Ui:OpenWindow("MessageBoxBig", XT(
[[   亲爱的少侠目前限量的测试资格已经发放完毕。您可以前往官方网站进行预约，将有机会获得额外的测试资格！
   如有疑问,欢迎通过官方QQ群或官方微信公众号进行反馈,《剑侠情缘》感谢您的支持！
   官方QQ群：174387680，119195846
   官方微信公众号：jianxqy
   ]]),
			{ {} },
	 		{"确定"}, 0)
	else
		--默认是第二天10点刷新
		local nCurTime = GetTime();
		local tbTime = os.date("*t", nCurTime - 36000 + 86400);
		local szTimeDesc = string.format(XT("%d月%d日上午10点"), tbTime.month, tbTime.day)

		Ui:OpenWindow("MessageBoxBig", string.format(XT([[      亲爱的少侠，今日登录注册的帐号已经达到上限。请于[FFFE0D]%s[-]再尝试登录抢注。
      如有疑问，欢迎通过官方QQ群或官方微信公众号进行反馈，《剑侠情缘》感谢您的支持！
      官方QQ群：174387680，119195846
      官方微信公众号：jianxqy
]]), szTimeDesc),
			{ {} },
	 		{"确定"}, 0)
	end
end

function tbLogin:GetVersionDesc(nVersion)
	nVersion = nVersion or GAME_VERSION;
	local nMainVersion = 1;
	if version_tx then
		nMainVersion = 2;
	end
	local szDesc = string.format("v%d.%d.%d", nMainVersion, math.floor(nVersion / 100000), nVersion % 100000);
	return szDesc
end

function tbLogin:NeedReturnToLogin()
	Ui:OpenWindow("MessageBox", "连接服务器失败",
	{
		{function ()
			Ui:ReturnToLogin();
			CloseServerConnect();
		end},
	},
	{"重新登录"}, nil, nil, true)
end

function tbLogin:OnNeedClientUpdate(nGameVersion)
	local szVersionInfo = self:GetVersionDesc(nGameVersion);
	Ui:OpenWindow("MessageBox", string.format("有新的客户端[%s]更新，请重进游戏更新", szVersionInfo),
	{
		{Sdk.DirectExit, Sdk},
	},
	{"退出游戏"}, nil, nil, true);
end

function tbLogin:OnServerUnavailable(dwServerIndex)
	me.CenterMsg(XT("该服正在维护，请选择其他服！"))
	if self.nConnectServerTimer then
		Ui:CloseWindow("LoadingTips")
		Timer:Close(self.nConnectServerTimer)
		self.nConnectServerTimer = nil;
	end
	self:ShowSelServer()
end

function tbLogin:OnServerLoginFail(nRetCode)
	local tbMsg =
	{
		"维护中",
		"需要排队",
		"服务器人数过多",
		"服务器关闭创建角色功能",
[[      亲爱的少侠，您所选择服务器的注册帐号数已达上限。请尝试在其他服务器进行登录抢注。
      如有疑问，欢迎通过官方QQ群或官方微信公众号进行反馈，《剑侠情缘》感谢您的支持！
      官方QQ群：174387680，119195846
      官方微信公众号：jianxqy]],
	}

	if self.nConnectServerTimer then
		Ui:CloseWindow("LoadingTips")
		Timer:Close(self.nConnectServerTimer)
		self.nConnectServerTimer = nil;
	end

	Ui:OpenWindow("MessageBoxBig", tbMsg[nRetCode] or "登录失败，未知错误！",
			{ {} },
	 		{"确定"}, 0)
end

function tbLogin:OnTouchReturn()
	if self.pPanel:IsActive("ServerSelectionWidget") then
		self.pPanel:SetActive("ServerSelectionWidget", false);
		self.pPanel:SetActive("Register&Entrance", true);
	else
		Sdk:Exit();
	end
end

function tbLogin:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_GATEWAY_CONNECT,		self.GatewayConnectResult },
		{ UiNotify.emNOTIFY_GATEWAY_CONNECT_LOST,	self.GatewayConnectLost },
		{ UiNotify.emNOTIFY_GATEWAY_LOGIN_RSP,		self.GatewayHandSuccess },
		{ UiNotify.emNOTIFY_SERVER_CONNECT,			self.ServerConnnectResult },
		{ UiNotify.emNOTIFY_LOGIN_QUEUE_NOTIFY,		self.OnQueueNotify },
		{ UiNotify.emNOTIFY_LOGIN_HAND_SHAKE_END,		self.OnHandShakeEnd },
		{ UiNotify.emNOTIFY_UPDATE_SERVER_LIST,		self.OnSyncServerListDone },
		{ UiNotify.emNOTIFY_SYNC_ACC_SER_INFO,		self.UpdateServerList },
		{ UiNotify.emNOTIFY_NEED_ACCOUT_ACTIVE,		self.OnNeedAccountActive },
		{ UiNotify.emNOTIFY_NEED_CLIENT_UPDATE,		self.OnNeedClientUpdate },
		{ UiNotify.emNOTIFY_NEED_ACCOUT_REG,			self.OnNeedAccountReg },
		{ UiNotify.emNOTIFY_LOGIN_SERVER_UNAVAILABLE,	self.OnServerUnavailable },
		{ UiNotify.emNOTIFY_LOGIN_SERVER_FAIL,			self.OnServerLoginFail },
	};

	return tbRegEvent;
end


local tbUi = Ui:CreateClass("ServerListGrid");
function tbUi:SetData(tbParent, tbSerGroup, nIndex, tbAccSerInfo)
	self.tbParent = tbParent;
	self.tbSerGroup = tbSerGroup
	self.nIndex = nIndex;

	tbAccSerInfo = tbAccSerInfo or {}

	for i = 1, 2 do
		local tbSerInfo = tbSerGroup[i]

		if not tbSerInfo then
			self.pPanel:SetActive("btnServer" .. i, false)
		else
			self.pPanel:SetActive("btnServer" .. i, true)

			SetServrGridSprite(self, "NewTag" .. i, tbSerInfo)

			self.pPanel:Label_SetText("lbSerName".. i, tbSerInfo.szName)

			if tbAccSerInfo[tbSerInfo.dwServerId] then
				self.pPanel:SetActive("severTag_role" .. i, true)
				if version_tx then
					self.pPanel:Label_SetText("lbRoleLevel" .. i, string.format("%s级", tbAccSerInfo[tbSerInfo.dwServerId]))
				else
					self.pPanel:Label_SetText("lbRoleLevel" .. i, "Lv."..tbAccSerInfo[tbSerInfo.dwServerId])
				end
			else
				self.pPanel:SetActive("severTag_role" .. i, false)
			end

			self.pPanel:Sprite_SetSprite("severTag_State" .. i, GetServerStateSprite(tbSerInfo.nType));
		end
	end
end


tbUi.tbOnClick = {};

tbUi.tbOnClick.btnServer1 = function (self)
	self.tbParent:SelectServer( self.tbSerGroup[1] )
end

tbUi.tbOnClick.btnServer2 = function (self)
	self.tbParent:SelectServer( self.tbSerGroup[2])
end

