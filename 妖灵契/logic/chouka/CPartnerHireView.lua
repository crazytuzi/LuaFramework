local CPartnerHireView = class("CPartnerHireView", CViewBase)

function CPartnerHireView.ctor(self, cb)
	CViewBase.ctor(self, "UI/partner/HireMainView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Dialog"
	self.m_IsAlwaysShow = true
end

function CPartnerHireView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_SelectPart = self:NewUI(2, CBox)
	self.m_RightPart = self:NewUI(3, CBox)
	self.m_TipBtn = self:NewUI(5, CButton)
	self.m_GetWayPart = self:NewUI(6, CBox)
	self.m_RBtn = self:NewUI(7, CButton)
	self.m_SSRBtn = self:NewUI(8, CButton)
	self:InitContent()
end

function CPartnerHireView.InitContent(self)
	self:InitSelect()
	self:InitRightPart()
	self:InitGetWay()
	self:InitZMData()
	self.m_SSRBtn:SetGroup(self.m_SSRBtn:GetInstanceID())
	self.m_RBtn:SetGroup(self.m_SSRBtn:GetInstanceID())
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipBtn:AddHelpTipClick("partner_hire")
	self.m_PartnerType = 1
	self:RefreshContent()
	self:SetPartner(self.m_DefaultID)
	self.m_RBtn:SetSelected(true)
	self.m_SSRBtn:AddUIEvent("click", callback(self, "OnChangeType"))
	self.m_RBtn:AddUIEvent("click", callback(self, "OnChangeType"))
	local pdata = data.partnerdata.DATA
	for _, obj in pairs(data.partnerhiredata.DATA) do
		if pdata[obj.id]["rare"] == 2 and self:IsCanCompose(obj.id) then
			self.m_SSRBtn:AddEffect("RedDot", 25)
		end
	end
	if self:IsCanSSRDraw() then
		self.m_SSRBtn:AddEffect("RedDot", 25)
	end
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrlEvent"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareCtrlEvent"))
end

function CPartnerHireView.InitSelect(self)
	self.m_RowAmount = 4
	local oPart = self.m_SelectPart
	
	self.m_ScrollView = oPart:NewUI(3, CScrollView)
	self.m_WrapContent = oPart:NewUI(4, CWrapContent)
	self.m_GridBox = oPart:NewUI(5, CBox)
	self.m_GridBox:SetActive(false)

	self.m_WrapContent:SetCloneChild(self.m_GridBox, callback(self, "CreateCloneWrap"))
	self.m_WrapContent:SetRefreshFunc(callback(self, "RefreshWrap"))
end

function CPartnerHireView.InitRightPart(self)
	local oPart = self.m_RightPart
	self.m_AttrGrid = oPart:NewUI(1, CGrid)
	self.m_AttrContainer = oPart:NewUI(2, CBox)
	self.m_SkillGrid = oPart:NewUI(3, CGrid)
	self.m_SkillBox = oPart:NewUI(4, CBox)
	self.m_FullTexture = oPart:NewUI(5, CTexture)
	self.m_NameLabel = oPart:NewUI(6, CLabel)
	self.m_DescLabel = oPart:NewUI(7, CLabel)
	self.m_AwakeBtn = oPart:NewUI(8, CButton)
	self.m_SkillBox:SetActive(false)
	self.m_AwakeBtn:AddUIEvent("click", callback(self, "OnShowAwakeTip"))
	self.m_AttrList = {}
	self.m_OriPos = self.m_FullTexture:GetLocalPos()
	for i = 1, 10 do
		self.m_AttrList[i] = self.m_AttrContainer:NewUI(i, CLabel)
	end
end

function CPartnerHireView.InitGetWay(self)
	local oPart = self.m_GetWayPart
	self.m_GetWayGrid = oPart:NewUI(1, CGrid)
	self.m_GetWayBtn = oPart:NewUI(2, CBox)
	self.m_ZMPart = oPart:NewUI(3, CBox)
	self.m_ChipPart = oPart:NewUI(4, CBox)
	self.m_HJPart = oPart:NewUI(5, CBox)
	self.m_SCPart = oPart:NewUI(6, CBox)
	self.m_DLPart = oPart:NewUI(7, CBox)
	self.m_TargetPart = oPart:NewUI(8, CBox)
	self.m_SSRPart = oPart:NewUI(9, CBox)
	self.m_ZZCardPart = oPart:NewUI(10, CBox)
	self.m_GetWayBtn:SetActive(false)
end

function CPartnerHireView.InitZMData(self)
	self.m_HireConfig = {}
	for _, v in ipairs(data.partnerhiredata.Config) do
		local iParID = v.parid
		self.m_HireConfig[iParID] = self.m_HireConfig[iParID] or {}
		self.m_HireConfig[iParID][v.times] = v
		local iTime = self.m_HireConfig[iParID]["max_time"] or 0

		if v.times > iTime then
			self.m_HireConfig[iParID]["max_time"] = v.times
			self.m_HireConfig[iParID]["max_value"] = v
		end
	end

	local dItemList = g_PartnerCtrl:GetChipByRare(0)
	local bRedDot = false
	for _, oItem in ipairs(dItemList) do
		local iAmount =  oItem:GetValue("amount")
		if oItem:GetValue("amount") > 0 then
			local iPartnerType = oItem:GetValue("partner_type")
			if not g_PartnerCtrl:IsHavePartner(iPartnerType) then
				local iComposeAmount = oItem:GetValue("compose_amount")
				if iComposeAmount <= iAmount then
					oItem.m_RedFlag = true
				end
			end
		end
	end

