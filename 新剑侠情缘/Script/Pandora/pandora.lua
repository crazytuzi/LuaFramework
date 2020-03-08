--精细化运营
local _Pandora = luanet.import_type("PandoraService");

Pandora.tbShowInfo = Pandora.tbShowInfo or {}

Pandora.szModulePlayerSpace = "PlayerSpace" --玩家空间的modle名
Pandora.szModuleWorldSquare = "WorldSquare" --江湖广场
Pandora.szModuleGoodVoice = "GoodVoice" 	-- 好声音modle名
Pandora.szPlayerRegression = "PlayerRegression" 	-- 回流返利modle名
Pandora.tbRedpointSetting = {
	[Pandora.szModuleWorldSquare] = "PandoraPlayerSpace";
	[Pandora.szModuleGoodVoice] = "PandoraGoodVoice";
	[Pandora.szPlayerRegression] = "PlayerRegression";
};
Pandora.szModuleGoodVoicePlayerPageName = "PlayerPage" 	-- 好声音玩家页面tab名，方便修改

--视频地址配置，接口中自动判断网络情况选择不同的地址
--[id] = {[1] = "移动网络环境地址", [2] = "wifi环境地址"}
Pandora.tbVideoUrl =
{
	--任务视频
	[1] = --序
	{
		[1] = "http://down.qq.com/yxgw/jxqy/gsp/091701.mp4",
		[2] = "http://down.qq.com/yxgw/jxqy/gsp/001.mp4",
	},
	[2] = --无名
	{
		[1] = "http://down.qq.com/yxgw/jxqy/gsp/091702.mp4",
		[2] = "http://down.qq.com/yxgw/jxqy/gsp/002.mp4",
	},
	[3] = --独孤雪
	{
		[1] = "http://down.qq.com/yxgw/jxqy/gsp/091703.mp4",
		[2] = "http://down.qq.com/yxgw/jxqy/gsp/003.mp4",
	},
	[4] = --挑战者
	{
		[1] = "http://down.qq.com/yxgw/jxqy/gsp/091704.mp4",
		[2] = "http://down.qq.com/yxgw/jxqy/gsp/004.mp4",
	},
	[5] = --独孤影
	{
		[1] = "http://down.qq.com/yxgw/jxqy/gsp/091705.mp4",
		[2] = "http://down.qq.com/yxgw/jxqy/gsp/005.mp4",
	},
	[6] = --决战
	{
		[1] = "http://down.qq.com/yxgw/jxqy/gsp/091706.mp4",
		[2] = "http://down.qq.com/yxgw/jxqy/gsp/006.mp4",
	},
}

function Pandora:IsEnable()
	if not Sdk:IsMsdk() then
		return false;
	end

	if Client:IsCloseIOSEntry() then
		return false
	end
	if IOS or ANDROID then
		return true
	end
	return false;
end

function Pandora:GetInitParam()
	return 1136, 640
end

function Pandora:OnHandleGeneralCmd(tbParam)
	Log("Pandora:OnHandleGeneralCmd")
	Lib:LogTB(tbParam)
	if not Pandora:IsEnable() then
		return
	end

	if not tbParam["type"] then -- not tbParam:ContainsKey("type") then
		Log("Pandora OnHandleGeneralCmd not have type tbParam");
		return
	end

	local fnProcess = Pandora[tostring(tbParam["type"])]
	if fnProcess then
		fnProcess(tbParam)
	else
		Log("Pandora unimpl process", tbParam["type"]);
	end
end

