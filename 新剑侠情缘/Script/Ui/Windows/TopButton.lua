
local TopButton = Ui:CreateClass("TopButton");
Sdk._BRIEFING_TIME = 20170604

TopButton.tBtn2Ui =
{
	["ItemBox"]             = "BtnBag",
	["KinDetailPanel"]      = "BtnFamily",
	["KinJoinPanel"]        = "BtnFamily",
	["SkillPanel"]          = "BtnSkill",
	["SocialPanel"]         = "BtnSocial",
	["CommonShop"]          = "BtnShop",
	["RankBoardPanel"]      = "BtnRanking",
	["HonorLevelPanel"]     = "BtnHonorLevel",
	["Partner"]             = "BtnCompanion",
	["CalendarPanel"]       = "BtnCalendar",
	["WelfareActivity"]     = "BtnActivity",
	["StrongerPanel"]       = "BtnStronger",
	["ExpUpPanel"]          = "BtnExpUp";
	["AuctionPanel"]    	= "BtnAuction",
	["MarketStallPanel"]    = "BtnMarketStall",
	["LoginAwardsPanel"]    = "BtnLoginAward",
	["SurveyPanel"]         = "BtnSurvey",
	["HomeScreenCommunity"] = "BtnGameCommunity",
	["NewInformationPanel"] = "BtnNewMessage",
	--["RegressionPrivilegePanel"] = "BtnReturnPrivilege",
	--["FriendRecallPanel"] = "BtnReunionArena",
	["AthleticsHonor"]      = "BtnHonor",
	["WLDHJoinPanel"]      = "BtnWLDH",
	["BtnHomepage"] 		= "BtnHomepage",
	["AnniversaryPanel"]    = "BtnAnniversary";
	--["WaiYiTryPanel"] = "BtnDress",
	["CeremonyPanel"] = "BtnBriefing",
	["BtnRebate"] = "BtnRebate",
	["BtnTreasure"] = "BtnTreasure",
	--["ItemRecoveryPanel"] = "BtnRecovery",
	["BtnFamilySelection"] = "BtnFamilySelection",

};

TopButton.tbSimpleMode = {
	["BtnBag"]         = 1;
	["BtnCalendar"]    = 1;
	["BtnActivity"]    = 1;
	["BtnAuction"]     = 1;
	["BtnMarketStall"] = 1;
	["BtnNewMessage"]  = 1;
	["BtnFold"] = 1;
	["HideGroup"] = 1;
	["BtnShop"] = 1;
	["BtnHonorLevel"] = 1;
	["BtnRanking"] = 1;
	["BtnSkill"] = 1;
	["BtnCompanion"] = 1;
	["BtnSocial"] = 1;
	["BtnFamily"] = 1;
};

TopButton.tBtnLevelShow =
{
	{
		nLevel = 1,
		"BtnBag",                   --Top
		"BtnFold",                     --Buttom
		"BtnCalendar",                 --Top
		"BtnNewMessage",
		"BtnGameCommunity",
		--"BtnInvitationFriend",         --Top
		"BtnReturnPrivilege",
	},
	{
		nLevel = 4,
		"BtnSkill",                    --Buttom
	},
	{
		nLevel = 5,
		"BtnLoginAward",               --Top
	},
	{
		nLevel = 8,
		"BtnActivity",                 --Top
		"BtnQQMember",                 --Top
	},
	{
		nLevel = 9,
		"BtnCompanion",                --Buttom
	},
	{
		nLevel = Shop.SHOW_LEVEL,
		"BtnShop",                     --Buttom
	},
	{
		nLevel = 11,
		"BtnFamily",                   --Buttom
	},
	{
		nLevel = FriendShip.SHOW_LEVEL, --10
		"BtnSocial",                   --Buttom
	},
	{
		nLevel = Kin.AuctionDef.nAuctionLevelLimit, --11
		"BtnAuction",
	},
	{
		nLevel = 15,
		"BtnStronger",
	},
	{
		nLevel = 18,
		"BtnHonorLevel",               --Buttom
	},
	{
		nLevel = 19,
		"BtnRanking",                  --Buttom
	},
	{
		nLevel = 20,
		"BtnMarketStall",                  --Buttom
	},
	{
		nLevel = 999,
		"BtnTP",
	},
};

TopButton.tbShowPos2Setting = { --第二行的位置参数
	-180, -265,-350,-435,-520,-605,-690,-775,-860
};
--插入按钮名到对应顺序，并且设置可见使用 SetBtnActive
TopButton.tbShowPos2Order = {
	"BtnFB", "BtnGameCommunity","BtnDirectSeeding","BtnQQMember","BtnTP","BtnFeedback",
	"BtnReunionArena","BtnLoginAward","BtnRecharge","BtnHonor","BtnBriefing","BtnQiesport","BtnBeauty","BtnWLDH",
	"BtnEngagement","BtnHomepage","BtnAnniversary",
    --"BtnDress","BtnGoodVoice",
}

TopButton.szTreasureEndTime = "2019/06/24 00:00:00"
TopButton.nTreasureEndTime = Lib:ParseDateTime(TopButton.szTreasureEndTime)

function TopButton:SetBtnActive( szWndName , bActive)
	if TopButton:IsSimpleMode() then
		bActive = self.tbSimpleMode[szWndName] and bActive or false;
	end

	self.pPanel:SetActive(szWndName, bActive)

	if self.nTimerUpdateBtnPos then
		return
	end
	if not self.tbShowPos2OrderIndex then
		self.tbShowPos2OrderIndex = {};
		for i, v in ipairs(self.tbShowPos2Order) do
			self.tbShowPos2OrderIndex[v] = i
		end
	end
	if not self.tbShowPos2OrderIndex[szWndName] then
		return
	end

	self.nTimerUpdateBtnPos = Timer:Register(1, function ( )
		self.nTimerUpdateBtnPos = nil
		self:UpdateButtonLine2Pos()
	end)
end

local tbSimpleModeMap = {
	[House.tbPeach.FAIRYLAND_MAP_TEMPLATE_ID] = true;
};

function TopButton:IsSimpleMode()
	return tbSimpleModeMap[me.nMapTemplateId];
end

