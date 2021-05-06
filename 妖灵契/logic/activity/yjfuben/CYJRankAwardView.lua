local CYJRankAwardView = class("CYJRankAwardView", CViewBase)

function CYJRankAwardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/YJFuben/YJRankAwardView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CYJRankAwardView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_ItemBox = self:NewUI(3, CItemTipsBox)
	self.m_AwardBox = self:NewUI(4, CBox)
	self.m_ScrollView = self:NewUI(5, CScrollView)
	self:InitContent()
end

function CYJRankAwardView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ItemBox:SetActive(false)
	self.m_AwardBox:SetActive(false)
	self:UpdateAward()
end

function CYJRankAwardView.UpdateAward(self)
	self.m_Grid:Clear()
	local titlelist = {
		"第一名", "第二名", "第三名", "第四至十名",
		"第一名", "第一名", "第一名",
	}
	local titlelist = {"4-10", "11-20", "21-50", "51-100"}
	for i = 1, 5 do
		local awardBox = self.m_AwardBox:Clone()
		awardBox.m_ItemGrid = awardBox:NewUI(1, CGrid)
		awardBox.m_Label = awardBox:NewUI(2, CLabel)
		awardBox:SetActive(true)
		if i < 4 then
			awardBox.m_Label:SetText(tostring(i))
		else
			awardBox.m_Label:SetText(titlelist[i-3])
		end
		local awardList = self:GetAwardList(i)
		awardBox.m_ItemGrid:Clear()
		for _, oAward in ipairs(awardList) do
			local t = self:ParseReward(oAward)
			if t then
				local box = self.m_ItemBox:Clone()
				if t.key == "value" then
					box:SetItemData(t.itemid, t.value)
				else
					box:SetItemData(t.itemid, t.amount, t.value)
				end
				box:SetActive(true)
				awardBox.m_ItemGrid:AddChild(box)
			end
		end
		awardBox.m_ItemGrid:Reposition()
		self.m_Grid:AddChild(awardBox)
	end
	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CYJRankAwardView.ParseReward(self, dData)
	local pat1 = "(%d+)%((%a+)=(%d+)%)"
	local pat2 = "(%d+)"
	local resultList = {}
	
	local amount = dData.amount
	local k1, k2, k3 = string.match(dData.sid, pat1)
	if k1 then
		local t = {
			itemid = tonumber(k1),
			key = tostring(k2),
			value = tonumber(k3),
			amount = amount,
		}
		return t
	else
		local k1, k2 = string.match(dData.sid, pat2)
		if k1 then
			local t = {
				itemid = tonumber(k1),
				amount = amount,
			}
			table.insert(resultList, t)
			return t
		end
	end
end

function CYJRankAwardView.GetAwardList(self, idx)
	local sType = string.format("排行%d", idx)
	local awardList = {}
	for _, tAward in ipairs(data.yjfubendata.REWARD) do
		if tAward.stype == sType then
			table.insert(awardList, tAward)
		end
	end
	return awardList
end

return CYJRankAwardView