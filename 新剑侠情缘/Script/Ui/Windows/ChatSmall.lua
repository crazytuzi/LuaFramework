local tbUi = Ui:CreateClass("ChatSmall");
tbUi.nMsgSizeHeight = 0;
tbUi.nMsgCount = 0;
tbUi.tbAssistBtn = {"BtnAction", "BtnLocking", "BtnSetUp", "BtnPhotograph"}
local MAX_ROW = 6;

local _tbAssistHelp =
{
	{"HelpClicker", "HelpClicker1"},
	{"HelpClicker", "HelpClicker2"},
	{"HelpClicker", "HelpClicker3"},
	{"HelpClicker", "HelpClicker4"},
	{"HelpClicker", "HelpClicker5"},
}
local tbAssistHelp = {}
local tbAllAssistHelpWnd = {}
for nSetpId, tbInfo in ipairs(_tbAssistHelp) do
	tbAssistHelp[nSetpId] = {}
	for _, szWnd in ipairs(tbInfo) do
		tbAssistHelp[nSetpId][szWnd] = true;
		tbAllAssistHelpWnd[szWnd] = true;
	end
end

function tbUi:SetBtnCoupeDodge()
	self.pPanel:SetActive("texiao111", false);
	self.pPanel:Sprite_SetFillPercent("BtnTime", 0);
	self.pPanel:SetActive("BtnCoupeDodge", me.bInDoubleFlyTrap and true or false);
end

function tbUi:ShowBtnCoupeDodge(bActive)
	local bShow = false
	local bRedPaperActive = self.pPanel:IsActive("RedPaper")
	if bActive and not bRedPaperActive and me.bInDoubleFlyTrap then
		bShow = true
	end
	self.pPanel:SetActive("BtnCoupeDodge", bShow);
end

