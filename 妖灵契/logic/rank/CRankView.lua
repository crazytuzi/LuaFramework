local CRankView = class("CRankView", CViewBase)

function CRankView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Rank/RankView.prefab", ob)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_IsAlwaysShow = true
end

function CRankView.OnCreateView(self)
	self.m_ScrollView = self:NewUI(1, CRecyclingScrollView)
	self.m_Cell = self:NewUI(2, CRankCellBox, true, self)
	self.m_TabBtnTable = self:NewUI(3, CTable)
	self.m_TabBtn = self:NewUI(4, CBox)
	self.m_ClostBtn = self:NewUI(5, CButton)
	self.m_PlayerInfoSlot = self:NewUI(6, CBox)
	self.m_RefreshInfoLabel = self:NewUI(7, CLabel)
	self.m_LocationPopupBox = self:NewUI(8, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, 1, true)
	self.m_TitlePart = self:NewUI(9, CBox)
	self.m_TitleLabel = self:NewUI(10, CLabel)
	self.m_GetingDataSprite = self:NewUI(11, CBox)
	self.m_ScrollWidget = self:NewUI(12, CWidget)
	self.m_RankListPart = self:NewUI(13, CWidget)
	self.m_CountingTips = self:NewUI(14, CLabel)
	self.m_ChildTabBtn = self:NewUI(15, CBox)
	self.m_PlayerInfoBox = self:NewUI(16, CRankCellBox, true, self)
	self.m_PartnerBtn = self:NewUI(17, CBox)
	self.m_PartnerListPart = self:NewUI(18, CTimeLimitPartnerPart)
	self.m_MyPartnerRankBtn = self:NewUI(19, CButton)
	self.m_HelpBtn = self:NewUI(20, CButton)

	self.m_TabBtnArr = {}
	self.m_RankIdToBtn = {}
	self.m_TitleArr = {}
	self.m_TitleArr[1] = self.m_TitleLabel
	self.m_CurrentTabBtn = nil
	self.m_Data = {}
	self.m_ExtraData = {}
	self.m_ChildScale = Vector3.New(1, 1, 1)
	self.m_TabData = data.rankdata.RankType
	self.m_TypeSort = data.rankdata.RankTypeSort
	self:InitContent()
end

