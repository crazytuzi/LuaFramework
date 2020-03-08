local tbUI = Ui:CreateClass("RedBagDetailPanel")

tbUI.tbOnClick =
{
    BtnAdd = function(self)
    	self:OpenAddPanel()
    end,

    BtnMinus = function(self)
    	self:AddReceiverCount(-1)
    end,

    BtnPlus = function(self)
    	self:AddReceiverCount(1)
    end,

    BtnGrant = function(self)
    	self:Send()
    end,

    Open = function(self)
    	self:Grab()
    end,

    BtnChange = function(self)
    	if self.tbRedBag.nKind ~= Kin.Def.tbRedBagKind.BOTH then
    		return
    	end
    	self.nCurKind = self.nCurKind == Kin.Def.tbRedBagKind.NORMAL and Kin.Def.tbRedBagKind.VOICE or Kin.Def.tbRedBagKind.NORMAL
    	self:RefreshSend()
    	me.CenterMsg("修改成功")
    end,
}

function tbUI:OnScreenClick()
	if not self.bCanClose then
		return
 	end
    Ui:CloseWindow(self.UI_NAME)
    Kin:RedBagUpdateRedPoint(false)
end

function tbUI:RegisterEvent()
	local tbRegEvent = {
		{ UiNotify.emNOTIFY_REDBAG_SINGLE_UPDATE, self.Refresh, self },
	}

	return tbRegEvent
end

function tbUI:OnOpen(szAction, szId, bAutoGrab, tbRedBag)
	if me.IsInPrison() then
		Log("Open RedBagDetailPanel Fail In prison");
		return 0;
	end

	self.szId = szId
	self.szAction = szAction
	self.bAutoGrab = bAutoGrab and (not Kin:RedBagIsPlayerGrabEnough(me))
	self:InitUI()
	if not tbRedBag then
		local tbDetail = Kin:GetRedBagDetailById(szId)
		if tbDetail then
			self:Refresh(tbDetail)
		end
	else
		tbRedBag.szId = szId;
		self:Refresh(tbRedBag);
	end

	self.bCanClose = false
	Timer:Register(10, function()
		self.bCanClose = true
		return false
	end)
end

function tbUI:InitUI()
	for i= 1, 6 do
		self.pPanel:SetActive(string.format("Panel%d", i), false)
	end
end