function Pandora:OnLogin(dwRoleId, nFaction, nSex)

	Log("Pandora:OnLogin", tostring(dwRoleId), tostring(nFaction), tostring(nSex))

	if not Pandora:IsEnable() then
		return
	end

	if not (Sdk:IsLoginByQQ() or Sdk:IsLoginByWeixin()) then
		return
	end

	local szAccountType = "qq"
	if Sdk:IsLoginByWeixin() then
		szAccountType = "wx"
	end
	local nQQInstalled = 0;
	local nWXInstalled = 0;

	if Sdk:IsPlatformInstalled(Sdk.ePlatform_QQ) then
		nQQInstalled = 1;
	end

	if Sdk:IsPlatformInstalled(Sdk.ePlatform_Weixin) then
		nWXInstalled = 1;
	end

	local msdkInfo = Sdk:GetMsdkInfo()

	local tbParam =
	{
		["sRoleId"] = tostring(dwRoleId),
		["sOpenId"] = msdkInfo.szOpenId,
		["sAcountType"] = szAccountType,
		["sArea"] = tostring(Sdk:GetAreaId()),
		["sPlatID"] = tostring(Sdk:GetPlatId()),
		["sPartition"] = tostring(Sdk:GetServerId()),
		["sAppId"] = Sdk:GetCurAppId(),
		["sAccessToken"] = msdkInfo.szOpenKey,
		["sPayToken"] =  msdkInfo.szPayToken,
		["sGameVer"] = Ui:GetClass("Login"):GetVersionDesc(),
		["sQQInstalled"] = tostring(nQQInstalled),
		["sWXInstalled"] = tostring(nWXInstalled),
		["sServiceType"] = "jxqy",
		["sGameName"] = "jxqy",
		["sGuildName"] = tostring(nFaction),
		["sGender"] = tostring(nSex),
		["sIsPCVersion"] = tostring(Sdk:IsPCVersion()),
		["sIsLoginForIOS"] = tostring(Sdk:IsLoginForIOS()),
		["sExtend"] = "",
	};
	Lib:LogTB(tbParam)

	_Pandora.PlayerLogin(tbParam);

	UiNotify:RegistNotify(UiNotify.emNOTIFY_CHANGE_FIGHT_STATE, self.OnChangeFightState, self);
end

function Pandora:OnLogout()
	Log("Pandora:OnLogout")

	self.tbShowInfo = {};
	self.bOpenPL = false
	self.bWelfareActivity = false
	self.bWillShowPL = false
	self:ClearRecordData()

	if not Pandora:IsEnable() then
		return
	end

	if Sdk:IsLoginByGuest() then
		return
	end

	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_CHANGE_FIGHT_STATE, self)

	_Pandora.PlayerLogout();
end

function Pandora:IsShowIcon(szModule, szTab)
	if not szModule or not szTab  then
		return false
	end

	local tbModule = Pandora.tbShowInfo[szModule];
	if not tbModule then
		return false
	end

	local tbTab = tbModule[szTab];
	if not tbTab then
		return false
	end

	return tbTab.bIsShowIcon
end

function Pandora:IsShowRedPoint(szModule, szTab)
	if not szModule or not szTab  then
		return false
	end

	local tbModule = Pandora.tbShowInfo[szModule];
	if not tbModule then
		return false
	end

	local tbTab = tbModule[szTab];
	if not tbTab then
		return false
	end

	return tbTab.bIsShowRedPoint
end

function Pandora:GetShowName(szModule, szTab)
	if not szModule or not szTab  then
		return nil
	end

	local tbModule = Pandora.tbShowInfo[szModule];
	if not tbModule then
		return nil
	end

	local tbTab = tbModule[szTab];
	if not tbTab then
		return nil
	end

	if tbTab.szShowName == "" then
		return nil
	end

	return tbTab.szShowName
end


function Pandora:GetItemDesc(szTemplateId)
	local nTemplateId = tonumber(szTemplateId);
	if not nTemplateId then
		return
	end

	local tbInfo = KItem.GetItemBaseProp(nTemplateId)
	if not tbInfo then
		return;
	end

	return tbInfo.szIntro;
end

function Pandora:OpenSeekHelp(szJumpTarget, szExtends)
	Log("Pandora:OpenSeekHelp", szJumpTarget, szExtends)
	if not Pandora:IsEnable() then
		return
	end

	_Pandora.DoAction({["type"] = "Open", ["content"] = szJumpTarget, ["extends"] = szExtends})
end

