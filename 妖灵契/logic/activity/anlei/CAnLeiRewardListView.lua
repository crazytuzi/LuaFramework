
--暗雷奖励界面


---------------------------------------------------------------

local CAnLeiRewardListView = class("CAnLeiRewardListView", CViewBase)

function CAnLeiRewardListView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/AnLei/AnLeiRewardListView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CAnLeiRewardListView.OnCreateView(self)	
	self.m_Container = self:NewUI(1, CBox)
	self.m_ItemGrid = self:NewUI(2, CGrid)
	self.m_ItemCloneBox = self:NewUI(3, CItemTipsBox)
	self.m_MaskBtn = self:NewUI(4, CBox)
	self.m_TitleLabel = self:NewUI(5, CLabel)
	self.m_OffLineLabel = self:NewUI(6, CLabel)
	self:InitContent()
	UITools.ResizeToRootSize(self.m_Container)
end

function CAnLeiRewardListView.InitContent(self)
	self.m_MaskBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ItemCloneBox:SetActive(false)
end

function CAnLeiRewardListView.SetContent(self, list, time, cost)
	list = list or {}
	for i = 1, #list do 
		if list[i].sid then
			local oBox = self.m_ItemCloneBox:Clone()
			oBox:SetActive(true)
			local config = {isLocal = true, refreshSize = 80}
			if list[i].virtual ~= 1010 then
				oBox:SetItemData(list[i].sid, list[i].amount, nil ,config)	
			else
				oBox:SetItemData(list[i].virtual, list[i].amount, list[i].sid ,config)						
			end
			oBox.m_CountLabel:SetActive(true)
			oBox.m_CountLabel:SetText(string.format("x%d", list[i].amount))
			self.m_ItemGrid:AddChild(oBox)
		end		
	end	
	self.m_ItemGrid:Reposition()
	if time == nil or cost == nil then
		self.m_TitleLabel:SetText("探索完成")
		self.m_OffLineLabel:SetActive(false)
	else
		self.m_TitleLabel:SetText("离线托管")
		if time >= 29 * 60 and time < 35 * 60 then
			time = 30 * 60
		elseif time >= 59 * 60 then
			time = 60 * 60
		end
		local min = "00"
		if math.floor( time / 60) ~= 0 then
			local t = math.floor(time / 60)
			if t > 9 then
				min = string.format("%d", t)
			else
				min = string.format("0%d", t)
			end
		end
		local sec = ""
		if time % 60 > 9 then
			sec = string.format("%d", time % 60)
		else
			sec = string.format("0%d", time % 60)
		end
		
		self.m_OffLineLabel:SetActive(true)
		self.m_OffLineLabel:SetText(string.format("[654a33]离线[c51111]%s:%s[654a33]，探索点消耗%d点", min, sec, cost))
	end
end

return CAnLeiRewardListView		