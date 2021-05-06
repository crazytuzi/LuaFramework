local CPEFbDropView = class("CPEFbDropView", CViewBase)

CPEFbDropView.CloseViewTime = 5

function CPEFbDropView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/PartnerEquipFuben/PEDropPlanView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_HelpKey = "pefuben_droplist"
end

function CPEFbDropView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_ItemBox = self:NewUI(3, CBox)
	self.m_PopupBox = self:NewUI(4, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, nil, true)
	self.m_SkillBox = self:NewUI(5, CBox)
	self.m_TipBtn = self:NewUI(6, CButton)
	self:InitContent()
end

function CPEFbDropView.InitContent(self)
	self.m_SkillBox:SetActive(false)
	self.m_ItemBox:SetActive(false)
	self.m_PopupBox:SetActive(false)
	
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnHelpTip"))
	g_UITouchCtrl:TouchOutDetect(self.m_SkillBox, callback(self, "CloseTips"))
	self:InitPopup()
	self:InitSkillBox()
end

function CPEFbDropView.InitPopup(self)
	local t = {"全部", "辅助"}
	for k, name in pairs(t) do
		self.m_PopupBox:AddSubMenu(name)
	end
	self.m_PopupBox:SetCallback(callback(self, "OnPlanSelect"))
end

function CPEFbDropView.InitSkillBox(self)
	self.m_SkillDesc = self.m_SkillBox:NewUI(1, CLabel)
	self.m_SkillIcon = self.m_SkillBox:NewUI(2, CSprite)
	self.m_SKillName = self.m_SkillBox:NewUI(3, CLabel)
	self.m_SKillBG = self.m_SkillBox:NewUI(4, CSprite)
end

function CPEFbDropView.SetType(self, fbid, fd_list)
	self.m_ID = fbid
	self.m_FbData = {}
	for _, obj in ipairs(fd_list) do
		self.m_FbData[obj.fb] = obj.cost
	end
	self:Refresh()
end

function CPEFbDropView.Refresh(self)
	self.m_Grid:Clear()
	local fdata = data.pefubendata.FUBEN
	local week = tonumber(g_TimeCtrl:GetTimeWeek())
	if week == 0 then
		week = 7
	end
	for i, dict in ipairs(fdata) do
		local box = self:CreateItemBox()
		for _, equiptype in ipairs(dict["equip"]) do
			local d = data.partnerequipdata.ParSoulType[equiptype]
			local icon = box.m_Icon:Clone()
			icon:SpriteItemShape(d["icon"])
			icon:SetActive(true)
			box.m_Grid:AddChild(icon)
			icon:AddUIEvent("click", callback(self, "OnClickItem", equiptype))
		end
		local timestr = self:GetTimeStr(dict["open_date"])
		box.m_Label:SetText(timestr)
		box.m_EnableSpr:AddUIEvent("click", callback(self, "OnForceSelectPlan", dict.id))
		local cost = self.m_FbData[dict.id]
		if cost and cost > 0 then
			box.m_EnableSpr:SetActive(true)
			box.m_CostLabel:SetActive(true)
			box.m_CostLabel:SetText(string.format("消耗#w2%d可选", cost))
		else
			box.m_CostLabel:SetActive(false)
			box.m_EnableSpr:SetActive(false)
		end
		if dict.id == self.m_ID then
			box.m_CostLabel:SetActive(false)
			box.m_SelSpr:SetActive(true)
		else
			box.m_SelSpr:SetActive(false)
		end
		box:AddUIEvent("click", callback(self, "OnSelectPlan", dict.id))
		self.m_Grid:AddChild(box)
	end
	self.m_Grid:Reposition()
end

function CPEFbDropView.CreateItemBox(self)
	local box = self.m_ItemBox:Clone()
	box.m_Grid = box:NewUI(1, CGrid)
	box.m_Icon = box:NewUI(2, CSprite)
	box.m_Label = box:NewUI(3, CLabel)
	box.m_EnableSpr = box:NewUI(4, CSprite)
	box.m_CostLabel = box:NewUI(5, CLabel)
	box.m_SelSpr = box:NewUI(6, CSprite)
	box.m_Icon:SetActive(false)
	box:SetActive(true)
	return box
end

function CPEFbDropView.GetTimeStr(self, date)
	local d = {"一", "二", "三", "四", "五", "六", "日"}
	local strlist = {"周"}
	for i, day in ipairs(date) do
		if i == 1 then
			table.insert(strlist, d[day])
		else
			table.insert(strlist, "/"..d[day])
		end
	end
	local str = table.concat(strlist, "")
	return str
end

function CPEFbDropView.OnPlanSelect(self)
	
end

function CPEFbDropView.OnClickItem(self, itemid, oItem)
	self:ShowTips(itemid, oItem)
end

function CPEFbDropView.OnSelectPlan(self, fbid)
	if CPEFbView.m_SelectPart > 0 then
		g_NotifyCtrl:FloatMsg("请先通关当前副本")
	else
		g_ActivityCtrl:GetPEFbCtrl():ChooseFuben(fbid)
		self:OnClose()
	end
end

function CPEFbDropView.OnForceSelectPlan(self, fbid)
	if CPEFbView.m_SelectPart > 0 then
		g_NotifyCtrl:FloatMsg("请先通关当前副本")
	else
		if self.m_FbData[fbid] > g_AttrCtrl.goldcoin then
			g_NotifyCtrl:FloatMsg("您的水晶不足")
			g_SdkCtrl:ShowPayView()
		else
			local windowConfirmInfo = {
				msg				= string.format("是否消耗%d水晶选取本掉落方案", self.m_FbData[fbid]),
				okCallback		= function ()
					nethuodong.C2GSCostSelectPEFuBen(fbid)
					self:OnClose()
				end,
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		end
	end
end

function CPEFbDropView.ShowTips(self, equip_type, oItem)
	local typedata = data.partnerequipdata.ParSoulType[equip_type]
	self.m_SkillBox:SetActive(true)
	self.m_SKillName:SetText(typedata["name"])
	self.m_SkillIcon:SpriteItemShape(typedata["icon"])
	local str = typedata["skill_desc"]
	self.m_SkillDesc:SetText(str)
	local lw, lh = self.m_SkillBox:GetSize()
	self.m_SKillBG:SetSize(309, 58+lh)
	UITools.NearTarget(oItem, self.m_SkillBox, enum.UIAnchor.Side.TopRight, Vector2.New(-35, 12))
end

function CPEFbDropView.CloseTips(self)
	self.m_SkillBox:SetActive(false)
end

function CPEFbDropView.OnHelpTip(self)
	CHelpView:ShowView(function(oView)
		oView:ShowHelp(self.m_HelpKey)
	end)
end

return CPEFbDropView