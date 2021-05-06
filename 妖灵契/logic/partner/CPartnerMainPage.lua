local CPartnerMainPage = class("CPartnerMainPage", CPageBase)

function CPartnerMainPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerMainPage.OnInitPage(self)
	self.m_ActorTexture = self:NewUI(2, CActorTexture)
	self.m_AttrBox = self:NewUI(3, CBox)
	self.m_NameLabel = self:NewUI(5, CLabel)
	self.m_RenameBtn = self:NewUI(6, CButton)
	self.m_LockBtn = self:NewUI(7, CButton)
	self.m_CommentBtn = self:NewUI(8, CButton)
	self.m_BreedBtn = self:NewUI(9, CButton)
	self.m_SkillGrid = self:NewUI(10, CGrid)
	self.m_SkillBox = self:NewUI(11, CBox)
	self.m_ExpProgress = self:NewUI(12, CSlider)
	self.m_ExpLabel = self:NewUI(13, CLabel)
	self.m_EmptyTexture = self:NewUI(14, CTexture)
	self.m_ShowPart = self:NewUI(15, CBox)
	self.m_NoUpdateLabel = self:NewUI(16, CLabel)
	self.m_GradeLabel = self:NewUI(17, CLabel)
	self.m_TipsBtn = self:NewUI(18, CButton)
	self.m_StarBox = self:NewUI(19, CBox)
	self.m_PowerLabel = self:NewUI(20, CLabel)
	self.m_FoodSpr = self:NewUI(21, CSprite)
	self.m_ChipBtn = self:NewUI(22, CButton)
	self.m_LeftBtn = self:NewUI(23, CButton)
	self.m_RightBtn = self:NewUI(24, CButton)
	self.m_FollowBtn = self:NewUI(25, CButton)
	self.m_HouseBuffBtn = self:NewUI(26, CButton)
	self.m_PowerRankLabel = self:NewUI(27, CLabel)
	self.m_AmountLabel = self:NewUI(28, CLabel)
	
	self.m_SkillBox:SetActive(false)
	self.m_TipsBtn:SetActive(false)
	self.m_FoodSpr:SetActive(false)
	self.m_BreedBtn.m_IgnoreCheckEffect = true
	self.m_HouseBuffBtn:AddUIEvent("click", callback(self, "OnHouseBuffBtn"))
	self.m_RenameBtn:AddUIEvent("click", callback(self, "OnRename"))
	self.m_LockBtn:AddUIEvent("click", callback(self, "OnLock"))
	self.m_CommentBtn:AddUIEvent("click", callback(self, "OnComment"))
	self.m_BreedBtn:AddUIEvent("click", callback(self, "OnBreed"))
	self.m_FollowBtn:AddUIEvent("click", callback(self, "OnFollow"))
	self.m_ChipBtn:AddUIEvent("click", callback(self, "OnShowChipCompose"))
	self.m_LeftBtn:AddUIEvent("click", callback(self, "OnLeftOrRightBtn", 1))
	self.m_RightBtn:AddUIEvent("click", callback(self, "OnLeftOrRightBtn", -1))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_PowerRankLabel:AddUIEvent("click", callback(self, "OnClickPowerRank"))

	self.m_CurParID = nil
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:InitAttrGrid()
end

function CPartnerMainPage.InitAttrGrid(self)
	local t = {
		{k="气血",v="maxhp"},
		{k="攻击",v="attack"},
		{k="防御",v="defense"},
		{k="速度",v="speed"},
		{k="暴击",v="critical_ratio"},
		{k="抗暴",v="res_critical_ratio"},
		{k="暴击伤害", v="critical_damage"},
		{k="治疗暴击",v="cure_critical_ratio"},
		{k="异常命中",v="abnormal_attr_ratio"},
		{k="异常抵抗",v="res_abnormal_ratio"},
	}
	self.m_AttrBoxList = {}
	for k, v in ipairs(t) do
		local oBox = self.m_AttrBox:NewUI(k, CBox)
		oBox:SetActive(true)
		oBox.m_AttrName = oBox:NewUI(1, CLabel)
		oBox.m_AttrValue = oBox:NewUI(2, CLabel)
		oBox.m_LevelSpr = oBox:NewUI(3, CSprite)
		oBox.m_AttrName:SetText(v["k"])
		oBox.m_AttrKey = v["v"]
		oBox.m_Name = v["k"]
		self.m_AttrBoxList[k] = oBox
	end
end

function CPartnerMainPage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		if oCtrl.m_EventData == self.m_CurParID then
			self:UpdatePartner()
		end
	elseif oCtrl.m_EventID == define.Partner.Event.UpdateRedPoint then
		if oCtrl.m_EventData == self.m_CurParID then
			self:UpdateRedPoint()
		end
	end