function TopButton:UpdateButtonLine2Pos( )
	local tbShowBtns = {};
	for i,v in ipairs(self.tbShowPos2Order) do
		if self.pPanel:IsActive(v) then
			table.insert(tbShowBtns, v)
		end
	end
	table.sort( tbShowBtns, function ( a, b )
		return self.tbShowPos2OrderIndex[a] < self.tbShowPos2OrderIndex[b]
	end )
	for i,v in ipairs(tbShowBtns) do
		local x = self.tbShowPos2Setting[i] or self.tbShowPos2Setting[#self.tbShowPos2Setting]
		self.pPanel:ChangePosition(v, x, -128)
	end
end

TopButton.tbButtonClick =
{
}
local tbTopWnds = {"BtnLeave", "BtnTopFold", "Weather", "House", "House2", "Top", "Anchor", "LevelGuide", "BtnRank", "WeddingDress"}
TopButton.tbBtnGroups = {
	["ShowDownParts"] = {"Anchor"};
};


function TopButton:OnOpen()
	for szUi, szWnd in pairs(self.tBtn2Ui) do
		self.pPanel:Button_SetCheck(szWnd, Ui:WindowVisible(szUi) == 1 and true or false);
		self:SetBtnActive(szWnd,false);
	end

	for _, tbInfo in pairs(self.tBtnLevelShow) do
		for _, szWnd in ipairs(tbInfo) do
			self:SetBtnActive(szWnd,false);
		end
	end

	self:TopButtonLevelShow();
	self:UpdateFriendRedInfo();
	self:CheckHasCanEquipItem();
	self:CheckHasCanUpgradeSkill();
	self:CheckFirstRechargeShow()
	JueXue:UpdateRedPoint()
	local tbSkillBook = Item:GetClass("SkillBook");
    tbSkillBook:UpdateRedPoint(me);
	self.nUpdateAllTimer = Timer:Register(5, function ()
		self.nUpdateAllTimer = nil;
		self:UpdateShowLoginAwardBtn();
		self:UpdateHomeScreenBattleShowInfo();
		self:UpdateShowFriendRecallBtn();
		self:UpdateBeautyPageantBtn();
		self:UpdateKinElectBtn()
		self:UpdateGoodVoiceBtn();
		self:UpdateShiyingeBtn()
		self:UpdateWLDHBtn();
		self:UpdateZNQBtn();
		self:UpdateKinEncounterBtn()
		self:RefreshRegressionBtn()
		self:UpdateDaShiSaiBtn()
	end)

	self:SetBtnActive("HideGroup", false);
	self.nNextBtnFoldTime = 0;

	local tbHonorLevel   = Player.tbHonorLevel;
	tbHonorLevel:UpdateRedPoint();
	local nCurTime = GetTime()
	if Sdk:IsLoginByQQ() and tonumber(os.date("%Y%m%d", nCurTime)) == Sdk._BRIEFING_TIME then
		self:SetBtnActive("BtnQiesport", true);
		self:SetBtnActive("QiesportTimesBg", true)
		if Lib:GetLocalDayTime(nCurTime) < 20 * 3600 then
			self.pPanel:Label_SetText("QiesportTimes", "20:00");
		elseif Lib:GetLocalDayTime(nCurTime) < 22 * 3600 then
			self.pPanel:Label_SetText("QiesportTimes", "直播中");
		else
			self:SetBtnActive("QiesportTimesBg", false)
		end
	else
		self:SetBtnActive("BtnQiesport", false);
	end

	local bPartnerCardOpen = PartnerCard:IsOpen()
	self:SetBtnActive("BtnMenke", bPartnerCardOpen);
	self["BtnMenke"].pPanel:SetActive("GuideTips", PartnerCard:CheckBtnActGuide())
	self:UpdateMenke()

	local nNowTime = GetTime()
	local bShowTreasure = nNowTime < self.nTreasureEndTime and true or false
	self:SetBtnActive("BtnTreasure", bShowTreasure);
end

function TopButton:UpdateMenke()
	local bCanGet = PartnerCard:CheckHavekGetActAward(me)
	self["BtnMenke"].pPanel:SetActive("Redmark", bCanGet)
end

function TopButton:OnOpenEnd()
	Sdk:CheckRedPoint();
	Shop:CheckRedPoint();
	Ui:CheckRedPoint("Activity");
	Ui:CheckRedPoint("Fuben");
	Ui:CheckRedPoint("Partner");
	Ui:CheckRedPoint("EverydayTarget");
	House:CheckMuseRedPoint();
	House:CheckMagicBowlPrayRedPoint()

	self:CheckShowSurvey()
	self:UpdatePartnerTime()
	self:UpdateActivityGuide()

	self:SetBtnActive("BtnNewMessage", not Client:IsCloseIOSEntry())

	self:UpdateTXLiveInfo();

	self:SetBtnActive("House", false);
	self:SetBtnActive("House2", false);

	local bIsInHouse = Map:IsHouseMap(me.nMapTemplateId) and not House.tbPeach:InFairyLand();
	if bIsInHouse and not self.BtnTopFoldState then
		self.tbOnClick.BtnTopFold(self);
	end

	if self.szCurHideBtnGroup then
		self:HideBtnGroups(self.szCurHideBtnGroup)
	else
		self:RestoreSavedState()
	end

	self:UpdateWeatherShowState();
	self:RefreshSpecialButton();
	self:RefreshSpecialButton(50);
	self:UpdateTopButtonLeave();
	self:UpdateRegressionTimer()

	if Client:IsCloseIOSEntry() then
		self:SetBtnActive("BtnMarketStall",false);
		self:SetBtnActive("BtnAuction",false);
	end
end

function TopButton:UpdateTopButtonLeave()
    local bIsInHouse = Map:IsHouseMap(me.nMapTemplateId) and not House.tbPeach:InFairyLand();
    local nMapId = Player:GetServerSyncData("HideTopButtonLeave") or 0;
    if nMapId == me.nMapId then
    	bIsInHouse = false;
    end

    self:SetBtnActive("BtnLeave", bIsInHouse);
end

function TopButton:UpdateTXLiveInfo()
	self:CloseTXLiveTimer();

	local szTXLiveMsg, bCountDown, nLeftTime = Sdk:GetTXLiveInfo();
	if szTXLiveMsg and not Activity.BeautyPageant:IsShowMainButton() then
		self:SetBtnActive("BtnBriefing", true);
		if bCountDown then
			local fnSetTxt = function ()
				if nLeftTime <= 0 then
					self:UpdateTXLiveInfo();
					return false;
				else
					self.pPanel:Label_SetText("BriefingTimes", szTXLiveMsg .. Lib:TimeDesc3(nLeftTime));
				end
				nLeftTime = nLeftTime - 1;
				return true;
			end

			self.nTXLiveCountDownTimer = Timer:Register(Env.GAME_FPS, fnSetTxt);
		else

			self.pPanel:Label_SetText("BriefingTimes", szTXLiveMsg);
		end
	else
		self:SetBtnActive("BtnBriefing", false);
	end
end

function TopButton:CloseTXLiveTimer()
	if self.nTXLiveCountDownTimer then
		Timer:Close(self.nTXLiveCountDownTimer)
		self.nTXLiveCountDownTimer = nil;
	end
end

function TopButton:UpdateSideBar(szUiName)
	if self.tBtn2Ui[szUiName] then
		self.pPanel:Button_SetCheck(self.tBtn2Ui[szUiName], Ui:WindowVisible(szUiName) == 1 and true or false);
	end
end

function TopButton:UpdateFriendRedInfo(dwID)
	if me.nLevel < FriendShip.SHOW_LEVEL then
		return
	end
	local tbAllRequet = FriendShip:GetAllFriendRequestData()
	if #tbAllRequet > 0 then
		 Ui:SetRedPointNotify("Friend_Request")
	else
		 Ui:ClearRedPointNotify("Friend_Request")
	end
end

function TopButton:UpdateCalendarFlag(bVisible)
	self:SetBtnActive("CalendarRedPoint", bVisible);
end

function TopButton:OnButtonClick(szWnd)
	local fnCall = self.tbButtonClick[szWnd]
	if fnCall then
		fnCall(self)
		return
	end
	if szWnd == "BtnHomepage" then
		Pandora:OpenWorldSquare()
		return
	end
	if szWnd == "BtnRebate" then
		Pandora:OpenPlayerRegression()
		return
	end
	if szWnd == "BtnFamilySelection" then
		Pandora:OpenFamilySelect()
		return
	end
	if szWnd == "BtnTreasure" then
		Pandora:OpenLianLianKanKan()
		--Pandora:OpenH5Draw()
		return
	end
	if szWnd == "BtnFamily" then
		if Kin:HasKin() then
			self.tBtn2Ui["KinJoinPanel"] = nil;
			self.tBtn2Ui["KinDetailPanel"] = "BtnFamily";
		else
			self.tBtn2Ui["KinJoinPanel"] = "BtnFamily";
			self.tBtn2Ui["KinDetailPanel"] = nil;
		end
	end

	for szUi, szUiWnd in pairs(self.tBtn2Ui) do
		if szWnd == szUiWnd then
			if self.pPanel:Button_GetCheck(szUiWnd) then
				Ui:OpenWindow(szUi);
				if szUiWnd == "BtnDress" then
					if Client:GetFlag("WaiYiTryGuide") ~= 1 then
						Client:SetFlag("WaiYiTryGuide", 1)
						self.pPanel:SetActive("texiaoDress", false)
					end
				end
			else
				Ui:CloseWindow(szUi);
			end
			break;
		end
	end
end

function TopButton:CheckHasCanEquipItem(nItemId, bNew)
	local tbAllEquips = me.FindItemInBag("Unidentify")
	for i,pItem in ipairs(tbAllEquips) do
		if Item:CheckUsable(pItem, pItem.szClass) == 1 then
			Ui:SetRedPointNotify("ItemBox")
			Ui:SetRedPointNotify("ItemBox_Battle")
			Ui:SetRedPointNotify("ItemBox_HomeScreeFuben")
			return
		end
	end

	local tbEquip = me.GetEquips();
	local tbAllEquips = me.FindItemInPlayer("equip")
    for i, pItem in ipairs(tbAllEquips) do
    	local nEquipingId = tbEquip[pItem.nEquipPos];
        if not nEquipingId then
         	if  pItem.nUseLevel <= me.nLevel then
         		Ui:SetRedPointNotify("ItemBox")
         		Ui:SetRedPointNotify("ItemBox_Battle")
         		Ui:SetRedPointNotify("ItemBox_HomeScreeFuben")
				return;
         	end
        else
        	if nEquipingId ~= pItem.dwId then
        		local pCurEquip = KItem.GetItemObj(nEquipingId);
        		if pItem.nRealLevel > pCurEquip.nRealLevel and pItem.nUseLevel <= me.nLevel  then
        			Ui:SetRedPointNotify("ItemBox")
        			Ui:SetRedPointNotify("ItemBox_Battle")
        			Ui:SetRedPointNotify("ItemBox_HomeScreeFuben")
        			return
        		end
        	end
        end
    end

	Ui:ClearRedPointNotify("ItemBox")
	Ui:ClearRedPointNotify("ItemBox_Battle")
	Ui:ClearRedPointNotify("ItemBox_HomeScreeFuben")
	return

end


TopButton.tbOnClick = TopButton.tbOnClick or {};
for _, szWndName in pairs(TopButton.tBtn2Ui) do
	TopButton.tbOnClick[szWndName] = TopButton.OnButtonClick
end

TopButton.tbOnClick.BtnFold = function (self)
	local nBtnTime = 5;
	local nCurTime = GetFrame();

	if self.nNextBtnFoldTime and self.nNextBtnFoldTime > nCurTime then
		return;
	end

	self.nNextBtnFoldTime = GetFrame() + nBtnTime;
	self:UpdateHomeScreenBattleShowInfo(true);
end

TopButton.tbOnClick.BtnTP = function (self)
	Map:SwitchMap(10);
end

TopButton.tbOnClick.BtnRecharge = function (self)
	Ui:OpenWindow("WelfareActivity", "FirstRecharge")
	WelfareActivity:ClearFirstLogin()
	self.pPanel:SetActive("texiao1", false)
end

TopButton.tbOnClick.BtnTopFold = function (self)
	self.BtnTopFoldState = not self.BtnTopFoldState;
	if self.BtnTopFoldState then
		self.pPanel:PlayUiAnimation("HomeScreenButtonRetract", false, false, {});
	else
		self.pPanel:PlayUiAnimation("HomeScreenButtonStretch", false, false, {});
	end

	self:SetBtnActive("House", false);
	self:SetBtnActive("House2", false);
	self:UpdateWeatherShowState();
	self:RefreshSpecialButton();
	self:RefreshSpecialButton(50);
end

TopButton.tbOnClick.BtnZeroIncome = function (self)
	Ui:OpenWindow("MessageBoxBig", Forbid:GetDesc(Forbid:IsForbidAward()),
			{ {} },
	 		{"确定"}, 3)
end

TopButton.tbOnClick.BtnQQMember = function (self)
	if version_kor then
		Sdk:XGCafeOpenHome();
	else
		Ui:OpenWindow("WelfareActivity", "QQVipPrivilege");
	end
end

TopButton.tbOnClick.BtnInvitationFriend = function (self)
end

TopButton.tbOnClick.BtnRealName = function (self)
	local szUrlFormat = "http://www.jxqy.org/?roleid=%d&serverid=%d&platid=%d&area=%d";
	local nArea = Sdk:GetAreaId();
	local nPlatId = Sdk:GetPlatId();
	local nServerId = Sdk:GetServerId();
	local szUrl = string.format(szUrlFormat, me.dwID, nServerId, nPlatId, nArea);
	Sdk:OpenUrl(szUrl);

	Client:SetFlag("SeenRealNameAuth", true);
	Ui:ClearRedPointNotify("RealNameAuth");
end

TopButton.tbOnClick.BtnZhuangxiuL = function (self)
	TopButton.tbOnClick.BtnZhuangxiu(self);
end

TopButton.tbOnClick.BtnZhuangxiu = function (self)
	House:EnterDecorationMode();
	Guide.tbNotifyGuide:ClearNotifyGuide("ZhuangXiu");
end

TopButton.tbOnClick.BtnZhizuo = function (self)
	Ui:OpenWindow("FurnitureMake");
end

TopButton.tbOnClick.BtnMenke = function (self)
	if not PartnerCard:IsOpen() then
		me.CenterMsg("还没开放门客功能", true)
		return
	end
	if PartnerCard:CheckBtnActGuide() then
		Client:SetFlag("PartnerCardActGuide", 1)
		self["BtnMenke"].pPanel:SetActive("GuideTips", false)
	end
	Ui:OpenWindow("PartnerCardActivityPanel");
end

TopButton.tbOnClick.BtnJiayuan = function (self)
	Ui:OpenWindow("HouseManagerPanel");
end

TopButton.tbOnClick.BtnCamera = function (self)
	Ui:OpenWindowAtPos("HouseCameraPanel", 317, 139, true);
end

TopButton.tbOnClick.BtnBriefing = function (self)
	Ui:OpenWindow("CeremonyPanel");
end

TopButton.tbOnClick.BtnJiayuan2 = function (self)
	self.tbOnClick.BtnJiayuan(self);
end

TopButton.tbOnClick.BtnCamera2 = function (self)
	self.tbOnClick.BtnCamera(self);
end

TopButton.tbOnClick.BtnLeave = function (self)
	RemoteServer.GoBackFromHome();
end

TopButton.tbOnClick.BtnQiesport = function (self)
	local szUrl = "http://www.jxqy.org/?_wv=1&_wwv=4";
	Sdk:OpenUrl(szUrl);
end

TopButton.tbOnClick.BtnBeauty = function (self)
	--Activity.BeautyPageant:OpenMainPage()
end

TopButton.tbOnClick.BtnGoodVoice = function (self)
	--Pandora:OpenGoodVoiceMain()
end

TopButton.tbOnClick.BtnShiyinge = function (self)
	--Pandora:OpenGoodVoiceMain()
end

TopButton.tbOnClick.BtnEngagement = function(self)
	Ui:OpenWindow("KinEncounterJoinPanel")
end

TopButton.tbOnClick.BtnCamera3 = function(self)
	if Operation:CheckAdjustView() then
		Operation:StartScreenShotState()
	elseif Map:IsHouseMap(me.nMapTemplateId) then
		self.tbOnClick.BtnCamera(self);
	else
		local szUiScreeShot = "HouseSharePanel"
		if Ui:WindowVisible(szUiScreeShot) ~= 1 then
	        Ui:OpenWindow(szUiScreeShot, true)
	    end
	end
end

TopButton.tbOnClick.BtnDashisai = function(self)
	Ui:OpenWindow("KinChaosFightPanel")
end

TopButton.tbOnClick.TakeOff = function(self)
	RemoteServer.OnWeddingRequest("ChangeDressState", false)
end

if Sdk:IsEfunHKTW() then
	TopButton.tbOnClick.BtnFB = function (self)
		Ui:OpenWindow("SocialPanel", "FriendsRankPanel");
	end

	TopButton.tbOnClick.BtnDirectSeeding = function (self)
		Sdk:XGStartBroadcast();
	end
end

if version_xm then
end

function TopButton:OnSyncItem(nItemId, bNew)
	self.CheckHasCanEquipItem(nItemId, bNew);

	local tbHonorLevel   = Player.tbHonorLevel;
	tbHonorLevel:UpdateRedPoint();

	local tbSkillBook = Item:GetClass("SkillBook");
    tbSkillBook:UpdateRedPoint(me);

    JueXue:UpdateRedPoint()
end

function TopButton:FinishPersonalFuben()
	local tbHonorLevel   = Player.tbHonorLevel;
	tbHonorLevel:UpdateRedPoint();
end

function TopButton:UpdateHomeScreenBattleShowInfo(bExchange)
	self:SetBtnActive("BattleHide", me.nFightMode ~= 1);

	if not Ui:WindowVisible(self.UI_NAME) then
		return;
	end

	local bFight = me.nFightMode == 1;
	if bExchange then
		bFight = self.bHideState;
	end

	self.bHideState = not bFight;
	local bShow = self.pPanel:IsActive("HideGroup");
	if (bFight and bShow) or (not bFight and not bShow) then
		if not bFight then
			self:SetBtnActive("HideGroup", true);
		end
		self.pPanel:PlayUiAnimation(bFight and "HomeScreenTopButtonDelete" or "HomeScreenTopButtonOpen", false, false, {});
	end

	if bFight and not Ui:WindowVisible("HomeScreenBattle") then
		Ui:OpenWindow("HomeScreenBattle");
	end

	if not bFight and Ui:WindowVisible("HomeScreenBattle") then
		Ui:CloseWindow("HomeScreenBattle");
	end

	local nScale = Ui:WindowVisible("HomeScreenBattle") and 0.8 or 0.01;
	self.pPanel:ChangeScale("BtnFoldRedmark", nScale, nScale, nScale);
end

function TopButton:OnCheckOut(dwOwnerId)
	local nHouseMapId = House:GetHouseMap(dwOwnerId);
	if not nHouseMapId or nHouseMapId ~= me.nMapId then
		return;
	end
	self:SetBtnActive("House2", false);
	self:UpdateWeatherShowState();
end

function TopButton:UpdateWeatherShowState()
	local bIsInHouse = Map:IsHouseMap(me.nMapTemplateId);
	self:SetBtnActive("Weather", self.BtnTopFoldState and bIsInHouse);
	self:UpdateWeatherInfo();
end

function TopButton:OnCheckIn(dwOwnerId)
	local nHouseMapId = House:GetHouseMap(dwOwnerId);
	if not nHouseMapId or nHouseMapId ~= me.nMapId then
		return;
	end
	self:SetBtnActive("House2", true);
	self:UpdateWeatherShowState();
end

function TopButton:RefreshSpecialButton(nWaiteTime)
	Timer:Register(math.max(10, nWaiteTime or 0), function () self:RefreshHouseButton(); end);
end

function TopButton:RefreshHouseButton()
	local pos = self.pPanel:GetPosition("Top");
	if pos.y < 179 then
		self:SetBtnActive("House", false);
		self:SetBtnActive("House2", false);
		self.BtnTopFoldState = false;
		self:UpdateWeatherShowState();
		return;
	end

	self.BtnTopFoldState = true;
	local bIsInOwnHouse = House:IsInOwnHouse(me);
	local bIsInLivingRoom = House:IsInLivingRoom(me);
	self:SetBtnActive("House", bIsInOwnHouse);
	self:SetBtnActive("House2", bIsInLivingRoom);
	self:UpdateWeatherShowState();

	local bHasDecorationAccess = false;
	if bIsInLivingRoom then
		bHasDecorationAccess = House:HasDecorationAccess(me);
	end
	self:SetBtnActive("BtnZhuangxiuL", bHasDecorationAccess);
	self.pPanel:ChangePosition("BtnJiayuan2", bHasDecorationAccess and -350 or -265, -47, 0);
	--self:UpdatePhotoState();

	self:CheckHouseUpradeTimer();
end

function TopButton:HideTopWnds()
	for _, szWnd in ipairs(tbTopWnds) do
		self:SetBtnActive(szWnd, false)
	end
end

function TopButton:SaveCurState()
	self.tbCurState = {}
	self.nCurHideBtnGroupMapTId = me.nMapTemplateId
	for _, szWnd in ipairs(tbTopWnds) do
		self.tbCurState[szWnd] = self.pPanel:IsActive(szWnd)
	end
end

function TopButton:RestoreSavedState()
	self.nCurHideBtnGroupMapTId = nil;
	self.szCurHideBtnGroup = nil;
	for szWnd, bActive in pairs(self.tbCurState or {}) do
		self:SetBtnActive(szWnd, bActive)
	end
	self:UpdateTopButtonLeave()
end

function TopButton:EnableWeddingDressMode(bEnable)
	if bEnable then
		self:SaveCurState()
		self:HideTopWnds()
		self:SetBtnActive("WeddingDress", true)
	else
		self:RestoreSavedState()
	end
end

function TopButton:HideBtnGroups( szGroup )
	local tbSkipBtnNames = {};
	for i,v in ipairs(self.tbBtnGroups[szGroup]) do
		tbSkipBtnNames[v] = 1;
	end
	for _, szWnd in ipairs(tbTopWnds) do
		if not tbSkipBtnNames[szWnd] then
			self:SetBtnActive(szWnd, false)
		end
	end
end

function TopButton:SwitchHideBtnGroup( szGroup )
	if szGroup == self.szCurHideBtnGroup then
		return
	end
	self.szCurHideBtnGroup = szGroup
	if szGroup then
		self:SaveCurState()
		self:HideBtnGroups(szGroup)
	else
		self:RestoreSavedState()
	end
end

function TopButton:CheckHouseUpradeTimer()
	self:CloseHouseUpgradeTimer();

	local bIsUpgrating = false;
	local bIsInOwnHouse = House:IsInOwnHouse(me);
	if bIsInOwnHouse and House.nStartLeveupTime then
		bIsUpgrating = true;
	end
	self:SetBtnActive("LevelUp", bIsUpgrating);

	if not bIsUpgrating then
		return;
	end

	local tbSetting = House.tbHouseSetting[House.nHouseLevel];
	local nLeftTime = House.nStartLeveupTime + tbSetting.nLevelupTime - GetTime();
	local fnRefreshUi = function ()
		if nLeftTime <= 0 then
			self.pPanel:Label_SetText("LevelUpTxt", "升级完成");
			return false;
		end
		self.pPanel:Label_SetText("LevelUpTxt", Lib:TimeDesc3(nLeftTime));
		return true;
	end

	local bRet = fnRefreshUi();
	if not bRet then
		return;
	end

	self.nHouseUpgradeTimerId = Timer:Register(Env.GAME_FPS, function ()
		nLeftTime = nLeftTime - 1;
		local bRet = fnRefreshUi();
		if not bRet then
			self.nHouseUpgradeTimerId = nil;
			return false;
		end

		return true;
	end)
end

function TopButton:CloseHouseUpgradeTimer()
	if self.nHouseUpgradeTimerId then
		Timer:Close(self.nHouseUpgradeTimerId);
		self.nHouseUpgradeTimerId = nil;
	end
end

function TopButton:OnSyncHouseInfo()
	self:RefreshHouseButton();
end

function TopButton:OnSyncData(szType)
	if szType == "ChangeSkillPoint" or szType == "SkillPanelUpdate" then
		self:CheckHasCanUpgradeSkill();
	elseif szType == "UpdateTopButton" then
		self:TopButtonLevelShow()
	elseif szType == "HideTopButtonLeave" then
		self:UpdateTopButtonLeave();
	end
end

function TopButton:OnWeddingDressChange(bOn)
	if self.szCurHideBtnGroup then --等婚服那边处理了再调整todo
		return
	end
	self:EnableWeddingDressMode(bOn)
end

function TopButton:UpdateWeatherInfo()
	local nMapTemplateId = me.nMapTemplateId;
	local bIsNight = WeatherMgr:CheckIsNight(nMapTemplateId);
	local _, szTimeInfo = WeatherMgr:GetTimeNow(nMapTemplateId);

	local szExtInfo = "晴";
	local szShowSprite = bIsNight and "WeatherNight" or "WeatherDay";
	if WeatherMgr.szWeatherType then
		if WeatherMgr.szWeatherType == "Rain" then
			szShowSprite = "WeatherRain";
		end

		szExtInfo = WeatherMgr.tbAllWeatherType[WeatherMgr.szWeatherType] or szExtInfo;
	end

	self.pPanel:Button_SetSprite("Weather", szShowSprite);
	self.pPanel:Label_SetText("WeatherTime", string.format("%s时（%s）", szTimeInfo, szExtInfo));
end

function TopButton:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_WND_OPENED,		 			self.UpdateSideBar},
		{ UiNotify.emNOTIFY_WND_CLOSED, 				self.UpdateSideBar},
		{ UiNotify.emNoTIFY_SYNC_FRIEND_DATA, 			self.UpdateFriendRedInfo },
		{ UiNotify.emNOTIFY_CHANGE_PLAYER_LEVEL,		self.TopButtonLevelShow },
		{ UiNotify.emNOTIFY_SYNC_ITEM,					self.OnSyncItem},
		{ UiNotify.emNOTIFY_DEL_ITEM,					self.CheckHasCanEquipItem},
		{ UiNotify.emNOTIFY_CHANGE_MONEY,				self.CheckHasCanUpgradeSkill},
		{ UiNotify.emNOTIFY_SKILL_LEVELUP,				self.CheckHasCanUpgradeSkill},
		{ UiNotify.emNOTIFY_FINISH_PERSONALFUBEN,		self.FinishPersonalFuben},
		{ UiNotify.emNOTIFY_RECHARGE_PANEL,				self.CheckFirstRechargeShow},
		{ UiNotify.emNOTIFY_UPDATE_SURVEY_STATE,		self.CheckShowSurvey},
		{ UiNotify.emNOTIFY_FORBID_STATE_CHANGE,		self.OnForbidStateChange},
		{ UiNotify.emNOTIFY_PANDORA_REFRESH_ICON,		self.OnRefreshPandoraIcon},
		{ UiNotify.emNOTIFY_PRECISE_CAST,				self.OnPreciseCastSkill},
		{ UiNotify.emNOTIFY_XGSDK_CALLBACK,				self.TopButtonLevelShow},
		{ UiNotify.emNOTIFY_UPDATE_RECALL_BUTTON,		self.UpdateShowFriendRecallBtn },
		{ UiNotify.emNOTIFY_ROOMER_CHECKOUT,			self.OnCheckOut },
		{ UiNotify.emNOTIFY_SYNC_DATA,           		self.OnSyncData},
		{ UiNotify.emNOTIFY_ROOMER_CHECKIN,				self.OnCheckIn },
		{ UiNotify.emNOTIFY_HOUSE_LEVELUP,				self.CheckHouseUpradeTimer },
		{ UiNotify.emNOTIFY_SYNC_HOUSE_INFO,			self.OnSyncHouseInfo },
		{ UiNotify.emNOTIFY_SYNC_WEATHER_CHANGE,		self.UpdateWeatherInfo },
		{ UiNotify.emNOTIFY_WEDDING_DRESS_CHANGE,		self.OnWeddingDressChange},
		{ UiNotify.emNOTIFY_PARTNER_CARD_ACT_AWARD,		self.UpdateMenke, self},
		{ UiNotify.emNOTIFY_SWITCH_TOP_BUTTON_UP,		self.SwitchHideBtnGroup, self},
		{ UiNotify.emNOTIFY_MAP_ENTER,		self.OnEnterNewMap, self},
		{ UiNotify.emNoTIFY_COOK_FISH_TRAP,				self.OnCookFishTrap, self},
		{ UiNotify.emNOTIFY_SYNC_SWITCH_PLACE, 		    self.OnSwitchHousePlace, self };
	}
	return tbRegEvent;
