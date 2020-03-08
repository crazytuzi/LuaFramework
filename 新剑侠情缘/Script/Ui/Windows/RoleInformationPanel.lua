
local RoleInformationPanel = Ui:CreateClass("RoleInformationPanel");
RoleInformationPanel.tbRenderPlayerCount =
{
	{0.0, 0},
	{0.4, 10},
	{1.0, 30}
};
RoleInformationPanel.fDrawDivide = 0.3;

RoleInformationPanel.tbOnClick =
{
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnBinding = function (self)
		if Sdk:IsMsdk() then
			Sdk:UpdateTXPhoneBind();

			local szUrlFormat = "http://www.jxqy.org";
			local nArea = Sdk:GetAreaId();
			local nPlatId = Sdk:GetPlatId();
			local nServerId = Sdk:GetServerId();
			local nLoginPlatId = Sdk:GetLoginPlatId();
			local szUrl = string.format(szUrlFormat, me.dwID, nServerId, nPlatId, nArea,nLoginPlatId);
			Sdk:OpenUrl(szUrl);
		elseif Sdk:IsEfunHKTW() then
			Sdk:XGBindPhone();
		elseif version_th then
			Sdk:XGBindAccount();
		elseif version_xm then
			local szUrlFormat = "http://www.jxqy.org";
			local szUid, szSign, szTimestamp, szGameCode = Sdk:XGGetXMExtraInfo();
			local szUrl = string.format(szUrlFormat, szUid, szSign, szTimestamp, szGameCode);
			Sdk:OpenUrl(szUrl);
		elseif version_kor then
			local bIsGuest = Sdk:XGIsGuest();
			if bIsGuest then
				Sdk:XGBindAccount();
			else
				me.CenterMsg("您已关联账号");
			end
		end

		Guide.tbNotifyGuide:ClearNotifyGuide("BindingMailGuideAndroid")
		Guide.tbNotifyGuide:ClearNotifyGuide("BindingMailGuideIOS")
	end,

	BtnGiftExchange = function (self)
		local fnCallBack = function (szInputCode)
			if szInputCode == "" then
				return
			end
			RemoteServer.TakeCodeAward(szInputCode)
        end
		Ui:OpenWindow("InputBox", "请输入礼包领取码", fnCallBack)
	end,

	BtnCustomerService = function (self)
		Sdk:OpenUrl("http://www.jxqy.org");
	end,

	BtnChangeRole = function (self)
		if not Survey:Available() then
			me.CenterMsg("目前没有问卷调查")
			return
		end
		Ui:OpenWindow("SurveyPanel")
	end,

	BtnSignIn = function (self)
		Sdk:Logout(true);
		Ui:ReturnToLogin();
		CloseServerConnect();
	end,

	BtnNameEdit = function (self)
		if me.nLevel < ChangeName.OPEN_LEVEL then
			me.CenterMsg(string.format("%d级开放改名", ChangeName.OPEN_LEVEL))
			return
		end
		Ui:OpenWindow("ChangeName");
	end,

	BtnVIP = function (self)
		Ui:OpenWindow("CommonShop", "Recharge", "Vip")
	end,

	BtnTitle = function (self)
		if me.IsInPrison() then
			me.CenterMsg("天罚期间无法使用此功能");
			return;
		end
		Ui:OpenWindow("HonorLevelPanel");
	end,

	BtnChenghao = function (self)
		if me.IsInPrison() then
			me.CenterMsg("天罚期间无法使用此功能");
			return;
		end
		Ui:OpenWindow("TitleChangePanel");
	end,

	BtnInfo = function (self)
		self:OpenInfoPanel();
	end,

	BtnSetting = function (self)
		self:OpenSettingPanel();
	end,

	BtnOperation = function (self)
		self:OpenOperationPanel(self);
	end,

	CheckSoundEffect = function (self)
		local tbUserSet = Ui:GetPlayerSetting();
		local fVolume = tbUserSet.fSoundEffectVolume > 0.001 and 0.0 or 1.0;
		Ui:SetSoundEffect(fVolume, true);
	end,

	CheckMusic = function(self)
		local tbUserSet = Ui:GetPlayerSetting();
		local fVolume = tbUserSet.fMusicVolume > 0.001 and 0.0 or 1.0;
		Ui:SetMusicVolume(fVolume, true);
	end,

	Easy = function(self)
		local tbUserSet = Ui:GetPlayerSetting();
		tbUserSet.nPreciseSkillOp = 0;
		self:UpdatePreciseCastSetting();
	end,

	Accurate = function(self)
		local tbUserSet = Ui:GetPlayerSetting();
		tbUserSet.nPreciseSkillOp = 1;
		self:UpdatePreciseCastSetting();
	end,

	Unlimited = function(self)
		Operation:SetSelectTargetMode(Operation.eTargetModeUnlimited);
		self:UpdateTargetSetting();
	end,

	NPC = function(self)
		Operation:SetSelectTargetMode(Operation.eTargetModeNpcFirst);
		self:UpdateTargetSetting();
	end,

	Player = function(self)
		Operation:SetSelectTargetMode(Operation.eTargetModePlayerFirst);
		self:UpdateTargetSetting();
	end,

	Follow = function(self)
		Operation:SetJoyStickMovable(true);
		self:UpdateTargetSetting();
	end,

	NotFollow = function(self)
		Operation:SetJoyStickMovable(false);
		self:UpdateTargetSetting();
	end,

	BtnChangePortrait = function (self)
		 Ui:OpenWindow("PortraitSelectPanel");
	end,

	BtnChengjiu = function ()
		Ui:OpenWindow("AchievementPanel");
	end,

	BtnBar = function (self)
		local fValue = self.pPanel:SliderBar_GetValue("BtnBar");
		local tbUserSet = Ui:GetPlayerSetting();
		tbUserSet.nMaxPlayerCount = Lib.Calc:Link(fValue, self.tbRenderPlayerCount);
		self:UpdateRenderPlayerCount(true);
		Ui:SetMaxShowNpcCount(tbUserSet.nMaxPlayerCount, true);
	end,

	BtnBarDraw = function (self)
		self:UpdateDrawLevelValue(true);
	end,

	BtnVideo = function (self)
		local nRet = StartRecordScreen();
		if nRet == 1 then
			Ui:CloseWindow(self.UI_NAME)
		else
			me.CenterMsg("录像开启失败！");
		end
	end,

	Btn01 = function (self)
		Sdk:OpenUrl("http://www.jxqy.org");
	end,

	Btn02 = function (self)
		if version_kor then
			Sdk:OpenUrl("http://www.jxqy.org");
			return;
		end
		Sdk:OpenUrl("http://www.jxqy.org");
	end,

	Btn03 = function (self)
		if version_kor then
			Sdk:OpenUrl("http://www.jxqy.org");
			return;
		end
		Sdk:OpenUrl("http://www.jxqy.org");
	end,

	Btn04 = function (self)
		local nNow = GetTime();
		if self.nLastSendLogTime and self.nLastSendLogTime + 60 > nNow then
			me.CenterMsg(XT("上报失败请稍后再试。"))
			return
		end

		self.nLastSendLogTime = nNow
		local szLogPath = Client:CombineLatestLog()
		FileServer:SendClientLog(szLogPath)
	end,

	BtnQQPrivilege = function (self)
		local nCurPlat = Sdk:GetCurPlatform();
		Ui:OpenWindow("PrivilegePanel", nCurPlat);
	end,

	BtnOpenVIP = function (self)
		Sdk:PayQQVip("VIP");
	end,
	BtnOpenSVIP = function (self)
		Sdk:PayQQVip("SVIP");
	end,
	BtnShowOff = function ()
		Ui:OpenWindow("SharePanelNew");
	end,
	BtnOnlineHosting = function (self)
		self:UpdateOnlineOHSetting()
		OnHook:ChangeOnLineOnHook()
	end,
	BtnLockScreen = function (self)
		if Sdk:IsPCVersion() then
			self.pPanel:Toggle_SetChecked("BtnLockScreen", false);
			me.CenterMsg("请使用手机端登录进行体验")
		else
			Ui:CloseWindow(self.UI_NAME)
			Ui:OpenWindow("LockScreenPanel")
		end
	end,
	BtnFreeFlow = function ()
		Sdk:OpenFreeFlowUrl();
	end,
	BtnPowerSaving = function (self)
		Ui:SwitchSaveBatteryMode();
	end,

	BtnAutomaticBattle = function (self)
		Ui:CloseWindow(self.UI_NAME);
		Ui:OpenWindow("AutoSkillSetting");
	end,
	
	BtnPCSetting = function(self)
		Ui:CloseWindow(self.UI_NAME);
		Ui:OpenWindow("OperationSet");
	end,

	BtnHelp = function (self)
		Ui:OnHelpClicked("ControlHelp");
	end,

	BtnWebsite = function (self)
		Sdk:OpenUrl("http://www.jxqy.org");
	end,

	BtnHabamute = function (self)
		Sdk:OpenUrl("http://www.jxqy.org");
	end,

	BtnCredit = function (self)
		if Sdk:IsPCVersion() then
			me.CenterMsg("请使用手机端登录进行体验");
			return;
		end
		
		local szUrlFormat = "http://www.jxqy.org?game_id=2082&area=%d&platid=%d&partition=%d&charac_no=%d&role=%s";
		local nArea = Sdk:GetAreaId();
		local nPlatId = Sdk:GetPlatId();
		local nServerId = Sdk:GetServerId();
		local szUrl = string.format(szUrlFormat, nArea, nPlatId, nServerId, me.dwID, Lib:UrlEncode(me.szName));
		Sdk:OpenUrl(szUrl);
	end,

	BtnHomepage = function (self)
		Pandora:OpenPlayerSpace(me.dwID)
	end,
}

