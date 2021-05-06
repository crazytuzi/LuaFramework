local CAwakeResultView = class("CAwakeResultView", CViewBase)

function CAwakeResultView.ctor(self, cb)
	CViewBase.ctor(self, "UI/partner/AWakeResultView.prefab", cb)
	self.m_DepthType = "Dialog"
end


function CAwakeResultView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Texture = self:NewUI(2, CActorTexture)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_AttrBox = self:NewUI(4, CBox)
	self.m_Contanier = self:NewUI(5, CWidget)
	self.m_DescLabel = self:NewUI(6, CLabel)
	self.m_FullTexture = self:NewUI(7, CTexture)
	self:InitContent()
end

function CAwakeResultView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Contanier)
	self.m_AttrBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OriPos = self.m_FullTexture:GetLocalPos()
end

function CAwakeResultView.SetPartner(self, parid)
	self.m_ParID = parid
	self:UpdateUI()
	Utils.AddTimer(callback(self, "UpdateAttr"), 0, 0)
end

function CAwakeResultView.UpdateUI(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ParID)
	self.m_DescLabel:SetText(oPartner:GetValue("awake_desc"))
	local iShape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
	self.m_Texture:ChangeShape(iShape, {})
	local v = self.m_OriPos
	local iFlip = enum.UIBasicSprite.Nothing
	local iDirect = 1
	if data.npcdata.DIALOG_NPC_CONFIG[iShape] then
		iDirect = data.npcdata.DIALOG_NPC_CONFIG[iShape]["direct"]
		if iDirect == 2 then
			iFlip = enum.UIBasicSprite.Horizontally
			iDirect = -1
		end
	end
	self.m_FullTexture:LoadFullPhoto(iShape, 
		objcall(self, function (obj) 
			local w = g_DialogueCtrl:GetFullTextureSize(iShape)[1]
			local w2 = data.partnerhiredata.DATA[iShape]["full_size"][1]
			local k = w2 / w
			obj.m_FullTexture:SnapFullPhoto(iShape, k)
			local ox, oy = obj.m_FullTexture:GetFullPhotoOffSet(iShape, k)
			obj.m_FullTexture:SetFlip(iFlip)
			obj.m_FullTexture:SetLocalPos(Vector3.New(v.x-ox*iDirect, v.y+oy, v.z))
			obj.m_FullTexture:SetActive(true)
		end))
end

function CAwakeResultView.UpdateAttr(self)
	local t = {
		{k="气血",v="maxhp"},
		{k="攻击",v="attack"},
		{k="防御",v="defense"},
		{k="速度",v="speed"},
		{k="暴击率",v="critical_ratio"},
		{k="暴击伤害", v="critical_damage"},
		{k="抗暴击率",v="res_critical_ratio"},
		{k="治疗暴击率",v="cure_critical_ratio"},
		{k="异常命中率",v="abnormal_attr_ratio"},
		{k="异常抵抗率",v="res_abnormal_ratio"},
	}
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ParID)
	local awakeattr = self:GetAwakeAttr()
	local level2text = define.Partner.AttrLevel
	for _, v in ipairs(t) do
		local oBox = self.m_AttrBox:Clone()
		oBox:SetActive(true)
		oBox.m_AttrName = oBox:NewUI(1, CLabel)
		oBox.m_OldLevel = oBox:NewUI(2, CSprite)
		oBox.m_NewLevel = oBox:NewUI(3, CSprite)
		oBox.m_AttrValue = oBox:NewUI(4, CLabel)
		oBox.m_AttrName:SetText(v["k"])
		oBox.m_OldLevel:SetSpriteName("pic_hqhb_attr"..tostring(oPartner:GetAttrLevel(v["v"])))
		oBox.m_NewLevel:SetSpriteName("pic_hqhb_attr"..tostring(oPartner:GetAwakeAttrLevel(v["v"])))
		local valuestr = self:GetAttrValue(awakeattr, v["v"])
		oBox.m_AttrValue:SetText(valuestr)

		self.m_Grid:AddChild(oBox)
	end
	self.m_Grid:Reposition()
	local h = self.m_DescLabel:GetHeight()
	self.m_Grid:SetLocalPos(Vector3.New(-19, 260 - h, 0))
end

function CAwakeResultView.GetAttrValue(self, awakeattr, key)
	local str = "无"
	if awakeattr[key] then
		local c = ""
		local k = 1
		local oriattr = awakeattr[key]["oriattr"]
		if string.endswith(key, "_ratio") or key == "critical_damage" then
			c = "%"
			k = 100
		else
			oriattr = math.floor(oriattr)
		end
		
		str = string.format("[cdcbb6]%d%s[-]", oriattr/k, c)
		local addattr = awakeattr[key]["addattr"]/k
		if addattr > 0 then
			str = string.format("[cdcbb6]%s[-][eebe4b]+%d%s[-]", str, addattr, c)
		end
	end
	return str
end

function CAwakeResultView.GetAttrLevel(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ParID)
	local attrlevel = oPartner:GetValue("attr_level")
	local func = loadstring("return "..attrlevel)
	local attrdict = func()
	local attrlevel = {}
	for k, v in pairs(attrdict) do
		attrlevel[k] = define.Partner.AttrLevel[v]
	end
	return attrlevel
end

function CAwakeResultView.GetAwakeAttrLevel(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ParID)
	local attrlevel = oPartner:GetValue("awake_attr_level")
	local func = loadstring("return "..attrlevel)
	local attrdict = func()
	local attrlevel = {}
	for k, v in pairs(attrdict) do
		attrlevel[k] = define.Partner.AttrLevel[v]
	end
	return attrlevel
end

function CAwakeResultView.GetAwakeAttr(self)
	local awakeattr = {}
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ParID)
	local oriattr = oPartner:GetOriAttr()
	
	local t = {"maxhp", "attack", "defense", "speed", "critical_ratio", "res_critical_ratio", 
	"critical_damage", "cure_critical_ratio", "abnormal_attr_ratio", "res_abnormal_ratio"}
	for _, k in ipairs(t) do
		awakeattr[k] = {}
		awakeattr[k]["oriattr"] = oriattr[k]
		awakeattr[k]["addattr"] = 0
	end


	local attrdict = data.partnerawakedata.AwakeAttr[oPartner:GetValue("partner_type")] or {}
	for _, k in ipairs({"defense", "attack", "maxhp"}) do
		if attrdict[k.."_ratio"] then	
			awakeattr[k]["addattr"] = awakeattr[k]["addattr"] + oriattr[k]*attrdict[k.."_ratio"]/100
		end
	end

	for _, k in ipairs(t) do
		if attrdict[k] then
			awakeattr[k]["addattr"] = awakeattr[k]["addattr"] + attrdict[k]
		end
	end
	return awakeattr
end

return CAwakeResultView