end

function TopButton:OnCookFishTrap(bIn)
	if not Furniture.Cook:IsOpened(me) then
		return
	end
	if bIn then
		Ui:OpenWindow("CookFishingTips")
	else
		Ui:CloseWindow("CookFishingTips")
	end
end

function TopButton:OnEnterNewMap( nMapTemplateId )
	if self.nCurHideBtnGroupMapTId and nMapTemplateId ~= self.nCurHideBtnGroupMapTId then
		self:RestoreSavedState()
	end
end

function TopButton:TopButtonLevelShow()
	self:CheckHasCanUpgradeSkill();
	for _, LevelUi in pairs(self.tBtnLevelShow) do
		if me.nLevel >= LevelUi.nLevel then
			for nId = 1, #LevelUi do
				if LevelUi[nId] ~= "BtnStronger" or not Forbid:IsForbidAward()  then
					self:SetBtnActive(LevelUi[nId],true);
				end
			end
		end
	end
	self:CheckFirstRechargeShow()
	self:UpdateShowLoginAwardBtn()
	self:UpdateHomeScreenBattleShowInfo();
	self:CheckLevelUpGuide()
	Recharge:CheckCanBuyVipAward();

	if (Sdk:IsMsdk() and not Sdk:IsLoginByGuest()) or version_xm or version_kor then
		self:SetBtnActive("BtnGameCommunity", true);
	else
		self:SetBtnActive("BtnGameCommunity", false);
	end

	self:SetBtnActive("BtnFB", Sdk:IsEfunHKTW() and me.nLevel >= FriendShip.SHOW_LEVEL);
	self:SetBtnActive("BtnQQMember", Sdk:ShowQQVipPrivilege() or (version_kor and ANDROID));

	if Client:IsCloseIOSEntry() then
		--IOS版本关闭入口
		self:SetBtnActive("BtnSurvey",false);
		self:SetBtnActive("BtnGameCommunity", false);
		self:SetBtnActive("BtnQQMember", false);
		--self:SetBtnActive("BtnInvitationFriend", false);
		self:SetBtnActive("BtnNewMessage", false);
		self:SetBtnActive("BtnFB", false);
		--self:SetBtnActive("BtnInvitationFriend_xm", false);
	end

	if Sdk:IsLoginByGuest() or Sdk:IsHideTXInvitation() then
		--self:SetBtnActive("BtnInvitationFriend", false);
	end
	--与实名认证互斥
	self:SetBtnActive("BtnReturnPrivilege", RegressionPrivilege:IsShowButton() and not Sdk:ShowHomeScreenRealAuth())
	self:RefreshFobidState(Forbid:IsForbidAward())

	self:SetBtnActive("BtnDirectSeeding", Sdk:XGIsBroadcastShow());

	self:SetBtnActive("BtnHomepage", Pandora:IsEnablePlayerSpace())

	self:SetBtnActive("BtnRealName", Sdk:ShowHomeScreenRealAuth());
	MarketStall:UiCheckMarketStallTime(self);

	--self:UpdateBeautyPageantBtn();
	self:UpdateKinElectBtn()
	--self:UpdateGoodVoiceBtn();
	self:UpdateKinEncounterBtn()
	self:UpdateWLDHBtn()
	self:UpdateZNQBtn()
	--self:UpdateWaiYiTryBtn()
	--self:UpdateItemRecoveryBtn()