end

function CPartnerHireView.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:UpdateChipAmount()

	elseif oCtrl.m_EventID == define.Item.Event.DelItem then
		self:UpdateChipAmount()

	elseif oCtrl.m_EventID == define.Item.Event.AddItem then
		self:UpdateChipAmount()
	end
end

function CPartnerHireView.OnPartnerCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.PartnerAdd then
		self:UpdateHireData(self.m_CurID)
		self:UpdateGetWay()
	end
end

function CPartnerHireView.OnWelfareCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnFirstCharge then
		if self.m_CurID == 503 then
			self:UpdateGetWay()
		end
	elseif oCtrl.m_EventID == define.Welfare.Event.OnYueKa then
		self:UpdateGetWay()
	end
end

function CPartnerHireView.CreateCloneWrap(self, oChild)
	if oChild then
		oChild.m_ItemList = {}
		for i = 1, self.m_RowAmount do
			local oItem = oChild:NewUI(i, CBox)
			oItem.m_SelSpr = oItem:NewUI(1, CSprite)
			oItem.m_NameLabel = oItem:NewUI(2, CLabel)
			oItem.m_DescLabel = oItem:NewUI(3, CLabel)
			oItem.m_IconSpr = oItem:NewUI(4, CSprite)
			oItem.m_NiceSpr = oItem:NewUI(5, CSprite)
			oItem.m_CanComposeObj = oItem:NewUI(6, CSprite)
			oItem.m_RareSpr = oItem:NewUI(7, CSprite)
			oItem:AddUIEvent("click", callback(self, "OnClickPartner"))
			oChild.m_ItemList[i] = oItem
		end
		return oChild
	end
end

function CPartnerHireView.RefreshWrap(self, oChild, dData)
	if dData then
		oChild:SetActive(true)
		for i = 1, self.m_RowAmount do
			local oItem = oChild.m_ItemList[i]
			if dData[i] then
				oItem:SetActive(true)
				self:RefreshItem(oItem, dData[i])
			else
				oItem.m_ID = nil
				oItem:SetActive(false)
			end
			if dData.m_Row == 1 and i == 1 then
				g_GuideCtrl:AddGuideUI("partner_draw_partner_1_1_btn", oItem)
			end
		end
	else
		oChild:SetActive(false)
	end
end

function CPartnerHireView.RefreshItem(self, oItem, iParID)
	local partnerData = data.partnerdata.DATA[iParID]
	oItem.m_SelSpr:SetActive(false)
	oItem.m_NameLabel:SetText(partnerData.name)
	oItem.m_IconSpr:SpriteAvatarBig(partnerData.icon)
	oItem.m_NiceSpr:SetActive(partnerData.rare == 2)
	if partnerData.rare == 2 then
		oItem.m_RareSpr:SetSpriteName("pic_zm_xuanxiangkuang3")
	else
		oItem.m_RareSpr:SetSpriteName("pic_zm_xuanxiangkuang2")
	end
	oItem.m_DescLabel:SetActive(false)
	oItem.m_CanComposeObj:SetActive(false)
	if self:IsCanHire(iParID) then
		oItem.m_DescLabel:SetActive(true)
		oItem.m_DescLabel:SetText("[58FF6D]可招募")
	elseif self:IsCanSC(iParID) then
		oItem.m_DescLabel:SetActive(true)
		oItem.m_DescLabel:SetText("首充获取")
	elseif self:IsCanDL(iParID) then
		oItem.m_DescLabel:SetActive(true)
		oItem.m_DescLabel:SetText("连续登录获取")
	elseif self:IsCanTarget(iParID) then
		oItem.m_DescLabel:SetActive(true)
		oItem.m_DescLabel:SetText("七日目标获取")
	elseif self:IsCanZZCard(iParID) then
		oItem.m_DescLabel:SetActive(true)
		oItem.m_DescLabel:SetText("终身卡获取")
	else
		local sText = self:GetCanHireText(iParID)
		if sText then
			oItem.m_DescLabel:SetActive(true)
			oItem.m_DescLabel:SetText(sText)
		end
	end
	if self:IsCanCompose(iParID) or self:IsCanYFRH(iParID) then
		oItem.m_CanComposeObj:SetActive(true)
	end
	oItem.m_SelSpr:SetActive(iParID == self.m_CurID)
	oItem.m_ID = iParID
end

function CPartnerHireView.RefreshContent(self)
	local dData = data.partnerhiredata.DATA
	local partnerData = data.partnerdata.DATA
	local resultList = {}
	for k, v in pairs(dData) do
		if partnerData[v.id]["rare"] == self.m_PartnerType then
			table.insert(resultList, k)
		end
	end
	--sort
	--table.sort(resultList)
	local resultList = self:SortList(resultList)
	local t = self:GetDivideList(resultList)
	self.m_WrapContent:SetData(t, true)
	self.m_ScrollView:ResetPosition()
	self.m_DefaultID = 301
	if #t then
		self.m_DefaultID = t[1][1]
	end