function tbUI:RefreshAddBtn()
	local tbAddGoldList = self:GetAddGoldList()
	self.pPanel:SetActive("BtnAdd", #tbAddGoldList>0)
end

function tbUI:Refresh(tbRedBag)
	if not tbRedBag then
		Log("[x] RedBagDetailPanel, unknown szId", self.szId)
		Ui:CloseWindow(self.UI_NAME)
		return
	end
	if tbRedBag.szId~=self.szId then
		Log("[x] RedBagDetailPanel, szId error", self.szId, tbRedBag.szId)
		Ui:CloseWindow(self.UI_NAME)
		return
	end
	self.tbRedBag = tbRedBag
	self.nCurKind = tbRedBag.nKind == Kin.Def.tbRedBagKind.VOICE and Kin.Def.tbRedBagKind.VOICE or Kin.Def.tbRedBagKind.NORMAL
	if tbRedBag.nKind == Kin.Def.tbRedBagKind.FIXED_VOICE then
		self.nCurKind = Kin.Def.tbRedBagKind.FIXED_VOICE
	end

	if self.szAction=="send" then
		self:RefreshSend()
	elseif self.szAction=="viewgrab" then
		local bCanGrab = true
		if tbRedBag.tbRecvData.nCount>=tbRedBag.nMaxReceiver then
			bCanGrab = false
		else
			if tbRedBag.tbRecvData.nMyGrabGold>0 then
				bCanGrab = false
			end
		end

		if bCanGrab then
			self:RefreshGrab()
		else
			self:RefreshView()
			Kin:RedBagUpdateCanGrab(tbRedBag.szId, bCanGrab)
			UiNotify.OnNotify(UiNotify.emNOTIFY_REDBAG_DATA_REFRESH)
		end
	elseif self.szAction == "chat_award" then
		self:RefreshChatAwardView();
	end
end

function tbUI:RefreshSend()
	self:InitUI()

	local tb = self.tbRedBag
	self.pPanel:Label_SetText("TxtMoney", tb.nGold)
	self.pPanel:Label_SetText("TxtNumber", tb.nMaxReceiver)
	self.pPanel:Input_SetText("InputTxt2", "")

	local bBoth = tb.nKind == Kin.Def.tbRedBagKind.BOTH
	self.pPanel:SetActive("ChangeTxt", bBoth)
	self.pPanel:SetActive("BtnChange", bBoth)

	local bVoice = self.nCurKind == Kin.Def.tbRedBagKind.VOICE or self.nCurKind == Kin.Def.tbRedBagKind.FIXED_VOICE
	if bBoth then
		self.pPanel:Label_SetText("ChangeTxt", bVoice and "该红包为语音红包，可改为普通红包" or "该红包为普通红包，可改为语音红包")
	end
	self.pPanel:Label_SetText("Title", bVoice and "语音红包" or "普通红包")
	self.pPanel:SetActive("InputTxt", not bVoice)
	self.pPanel:SetActive("InputTxt2", bVoice)
	if not bVoice then
		local szContent = tb.szContent or Kin:RedBagGetContent(tb)
		self.pPanel:Label_SetText("InputTxt", szContent)
	end
	self.pPanel:Label_SetText("TxtSpend", 0)
	self.pPanel:Label_SetText("TxtHave", me.GetMoney("Gold"))

	self:ShowPanel("Panel1")
	self:RefreshAddBtn()
end

function tbUI:InitHead(pGrid, tbData)
	pGrid.pPanel:SetActive("lbLevel", tbData.nLevel and true or false);
	if tbData.nLevel then
		pGrid.pPanel:Label_SetText("lbLevel", tbData.nLevel)
	end

	pGrid.pPanel:SetActive("SpFaction", tbData.nFaction and true or false);
	if tbData.nFaction then
		local szFactionIcon = Faction:GetIcon(tbData.nFaction)
		pGrid.pPanel:Sprite_SetSprite("SpFaction", szFactionIcon)
	end

	local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbData.nPortrait)
	pGrid.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas)
end

function tbUI:RefreshView()
	self:InitUI()

	local tbRedBag = self.tbRedBag
	local tbOwner = tbRedBag.tbOwner

	local szMarkIcon;
	if tbRedBag.nEventId and tbRedBag.nGold then
		szMarkIcon = Kin:RedBagGetMultiInfo(tbRedBag.nEventId, tbRedBag.nGold);
	end

	self.pPanel:SetActive("Mark", szMarkIcon and true or false);
	if szMarkIcon then
		self.pPanel:Sprite_SetSprite("Mark", szMarkIcon)
	end

	self.pPanel:Label_SetText("Name1", tbRedBag.szTips or string.format("%s的红包", tbOwner.szName))

	local szContent = tbRedBag.szContent or Kin:RedBagGetContent(tbRedBag)
	self.pPanel:Label_SetText("Content1", szContent)
	self:InitHead(self.Head1, tbOwner)

	local szDesc = ""
	local nReceivedCount = tbRedBag.tbRecvData.nCount
	local bEmpty = nReceivedCount>=tbRedBag.nMaxReceiver
	if not bEmpty then
		local nReceivedGold = tbRedBag.tbRecvData.nReceivedGold
		szDesc = string.format("已领取[FFFE0D]%d/%d[-]个，共[FFFE0D]%d/%d#999[-]", tbRedBag.nCurrentReceiver or nReceivedCount, tbRedBag.nMaxReceiver, nReceivedGold, tbRedBag.nGold)
	else
		szDesc = string.format("[FFFE0D]%d个[-]红包共[FFFE0D]%d#999[-]，已被抢完", tbRedBag.nMaxReceiver, tbRedBag.nGold)
	end
	self.pPanel:Label_SetText("Txt1", szDesc)
	local bGlobal = Kin:RedBagIsIdGlobal(self.tbRedBag.szId)
	self.pPanel:SetActive("ReceiveDetails", not bGlobal)
	self.pPanel:SetActive("ReceiveDetails2", bGlobal)

	local nGrabGold = tbRedBag.tbRecvData.nMyGrabGold
	self.pPanel:SetActive("GetMoney", false)
	self.pPanel:SetActive("NoMoney", false)
	if nGrabGold>0 then
		self.pPanel:Label_SetText("GetMoney", nGrabGold)
		self.pPanel:SetActive("GetMoney", true)
	else
		self.pPanel:SetActive("NoMoney", true)
	end

	self.GetRedPaperScrollView:Update(math.min(nReceivedCount, Kin.Def.nRedBagReceiverShowCount), function(pGrid, nIdx)
		local tbReceiver = tbRedBag.tbRecvData.tbTop[nIdx]
		pGrid.pPanel:Label_SetText("Name", tbReceiver.szName)
		pGrid.pPanel:Label_SetText("Money", string.format("%d#999", tbReceiver.nGold))
		pGrid.pPanel:SetActive("Best", nIdx==1 and bEmpty)

		self:InitHead(pGrid.Head, tbReceiver)
	end)

	self:ShowPanel("Panel3")
