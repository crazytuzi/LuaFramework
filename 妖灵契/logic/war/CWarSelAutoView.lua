local CWarSelAutoView = class("CWarSelAutoView", CViewBase)

function CWarSelAutoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarSelAutoView.prefab", cb)
	
	self.m_ExtendClose = "ClickOut"
end

function CWarSelAutoView.OnCreateView(self)
	self.m_MagicGrid = self:NewUI(1, CGrid)
	self.m_ExtraGrid = self:NewUI(2, CGrid)
	self.m_RepositionTable = self:NewUI(3, CTable)
	self.m_MagicBoxClone = self:NewUI(4, CBox)
	self.m_NameLabel = self:NewUI(5, CLabel)
	self.m_Bg = self:NewUI(6, CSprite)
	self.m_CurSelID = nil
	self.m_Wid = nil
	self.m_MagicBoxClone:SetActive(false)
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvent"))
end

function CWarSelAutoView.SetWid(self, wid, idx)
	self.m_Wid = wid
	local oWarrior = g_WarCtrl:GetWarrior(wid)
	if oWarrior.m_PartnerID then
		self.m_NameLabel:SetText("选择伙伴自动技能")
	elseif oWarrior.m_ID == g_WarCtrl.m_HeroWid then
		self.m_NameLabel:SetText("选择人物自动技能")
	else
		self.m_NameLabel:SetText("选择友方自动技能")
	end
	self.m_CurSelID = oWarrior:GetAutoMagic()	
	self:RefreshMagic(idx)
end

function CWarSelAutoView.RefreshMagic(self, idx)
	self.m_MagicGrid:Clear()
	local lMagics = self:GetMagicList()
	for i, magicid in ipairs(lMagics) do
		local oBox = self:CreateMagicBox(magicid, i)
		self.m_MagicGrid:AddChild(oBox)
		if i >= 1 and i <= 2 then
			g_GuideCtrl:AddGuideUI(string.format("war_select_auto_skill_box%d", i), oBox)
		end			
	end
	self.m_MagicGrid:Reposition()
	local lExtraMagics = self:GetExtraMagicList()
	self.m_ExtraGrid:Clear()
	for i, magicid in ipairs(lExtraMagics) do
		local oBox = self:CreateMagicBox(magicid, i)
		self.m_ExtraGrid:AddChild(oBox)	
	end
	self.m_ExtraGrid:Reposition()
	self.m_RepositionTable:Reposition()
	local bounds = UITools.CalculateRelativeWidgetBounds(self.m_RepositionTable.m_Transform)
	self.m_Bg:SetHeight(bounds.max.y-bounds.min.y+20)

	--引导处理
	if idx and g_GuideCtrl:GetGuideWar4Step() ~= 0 then
		if table.key(g_GuideCtrl.m_War4AutoBoxSelectIdx, idx) then
			g_GuideCtrl:SetGuideWar4Step(2)
			g_GuideCtrl:StartWar4StepTwo()
		else
			g_GuideCtrl:StoptWar4StepTwo()
			g_GuideCtrl:SetGuideWar4Step(1)
		end
	end
	--引导处理
end

function CWarSelAutoView.CreateMagicBox(self, magicid, idx)
	local oBox = self.m_MagicBoxClone:Clone()
	oBox:SetActive(true)
	oBox.m_Icon = oBox:NewUI(1, CSprite)
	oBox.m_CostLabel = oBox:NewUI(2, CLabel)
	oBox.m_LockSpr = oBox:NewUI(3, CSprite)
	oBox.m_BoutLabel = oBox:NewUI(4, CLabel)
	oBox.m_MaigID = magicid
	local dData = DataTools.GetMagicData(magicid)
	oBox.m_Icon:SpriteMagic(magicid)
	if dData and dData.sp and dData.sp > 0 then
		oBox.m_CostLabel:SetActive(true)
		oBox.m_CostLabel:SetText(tostring(dData.sp/20))
	else
		oBox.m_CostLabel:SetActive(false)
	end
	local dSkillData = g_SkillCtrl:GetSkillBaseDataById(magicid)
	if dSkillData and dSkillData.unlock_grade then
		oBox.m_Lock = dSkillData.unlock_grade > g_AttrCtrl.grade
	else
		oBox.m_Lock = false
	end
	oBox.m_LockSpr:SetActive(oBox.m_Lock)

	oBox.m_CD = g_WarCtrl:GetMagicCD(self.m_Wid, magicid)
	if oBox.m_CD > 0 then
		oBox.m_BoutLabel:SetText(tostring(oBox.m_CD))
		oBox.m_Icon:SetGrey(true)
	else
		oBox.m_Icon:SetGrey(false)
		oBox.m_BoutLabel:SetText("")
	end

	oBox:AddUIEvent("click", callback(self, "OnSelMagic", idx))
	oBox:SetGroup(self:GetInstanceID())
	oBox:SetSelected(self.m_CurSelID == magicid)
	return oBox
end

function CWarSelAutoView.GetMagicList(self)
	return g_WarCtrl:GetMagicList(self.m_Wid)
end

function CWarSelAutoView.GetExtraMagicList(self)
	return {}
end

function CWarSelAutoView.OnSelMagic(self, idx, oBox)
	if g_GuideCtrl:GetGuideWar4Step() == 2 and idx == 2 then
		g_GuideCtrl:ReqCustomGuideWar4Finish()
	end

	if oBox.m_Lock then
		g_NotifyCtrl:FloatMsg("技能未解锁")
		return
	end
	--[[
	if oBox.m_CD > 0 then
		g_NotifyCtrl:FloatMsg("技能冷却中")
		return
	end
	]]
	local iWar = g_WarCtrl:GetWarID()
	g_WarOrderCtrl:ChangeAutoMagicByWid(self.m_Wid, oBox.m_MaigID)
	netwar.C2GSChangeAutoSkill(iWar, self.m_Wid, oBox.m_MaigID)
	g_WarCtrl:C2GSSelectCmd(iWar, self.m_Wid, oBox.m_MaigID)
	self:CloseView()
	local warMain = CWarMainView:GetView()
	if warMain then
		local oView = CWarFloatView:GetView()
		if oView then
			local level = g_WarCtrl:GetMagicLevel(self.m_Wid, oBox.m_MaigID)
			level = level or 0
			local oDescBox = oView:ShowMagicDesc(oBox.m_MaigID, level)
			local list = warMain.m_RB.m_AutoMenu.m_MagicGrid:GetChildList()
				UITools.NearTarget(list[1], oDescBox, enum.UIAnchor.Side.TopLeft)
		end
	end
end

function CWarSelAutoView.OnWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.BoutStart and self.m_Wid then
		self:RefreshMagic()
	end
end

function CWarSelAutoView.Destroy(self)
	CViewBase.Destroy(self)
	if g_GuideCtrl:GetGuideWar4Step() == 2 then
		g_GuideCtrl:StoptWar4StepTwo()
		g_GuideCtrl:SetGuideWar4Step(0)
		g_GuideCtrl:TriggerCheckWarGuide()
	end
	if g_WarCtrl:GetWarType() == define.War.Type.Guide2 then
		CGuideView:CloseView()
	end	
end


return CWarSelAutoView