local CLoginRewardNextView = class("CLoginRewardNextView", CViewBase)

function CLoginRewardNextView.ctor(self, cb)
	CViewBase.ctor(self, "UI/LoginReward/LoginRewardNextView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Top"
	self.m_LockClose = true
end

function CLoginRewardNextView.OnCreateView(self)
	self.m_Contanier = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_BGTexture = self:NewUI(3, CTexture)
	self.m_HousePart = self:NewUI(4, CBox)
	self.m_PartnerAwakePart = self:NewUI(5, CBox)
	self.m_ItemPart = self:NewUI(6, CBox)
	self.m_SSRPart = self:NewUI(7, CBox)
	self.m_WeaponPart = self:NewUI(8, CBox)
	self.m_PartnerPart = self:NewUI(9, CBox)
	self:InitContent()
end

function CLoginRewardNextView.SetNextDay(self, next_day)
	local dNext = data.loginrewarddata.Reward[next_day]
	if dNext then
		if string.find(dNext.item.sid, "house_partner") then
			local _, house_partner = g_ItemCtrl:SplitSidToHousePartner(dNext.item.sid)
			self:ShowHousePart(house_partner)
		elseif string.find(dNext.item.sid, "partner") then
			local awakes = {}
			local _, partner = g_ItemCtrl:SplitSidToPartner(dNext.item.sid)
			if table.index(awakes, partner) then
				self:ShowPartnerAwakePart(partner)
			else
				self:ShowPartnerPart(partner, dNext.item.num)
			end
		elseif tonumber(dNext.item.sid) == 10019 then
			self:ShowSSRPart(dNext.item)
		elseif tonumber(dNext.item.sid) == 12083 then
			self:ShowWeaponPart(dNext.item)
		elseif string.find(dNext.item.sid, "value") then
			local sid, value = g_ItemCtrl:SplitSidAndValue(dNext.item.sid)
			dNext.item.sid = sid
			dNext.item.num = value
			self:ShowItemPart(dNext.item, value)
		else
			self:ShowItemPart(dNext.item)
		end
	end
end

function CLoginRewardNextView.HideAllPart(self)
	self.m_HousePart:SetActive(false)
	self.m_PartnerAwakePart:SetActive(false)
	self.m_ItemPart:SetActive(false)
	self.m_SSRPart:SetActive(false)
	self.m_PartnerPart:SetActive(false)
end

function CLoginRewardNextView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Contanier)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_BGTexture:AddUIEvent("click", callback(self, "OnBGTexture"))

	self.m_LockCloseTimer = Utils.AddTimer(function ()
		if Utils.IsNil(self) then
			return
		end
		self.m_LockClose = false
	end, 2, 2)
end

function CLoginRewardNextView.OnBGTexture(self)
	if self.m_PartnerPart and self.m_PartnerPart.m_PartnerSkillInfoPage 
		and self.m_PartnerPart.m_PartnerSkillInfoPage:GetActive() then
		self.m_PartnerPart.m_PartnerSkillInfoPage:SetActive(false)
		return
	end
	self:OnClose()
end

function CLoginRewardNextView.CloseView(self)
	if self.m_LockClose then
		return
	end
	CViewBase.CloseView(self)
end