function Pandora:OpenPL()
	if not Pandora:IsEnable() then
		return
	end

	Pandora.bOpenPL = true

	_Pandora.DoAction({["type"] = "OpenPL", ["content"] = "EnterGame"})
end

function Pandora:Open(szModule, szTab)
	if not Pandora:IsEnable() then
		return
	end

	if szTab == "Webview" then
		_Pandora.DoAction({["type"] = "OpenWebview", ["module"] = szModule, ["tab"] = szTab})
	else
		_Pandora.DoAction({["type"] = "Open", ["module"] = szModule, ["tab"] = szTab})
	end
end

function Pandora:Hide(szModule, szTab)
	if not Pandora:IsEnable() then
		return
	end

	_Pandora.DoAction({["type"] = "Hide", ["module"] = szModule, ["tab"] = szTab})
end

function Pandora:ClosePanel(szModule)

	if not Pandora:IsEnable() then
		return
	end

	_Pandora.DoAction({["type"] = "Close",["module"] = szModule,})
end

function Pandora:OnWindowClose(szUiName)
	if not Pandora:IsEnable() then
		return
	end

	_Pandora.DoAction({["type"] = "GamePanelClosed",["content"] = szUiName,})
end

function Pandora:OpenPlayerSpace(dwRoleId)
	if not Pandora:IsEnable() then
		return
	end
	local tbExtendData = {};
	if me.dwID == dwRoleId then
		local szRedPoint = Pandora.tbRedpointSetting[Pandora.szModulePlayerSpace]
		if szRedPoint then
			Ui:ClearRedPointNotify(szRedPoint)		
		end
		
		Pandora:OnOpenPlayerSpace({
			dwRoleId = dwRoleId,
			szOpenId = Sdk:GetUid(),
			})		
		Task:TryAddZoneTaskExtPoint(Task.nMyZoneTaskId)
		Ui:ClearRedPointNotify("BtnHomepageMy")
		Ui:CloseWindow("RoleInformationPanel")
	else
		RemoteServer.RequestOpenPandoraPlayerSpace(dwRoleId)
		Task:TryAddZoneTaskExtPoint(Task.nOtherZoneTaskId)
	end
end

function Pandora:OnOpenPlayerSpace(tbParams)
	if not Pandora:IsEnable() then
		return
	end
	if not self:IsEnablePlayerSpace() then
		return
	end
	local bMine = tbParams.dwRoleId == me.dwID;
	local szExtendData =  string.format("%s#%s", tbParams.dwRoleId or "", tbParams.szOpenId or "") ;
	_Pandora.DoAction({["type"] = "Open",["module"] = Pandora.szModulePlayerSpace, ["tab"] = bMine and "PersonalZone" or "GeneralZone",
				["action"] = "", extentdData = szExtendData })
end

function Pandora:OpenGoodVoiceMain()
	if not Pandora:IsEnable() then
		return
	end
	_Pandora.DoAction({["type"] = "Open",["module"] = Pandora.szModuleGoodVoice, ["tab"] = "CompetitionScene", ["action"] = "" })
	Log("[Pandora] OpenGoodVoiceMain ok..")
	return true
end

function Pandora:OpenGoodVoiceSignUp()
	if not Pandora:IsEnable() then
		return
	end
	_Pandora.DoAction({["type"] = "Open",["module"] = Pandora.szModuleGoodVoice, ["tab"] = "PersonalPage", ["action"] = "" })
	Log("[Pandora] OpenGoodVoiceSignUp ok..")
	return true
end

function Pandora:OpenGoodVoicePlayerPage(tbParams)
	if not Pandora:IsEnable() then
		return
	end
	local dwRoleId = tbParams.dwRoleId or ""
	local szOpenId = tbParams.szOpenId or ""
	local szExtendData =  string.format("%s#%s", dwRoleId, szOpenId) ;
	_Pandora.DoAction({["type"] = "Open",["module"] = Pandora.szModuleGoodVoice, ["tab"] = Pandora.szModuleGoodVoicePlayerPageName, 
		["action"] = "" , extentdData = szExtendData})
	Log("[Pandora] OpenGoodVoicePlayerPage ok..", dwRoleId ,szOpenId)
	return true