RoleInformationPanel.tbOnClick.BtnWeiXinPrivilege  = RoleInformationPanel.tbOnClick.BtnQQPrivilege;
RoleInformationPanel.tbOnClick.BtnTouristPrivilege = RoleInformationPanel.tbOnClick.BtnQQPrivilege;
RoleInformationPanel.tbOnClick.BtnSignIn1          = RoleInformationPanel.tbOnClick.BtnSignIn;
RoleInformationPanel.tbOnClick.BtnCustomerService1 = RoleInformationPanel.tbOnClick.BtnCustomerService;
RoleInformationPanel.tbOnClick.BtnBinding1         = RoleInformationPanel.tbOnClick.BtnBinding;
RoleInformationPanel.tbOnClick.BtnChangeRole1      = RoleInformationPanel.tbOnClick.BtnChangeRole;
RoleInformationPanel.tbOnClick.BtnOnlineHosting1   = RoleInformationPanel.tbOnClick.BtnOnlineHosting;
RoleInformationPanel.tbOnClick.BtnPowerSaving1     = RoleInformationPanel.tbOnClick.BtnPowerSaving;
RoleInformationPanel.tbOnClick.BtnGiftExchange1    = RoleInformationPanel.tbOnClick.BtnGiftExchange;

RoleInformationPanel.tbOnDragEnd =
{
	BtnBar = function (self)
		local tbUserSet = Ui:GetPlayerSetting();
		Ui:SetMaxShowNpcCount(tbUserSet.nMaxPlayerCount, true);
	end,

	BtnBarDraw = function (self)
		self:UpdateDrawLevelValue(true);
	end,
}