end

function TopButton:UpdateWaiYiTryBtn()
	local bShow = WaiYiTry:CanShowHomeScreenBtn()
	self:SetBtnActive("BtnDress", bShow)
	if bShow then
		self.pPanel:SetActive("texiaoDress", Client:GetFlag("WaiYiTryGuide") ~= 1)
	end
end

function TopButton:CheckShowSurvey()
	local bSurveyAvailable = Survey:Available()

	if Client:IsCloseIOSEntry() then
		bSurveyAvailable = false
	end

	self:SetBtnActive(self.tBtn2Ui.SurveyPanel, bSurveyAvailable)
end

function TopButton:CheckHasCanUpgradeSkill()
	local tbSkillBook = Item:GetClass("SkillBook");
	tbSkillBook:UpdateRedPoint(me);

	local bShowRedPoint = false;
	local tbFactionSkill = FightSkill:GetFactionSkill(me.nFaction);
	for _, tbInfo in pairs(tbFactionSkill) do
		local bRet = FightSkill:CheckSkillLeveUp(me, tbInfo.SkillId);
		if bRet then
			bShowRedPoint = true;
			break;
		end
	end

	if bShowRedPoint == true and me.nLevel >= 4 then
		if not Ui:GetRedPointState("Skill") then
			self.bSkillPointNotify = true;
			Ui:SetRedPointNotify("Skill");
		end
	else
		if self.bSkillPointNotify then
			self.bSkillPointNotify = false;
			Ui:ClearRedPointNotify("Skill");
		end
	end