end

function Pandora:OpenDrinkHouseWolrdSquare()
	if not Pandora:IsEnable() then
		return
	end
	-- {"module":"WorldSquare","type":"Open","action":"","tab":"CompetitionScene"}
	_Pandora.DoAction({["type"] = "Open",["module"] = "WorldSquare", ["tab"] = "CompetitionScene", ["action"] = "" });
	Log("[Pandora] OpenDrinkHouseWolrdSquare")
	return true
end

function Pandora:OpenWorldSquare()
	if not Pandora:IsEnable() then
		return
	end
	if not self:IsEnablePlayerSpace() then
		return
	end
	_Pandora.DoAction({["type"] = "Open",["module"] = Pandora.szModuleWorldSquare, ["tab"] = "", ["action"] = "" })
	Task:TryAddZoneTaskExtPoint(Task.nWorldSquareTaskId)
	Ui:ClearRedPointNotify("PandoraPlayerSpaceGuide")
end

function Pandora:OpenPlayerRegression()
	if not Pandora:IsEnable() then
		return
	end
	self:Open("Huiliu", "GeneralPanel")
	Ui:ClearRedPointNotify("PlayerRegression")
	Log("Pandora OpenPlayerRegression Ok..")
end

function Pandora:CheckPushNewInfomation(szModule, szTab, szShowName, nFlag)
	if szModule ~= "NewInformationPanel" then
		return
	end

	local tbInfo =
	{
		szKey = szTab,
		szTitle = szShowName,
		nShowPriority = 999,
		nOperationType = nFlag,
		szUiName = "Normal",
		szTimeFunc = "fnCheckPandora",
		szClickFunc = "fnClickPandora",
		szSwitchFunc = "fnSwitchPandora",
		szCheckShowFunc = "fnCheckShowPandora",
		szCheckRpFunc = "fnPandoraCheckRp",
	};

	NewInformation:AddLocalSetting(tbInfo)
	NewInformation:PushLocalInformation();
end

function Pandora:CheckPushWelfareActivity(szModule, szTab, szShowName)
	if szModule ~= "WelfareActivity" then
		return
	end

	local tbInfo =
	{
		szKey = szTab,
		szName = szShowName,
		szCheckShowFunc = "fnCheckShowPandora",
		szClickFunc = "fnClickPandora",
		szSwitchFunc = "fnSwitchPandora",
		szCheckRpFunc = "fnPandoraCheckRp",
		szCheckNewIconFunc = "fnCheckPandoraWelfareNewIcon",
	};

	WelfareActivity:AddLocalActivity(tbInfo)
end

function Pandora.ShowIcon(tbParam)
	local szModule = tostring(tbParam["module"])
	local szTab = tostring(tbParam["tab"])
	local szContent = tostring(tbParam["content"])
	local szShowName = tostring(tbParam["showName"])
	local bIsShow = (szContent == "1")
	local nFlag = tonumber(tbParam["flag"])

	Pandora.tbShowInfo[szModule] = Pandora.tbShowInfo[szModule] or {}
	Pandora.tbShowInfo[szModule][szTab] =  Pandora.tbShowInfo[szModule][szTab] or {}
	local tbShowInfo = Pandora.tbShowInfo[szModule][szTab]
	tbShowInfo.bIsShowIcon = bIsShow
	tbShowInfo.szShowName = szShowName

	if szModule == "NewInformationPanel" then
		--幸运星活动独立一个显示标签
		if szTab == "LuckyStar" or szTab == "ImperialExam" then
			if bIsShow then
				local tbRedpoint = {}
				table.insert(tbRedpoint, "Btn" .. szTab)
				Ui:InitRedPointNode("NewMessageRedPoint", tbRedpoint)
				Ui:SetRedPointNotify("Btn" .. szTab)
			else
				Ui:ClearRedPointNotify("Btn" .. szTab)
			end
		else
			Pandora:CheckPushNewInfomation(szModule, szTab, szShowName, nFlag)
		end
	elseif szModule == "WelfareActivity" then
		Pandora:CheckPushWelfareActivity(szModule, szTab, szShowName)
	elseif szModule == Pandora.szPlayerRegression then
		RegressionPrivilege:CachePandoraPlayer(Player:GetMyRoleId(), bIsShow)
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_PANDORA_REFRESH_ICON, szModule, szTab, tbShowInfo.bIsShowIcon, tbShowInfo.bIsShowRedPoint)
end

