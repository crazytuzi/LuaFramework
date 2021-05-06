local CTeamPvpRewardView = class("CTeamPvpRewardView", CEqualRewardView)

function CTeamPvpRewardView.SetData(self)
	self.m_TitleLabel:SetText("协同比武排行奖励")
	local rewardList = {}
	for k,v in pairs(data.teampvpdata.Reward) do
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

return CTeamPvpRewardView