RoleInformationPanel.tbOnDrag =
{
	BtnBar = function (self)
		local fValue = self.pPanel:SliderBar_GetValue("BtnBar");
		local tbUserSet = Ui:GetPlayerSetting();
		tbUserSet.nMaxPlayerCount = Lib.Calc:Link(fValue, self.tbRenderPlayerCount);
		self:UpdateRenderPlayerCount(true);
	end,

	BtnBarDraw = function (self)
		self:UpdateDrawLevelValue();
	end,
}

local tbPageBtnName =
{
	"BtnInfo",
	"BtnSetting",
	"BtnOperation",
}

function RoleInformationPanel:SelectPageShow(szBtnName)
	for _, szName in ipairs(tbPageBtnName) do
		self.pPanel:Toggle_SetChecked(szName, szBtnName == szName);
	end
end

function RoleInformationPanel:OnOpen(bIsShowBindingGuide)
	local pNpc = me.GetNpc();
	if not pNpc then
		return 0;
	end

	if pNpc.nMapTemplateId == XinShouLogin.tbDef.nFubenMapID then
		return 0;
	end

	self.pPanel:Toggle_SetChecked("BtnInfo", true);
	self.pPanel:Toggle_SetChecked("BtnSetting", false);
	self.pPanel:Toggle_SetChecked("BtnLockScreen", false);
	self:OpenInfoPanel();

	local szNotifyGuideName = "NG_BindingMailGuideAndroid"
