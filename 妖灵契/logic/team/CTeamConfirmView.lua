local CTeamConfirmView = class("CTeamConfirmView", CViewBase)

function CTeamConfirmView.ctor(self, obj)
	CViewBase.ctor(self, "UI/Team/TeamConfirmView.prefab", obj)
	self.m_ExtendClose = "Black"
end

function CTeamConfirmView.OnCreateView(self)
	self.m_PlayerGrid = self:NewUI(1, CGrid)
	self.m_PlayerBox = self:NewUI(2, CBox)
	self.m_CancelBtn = self:NewUI(3, CButton)
	self.m_ConfirmBtn = self:NewUI(4, CButton)
	self.m_SelectPart = self:NewUI(5, CObject)
	self.m_SelectBtn = self:NewUI(6, CButton)
	self.m_TitleLabel = self:NewUI(7, CLabel)
	self.m_WaitLabel = self:NewUI(8, CLabel)
	self:InitContent()
end

function CTeamConfirmView.InitContent(self)
	self.m_PlayerBox:SetActive(false)
	self.m_WaitLabel:SetActive(false)
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancel"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
end

function CTeamConfirmView.SetData(self, sMsg, dMemberInfo, sType, iTime)
	self.m_TitleLabel:SetText(sMsg)
	self.m_Type = sType
	self.m_Time = iTime
	
	if self.m_CloseTimer then
		Utils.DelTimer(self.m_CloseTimer)
	end
	self.m_CloseTimer = Utils.AddTimer(callback(self, "OnClose"), 0, self.m_Time)
	if CTeamConfirmView.CACHEDATA and CTeamConfirmView.CACHEDATA.stype == sType then
		self.m_TitleLabel:SetText(CTeamConfirmView.CACHEDATA["msg"])
		self:UpdatePlayer(CTeamConfirmView.CACHEDATA["memberinfo"])
	else
		self:UpdatePlayer(dMemberInfo)
	end
	CTeamConfirmView.CACHEDATA = {}
end

function CTeamConfirmView.UpdateData(cls, sMsg, dMemberInfo, sType)
	local oView = cls:GetView()
	if oView then
		oView.m_TitleLabel:SetText(sMsg)
		oView.m_Type = sType
		oView:UpdatePlayer(dMemberInfo)
	else
		cls.CACHEDATA = {
			msg = sMsg,
			memberinfo = dMemberInfo,
			stype = sType,
		}
	end
end

function CTeamConfirmView.UpdatePlayer(self, dMemberInfo)
	self.m_PlayerGrid:Clear()
	local bFinish = false
	for _, dObj in ipairs(dMemberInfo) do
		local info = dObj.info
		local iState = dObj.state
		local oBox = self.m_PlayerBox:Clone()
		oBox.m_IconSpr = oBox:NewUI(1, CSprite)
		oBox.m_NameLabel = oBox:NewUI(2, CLabel)
		oBox.m_ConfirmSpr = oBox:NewUI(3, CSprite)
		oBox:SetActive(true)
		oBox.m_IconSpr:SpriteAvatar(info.model_info.shape)
		oBox.m_NameLabel:SetText(info.name)
		oBox.m_ConfirmSpr:SetActive(iState > 0)
		if iState == 1 then
			oBox.m_ConfirmSpr:SetSpriteName("pic_zudui_queding")
		elseif iState == 2 then
			oBox.m_ConfirmSpr:SetSpriteName("pic_zudui_jujue")
		end
		if info.pid == g_AttrCtrl.pid and iState > 0 then
			bFinish = true
		end
		self.m_PlayerGrid:AddChild(oBox)
	end
	self.m_PlayerGrid:Reposition()
	self.m_WaitLabel:SetActive(bFinish)
	self.m_SelectPart:SetActive(not bFinish)
	self.m_ConfirmBtn:SetActive(not bFinish)
	self.m_CancelBtn:SetActive(not bFinish)
	self:ShowTimer(not bFinish)
end

function CTeamConfirmView.ShowTimer(self, bShow)
	if self.m_BtnTimer then
		Utils.DelTimer(self.m_BtnTimer)
	end
	if bShow then
		local function update(obj)
			obj.m_CancelBtn:SetText("取消".."("..tostring(obj.m_Time).."s)")
			if obj.m_Time <= 0 then
				return
			end
			obj.m_Time = math.max(0, obj.m_Time - 1)
			return true
		end
		self.m_BtnTimer = Utils.AddTimer(objcall(self, update), 1, 0)
	else
		self.m_BtnTimer = nil
	end
end

function CTeamConfirmView.SetSessionidx(self, iSessionIdx)
	self.m_SessionIdx =iSessionIdx
	if not g_WindowTipCtrl:IsShowTips(self.m_Type) or g_TeamCtrl:IsLeader() then
		self:OnConfirm()
		self.m_WaitLabel:SetActive(true)
		self.m_SelectPart:SetActive(false)
		self.m_ConfirmBtn:SetActive(false)
		self.m_CancelBtn:SetActive(false)
		self:ShowTimer(false)
	end
end

function CTeamConfirmView.OnCancel(self)
	if self.m_SessionIdx then
		netother.C2GSCallback(self.m_SessionIdx, 0)
	end
end

function CTeamConfirmView.OnConfirm(self)
	if self.m_SessionIdx then
		netother.C2GSCallback(self.m_SessionIdx, 1)
	end
	if self.m_SelectBtn:GetSelected() then
		g_WindowTipCtrl:SetTodayTip(self.m_Type, true)
	else
		g_WindowTipCtrl:SetTodayTip(self.m_Type, false)
	end
end

function CTeamConfirmView.ExtendCloseView(self)
	-- body
end

return CTeamConfirmView

