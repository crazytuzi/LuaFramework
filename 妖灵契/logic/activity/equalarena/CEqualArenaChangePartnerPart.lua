local CEqualArenaChangePartnerPart = class("CEqualArenaChangePartnerPart", CBox)

function CEqualArenaChangePartnerPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self:InitContent()
end

function CEqualArenaChangePartnerPart.InitContent(self)
	self.m_PosGrid = self:NewUI(1, CBox)
	self.m_ActorList = {}
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_EqualArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEqualEvent"))
	self:InitBox()
end

function CEqualArenaChangePartnerPart.InitBox(self)
	for i = 1, 2 do
		local oBox = self.m_PosGrid:NewUI(i, CBox)
		oBox.m_ActorTexture = oBox:NewUI(2, CActorTexture)
		oBox.m_NameLabel = oBox:NewUI(4, CLabel)
		oBox.m_WidgetObj = oBox:NewUI(5, CWidget)
		oBox.m_ActorTexture:AddUIEvent("click", callback(self, "ShowPartnerChooseView", oBox))
		oBox.m_PosIdx = i
		self.m_ActorList[i] = oBox
	end
end

function CEqualArenaChangePartnerPart.ShowPartnerChooseView(self, oBox)
	self.m_CurrentBox = oBox
	CPartnerChooseView:ShowView(function (oView)
		oView:SetConfirmCb(callback(self, "OnChangePartner"))
		oView:SetFilterCb(callback(self, "ExceptEqualArena"))
	end)
end

function CEqualArenaChangePartnerPart.ExceptEqualArena(self, partnerlist)
	local list = {}
	for k, oPartner in ipairs(partnerlist) do
		if (not g_EqualArenaCtrl:IsPartnerUsed(oPartner:GetValue("parid"))) and oPartner:IsEqualarenaPartner() then
			table.insert(list, oPartner)
		end
	end
	return list
end

function CEqualArenaChangePartnerPart.OnChangePartner(self, parid)
	if not self.m_CurrentBox then
		return
	end
	if g_EqualArenaCtrl:GetParByPos(self.m_CurrentBox.m_PosIdx) == parid then
		return
	end
	g_EqualArenaCtrl:ChangePartner(self.m_CurrentBox.m_PosIdx, parid)
end

function CEqualArenaChangePartnerPart.OnEqualEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EqualArena.Event.OnChangePartner then
		self:RefreshGrid()
	end
end

function CEqualArenaChangePartnerPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		self:UpdatePartner(oCtrl.m_EventData)
	end
end

--面板显示的两个人物
function CEqualArenaChangePartnerPart.RefreshGrid(self)
	for i, oBox in ipairs(self.m_ActorList) do
		local oPartner = g_EqualArenaCtrl:GetParByPos(i)
		if oPartner then
			oBox.m_ID = oPartner.m_ID
			oBox.m_ActorTexture:SetActive(true)
			local shape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
			oBox.m_ActorTexture:ChangeShape(shape, {})
			oBox.m_ActorTexture.m_PartnerID = oPartner.m_ID
			oBox.m_NameLabel:SetText(oPartner:GetValue("name"))
		else
			oBox.m_ID = nil
			-- oBox.m_ActorTexture:SetActive(false)
			-- g_UITouchCtrl:DelDragObject(oBox.m_ActorTexture)
			oBox.m_NameLabel:SetText("")
		end
	end
end

function CEqualArenaChangePartnerPart.UpdatePartner(self, parid)
	for i, oBox in ipairs(self.m_ActorList) do
		if oBox.m_ID == parid then
			local oPartner = g_PartnerCtrl:GetPartner(parid)
			local shape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
			oBox.m_ActorTexture:ChangeShape(shape, {})
			oBox.m_NameLabel:SetText(oPartner:GetValue("name"))
		end
	end
end

return CEqualArenaChangePartnerPart