end

function tbUI:IsPasswordMatch(szVoice, szAnswer)
	local tbVoice = Lib:GetUft8Chars(szVoice)
	tbVoice[#tbVoice] = nil
	local tbAnswer = Lib:GetUft8Chars(szAnswer)

	if math.abs(#tbVoice - #tbAnswer) > #tbAnswer * Kin.Def.nVoicePwdLenDelta then
		return false
	end

	local nMaxErr = #tbAnswer * Kin.Def.nVoicePwdCharDelta
	local nErr = 0
	for _, szChar in ipairs(tbAnswer) do
		if not Lib:IsInArray(tbVoice, szChar) then
			nErr = nErr + 1
			if nErr > nMaxErr then
				return false
			end
		end
	end
	return true
end

function tbUI:InitBtnVoiceInput()
	local fnCallback = function (szMsg,uFileIdHigh,uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
		if szMsg ~= "" then
			if self:IsPasswordMatch(szMsg, self.tbRedBag.szVoicePwd) then
				self:Grab()
			else
				me.CenterMsg("语音口令不正确，请重试")
			end
			szMsg = ChatMgr:CutMsg(szMsg)
			local bGlobal = Kin:RedBagIsIdGlobal(self.tbRedBag.szId)
			if bGlobal then
				ChatMgr:SendMsg(ChatMgr.ChannelType.Public, szMsg, true, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
			else
				ChatMgr:SendMsg(ChatMgr.ChannelType.Kin, szMsg, true, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
			end
		end
	end

	local fnCheckVoiceSend = function ()
		return true
	end

	local nVoiceTime = ChatMgr:GetMaxVoiceTime(ChatMgr.ChannelType.Kin)
	self.pPanel:FlyCom_Init("Voice", fnCallback, fnCheckVoiceSend, nVoiceTime);
end

function tbUI:RefreshGrab()
	self:InitUI()

	local tbRedBag = self.tbRedBag
	local tbOwner = tbRedBag.tbOwner

	if self.nCurKind == Kin.Def.tbRedBagKind.VOICE then
		self:InitBtnVoiceInput()
		self.pPanel:Label_SetText("Name6", string.format("%s的红包", tbOwner.szName))

		self.pPanel:Label_SetText("Content6", string.format("“%s”", tbRedBag.szVoicePwd or ""))
		self:InitHead(self.Head6, tbOwner)
		self.pPanel:Button_SetEnabled("Voice", true)

		self:ShowPanel("Panel6")
	elseif self.nCurKind == Kin.Def.tbRedBagKind.FIXED_VOICE then
		self:InitBtnVoiceInput()
		self.pPanel:Label_SetText("Name6", string.format("%s的红包", tbOwner.szName))

		self.pPanel:Label_SetText("Content6", "")
		self:InitHead(self.Head6, tbOwner)
		self.pPanel:Button_SetEnabled("Voice", true)

		self:ShowPanel("Panel6")
	else
		self.pPanel:Label_SetText("Name2", string.format("%s的红包", tbOwner.szName))

		local szContent = tbRedBag.szContent or Kin:RedBagGetContent(tbRedBag)
		self.pPanel:Label_SetText("Content2", szContent)
		self:InitHead(self.Head2, tbOwner)

		self.pPanel:Button_SetEnabled("Open", true)
		self:ShowPanel("Panel4")
	end

	self.bAutoGrab = self.bAutoGrab and tbRedBag.nKind == Kin.Def.tbRedBagKind.NORMAL
	if self.bAutoGrab then
		self:Grab()
	end
end

function tbUI:RefreshChatAwardView()
	local tbRedBag = self.tbRedBag

	if tbRedBag.szSprite and tbRedBag.szSprite ~= "" then
		self.pPanel:Sprite_SetSprite("TitleSprite5", tbRedBag.szSprite);
	end

	self.pPanel:Label_SetText("Name5", tbRedBag.szTips or "发布会红包");
	self.pPanel:Label_SetText("Content5", tbRedBag.szContent or "口令：剑手真好玩");
	self.pPanel:Label_SetText("GetMoney5", tbRedBag.tbReceivers[1].nGold);

	local nReceivedCount = tbRedBag.nCurrentReceiver;
	local bEmpty = nReceivedCount>=tbRedBag.nMaxReceiver;
	self.GetRedPaperScrollView5:Update(math.min(nReceivedCount, Kin.Def.nRedBagReceiverShowCount), function(pGrid, nIdx)
		local tbReceiver = tbRedBag.tbReceivers[nIdx]
		pGrid.pPanel:Label_SetText("Name", tbReceiver.szName)
		pGrid.pPanel:Label_SetText("Money", string.format("%d#999", tbReceiver.nGold))
		pGrid.pPanel:SetActive("Best", false);
		self:InitHead(pGrid.Head, tbReceiver);
	end)
	self:ShowPanel("Panel5");
end

function tbUI:ShowPanel(szPanel)
	local bGlobal = Kin:RedBagIsIdGlobal(self.tbRedBag.szId)
	self.pPanel:Texture_SetTexture(szPanel, bGlobal and "UI/Textures/RedPaper5.png" or "UI/Textures/RedPaper1.png")
	self.pPanel:SetActive(szPanel, true)
end

function tbUI:GetAddGoldList()
	local tbAddGoldList = {}
	local nEventId = self.tbRedBag.nEventId
	if not nEventId or nEventId<=0 then
		return tbAddGoldList
	end

	local tbSetting = Kin.tbRedBagSettings[nEventId]
	local nVip = me.GetVipLevel()
	for _, nAdd in ipairs(tbSetting.tbAddGoldList) do
		if not Kin:RedBagIsMultiValid(nVip, self.tbRedBag.nGold, nAdd) then
			break
		end
		table.insert(tbAddGoldList, nAdd)
	end
	return tbAddGoldList
end

function tbUI:OpenAddPanel()
	local tbAddGoldList = self:GetAddGoldList()

	self.tbAddGoldToggles = {}
	self.AddMoneyScrollView:Update(#tbAddGoldList+1, function(pGrid, nIdx)
		table.insert(self.tbAddGoldToggles, pGrid.Toggle.pPanel)

		local bFirst = nIdx==1
		pGrid.pPanel:SetActive("NotAdd", bFirst)
		pGrid.pPanel:SetActive("Add", not bFirst)

		pGrid.pPanel:SetActive("Mark", false)
		local nAddGold = tbAddGoldList[nIdx-1]
		if not bFirst then
			pGrid.pPanel:Label_SetText("Number", nAddGold)

			local szMarkIcon = Kin:RedBagGetMultiInfo(self.tbRedBag.nEventId, nAddGold+self.tbRedBag.nGold)
			if szMarkIcon then
				pGrid.pPanel:SetActive("Mark", true)
				pGrid.pPanel:Sprite_SetSprite("Mark", szMarkIcon)
			end
		end
		pGrid.Toggle.pPanel:Toggle_SetChecked("Main", bFirst)
		pGrid.Toggle.pPanel.OnTouchEvent = function()
			local nAdd = bFirst and 0 or nAddGold
			if not Kin:RedBagIsMultiValid(me.GetVipLevel(), self.tbRedBag.nGold, nAdd) then
				pGrid.Toggle.pPanel:Toggle_SetChecked("Main", false)
				me.CenterMsg("剑侠V等级不足")
				return
			end
			for _,pToggle in ipairs(self.tbAddGoldToggles) do
				pToggle:Toggle_SetChecked("Main", false)
			end
			pGrid.Toggle.pPanel:Toggle_SetChecked("Main", true)

			self.pPanel:Label_SetText("TxtMoney", self.tbRedBag.nGold+nAdd)
			self.pPanel:Label_SetText("TxtSpend", nAdd)

			self.pPanel:Label_SetText("TxtNumber", self.tbRedBag.nMaxReceiver)
		end
	end)
	self.pPanel:SetActive("Panel2", true)
end

function tbUI:AddReceiverCount(nAdd)
	local bGlobal = Kin:RedBagIsIdGlobal(self.tbRedBag.szId)
	local nEventId = self.tbRedBag.nEventId
	if bGlobal or not nEventId or nEventId<=0 then
		me.CenterMsg("此红包不可修改个数")
		return
	end

	local nAddGold = tonumber(self.pPanel:Label_GetText("TxtSpend"))
	local nCurCount = tonumber(self.pPanel:Label_GetText("TxtNumber"))
	local nAfterCount = math.max(nCurCount+nAdd, 1)
	local bValid, szErr = Kin:RedBagIsModifyValid(nEventId, nAddGold, nAfterCount, me.GetVipLevel())
	if not bValid then
		me.CenterMsg(szErr)
		return
	end

	self.pPanel:Label_SetText("TxtNumber", nAfterCount)
end

function tbUI:Send()
	local nAddGold = tonumber(self.pPanel:Label_GetText("TxtSpend"))
	local nCurCount = tonumber(self.pPanel:Label_GetText("TxtNumber"))
	local bValid, szErr = Kin:RedBagIsModifyValid(self.tbRedBag.nEventId, nAddGold, nCurCount, me.GetVipLevel())
	if not bValid then
		me.CenterMsg(szErr)
		return
	end

	local szVoicePwd = nil
	if self.nCurKind == Kin.Def.tbRedBagKind.VOICE then
		szVoicePwd = self.pPanel:Input_GetText("InputTxt2")
	end

	local bOk, szErr = Kin:RedBagSend(self.szId, nAddGold, nCurCount, self.nCurKind, szVoicePwd)
	if not bOk then
		me.CenterMsg(szErr)
		return
	end
	Ui:CloseWindow(self.UI_NAME)
	Ui:CloseWindow("RedBagPanel")
	Ui:CloseWindow("KinDetailPanel")
	local bGlobal = Kin:RedBagIsIdGlobal(self.tbRedBag.szId)
	Ui:OpenWindow("ChatLargePanel", bGlobal and ChatMgr.ChannelType.Public or ChatMgr.ChannelType.Kin)
end

function tbUI:Grab()
	Kin:RedBagGrab(self.szId)
	self.pPanel:Button_SetEnabled("Voice", false)
	self.pPanel:Button_SetEnabled("Open", false)
end