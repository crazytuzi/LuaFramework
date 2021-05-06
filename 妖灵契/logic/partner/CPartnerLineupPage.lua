local CPartnerLineupPage = class("CPartnerLineupPage", CPageBase)

function CPartnerLineupPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerLineupPage.SetPartnerID(self, parid)
	self.m_CurParID = parid
end

function CPartnerLineupPage.OnInitPage(self)
	self.m_PosGrid = self:NewUI(1, CBox)
	self.m_LinePopupBox = self:NewUI(2, CPopupBox, true, CPopupBox.EnumMode.SelectedMode)
	self.m_ActorTexture = self:NewUI(3, CActorTexture)
	self.m_SwitchBtn = self:NewUI(4, CButton)
	self.m_ActorTexture:SetActive(false)
	self.m_ActorList = {}
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnShowPartnerScroll"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	for i = 1, 4 do
		local oBox = self.m_PosGrid:NewUI(i, CBox)
		oBox.m_AddBtn = oBox:NewUI(1, CButton)
		oBox.m_ActorTexture = oBox:NewUI(2, CActorTexture)
		oBox.m_CloseBtn = oBox:NewUI(3, CButton)
		oBox.m_NameLabel = oBox:NewUI(4, CLabel)
		oBox.m_WidgetObj = oBox:NewUI(5, CWidget)
		oBox.m_BG = oBox:NewUI(6, CSprite)
		oBox.m_FightLockSpr = oBox:NewUI(7, CSprite)
		oBox.m_ActorTextureBtn = oBox:NewUI(8, CButton)
		oBox.m_PosIdx = i
		oBox.m_CloseBtn:SetActive(i ~= 1)
		oBox.m_CloseBtn:AddUIEvent("click", callback(self, "CloseFight", oBox))
		oBox.m_ActorTexture:AddUIEvent("click", callback(self, "OnAddWarrior", oBox))
		oBox.m_ActorTextureBtn:AddUIEvent("click", callback(self, "OnAddWarrior", oBox))
		oBox.m_AddBtn:AddUIEvent("click", callback(self, "OnAddWarrior", oBox))
		if i ~= 1 then
			if g_PartnerCtrl:GetPartnerByFightPos(i) ~= nil then
				g_GuideCtrl:AddGuideUI(string.format("partner_lineup_pos_%d_btn", i), oBox.m_ActorTextureBtn)
			else
				g_GuideCtrl:AddGuideUI(string.format("partner_lineup_pos_%d_btn", i), oBox.m_AddBtn)
			end			
		end
		self.m_ActorList[i] = oBox
	end
	local iMaxAmount = g_WarCtrl:GetMaxFightAmount()
	for i, oBox in ipairs(self.m_ActorList) do
		local oPartner = g_PartnerCtrl:GetPartnerByFightPos(i)
		if oPartner then
			oBox.m_ID = oPartner.m_ID
			oBox.m_NameLabel:SetText(oPartner:GetValue("name"))
			oBox.m_CloseBtn:SetActive(i ~= 1)
			oBox.m_AddBtn:SetActive(false)
			oBox.m_BG:SetSpriteName("pic_huoban_shangzheng")
		else
			oBox.m_ID = nil
			oBox.m_NameLabel:SetText("")
			oBox.m_CloseBtn:SetActive(false)
			oBox.m_AddBtn:SetActive(true)
			oBox.m_BG:SetSpriteName("pic_huoban_weishangzhen")
			if i > iMaxAmount then
				oBox.m_FightLockSpr:SetActive(true)
				oBox.m_AddBtn:SetActive(false)
			else
				oBox.m_FightLockSpr:SetActive(false)
				oBox.m_AddBtn:SetActive(true)
			end
		end
	end
end

-- function CPartnerLineupPage.UpdateLinePos(self)
-- 	local iMaxAmount = g_WarCtrl:GetMaxFightAmount()
-- 	for i, oBox in ipairs(self.m_ActorList) do
-- 		oBox.m_AddBtn:SetActive()
-- 		oBox.m_FightLockSpr:SetActive
-- 		oBox.m_CloseBtn:SetActive
-- 		if iMaxAmount >= i then
-- 			oBox.m_FightLockSpr:SetActive(false)
-- 			(false)
-- 		else

-- 		end
-- 	end
-- end

function CPartnerLineupPage.OnLineSelect(self, oBox)
	local subMenu = oBox:GetSelectedSubMenu()
	oBox:SetMainMenu(subMenu.m_Label:GetText())
end

function CPartnerLineupPage.OnShowPage(self)
	
end

function CPartnerLineupPage.DelayInitPage(self)
	self:RefreshGrid()
end

function CPartnerLineupPage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.FightChange then
		self:RefreshGrid()
	
	elseif oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		self:UpdatePartner(oCtrl.m_EventData)
	end

end

