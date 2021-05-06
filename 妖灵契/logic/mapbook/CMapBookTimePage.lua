local CMapBookTimePage = class("CMapBookTimePage", CPageBase)

function CMapBookTimePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CMapBookTimePage.OnInitPage(self)
	self.m_LabelList = {}
	for i = 1, 4 do
		self.m_LabelList[i] = self:NewUI(2+i, CLabel)
		self.m_LabelList[i]:SetActive(false)
	end
	self.m_LeftBtn = self:NewUI(7, CButton)
	self.m_RightBtn = self:NewUI(8, CButton)
	self.m_NameLabel = self:NewUI(9, CLabel)
	self.m_BackBtn = self:NewUI(10, CButton)
	self.m_LinePosList = {}
	for i = 1, 3 do
		self.m_LinePosList[i] = self:NewUI(10 + i, CObject)
	end
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBack"))
	self.m_LeftBtn:AddUIEvent("click", callback(self, "OnLeftPage"))
	self.m_RightBtn:AddUIEvent("click", callback(self, "OnRightPage"))
end

function CMapBookTimePage.OnShowPage(self)
	self:SetEffect()
	self:RefreshData()
end

function CMapBookTimePage.OnHidePage(self)
	self.m_Effect:DestroyList()
	self.m_Effect:Destroy()
end

function CMapBookTimePage.SetEffect(self)
	self.m_Effect = CWorldMapEffect.New()
end

function CMapBookTimePage.RefreshData(self)
	self.m_PageAmount = 4
	local list = {}
	for _, t in ipairs(data.mapbookdata.WORLDMAP) do
		table.insert(list, {year = t.year, id = t.id, name = t.name, building = t.building})
	end
	table.sort(list, function (a, b) 
		return a.year < b.year
	end)
	self.m_DataList = list
	self.m_Page = 1
	self.m_MaxPage = math.floor((#list-1) / self.m_PageAmount) + 1
	self:RefreshPage()
end

function CMapBookTimePage.RefreshPage(self)
	local flag = nil
	for i = 1, 4 do
		self.m_LabelList[i]:SetActive(false)
	end
	self.m_Effect:DestroyList()
	local lineConfig = {
		{-45, 90, 0.75},
		{60, 90 , 0.75},
		{-30, 90, 0.75},
	}
	self.m_Idx = 1
	local function refresh()
		if self.m_Idx > 4 then
			return
		end
		local i = self.m_Idx
		local dData = self.m_DataList[i+(self.m_Page-1)*self.m_PageAmount]
		if dData then
			self.m_LabelList[i]:SetText(string.format("新历%d年", dData.year))
			self.m_LabelList[i]:AddUIEvent("click", callback(self, "OnClickBox", dData.name, self.m_Idx, dData.building))
			self.m_Idx = self.m_Idx + 1
			Utils.AddTimer(function () self.m_LabelList[i]:SetActive(true) end, 0, 0.15)
			self.m_Effect:CreateBall(self.m_LabelList[i]:GetPos())
			if i < 4 and self.m_DataList[i+(self.m_Page-1)*self.m_PageAmount+1] then
				self.m_Effect:CreateLine(self.m_LinePosList[i]:GetPos(), lineConfig[i][1], lineConfig[i][2], lineConfig[i][3])
			end
			if i == 1 then
				self:OnClickBox(dData.name, self.m_Idx, dData.building)
			end
			return true
		else
			self.m_LabelList[i]:SetActive(false)
			return false
		end
	end
	if self.m_EffectTimer then
		Utils.DelTimer(self.m_EffectTimer)
	end
	self.m_EffectTimer = Utils.AddTimer(refresh, 0.5, 0.2)
	self.m_LeftBtn:SetActive(self.m_Page > 1)
	self.m_RightBtn:SetActive(self.m_Page < self.m_MaxPage)
end

function CMapBookTimePage.OnClickBox(self, msg, idx, iCity)
	self.m_NameLabel:SetText("[u]"..msg)
	if self.m_Effect then
		self.m_Effect:ShowSelectEffect(self.m_LabelList[idx]:GetPos())
	end
	self.m_NameLabel:AddUIEvent("click", callback(self, "OnShowCity", iCity))
end

function CMapBookTimePage.OnShowCity(self, iCity)
	self.m_ParentView:ShowCityPage(iCity)
end

function CMapBookTimePage.OnLeftPage(self)
	self.m_Page = math.max(1, self.m_Page - 1)
	self:RefreshPage()
end


function CMapBookTimePage.OnRightPage(self)
	self.m_Page = math.min(self.m_MaxPage, self.m_Page + 1)
	self:RefreshPage()
end

function CMapBookTimePage.OnBack(self)
	if self.m_EffectTimer then
		Utils.DelTimer(self.m_EffectTimer)
	end
	self.m_ParentView:ShowMainPage()
end

return CMapBookTimePage