--    if IOS then
	   -- self.pPanel:SetActive("AndroidBtns", false);
	   -- self.pPanel:SetActive("IOSBtns", true);
	   -- szNotifyGuideName = "NG_BindingMailGuideIOS"           -- 解开注释的时候记得去RedPointNotify的ChanfeName把NG_BindingMailGuideAndroid换成NG_BindingMailGuideIOS
--    else
		self.pPanel:SetActive("AndroidBtns", true);
		self.pPanel:SetActive("IOSBtns", false);
--    end
	 if bIsShowBindingGuide then
		Ui:SetRedPointNotify(szNotifyGuideName)
	end

	if Sdk:IsMsdk() then
		self.pPanel:SetActive("BtnShowOff", Sdk:IsLoginByQQ() or Sdk:IsLoginByWeixin());
		self.pPanel:SetActive("BtnCustomerService", not Sdk:IsLoginByGuest());
		self.pPanel:SetActive("BtnCustomerService1", not Sdk:IsLoginByGuest());
		self.pPanel:SetActive("BtnBinding", not Sdk:IsLoginByGuest());
		self.pPanel:SetActive("BtnBinding1", not Sdk:IsLoginByGuest());
		self.pPanel:SetActive("BtnFreeFlow", not Sdk:IsLoginByGuest() and Sdk:IsFreeFlowShow());
		self.pPanel:SetActive("BtnGiftExchange1", false);
		self.pPanel:SetActive("BtnGiftExchange", false);
		self.pPanel:SetActive("BtnCredit1", true);
		self.pPanel:SetActive("BtnCredit", true);
		self.pPanel:SetActive("Btn01", IOS and true or false);
		self.pPanel:SetActive("Btn02", IOS and true or false);
	else
		self.pPanel:SetActive("BtnShowOff", Sdk:CanShowOffShare());
		self.pPanel:SetActive("BtnCustomerService", version_vn or (version_kor and ANDROID));
		self.pPanel:SetActive("BtnCustomerService1", version_vn or (version_kor and ANDROID));
		self.pPanel:SetActive("BtnBinding", Sdk:IsEfunHKTW() or version_th or version_kor or version_xm);
		self.pPanel:SetActive("BtnBinding1", Sdk:IsEfunHKTW() or version_th or version_kor or version_xm);
		self.pPanel:SetActive("BtnWebsite", Sdk:IsEfunHKTW());
		self.pPanel:SetActive("BtnHabamute", Sdk:IsEfunHKTW());
		self.pPanel:SetActive("BtnGiftExchange1", not version_vn);
		self.pPanel:SetActive("BtnGiftExchange", not version_vn);
		self.pPanel:SetActive("BtnFreeFlow", false);
		self.pPanel:SetActive("Btn01", false);
		self.pPanel:SetActive("Btn02", version_kor and true or false);
		self.pPanel:SetActive("Btn03", version_kor and true or false);
		self.pPanel:SetActive("BtnCredit1", false);
		self.pPanel:SetActive("BtnCredit", false);
	end

	if Client:IsCloseIOSEntry() then
		self.pPanel:SetActive("BtnShowOff", false);
		self.pPanel:SetActive("BtnBinding", false);
		self.pPanel:SetActive("BtnBinding1", false);
		self.pPanel:SetActive("BtnChangeRole", false);
		self.pPanel:SetActive("BtnChangeRole1", false);
		self.pPanel:SetActive("BtnCustomerService", false);
		self.pPanel:SetActive("BtnCustomerService1", false);
		self.pPanel:SetActive("BtnFreeFlow", false);
		self.pPanel:SetActive("BtnWebsite", false);
		self.pPanel:SetActive("BtnHabamute", false);
		self.pPanel:SetActive("BtnGiftExchange1", false);
		self.pPanel:SetActive("BtnGiftExchange", false);
	end
	
	if Sdk:IsPCVersion() then
		self.pPanel:SetActive("BtnPCSetting", true);
	else
		self.pPanel:SetActive("BtnPCSetting", false);
	end
	self.pPanel:SetActive("BtnHomepage", Pandora:IsEnablePlayerSpace())

	self:UpdateOnlineOHSetting()
	self:UpdateSaveBatteryMode()

	self.pPanel:SetActive("BtnChengjiu", not Client:IsCloseIOSEntry())