end

function CPartnerHireView.SortList(self, dPartnerList)
	local dSortList = {}
	local pdata = data.partnerdata.DATA
	for _, iParID in ipairs(dPartnerList) do
		local dConfig = self.m_HireConfig[iParID]
		local iLevel = 99999
		local iCost = 99999
		local iHire = 0
		local iUnableHire = 1
		local iCompose = 0
		if self:IsCanHire(iParID) then
			iHire = 1
		end
		if self:IsUnableHire(iParID) then
			iUnableHire = 0
		end
		if self:IsCanCompose(iParID) then
			iCompose = 1
		end
		local iFlag = 0
		if self:IsCanSC(iParID) then
			iFlag = 8
		elseif self:IsCanDL(iParID) then
			iFlag = 4
		elseif self:IsCanTarget(iParID) then
			iFlag = 2
		end
		if dConfig then
			iLevel = dConfig[1]["level"]
			iCost = dConfig[1]["coin_cost"]
		end
		local t ={
			iParID,
			iUnableHire,
			iCompose,
			iHire,
			-iLevel,
			-iCost,
			-pdata[iParID]["rare"],
			iFlag,
			iParID,
		}
		table.insert(dSortList, t)
	end
	local function cmp(listA, listB)
		for i = 2, 9 do
			if listA[i] ~= listB[i] then
				return listA[i] > listB[i]
			end
		end
		return false
	end
	table.sort(dSortList, cmp)
	local dResultList = {}
	for _, v in ipairs(dSortList) do
		table.insert(dResultList, v[1])
	end
	return dResultList
end

function CPartnerHireView.GetDivideList(self, list)
	local newlist = {}
	local data = {}
	local guidePartnerId = nil
	if g_GuideCtrl:IsCustomGuideFinishByKey("Open_ZhaoMu") and not g_GuideCtrl:IsCustomGuideFinishByKey("DrawCard") then
		table.insert(data, 502)
		guidePartnerId = 502
	elseif g_GuideCtrl:IsCustomGuideFinishByKey("Open_ZhaoMu_Two") and not g_GuideCtrl:IsCustomGuideFinishByKey("DrawCard_Two") then
		table.insert(data, 403)
		guidePartnerId = 403
	elseif g_GuideCtrl:IsCustomGuideFinishByKey("Open_ZhaoMu_Three") and not g_GuideCtrl:IsCustomGuideFinishByKey("DrawCard_Three") then
		table.insert(data, 501)
		guidePartnerId = 501
	end

	for i, oPartner in ipairs(list) do
		if not guidePartnerId or oPartner ~= guidePartnerId then
			table.insert(data, oPartner)
			if #data >= self.m_RowAmount then
				data.m_Row = #newlist + 1
				table.insert(newlist, data)
				data = {}
			end
		end
	end
	if #data > 0 then
		table.insert(newlist, data)
	end
	return newlist
end

function CPartnerHireView.SetPartner(self, iParID)
	self.m_CurID = iParID
	local pdata = data.partnerdata.DATA[self.m_CurID]
	local iShape = pdata["shape"]
	self.m_FullTexture:SetActive(false)
	local v = self.m_OriPos
	local iDirect = 1
	local iFlip = enum.UIBasicSprite.Nothing
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
			local w2 = data.partnerhiredata.DATA[self.m_CurID]["full_size"][1]
			local k = w2 / w
			obj.m_FullTexture:SnapFullPhoto(iShape, k)
			local ox, oy = obj.m_FullTexture:GetFullPhotoOffSet(iShape, k)
			obj.m_FullTexture:SetFlip(iFlip)
			obj.m_FullTexture:SetLocalPos(Vector3.New(v.x-ox*iDirect, v.y+oy, v.z))
			obj.m_FullTexture:SetActive(true)
		end))
	self.m_NameLabel:SetText(pdata["name"])
	self.m_DescLabel:SetText(data.partnerhiredata.DATA[self.m_CurID]["desc"])
	self.m_DescLabel:UITweenPlay()
	self:UpdateSkill()
	self:UpdateAttr()
	self:UpdateGetWay()
end

function CPartnerHireView.UpdateSkill(self)
	local pdata = data.partnerdata.DATA[self.m_CurID]
	self.m_SkillGrid:Clear()
	local skilllist = pdata["skill_list"]
	local d = data.skilldata.PARTNERSKILL
	table.sort(list, function (a, b) return a["sk"] < b["sk"] end)
	for _, skillid in ipairs(skilllist) do
		local box = self.m_SkillBox:Clone()
		box:SetActive(true)
		box.m_Label = box:NewUI(1, CLabel)
		box.m_Icon = box:NewUI(2, CSprite)
		box.m_Icon:SpriteSkill(d[skillid]["icon"])
		box.m_Label:SetText("1")
		box.m_ID = skillid
		box.m_Level = 1
		box.m_IsAwake = false
		box:AddUIEvent("click", callback(self, "OnClickSkill"))
		self.m_SkillGrid:AddChild(box)
	end
	self.m_SkillGrid:Reposition()
