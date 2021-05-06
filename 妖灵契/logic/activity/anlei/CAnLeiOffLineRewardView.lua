
--暗雷奖励界面


---------------------------------------------------------------

local CAnLeiOffLineRewardView = class("CAnLeiOffLineRewardView", CViewBase)

function CAnLeiOffLineRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/AnLei/AnLeiOffLineRewardView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CAnLeiOffLineRewardView.OnCreateView(self)	
	self.m_Container = self:NewUI(1, CBox)
	self.m_ItemGrid = self:NewUI(2, CGrid)
	self.m_ItemCloneBox = self:NewUI(3, CItemTipsBox)
	self.m_OkBtn = self:NewUI(4, CButton)
	self.m_TipsLabel = self:NewUI(5, CLabel)
	self:InitContent()
	UITools.ResizeToRootSize(self.m_Container)
end

function CAnLeiOffLineRewardView.InitContent(self)
	self.m_MaskBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ItemCloneBox:SetActive(false)
end

function CAnLeiOffLineRewardView.SetContent(self, list, time, cost)
	local min = (time / 60 == 0 ) and "" or tostring(time / 60)
	local sec = tostring(time % 60)
	self.m_TipsLabel:SetText(string.format("离线%s:%s，探索点消耗%d点", min, sec, cost))
	list = list or {}
	for i = 1, #list do 
		if list[i].sid then
			local oBox = self.m_ItemCloneBox:Clone()
			oBox:SetActive(true)
			local config = {isLocal = true,}
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
end

return CAnLeiOffLineRewardView		