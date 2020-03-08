local tbUi = Ui:CreateClass("NewYearQAMainPanel")
tbUi.TAB_SET    = 1
tbUi.TAB_ANSWER = 2

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_NEWYEAR_QA_ACT, self.OnNotify, self },
    };

    return tbRegEvent;
end

function tbUi:OnOpenEnd(nTab)
	self.nTab = nTab or self.nTab
	self:UpdateTab()
	self:UpdateContent()

	local szTitle = Activity.NewYearQAAct:GetValue("szMailTitle")
	self.pPanel:Label_SetText("Title", szTitle)
	Activity:SetRedPointShow("AnniversaryQAAct")
	Activity:CheckRedPointShowAnn2()
end

function tbUi:OnNotify(...)
	self:_OnNotify(...)
end

function tbUi:_OnNotify(...)
	if self.nTab == self.TAB_ANSWER then
		self:UpdateQuestionList(...)
	end
end

function tbUi:SetQuestion()
	self.nTab = self.TAB_SET
	self:UpdateTab()
	self:UpdateContent()
end

function tbUi:Answer()
	self.nTab = self.TAB_ANSWER
	self:UpdateTab()
	self:UpdateContent()
end

function tbUi:UpdateTab()
	if not self.nTab then
		if Activity.NewYearQAAct:IsCanSetQuestion() then
			self.nTab = self.TAB_SET
		else
			self.nTab = self.TAB_ANSWER
		end
	end
	self.pPanel:SetActive("ProposeQuestion", self.nTab == self.TAB_SET)
	self.pPanel:SetActive("QuestionAnswering", self.nTab == self.TAB_ANSWER)
	self.pPanel:Toggle_SetChecked("BtnCareerPage", self.nTab == self.TAB_SET)
	self.pPanel:Toggle_SetChecked("BtnTitlePage", self.nTab == self.TAB_ANSWER)
end

function tbUi:UpdateContent()
	if self.nTab == self.TAB_SET then
		local bCanSet = Activity.NewYearQAAct:IsCanSetQuestion() or false
		self.pPanel:SetActive("FriendPicture", bCanSet)
		self.pPanel:SetActive("Subject", not bCanSet)
		self.pPanel:SetActive("BtnOrdinary", bCanSet)
		local szTitle = "看看谁是真朋友"
		if not bCanSet then
			local tbQ, bCostGold = Activity.NewYearQAAct:GetMyQuestion()
			for nIdx, tbInfo in ipairs(tbQ) do
				local tbQInfo = Activity.NewYearQAAct:GetQInfo(tbInfo[1])
				self.pPanel:Label_SetText("ProblemTxt" .. nIdx, nIdx .. "." .. string.format(tbQInfo.szTitle, "你"))
				self.pPanel:Label_SetText("AnswerTxt" .. nIdx, "答案：" .. tbQInfo["szA" .. tbInfo[2]])
			end
			szTitle = "我本轮的题目"
			if bCostGold then
				szTitle = szTitle .. "[FFFE0D]【高级出题】"
			end
		end
		self.pPanel:Label_SetText("Label2", szTitle)
	elseif self.nTab == self.TAB_ANSWER then
		self:UpdateQuestionList()
	end
end