end

function TopButton:CheckFirstRechargeShow()
	local nHonorLevel = Calendar.JOIN_LV
	self:SetBtnActive("BtnHonor", me.nLevel >= nHonorLevel)

	local bGetFirstRecharge = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_GET_FIRST_RECHARGE) == 1
	local bShow = me.nLevel >= 10 and me.nLevel <= math.min(nHonorLevel - 1, 40) and not bGetFirstRecharge
	local bEffects = WelfareActivity:IsDayFirstLogin()
	self:SetBtnActive("BtnRecharge", bShow)
	self:SetBtnActive("texiao1", bShow and bEffects)
end

--登录奖励按钮出现由功能控制
function TopButton:UpdateShowLoginAwardBtn()
	local bEnable = LoginAwards:IsActivityActive()
	if FriendRecall:IsShowMainButton() then
		bEnable = false
	end
	self:SetBtnActive("BtnLoginAward", bEnable)
end

--升级引导UI
function TopButton:CheckLevelUpGuide()
	self.LevelGuide:Update()

	if Client:IsCloseIOSEntry() then
		self:SetBtnActive("BtnMarketStall",false);
		self:SetBtnActive("BtnAuction",false);
	end
end

--月媚儿倒计时
function TopButton:UpdatePartnerTime()
	self.nLoginAwardsTimer = Timer:Register(Env.GAME_FPS, function ()
		local szTime = LoginAwards:GetPartnerTime(true)
		self:SetBtnActive("LoginAwardTimesBg", szTime and true or false)
		if not szTime then
			self.nLoginAwardsTimer = nil
			return
		end

		self.pPanel:Label_SetText("LoginAwardTimes", szTime)
		return true
	end)