end

function RoleInformationPanel:CloseAllSelectPanel()
	self.pPanel:SetActive("RoleInformation", false);
	self.pPanel:SetActive("SetUpPanel", false);
	self.pPanel:SetActive("OperationPanel", false);
end

function RoleInformationPanel:OnClose()
	self:StopTimer();
	Client:SaveUserInfo();
end

function RoleInformationPanel:OpenInfoPanel()
	self:CloseAllSelectPanel();
	self.pPanel:SetActive("RoleInformation", true);
	self:SelectPageShow("BtnInfo");
	self.pPanel:Label_SetText("Number", me.dwID);

	local nLastSendTime = me.GetUserValue(ChuangGong.SAVE_GROUP, ChuangGong.KEY_SEND_TIME)
	local nCDTime = nLastSendTime + ChuangGong.SEND_CD - GetTime()
	local szCDTime = "--"
	if nCDTime > 0 and not ChuangGong.tbWithoutCDVip[me.GetVipLevel()] then
		szCDTime = Lib:TimeDesc(nCDTime)
	end
	self.pPanel:Label_SetText("ChuanGongCD", szCDTime);
	
	self:UpdateVipLevel();
	self:UpdateHonorLevelTitle();
	self:UpdatePlayerTitle();
	self:UpdatePortrait();
	self:UpdateName();
	self:UpdateAchievement();

	local nQQVip = me.GetQQVipInfo();
	self.pPanel:SetActive("QQ", nQQVip ~= Player.QQVIP_NONE and not IOS and not Sdk:IsOuterChannel());
	self.pPanel:SetActive("BtnOpenVIP", nQQVip == Player.QQVIP_NONE and not IOS and Sdk:IsLoginByQQ() and not Sdk:IsOuterChannel());
	self.pPanel:SetActive("BtnOpenSVIP", nQQVip == Player.QQVIP_NONE and not IOS and Sdk:IsLoginByQQ() and not Sdk:IsOuterChannel());
	if nQQVip == Player.QQVIP_VIP then
		self.pPanel:Sprite_SetSprite("QQVipIcon", "QQvip");
		self.pPanel:Label_SetText("TxtQQVipDesc", "您是QQ会员");
	elseif nQQVip == Player.QQVIP_SVIP then
		self.pPanel:Sprite_SetSprite("QQVipIcon", "QQsvip");
		self.pPanel:Label_SetText("TxtQQVipDesc", "您是QQ超级会员");
	end

	local nCurPlat = Sdk:GetCurPlatform();
	local nLaunchPlatform = Sdk:GetValidLaunchPlatform();
	self.pPanel:SetActive("BtnQQPrivilege", nCurPlat == Sdk.ePlatform_QQ);
	self.pPanel:SetActive("BtnWeiXinPrivilege", nCurPlat == Sdk.ePlatform_Weixin);
	self.pPanel:SetActive("BtnTouristPrivilege", nCurPlat == Sdk.ePlatform_Guest);
	if Client:IsCloseIOSEntry() or Sdk:IsOuterChannel() then
		self.pPanel:SetActive("BtnQQPrivilege", false);
		self.pPanel:SetActive("BtnWeiXinPrivilege", false);
		self.pPanel:SetActive("BtnTouristPrivilege", false);
	end

	self.pPanel:SetActive("GameCenter", Sdk.Def.tbPlatformIcon[nLaunchPlatform] and true or false);
	if Sdk.Def.tbPlatformIcon[nLaunchPlatform] then
		local szTips = Sdk.Def.tbPlatformName[nLaunchPlatform] .. "游戏中心启动";
		if nLaunchPlatform == Sdk.ePlatform_Guest then
			szTips = "游客登录";
		end
		self.pPanel:Label_SetText("TxtGameCenter", szTips);
		local nLaunchedPlatform = me.GetLaunchedPlatform();
		self.pPanel:Sprite_SetSprite("GameCenter", Sdk.Def.tbPlatformIcon[nLaunchPlatform]);
	end