function CPartnerLineupPage.RefreshGrid(self)
	g_UITouchCtrl:FroceEndDrag()
	local iMaxAmount = g_WarCtrl:GetMaxFightAmount()
	for i, oBox in ipairs(self.m_ActorList) do
		local oPartner = g_PartnerCtrl:GetPartnerByFightPos(i)
		if oPartner then
			oBox.m_ID = oPartner.m_ID
			oBox.m_ActorTexture:SetActive(true)
			local shape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
			oBox.m_ActorTexture:ChangeShape(shape, {})
			oBox.m_ActorTexture.m_PartnerID = oPartner.m_ID
			g_UITouchCtrl:AddDragObject(oBox.m_ActorTexture, self:GetActorDragArgs())
			oBox.m_NameLabel:SetText(oPartner:GetValue("name"))
			oBox.m_CloseBtn:SetActive(i ~= 1)
			oBox.m_AddBtn:SetActive(false)
			oBox.m_BG:SetSpriteName("pic_huoban_shangzheng")
			oBox.m_FightLockSpr:SetActive(false)
		else
			oBox.m_ID = nil
			oBox.m_ActorTexture:SetActive(false)
			g_UITouchCtrl:DelDragObject(oBox.m_ActorTexture)
			oBox.m_NameLabel:SetText("")
			oBox.m_AddBtn:SetActive(true)
			oBox.m_CloseBtn:SetActive(false)
			oBox.m_BG:SetSpriteName("pic_huoban_weishangzhen")
			if i > iMaxAmount then
				oBox.m_FightLockSpr:SetActive(true)
				oBox.m_AddBtn:SetActive(false)
			else
				oBox.m_FightLockSpr:SetActive(false)
				oBox.m_AddBtn:SetActive(true)
			end
		end
	end
end

function CPartnerLineupPage.UpdatePartner(self, parid)
	for i, oBox in ipairs(self.m_ActorList) do
		if oBox.m_ID == parid then
			local oPartner = g_PartnerCtrl:GetPartner(parid)
			local shape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
			oBox.m_ActorTexture:ChangeShape(shape, {})
			oBox.m_NameLabel:SetText(oPartner:GetValue("name"))
		end
	end
end

function CPartnerLineupPage.GetDragArgs(self)
	local dArgs = {
		start_delta = {x=99999, y=99999},
		cb_dragging = callback(self, "OnDragging"),
		cb_dragend = callback(self, "OnDragEnd"),
		cb_dragstart = callback(self, "OnDragStart"),
		offset = Vector3.New(40, 0, 0),
		drag_obj = self.m_ActorTexture,
		long_press = 0.5,
	}
	return dArgs
end

function CPartnerLineupPage.GetActorDragArgs(self)
	local dArgs = {
		start_delta = {x=0,y=0},
		cb_dragging = callback(self, "OnDragging"),
		cb_dragend = callback(self, "OnDragEnd"),
		long_press = 0.5,
	}
	return dArgs
end

function CPartnerLineupPage.OnDragStart(self, oDragObj)
	local oPartner = g_PartnerCtrl:GetPartner(oDragObj.m_ID)
	if oPartner then
		self.m_ActorTexture:SetActive(true)
		self.m_ActorTexture:ChangeShape(oPartner:GetValue("shape"))
		self.m_ActorTexture.m_PartnerID = oDragObj.m_ID
	end
	--self.m_ParentView:StopDragScroll()
end

function CPartnerLineupPage.OnDragging(self, oDragObj)

end

function CPartnerLineupPage.OnDragEnd(self, oDragObj)
	local pos = oDragObj:GetCenterPos()
	local oBox = self:GetBoxByPos(pos)
	if oBox and not oBox.m_FightLockSpr:GetActive() then

		local tParid = oDragObj.m_PartnerID
		local tPos = oBox.m_PosIdx
		if g_PartnerCtrl:GetFightPos(tParid) == tPos then
			self.m_ActorTexture:SetActive(false)
			return
		end
		g_PartnerCtrl:C2GSPartnerFight(tPos, tParid)
	end
	self.m_ActorTexture:SetActive(false)
	--self.m_ParentView:StartDragScroll()
end

function CPartnerLineupPage.CloseFight(self, oBox)
	if not self.m_LockCloseFight then
		g_PartnerCtrl:C2GSPartnerFight(oBox.m_PosIdx, oBox.m_ID)
		self.m_LockCloseFight = true
		Utils.AddTimer(function() self.m_LockCloseFight = false end, 0, 1)
	end
	
end

function CPartnerLineupPage.OnAddWarrior(self, oBox)
	local isInGuide = CGuideView:GetView() ~= nil and (g_GuideCtrl:IsInTargetGuide("PartnerFightLineupView") or g_GuideCtrl:IsInTargetGuide("Partner_HPPY_PartnerMain") )
	CPartnerChooseView:ShowView(function (oView)
		oView:SetFilterCb(callback(self, "IsCanFight"))
		oView:SetConfirmCb(callback(self, "SetWarrior", oBox.m_PosIdx))
		if isInGuide then
			oView:RefreshGuideContent()			
		end
	end)
end

function CPartnerLineupPage.IsCanFight(self, list)
	local newlist = {}
	for _, oPartner in ipairs(list) do
		local itype = oPartner:GetValue("partner_type")
		if itype ~= 1754 and itype ~= 1755 then
			table.insert(newlist, oPartner)
		end
	end
	return newlist
end

function CPartnerLineupPage.SetWarrior(self, iPos, iParID)
	g_PartnerCtrl:C2GSPartnerFight(iPos, iParID)
end

function CPartnerLineupPage.GetBoxByPos(self, pos)
	for i, oBox in ipairs(self.m_ActorList) do
		local bounds = UITools.CalculateAbsoluteWidgetBounds(oBox.m_WidgetObj.m_Transform)
		if pos.x >= bounds.min.x and pos.x <= bounds.max.x and
			pos.y >= bounds.min.y and pos.y <= bounds.max.y then
			return oBox
		end
	end
end

function CPartnerLineupPage.OnChangePos(self, data)
	local oBox = data["oBox"]
	local oPartner = g_PartnerCtrl:GetPartner(data["parid"])
	oBox.m_ActorTexture:ChangeShape(oPartner.shape, oPartner.model_info)
end

function CPartnerLineupPage.OnShowPartnerScroll(self)
	-- self.m_ParentView:ShowPartnerScroll()
end

return CPartnerLineupPage