end

function TopButton:CloseLoginAwardsTimer()
	if self.nLoginAwardsTimer then
		Timer:Close(self.nLoginAwardsTimer)
		self.nLoginAwardsTimer = nil
	end
end

--活动引导
function TopButton:UpdateActivityGuide()
	self:CloseActivityGuideTimer();
	self.LevelGuide:OnOpen()
	local tbSkillBook = Item:GetClass("SkillBook");
	self.nActivityGuideTimer = Timer:Register(Env.GAME_FPS * 5, function ()
		if GetTime() % 60 < 5 then
			self.LevelGuide:Update()
			tbSkillBook:UpdateRedPoint(me);
		end

		return true
	end)
end

function TopButton:CloseActivityGuideTimer()
	if self.nActivityGuideTimer then
		Timer:Close(self.nActivityGuideTimer)
		self.nActivityGuideTimer = nil
	end
end

function TopButton:OnClose()
	MarketStall:UiCloseMarketStallTime(self);
	self:CloseLoginAwardsTimer()
	self:CloseActivityGuideTimer()
	self:CloseHouseUpgradeTimer();
	self:SetBtnActive("HideGroup", false);
	self:CloseTXLiveTimer();
	self:SetBtnActive("House", false);
	self:UpdateWeatherShowState();
	if self.nUpdateAllTimer then
		Timer:Close(self.nUpdateAllTimer);
		self.nUpdateAllTimer = nil;
	end
	if self.nTimerUpdateBtnPos then
		Timer:Close(self.nTimerUpdateBtnPos)
		self.nTimerUpdateBtnPos = nil
	end
	--self:CloseRegressionTimer()
	--self:CloseItemRecoverTimer()