end

function RoleInformationPanel:UpdateName()
	local szNameAdd = "";
	local nQQVip = me.GetQQVipInfo();
	if IOS and nQQVip ~= Player.QQVIP_NONE and not Sdk:IsOuterChannel() then
		szNameAdd = nQQVip == Player.QQVIP_VIP and "#966" or "#965";
	end
	self.pPanel:Label_SetText("Name", me.szName .. szNameAdd);
end

function RoleInformationPanel:OpenSettingPanel()
	self:CloseAllSelectPanel();
	self.pPanel:SetActive("SetUpPanel", true);
	self:SelectPageShow("BtnSetting");
	self:UpdateSoundSetting();
	self:UpdateDrawSetting();
	self:UpdateNotifySetting()
end

function RoleInformationPanel:OpenOperationPanel()
	self:CloseAllSelectPanel();
	self.pPanel:SetActive("OperationPanel", true);
	self:SelectPageShow("BtnOperation");
	self:UpdatePreciseCastSetting();
	self:UpdateTargetSetting();
end

function RoleInformationPanel:UpdateOnlineOHSetting()
	self.pPanel:Toggle_SetChecked("BtnOnlineHosting", OnHook:IsOnLineOnHook(me));
end

function RoleInformationPanel:UpdateSaveBatteryMode()
	self.pPanel:Toggle_SetChecked("BtnPowerSaving",Ui.bOnSaveBatteryMode and true or false );
	self.pPanel:Toggle_SetChecked("BtnPowerSaving1",Ui.bOnSaveBatteryMode and true or false );
end

function RoleInformationPanel:UpdateNotifySetting()
	local tbSysNotiy = Calendar:GetSysNotiyTable()
	if not tbSysNotiy or not next(tbSysNotiy) then
		self.pPanel:SetActive("ListTitleBackground", false)
		return
	end
	self.pPanel:SetActive("ListTitleBackground", true)

	local tbMySysNotify = Client:GetUserInfo("MySysNotify", -1)
	local fnClickToggle = function (tbToggle)
		local bChecked = tbToggle.pPanel:Toggle_GetChecked("Main")
		local index = tbToggle.index
		local tbData = tbSysNotiy[index]
		tbMySysNotify[tbData.szKey] = not bChecked
	end

	local fnSetItem = function (itemObj, index)
		local tbData = tbSysNotiy[index]
		local szTimeDesc;
		if tbData.tbTimeGroup then
			for i,nScends in ipairs(tbData.tbTimeGroup) do
				nScends = nScends + tbData.BeforSec
				local nHour = math.floor(nScends / 3600)
				local nMinute = math.floor((nScends - nHour * 3600) / 60)
				if szTimeDesc then
					szTimeDesc = szTimeDesc .. string.format("、%.2d:%.2d", nHour, nMinute)
				else
					szTimeDesc = string.format("%.2d:%.2d", nHour, nMinute)
				end
			end
		end

		itemObj.pPanel:Label_SetText("Name", tbData.szName)
		itemObj.pPanel:Label_SetText("Time", szTimeDesc or "")
		itemObj.pPanel:Toggle_SetChecked("Toggle", not tbMySysNotify[tbData.szKey])
		itemObj.Toggle.pPanel.OnTouchEvent = fnClickToggle;
		itemObj.Toggle.index = index
	end

	self.ScrollViewNotify:Update(tbSysNotiy, fnSetItem)