function tbUi:OnOpenEnd(bShowGuide)
	self.bButtonsShow = true;
	self.pPanel:SetActive("BtnChatTeamVoice", TeamMgr:HasTeam());
	self.pPanel:SetActive("BtnChatKinVoice", Kin:HasKin());
	self.pPanel:SetActive("ColorMsgground", false);
	self.pPanel:SetActive("Lantern", false)
	self.pPanel:SetActive("NewYear", false)
	self.pPanel:SetActive("HelpClicker", false);
	self:SetBtnCoupeDodge()
	self:UpdateChatMsg();
	self:UpdateColorMsg();
	self:UpdatePriveMsgNum();
	self:UpdateProcessMsgNum()
	self.pPanel:SetActive("RedPaper", false)
	self.pPanel:SetActive("BtnRadio", version_tx and ChatMgr:GFMEntrySwitch())
	-- 聊天默认收起
	if self.bSmall == nil then
		self.tbOnClick.BtnChatStretch(self);
	end

	local fnKinCallback = function (szMsg,uFileIdHigh,uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
		szMsg = ChatMgr:CutMsg(szMsg);
		ChatMgr:SendMsg(ChatMgr.ChannelType.Kin, szMsg, true, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId);
	end

	local fnCheckKin = function ()
		return ChatMgr:CheckSendMsg(ChatMgr.ChannelType.Kin, "check", true);
	end
	local nVoiceTime = ChatMgr:GetMaxVoiceTime(ChatMgr.ChannelType.Kin);
	self.pPanel:FlyCom_Init("BtnChatKinVoice", fnKinCallback, fnCheckKin, nVoiceTime);

	local fnTeamCallback = function (szMsg, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
		szMsg = ChatMgr:CutMsg(szMsg);
		ChatMgr:SendMsg(ChatMgr.ChannelType.Team, szMsg, true, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId);
	end

	local fnCheckTeam = function ()
		return ChatMgr:CheckSendMsg(ChatMgr.ChannelType.Team, "check", true);
	end
	local nVoiceTime = ChatMgr:GetMaxVoiceTime(ChatMgr.ChannelType.Team);
	self.pPanel:FlyCom_Init("BtnChatTeamVoice", fnTeamCallback, fnCheckTeam, nVoiceTime);

	if Ui:WindowVisible("BossPanel") and not Ui:IsAutoHide() then
		self:WndOpened("BossPanel");
	else
		self:WndClosed("BossPanel");
	end
	self:UpdateAssistState()
	self:UpdateToyState()
	if bShowGuide then
		self:ShowAssistHelpClicker(true)
	end
end

function tbUi:UpdateChatMsg()
	local tbItems = ChatMgr:GetChatSmallMsg();
	self.nMsgCount = #tbItems
	local tbHeight = {};
	self.nMsgSizeHeight = 0;
	local fnSetItem = function (itemObj, nIndex)
		local tbMsgData = tbItems[nIndex];
		if not tbMsgData.szSenderName then
			return;
		end

		local tbLinkInfo = tbMsgData.tbLinkInfo;
		local szCurMsg = ChatMgr:DealMsgWithLinkColor(tbMsgData.szMsg, tbLinkInfo);
		local szMsg = nil;
		if tbMsgData.szSenderName == "" then
			szMsg = string.format("%s[%s]%s%s[-]",
				ChatMgr:GetChannelEmotion(tbMsgData.nChannelType, tbMsgData.nSenderId),
				ChatMgr:GetChannelColor(tbMsgData.nChannelType, tbMsgData.nSenderId),
				(ChatMgr:IsValidVoiceFileId(tbMsgData.uFileIdHigh, tbMsgData.uFileIdLow, tbMsgData.szApolloVoiceId) and "#107") or "" , --如果是语音信息加一个图标
				szCurMsg);
		else
			szMsg = string.format("%s%s%s: [%s]%s%s[-]",
				ChatMgr:GetChannelEmotion(tbMsgData.nChannelType, tbMsgData.nSenderId),
				ChatMgr:GetNamePrefix(tbMsgData.nNamePrefix, true, tbMsgData.nChannelType, tbMsgData.nFaction, tbMsgData.nSenderId, tbMsgData.nSex),
				tbMsgData.szSenderName,
				ChatMgr:GetChannelColor(tbMsgData.nChannelType, tbMsgData.nSenderId),
				(ChatMgr:IsValidVoiceFileId(tbMsgData.uFileIdHigh, tbMsgData.uFileIdLow, tbMsgData.szApolloVoiceId) and "#107") or "" , --如果是语音信息加一个图标
				szCurMsg);
		end

		-- 处理链接点击
		if not tbLinkInfo
			or not tbLinkInfo.nLinkType
			or not ChatMgr.tbLinkClickFns[tbLinkInfo.nLinkType]
			then
			itemObj.Msg.pPanel.OnTouchEvent = nil;
		else
			itemObj.Msg.pPanel.OnTouchEvent = function (msgObj, nClickId)
				ChatMgr:OnLinkClicked(tbLinkInfo);
			end
		end

		itemObj.pPanel:Label_SetText("Msg", szMsg);
		local tbSize = itemObj.pPanel:Widget_GetSize("Msg");
		self.nMsgSizeHeight = self.nMsgSizeHeight + tbSize.y;
		itemObj.pPanel:ChangePosition("Msg", -183, tbSize.y / 2);
		itemObj.pPanel:Widget_SetSize("Main", tbSize.x, tbSize.y);

		if not tbHeight[nIndex] then
			tbHeight[nIndex] = tbSize.y;
			self.MsgScrollView:UpdateItemHeight(tbHeight);
		end
	end
	self.MsgScrollView:Update(tbItems, fnSetItem);
	self:UpdateMsgContainer();
	self.MsgScrollView:GoBottom();
end

function tbUi:UpdatePriveMsgNum(dwSender)
	local nMailNum = Mail:GetUnreadMailCount()
	local szShowTag;
	if nMailNum > 0 then
		szShowTag = "NewMail"
	else
		local nPrivateNum = ChatMgr:GetUnReadPrivateMsgNum()
		if nPrivateNum > 0 then
			szShowTag = "NewWhisper"
		end
	end

	if dwSender then
		Ui.SoundManager.PlayUISound(8011)
	end

	if szShowTag then
		self.pPanel:SetActive("BtnNewMsg", true);
		self.pPanel:SetActive("NewMail", 	"NewMail" == szShowTag)
		self.pPanel:SetActive("NewWhisper", "NewWhisper" == szShowTag)
	else
		self.pPanel:SetActive("BtnNewMsg", false);
	end
end

local tbMultis = {2, 3, 6}
function tbUi:NewRedBag(szId, nMulti)
	if me.IsInPrison() then
		Log("Update Redbag In ChatSmall Fail In prison");
		return 0;
	end

	Ui:SetRedPointNotify("KinRedBagNotify")
	self.szRedBagId = szId
	local bGlobal = Kin:RedBagIsIdGlobal(self.szRedBagId)
	self.pPanel:Texture_SetTexture("RedPaper", bGlobal and "UI/Textures/RedPaper6.png" or "UI/Textures/RedPaper2.png")
	self.pPanel:SetActive("RedPaper", true)
	self.pPanel:SetActive("effect", true)
	for i=1,3 do
		self.pPanel:SetActive("texiao"..i, tbMultis[i]==nMulti)
	end
	self.pPanel:SetActive("BtnCoupeDodge", false);
end

function tbUi:UpdateProcessMsgNum()
	if #Ui.tbNotifyMsgDatas  <= 0 then
		self.pPanel:SetActive("BtnActivityMsg", false)
		return
	end

	local szSprite = Ui:GetNotifyMsgIcon()
	if szSprite then
		self.pPanel:Button_SetSprite("BtnActivityMsg", szSprite, 1)
	end

	self.pPanel:SetActive("BtnActivityMsg", true)
	self.pPanel:PlayUiAnimation("NewMsg", false, true, {});

	local nUnReadNum = Ui.nUnReadNotifyMsgNum
	if nUnReadNum > 0 then
		self.pPanel:SetActive("NewMsg", true)
		self.pPanel:Label_SetText("NewMsgNum", nUnReadNum)
	else
		self.pPanel:SetActive("NewMsg", false)
	end
end

function tbUi:UpdateColorMsg()
	local tbColorMsg = ChatMgr:GetColorMsg();
	if tbColorMsg.szMsg then
		local szMsg = string.format("%s「%s」:%s %s", 
			ChatMgr:GetChannelEmotion(tbColorMsg.nChannelType, tbColorMsg.nSenderId),
			tbColorMsg.szSenderName, 
			(ChatMgr:IsValidVoiceFileId(tbColorMsg.uFileIdHigh, tbColorMsg.uFileIdLow) and "#107") or "" , --如果是语音信息加一个图标
			tbColorMsg.szMsg);

		self.pPanel:Label_SetText("ColorMsgText", szMsg);
		self.pPanel:SetActive("ColorIcon", false);
		self.pPanel:SetActive("ColorMsgground", false);
		self.pPanel:SetActive("ColorMsgground", true);
	else
		self.pPanel:Label_SetText("ColorMsgText", "");
		self.pPanel:SetActive("ColorMsgground", false);
		self.pPanel:SetActive("ColorIcon", false);
	end
end

function tbUi:UpdateTeamButton(szType)
	if szType == "new" then
		self.pPanel:SetActive("BtnChatTeamVoice", true);
	elseif szType == "quite" then
		self.pPanel:SetActive("BtnChatTeamVoice", false);
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnChatLarge()
	Ui:SwitchWindow("ChatLargePanel");
end

function tbUi.tbOnClick:BtnChatSetting()
	Ui:OpenWindow("ChatSetting");
end

function tbUi.tbOnClick:BtnActivityMsg()
	Ui:OpenWindow("NotifyMsgList")
end

function tbUi.tbOnClick:RedPaper()
	self.pPanel:SetActive("RedPaper", false)
	if self.szRedBagId then
		Ui:OpenWindow("RedBagDetailPanel", "viewgrab", self.szRedBagId, true)
	end
	Kin:RedBagUpdateRedPoint(false)
	self.pPanel:SetActive("BtnCoupeDodge", me.bInDoubleFlyTrap and true or false);
end 

function tbUi.tbOnClick:BtnLocking()
	local pNpc = me.GetNpc();
	if pNpc then
		local pNpcRep = Ui.Effect.GetNpcRepresent(pNpc.nId);
		if pNpcRep then
			pNpcRep:ResetRepData();
		end
	end

	if Ui:WindowVisible("ViewPanel") == 1 then
		self:UpdateAssistBtn()
		me.CenterMsg("请先完成当前操作")
		return
	end
	if Ui:WindowVisible("FrameSettingPanel") == 1 then
		self:UpdateAssistBtn()
		me.CenterMsg("请先完成当前操作")
		return
	end
	self:DoSwitchAssistState()
end

function tbUi.tbOnClick:BtnSetUp()
	Ui:OpenWindow("FrameSettingPanel")
end

function tbUi.tbOnClick:BtnPhotograph()
	Operation:StartScreenShotState()
end

function tbUi.tbOnClick:BtnCoupeDodge()
	if Operation:CheckAdjustView() then
		me.CenterMsg("请先切回2D模式")
		return
	end
	RemoteServer.OnWeddingRequest("TryDoubleFly");
end

function tbUi.tbOnClick:BtnRadio()
	if version_tx then
		ChatMgr:StartGFM()
		ChatMgr:GFMUpdateBalance()
	end
end

function tbUi:OnMoneyChanged()
	if version_tx then
		ChatMgr:GFMUpdateBalance()
	end
end

function tbUi:UpdateToyState()
	local bToyMap = Toy:CanUse(me)
	self.pPanel:SetActive("BtnToy", bToyMap)

	local bAssistMap = Operation:IsAssistMap()
	self.pPanel:ChangePosition("ColorMsgContainer", 0, (bToyMap or bAssistMap) and 55 or 15)
end

function tbUi:UpdateAssistState()
	self:UpdateAssistBtn()
end

local nExtra = 1

function tbUi:UpdateMsgContainer()
	local nMsgScrollViewY = self.bSmall and (72 + nExtra) or (0 + nExtra);
	if self.nMsgCount < MAX_ROW then
		if self.nMsgSizeHeight <= 140 then
			if self.bSmall then
				if self.nMsgSizeHeight <= 24*3 then
					nMsgScrollViewY = -4;
				elseif self.nMsgSizeHeight <= 24 * 4 then
					nMsgScrollViewY = 20;
				elseif self.nMsgSizeHeight <= 24 * 5 then
					nMsgScrollViewY = 44;
				elseif self.nMsgSizeHeight <= 140 then 			-- 中文一句三行为140，而不是24*3
					nMsgScrollViewY = 68;
				end
			else
				if self.nMsgSizeHeight <= 140 then
					nMsgScrollViewY = -4;
				end
			end
		end
	end
	self.pPanel:ChangePosition("UpContainer", 0, self.bSmall and (-72 + nExtra) or (0 + nExtra));
	self.pPanel:ChangePosition("MsgScrollView", 0, nMsgScrollViewY);
	self.pPanel:ChangePanelOffset("MsgScrollView", 0, -4);
end

function tbUi.tbOnClick:BtnChatStretch()
	self.bSmall = not self.bSmall;
	if self.bSmall == true then
		self.pPanel:ChangePosition("Ingredients",0,131);
	else
		self.pPanel:ChangePosition("Ingredients",0,203);
	end
	self.pPanel:ChangeRotate("BtnChatStretch", self.bSmall and 0 or 180);
	self:UpdateChatMsg();
end

function tbUi.tbOnClick:BtnNewMsg()
	if self.pPanel:IsActive("NewMail") then
		Ui:OpenWindow("ChatLargePanel", ChatMgr.nChannelMail);
	elseif self.pPanel:IsActive("NewWhisper") then
		Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Private);
	end
end

function tbUi.tbOnClick:BtnToy()
	local tbPos = self.bSmall and {0, -370} or {0, -290}
	Ui:OpenWindowAtPos("ToyPanel", tbPos[1], tbPos[2])
end

function tbUi.tbOnClick:BtnAction()
	local tbPos = self.bSmall and {0, -370} or {0, -290};
	Ui:OpenWindowAtPos("ActionBQPanel", tbPos[1], tbPos[2])
end

function tbUi.tbOnClick:HelpClicker()
	self:UpdateAssistHelp()
end

function tbUi.tbOnClick:BtnVoice()
	ChatMgr:OnSwitchNpcGuideVoice()
end

function tbUi:WndOpened(szUiName)
	if szUiName == "BossPanel" and not Ui:IsAutoHide() then
		Ui.UiManager.ChangeUiLayer("ChatSmall", Ui.LAYER_NORMAL);
		self.pPanel:ChangePosition("PosCtrl", -265, 0);
	end
end


function tbUi:WndClosed(szUiName)
	if szUiName == "BossPanel" then
		Ui.UiManager.ChangeUiLayer("ChatSmall", Ui.LAYER_HOME);
		self.pPanel:ChangePosition("PosCtrl", 0, 0);
	end
end

function tbUi:UpdateKinButton()
	self.pPanel:SetActive("BtnChatKinVoice", Kin:HasKin());
end

function tbUi:ChangeFightState(bFight)
	if bFight then
		self.pPanel:ChangePosition("PosCtrl", 0, 0);
	elseif Ui:WindowVisible("BossPanel") then
		self.pPanel:ChangePosition("PosCtrl", -265, 0);
	end
end

function tbUi:OnTouchReturn()
	if Ui:WindowVisible("BossPanel") then
		-- ChatSmall会在BossPanel之上，点返回需关闭BossPanel
		Ui:CloseWindow("BossPanel");
	end
end

function tbUi:OnGetSendBless(dwRoleId, bGold)
	if not dwRoleId then
		return
	end

	local tbActSetting = SendBless:GetActSetting()
	local szImg = tbActSetting.szNotifyUi
	if tbActSetting.szGoldSprite then
		if bGold then
			self.pPanel:Sprite_SetSprite(szImg, tbActSetting.szGoldSprite)	
			self.pPanel:SetActive("texiao_F", true)
			self.pPanel:SetActive("texiao_J", false)
		else
			self.pPanel:Sprite_SetSprite(szImg, tbActSetting.szNormalSprite)	
			self.pPanel:SetActive("texiao_F", false)
			self.pPanel:SetActive("texiao_J", true)
		end
	end
	self.pPanel:SetActive(szImg, true)
	if self.nTimrGetSendBless then
		Timer:Close(self.nTimrGetSendBless)
	end
	self.nTimrGetSendBless = Timer:Register(Env.GAME_FPS * 3, function ( ... )
		self.pPanel:SetActive(szImg, false)
		self.nTimrGetSendBless = nil;
	end)	
	
end

function tbUi:OnClose()
	if self.pPanel:IsActive("BtnChatTeamVoice") then
		local wndTeamVoice = self.pPanel:FindChildTransform("BtnChatTeamVoice");
		if wndTeamVoice then
			local iflyCom = wndTeamVoice:GetComponent("IFlyCom");
			if iflyCom then
				iflyCom:SendMessage("OnPress", false);
			end
		end
	end

	if self.pPanel:IsActive("BtnChatKinVoice") then
		local wndKinVoice = self.pPanel:FindChildTransform("BtnChatKinVoice");
		if wndKinVoice then
			local iflyCom = wndKinVoice:GetComponent("IFlyCom");
			if iflyCom then
				iflyCom:SendMessage("OnPress", false);
			end
		end
	end
end

function tbUi:OnMapLoad()
	self:UpdateAssistState()
	self:UpdateToyState()
end

function tbUi:SetAssistBtnActive(bActive)
	for _, szBtnName in ipairs(self.tbAssistBtn) do
		self.pPanel:SetActive(szBtnName, bActive)
	end
	local bAdjustView = Operation:GetAdjustViewState()
	self.pPanel:SetActive("BtnSetUp", bActive and bAdjustView)
	self.pPanel:SetActive("BtnPhotograph", bActive and bAdjustView)

	local bToyMap = Toy:CanUse(me)
	self.pPanel:ChangePosition("ColorMsgContainer", 0, (bActive or bToyMap) and 55 or 15);
end

function tbUi:UpdateAssistBtn()
	local bAssistMap = Operation:IsAssistMap()
	self:SetAssistBtnActive(bAssistMap)
	self.pPanel:Toggle_SetChecked("BtnLocking", bAssistMap and Operation:GetAdjustViewState());
end

function tbUi:ShowAssistHelpClicker(bShow)
	if bShow then
		self.pPanel:Label_SetText("Name1", Guide.ZHAOLIYING_NAME);
		self.pPanel:Label_SetText("Name2", Guide.ZHAOLIYING_NAME);
		self.pPanel:Label_SetText("Name3", Guide.ZHAOLIYING_NAME);
		self.pPanel:Label_SetText("Name4", Guide.ZHAOLIYING_NAME);
		self.pPanel:Label_SetText("Name5", Guide.ZHAOLIYING_NAME);
		self.nAssistHelpStep = 0;
		self:UpdateAssistHelp();
		Client:SetFlag(Operation.szCameraSettingKey, 1, Operation.nSaveCameraSettingGuide)
		local tbUserSet = Ui:GetPlayerSetting();
		self.pPanel:Button_SetCheck("BtnVoice", tbUserSet.bMuteGuideVoice);
	else
		self.pPanel:SetActive("HelpClicker", false);
	end
end


function tbUi:DoSwitchAssistState(bNotTip)
	Operation:DoSwitchAdjustViewState(bNotTip)
	self:UpdateAssistState()
	Operation:OpenAssistHelpClicker()
end

function tbUi:QuiteAssistState()
	if Operation:CheckAdjustView() then
		Operation:QuiteAssistUiState()
		self:DoSwitchAssistState(true)
	end
end

function tbUi:EnterAssistState()
	if not Operation:CheckAdjustView() then
		self:DoSwitchAssistState(true)
	end
end

function tbUi:UpdateAssistHelp()
	self.nAssistHelpStep = self.nAssistHelpStep + 1;
	if tbAssistHelp[self.nAssistHelpStep] then
		for szWnd, _ in pairs(tbAllAssistHelpWnd) do
			self.pPanel:SetActive(szWnd, tbAssistHelp[self.nAssistHelpStep][szWnd])
		end
	else
		for szWnd, _ in pairs(tbAllAssistHelpWnd) do
			self.pPanel:SetActive(szWnd, false);
		end
	end
end

function tbUi:StartDoubleFlyCountDown()
	self:CloseDoubleFlyTimer()
	self.nDoubleFlyCountDownTime = 0
	self.pPanel:SetActive("texiao111", true);
	self.nDoubleFlyTimer = Timer:Register(1, function ()
		self.nDoubleFlyCountDownTime = self.nDoubleFlyCountDownTime + (1 / Env.GAME_FPS)
		local nRate = self.nDoubleFlyCountDownTime / Wedding.nDoubleFlyWaitTime
		self.pPanel:Sprite_SetFillPercent("BtnTime", nRate);
		if self.nDoubleFlyCountDownTime >= Wedding.nDoubleFlyWaitTime then
			self.pPanel:Sprite_SetFillPercent("BtnTime", 0);
			self.pPanel:SetActive("texiao111", false);
			self.nDoubleFlyTimer = nil
			return false
		end
		return true
	end)
end

function tbUi:CloseDoubleFlyTimer()
	if self.nDoubleFlyTimer then
		Timer:Close(self.nDoubleFlyTimer)
		self.nDoubleFlyTimer = nil
	end
end

function tbUi:OnDoubleFlyBtnChange(bActive)
	self:ShowBtnCoupeDodge(bActive)
end

function tbUi:SetIngredients()
	local tbInfo = Activity.DumplingBanquetAct:GetIngredientsData()
	local tbAct = Activity.DumplingBanquetAct;
	if tbInfo.bFlag == true then
		self.pPanel:Sprite_SetSprite("Ingredients", tbAct.szIngredientSprite[tbInfo.nNpcTemplateId], tbAct.szIngredientAtlas)
		self.pPanel:SetActive("Ingredients", true)
		self.pPanel:Label_SetText("IngredientsName", tbAct.szIngredientName[tbInfo.nNpcTemplateId]);
	else
		self.pPanel:SetActive("Ingredients", false)
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_CHAT_NEW_MSG, self.UpdateChatMsg },
		{ UiNotify.emNOTIFY_SYNC_KIN_DATA, self.UpdateKinButton },
		{ UiNotify.emNoTIFY_NEW_PRIVATE_MSG, self.UpdatePriveMsgNum },
		{ UiNotify.emNOTIFY_PRIVATE_MSG_NUM_CHANGE, self.UpdatePriveMsgNum },
		{ UiNotify.emNOTIFY_CHAT_COLOR_MSG, self.UpdateColorMsg },
		{ UiNotify.emNOTIFY_TEAM_UPDATE, self.UpdateTeamButton },
		{ UiNotify.emNOTIFY_IFLY_IAT_RESULT, self.UpdateTeamButton },
		{ UiNotify.emNOTIFY_NOTIFY_NEW_MAIL, self.UpdatePriveMsgNum },
		{ UiNotify.emNOTIFY_WND_OPENED, self.WndOpened },
		{ UiNotify.emNOTIFY_WND_CLOSED, self.WndClosed },
		{ UiNotify.emNOTIFY_UI_AUTO_HIDE, self.ChangeFightState},
		{ UiNotify.emNOTIFY_NOTIFY_PROCESS_MSG, self.UpdateProcessMsgNum },
		{ UiNotify.emNOTIFY_NEW_REDBAG, self.NewRedBag},
		{ UiNotify.emNOTIFY_SEND_BLESS_CHANGE, self.OnGetSendBless},
		{ UiNotify.emNOTIFY_MAP_LOADED, self.OnMapLoad},
		{ UiNotify.emNOTIFY_VIEW_STATE_CHANGE, self.UpdateAssistState},
		{ UiNotify.emNOTIFY_VIEW_ASSIST_BTN_CHANGE, self.SetAssistBtnActive},
		{ UiNotify.emNOTIFY_DOUBLE_FLY_BTN_CHANGE, self.OnDoubleFlyBtnChange},
		{ UiNotify.emNOTIFY_DOUBLE_FLY_COUNTDOWN, self.StartDoubleFlyCountDown},
		{ UiNotify.emNOTIFY_LOCK_TO_NPC, self.QuiteAssistState},
		{ UiNotify.emNOTIFY_LOCK_TO_NPC_CONFIRM, self.EnterAssistState},
		{ UiNotify.emNOTIFY_CHANGE_MONEY, self.OnMoneyChanged},
		{ UiNotify.emNOTIFY_SETINGREDIENTS, self.SetIngredients, self},
	};

	return tbRegEvent;
end
