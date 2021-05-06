local CPartnerAwakePage = class("CPartnerAwakePage", CPageBase)

function CPartnerAwakePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerAwakePage.OnInitPage(self)
	self.m_SkillDesc = self:NewUI(1, CLabel)
	self.m_CostPart = self:NewUI(2, CBox)
	self.m_SkillLabel = self:NewUI(3, CLabel)
	self.m_SkillSpr = self:NewUI(4, CSprite)
	self.m_TipBtn = self:NewUI(5, CButton)
	self.m_FullPart = self:NewUI(6, CObject)
	self:InitCost()
	self.m_TipBtn:AddHelpTipClick("partner_awake")
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
end


function CPartnerAwakePage.InitCost(self)
	self.m_CostGrid = self.m_CostPart:NewUI(1, CGrid)
	self.m_CostBox = self.m_CostPart:NewUI(2, CBox)
	self.m_ConfirmBtn = self.m_CostPart:NewUI(3, CButton)
	self.m_GoldLabel = self.m_CostPart:NewUI(4, CLabel)
	self.m_EnableSpr = self.m_CostPart:NewUI(5, CObject)
	local grade = data.globalcontroldata.GLOBAL_CONTROL.partnerawake.open_grade
	self.m_EnableSpr:SetActive(g_AttrCtrl.grade < grade)
	
	self.m_CostBox:SetActive(false)
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
end

function CPartnerAwakePage.OnItemCtrlEvent(self, oCtrl)
	self:UpdateAwakeItem()
end

function CPartnerAwakePage.OnPartnerCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		self:UpdatePartner()
	end
end

function CPartnerAwakePage.UpdateView(self)
	if self:GetActive() then
		self:UpdateAwakeItem()
		self:UpdatePartner()
	end
end

function CPartnerAwakePage.SetPartnerID(self, parid)
	self.m_CurParID = parid
	self:UpdatePartner()
end