end

function CPartnerHireView.UpdateAttr(self)
	local attrlevel = data.partnerdata.DATA[self.m_CurID]["attr_level"]
	local attrdict = self:GetOriAttr(self.m_CurID)

	local t = {"maxhp", "attack", "defense", "speed", "critical_ratio", "res_critical_ratio", 
	"critical_damage", "cure_critical_ratio", "abnormal_attr_ratio", "res_abnormal_ratio"}
	for i, key in ipairs(t) do
		local oItem = self.m_AttrList[i]
		if string.endswith(key, "_ratio") or key == "critical_damage" then
			local value = math.floor(attrdict[key]/10)/10
			if math.isinteger(value) then
				oItem:SetText(string.format("%d%%", value))
			else
				oItem:SetText(string.format("%.1f%%", value))
			end
		else
			oItem:SetText(string.format("%d", attrdict[key]))
		end
	end
end

function CPartnerHireView.GetOriAttr(self, partnertype)
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

function CPartnerHireView.UpdateSel(self)
	for _, boxList in pairs(self.m_WrapContent:GetChildList()) do
		for _, oBox in ipairs(boxList.m_ItemList) do
			oBox.m_SelSpr:SetActive(oBox.m_ID == self.m_CurID)
		end
	end
end

function CPartnerHireView.UpdateHireData(self, iParID)
	for _, boxList in pairs(self.m_WrapContent:GetChildList()) do
		for _, oBox in ipairs(boxList.m_ItemList) do
			if oBox.m_ID == iParID then
				self:RefreshItem(oBox, iParID)
			end
		end
	end
	if self.m_CurID == iParID and self.m_Key == "招募获取" then
		self:OnClickGetWay("招募获取")
	end
end

function CPartnerHireView.UpdateGetWay(self)
	local dData = data.partnerhiredata.DATA
	local pdata = dData[self.m_CurID]
	self.m_GetWayGrid:Clear()
	for _, key in ipairs(pdata.recommand_list) do
		local iBreak = self:IsHideGetWayBtn(key, self.m_CurID)
		if not iBreak then
			local box = self.m_GetWayBtn:Clone()
			local btn = box:NewUI(1, CButton)
			btn.m_SelLabel = box:NewUI(2, CLabel)
			btn:SetText(key)
			btn.m_SelLabel:SetText(key)
			btn:SetGroup(self.m_GetWayGrid:GetInstanceID())
			btn:AddUIEvent("click", callback(self, "OnClickGetWay", key))
			btn:SetActive(true)
			box.m_Btn = btn
			box.m_Key = key
			if key == "碎片合成" and self:IsCanCompose(self.m_CurID) then
				box.m_Btn:AddEffect("RedDot", 25)
			elseif key == "一发入魂" and self:IsCanSSRDraw(self.m_CurID) then
				box.m_Btn:AddEffect("RedDot", 25)
			end

			if key == "首充" and not g_WelfareCtrl:IsOpenFirstCharge() and g_PartnerCtrl:IsHavePartner(self.m_CurID) then
				btn:SetText("累充")
				btn.m_SelLabel:SetText("累充")
			end
			self.m_GetWayGrid:AddChild(box)
		end
	end
	local oChild = self.m_GetWayGrid:GetChild(1)
	if oChild then
		oChild:SetSelected(true)
		self:OnClickGetWay(oChild.m_Key)
	end
	self.m_GetWayGrid:Reposition()
end

function CPartnerHireView.IsHideGetWayBtn(self, key, iParID)
	if key == "终身卡获取" then
		if g_WelfareCtrl:HasZhongShengKa() then
			return true
		end
	end
	return false
end

function CPartnerHireView.UpdateChipAmount(self)
	if self.m_ChipPart:GetActive() then
		self:ShowSP()
	elseif self.m_SSRPart:GetActive() then
		self:ShowSSR()
	end
end

function CPartnerHireView.IsCanHire(self, iParID)
	local dConfig = self:GetHireConfig(iParID)
	local dData = data.partnerhiredata.DATA[iParID]
	if dConfig then
		local iTimes = g_PartnerCtrl:GetHireTime(iParID)
		if dData["max_times"] > 0 and iTimes >= dData["max_times"] then
			return false
		end
		if dData["max_times"] == 0 then
			return false
		end
		if g_AttrCtrl.grade >= dConfig["level"] then
			return true
		end
	end
	return false
end

function CPartnerHireView.IsUnableHire(self, iParID)
	local dConfig = self:GetHireConfig(iParID)
	local dData = data.partnerhiredata.DATA[iParID]
	if dConfig then
		local iTimes = g_PartnerCtrl:GetHireTime(iParID)
		if dData["max_times"] > 0 and iTimes >= dData["max_times"] then
			return true
		end
	end
	return false
end