function CRankView.InitContent(self)
	self:InitPartnerBox()
	
	self.m_PartnerListPart:SetClickCb(callback(self, "OnSelectPartner"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_PartnerBtn:AddUIEvent("click", callback(self, "OnClickPartner"))
	self.m_MyPartnerRankBtn:AddUIEvent("click", callback(self, "OnClickMyPartnerRank"))
	self.m_LocationPopupBox:SetRepositionWhenOpen(true)
	self.m_TitleLabel:SetActive(false)
	self.m_ClostBtn:AddUIEvent("click", callback(self, "OnClose"))
	self:SetTabBtnData()
	self.m_TabBtn:SetActive(false)
	self.m_ChildTabBtn:SetActive(false)
	self:PlayCellInit()
	g_RankCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	self.m_Cell:SetActive(false)
	self.m_PartnerListPart:SetHideCb(function ()
		self.m_PartnerBtn.m_TweenObj:Toggle()
	end)
end

function CRankView.OnClickHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("partner_rank")
	end)
end

function CRankView.InitPartnerBox(self)
	local oPartnerBox = self.m_PartnerBtn
	oPartnerBox.m_NameLabel = oPartnerBox:NewUI(1, CLabel)
	oPartnerBox.m_TweenSprite = oPartnerBox:NewUI(2, CSprite)
	oPartnerBox.m_TweenObj = oPartnerBox.m_TweenSprite:GetComponent(classtype.TweenRotation)
end

function CRankView.OnSelectPartner(self, iPartner)
	g_RankCtrl:GetDataFromServer(self.m_CurrentRankId, 1, iPartner)
end

function CRankView.OnClickPartner(self)
	self.m_PartnerBtn.m_TweenObj:Toggle()
	self.m_PartnerListPart:SetActive(true)
	self.m_PartnerListPart:OnSelectPartner(self.m_PartnerType)
end

function CRankView.OnClickMyPartnerRank(self)
	netrank.C2GSPartnerRank(define.Rank.SubType.Common)
end

function CRankView.PlayCellInit(self)
	-- self.m_PlayerInfoBox = self.m_Cell:Clone()
	-- self.m_PlayerInfoBox:SetParent(self.m_PlayerInfoSlot.m_Transform)
	-- self.m_PlayerInfoBox:SetLocalPos(Vector3.zero)
	self:CellInit(self.m_PlayerInfoBox)
	self.m_PlayerInfoBox:SetActive(false)
end

function CRankView.SetLocation(self, oBox)
	self.m_Location = oBox:GetSelectedSubMenu().m_ExtraData
	local page = math.ceil(oBox:GetSelectedSubMenu().m_ExtraData / self.m_RankInfo.per_page)
	if g_RankCtrl:GetDataFromServer(self.m_CurrentRankId, page, self.m_PartnerType) then
		self:ShowGettingData(page)
	end
end

function CRankView.SetTitle(self, rankListId)
	local titleList = data.rankdata.DATA[rankListId].attribute
	local xposList = self.m_RankInfo.head_xpos
	local count = 0
	for i=1,#titleList do
		if titleList[i] ~= 6 and titleList[i] ~= 17 and titleList[i] ~= 18 and titleList[i] ~= 22 then
			count = count + 1
			if self.m_TitleArr[count] == nil then
				self.m_TitleArr[count] = self.m_TitleLabel:Clone()
				self.m_TitleArr[count]:SetParent(self.m_TitlePart.m_Transform)
			end
			self.m_TitleArr[count]:SetActive(true)
			self.m_TitleArr[count]:SetText(data.rankdata.Attribute[titleList[i]].name)
			self.m_TitleArr[count]:SetLocalPos(Vector3.New(xposList[count],0,0))
		end
	end
	count = count + 1
	for i = count,#self.m_TitleArr do
		self.m_TitleArr[i]:SetActive(false)
	end
	self.m_TitleArr[1]:SetActive(rankListId ~= define.Rank.RankId.Partner)
	self.m_HelpBtn:SetActive(rankListId == define.Rank.RankId.Partner)
end

function CRankView.CreateTabBtn(self, oBtn)
	local oTabBtn = oBtn:Clone("oTabBtn")
	oTabBtn.m_Btn = oTabBtn:NewUI(1, CButton)
	oTabBtn.m_Label = oTabBtn:NewUI(2, CLabel)
	oTabBtn.m_OnSelectLabel = oTabBtn:NewUI(3, CLabel)
	oTabBtn.m_OnSelect = oTabBtn:NewUI(4, CBox)

	self.m_TabBtnTable:AddChild(oTabBtn)
	oTabBtn.m_Btn:AddUIEvent("click", callback(self, "OnClickTabBtn", oTabBtn))
	function oTabBtn.SetData(self, data, isNode, name)
		oTabBtn.m_Data = data
		oTabBtn.m_id = data.id
		oTabBtn.m_IsNode = isNode
		if name ~= nil then
			oTabBtn.m_Label:SetText(name)
			oTabBtn.m_OnSelectLabel:SetText(name)
		else
			oTabBtn.m_Label:SetText(data.name)
			oTabBtn.m_OnSelectLabel:SetText(data.name)
		end
	end

	return oTabBtn
end

function CRankView.SetTabBtnData(self)
	local count = 1
	local parentCount = 1
	for i,v in ipairs(self.m_TypeSort) do
		local oData = self.m_TabData[v]
		if self.m_TabBtnArr[count] == nil then
			self.m_TabBtnArr[count] = self:CreateTabBtn(self.m_TabBtn)
		end
		self.m_TabBtnArr[count]:SetActive(true)
		self.m_TabBtnArr[count]:SetLocalScale(Vector3.one)
		self.m_TabBtnArr[count].m_Child = {}
		self.m_TabBtnArr[count].m_Parent = nil
		if #oData.subid > 1 then
			self.m_TabBtnArr[count]:SetData(oData, false, oData.name)
		else
			self.m_RankIdToBtn[g_RankCtrl:GetRankInfo(oData.subid[1]).id] = self.m_TabBtnArr[count]
			self.m_TabBtnArr[count]:SetData(g_RankCtrl:GetRankInfo(oData.subid[1]), true)
		end
		parentCount = count
		count = count + 1

		if #oData.subid > 1 then
			for k,v1 in ipairs(oData.subid) do
				if self.m_TabBtnArr[count] == nil then
					self.m_TabBtnArr[count] = self:CreateTabBtn(self.m_ChildTabBtn)
					self.m_TabBtnArr[count]:SetActive(false)
				end
				self.m_RankIdToBtn[g_RankCtrl:GetRankInfo(v1).id] = self.m_TabBtnArr[count]
				table.insert(self.m_TabBtnArr[parentCount].m_Child, self.m_TabBtnArr[count])
				self.m_TabBtnArr[count]:SetLocalScale(self.m_ChildScale)
				self.m_TabBtnArr[count].m_Child = {}
				self.m_TabBtnArr[count].m_Parent = self.m_TabBtnArr[parentCount]
				self.m_TabBtnArr[count]:SetData(g_RankCtrl:GetRankInfo(v1), true)
				count = count + 1
			end
		end
	end
end

function CRankView.OnClickTabBtn(self, oTabBtn)
	if self.m_CurrentTabBtn ~= nil and oTabBtn == self.m_CurrentTabBtn then
		return
	end
	if oTabBtn.m_IsNode then
		self:OnClickChildTab(oTabBtn)
	else
		self:OnClickParentTab(oTabBtn)
	end
end

function CRankView.OnClickParentTab(self, oTabBtn)
	-- printc("OnClickParentTab: " .. oTabBtn.m_Data.id)
	self:HideTabChild()
	if self.m_CurrentTabBtn ~= nil then
		self.m_CurrentTabBtn.m_Btn:SetActive(true)
		self.m_CurrentTabBtn.m_OnSelect:SetActive(false)
	end
	self.m_CurrentTabBtn = oTabBtn
	self.m_CurrentTabBtn.m_Btn:SetActive(false)
	self.m_CurrentTabBtn.m_OnSelect:SetActive(true)
	
	for i,v in ipairs(self.m_CurrentTabBtn.m_Child) do
		v:SetActive(true)
	end
	self.m_TabBtnTable:Reposition()
end

function CRankView.HideTabChild(self)
	if self.m_CurrentTabBtn ~= nil then
		for i,v in ipairs(self.m_CurrentTabBtn.m_Child) do
			v:SetActive(false)
		end
		if self.m_CurrentTabBtn.m_Parent ~= nil then
			for i,v in ipairs(self.m_CurrentTabBtn.m_Parent.m_Child) do
				v:SetActive(false)
			end
		end
	end
end

function CRankView.OnClickChildTab(self, oTabBtn)
	-- printc("OnClickChildTab: " .. oTabBtn.m_Data.id)
	if not g_RankCtrl:GetDataFromServer(oTabBtn.m_Data.id, 1) then
	end
end

function CRankView.OnChangeTab(self, rankListId, partnerType)
	-- printc("OnChangeTab: " .. rankListId)
	-- printc("self.m_PartnerType: " .. (self.m_PartnerType or "nil"))
	if not self.m_RankIdToBtn[rankListId] then
		return
	end
	self.m_PartnerType = partnerType
	self.m_GetingDataSprite:SetActive(false)
	self:HideTabChild()
	if self.m_CurrentTabBtn ~= nil then
		self.m_CurrentTabBtn.m_Btn:SetActive(true)
		self.m_CurrentTabBtn.m_OnSelect:SetActive(false)
	end
	if self.m_RankIdToBtn[rankListId].m_Parent ~= nil then
		for i,v in ipairs(self.m_RankIdToBtn[rankListId].m_Parent.m_Child) do
			v:SetActive(true)
		end
	end
	self.m_CurrentTabBtn = self.m_RankIdToBtn[rankListId]
	self.m_CurrentTabBtn.m_Btn:SetActive(false)
	self.m_CurrentTabBtn.m_OnSelect:SetActive(true)
	self.m_TabBtnTable:Reposition()
	
	local rankCount = g_RankCtrl:GetRankCount(rankListId, self.m_PartnerType)

	self.m_CurrentRankId = rankListId
	self.m_RankInfo = g_RankCtrl:GetRankInfo(self.m_CurrentRankId)
	self.m_LocationPopupBox:Clear()
	self.m_PartnerListPart:OnHide()
	if partnerType then
		self.m_PartnerBtn:SetActive(true)
		self.m_MyPartnerRankBtn:SetActive(true)
		if partnerType == 0 then
			self.m_PartnerBtn.m_NameLabel:SetText("全部伙伴")
		else
			self.m_PartnerBtn.m_NameLabel:SetText(data.partnerdata.DATA[partnerType].name)
		end
	else
		self.m_MyPartnerRankBtn:SetActive(false)
		self.m_PartnerBtn:SetActive(false)
	end
	local count = 0
	for i = 1, #self.m_RankInfo.rank_find do
		local index = self.m_RankInfo.rank_find[#self.m_RankInfo.rank_find - i + 1]
		if index == 1 or index < rankCount then
			if index % 2 == 1 then
				self.m_LocationPopupBox:AddSubMenu(string.format("第%d名", index), index, "bg_dijidi_mengban")
			else
				self.m_LocationPopupBox:AddSubMenu(string.format("第%d名", index), index, "bg_ciji_di")
			end
			count = count + 1
		end
	end
	self.m_LocationPopupBox:ChangeSelectedIndex(count)
	self.m_LocationPopupBox:SetOffsetHeight(-35)
	self.m_LocationPopupBox:SetCallback(callback(self, "SetLocation"))
	self.m_RefreshInfoLabel:SetText(self.m_RankInfo.refresh_tips)
	self.m_LocationPopupBox:SetActive(not(rankListId == define.Rank.RankId.OrgPrestige or rankListId == define.Rank.RankId.Partner))

	if rankCount == 0 then
		self.m_PlayerInfoBox:SetActive(false)
		self.m_RankListPart:SetActive(false)
		self.m_CountingTips:SetActive(true)
		return
	else
		self.m_PlayerInfoBox:SetActive(true)
		self.m_RankListPart:SetActive(true)
		self.m_CountingTips:SetActive(false)
	end
	
	
	self.m_Data = g_RankCtrl:GetRankData(rankListId, partnerType)
	self.m_ExtraData = g_RankCtrl:GetExtraData(self.m_CurrentRankId, partnerType)

	self:SetTitle(rankListId)
	self.m_PlayerInfoBox:SetData(g_RankCtrl:GetPlayerRankData(rankListId, partnerType), nil, partnerType)
	if (rankListId == define.Rank.RankId.OrgPrestige or rankListId == define.Rank.RankId.TerrawarServer or rankListId == define.Rank.RankId.TerrawarOrg) then
		self.m_PlayerInfoBox:SetActive(g_OrgCtrl:HasOrg())
	else
		self.m_PlayerInfoBox:SetActive(true)
	end

	self.m_ScrollView:SetData(self.m_ScrollWidget, self.m_RankInfo.per_page, self.m_Cell, callback(self, "CellInit"), callback(self, "CellSetData"))
	self.m_ScrollView:SetCrossPageEvent(self.m_RankInfo.per_page, callback(self, "GetPageData"))
	self.m_ScrollView:SetMaxIndex(rankCount)
	
	
end

function CRankView.GetPageData(self, page)
	if g_RankCtrl:GetDataFromServer(self.m_CurrentRankId, page, self.m_PartnerType) then
		self:ShowGettingData(page)
	end
end

function CRankView.ShowGettingData(self, page)
	if self.m_RankInfo.per_page * (page - 1) < g_RankCtrl:GetRankCount(self.m_CurrentRankId, self.m_PartnerType) then
		self.m_GetingDataSprite:SetActive(true)
		self.m_GetDataTimeUp = false
		self.m_GetDataCallbackData = nil
		self.m_TimerId = Utils.AddTimer(callback(self, "GetDataTimeUp"), 0, 0.5)
	end
end

function CRankView.GetDataTimeUp(self)
	self.m_GetDataTimeUp = true
	self.m_TimerId = nil
	if self.m_GetDataCallbackData ~= nil then
		self:AfterGetData(self.m_GetDataCallbackData)
	end
end

function CRankView.AfterGetData(self, oData)
	local to = oData.page * self.m_RankInfo.per_page
	local from = to - self.m_RankInfo.per_page + 1
	self.m_ScrollView:AddCanShowSpace(from, to)
	if self.m_Location ~= nil then
		self.m_ScrollView:SetLocation(self.m_Location)
		self.m_Location = nil
	else

	end
	--本页内刷新数据
	self.m_GetingDataSprite:SetActive(false)
end

function CRankView.CellInit(self, oBox)
	oBox.m_ParentView = self
end

function CRankView.CellSetData(self, oBox, index)
	return oBox:SetData(self.m_Data[index], index, self.m_PartnerType)
end

function CRankView.Destroy(self)
	self.m_ScrollView:Close()
	g_RankCtrl:ClearExtraData()
	if self.m_TimerId ~= nil then
		Utils.DelTimer(self.m_TimerId)
		self.m_TimerId = nil
	end
	CViewBase.Destroy(self)
end

function CRankView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Rank.Event.ReceiveData then
		if oCtrl.m_EventData.ranklistId ~= self.m_CurrentRankId 
			or (oCtrl.m_EventData.ranklistId == define.Rank.RankId.Partner and oCtrl.m_EventData.partnerType ~= self.m_PartnerType) then
			--非本页刷新数据
			self:OnChangeTab(oCtrl.m_EventData.ranklistId, oCtrl.m_EventData.partnerType)
		else
			if self.m_GetDataTimeUp or (not oCtrl.m_EventData.isNewData) then
				self:AfterGetData(oCtrl.m_EventData)
			else
				self.m_GetDataCallbackData = oCtrl.m_EventData
			end
		end
	elseif oCtrl.m_EventID == define.Rank.Event.RefreshData then
		--数据过期刷新
		g_NotifyCtrl:FloatMsg("排行榜数据已刷新")
		self:OnChangeTab(oCtrl.m_EventData.ranklistId, oCtrl.m_EventData.partnerType)
	-- elseif oCtrl.m_EventID == define.Rank.Event.ClearAll then
	-- 	g_NotifyCtrl:FloatMsg("排行榜数据已刷新")
	-- 	self.m_Location = 1
	-- 	g_RankCtrl:GetDataFromServer(self.m_CurrentRankId, 1)
	elseif oCtrl.m_EventID == define.Rank.Event.ReceiveEmptyData then
		self:OnChangeTab(oCtrl.m_EventData.ranklistId, oCtrl.m_EventData.partnerType)
	end
end

return CRankView