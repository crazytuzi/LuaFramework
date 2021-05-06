local CTimeLimitRankView = class("CTimeLimitRankView", CViewBase)

function CTimeLimitRankView.ctor(self, ob)
	CViewBase.ctor(self, "UI/TimeLimitRank/TimeLimitRankView.prefab", ob)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CTimeLimitRankView.OnCreateView(self)
	self.m_ScrollView = self:NewUI(1, CRecyclingScrollView)
	self.m_Cell = self:NewUI(2, CTimeLimitRankCellBox, true, self)
	self.m_TabBtnTable = self:NewUI(3, CTable)
	self.m_TabBtn = self:NewUI(4, CBox)
	self.m_CloseBtn = self:NewUI(5, CButton)
	self.m_PartnerBtn = self:NewUI(6, CBox)
	self.m_MyPartnerRankBtn = self:NewUI(7, CButton)
	self.m_GetingDataSprite = self:NewUI(11, CBox)
	self.m_ScrollWidget = self:NewUI(12, CWidget)
	self.m_RankListPart = self:NewUI(13, CWidget)
	self.m_CountingTips = self:NewUI(14, CLabel)

	self.m_PlayerInfoBox = self:NewUI(16, CTimeLimitRankCellBox, true, self)
	self.m_PartnerListPart = self:NewUI(17, CTimeLimitPartnerPart)
	self.m_TimeLabel = self:NewUI(18, CCountDownLabel)
	self.m_DescLabel = self:NewUI(19, CLabel)
	self.m_TipsLabel = self:NewUI(20, CLabel)
	self.m_RefreshTimer = {}
	self.m_TabBtnArr = {}
	self.m_RankIdToBtn = {}

	self.m_CurrentTabBtn = nil
	self.m_Data = {}
	self.m_ExtraData = {}
	self:InitContent()
end

