local CCreateRoleBranchPage = class("CCreateRoleBranchPage", CPageBase)

function CCreateRoleBranchPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CCreateRoleBranchPage.OnInitPage(self)
	self.m_BranchBtn1 = self:NewUI(1, CCreateRoleBranchBox)
	self.m_BranchBtn2 = self:NewUI(2, CCreateRoleBranchBox)
	self.m_BackBtn = self:NewUI(3, CButton)
	self.m_SkillGrid = self:NewUI(4, CGrid)
	self.m_DescBox = self:NewUI(5, CBox)

	self.m_DescBox.m_Label = self.m_DescBox:NewUI(1, CLabel)
	self.m_DescBox.m_Bg = self.m_DescBox:NewUI(2, CSprite)
	self.m_DescBox.m_Bg:SetAlpha(0.01)
	self:InitContent()
end

function CCreateRoleBranchPage.InitContent(self)
	self.m_Pos1 = self.m_BranchBtn1.m_Btn:GetLocalPos()
	self.m_Scale1 = self.m_BranchBtn1.m_Btn:GetLocalScale()
	self.m_Pos2 = self.m_BranchBtn2.m_Btn:GetLocalPos()
	self.m_Scale2 = self.m_BranchBtn2.m_Btn:GetLocalScale()
	self.m_Tweening = false
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnClickBack"))
	self.m_SkillBoxArr = {}
	self.m_SkillGrid:InitChild(function (obj, idx)
		local oSkillBox = CSprite.New(obj)
		oSkillBox:SetGroup(self:GetInstanceID())
		self.m_SkillBoxArr[idx] = oSkillBox
		oSkillBox:AddUIEvent("click", callback(self, "OnClickSkill"))
		return oSkillBox
	end)
end

function CCreateRoleBranchPage.OnClickBack(self)
	self.m_ParentView:ShowMainPage()
end

function CCreateRoleBranchPage.OnChooseBranch(self, oBox)
	if self.m_CurrentBox and self.m_CurrentBox == oBox then
		oBox = (oBox == self.m_BranchBtn1) and self.m_BranchBtn2 or self.m_BranchBtn1
	end
	if self.m_Tweening then
		return
	end
	local tweenTime = 0.5
	local easeType = enum.DOTween.Ease.OutBack
	if self.m_CurrentBox then

		self.m_Tweening = true
		local tempBox = self.m_CurrentBox
		local tween1 = DOTween.DOScale(self.m_CurrentBox.m_Btn.m_Transform, self.m_Scale2, tweenTime)
		local tween2 = DOTween.DOLocalMove(self.m_CurrentBox.m_Btn.m_Transform, self.m_Pos2, tweenTime)
		DOTween.SetEase(tween1, easeType)
		DOTween.SetEase(tween2, easeType)
		-- tempBox.m_WeaponSprite:SetGrey(true)
		tempBox:SetSelect(false)

		local tween3 = DOTween.DOScale(oBox.m_Btn.m_Transform, self.m_Scale1, tweenTime)
		local tween4 = DOTween.DOLocalMove(oBox.m_Btn.m_Transform, self.m_Pos1, tweenTime)
		DOTween.SetEase(tween3, easeType)
		DOTween.SetEase(tween4, easeType)
		DOTween.OnComplete(tween4, function ()
			if Utils.IsExist(self) then
				self.m_Tweening = false
			end
		end)
		oBox:SetSelect(true)
		local TempDepth = oBox.m_Panel:GetDepth()
		oBox.m_Panel:SetDepth(tempBox.m_Panel:GetDepth())
		tempBox.m_Panel:SetDepth(TempDepth)
		-- oBox.m_WeaponSprite:SetGrey(false)
	end
	self.m_CurrentBox = oBox
	g_CreateRoleCtrl:SetCreateData("branch", self.m_CurrentBox.m_Branch)
	self:RefreshSkillGrid()
end

function CCreateRoleBranchPage.ResetPos(self)
	self.m_BranchBtn1.m_Btn:SetLocalPos(self.m_Pos1)
	self.m_BranchBtn2.m_Btn:SetLocalPos(self.m_Pos2)
	self.m_BranchBtn1.m_Btn:SetLocalScale(self.m_Scale1)
	self.m_BranchBtn2.m_Btn:SetLocalScale(self.m_Scale2)
	self.m_BranchBtn1:SetSelect(true)
	self.m_BranchBtn2:SetSelect(false)
end

function CCreateRoleBranchPage.SetSchool(self, iSchool)
	self.m_Tweening = false
	self.m_School = iSchool
	self.m_CurrentBox = nil
	self:ResetPos()
	local lBranchDatas = self:GetBranchDatas()
	self.m_BranchBtn1:SetInitData(iSchool, lBranchDatas[1], callback(self, "OnChooseBranch"))
	self.m_BranchBtn2:SetInitData(iSchool, lBranchDatas[2], callback(self, "OnChooseBranch"))
	--默认显示1武器
	self:OnChooseBranch(self.m_BranchBtn1)
end

function CCreateRoleBranchPage.GetBranchDatas(self)
	local list = {}
	for i, v in ipairs(data.roletypedata.BRANCH_TYPE) do
		if v.school == self.m_School then
			table.insert(list, v)
		end
	end
	return list
end

function CCreateRoleBranchPage.RefreshSkillGrid(self)
	local list = g_SkillCtrl:GetSchoolSkillListData(self.m_School, self.m_CurrentBox.m_Branch)
	local idx = 1
	for i, dSkill in ipairs(list) do
		if dSkill.type == 1 or dSkill.type == 3 then
			local oSkillBox = self.m_SkillBoxArr[idx]
			if oSkillBox then
				if idx > 4 then
					oSkillBox:SetActive(false)
				else
					oSkillBox:SetActive(true)
					oSkillBox:SpriteSkill(dSkill.skill_id)
					idx = idx + 1
					oSkillBox.m_Idx = idx
					oSkillBox.m_SkillID = dSkill.skill_id
				end
			end
		end
	end
	self.m_SkillGrid:Reposition()
	self.m_DescBox.m_Bg:SetAlpha(0.01)
end

function CCreateRoleBranchPage.OnClickSkill(self, oBox)
	oBox:SetSelected(true)
	self.m_DescBox.m_Bg:SetAlpha(1)
	local dMagic = DataTools.GetMagicData(oBox.m_SkillID)
	self.m_DescBox.m_Label:SetText(dMagic.short_desc)
	self.m_DescBox.m_Bg:SimulateOnEnable()
	UITools.NearTarget(oBox, self.m_DescBox.m_Bg, enum.UIAnchor.Side.Top, Vector2.New(0, 20))
	-- CMagicDescView
	g_CreateRoleCtrl:DisplaySkill(oBox.m_SkillID)
end

return CCreateRoleBranchPage