function CPartnerHireView.GetCanHireText(self, iParID)
	local dConfig = self:GetHireConfig(iParID)
	local dData = data.partnerhiredata.DATA[iParID]
	if dConfig then
		local iTimes = g_PartnerCtrl:GetHireTime(iParID)
		if dData["max_times"] > 0 and iTimes >= dData["max_times"] then
			return "#R已招募"
		end
		if dData["max_times"] == 0 then
			return false
		end
		if g_AttrCtrl.grade < dConfig["level"] then
			return tostring(dConfig["level"]).."级可招募"
		end
	end
	return false
end

function CPartnerHireView.IsCanSC(self, iParID)
	if g_WelfareCtrl:IsOpenFirstCharge() then
		local d = data.partnerhiredata.DATA
		if table.index(d[iParID]["recommand_list"], "首充") then
			return true
		end
	end
	return false
end

function CPartnerHireView.IsCanDL(self, iParID)
	if not g_PartnerCtrl:IsGetPartner(iParID) then
		local d = data.partnerhiredata.DATA
		if table.index(d[iParID]["recommand_list"], "登录奖励") then
			return true
		end
	end
	return false
end

function CPartnerHireView.IsCanTarget(self, iParID)
	if g_WelfareCtrl:IsOpenSevenDayTarget() then
		if not g_PartnerCtrl:IsGetPartner(iParID) then
			local d = data.partnerhiredata.DATA
			if table.index(d[iParID]["recommand_list"], "七日目标") then
				return true
			end
		end
	end
	return false
end

function CPartnerHireView.IsCanZZCard(self, iParID)
	if not g_WelfareCtrl:HasZhongShengKa() then
		local d = data.partnerhiredata.DATA
		if table.index(d[iParID]["recommand_list"], "终身卡获取") then
			return true
		end
	end
end

function CPartnerHireView.IsCanCompose(self, iParID)
	if g_PartnerCtrl:IsHavePartner(iParID) then
		return false
	end
	local iChipType = g_PartnerCtrl:GetChipByPartner(iParID)
	local oItem = g_PartnerCtrl:GetSingleChipInfo(iChipType)
	if oItem:GetValue("amount") >= oItem:GetValue("compose_amount") then
		return true
	else
		return false
	end
end

function CPartnerHireView.IsCanYFRH(self, iParID)
	local d = data.partnerhiredata.DATA
	if table.index(d[iParID]["recommand_list"], "一发入魂") then
		return self:IsCanSSRDraw()
	end
end

function CPartnerHireView.IsCanSSRDraw(self, iParID)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(10019)
	if iAmount > 0 then
		return true
	else
		local iAmount = g_ItemCtrl:GetBagItemAmountBySid(13212)
		local iNeedAmount = CPartnerHireView.SSRNEEDAMOUNT
		if iAmount >= iNeedAmount then
			return true
		end
	end
	return false
end

function CPartnerHireView.GetHireConfig(self, iParID)
	local dConfig = self.m_HireConfig[iParID]
	if dConfig then
		local iTimes = g_PartnerCtrl:GetHireTime(iParID)
		return dConfig[iTimes] or dConfig["max_value"]
	end
end

function CPartnerHireView.OnClickSkill(self, oBox)
	g_WindowTipCtrl:SetWindowPartnerSKillInfo(oBox.m_ID, oBox.m_Level, oBox.m_IsAwake)
end

function CPartnerHireView.OnClickPartner(self, oItem)
	if oItem.m_ID then
		self:SetPartner(oItem.m_ID)
		self:UpdateSel()
	end
end

function CPartnerHireView.OnClickGetWay(self, key)
	self.m_ZMPart:SetActive(false)
	self.m_ChipPart:SetActive(false)
	self.m_HJPart:SetActive(false)
	self.m_DLPart:SetActive(false)
	self.m_SCPart:SetActive(false)
	self.m_TargetPart:SetActive(false)
	self.m_SSRPart:SetActive(false)
	self.m_ZZCardPart:SetActive(false)
	self.m_Key = key
	if key == "招募获取" then
		self:ShowZM()
	elseif key == "灵魂宝箱" then
		self:ShowHJ()
	elseif key == "碎片合成" then
		self:ShowSP()
	elseif key == "首充" or key == "累充" then
		self:ShowSC()
	elseif key == "登录奖励" then
		self:ShowDL()
	elseif key == "七日目标" then
		self:ShowTarget()
	elseif key == "一发入魂" then
		self:ShowSSR()
	elseif key == "终身卡获取" then
		self:ShowZZCard()
	end
end

