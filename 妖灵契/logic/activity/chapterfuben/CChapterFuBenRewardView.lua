local CChapterFuBenRewardView = class("CChapterFuBenRewardView", CViewBase)

function CChapterFuBenRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/ChapterFuBen/ChapterFuBenRewardView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CChapterFuBenRewardView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_TitleLabel = self:NewUI(2, CLabel)
	self.m_ItemGrid = self:NewUI(3, CGrid)
	self.m_ItemBox = self:NewUI(4, CItemRewardBox)
	self.m_GetBtn = self:NewUI(5, CButton)
	self.m_StarLabel = self:NewUI(6, CLabel)
	self.m_LevelLabel = self:NewUI(7, CLabel)
	self:InitContent()
end

function CChapterFuBenRewardView.InitContent(self)
	self.m_ItemBox:SetActive(false)
	self.m_GetBtn:SetActive(false)
end

--章节宝箱
function CChapterFuBenRewardView.SetChapterData(self, dData)
	self.m_StarLabel:SetActive(true)
	self.m_LevelLabel:SetActive(false)
	self.m_TitleLabel:SetText("章节宝箱")
	self.m_StarLabel:SetText(string.format("达到%d", dData.star))
	self:SetReward(dData.star_reward)
end

--关卡宝箱
function CChapterFuBenRewardView.SetLevelData(self, dData)
	self.m_StarLabel:SetActive(false)
	self.m_LevelLabel:SetActive(true)
	self.m_TitleLabel:SetText("关卡宝箱")
	self.m_StarLabel:SetText("3星通关关卡后即可领取")
	self:SetReward(dData.extra_reward)
end

function CChapterFuBenRewardView.SetReward(self, rewardlist)
	self.m_ItemGrid:Clear()
	for i,v in ipairs(rewardlist) do
		local box = self.m_ItemBox:Clone()
		box:SetActive(true)
		box:SetItemBySid(v.sid, v.amount)
		self.m_ItemGrid:AddChild(box)
	end
	self.m_ItemGrid:Reposition()
end

return CChapterFuBenRewardView