function Pandora.ShowRedPoint(tbParam)
	local szModule = tostring(tbParam["module"])
	local szTab = tostring(tbParam["tab"])
	local szContent = tostring(tbParam["content"])
	local bIsShow = (szContent == "1")
	Pandora.tbShowInfo[szModule] = Pandora.tbShowInfo[szModule] or {}
	Pandora.tbShowInfo[szModule][szTab] =  Pandora.tbShowInfo[szModule][szTab] or {}
	local tbShowInfo = Pandora.tbShowInfo[szModule][szTab]
	tbShowInfo.bIsShowRedPoint = bIsShow

	NewInformation:CheckRedPoint()

	UiNotify.OnNotify(UiNotify.emNOTIFY_PANDORA_REFRESH_ICON, szModule, szTab, tbShowInfo.bIsShowIcon, tbShowInfo.bIsShowRedPoint)

	local szRedPoint = Pandora.tbRedpointSetting[szModule]
	if szRedPoint then
		if bIsShow then
			Ui:SetRedPointNotify(szRedPoint)
		else
			Ui:ClearRedPointNotify(szRedPoint)
		end
	end
end

function Pandora.ClosePL(tbParam)
	if Pandora.bWelfareActivity then
		Ui:OpenWindow("WelfareActivity","OnHook");
	end
	Pandora.bWelfareActivity = false
	Pandora.bOpenPL = false
end

function Pandora.OpenUrl(tbParam)
	Sdk:OpenUrl(tostring(tbParam["content"]))
end

function Pandora.RefreshDiamond(tbParam)
	Sdk:UpdateBalanceInfo()
end

function Pandora.ShowLoading(tbParam)
	Ui:OpenWindow("LoadingTips", tostring(tbParam["content"]));
end

function Pandora.HideLoading(tbParam)
	Ui:CloseWindow("LoadingTips");
end

function Pandora.GoTo(tbParam)

	Ui:CloseWindow("NewInformationPanel");

	local szClassName = tostring(tbParam["module"])
	local szTabName = tostring(tbParam["tab"])
	if szTabName == "" then
		szTabName = nil
	end

	if szClassName == "Mail" then
		Ui:OpenWindow("ChatLargePanel", ChatMgr.nChannelMail);
	elseif szClassName == "WelfareActivity" then
		local nMinLevel, _ = WelfareActivity:GetActivityOpenLevel(szTabName)
		if nMinLevel and nMinLevel > me.nLevel then
			me.CenterMsg("您的级别不够，暂时无法参加活动")
		else
			Ui:OpenWindow('WelfareActivity', szTabName)
		end
	elseif szClassName == "NewInformationPanel" then
		local tbList = NewInformation:GetShowActivity();
		local bShow = false;
		if szTabName then
			for _,szKey in pairs(tbList) do
				if szKey == szTabName then
					bShow = true
					break;
				end
			end
		else
			bShow = true;
		end

		if bShow then
			Ui:OpenWindow('NewInformationPanel', szTabName)
		else
			me.CenterMsg("您的级别不够，暂时无法参加活动")
		end
	elseif szClassName == "CalendarPanel" then
		local nTabIdx = (szTabName and tonumber(szTabName)) or 1
		Ui:OpenWindow(szClassName, nTabIdx)
	else
		Ui:OpenWindow(szClassName, szTabName)
	end
end

