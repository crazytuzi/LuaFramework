local CMapBookAwardView = class("CMapBookAwardView", CViewBase)


function CMapBookAwardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/MapBook/MapBookAwardView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Dialog"
end

function CMapBookAwardView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TitleLabel = self:NewUI(2, CLabel)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_ItemClone = self:NewUI(4, CItemTipsBox)
	self:InitContent()
end

function CMapBookAwardView.InitContent(self)
	self.m_ItemClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CMapBookAwardView.RefreshAward(self, data)
	self.m_TitleLabel:SetText(data.title)
	self.m_Grid:Clear()
	local itemlist = self:GetAwardList(data.rewarditem)
	for _, t in ipairs(itemlist) do
		local itembox = self.m_ItemClone:Clone()
		if t.key == "value" then
			itembox:SetItemData(t.itemid, t.value)
		else
			itembox:SetItemData(t.itemid, t.amount, t.value)
		end
		itembox:SetActive(true)
		self.m_Grid:AddChild(itembox)
	end
	self.m_Grid:Reposition()
end

function CMapBookAwardView.GetAwardList(self, itemList)
	local pat1 = "(%d+)%((%a+)=(%d+)%)"
	local pat2 = "(%d+)"
	local resultList = {}
	for _, oItem in ipairs(itemList) do
		local amount = oItem.num
		local k1,k2,k3 = string.match(oItem.sid, pat1)
		if k1 then
			local t = {
				itemid = tonumber(k1),
				key = tostring(k2),
				value = tonumber(k3),
				amount = amount,
			}
			table.insert(resultList, t)
		else
			local k1, k2 = string.match(oItem.sid, pat2)
			if k1 then
				local t = {
					itemid = tonumber(k1),
					amount = amount,
				}
				table.insert(resultList, t)
			end
		end
	end
	return resultList
end

return CMapBookAwardView