function CPartnerHireView.ShowZM(self)
	local oPart = self.m_ZMPart
	oPart:SetActive(true)
	if not oPart.m_Init then
		oPart.m_Init = true
		oPart.m_TipLabel = oPart:NewUI(1, CLabel)
		oPart.m_ConfirmBtn = oPart:NewUI(2, CButton)
		oPart.m_CostLabel = oPart:NewUI(3, CLabel)
	end
	oPart.m_ConfirmBtn:SetText("招募")
	oPart.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnZMPartner"))
	g_GuideCtrl:AddGuideUI("partner_draw_partner_confirm_btn", oPart.m_ConfirmBtn)
	g_GuideCtrl:AddGuideUI("partner_draw_partner_close_btn", self.m_CloseBtn)
	
	local dConfig = self:GetHireConfig(self.m_CurID)
	local dData = data.partnerhiredata.DATA[self.m_CurID]

	if g_AttrCtrl.grade < dConfig.level then
		oPart.m_TipLabel:SetText(string.format("%d级后可解锁招募", dConfig.level))
		oPart.m_CostLabel:SetActive(true)
		oPart.m_ConfirmBtn:SetEnabled(true)		--暂时屏蔽不可点击  by ych
		oPart.m_ConfirmBtn:SetGrey(true)
		--return
	elseif dData["max_times"] > 0 and g_PartnerCtrl:GetHireTime(self.m_CurID) >= dData["max_times"] then
		oPart.m_CostLabel:SetActive(false)
		oPart.m_ConfirmBtn:SetEnabled(true)
		oPart.m_ConfirmBtn:SetGrey(true)
		oPart.m_ConfirmBtn:SetText("招募完毕")
	else
		oPart.m_ConfirmBtn:SetGrey(false)
		oPart.m_CostLabel:SetActive(true)
		oPart.m_ConfirmBtn:SetEnabled(true)
	end


	local sCost = ""
	if dConfig["arena_cost"] > 0 then
		sCost = ""
		sCost = sCost.."#w4 "..string.numberConvert(dConfig["arena_cost"])
		if g_AttrCtrl.arenamedal < dConfig["arena_cost"] then
			sCost = "#R"..sCost
		end
	end
	if dConfig["coin_cost"]> 0 then
		sCost = ""
		sCost = sCost.."#w1 "..string.numberConvert(dConfig["coin_cost"])
		if g_AttrCtrl.coin < dConfig["coin_cost"] then
			sCost = "#R"..sCost
		end
	end
	if dConfig["goldcoin"]> 0 then
		sCost = ""
		sCost = sCost.."#w2 "..string.numberConvert(dConfig["goldcoin"])
		if g_AttrCtrl.coin < dConfig["coin_cost"] then
			sCost = "#R"..sCost
		end
	end
	
	oPart.m_CostLabel:SetText(sCost)
	if g_PartnerCtrl:IsGetPartner(self.m_CurID) then
		oPart.m_TipLabel:SetText("已拥有该伙伴，再次获得将转化成碎片")
	else
		oPart.m_TipLabel:SetText("可通过招募获取伙伴")
	end
end

function CPartnerHireView.ShowHJ(self)
	local oPart = self.m_HJPart
	oPart:SetActive(true)
	if not oPart.m_Init then
		oPart.m_Init = true
		oPart.m_TipLabel = oPart:NewUI(1, CLabel)
		oPart.m_ConfirmBtn = oPart:NewUI(2, CButton)
		oPart.m_ConfirmBtn:SetText("前往")
		oPart.m_ConfirmBtn:AddUIEvent("click", function ()
			g_NotifyCtrl:FloatMsg("每天整点和半点时，世界各地会出现灵魂宝箱，打开可获取伙伴碎片")
		end)
	end
	if g_PartnerCtrl:IsGetPartner(self.m_CurID) then
		oPart.m_TipLabel:SetText("已拥有该伙伴，再次获得将转化成碎片")
	else
		oPart.m_TipLabel:SetText("可通过灵魂宝箱获取伙伴")
	end
end

function CPartnerHireView.ShowSP(self)
	local oPart = self.m_ChipPart
	oPart:SetActive(true)
	if not oPart.m_Init then
		oPart.m_Init = true
		oPart.m_ItemTipsBox = oPart:NewUI(1, CItemTipsBox)
		oPart.m_Silder = oPart:NewUI(2, CSlider)
		oPart.m_ChipBtn = oPart:NewUI(3, CButton)
		oPart.m_ComposeCostLabel = oPart:NewUI(4, CLabel)
	end

	oPart.m_ItemTipsBox:SetActive(true)
	local iChipType = g_PartnerCtrl:GetChipByPartner(self.m_CurID)
	oPart.m_ItemTipsBox:SetItemData(iChipType, 1, nil, {isLocal = true, uiType = 1, openView = self})
	local oItem = g_PartnerCtrl:GetSingleChipInfo(iChipType)
	local iAmount = oItem:GetValue("amount")
	local iNeedAmount = oItem:GetValue("compose_amount")
	oPart.m_Silder:SetActive(true)
	oPart.m_Silder:SetSliderText(string.format("%d/%d", iAmount, iNeedAmount))
	oPart.m_Silder:SetValue(iAmount/iNeedAmount)
	if iAmount >= iNeedAmount then
		oPart.m_ChipBtn:AddUIEvent("click", callback(self, "OnChipCompose", iChipType, true))
	else
		oPart.m_ChipBtn:AddUIEvent("click", callback(self, "OnChipCompose", iChipType, false))
	end
	local cost = oItem:GetValue("coin_cost")
	if g_AttrCtrl.coin >= cost then
		oPart.m_ComposeCostLabel:SetText("#w1"..string.numberConvert(cost))
	else
		oPart.m_ComposeCostLabel:SetText("#R#w1"..string.numberConvert(cost))
	end