function tbUi:UpdateQuestionList(tbQList)
	local tbList = tbQList or Activity.NewYearQAAct:GetQuestionList() or {}
	local bHave = #tbList > 0
	self.pPanel:SetActive("NoQuestion", not bHave)
	self.pPanel:SetActive("Complete", bHave)
	self.pPanel:SetActive("ScrollView", bHave)
	local nLastTimes = Activity.NewYearQAAct:GetLastRefreshQTimes()
	self.pPanel:SetActive("Consume", nLastTimes > 0 and bHave)
	self.pPanel:SetActive("BtnNext", nLastTimes > 0 and bHave)
	if bHave then
		local nAll = Activity.NewYearQAAct.nDayMoneyRefresh + 1
		local bComplete = true
		for _, tbInfo in pairs(tbList) do
			if not tbInfo.nChooseAnswer then
				bComplete = false
				break
			end
		end
		local nComplete = bComplete and nAll - nLastTimes or nAll - nLastTimes - 1
		self.pPanel:Label_SetText("CompleteTxt2", string.format("%d/%d", nComplete, nAll))
		self.pPanel:Label_SetText("ConsumeTxt2", Activity.NewYearQAAct.nRefreshQuestionGold)
	end
	if bHave then
		local fnSetItem = function (itemObj, nIdx)
			local tbInfo = tbList[nIdx]
			local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbInfo.nPortrait)
			itemObj.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas)
			itemObj.pPanel:SetActive("SpFaction", tbInfo.nFaction or false)
			if tbInfo.nFaction then
				itemObj.pPanel:Sprite_SetSprite("SpFaction", Faction:GetIcon(tbInfo.nFaction))
			end
			itemObj.pPanel:Label_SetText("lbLevel", tbInfo.nLevel)
			itemObj.pPanel:Label_SetText("TxtCaptainName", tbInfo.szName)
			local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbInfo.nHonorLevel)
			itemObj.pPanel:SetActive("PlayerTitle", ImgPrefix or false)
			if ImgPrefix then
				itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas)
			end
			itemObj.pPanel:SetActive("BtnApply", not tbInfo.nChooseAnswer)
			itemObj.pPanel:SetActive("Completed", tbInfo.nChooseAnswer or false)
			if not tbInfo.nChooseAnswer then
				itemObj.BtnApply.pPanel.OnTouchEvent = function ()
					if tbInfo.nPlayerId > 0 then
						if Activity.NewYearQAAct.nViewRoleTimer then
							Timer:Close(Activity.NewYearQAAct.nViewRoleTimer)
							Activity.NewYearQAAct.nViewRoleTimer = nil
						end
						Activity.NewYearQAAct.nViewRoleTimer = Timer:Register(Env.GAME_FPS * 3, function ()
							Activity.NewYearQAAct.nViewRoleTimer = nil
							Ui:OpenWindow("NewYearQAAnswerPanel", nil, nil, nil, nil, tbInfo)
						end)
						ViewRole:OpenWindow("NewYearQAAnswerPanel", tbInfo.nPlayerId, tbInfo)
					else
						Ui:OpenWindow("NewYearQAAnswerPanel", nil, nil, nil, nil, tbInfo)
					end
				end
			end
		end
		self.ScrollView:Update(#tbList, fnSetItem)
	end
end

function tbUi:RefreshQA()
	local nLastTimes = Activity.NewYearQAAct:GetLastRefreshQTimes()
	if nLastTimes > 0 then
		local nCost = Activity.NewYearQAAct.nRefreshQuestionGold
		if me.GetMoney("Gold") < nCost then
			me.CenterMsg("元宝不足！")
			me.CallClientScript("Ui:OpenWindow", "CommonShop", "Recharge", "Recharge")
		else
			local fnAgree = function ()
				RemoteServer.NewYearQAClientCall("TryRefreshQuestion")
			end
			local szMsg = string.format("确定消耗[eebb01]%d元宝[-]刷新下一套题吗？同意后如本套题未完成，已完成部分奖励将不能再获得", nCost)
			me.MsgBox(szMsg, {{"同意", fnAgree}, {"取消"}})
		end
	else
	end
end

tbUi.tbOnClick = {}
tbUi.tbOnClick.BtnCareerPage = function (self)
	self:SetQuestion()
end
tbUi.tbOnClick.BtnTitlePage = function (self)
	self:Answer()
end
tbUi.tbOnClick.BtnOrdinary = function (self)
	Activity.NewYearQAAct:TryBeginQuestion()
end
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end
tbUi.tbOnClick.BtnNext = function (self)
	self:RefreshQA()
end

local tbAnsUi = Ui:CreateClass("NewYearQAAnswerPanel")
function tbAnsUi:OnOpenEnd(tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole, tbQA)
	if Activity.NewYearQAAct.nViewRoleTimer then
		Timer:Close(Activity.NewYearQAAct.nViewRoleTimer)
		Activity.NewYearQAAct.nViewRoleTimer = nil
	end
	self.tbQA = tbQA
	self.bOpenNpcView = false

	if tbQA.nResId then
		self.pPanel:NpcView_Open("PartnerView")
		self.pPanel:NpcView_ShowNpc("PartnerView", tbQA.nResId)
		local tbPos = Npc.tbTaskDialogModelPos[tbQA.nResId] or Npc.tbTaskDialogModelPos[0]
		self.pPanel:NpcView_SetModePos("PartnerView", unpack(tbPos))
		self.bOpenNpcView = true
		self.pPanel:NpcView_SetScale("PartnerView", 1)
	elseif tbEquip and tbNpcRes and pAsyncRole then
		local tbEffectRest = {}
		for nI = 0, Npc.NpcResPartsDef.npc_res_part_count - 1 do
			tbEffectRest[nI] = 0
		end

		local nLightID = pAsyncRole.GetOpenLight()
		local nFaction = pAsyncRole.GetFaction()
		local nSex = Player:Faction2Sex(nFaction, pAsyncRole.GetSex())
		if nLightID > 0 then
			tbEffectRest[Npc.NpcResPartsDef.npc_part_weapon] = OpenLight:GetFactionEffectByLight(nLightID, nFaction, nSex)
		end

		self.pPanel:NpcView_Open("PartnerView", nFaction or me.nFaction)

		local tbPlayerInfo = KPlayer.GetPlayerInitInfo(nFaction, nSex) or {}
		if tbPlayerInfo.nBodyResId and tbPlayerInfo.nBodyResId > 0 then
			tbNpcRes[Npc.NpcResPartsDef.npc_part_body] = tbPlayerInfo.nBodyResId
		end
		if tbPlayerInfo.nHeadResId and tbPlayerInfo.nHeadResId > 0 then
			tbNpcRes[Npc.NpcResPartsDef.npc_part_head] = tbPlayerInfo.nHeadResId
		end

		if tbEquip[Item.EQUIPPOS_HEAD] then
			local pItem = KItem.GetItemObj(tbEquip[Item.EQUIPPOS_HEAD])
			if pItem then
				local _, _, _, _, nRes = Item:GetItemTemplateShowInfo(pItem.dwTemplateId, nFaction, nSex)
				if nRes ~= 0 then
					tbNpcRes[Npc.NpcResPartsDef.npc_part_head] = nRes
				end
			end
		end

	    if tbEquip[Item.EQUIPPOS_WAIYI] then
	        local pItem = KItem.GetItemObj(tbEquip[Item.EQUIPPOS_WAIYI])
	        if pItem then
	            local nRes = Item.tbChangeColor:GetWaiZhuanRes(pItem.dwTemplateId, nFaction, nSex)
	            if nRes ~= 0 then
	                tbNpcRes[Npc.NpcResPartsDef.npc_part_body] = nRes
	            end
	        end
	    end
	    
	    if tbEquip[Item.EQUIPPOS_WAI_WEAPON] then
	        local pItem = KItem.GetItemObj(tbEquip[Item.EQUIPPOS_WAI_WEAPON])
	        if pItem then
	            local nRes = Item.tbChangeColor:GetWaiZhuanRes(pItem.dwTemplateId, nFaction, nSex)
	            if nRes ~= 0 then
	                tbNpcRes[Npc.NpcResPartsDef.npc_part_weapon] = nRes
	            end
	        end
	    end
	    if tbEquip[Item.EQUIPPOS_WAI_HEAD] then
	        local pItem = KItem.GetItemObj(tbEquip[Item.EQUIPPOS_WAI_HEAD])
	        if pItem then
	            local nRes = Item.tbChangeColor:GetWaiZhuanRes(pItem.dwTemplateId, nFaction, nSex)
	            if nRes ~= 0 then
	                tbNpcRes[Npc.NpcResPartsDef.npc_part_head] = nRes
	            end
	        end
	    end

	    self:ChangeFeature(tbNpcRes, tbEffectRest)

	    local tbPos = Npc.tbTaskDialogModelPos[0]
		self.pPanel:NpcView_SetModePos("PartnerView", unpack(tbPos))


    	local tbFactionScale = Ui:CreateClass("ItemBox").tbFactionScale   -- 贴图缩放比例
    	local fScale = tbFactionScale[nFaction] or 1
    	self.pPanel:NpcView_SetScale("PartnerView", fScale)
		self.bOpenNpcView = true
	end

	local tbInfo
	if tbQA.nPlayerId > 0 then
		tbInfo = Activity.NewYearQAAct:GetQInfo(tbQA.nTitle)
	else
		tbInfo = Activity.NewYearQAAct:GetDefaultQInfo(tbQA.nTitle)
	end
	local szTitle = string.format(tbInfo.szTitle, tbQA.szName)
	if tbQA.bCostGold then
		szTitle = szTitle .. "[FFFE0D]【高级答题】"
	end
	self.pPanel:Label_SetText("ProblemTxt1", szTitle)
	for i = 1, 4 do
		self.pPanel:Toggle_SetChecked("AnswerName" .. i, false)
		self["AnswerName" .. i].pPanel:Label_SetText("AnswerTxt" .. i, tbInfo["szA" .. tbQA.tb4Choose[i]])
	end
end

function tbAnsUi:ChangeFeature(tbNpcRes, tbEffectRest)
    local tbCopyNpcRes = Lib:CopyTB(tbNpcRes);
    for nI = 0, Npc.NpcResPartsDef.npc_res_part_count - 1 do
        if not tbCopyNpcRes[nI] then
            tbCopyNpcRes[nI] = 0;
        end
    end
    tbCopyNpcRes[Npc.NpcResPartsDef.npc_part_horse] = 0

    for nPartId, nResId in pairs(tbCopyNpcRes) do
        self.pPanel:NpcView_ChangePartRes("PartnerView", nPartId, nResId);
    end

    tbEffectRest = tbEffectRest or {};
    for nPartId, nResId in pairs(tbEffectRest) do
        self.pPanel:NpcView_ChangePartEffect("PartnerView", nPartId, nResId);
    end
end

function tbAnsUi:OnClose()
	if self.bOpenNpcView then
		self.pPanel:NpcView_Close("PartnerView")
	end
end

function tbAnsUi:Choose(nIdx)
	RemoteServer.NewYearQAClientCall("TryAnswer", self.tbQA.nQuestionId, self.tbQA.tb4Choose[nIdx])
	Ui:CloseWindow(self.UI_NAME)
end

tbAnsUi.tbOnClick = {}
tbAnsUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

for i = 1, 4 do
	tbAnsUi.tbOnClick["AnswerName" .. i] = function (self)
		self:Choose(i)
	end
end

local tbSetUi = Ui:CreateClass("NewYearQASetPanel")
function tbSetUi:OnOpenEnd(tbAskInfo)
	local szTitle = Activity.NewYearQAAct:GetValue("szMailTitle")
	self.pPanel:Label_SetText("Label4", szTitle)
	self.pPanel:Label_SetText("ConsumeProposeTxt2", Activity.NewYearQAAct.nSetQuestionGold)
	
	self.tbAnswer = self.tbAnswer or {}
	for i = 1, Activity.NewYearQAAct.nQuestionNum do
		local nQId   = tbAskInfo.tbQuestion[i].nTitle
		local tbInfo = Activity.NewYearQAAct:GetQInfo(nQId)
		self.pPanel:Label_SetText("ProblemTxt" .. i, string.format(tbInfo.szTitle, "你"))
		for j = 1, Activity.NewYearQAAct.nAnswerCount do
			local szLabel = string.format("Answer%dTxt%d", i, j)
			self["Answer" .. i .. "Name" .. j].pPanel:Label_SetText(szLabel, tbInfo["szA" .. j])
			self["Answer" .. i .. "Name" .. j].pPanel.OnTouchEvent = function ()
				self:SetAnswer(i, j)
			end
		end
	end
end

function tbSetUi:SetAnswer(nQIdx, nAnswer)
	self.tbAnswer[nQIdx] = nAnswer
end

function tbSetUi:Submit(bCostGold)
	if #self.tbAnswer == Activity.NewYearQAAct.nQuestionNum then
		local fnAgree = function ()
			RemoteServer.NewYearQAClientCall("TrySetQuestion", Activity.NewYearQAAct:GetRound(), self.tbAnswer, bCostGold)
		end
		if bCostGold then
			local nCost = Activity.NewYearQAAct.nSetQuestionGold
			if me.GetMoney("Gold") < nCost then
				me.CenterMsg("元宝不足！")
				me.CallClientScript("Ui:OpenWindow", "CommonShop", "Recharge", "Recharge")
				return
			else
				local szMsg = string.format("选择高级提问，您的好友回答您的问题会获得更精美的礼盒，回答正确您还能获得[eebb01]1000贡献[-]及与对应好友更高的亲密度奖励。确定消耗[eebb01]%d元宝[-]进行高级提问吗？", nCost)
				me.MsgBox(szMsg, {{"同意", fnAgree}, {"取消"}})
			end
		else
			me.MsgBox("选择高级提问，您的好友回答您的问题会获得更加精美的礼盒，回答正确您还能获得[eebb01]1000贡献[-]及与对应好友更高的亲密度奖励。是否仍然选择普通提问？", {{"同意", fnAgree}, {"取消"}})
		end
	else
		me.CenterMsg("您有未选择答案的问题！")
	end
end

tbSetUi.tbOnClick = {}
tbSetUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

tbSetUi.tbOnClick.BtnOrdinary = function (self)
	self:Submit()
end

tbSetUi.tbOnClick.BtnPay = function (self)
	self:Submit(true)
end

local tbRBUi = Ui:CreateClass("NewYearQARedbagPanel")
function tbRBUi:OnOpenEnd()
	self:CloseTimer()
	self.nCloseTimer = Timer:Register(Env.GAME_FPS * 7, function ()
		self.nCloseTimer = nil
		Ui:CloseWindow(self.UI_NAME)
	end)
end

function tbRBUi:CloseTimer()
	if self.nCloseTimer then
		Timer:Close(self.nCloseTimer)
		self.nCloseTimer = nil
	end
end

function tbRBUi:OnClose()
	self:CloseTimer()
end