function CLoginRewardNextView.ShowHousePart(self, house_partner)
	self.m_BGTexture:LoadPath("Texture/House/bg_zhaidi_chayidaobeijing.png", function () end)
	self:HideAllPart()
	self.m_HousePart:SetActive(true)
	self.m_HousePart.m_LiveTexture = self.m_HousePart:NewUI(1, CLive2dTexture)
	local dData = data.housedata.HousePartner[house_partner]
	--self.m_HousePart.m_LiveTexture:SetActive(true)
	--self.m_HousePart.m_LiveTexture:ResetAndUpdateAnchors()
	self.m_HousePart.m_LiveTexture:SetActive(false)
	self.m_HousePart.m_LiveTexture:LoadModel(house_partner)

	if self.m_HousePartTimer then
		Utils.DelTimer(self.m_HousePartTimer)
		self.m_HousePartTimer = nil
	end
	local function delayload()
		local containerW, containerH = self.m_Contanier:GetSize()
		local ratio = 960/811
		local finalWidth, finalHeight
		-- 适配(横向,定宽 \ 纵向,定高)
		if ratio >= 1 then
			finalWidth = containerW
			finalHeight = finalWidth / ratio
		else
			finalHeight = containerH
			finalWidth = finalHeight * ratio
		end

		--以宽未基准做检测
		finalWidth = containerW
		finalHeight = finalWidth / ratio
		if finalHeight > containerH then
			finalHeight = containerH
			finalWidth = finalHeight * ratio
		end
		self.m_HousePart.m_LiveTexture:SetSize(finalWidth, finalHeight)
		self.m_HousePart.m_LiveTexture:SetLocalPos(Vector3.New(0, -(finalHeight/2)-50, 0))	
		self.m_HousePart.m_LiveTexture:SetActive(true)	
	end
	self.m_HousePartTimer = Utils.AddTimer(delayload, 0, 0)
end

function CLoginRewardNextView.ShowPartnerAwakePart(self, partner)
	self:HideAllPart()
	self.m_BGTexture:LoadPath("Texture/LoginReward/bg_qitian_partner.png", function () end)
	self.m_PartnerAwakePart:SetActive(true)	
	self.m_PartnerAwakePart.m_LeftActorTexture = self.m_PartnerAwakePart:NewUI(1, CActorTexture)
	self.m_PartnerAwakePart.m_RightActorTexture = self.m_PartnerAwakePart:NewUI(2, CActorTexture)
	self.m_PartnerAwakePart.m_LeftActorTexture:ChangeShape(partner)
	self.m_PartnerAwakePart.m_RightActorTexture:ChangeShape(702)
end

function CLoginRewardNextView.ShowItemPart(self, items, value)
	self:HideAllPart()
	self.m_BGTexture:LoadPath("Texture/LoginReward/bg_qitian_item.png", function () end)
	self.m_ItemPart:SetActive(true)
	self.m_ItemPart.m_ItemGrid = self.m_ItemPart:NewUI(1, CGrid)
	self.m_ItemPart.m_ItemCloneBox = self.m_ItemPart:NewUI(2, CItemTipsBox)
	self.m_ItemPart.m_CountLabel = self.m_ItemPart:NewUI(3, CLabel)
	self.m_ItemPart.m_ItemCloneBox:SetActive(false)
	local sid = tonumber(items.sid)
	local num = items.num
	if value then
		local oBox = self.m_ItemPart.m_ItemCloneBox:Clone()
		oBox:SetActive(true)
		oBox:SetItemData(sid, value, nil, {isLocal = true})
		self.m_ItemPart.m_ItemGrid:AddChild(oBox)
	else
		local oBox = self.m_ItemPart.m_ItemCloneBox:Clone()
		oBox:SetActive(true)
		oBox:SetItemData(sid, num, nil, {isLocal = true})
		self.m_ItemPart.m_ItemGrid:AddChild(oBox)
	end
	--[[
	elseif sid == 14011 then
		local oBox = self.m_ItemPart.m_ItemCloneBox:Clone()
		oBox:SetActive(true)
		oBox:SetItemData(sid, num, nil, {isLocal = true})
		self.m_ItemPart.m_ItemGrid:AddChild(oBox)
	else
		for i=1,num do
			local oBox = self.m_ItemPart.m_ItemCloneBox:Clone()
			oBox:SetActive(true)
			oBox:SetItemData(sid, 1, nil, {isLocal = true})
			self.m_ItemPart.m_ItemGrid:AddChild(oBox)
		end
		self.m_ItemPart.m_ItemGrid:Reposition()
	end
	]]
	local oItem = CItem.NewBySid(sid)
	if sid == 1002 then
		self.m_ItemPart.m_CountLabel:SetText(oItem:GetValue("name").." X "..string.numberConvert(num))
	else
		self.m_ItemPart.m_CountLabel:SetText(oItem:GetValue("name").." X "..num)
	end