end

function TopButton:CheckButtonLevelVisible(szBtnName)
	for _, LevelUi in pairs(self.tBtnLevelShow) do
		for nId = 1, #LevelUi do
			if LevelUi[nId] == szBtnName then
				return me.nLevel >= LevelUi.nLevel
			end
		end
	end

	return false
end

function TopButton:OnForbidStateChange(bIsForbid)
	self:RefreshFobidState(bIsForbid)
end

function TopButton:RefreshFobidState(bIsForbid)
	self:SetBtnActive("BtnZeroIncome", bIsForbid)
	if not bIsForbid and self:CheckButtonLevelVisible("BtnStronger") then
		local bRet = self:CheckOpenExpUp();
		if bRet then
			self:SetBtnActive("BtnExpUp", true);
			self:SetBtnActive("BtnStronger", false);
			local tbInfo = Client:GetUserInfo("BtnExpUpRed");
			if not tbInfo or not tbInfo.nRedPoint then
				Ui:SetRedPointNotify("ExpUpRedPoint")
			else
				Ui:ClearRedPointNotify("ExpUpRedPoint")
			end
		else
			self:SetBtnActive("BtnExpUp", false);
			--与回归特权和实名认证互斥
			--129级上限开放后补不显示变强
			self:SetBtnActive("BtnStronger", true and not RegressionPrivilege:IsShowButton() and
								 not Sdk:ShowHomeScreenRealAuth() and
								  Player.Stronger:CheckVisible());
		end
	else
		self:SetBtnActive("BtnStronger", false);
		self:SetBtnActive("BtnExpUp", false);
	end
end

function TopButton:CheckOpenExpUp()
    if RegressionPrivilege:IsShowButton() then
    	return false;
    end

    local tbLevelInfo = Npc:GetPlayerLevelAddExpP() or {};
    local nExpP = tbLevelInfo[me.nLevel];
    if not nExpP or nExpP <= 100 then
    	return false;
    end

    return true;
end

function TopButton:OnRefreshPandoraIcon(szModule, szTab, bIsShowIcon, bIsShowRedPoint)
	if szModule == "PlayerRegression" then
		self:RefreshRegressionBtn(bIsShowIcon, bIsShowRedPoint)
	elseif szModule == "FamilySelect" then
		self:RefreshFamilySelectBtn(bIsShowIcon, bIsShowRedPoint)
	end