end

function RoleInformationPanel:UpdateDrawLevelValue(bUpdateLevel)
	local fValue = self.pPanel:SliderBar_GetValue("BtnBarDraw");
	local nDrawLevel = Ui.tbDefDrawLevel.nLow;

	if fValue >= RoleInformationPanel.fDrawDivide * 2 then
		nDrawLevel = Ui.tbDefDrawLevel.nHeight;
	elseif fValue >= RoleInformationPanel.fDrawDivide then
		nDrawLevel = Ui.tbDefDrawLevel.nMiddle;
	else
		nDrawLevel = Ui.tbDefDrawLevel.nLow;
	end

	if bUpdateLevel then
		local tbUserSet = Ui:GetPlayerSetting();
		tbUserSet.nDrawLevel = nDrawLevel;
		Ui:UpdateDrawLevel();
	end
end

function RoleInformationPanel:UpdateDrawSetting()
	local tbUserSet = Ui:GetPlayerSetting();
	if tbUserSet.nDrawLevel == Ui.tbDefDrawLevel.nHeight then
		self.pPanel:SliderBar_SetValue("BtnBarDraw", 1.0);

	elseif tbUserSet.nDrawLevel == Ui.tbDefDrawLevel.nMiddle then
		self.pPanel:SliderBar_SetValue("BtnBarDraw", 0.5);

	elseif tbUserSet.nDrawLevel == Ui.tbDefDrawLevel.nLow then
		self.pPanel:SliderBar_SetValue("BtnBarDraw", 0.0);
	end
	self:UpdateDrawLevelValue();
	self:UpdateRenderPlayerCount();
end

function RoleInformationPanel:UpdateRenderPlayerCount(bSetValue)
	local tbUserSet = Ui:GetPlayerSetting();
	local fValue = Lib.Calc:LinkY(tbUserSet.nMaxPlayerCount, self.tbRenderPlayerCount, true);
	fValue = math.min(1.0, fValue);
	fValue = math.max(0.0, fValue);

	if fValue >= 0.98 then
		self.pPanel:Label_SetText("LbPlayerCount", "全部");
	else
		self.pPanel:Label_SetText("LbPlayerCount", tostring(tbUserSet.nMaxPlayerCount));
	end

	if not bSetValue then
		self.pPanel:SliderBar_SetValue("BtnBar", fValue);
	end
end

function RoleInformationPanel:UpdateSoundSetting()
	local tbUserSet = Ui:GetPlayerSetting();
	if tbUserSet.fSoundEffectVolume <= 0.001 then
		self.pPanel:Toggle_SetChecked("CheckSoundEffect", false);
	else
		self.pPanel:Toggle_SetChecked("CheckSoundEffect", true);
	end

	if tbUserSet.fMusicVolume <= 0.001 then
		self.pPanel:Toggle_SetChecked("CheckMusic", false);
	else
		self.pPanel:Toggle_SetChecked("CheckMusic", true);
	end
end

function RoleInformationPanel:UpdatePortrait()
	local nId = PlayerPortrait:GetBigFaceId(me);
	local szBigIcon, szBigIconAtlas = PlayerPortrait:GetPortraitBigIcon(nId);
	self.pPanel:Sprite_SetSprite("Head", szBigIcon, szBigIconAtlas)
