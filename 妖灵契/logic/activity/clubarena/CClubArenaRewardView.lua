local CClubArenaRewardView = class("CClubArenaRewardView", CViewBase)

function CClubArenaRewardView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Activity/ClubArena/ClubArenaRewardView.prefab", ob)
	-- self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CClubArenaRewardView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_Table = self:NewUI(2, CGrid)
	self.m_ItemTipsBox = self:NewUI(3, CItemTipsBox)
	self.m_InfoBox = self:NewUI(4, CBox)
	self.m_CloseMark = self:NewUI(5, CBox)
	self.m_TagGrid = self:NewUI(6, CGrid)
	self.m_TagBox = self:NewUI(7, CBox)
	self.m_DescLabal = self:NewUI(8, CLabel)
	self:InitContent()
end

function CClubArenaRewardView.InitContent(self)
	self.m_InfoBox:SetActive(false)
	self.m_TagBox:SetActive(false)
	self.m_CloseMark:AddUIEvent("click", callback(self, "OnClickMark"))
	self.m_TitleLabel:SetText("武馆比武场奖励")
	self.m_TagList = {
		[1] = {name="武馆奖励", id = 1, desc = "奖励每天00:00点结算，发送至邮件。"},
		[2] = {name="馆主奖励", id = 2, desc = "馆主每10分钟获得荣誉，荣誉会一直累积。"},
	}
	for i,v in ipairs(self.m_TagList) do
		local oBox = self.m_TagBox:Clone()
		oBox:SetActive(true)
		oBox.m_NameLabel = oBox:NewUI(1, CLabel)
		oBox.m_NameLabel:SetText(v.name)
		oBox.m_ID = v.id
		oBox.m_Desc = v.desc
		oBox:SetGroup(self.m_TagGrid:GetInstanceID())
		oBox:AddUIEvent("click", callback(self, "OnTag"))
		self.m_TagGrid:AddChild(oBox)
	end
	self.m_TagGrid:Reposition()

	local oDefault = self.m_TagGrid:GetChild(1)
	self:OnTag(oDefault)
end

function CClubArenaRewardView.OnTag(self, oBox)
	oBox:SetSelected(true)
	self.m_DescLabal:SetText(oBox.m_Desc)
	if oBox.m_ID == 1 then
		self:SetData1()
	elseif oBox.m_ID == 2 then
		self:SetData2()
	end
end

function CClubArenaRewardView.OnClickMark(self)
	if CItemTipsSimpleInfoView:GetView() then
		return
	end
	self:OnClose()
end

function CClubArenaRewardView.SetData1(self)
	self.m_Table:Clear()
	local rewardList = {}
	for k,v in pairs(data.clubarenadata.Config) do
		if v.club_reward and next(v.club_reward) then
			table.insert(rewardList, v)
		end
	end
	local function sortFunc(v1, v2)
		return v1.id > v2.id
	end

	table.sort(rewardList, sortFunc)
	for i,v in ipairs(rewardList) do
		local oInfoBox = self:CreateInfoBox()
		oInfoBox:SetActive(true)
		self.m_Table:AddChild(oInfoBox)
		oInfoBox:SetData(v, 1)
	end
	self.m_Table:Reposition()
end

function CClubArenaRewardView.SetData2(self)
	self.m_Table:Clear()
	local rewardList = {}
	for k,v in pairs(data.clubarenadata.Config) do
		if v.owner_reward and next(v.owner_reward)  then
			table.insert(rewardList, v)
		end
	end
	local function sortFunc(v1, v2)
		return v1.id > v2.id
	end

	table.sort(rewardList, sortFunc)
	for i,v in ipairs(rewardList) do
		local oInfoBox = self:CreateInfoBox()
		oInfoBox:SetActive(true)
		self.m_Table:AddChild(oInfoBox)
		oInfoBox:SetData(v, 2)
	end
	self.m_Table:Reposition()
end

function CClubArenaRewardView.CreateInfoBox(self)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_DescLabal = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_Grid = oInfoBox:NewUI(2, CGrid)
	oInfoBox.m_ParentView = self
	function oInfoBox.SetData(self, oData, idx)
		oInfoBox.m_Grid:Clear()
		oInfoBox.m_DescLabal:SetText(oData.desc)
		local reward
		if idx == 1 then
			reward = oData.club_reward
		elseif idx == 2 then
			reward = oData.owner_reward
		end
		if reward and next(reward) then
			for i,v in ipairs(reward) do
				local oItemBox = oInfoBox.m_ParentView.m_ItemTipsBox:Clone()
				oInfoBox.m_Grid:AddChild(oItemBox)
				oItemBox:SetActive(true)
				oItemBox:SetItemData(v.id, v.num, nil, {isLocal = true, uiType = 1})
			end
		end
		oInfoBox.m_Grid:Reposition()
	end

	return oInfoBox
end

return CClubArenaRewardView