end

function CPartnerHireView.ShowSC(self)
	local oPart = self.m_SCPart
	oPart:SetActive(true)
	if not oPart.m_Init then
		oPart.m_Init = true
		oPart.m_TipLabel = oPart:NewUI(1, CLabel)
		oPart.m_ConfirmBtn = oPart:NewUI(2, CButton)
	end
	if g_WelfareCtrl:IsOpenFirstCharge() then
		if g_PartnerCtrl:IsGetPartner(self.m_CurID) then
			oPart.m_TipLabel:SetText("完成首充可以获得黑碎片用于伙伴升星")
			oPart.m_ConfirmBtn:SetActive(true)
			oPart.m_ConfirmBtn:SetText("前往")
			oPart.m_ConfirmBtn:AddUIEvent("click", function ()
				CFirstChargeView:ShowView()
			end)
		else
			oPart.m_TipLabel:SetText("完成首充可获得此伙伴")
			oPart.m_ConfirmBtn:SetActive(true)
			oPart.m_ConfirmBtn:SetText("前往")
			oPart.m_ConfirmBtn:AddUIEvent("click", function ()
				CFirstChargeView:ShowView()
			end)
		end
	else
		if g_PartnerCtrl:IsGetPartner(self.m_CurID) then
			oPart.m_TipLabel:SetText("累计充值可以获得黑碎片用于伙伴升星")
			oPart.m_ConfirmBtn:SetActive(true)
			oPart.m_ConfirmBtn:SetText("前往")
			oPart.m_ConfirmBtn:AddUIEvent("click", function ()
				g_OpenUICtrl:OpenTotalPay()
			end)
		else
			oPart.m_TipLabel:SetText("完成首充可获得此伙伴")
			oPart.m_ConfirmBtn:SetActive(true)
			oPart.m_ConfirmBtn:SetText("前往")
			oPart.m_ConfirmBtn:AddUIEvent("click", function ()
				CFirstChargeView:ShowView()
			end)
		end
	end
end

function CPartnerHireView.ShowDL(self)
	local oPart = self.m_DLPart
	oPart:SetActive(true)
	if not oPart.m_Init then
		oPart.m_Init = true
		oPart.m_TipLabel = oPart:NewUI(1, CLabel)
		oPart.m_ConfirmBtn = oPart:NewUI(2, CButton)
		oPart.m_ConfirmBtn:AddUIEvent("click", function ()
			if g_LoginRewardCtrl:IsHasLoginReward() and
				g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.loginreward.open_grade and 
				data.globalcontroldata.GLOBAL_CONTROL.loginreward.is_open == "y" then
				g_TaskCtrl.m_IsOpenLoginRewardView = true
				g_GuideCtrl:ReqTipsGuideFinish("mainmenu_loginreward_btn")
				CLoginRewardView:ShowView()
			else
				g_NotifyCtrl:FloatMsg("活动已结束")
			end
		end)
	end
end

function CPartnerHireView.ShowTarget(self)
	local oPart = self.m_TargetPart
	oPart:SetActive(true)
	if not oPart.m_Init then
		oPart.m_Init = true
		oPart.m_TipLabel = oPart:NewUI(1, CLabel)
		oPart.m_ConfirmBtn = oPart:NewUI(2, CButton)
		oPart.m_ConfirmBtn:AddUIEvent("click", function ()
			if g_WelfareCtrl:IsOpenSevenDayTarget() then
				g_WelfareCtrl:ForceSelect(define.Welfare.ID.SevenDayTarget)
			else
				g_NotifyCtrl:FloatMsg("活动已结束")
			end
		end)
	end
end

CPartnerHireView.SSRNEEDAMOUNT = 80
function CPartnerHireView.ShowSSR(self)
	local oPart = self.m_SSRPart
	oPart:SetActive(true)
	if not oPart.m_Init then
		oPart.m_Init = true
		oPart.m_ItemTipsBox = oPart:NewUI(1, CItemTipsBox)
		oPart.m_Silder = oPart:NewUI(2, CSlider)
		oPart.m_ChipBtn = oPart:NewUI(3, CButton)
		oPart.m_ComposeCostLabel = oPart:NewUI(4, CLabel)
	end

	oPart.m_ItemTipsBox:SetActive(true)
	oPart.m_ComposeCostLabel:SetActive(false)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(10019)
	if iAmount > 0 then
		oPart.m_ItemTipsBox:SetItemData(10019, 1, nil, {isLocal = true, uiType = 1, openView = self})
		local iNeedAmount = 1
		oPart.m_Silder:SetActive(true)
		oPart.m_Silder:SetSliderText(string.format("%d/%d", iAmount, iNeedAmount))
		oPart.m_Silder:SetValue(iAmount/iNeedAmount)
		oPart.m_ChipBtn:SetText("使用")
		oPart.m_ChipBtn:AddUIEvent("click", callback(self, "OnSSRDraw"))
	else
		local iChipType = 13212
		oPart.m_ItemTipsBox:SetItemData(iChipType, 1, nil, {isLocal = true, uiType = 1, openView = self})
		local iAmount = g_ItemCtrl:GetBagItemAmountBySid(iChipType)
		local iNeedAmount = CPartnerHireView.SSRNEEDAMOUNT
		oPart.m_Silder:SetActive(true)
		oPart.m_Silder:SetSliderText(string.format("%d/%d", iAmount, iNeedAmount))
		oPart.m_Silder:SetValue(iAmount/iNeedAmount)
		if iAmount >= iNeedAmount then
			oPart.m_ChipBtn:SetText("合成")
			oPart.m_ChipBtn:AddUIEvent("click", callback(self, "OnSSRChipCompose", iChipType, true))
		else
			oPart.m_ComposeCostLabel:SetActive(true)
			oPart.m_ChipBtn:SetText("一键合成")
			oPart.m_ComposeCostLabel:SetText("#w2"..tostring((iNeedAmount-iAmount)*300))
			oPart.m_ChipBtn:AddUIEvent("click", callback(self, "OnFastSSRChipCompose", iChipType, false))
		end
	end