end

function RoleInformationPanel:UpdateBigFace(nBigFaceID)
	local szBigIcon, szBigIconAtlas = PlayerPortrait:GetPortraitBigIcon(nBigFaceID);
	self.pPanel:Sprite_SetSprite("Head", szBigIcon, szBigIconAtlas)
end

function RoleInformationPanel:UpdateHonorLevelTitle()
	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(me.nHonorLevel)
	if ImgPrefix then
		self.pPanel:SetActive("lbRoleTitle", true);
		self.pPanel:Sprite_Animation("lbRoleTitle", ImgPrefix, Atlas);
	else
		self.pPanel:SetActive("lbRoleTitle", false);
	end
end

function RoleInformationPanel:UpdatePlayerTitle()
	PlayerTitle:SetTitleLabel(self, "AnotherName");
end

function RoleInformationPanel:UpdateVipLevel()
	local nLevel = me.GetVipLevel()
	local nKind = 0;
	if nLevel == 0 then
		nKind = 0;
	elseif nLevel <= 8 then
		nKind = 1;
	elseif nLevel <= 14 then
		nKind = 2;
	else
		nKind = 3;
	end

	for i = 1, 3 do
		if nKind == i then
			self.pPanel:SetActive("VIP"..i, true)
			self.pPanel:Label_SetText("VipNum"..i, nLevel)
		else
			self.pPanel:SetActive("VIP"..i, false)
		end
	end
end

function RoleInformationPanel:UpdateAchievement()
	local nAchievementNum = Achievement:GetAchievementNum();
	local nCompleteNum    = Achievement:GetCompleteNum();
	self.pPanel:Label_SetText("AchievementNumber", string.format("%d/%d", nCompleteNum, nAchievementNum));
end

function RoleInformationPanel:StopTimer()
	if self.nTimer then
		Timer:Close(self.nTimer);
		self.nTimer = nil;
	end
end

function RoleInformationPanel:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_CHANGE_VIP_LEVEL,   self.UpdateVipLevel},
		{ UiNotify.emNOTIFY_CHANGE_BIGFACE,    self.UpdateBigFace},
		{ UiNotify.emNOTIFY_CHANGE_PLAYER_NAME, self.UpdateName},
		{ UiNotify.emNOTIFY_UPDATE_TITLE,       self.UpdatePlayerTitle},
		{ UiNotify.emNOTIFY_ONLINE_ONHOOK_STATE,self.UpdateOnlineOHSetting},
		{ UiNotify.emNOTIFY_CHANGE_SAVE_BATTERY_MODE,self.UpdateSaveBatteryMode},
	};

	return tbRegEvent;
end

function RoleInformationPanel:UpdatePreciseCastSetting()
	local tbUserSet = Ui:GetPlayerSetting();
	
	if Sdk:IsPCVersion() then
		self.pPanel:SetActive("Accurate", false);
	else
		self.pPanel:SetActive("Accurate", true);
		self.pPanel:Toggle_SetChecked("Accurate", tbUserSet.nPreciseSkillOp == 1);
		self.pPanel:Toggle_SetChecked("Easy", tbUserSet.nPreciseSkillOp ~= 1);
	end
end

function RoleInformationPanel:UpdateTargetSetting()
	local tbUserSet = Ui:GetPlayerSetting();
	local nSelectMode = Operation:GetSelectTargetMode();

	self.pPanel:Toggle_SetChecked("Unlimited", nSelectMode == Operation.eTargetModeUnlimited);
	self.pPanel:Toggle_SetChecked("NPC", nSelectMode == Operation.eTargetModeNpcFirst);
	self.pPanel:Toggle_SetChecked("Player", nSelectMode == Operation.eTargetModePlayerFirst);

	local bJoyStickMovable = Operation:IsJoyStickMovable();
	self.pPanel:Toggle_SetChecked("Follow", bJoyStickMovable);
	self.pPanel:Toggle_SetChecked("NotFollow", not bJoyStickMovable);
end