end

function CLoginRewardNextView.ShowSSRPart(self, items)
	self:HideAllPart()
	self.m_BGTexture:LoadPath("Texture/LoginReward/bg_qitian_item.png", function () end)
	self.m_SSRPart:SetActive(true)
	self.m_SSRPart.m_ItemLabel = self.m_SSRPart:NewUI(1, CLabel)
	self.m_SSRPart.m_ItemDescLabel = self.m_SSRPart:NewUI(2, CLabel)
	local sid = tonumber(items.sid)
	local oItem = CItem.NewBySid(sid)
	self.m_SSRPart.m_ItemLabel:SetText(oItem:GetValue("name").." * "..items.num)
	self.m_SSRPart.m_ItemDescLabel:SetText(oItem:GetValue("introduction"))
end

function CLoginRewardNextView.ShowWeaponPart(self, items)
	self:HideAllPart()
	self.m_BGTexture:LoadPath("Texture/LoginReward/bg_qitian_item.png", function () end)
	self.m_WeaponPart:SetActive(true)
	self.m_WeaponPart.m_ItemLabel = self.m_WeaponPart:NewUI(1, CLabel)
	self.m_WeaponPart.m_ItemDescLabel = self.m_WeaponPart:NewUI(2, CLabel)
	--local sid = tonumber(items.sid)
	--local oItem = CItem.NewBySid(sid)
	--self.m_WeaponPart.m_ItemLabel:SetText(oItem:GetValue("name").." * "..items.num)
	--self.m_WeaponPart.m_ItemDescLabel:SetText(oItem:GetValue("introduction"))
end

function CLoginRewardNextView.ShowPartnerPart(self, partner, num)
	self:HideAllPart()
	self.m_BGTexture:LoadPath("Texture/LoginReward/bg_qitian_partner.png", function () end)
	self.m_PartnerPart:SetActive(true)	
	self.m_PartnerPart.m_ActorTexture = self.m_PartnerPart:NewUI(1, CActorTexture)
	self.m_PartnerPart.m_DescLabel = self.m_PartnerPart:NewUI(2, CLabel)
	self.m_PartnerPart.m_AttrPart = self.m_PartnerPart:NewUI(3, CBox)
	self.m_PartnerPart.m_NameLabel = self.m_PartnerPart:NewUI(4, CLabel)
	self.m_PartnerPart.m_SkillGrid = self.m_PartnerPart:NewUI(5, CGrid)
	self.m_PartnerPart.m_SkillBox = self.m_PartnerPart:NewUI(6, CBox)
	self.m_PartnerPart.m_PartnerSkillInfoPage = self.m_PartnerPart:NewUI(7, CPartnerSkillTipsPage)
	
	self.m_PartnerPart.m_SkillBox:SetActive(false)
	self.m_PartnerPart.m_PartnerSkillInfoPage:SetActive(false)
	self:InitAttr()
	self:SetPartnerByType(partner, num)
end

function CLoginRewardNextView.InitAttr(self)
	local t = {
		{k="气血",v="maxhp"},
		{k="攻击",v="attack"},
		{k="防御",v="defense"},
		{k="速度",v="speed"},
		{k="暴击率",v="critical_ratio"},
		{k="暴击伤害", v="critical_damage"},
		{k="抗暴击率",v="res_critical_ratio"},
		{k="治疗暴击",v="cure_critical_ratio"},
		{k="异常命中",v="abnormal_attr_ratio"},
		{k="异常抵抗",v="res_abnormal_ratio"},
	}
	self.m_PartnerPart.m_AttrBoxList = {}
	for i, v in ipairs(t) do
		local oBox = self.m_PartnerPart.m_AttrPart:NewUI(i, CBox)
		oBox.m_AttrName = oBox:NewUI(1, CLabel)
		oBox.m_AttrValue = oBox:NewUI(2, CLabel)
		oBox.m_AttrLevel = oBox:NewUI(3, CLabel)
		oBox.m_AttrName:SetText(v.k)
		oBox.m_AttrKey = v.v
		self.m_PartnerPart.m_AttrBoxList[i] = oBox
	end