end

function CPartnerHireView.ShowZZCard(self)
	local oPart = self.m_ZZCardPart
	oPart:SetActive(true)
	if not oPart.m_Init then
		oPart.m_Init = true
		oPart.m_TipLabel = oPart:NewUI(1, CLabel)
		oPart.m_ConfirmBtn = oPart:NewUI(2, CButton)
		oPart.m_TipLabel:SetText("获得终身卡后可选择获取伙伴")
		oPart.m_ConfirmBtn:AddUIEvent("click", function ()
			g_OpenUICtrl:OpenYueKa()
		end)
	end
end

function CPartnerHireView.OnChangeType(self)
	if self.m_SSRBtn:GetSelected() then
		self.m_PartnerType = 2
	else
		self.m_PartnerType = 1
	end
	self:RefreshContent()
end

function CPartnerHireView.OnZMPartner(self)
	local dConfig = self:GetHireConfig(self.m_CurID)
	local dData = data.partnerhiredata.DATA[self.m_CurID]
	if g_AttrCtrl.grade < dConfig.level then
		g_NotifyCtrl:FloatMsg(string.format("%d级后可解锁招募", dConfig.level))
		return
	end
	local iTimes = g_PartnerCtrl:GetHireTime(self.m_CurID) 
	if dData["max_times"] > 0 and iTimes >= dData["max_times"] then
		g_NotifyCtrl:FloatMsg("招募次数已达到上限")
		return
	end

	if g_AttrCtrl.arenamedal < dConfig.arena_cost then
		g_NotifyCtrl:FloatMsg("荣誉不足")
			CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetInitBox(1009, nil, {})
			oView:ForceShowFindWayBox(true)
		end)
		return
	end
	if g_AttrCtrl.coin < dConfig.coin_cost then
		g_WindowTipCtrl:ShowNoGoldTips(1)
		return
	end
	if g_AttrCtrl.goldcoin < dConfig.goldcoin then
		g_WindowTipCtrl:ShowNoGoldTips(2)
		return
	end
	nethuodong.C2GSHirePartner(self.m_CurID)
end

function CPartnerHireView.OnChipCompose(self, iChipType, bEnough)
	if iChipType and bEnough then
		netpartner.C2GSComposePartner(iChipType, 1)
	else
		CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetInitBox(iChipType, nil, {})
			oView:ForceShowFindWayBox(true)
		end)
		g_NotifyCtrl:FloatMsg("碎片不足")
	end
end

function CPartnerHireView.OnSSRChipCompose(self, iChipType, bEnough)
	if iChipType and bEnough then
		CItemTipsPropComposeView:ShowView(function (oView)
			oView:SetItem(iChipType)
		end)
	else
		CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetInitBox(iChipType, nil, {})
			oView:ForceShowFindWayBox(true)
		end)
		g_NotifyCtrl:FloatMsg("碎片不足")
	end
end

function CPartnerHireView.OnSSRDraw(self)
	local itemID = g_ItemCtrl:GetItemSerberIdListBySid(10019)
	if itemID then
		g_ItemCtrl:C2GSItemUse(itemID, g_AttrCtrl.pid, 1)
	end
end

function CPartnerHireView.OnFastSSRChipCompose(self)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(13212)
	local iNeedAmount = CPartnerHireView.SSRNEEDAMOUNT
	if iAmount < iNeedAmount then
		local windowConfirmInfo = {
			msg				= string.format("是否消耗#w2%d购买一发入魂碎片并合成一发入魂契约？", (iNeedAmount-iAmount)*300),
			okCallback		= function ()
				netitem.C2GSComposeItem(13212, 1, 1)
			end,
			okStr = "是",
			cancelStr = "否",			
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	end
	
end
function CPartnerHireView.OnShowAwakeTip(self)
	CPartnerHireTipsView:ShowView(function (oView)
		oView:SetPartner(self.m_CurID)
	end)
end

function CPartnerHireView.SetChangeType(self, iType)
	if iType == 2 then
		self.m_SSRBtn:SetSelected(true)
	else
		self.m_RBtn:SetSelected(true)
	end
	self:OnChangeType()
end

return CPartnerHireView
