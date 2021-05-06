local CExpandConvoyPage = class("CExpandConvoyPage", CPageBase)

function CExpandConvoyPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandConvoyPage.OnInitPage(self)
	self.m_ContentLabel = self:NewUI(1, CLabel)
	self.m_TimeLabel = self:NewUI(2, CCountDownLabel)
	self.m_GiveUpBtn = self:NewUI(3, CButton)
	self.m_HideGroup = self:NewUI(4, CBox)
	self.m_CloseBtn = self:NewUI(5, CButton)
	self.m_OpenBtn = self:NewUI(6, CButton)
	self.m_ShowGroup = self:NewUI(7, CBox)
	self:InitContent()
end

function CExpandConvoyPage.InitContent(self)
	self.m_OpenBtn:AddUIEvent("click", callback(self, "OnOpen"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_GiveUpBtn:AddUIEvent("click", callback(self, "OnGiveUp"))
	g_ConvoyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnConvoyEvent"))
	self:SetData()
	self:OnOpen()
end

function CExpandConvoyPage.OnOpen(self)
	self.m_ShowGroup:SetActive(true)
	self.m_HideGroup:SetActive(false)
end

function CExpandConvoyPage.OnClose(self)
	self.m_ShowGroup:SetActive(false)
	self.m_HideGroup:SetActive(true)
end

function CExpandConvoyPage.SetData(self)
	if not g_ConvoyCtrl:IsConvoying() then
		return
	end
	local targetData = g_ConvoyCtrl:GetTargetData()
	if not targetData then
		self.m_TimeLabel:SetText("")
		self.m_ContentLabel:SetText(string.format("target_npc id: %s", g_ConvoyCtrl.m_TargetNpc))
		printc(string.format("target_npc id: %s不存在!服务器的锅！！！", g_ConvoyCtrl.m_TargetNpc))
		return
	end
	local sName = targetData.name
	local mapName = ""
	for k,v in pairs(data.scenedata.DATA) do
		if v.map_id == targetData.sceneId then
			mapName = v.scene_name
		end
	end
	local partnerType = g_ConvoyCtrl:GetConvoyPartnerType()
	local partnerName = data.convoydata.FollowTalk[partnerType].name
	self.m_ContentLabel:SetText(string.format("[FCE9B6]将[11f1bf]【%s】[-]护送到[11f1bf]【%s】[-]的[11f1bf]【%s】[-]处", partnerName, mapName, sName))
	self.m_TimeLabel:SetText("")
	self.m_TimeLabel:BeginCountDown(g_ConvoyCtrl:GetRestTime())
	self.m_TimeLabel:SetTickFunc(callback(self, "UpdateTime"))
	self.m_TimeLabel:SetTimeUPCallBack(callback(self, "OnTimeUp"))
	
end

function CExpandConvoyPage.OnShowPage(self)
	self:SetData()
end

function CExpandConvoyPage.UpdateTime(self, iValue)
	self.m_TimeLabel:SetText(string.format("[FCE9B6]剩余时间:[ff5656]%s", g_TimeCtrl:GetLeftTime(iValue)))
end

function CExpandConvoyPage.OnTimeUp(self)
	self.m_TimeLabel:SetText("[ff5656]任务失败")
end

function CExpandConvoyPage.OnGiveUp(self)
	nethuodong.C2GSGiveUpConvoy()
end

function CExpandConvoyPage.OnConvoyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Convoy.Event.UpdateConvoyInfo then
		self:SetData()
	end
end

return CExpandConvoyPage