function CTimeLimitRankView.InitContent(self)
	-- self.m_PartnerListPart:SetBanList({418})
	self:InitPartnerBox()
	self.m_MyPartnerRankBtn:AddUIEvent("click", callback(self, "OnClickMyPartnerRank"))
	self.m_PartnerListPart:SetClickCb(callback(self, "OnSelectPartner"))
	self.m_PartnerBtn:AddUIEvent("click", callback(self, "OnClickPartner"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self:SetTabBtnData()
	self.m_TabBtn:SetActive(false)

	self:PlayerCellInit()
	g_RankCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	self.m_Cell:SetActive(false)
	self.m_PartnerListPart:SetHideCb(function ()
		self.m_PartnerBtn.m_TweenObj:Toggle()
	end)
end

function CTimeLimitRankView.OnClickMyPartnerRank(self)
	netrank.C2GSPartnerRank(define.Rank.SubType.TimeLimit)
end

function CTimeLimitRankView.InitPartnerBox(self)
	local oPartnerBox = self.m_PartnerBtn
	oPartnerBox.m_NameLabel = oPartnerBox:NewUI(1, CLabel)
	oPartnerBox.m_TweenSprite = oPartnerBox:NewUI(2, CSprite)
	oPartnerBox.m_TweenObj = oPartnerBox.m_TweenSprite:GetComponent(classtype.TweenRotation)
end

function CTimeLimitRankView.OnSelectPartner(self, iPartner)
	g_RankCtrl:GetDataFromServer(self.m_CurrentRankId, 1, iPartner, define.Rank.SubType.TimeLimit)
end

function CTimeLimitRankView.OnClickPartner(self)
	self.m_PartnerListPart:SetActive(true)
	self.m_PartnerBtn.m_TweenObj:Toggle()
	self.m_PartnerListPart:OnSelectPartner(self.m_PartnerType)
end

function CTimeLimitRankView.RefreshTips(self, ranklistId)
	local iLeaveTime = g_RankCtrl:GetRushLeaveTime(ranklistId)
	self.m_TimeLabel:SetTickFunc(callback(self, "UpdataTime"))
	self.m_TimeLabel:SetTimeUPCallBack(callback(self, "OnTimeUp"))
	if iLeaveTime >= 0 then
		self.m_TimeLabel:BeginCountDown(iLeaveTime)
	else
		self.m_TimeLabel:BeginCountDown(0)
	end
	self.m_DescLabel:SetText(data.rankdata.RushConfig[ranklistId].desc)
	self:CheckRefreshTips()

	local lRefreshTime = {0, -600}
	for i,v in ipairs(self.m_RefreshTimer) do
		Utils.DelTimer(v)
	end
	self.m_RefreshTimer = {}
	for i,v in ipairs(lRefreshTime) do
		if iLeaveTime > v then
			local iTimerID = Utils.AddTimer(callback(self, "CheckRefreshTips"), iLeaveTime - v + 1, 0)
			table.insert(self.m_RefreshTimer, iTimerID)
		end
	end
end

function CTimeLimitRankView.CheckRefreshTips(self)
	local iLeaveTime = g_RankCtrl:GetRushLeaveTime(self.m_CurrentRankId)
	if iLeaveTime > 0 then
		self.m_TipsLabel:SetText(data.rankdata.RushConfig[self.m_CurrentRankId].refresh_desc)
	elseif iLeaveTime > -600 then
		self.m_TipsLabel:SetText("【数据统计中】")
	else
		self.m_TipsLabel:SetText("【奖励已发放】")
	end
end

function CTimeLimitRankView.UpdataTime(self, iValue)
	self.m_TimeLabel:SetText(string.format("倒计时:%s", self:GetLeftTime(iValue, true)))
end

function CTimeLimitRankView.GetLeftTime(self, iSec, bShowHour)
	local day = math.modf(iSec / 86400)
	local hour = math.modf((iSec % 86400)/ 3600)
	local min = math.modf((iSec % 3600) / 60)
	local sec = iSec % 60
	return string.format("%d天%d小时%d分", day, hour, min)
end

function CTimeLimitRankView.OnTimeUp(self)
	self.m_TimeLabel:SetText("活动结束")
end

function CTimeLimitRankView.PlayerCellInit(self)
	self:CellInit(self.m_PlayerInfoBox)
	self.m_PlayerInfoBox:SetActive(false)
end

function CTimeLimitRankView.SetLocation(self, oBox)
	self.m_Location = oBox:GetSelectedSubMenu().m_ExtraData
	local page = math.ceil(oBox:GetSelectedSubMenu().m_ExtraData / self.m_RankInfo.per_page)
	if g_RankCtrl:GetDataFromServer(self.m_CurrentRankId, page, self.m_PartnerType, define.Rank.SubType.TimeLimit) then
		self:ShowGettingData(page)
	end
end

function CTimeLimitRankView.CreateTabBtn(self, oBtn)
	local oTabBtn = oBtn:Clone("oTabBtn")
	oTabBtn.m_Btn = oTabBtn:NewUI(1, CButton)
	oTabBtn.m_Label = oTabBtn:NewUI(2, CLabel)
	oTabBtn.m_OnSelectLabel = oTabBtn:NewUI(3, CLabel)
	oTabBtn.m_OnSelect = oTabBtn:NewUI(4, CBox)
	oTabBtn.m_OnSelect:SetActive(false)

	self.m_TabBtnTable:AddChild(oTabBtn)
	oTabBtn.m_Btn:AddUIEvent("click", callback(self, "OnClickTabBtn", oTabBtn))
	function oTabBtn.SetData(self, oData)
		oTabBtn.m_Data = oData
		oTabBtn.m_Label:SetText(oData.name)
		oTabBtn.m_OnSelectLabel:SetText(oData.name)
	end

	return oTabBtn
end

function CTimeLimitRankView.SetTabBtnData(self)
	local count = 1
	for i,v in ipairs(data.rankdata.RushSort) do
		local iShowTime = g_RankCtrl:GetRushShowTime(v)
		if iShowTime > 0 then
			local oData = data.rankdata.RushConfig[v]
			if self.m_TabBtnArr[count] == nil then
				self.m_TabBtnArr[count] = self:CreateTabBtn(self.m_TabBtn)
			end
			self.m_TabBtnArr[count]:SetActive(true)
			self.m_TabBtnArr[count]:SetData(oData)
			self.m_RankIdToBtn[oData.id] = self.m_TabBtnArr[count]
			count = count + 1
		end
	end
end

function CTimeLimitRankView.OnClickTabBtn(self, oTabBtn)
	if self.m_CurrentTabBtn ~= nil and oTabBtn == self.m_CurrentTabBtn then
		return
	end
	self:OnClickChildTab(oTabBtn)
end

function CTimeLimitRankView.OnClickChildTab(self, oTabBtn)
	if not g_RankCtrl:GetDataFromServer(oTabBtn.m_Data.id, 1, nil, define.Rank.SubType.TimeLimit) then
	end
end

function CTimeLimitRankView.OnChangeTab(self, rankListId, partnerType)
	if not self.m_RankIdToBtn[rankListId] then
		return
	end
	self.m_PartnerType = partnerType
	-- printc("OnChangeTab: " .. (self.m_PartnerType or "nil"))
	self.m_GetingDataSprite:SetActive(false)

	if self.m_CurrentTabBtn ~= nil then
		self.m_CurrentTabBtn.m_Btn:SetActive(true)
		self.m_CurrentTabBtn.m_OnSelect:SetActive(false)
	end
	self.m_CurrentTabBtn = self.m_RankIdToBtn[rankListId]
	self.m_CurrentTabBtn.m_Btn:SetActive(false)
	self.m_CurrentTabBtn.m_OnSelect:SetActive(true)

	local rankCount = g_RankCtrl:GetRankCount(rankListId, self.m_PartnerType, define.Rank.SubType.TimeLimit)
	-- printc("rankCount: " .. rankCount)
	self.m_CurrentRankId = rankListId
	self.m_RankInfo = g_RankCtrl:GetRankInfo(self.m_CurrentRankId)
	-- printc("self.m_CurrentRankId: " .. self.m_CurrentRankId)
	self:RefreshTips(rankListId)
	self.m_PartnerListPart:OnHide()
	if partnerType then
		self.m_MyPartnerRankBtn:SetActive(true)
		self.m_PartnerBtn:SetActive(true)
		if partnerType == 0 then
			self.m_PartnerBtn.m_NameLabel:SetText("全部伙伴")
		else
			self.m_PartnerBtn.m_NameLabel:SetText(data.partnerdata.DATA[partnerType].name)
		end
	else
		self.m_MyPartnerRankBtn:SetActive(false)
		self.m_PartnerBtn:SetActive(false)
	end

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
	
	
	self.m_Data = g_RankCtrl:GetRankData(rankListId, partnerType, define.Rank.SubType.TimeLimit)
	self.m_ExtraData = g_RankCtrl:GetExtraData(self.m_CurrentRankId, partnerType, define.Rank.SubType.TimeLimit)

	self.m_PlayerInfoBox:SetData(g_RankCtrl:GetPlayerRankData(rankListId, partnerType, define.Rank.SubType.TimeLimit), nil, partnerType)
	if (rankListId == define.Rank.RankId.OrgPrestige or rankListId == define.Rank.RankId.TerrawarServer or rankListId == define.Rank.RankId.TerrawarOrg) then
		self.m_PlayerInfoBox:SetActive(g_OrgCtrl:HasOrg())
	else
		self.m_PlayerInfoBox:SetActive(true)
	end

	self.m_ScrollView:SetData(self.m_ScrollWidget, self.m_RankInfo.per_page, self.m_Cell, callback(self, "CellInit"), callback(self, "CellSetData"))
	self.m_ScrollView:SetCrossPageEvent(self.m_RankInfo.per_page, callback(self, "GetPageData"))
	self.m_ScrollView:SetMaxIndex(rankCount)
	
end

function CTimeLimitRankView.GetPageData(self, page)
	if g_RankCtrl:GetDataFromServer(self.m_CurrentRankId, page, self.m_PartnerType, define.Rank.SubType.TimeLimit) then
		self:ShowGettingData(page)
	end
end

function CTimeLimitRankView.ShowGettingData(self, page)
	if self.m_RankInfo.per_page * (page - 1) < g_RankCtrl:GetRankCount(self.m_CurrentRankId, self.m_PartnerType, define.Rank.SubType.TimeLimit) then
		self.m_GetingDataSprite:SetActive(true)
		self.m_GetDataTimeUp = false
		self.m_GetDataCallbackData = nil
		self.m_TimerId = Utils.AddTimer(callback(self, "GetDataTimeUp"), 0, 0.5)
	end
end

function CTimeLimitRankView.GetDataTimeUp(self)
	self.m_GetDataTimeUp = true
	self.m_TimerId = nil
	if self.m_GetDataCallbackData ~= nil then
		self:AfterGetData(self.m_GetDataCallbackData)
	end
end

function CTimeLimitRankView.AfterGetData(self, oData)
	local to = oData.page * self.m_RankInfo.per_page
	local from = to - self.m_RankInfo.per_page + 1
	self.m_ScrollView:AddCanShowSpace(from, to)
	-- printc("AddCanShowSpace:%s~%s", from, to)
	if self.m_Location ~= nil then
		self.m_ScrollView:SetLocation(self.m_Location)
		self.m_Location = nil
	else

	end
	--本页内刷新数据
	self.m_GetingDataSprite:SetActive(false)
end

function CTimeLimitRankView.CellInit(self, oBox)
	oBox.m_ParentView = self
end

function CTimeLimitRankView.CellSetData(self, oBox, index)
	return oBox:SetData(self.m_Data[index], index, self.m_PartnerType)
end

function CTimeLimitRankView.Destroy(self)
	self.m_ScrollView:Close()
	g_RankCtrl:ClearExtraData()
	if self.m_TimerId ~= nil then
		Utils.DelTimer(self.m_TimerId)
		self.m_TimerId = nil
	end
	CViewBase.Destroy(self)
end

function CTimeLimitRankView.OnNotify(self, oCtrl)
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
	elseif oCtrl.m_EventID == define.Rank.Event.ReceiveEmptyData then
		self:OnChangeTab(oCtrl.m_EventData.ranklistId, oCtrl.m_EventData.partnerType)
	end
end

return CTimeLimitRankView