end

function CLoginRewardNextView.SetPartnerByType(self, partner_type, num)
	self.m_PartnerPart.m_ActorTexture:ChangeShape(partner_type)
	local desc = ""
	if num then
		local dData = data.partnerdata.DATA[partner_type]
		desc = string.format("%s * %d", dData.name, num)
	end
	self.m_PartnerPart.m_DescLabel:SetText(desc)

	local attrlevel = data.partnerdata.DATA[partner_type]["attr_level"]
	local function GetOriAttr(partnertype)
		local grade = 1
		for _, attrdata in pairs(data.partnerdata.ATTR) do
			if attrdata["partner_type"] == partnertype and attrdata["star"] == 1 
				and grade >= attrdata["grade_range"]["min"]
				and grade <= attrdata["grade_range"]["max"] then
				local result = {}
				for key, value in pairs(attrdata) do
					if type(value) == "string" then
						result[key] = math.floor(string.eval(value, {lv = grade}))
					end
				end
				return result
			end
		end
		return nil
	end

	local attrdict = GetOriAttr(partner_type)

	local dData = data.partnerawakedata.Level
	local dict = dData[partner_type] or {}

	local t = {"maxhp", "attack", "defense", "speed", "critical_ratio", "res_critical_ratio", 
	"critical_damage", "cure_critical_ratio", "abnormal_attr_ratio", "res_abnormal_ratio"}
	for i, key in ipairs(t) do
		local oItem = self.m_PartnerPart.m_AttrBoxList[i]
		oItem.m_AttrLevel:SetText(define.Partner.AttrLevel[dict[key]])
		if string.endswith(key, "_ratio") or key == "critical_damage" then
			local value = math.floor(attrdict[key]/10)/10
			if math.isinteger(value) then
				oItem.m_AttrValue:SetText(string.format("%d%%", value))
			else
				oItem.m_AttrValue:SetText(string.format("%.1f%%", value))
			end
		else
			oItem.m_AttrValue:SetText(string.format("%d", attrdict[key]))
		end
	end

	local pdata = data.partnerdata.DATA[partner_type]
	self.m_PartnerPart.m_SkillGrid:Clear()
	local skilllist = pdata["skill_list"]
	local d = data.skilldata.PARTNERSKILL
	table.sort(list, function (a, b) return a["sk"] < b["sk"] end)
	for _, skillid in ipairs(skilllist) do
		local box = self.m_PartnerPart.m_SkillBox:Clone()
		box:SetActive(true)
		box.m_Label = box:NewUI(1, CLabel)
		box.m_Icon = box:NewUI(2, CSprite)
		box.m_LockSpr = box:NewUI(3, CSprite, false)
		box.m_Icon:SpriteSkill(d[skillid]["icon"])
		box.m_Label:SetText("1")
		box.m_ID = skillid
		box.m_Level = 1
		box.m_IsAwake = false
		box.m_LockSpr:SetActive(false)
		box:AddUIEvent("click", callback(self, "OnClickSkill"))
		self.m_PartnerPart.m_SkillGrid:AddChild(box)
	end
	self.m_PartnerPart.m_SkillGrid:Reposition()

	local shape = pdata.shape
	self.m_PartnerPart.m_NameLabel:SetText(pdata.name)
end

function CLoginRewardNextView.OnClickSkill(self, oBox)
	self.m_PartnerPart.m_PartnerSkillInfoPage:SetActive(true)
	self.m_PartnerPart.m_PartnerSkillInfoPage:SetSkill(oBox.m_ID, oBox.m_Level, oBox.m_IsAwake)
	--g_WindowTipCtrl:SetWindowPartnerSKillInfo(oBox.m_ID, oBox.m_Level, oBox.m_IsAwake)
end

function CLoginRewardNextView.Destroy(self)
	if self.m_HousePart.m_LiveTexture then
		self.m_HousePart.m_LiveTexture:Destroy()
	end
	CViewBase.Destroy(self)
end

return CLoginRewardNextView