function CPartnerAwakePage.UpdatePartner(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	
	if not oPartner then
		self:ShowUI(false)
		return
	else
		self:ShowUI(true)
	end

	local awakestate = oPartner:GetValue("awake")
	self.m_FullPart:SetActive(awakestate == 1)
	self.m_CostPart:SetActive(awakestate ~= 1)
	self:UpdateAwakeItem()
	self:UpdateSkillDesc(oPartner)
	self:UpdateCost()
end

function CPartnerAwakePage.ShowUI(self, bshow)
end

function CPartnerAwakePage.ShowNoAwake(self)
end

function CPartnerAwakePage.SetNonePartner(self)
	self:ShowUI(false)
end

function CPartnerAwakePage.UpdateAwakeItem(self)
	self.m_CostGrid:Clear()
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	for _, v in ipairs(oPartner:GetValue("awake_cost")) do
		local costbox = self.m_CostBox:Clone()
		costbox:SetActive(true)
		costbox.m_Spr = costbox:NewUI(1, CSprite)
		costbox.m_AmountLabel = costbox:NewUI(2, CLabel)
		costbox.m_RareSpr = costbox:NewUI(3, CSprite)
		costbox.m_Slider = costbox:NewUI(4, CSlider)
		local curamount = g_ItemCtrl:GetTargetItemCountBySid(v["sid"])
		costbox.m_AmountLabel:SetText(string.format("%d/%d", curamount, v["amount"]))
		costbox.m_Slider:SetValue(curamount / v["amount"])
		costbox.m_ID = v["sid"]
		costbox.m_ComposeAmount = v["amount"]
		local quality = 0
		if data.itemdata.PARTNER_AWAKE[v["sid"]] then
			quality = data.itemdata.PARTNER_AWAKE[v["sid"]]["quality"]
		end
		costbox.m_RareSpr:SetItemQuality(quality)
		costbox.m_Spr:SpriteItemShape(v["sid"])
		costbox:AddUIEvent("click", callback(self, "OnClickAwakeItem", v["sid"], costbox))
		self.m_CostGrid:AddChild(costbox)
	end
	self.m_CostGrid:Reposition()
end

function CPartnerAwakePage.UpdateSkillDesc(self, oPartner)
	local skillname = nil
	--觉醒类型 1-加技能，2-解锁技能，3-加强技能，4-加属性
	local awaketype = oPartner:GetValue("awake_type")
	if awaketype < 4 then
		local skid = tonumber(oPartner:GetValue("awake_effect_skill"))
		if awaketype ~= 3 then
			skid = tonumber(oPartner:GetValue("awake_effect"))
		end
		if skid then
			local d = data.skilldata.PARTNERSKILL[skid]
			self.m_SkillSpr:SetActive(true)
			self.m_SkillDesc:SetActive(false)
			self.m_SkillLabel:SetActive(true)
			self.m_SkillSpr:SpriteSkill(d["icon"])
			skillname = d["name"]
			local text = ""
			local sdata = data.skilldata.PARTNER[skid]
			if awaketype == 2 then
				self.m_SkillLabel:SetText("技能解锁")
				text = sdata[1]["desc"]
			else
				self.m_SkillLabel:SetText("技能加强")
				local s = string.format("[ded65b]觉醒前：%s[-]\n\n[e1a113]觉醒后：%s", sdata[1]["desc"], oPartner:GetValue("awake_desc"))
				text = s
			end
			local info = {icon = d["icon"], desc = text, name = d["name"]}
			self.m_SkillSpr:AddUIEvent("click", function ()
				g_WindowTipCtrl:SetWindowAwakeItemInfo(info)
			end
			)
		end
	end

	if awaketype == 4 then
		self.m_SkillSpr:SetActive(false)
		self.m_SkillDesc:SetActive(true)
		self.m_SkillLabel:SetActive(false)
	end
	local showdesc = nil
	if skillname then
		showdesc = string.format("[%s] %s", skillname, oPartner:GetValue("awake_desc"))
	else
		showdesc = oPartner:GetValue("awake_desc")
		local t = string.split(showdesc, "：")
		if t[2] then
			self.m_SkillLabel:SetActive(true)
			self.m_SkillLabel:SetText(t[1])
			self.m_SkillDesc:SetText(t[2])
			return
		end
	end
	self.m_SkillDesc:SetText(showdesc)
end

function CPartnerAwakePage.UpdateCost(self)
	for i, costbox in pairs(self.m_CostGrid:GetChildList()) do
		local itemid = costbox.m_ID
		local curamount = g_ItemCtrl:GetTargetItemCountBySid(itemid)
		costbox.m_AmountLabel:SetText(string.format("%d/%d", curamount, costbox.m_ComposeAmount))
	end

	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	local cost = oPartner:GetValue("awake_coin_cost")
	if g_AttrCtrl.coin < cost then
		self.m_GoldLabel:SetText(string.format("#R#w1%s", string.numberConvert(cost)))
	else
		self.m_GoldLabel:SetText(string.format("#w1%s", string.numberConvert(cost)))
	end
end


function CPartnerAwakePage.OnClickAwakeItem(self, itemid, oBox)
	local itemList = g_ItemCtrl:GetItemIDListBySid(itemid)
	local itemobj = g_ItemCtrl:GetItem(itemList[1]) or CItem.NewBySid(itemid)
	-- if itemobj:GetValue("composable") == 1 then
	-- 	g_WindowTipCtrl:SetWindowItemTipsBaseItemInfo(itemobj)
	-- 	CItemTipsBaseInfoView:ShowView(function (oView)
	-- 		oView:SetContent(CItemTipsBaseInfoView.enum.BaseInfo, itemobj)
	-- 		oView.m_ItemUnConfirmleBtn:SetActive(false)
	-- 		oView.m_ItemUseBtn:SetLocalPos(Vector3.New(0, oView.m_ItemUseBtn:GetLocalPos().y, 0))
	-- 	end)
	-- else
		g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(itemid, 
			{widget = oBox, openView = self.m_ParentView}, nil, {showQuickBuy = true})
	-- end
end

function CPartnerAwakePage.OnConfirm(self)
	local grade = data.globalcontroldata.GLOBAL_CONTROL.partnerawake.open_grade
	if g_AttrCtrl.grade < grade then
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", grade))
	else
		netpartner.C2GSAwakePartner(self.m_CurParID)
	end
end

function CPartnerAwakePage.OnLeftOrRightBtn(self, idx)
	local list = g_PartnerCtrl:GetPartnerList()
	table.sort(list, callback(CPartnerMainPage, "PartnerSortFunc"))
	if #list > 1 then
		local curIdx = 1
		for i,oPartner in ipairs(list) do
			if oPartner.m_ID == self.m_CurParID then
				curIdx = i
				break
			end
		end
		curIdx = curIdx + idx
		if curIdx <= 0 then
			curIdx = #list
		elseif curIdx > #list then
			curIdx = 1
		end
		if self.m_ParentView then
			self.m_ParentView:OnChangePartner(list[curIdx].m_ID)
		end
	end
end

return CPartnerAwakePage