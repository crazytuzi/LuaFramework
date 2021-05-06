local CPartnerImproveView = class("CPartnerImproveView", CViewBase)

function CPartnerImproveView.ctor(self, cb)
	CViewBase.ctor(self, "UI/partner/PartnerImproveView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_GroupName = "main"
end

function CPartnerImproveView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TabGrid = self:NewUI(3, CGrid)
	self.m_ModelPart = self:NewUI(4, CBox)
	self.m_UpGradePage = self:NewPage(5, CPartnerUpGradePage)
	self.m_UpStarPage = self:NewPage(6, CPartnerUpStarPage)
	self.m_AwakePage = self:NewPage(7, CPartnerAwakePage)
	self.m_UpSkillPage = self:NewPage(8, CPartnerUpSkillPage)
	self:InitContent()
end

function CPartnerImproveView.InitContent(self)
	self.m_TabGrid:InitChild(function(obj, idx)
		local oBtn = CBox.New(obj, false)
		oBtn:SetGroup(self.m_TabGrid:GetInstanceID())
		return oBtn
	end)
	self.m_UpGradeBtn = self.m_TabGrid:GetChild(1)
	self.m_UpStarBtn = self.m_TabGrid:GetChild(2)
	self.m_UpSkillBtn = self.m_TabGrid:GetChild(3)
	self.m_AwakeBtn = self.m_TabGrid:GetChild(4)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_UpGradeBtn:AddUIEvent("click", callback(self, "OnShowGrade"))
	self.m_UpStarBtn:AddUIEvent("click", callback(self, "OnShowStar"))
	self.m_UpSkillBtn:AddUIEvent("click", callback(self, "OnShowSkill"))
	self.m_AwakeBtn:AddUIEvent("click", callback(self, "OnShowAwake"))
	
	g_GuideCtrl:AddGuideUI("partner_upgrade_close_btn", self.m_CloseBtn)

	self:InitModelPart()

	self:ShowUpGradePage()
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CPartnerImproveView.InitModelPart(self)
	self.m_TurnLeftBtn = self.m_ModelPart:NewUI(1, CButton)
	self.m_TurnRightBtn = self.m_ModelPart:NewUI(2, CButton)
	self.m_ActorTexture = self.m_ModelPart:NewUI(3, CActorTexture)
	self.m_StarBox = self.m_ModelPart:NewUI(4, CBox)
	self.m_StarList = {}
	for i = 1, 5 do
		local spr = self.m_StarBox:NewUI(i, CSprite)
		self.m_StarList[i] = spr
	end
	self.m_NameLabel = self.m_ModelPart:NewUI(5, CLabel)
	self.m_SwitchBtn = self.m_ModelPart:NewUI(6, CButton)
	self.m_NameBG = self.m_ModelPart:NewUI(7, CSprite)
	
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnSwitchPartner"))
	self.m_TurnLeftBtn:AddUIEvent("click", callback(self, "OnLeftOrRightBtn", 1))
	self.m_TurnRightBtn:AddUIEvent("click", callback(self, "OnLeftOrRightBtn", -1))
end

function CPartnerImproveView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		if oCtrl.m_EventData == self.m_CurParID then
			self:UpdatePartner(self.m_CurParID)
		end
	end
end

function CPartnerImproveView.OnChangePartner(self, iParID)
	self.m_CurParID = iParID
	self:UpdatePartner(iParID)
	if self.m_CurPage then
		self.m_CurPage:SetPartnerID(iParID)
	end
end


function CPartnerImproveView.UpdatePartner(self, iParID)
	local oPartner = g_PartnerCtrl:GetPartner(iParID)
	if not oPartner then
		return
	end
	if oPartner:GetValue("partner_type") == 302 then
		g_GuideCtrl:AddGuideUI("partner_improve_star_tab_302_btn", self.m_TabGrid:GetChild(2))
		local guide_ui = {"partner_improve_star_tab_302_btn"}
		g_GuideCtrl:LoadTipsGuideEffect(guide_ui)		
	end
	
	self.m_NameLabel:SetText(oPartner:GetValue("name"))
	self.m_NameBG:SetHeight(self.m_NameLabel:GetHeight()+30)
	local shape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
	self.m_ActorTexture:ChangeShape(shape, {})
	local iStar = oPartner:GetValue("star")
	for i = 1, 5 do
		if iStar >= i then
			self.m_StarList[i]:SetSpriteName("pic_chouka_dianliang")
		else
			self.m_StarList[i]:SetSpriteName("pic_chouka_weidianliang")
		end
	end
end

function CPartnerImproveView.DefaultSelect(self, parid)
	--self.m_PartnerList:SetDefaultPartner(parid)
end

function CPartnerImproveView.GetCurPartnerID(self)
	return self.m_CurParID
end

function CPartnerImproveView.SetCurPartnerID(self, parid)
	self.m_CurParID = parid
end

function CPartnerImproveView.ShowUpGradePage(self)
	self:ShowSubPage(self.m_UpGradePage)
	self.m_CurPage = self.m_UpGradePage
	self.m_CurPage:SetPartnerID(self.m_CurParID)
	self.m_UpGradeBtn:SetSelected(true)
end

function CPartnerImproveView.ShowUpStarPage(self)
	self:ShowSubPage(self.m_UpStarPage)
	self.m_CurPage = self.m_UpStarPage
	self.m_CurPage:SetPartnerID(self.m_CurParID)
	self.m_UpStarBtn:SetSelected(true)
end

function CPartnerImproveView.ShowAwakePage(self)
	self:ShowSubPage(self.m_AwakePage)
	self.m_CurPage = self.m_AwakePage
	self.m_CurPage:SetPartnerID(self.m_CurParID)
	self.m_AwakeBtn:SetSelected(true)
end

function CPartnerImproveView.ShowUpSkillPage(self)
	self:ShowSubPage(self.m_UpSkillPage)
	self.m_CurPage = self.m_UpSkillPage
	self.m_CurPage:SetPartnerID(self.m_CurParID)
	self.m_UpSkillBtn:SetSelected(true)
end

function CPartnerImproveView.UpdateAttrResult(self, iParID, iType, dApplyList)
	if iType == 1 then
		self.m_UpGradePage:UpdateAttrResult(iParID, dApplyList)
	else
		self.m_UpStarPage:UpdateAttrResult(iParID, dApplyList)
	end
end

function CPartnerImproveView.DoUpGradeEffect(self)
	local function localcb(oEffect)
		if Utils.IsExist(self) then
			oEffect:SetParent(self.m_ActorTexture:GetActorTransform())
		end
	end
	local oEffect = CEffect.New("Effect/Game/game_eff_1168/Prefabs/game_eff_1168.prefab", define.Layer.ModelTexture, false, localcb)
	oEffect:AutoDestroy(2)
end

function CPartnerImproveView.DoUpStarEffect(self)
	if self.m_UpStarPage:GetActive() then
		self.m_UpStarPage:DoUpEffect()
	end
end

function CPartnerImproveView.DoSkillEffect(self, dSkill)
	if self.m_UpSkillPage:GetActive() then
		self.m_UpSkillPage:DoSkillEffect(dSkill)
	end
end

function CPartnerImproveView.OnClose(self)
	self:CloseView()
end

function CPartnerImproveView.OnShowGrade(self)
	self:ShowUpGradePage()
end

function CPartnerImproveView.OnShowStar(self)
	self:ShowUpStarPage()
	g_GuideCtrl:ReqTipsGuideFinish("partner_improve_star_tab_302_btn")
end

function CPartnerImproveView.OnShowAwake(self)
	self:ShowAwakePage()
end

function CPartnerImproveView.OnShowSkill(self)
	self:ShowUpSkillPage()
end

function CPartnerImproveView.OnFilterUpGrade(self, parList)
	if self.m_CurPage == self.m_UpStarPage then
		local list = {}
		for k, oPartner in ipairs(parList) do
			local grade = oPartner:GetValue("grade")
			local star = oPartner:GetValue("star")
			if grade >= data.partnerdata.UPSTAR[star]["limit_level"] and star < 5 then
				table.insert(list, oPartner)
			end
		end
		return list
	else
		local list = {}
		for k, oPartner in ipairs(parList) do
			if oPartner:IsNormalType() or oPartner:IsStarType() then
				table.insert(list, oPartner)
			end
		end
		return list
	end
end

function CPartnerImproveView.OnSwitchPartner(self)
	CPartnerChooseView:ShowView(function (oView)
		oView:SetConfirmCb(callback(self, "OnChangePartner"))
		oView:SetFilterCb(callback(self, "OnFilterUpGrade"))
	end)
end

function CPartnerImproveView.OnLeftOrRightBtn(self, idx)
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
		self:OnChangePartner(list[curIdx].m_ID)
	end
end


return CPartnerImproveView