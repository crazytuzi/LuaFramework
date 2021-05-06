local CPartnerUpSkillPage = class("CPartnerUpSkillPage", CPageBase)
CPartnerUpSkillPage.ITEM_SHAPE = 14011
function CPartnerUpSkillPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerUpSkillPage.OnInitPage(self)
	self.m_SkillGrid = self:NewUI(1, CGrid)
	self.m_SkillBox = self:NewUI(2, CBox)
	self.m_NeedItem = self:NewUI(3, CBox)
	self.m_ConfirmBtn = self:NewUI(4, CButton)
	self.m_TipBtn = self:NewUI(5, CButton)

	self.m_SkillBox:SetActive(false)
	self.m_SkillIcon = self.m_SkillBox:NewUI(2, CSprite)
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnUpSkill"))
	self.m_TipBtn:AddHelpTipClick("partner_upskill")
	self:InitItem()

	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
end

function CPartnerUpSkillPage.InitItem(self)
	self.m_ItemTipBox = self.m_NeedItem:NewUI(1, CItemTipsBox)
	self.m_AmountLabel = self.m_NeedItem:NewUI(2, CLabel)
	self.m_Slider = self.m_NeedItem:NewUI(3, CSlider)
end

function CPartnerUpSkillPage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		if oCtrl.m_EventData == self.m_CurParID then
			self:UpdatePartner()
		end
	end
end

function CPartnerUpSkillPage.OnItemCtrlEvent(self, oCtrl)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	self:UpdateCost(oPartner)
end

function CPartnerUpSkillPage.SetPartnerID(self, parid)
	self.m_CurParID = parid
	self:UpdatePartner()
end

function CPartnerUpSkillPage.UpdatePartner(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	self:UpdateCost(oPartner)
	self:UpdateSkill()
end

function CPartnerUpSkillPage.UpdateSkill(self)
	
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	local skilllist = oPartner:GetValue("skill")
	local list = table.copy(skilllist)
	if oPartner:GetValue("awake_type") == 2 and oPartner:GetValue("awake") == 0 then
		local num = tonumber(oPartner:GetValue("awake_effect"))
		if num then
			local skillobj = {sk=num, level=0}
			table.insert(list, skillobj)
		end
	end
	
	local d = data.skilldata.PARTNERSKILL
	table.sort(list, function (a, b) return a["sk"] < b["sk"] end)
	--self.m_SkillGrid:Clear()
	for i, skillobj in ipairs(list) do
		local box = self.m_SkillGrid:GetChild(i)
		if not box then
			box = self.m_SkillBox:Clone()
			box:SetActive(true)
			box.m_Label = box:NewUI(1, CLabel)
			box.m_Icon = box:NewUI(2, CSprite)
			box.m_LockSpr = box:NewUI(3, CSprite, false)
			box.m_UIEffect = box:NewUI(4, CUIEffect)
			box.m_UIEffect:Above(self.m_SkillIcon)
			box.m_UIEffect:SetActive(false)
		end

		if d[skillobj["sk"]] and d[skillobj["sk"]]["icon"] then
			box.m_Icon:SpriteSkill(d[skillobj["sk"]]["icon"])
		end
		local str = string.format("%d", skillobj["level"])
		box.m_Label:SetText(str)
		box.m_ID = skillobj["sk"]
		box.m_Level = skillobj["level"]
		box.m_IsAwake = oPartner:GetValue("awake") == 1
		if box.m_LockSpr then
			box.m_LockSpr:SetActive(skillobj["level"] == 0)
		end
		box:AddUIEvent("click", callback(self, "OnClickSkill"))
		self.m_SkillGrid:AddChild(box)
	end
	self.m_SkillGrid:Reposition()
end

function CPartnerUpSkillPage.UpdateCost(self, oPartner)
	local dCost = oPartner:GetValue("skill_cost")
	self.m_ItemTipBox:SetItemData(dCost.sid, 1, nil, {isLocal = true, uiType = 1, openView = self.m_ParentView})
	self.m_ItemTipBox:AddUIEvent("click", function ()
		CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetInitBox(dCost.sid, nil, {})
			oView:ForceShowFindWayBox(true)
		end)
	end)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(dCost.sid)
	self.m_AmountLabel:SetText(string.format("%d/%d", iAmount, dCost.amount))
	self.m_Slider:SetValue(iAmount/dCost.amount)
	self.m_ItemID = dCost.sid
end

function CPartnerUpSkillPage.OnClickSkill(self, oBox)
	g_WindowTipCtrl:SetWindowPartnerSKillInfo(oBox.m_ID, oBox.m_Level, oBox.m_IsAwake)
end

function CPartnerUpSkillPage.OnClickUseItem(self, sid)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid, 
		{widget = self.m_IconSpr}, nil)
end

function CPartnerUpSkillPage.OnUpSkill(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	local iAmount = oPartner:GetUpSkillAmount()
	if iAmount == 0 then
		if #oPartner:GetValue("skill") < 3 then
			g_NotifyCtrl:FloatMsg("技能已满，觉醒后可解锁新的技能")
		else
			g_NotifyCtrl:FloatMsg("技能已全部到达满级")
		end
	end
	if self.m_Slider:GetValue() < 1 then
		local d = DataTools.GetItemData(self.m_ItemID)
		g_NotifyCtrl:FloatMsg("你的"..d.name.."不足")
		CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetInitBox(self.m_ItemID, nil, {})
			oView:ForceShowFindWayBox(true)
		end)
		return
	end
	if self.m_CurParID then
		netpartner.C2GSAddPartnerSkill(self.m_CurParID)
	end
end

function CPartnerUpSkillPage.DoSkillEffect(self, dSkills)
	self:CloseSkillEffect()
	if dSkills and dSkills[1] then
		local skid = dSkills[1].id
		for _, oChild in ipairs(self.m_SkillGrid:GetChildList()) do
			printc(skid, oChild.m_ID)
			if oChild.m_ID == skid then
				printc("ggg")
				oChild.m_UIEffect:SetActive(true)
			end
		end
	end
	if self.m_SkillEffectTimer then
		Utils.DelTimer(self.m_SkillEffectTimer)
	end
	self.m_SkillEffectTimer = Utils.AddTimer(callback(self, "CloseSkillEffect"), 0, 2)
end

function CPartnerUpSkillPage.CloseSkillEffect(self)
	for _, oChild in ipairs(self.m_SkillGrid:GetChildList()) do
		oChild.m_UIEffect:SetActive(false)
	end
end

return CPartnerUpSkillPage