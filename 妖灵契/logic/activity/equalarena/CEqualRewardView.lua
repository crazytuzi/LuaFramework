local CEqualRewardView = class("CEqualRewardView", CViewBase)

function CEqualRewardView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Activity/EqualArena/EqualRewardView.prefab", ob)
	-- self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CEqualRewardView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	-- self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Table = self:NewUI(2, CGrid)
	self.m_ItemTipsBox = self:NewUI(3, CItemTipsBox)
	self.m_InfoBox = self:NewUI(4, CBox)
	self.m_CloseMark = self:NewUI(5, CBox)
	self:InitContent()
end

function CEqualRewardView.InitContent(self)
	self.m_InfoBox:SetActive(false)
	-- self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CloseMark:AddUIEvent("click", callback(self, "OnClickMark"))
	self:SetData()
end

function CEqualRewardView.OnClickMark(self)
	if CItemTipsSimpleInfoView:GetView() then
		return
	end
	self:OnClose()
end

function CEqualRewardView.SetData(self)
	self.m_TitleLabel:SetText("每月排行奖励")
	local rewardList = {}
	for k,v in pairs(data.equalarenadata.Reward) do
		table.insert(rewardList, v)
	end
	local function sortFunc(v1, v2)
		return v1.id < v2.id
	end

	table.sort(rewardList, sortFunc)
	for i,v in ipairs(rewardList) do
		local oInfoBox = self:CreateInfoBox()
		oInfoBox:SetActive(true)
		self.m_Table:AddChild(oInfoBox)
		oInfoBox:SetData(v)
	end
	self.m_Table:Reposition()
end

function CEqualRewardView.CreateInfoBox(self)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_DescLabal = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_Grid = oInfoBox:NewUI(2, CGrid)
	oInfoBox.m_ParentView = self
	function oInfoBox.SetData(self, oData)
		oInfoBox.m_Grid:Clear()
		oInfoBox.m_DescLabal:SetText(oData.desc)
		for i,v in ipairs(oData.weeky_award) do
			local oItemBox = oInfoBox.m_ParentView.m_ItemTipsBox:Clone()
			oInfoBox.m_Grid:AddChild(oItemBox)
			oItemBox:SetActive(true)
			oItemBox:SetItemData(v.id, v.num, nil, {isLocal = true, uiType = 1})
		end
		oInfoBox.m_Grid:Reposition()
	end

	return oInfoBox
end

return CEqualRewardView