function Pandora.ShowItemDetail(tbParam)
	Log("Pandora.ShowItemDetail")
	local nTemplate = tonumber(tbParam["content"])
	if not nTemplate then
		return
	end

	local tbInfo = {
		nTemplate = nTemplate;
		nFaction = me.nFaction;
	};
	Item:ShowItemDetail(tbInfo);
end

function Pandora.GoPandora(tbParam)
	local szModule = tostring(tbParam["module"])
	local szTab = tostring(tbParam["tab"])

	if szModule == "NewInformationPanel" then
		szTab = "Local_" .. szTab
	end

	Ui:OpenWindow(szModule, szTab)
end

function Pandora.ShowPL(tbParam)
	if not Pandora:IsEnable() then
		return
	end

	local szMapClass = Map:GetClassDesc(me.nMapTemplateId)

	if not Map:IsMapOnLoading() and (szMapClass == "city" or (szMapClass == "fight" and me.nFightMode == 0)) then
		Pandora.bWillShowPL = false;
		Pandora.bWelfareActivity = Ui:WindowVisible("WelfareActivity") or (Ui.tbWaitingForOpen["WelfareActivity"] ~= nil)
		Ui:CloseWindow("WelfareActivity")
		Pandora:OpenPL()
	else
		Pandora.bWillShowPL = true;
	end
end

function Pandora.ShowCommonTips(tbParam)
	local szMsg = tostring(tbParam["content"])

	me.CenterMsg(szMsg);
end

function Pandora.PictureShare(tbParam)
	local nSendType = tonumber(tbParam["sendType"])
	local szMediaTagName = tostring(tbParam["mediaTagName"])
	local szMessageAction = tostring(tbParam["messageAction"])
	local szObjPath = tostring(tbParam["gameObjectPath"])

	local szSendType = ""

	if Sdk:IsLoginByQQ() then
		szSendType = (nSendType ~= 1 and "QQ") or "QZone"
	elseif Sdk:IsLoginByWeixin() then
		szSendType = (nSendType ~= 1 and "WX") or "WXMo"
	end

	Sdk.SdkMgr.SharePhotoWithObjPath(szSendType, szMediaTagName, "", szMessageAction, szObjPath);
end

function Pandora.H5Share(tbParam)
	local nSendType = tonumber(tbParam["sendType"])
	local szUrl = tostring(tbParam["targetUrl"])
	local szTitle = tostring(tbParam["title"])
	local szDesc = tostring(tbParam["desc"])
	local szImgUrl = tostring(tbParam["imgUrl"])
	local szMediaTagName = tostring(tbParam["mediaTagName"])

	local szSendType = ""

	if Sdk:IsLoginByQQ() then
		szSendType = (nSendType ~= 1 and "QQ") or "QZone"
	elseif Sdk:IsLoginByWeixin() then
		szSendType = (nSendType ~= 1 and "WXSe") or "WXMo"
	end

	Sdk.SdkMgr.ShareUrl(szSendType, szTitle, szDesc, szMediaTagName, szUrl, szImgUrl);
end


function Pandora.SeekHelp(tbParam)
	local szSendContent = tostring(tbParam["sendContent"])
	local nSendChannel = tonumber(tbParam["sendChannel"])
	local szJumpTarget = tostring(tbParam["jumpTarget"])
	local szExtends = tostring(tbParam["extends"])

	if not ChatMgr.tbPandoraSeekChannel[nSendChannel] then
		Log("Pandora.SeekHelp wrong channel id", tostring(nSendChannel))
		return
	end

	if not ChatMgr:CheckSendMsg(nSendChannel, "1", false) then
		return;
	end

	RemoteServer.SendPandoraSeekHelpMsg(nSendChannel, szSendContent, szJumpTarget, szExtends);
end

function Pandora.PlayBackgroundMusic(tbParam)
	Pandora:RestoreOtherVoice();
end

function Pandora.StopBackgroundMusic(tbParam)
	Pandora:StopOtherVoice();
end

function Pandora:OnEnterMap(nTemplateID, nMapID, nIsLocal)
end

function Pandora:OnMapLoaded(nTemplateID)
	if self.bWillShowPL then
		Pandora.ShowPL({});
	end