end

function CPartnerMainPage.OnShowPage(self)
	local oBuffInfo = g_PlayerBuffCtrl:GetHouseBuff()
	local oBuffData = data.housedata.LoveBuff[oBuffInfo.stage]
	self.m_HouseBuffBtn:SpriteHouseBuff(oBuffData.icon)
	self.m_HouseBuffBtn:SetActive(oBuffInfo.stage > 0)
	self:SetPartnerID(self.m_ParentView:GetCurPartnerID())
	if self:IsComposeChip() then
		self.m_ChipBtn:AddEffect("RedDot")
	else
		self.m_ChipBtn:DelEffect("RedDot")
	end
end

function CPartnerMainPage.SetPartnerID(self, parid)
	self.m_CurParID = parid
	self:UpdatePartner()
end

function CPartnerMainPage.UpdatePartner(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	self.m_PowerRankLabel:SetActive(false)
	if not oPartner then
		return
	end
	g_GuideCtrl:AddGuideUI("partner_main_breed_btn", self.m_BreedBtn)
	if oPartner:GetValue("partner_type") == 302 then
		g_GuideCtrl:AddGuideUI("partner_main_breed_302_btn", self.m_BreedBtn)
	else
		g_GuideCtrl:AddGuideUI("partner_main_breed_302_btn")
	end
	g_GuideCtrl:AddGuideUI("partner_chip_compose_show_btn", self.m_ChipBtn)

	self.m_BreedBtn:DelEffect("Finger3")
	local guide_ui = {"partner_chip_compose_show_btn", "partner_main_breed_302_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)

	if oPartner:HasRank() then
		self.m_PowerRankLabel:SetActive(true)
		self.m_PowerRankLabel:SetText(oPartner:GetRankStr())
	end
	local shape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
	self.m_ActorTexture:ChangeShape(shape, {})
	
	self.m_NameLabel:SetText(oPartner:GetValue("name"))
	self.m_RenameBtn:SetActive(false)
	self.m_RenameBtn:SetActive(true)
	self.m_PowerLabel:SetText(tostring(oPartner:GetValue("power")))
	self.m_GradeLabel:SetText(string.format("Lv:%d/%d",oPartner:GetValue("grade"), g_AttrCtrl.grade + 5))
	if oPartner:IsLock() then
		self.m_LockBtn:SetSpriteName("btn_huoban_shangsuo")
		self.m_LockBtn:SetText("已锁")
	else
		self.m_LockBtn:SetSpriteName("btn_huoban_weishangsuo")
		self.m_LockBtn:SetText("未锁")
	end
	if oPartner:IsFollow() then
		self.m_FollowBtn:SetText("隐藏")
	else
		self.m_FollowBtn:SetText("跟随")
	end
	local curexp = oPartner:GetCurExp()
	local needexp = oPartner:GetNeedExp()
	self.m_ExpProgress:SetValue(curexp / needexp)
	self.m_ExpLabel:SetText(string.format("%d/%d", curexp, needexp))
	if oPartner:IsNormalType() or oPartner:IsStarType() then
		self.m_BreedBtn:SetActive(true)
		self.m_NoUpdateLabel:SetActive(false)
		self.m_ExpProgress:SetActive(true)
		self.m_ExpLabel:SetActive(true)
	else
		self.m_ExpLabel:SetActive(false)
		self.m_BreedBtn:SetActive(false)
		self.m_ExpProgress:SetActive(false)
		self.m_NoUpdateLabel:SetActive(true)
	end
	local controlData = data.globalcontroldata.GLOBAL_CONTROL.partnerrecommend
	if g_AttrCtrl.grade >= controlData.open_grade and controlData.is_open == "y" then
		self.m_TipsBtn:SetActive(true)
	else
		self.m_TipsBtn:SetActive(false)
	end
	self:UpdateRedPoint()
	self:UpdateAttr()
	self:UpdateFoodSpr(oPartner:GetValue("partner_type"))
	self:UpdateStar(oPartner:GetValue("star"))
	self:UpdateAmount()
	self:UpdateSkill()
end

function CPartnerMainPage.ShowUI(self, bshow)
	self.m_ShowPart:SetActive(bshow)
	self.m_EmptyTexture:SetActive(not bshow)
end

function CPartnerMainPage.SetNonePartner(self)
	self:ShowUI(false)
end

function CPartnerMainPage.UpdateAttr(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	local funcGetAttrLevel = oPartner.GetAttrLevel
	if oPartner:GetValue("awake") == 1 then
		funcGetAttrLevel = oPartner.GetAwakeAttrLevel
	end
	for k, oItem in ipairs(self.m_AttrBoxList) do
		local iLevel = funcGetAttrLevel(oPartner, oItem.m_AttrKey)
		oItem.m_LevelSpr:SetSpriteName("text_level_"..tostring(iLevel))
		oItem.m_AttrName:SetText(oItem.m_Name)
		if string.endswith(oItem.m_AttrKey, "_ratio") or oItem.m_AttrKey == "critical_damage" then
			local value = math.floor(oPartner:GetValue(oItem.m_AttrKey)/10)/10
			if math.isinteger(value) then
				oItem.m_AttrValue:SetText(string.format("%d%%", value))
			else
				oItem.m_AttrValue:SetText(string.format("%.1f%%", value))
			end
		else
			oItem.m_AttrValue:SetText(string.format("%d", oPartner:GetValue(oItem.m_AttrKey)))
		end
	end
end

function CPartnerMainPage.UpdateSkill(self)
	self.m_SkillGrid:Clear()
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
	for _, skillobj in ipairs(list) do
		local box = self.m_SkillBox:Clone()
		box:SetActive(true)
		box.m_Label = box:NewUI(1, CLabel)
		box.m_Icon = box:NewUI(2, CSprite)
		box.m_LockSpr = box:NewUI(3, CSprite, false)
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

function CPartnerMainPage.UpdateRedPoint(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	if oPartner:IsHasUpStarRedPoint() then
		self.m_BreedBtn:AddEffect("RedDot")
	else
		self.m_BreedBtn:DelEffect("RedDot")
	end
end

function CPartnerMainPage.UpdateStar(self, iStar)
	if not self.m_StarList then
		self.m_StarList = {}
		for i = 1, 5 do
			self.m_StarList[i] = self.m_StarBox:NewUI(i, CSprite)
		end
	end
	
	for i = 1, 5 do
		if iStar >= i then
			self.m_StarList[i]:SetSpriteName("pic_chouka_dianliang")
		else
			self.m_StarList[i]:SetSpriteName("pic_chouka_weidianliang")
		end
	end
end

function CPartnerMainPage.UpdateFoodSpr(self, iType)
	local sprName = nil
	if iType == 1753 then
		sprName = "text_huoban_shengxing"
	elseif iType == 1754 then
		sprName = "text_huoban_shengji"
	elseif iType == 1755 then
		sprName = "text_huoban_shengjineng"
	end
	if sprName then
		self.m_FoodSpr:SetActive(true)
		self.m_FoodSpr:SetSpriteName(sprName)
	else
		self.m_FoodSpr:SetActive(false)
	end
end

function CPartnerMainPage.UpdateAmount(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	if oPartner:IsRedBun() then
		self.m_FollowBtn:SetActive(false)
		self.m_LockBtn:SetActive(false)
		self.m_AmountLabel:SetActive(true)
		self.m_RenameBtn:SetActive(false)
		self.m_CommentBtn:SetLocalPos(Vector3.New(-217, -240, 0))
		self.m_AmountLabel:SetText(string.format("数量：%d", oPartner:GetValue("amount")))
	else
		self.m_RenameBtn:SetActive(true)
		self.m_FollowBtn:SetActive(true)
		self.m_LockBtn:SetActive(false)
		self.m_AmountLabel:SetActive(false)
		self.m_CommentBtn:SetLocalPos(Vector3.New(-217, -164, 0))
	end
end

function CPartnerMainPage.IsComposeChip(self)
	local list = g_PartnerCtrl:GetChipByRare(0)
	for _, oItem in ipairs(list) do
		local haveamount = oItem:GetValue("amount")
		local needamount = oItem:GetValue("compose_amount")
		if haveamount >= needamount then
			return true
		end
	end
	return false
end

function CPartnerMainPage.OnHouseBuffBtn(self)
	CPartnerHouseBuffView:ShowView()
end

function CPartnerMainPage.OnRename(self)
	local windowInputInfo = {
		des				= "输入伙伴的新名字（最多6个字）",
		title			= "改名",
		inputLimit		= 12,
		okCallback		= function (input)
		 	self:ConfirmRename(input)
		end,
		cancelCallback  = function() end,
		isclose         = false,
		defaultText		= "请输入名称"
	}
	
	g_WindowTipCtrl:SetWindowInput(windowInputInfo)
end

function CPartnerMainPage.ConfirmRename(self, input)
	if input:GetInputLength() == 0 then 
		g_NotifyCtrl:FloatMsg("伙伴不能没有姓名哦，请给伙伴取个名字吧!")
		return
	end 
	local name = input:GetText()
	if g_MaskWordCtrl:IsContainMaskWord(name) or string.isIllegal(name) == false then 
		g_NotifyCtrl:FloatMsg("内容中包含非法文字和词汇，请重新为小伙伴取名")
		return
	end
	netpartner.C2GSRenamePartner(self.m_CurParID, name)
	CItemTipsInputWindowView:CloseView()
end

function CPartnerMainPage.OnLock(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if oPartner:IsLock() then
		netpartner.C2GSSetPartnerLock(self.m_CurParID, 0)
	else
		netpartner.C2GSSetPartnerLock(self.m_CurParID, 1)
	end

end

function  CPartnerMainPage.OnFollow(self)
	--IsFollow
	if g_ConvoyCtrl:IsConvoying() then
		g_NotifyCtrl:FloatMsg(data.huodongblockdata.DATA.convoy.tips)
	else
		local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
		g_PartnerCtrl:SetFollower(oPartner)
	end
end

function CPartnerMainPage.OnComment(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	netpartner.C2GSPartnerCommentInfo(oPartner:GetValue("partner_type"))
end

function CPartnerMainPage.OnBreed(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	local grade = oPartner:GetValue("grade")
	local star = oPartner:GetValue("star")

	g_GuideCtrl:ReqTipsGuideFinish("partner_main_breed_302_btn")

	if g_GuideCtrl:IsCustomGuideFinishByKey("Partner_HBJN_MainMenu") and not g_GuideCtrl:IsCustomGuideFinishByKey("Partner_HBJN_PartnerMain") then
		CPartnerImproveView:ShowView(function(oView)
			oView:OnChangePartner(self.m_CurParID)
		end)

	elseif oPartner:CanUpStar() then
		CPartnerImproveView:ShowView(function(oView)
			oView:ShowUpStarPage()
			oView:OnChangePartner(self.m_CurParID)
		end)

	else
		CPartnerImproveView:ShowView(function(oView)
			oView:OnChangePartner(self.m_CurParID)
		end)
	end
end

function CPartnerMainPage.OnClickSkill(self, oBox)
	g_WindowTipCtrl:SetWindowPartnerSKillInfo(oBox.m_ID, oBox.m_Level, oBox.m_IsAwake)
end

function CPartnerMainPage.OnClickHelp(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if oPartner then
		CPowerGuideMainView:ShowView(function (oView)
			oView:ShowPartnerCommand(oPartner:GetValue("partner_type"))
		end)
	end
end

function CPartnerMainPage.OnShowPartnerScroll(self)
	self.m_ParentView:ShowPartnerScroll()
end

function CPartnerMainPage.OnShowChipCompose(self)
	g_GuideCtrl:ReqTipsGuideFinish("partner_chip_compose_show_btn")
	--伙伴合成引导
	if g_GuideCtrl:IsCompleteTipsGuideByKey("Tips_PartnerChip_Compose_2") and not g_GuideCtrl:IsCompleteTipsGuideByKey("Tips_PartnerChip_Compose_3") then		
		local parid = g_PartnerCtrl:GetCanComposePanterChipSid()	
		self.m_ParentView:ShowComposePage(parid)	
	else
		self.m_ParentView:ShowComposePage()	
	end	
end

function CPartnerMainPage.OnLeftOrRightBtn(self, idx)
	local list = g_PartnerCtrl:GetPartnerList()
	table.sort(list, callback(self, "PartnerSortFunc"))
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

function CPartnerMainPage.PartnerSortFunc(cls, oPartner1, oPartner2)
	local pos1 = g_PartnerCtrl:GetFightPos(oPartner1:GetValue("parid")) or 9999
	local pos2 = g_PartnerCtrl:GetFightPos(oPartner2:GetValue("parid")) or 9999
	if pos1 ~= pos2 then
		return pos1 < pos2
	end
	local iPowner1 = oPartner1:GetValue("power")
	local iPowner2 = oPartner2:GetValue("power")
	if iPowner1 and iPowner2 and iPowner1 ~= iPowner2 then
		return iPowner2 < iPowner1
	end
	local iRare1 = oPartner1:GetValue("rare")
	local iRare2 = oPartner2:GetValue("rare")
	if iRare1 and iRare2 and iRare1 ~= iRare2 then
		return oPartner1:GetValue("rare") < oPartner2:GetValue("rare")
	end
	return oPartner1:GetValue("parid") < oPartner2:GetValue("parid")
end

function CPartnerMainPage.OnClickPowerRank(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	g_RankCtrl:OpenRank(define.Rank.RankId.Partner, oPartner:GetValue("partner_type"))
end

return CPartnerMainPage