end

function TopButton:RefreshFamilySelectBtn(bIsShowIcon, bIsShowRedPoint)
	Activity.KinElect.bShowBtn = bIsShowIcon
	self:UpdateKinElectBtn()
end

--回归
function TopButton:RefreshRegressionBtn(bIsShowIcon, bIsShowRedPoint)
--[[
	local bShow = bIsShowIcon or RegressionPrivilege:IsRegressionPlayer(Player:GetMyRoleId())
	self:SetBtnActive("BtnRebate", bShow and true or false)
	if bIsShowRedPoint then
		Ui:SetRedPointNotify(Pandora.szPlayerRegression)
	else
		Ui:ClearRedPointNotify(Pandora.szPlayerRegression)
	end
]]
	self:SetBtnActive("BtnRebate", false)
end

function TopButton:OnPreciseCastSkill(bStart)
	if bStart then
		self.LevelGuide.pPanel:SetActive("Main", false);
	else
		self:CheckLevelUpGuide()
	end
end

--玩家召回按钮出现由功能控制
function TopButton:UpdateShowFriendRecallBtn()
	self:SetBtnActive("BtnReunionArena", FriendRecall:IsShowMainButton())
	self:UpdateShowLoginAwardBtn();
end

function TopButton:UpdateBeautyPageantBtn()
--[[
	local bEnable = Activity.BeautyPageant:IsShowMainButton();

	self:SetBtnActive("BtnBeauty", bEnable)
	if bEnable then
		local nState = Activity.BeautyPageant:GetCurState();
		self.pPanel:Label_SetText("BeautyTimes", Activity.BeautyPageant.STATE_DESC[nState] or "");
	end
	self:UpdateTXLiveInfo();
]]
	self:SetBtnActive("BtnBeauty", false)
end

function TopButton:UpdateKinElectBtn()
	local bEnable = Activity.KinElect:IsShowMainButton();
	self:SetBtnActive("BtnFamilySelection", bEnable)
	if bEnable then
		local nState = Activity.KinElect:GetCurState();
		self.pPanel:Label_SetText("FamilySelectionState", Activity.KinElect.STATE_DESC[nState] or "");
	end
	self:StartKinElectTimer(bEnable);
end

function TopButton:StartKinElectTimer(bEnable)
	self:CloseKinElectTimer();
	if not bEnable then
		return
	end

	local fnSetTxt = function ()
		local nLeftTime = Activity.KinElect:GetStateLeftTimeShow()
		if nLeftTime <= 0 then
			self:CloseKinElectTimer()
			return false;
		else
			self.pPanel:Label_SetText("FamilySelectionTime", Lib:TimeDesc2(nLeftTime));
			self.pPanel:SetActive("FamilySelectionTimeBg", true)
		end
		return true;
	end
	self.nKinElectTimer = Timer:Register(Env.GAME_FPS, fnSetTxt)
end

function TopButton:CloseKinElectTimer()
	if self.nKinElectTimer then
		Timer:Close(self.nKinElectTimer)
		self.nKinElectTimer = nil;
	end
	self.pPanel:SetActive("FamilySelectionTimeBg", false)
end

function TopButton:UpdateGoodVoiceBtn()
--[[
	local bEnable = Activity.GoodVoice:CheckJoin(me);

	self:SetBtnActive("BtnGoodVoice", bEnable)
	if bEnable then
		local nState = Activity.GoodVoice:GetCurState();
		self.pPanel:Label_SetText("GoodVoiceTimes", Activity.GoodVoice.STATE_DESC[nState] or "");
	end
	self:UpdateTXLiveInfo();
]]
	self:SetBtnActive("BtnGoodVoice", false)
end

function TopButton:UpdateShiyingeBtn()
--[[
	local bEnable = Activity.GoodVoice:CheckJoin(me);
	self:SetBtnActive("BtnShiyinge", bEnable)
	if bEnable then
		local nState = Activity.GoodVoice:GetCurState()
		self.pPanel:Label_SetText("ShiyingeTimes", Activity.GoodVoice.STATE_DESC[nState] or "")
	end
	self:UpdateTXLiveInfo()
]]

	self:SetBtnActive("BtnShiyinge", false)
end

function TopButton:UpdateKinEncounterBtn()
	self:SetBtnActive("BtnEngagement", not not Activity:__IsActInProcessByType("KinEncounterAct"))
	self:SetBtnActive("EngagementTimesBg", KinEncounter:IsPreparing())
end

function TopButton:UpdateWLDHBtn()
	local bShow,szActTime = WuLinDaHui:IsShowTopButton()
	self:SetBtnActive("BtnWLDH", bShow)
	WuLinDaHui:CheckRedPoint()
end

function TopButton:UpdateItemRecoveryBtn()
	local bShow = Item.tbItemRecovery:IsShowUi( me )
	self:SetBtnActive("BtnRecovery", bShow)
	if bShow then
		self:UpdateItemRecoverTimer()
	else
		self:CloseItemRecoverTimer()
	end
	Item.tbItemRecovery:CheckRedPoint()
end

function TopButton:UpdateZNQBtn()
	if Activity:__IsActInProcessByType("ZhouNianQing2") then
		self.pPanel:Button_SetSprite("BtnAnniversary", "NewYearsActivity");
		self:SetBtnActive("BtnAnniversary", true)
		local szDesc = Activity:GetCurRuningActShowDesc()
		if szDesc then
			self:SetBtnActive("AnniversaryStateBg", true)
			self.pPanel:Label_SetText("AnniversaryState", szDesc)
		else
			self:SetBtnActive("AnniversaryStateBg", false)
		end
	else
		self:SetBtnActive("BtnAnniversary", false)
	end
end

function TopButton:UpdateRegressionTimer()
end

function TopButton:UpdateDaShiSaiBtn()
	if Activity:__IsActInProcessByType("KinChaosFightAct") then
		self:SetBtnActive("BtnDashisai", true)
		local szDesc = Activity.tbKinChaosFight:GetStateDesc()
		if szDesc then
			self.pPanel:Label_SetText("DashisaiState", szDesc)
		end
	else
		self:SetBtnActive("BtnDashisai", false)
	end
end

function TopButton:CloseRegressionTimer()
	if self.nRegressionTimer then
		Timer:Close(self.nRegressionTimer)
		self.nRegressionTimer = nil
	end
end

function TopButton:UpdateItemRecoverTimer()
end

function TopButton:CloseItemRecoverTimer()
end

function TopButton:UpdatePhotoState()
end

function TopButton:OnSwitchHousePlace()
	self:RefreshHouseButton();
end