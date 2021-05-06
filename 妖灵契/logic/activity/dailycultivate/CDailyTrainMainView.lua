local CDailyTrainMainView = class("CDailyTrainMainView", CViewBase)

function CDailyTrainMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/dailycultivate/DailyTrainMainView.prefab", cb)	
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_IsAnswer = false
end

function CDailyTrainMainView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_MainTipsLabel = self:NewUI(3, CLabel)
	self.m_CountLabel = self:NewUI(4, CLabel)
	self.m_SubTipsLabel = self:NewUI(5, CLabel)
	self.m_AwardGrid = self:NewUI(6, CGrid)
	self.m_AwardCloneBox = self:NewUI(7, CItemTipsBox)
	self.m_GoBtn = self:NewUI(8, CButton)
	self:InitContent()
end

function CDailyTrainMainView.InitContent(self)
	self.m_AwardCloneBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
	self.m_GoBtn:AddUIEvent("click", callback(self, "OnGo"))
	g_ActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlActivityEvent"))
	self:RefreshAll()

end

function CDailyTrainMainView.RefreshAll(self)
	local d = data.liliandata.DATA[10001]
	if d then
		local str = ""
		if d.main_tips and #d.main_tips > 0 then
			for i, v in ipairs(d.main_tips) do
				str = str..v.."\n"
			end
		end
		self.m_MainTipsLabel:SetText(str)
		self.m_SubTipsLabel:SetText(d.sub_tips)
		self.m_CountLabel:SetText(string.format("%d/60", g_ActivityCtrl:GetDailyTrainTimes()))
		self.m_AwardGrid:Clear()
		local list = d.reward_list_ui
		for i = 1, #list do
			local sid = nil
			local parId	= nil
			local value = nil
			local str = list[i]
			if string.find(str, "value") then
				sid, value = g_ItemCtrl:SplitSidAndValue(str)
			elseif string.find(str, "partner") then
				sid, parId = g_ItemCtrl:SplitSidAndValue(str)
			else
				sid = tonumber(str)
			end
			local oBox = self.m_AwardCloneBox:Clone()
			oBox:SetActive(true)
			local config = {isLocal = true,}
			oBox:SetItemData(sid, 1, parId, config)
			self.m_AwardGrid:AddChild(oBox)
		end
	end
end


function CDailyTrainMainView.OnGo(self)
	g_OpenUICtrl:WalkToDailyTrainNpc()
	self:CloseView()
end

function CDailyTrainMainView.OnCtrlActivityEvent(self, oCtrl)

end

function CDailyTrainMainView.Destory(self)
	CViewBase.Destory(self)
end

return CDailyTrainMainView