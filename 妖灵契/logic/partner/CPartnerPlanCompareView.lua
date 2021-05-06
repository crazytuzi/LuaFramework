local CPartnerPlanCompareView = class("CPartnerPlanCompareView", CViewBase)

function CPartnerPlanCompareView.ctor(self, cb)
	CViewBase.ctor(self, "UI/partner/PartnerPlanCompareView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
	--self.m_GroupName = "main"
end


function CPartnerPlanCompareView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_AttrGrid = self:NewUI(2, CGrid)
	self.m_AttrBox = self:NewUI(3, CBox)
	self.m_LeftPart = self:NewUI(4, CBox)
	self.m_RightPart = self:NewUI(5, CBox)
	self.m_ConfirmBtn = self:NewUI(6, CButton)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnSwapEquip"))
	self:InitContent()
end

function CPartnerPlanCompareView.InitContent(self)
	self.m_AttrBox:SetActive(false)

	self.m_LIconSpr = self.m_LeftPart:NewUI(1, CSprite)
	self.m_LItemBox = self.m_LeftPart:NewUI(2, CBox)
	self.m_LAwakeSpr = self.m_LeftPart:NewUI(3, CSprite)
	self.m_LGradeLabel = self.m_LeftPart:NewUI(4, CLabel)
	self.m_LStarGrid = self.m_LeftPart:NewUI(5, CGrid)
	self.m_LStarGrid:InitChild(function (obj, idx)
		local spr = CSprite.New(obj)
		return spr
	end)
	self.m_LItemBoxList = {}
	for i = 1, 4 do
		local oItemBox = self.m_LItemBox:NewUI(i, CBox)
		oItemBox.m_ParEquipItem = oItemBox:NewUI(1, CParEquipItem)
		oItemBox.m_ParEquipItem:AddUIEvent("click", callback(self, "OnClickItem", oItemBox))
		self.m_LItemBoxList[i] = oItemBox
	end
	
	self.m_RIconSpr = self.m_RightPart:NewUI(1, CSprite)
	self.m_RItemBox = self.m_RightPart:NewUI(2, CBox)
	self.m_RAwakeSpr = self.m_RightPart:NewUI(3, CSprite)
	self.m_RGradeLabel = self.m_RightPart:NewUI(4, CLabel)
	self.m_RStarGrid = self.m_RightPart:NewUI(5, CGrid)
	self.m_RStarGrid:InitChild(function (obj, idx)
		local spr = CSprite.New(obj)
		return spr
	end)
	self.m_RItemBoxList = {}
	for i = 1, 4 do
		local oItemBox = self.m_RItemBox:NewUI(i, CBox)
		oItemBox.m_ParEquipItem = oItemBox:NewUI(1, CParEquipItem)
		oItemBox.m_ParEquipItem:AddUIEvent("click", callback(self, "OnClickItem", oItemBox))
		self.m_RItemBoxList[i] = oItemBox
	end
end

function CPartnerPlanCompareView.SetPartnerID(self, parid, rparid)
	self.m_CurParID = parid
	self.m_RParID = rparid
	self:UpdateItem()
	self:UpdateAttrUI()
end

function CPartnerPlanCompareView.UpdateItem(self)
	local loopTable = {
		{self.m_CurParID, self.m_LItemBoxList, self.m_LIconSpr, self.m_LAwakeSpr, self.m_LGradeLabel, self.m_LStarGrid},
		{self.m_RParID, self.m_RItemBoxList, self.m_RIconSpr, self.m_RAwakeSpr, self.m_RGradeLabel, self.m_RStarGrid},
	}
	for _, v in ipairs(loopTable) do
		local oPartner = g_PartnerCtrl:GetPartner(v[1])
		if oPartner then
			local info = oPartner:GetCurEquipInfo()
			for i, itemobj in ipairs(v[2]) do
				if info[i] then
					itemobj.m_ParEquipItem:SetActive(true)
					itemobj.m_ParEquipItem:SetItem(info[i])
					itemobj.m_ID = info[i]
				else
					itemobj.m_ID = nil
					itemobj.m_ParEquipItem:SetActive(false)
				end
			end
		end
		v[3]:SpriteAvatar(oPartner:GetIcon())
		v[4]:SetActive(oPartner:GetValue("awake") == 1)
		v[5]:SetText(tostring(oPartner:GetValue("grade")))
		local iStar = oPartner:GetValue("star")
		for i, spr in ipairs(v[6]:GetChildList()) do
			if iStar >= i then
				spr:SetSpriteName("pic_chouka_dianliang")
			else
				spr:SetSpriteName("pic_chouka_weidianliang")
			end
		end
	end
end

function CPartnerPlanCompareView.GetAttrDict(self, info)
	local itemlist = {}
	for k, itemid in pairs(info) do
		table.insert(itemlist, itemid)
	end
	local attrdict = g_ItemCtrl:GetEquipListAttr(itemlist)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	local oriattr = oPartner:GetOriAttr()
	if oriattr then
		local ratiolist = {"defense", "attack", "maxhp"}
		for _, attrkey in pairs(ratiolist) do
			if attrdict[attrkey.."_ratio"]["value"] > 0 then
				attrdict[attrkey]["value"] = attrdict[attrkey]["value"] + oriattr[attrkey]*attrdict[attrkey.."_ratio"]["value"]/10000
			end
		end
	end
	return attrdict
end

function CPartnerPlanCompareView.UpdateAttrUI(self)
	local oLPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	local curattr = {}
	if oLPartner then
		curattr = self:GetAttrDict(oLPartner:GetCurEquipInfo()) 
	end
	local oRPartner = g_PartnerCtrl:GetPartner(self.m_RParID)
	local planattr = {}
	if oRPartner then
		planattr = self:GetAttrDict(oRPartner:GetCurEquipInfo()) 
	end

	self.m_AttrGrid:Clear()
	local t = {"maxhp", "attack", "defense", "speed", "critical_ratio", 
		"critical_damage", "abnormal_attr_ratio", "res_abnormal_ratio"}

	for _, key in pairs(t) do
		local attrobj = curattr[key]
		local planobj = planattr[key]
		local oBox = self.m_AttrBox:Clone()
		oBox:SetActive(true)
		oBox.m_AttrName = oBox:NewUI(1, CLabel)
		oBox.m_LAttrValue = oBox:NewUI(2, CLabel)
		oBox.m_ChangeSpr = oBox:NewUI(3, CSprite)
		oBox.m_RAttrValue = oBox:NewUI(4, CLabel)
		oBox.m_ChangeLabel = oBox:NewUI(5, CLabel)
		
		oBox.m_AttrName:SetText(attrobj["name"])
		
		local lstr, rstr, delta, deltastr = self:GetPrintStr(key, attrobj["value"], planobj["value"])
		oBox.m_LAttrValue:SetText(lstr)
		oBox.m_RAttrValue:SetText(rstr)
		
		if delta > 0 then
			oBox.m_ChangeSpr:SetSpriteName("pic_tisheng")
			oBox.m_ChangeLabel:SetText(string.format("(+%s)", deltastr))
		elseif delta < 0 then
			oBox.m_ChangeSpr:SetSpriteName("pic_xiajiang")
			oBox.m_ChangeLabel:SetText(string.format("(-%s)", deltastr))
		else
			oBox.m_ChangeSpr:SetFlip("pic_tisheng")
			oBox.m_ChangeLabel:SetActive(false)
		end
		self.m_AttrGrid:AddChild(oBox)
	end
	self.m_AttrGrid:Reposition()
end

function CPartnerPlanCompareView.GetPrintStr(self, key, lvalue, rvalue)
	local lstr = ""
	local rstr = ""
	local delta = 0
	local deltastr = ""
	if string.endswith(key, "_ratio") or key == "critical_damage" then
		lvalue = math.floor(lvalue/10)/10
		rvalue = math.floor(rvalue/10)/10
		printc(lvalue, rvalue)
		if math.isinteger(lvalue) then
			lstr = string.format("%d%%", lvalue)
		else
			lstr = string.format("%.1f%%", lvalue)
		end
		
		if math.isinteger(rvalue) then
			rstr = string.format("%d%%", rvalue)
		else
			rstr = string.format("%.1f%%", rvalue)
		end
		
		delta = rvalue - lvalue
		if math.isinteger(delta) then
			deltastr = string.format("%d%%", math.abs(delta))
		else
			deltastr = string.format("%.1f%%", math.abs(delta))
		end
	
	else
		if lvalue > 0 and lvalue < 1 then
			lvalue = 1
		else
			lvalue = math.floor(lvalue)
		end
		
		if rvalue > 0 and rvalue < 1 then
			rvalue = 1
		else
			rvalue = math.floor(rvalue)
		end
		lstr = string.format("%d", lvalue)
		rstr = string.format("%d", rvalue)
		
		delta = rvalue - lvalue
		deltastr = string.format("%d", math.abs(delta))
	end
	return lstr, rstr, delta, deltastr
end


function CPartnerPlanCompareView.OnChangePlan(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	self:OnClose()
end

function CPartnerPlanCompareView.OnClickItem(self, itemobj)
	if itemobj.m_ID	then
		local oItem = g_ItemCtrl:GetItem(itemobj.m_ID)
		if oItem then
			g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(oItem, {})
		end
	end
end

function CPartnerPlanCompareView.OnSwapEquip(self)
	netpartner.C2GSSwapPartnerEquip(self.m_CurParID, self.m_RParID)
	self:OnClose()
end

return CPartnerPlanCompareView