end

function Pandora:OnChangeFightState(nFightState)
	if nFightState == 0 and self.bWillShowPL then
		Pandora.ShowPL({});
	end

end

function Pandora:OnEventWithReturn(tbParam)
	Lib:LogTB(tbParam)

	local nMySex = 1;
	local pNpc = me.GetNpc();
	if pNpc then
		nMySex = me.nSex;
	end

	local szType = tbParam.type;
	local szContent = tbParam.content;
	if szType == "getItemPath" then
		local nItemId = tonumber(szContent);
		local nFaction = tonumber(tbParam.guildName or "") or me.nFaction
		local nSex = Player:Faction2Sex(nFaction, tonumber(tbParam.gender or "") or nMySex);
		local szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(nItemId, nFaction, nSex)
		local szIconAtlas = ""
		local szIconSprite = ""
		local szExtAtlas = ""
		local szExtSprite = ""
		if nIcon then
			local _szIconAtlas, _szIconSprite, _szExtAtlas, _szExtSprite = Item:GetIcon(nIcon);
			szIconAtlas = _szIconAtlas
			szIconSprite = _szIconSprite
			szExtAtlas = _szExtAtlas
			szExtSprite = _szExtSprite
			local nFragNum = Compose.EntityCompose.tbShowFragTemplates[nItemId];
			if nFragNum then
				szExtAtlas = "UI/Atlas/NewAtlas/Panel/NewPanel.prefab"
				szExtSprite = "itemfragmnet"
			end
		end

		return {type="refreshItemPath", content=string.format("%s#%s#%s#%s", szIconAtlas, szIconSprite, szExtAtlas, szExtSprite)};
	elseif szType == "getItemFramePath" then
		local nItemId = tonumber(szContent);
		local szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(nItemId, me.nFaction, nMySex)
		local szFrameColor = ""
		if nQuality then
			local _, _szFrameColor, _, _ = Item:GetQualityColor(nQuality)
			szFrameColor = _szFrameColor
		end
		return {type="refreshItemFramePath", content=string.format("UI/Atlas/NewAtlas/Panel/NewPanel.prefab#%s", szFrameColor)};
	elseif szType == "getUserLevel" then
		return {type="refreshUserLevel", content=tostring(me.nLevel)};
	end

	return {}
end

Pandora.nOpenPlayerSpaceLevel = 39
function Pandora:IsEnablePlayerSpace()
	if not Pandora:IsEnable() then
		return false
	end
	if me.nLevel and me.nLevel < Pandora.nOpenPlayerSpaceLevel then
		return false
	end
	return true
end

function Pandora:__DoAction(tbParam)
    _Pandora.DoAction(tbParam)
    tbParam.type = tostring(tbParam.type) or "errType"
    tbParam.result = tostring(tbParam.result) or "nilRet"
    Log(string.format("Pandora __DoAction Type:%s, Result:%s", tbParam.type, tbParam.result))
end

function Pandora.midasPay(tbParam)
	Sdk:PandoraPay(tbParam);
end

function Pandora:GetAccountTokens()
	local msdkInfo = Sdk:GetMsdkInfo()

	return {
		["sAccessToken"] = msdkInfo.szOpenKey,
		["sPayToken"] =  msdkInfo.szPayToken,
	}
end

function Pandora:OpenVideo(nUrlId)
	local szUrl
	if nUrlId then
		local tbCfg = self.tbVideoUrl[nUrlId]
		if tbCfg then
			if Ui.ToolFunction.GetNetWorkType() ~= Ui.NETWORKTYPE_WIFI then
				szUrl = tbCfg[1]
			else
				szUrl = tbCfg[2] or tbCfg[1]
			end
		end
	end
	local tbParam = {["type"] = "Open", ["content"] = "Video"}
	if szUrl then
		tbParam.url = szUrl
	end
	Pandora:__DoAction(tbParam)
	Lib:LogTB(tbParam)
end

function Pandora:VideoClosed()
	Log("Pandora VideoClosed")
end