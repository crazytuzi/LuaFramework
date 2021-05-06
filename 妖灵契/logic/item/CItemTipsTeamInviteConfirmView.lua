---------------------------------------------------------------
--组队邀请 确定 取消 弹窗


---------------------------------------------------------------

local CItemTipsTeamInviteConfirmView = class("CItemTipsTeamInviteConfirmView", CViewBase)

CItemTipsTeamInviteConfirmView.Button = {
	Cancel = 0,
	OK = 1,
}

CItemTipsTeamInviteConfirmView.UIMode = 
{
	Select = 1,
	Refuse = 2,
}

function CItemTipsTeamInviteConfirmView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsTeamInviteConfirmView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Shelter"
end

function CItemTipsTeamInviteConfirmView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_ShapeBox = self:NewUI(2, CBox)
	self.m_IconSprite = self:NewUI(3, CSprite)
	self.m_SchoolIcon = self:NewUI(4, CSprite)
	self.m_NameLabel = self:NewUI(5, CLabel)
	self.m_LevelLabel = self:NewUI(6, CLabel)
	self.m_RelationLabel = self:NewUI(7, CLabel)
	self.m_BgSprite = self:NewUI(8, CLabel)
	self.m_ContentSprite = self:NewUI(9, CSprite)
	self.m_ContentLabel = self:NewUI(10, CLabel)
	self.m_BottomBox = self:NewUI(11, CBox)
	self.m_OKBtn = self:NewUI(12, CButton)
	self.m_CancelBtn = self:NewUI(13, CButton)
	self.m_SendBtn = self:NewUI(14, CButton)
	self.m_TipsLabel = self:NewUI(15, CLabel)
	self.m_SelectBtnBox = self:NewUI(16, CBox)
	self.m_SelectLabel = self.m_SelectBtnBox:NewUI(1, CLabel)
	self.m_SelectBtn = self.m_SelectBtnBox:NewUI(2, CButton)
	self.m_CloseBtn	= self:NewUI(17, CButton)
	self.m_InputBox = self:NewUI(18, CInput)
	self.m_InputLabel = self:NewUI(19, CLabel)
	self.m_PopupBox = self:NewUI(20, CPopupBox, true, CPopupBox.EnumMode.SelectedMode,1, true)
	self.m_BranchLabel = self:NewUI(21, CLabel)
	self.m_PointLabel = self:NewUI(22, CLabel)

	self.m_Buttons = {}
	self.m_Buttons[self.Button.Cancel] = self.m_CancelBtn
	self.m_Buttons[self.Button.OK] = self.m_OKBtn
	self.m_IsDoneCancelCb = false
	self.m_ButtonTexts = {}
	self.m_RefuseData = data.teamdata.REFUSE_CONFIG
	self.m_RefuseTime = nil
	self.m_PointLabel:SetActive(false)
	self:InitContent()
end

function CItemTipsTeamInviteConfirmView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnMyClose"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancelBtn"))
	self.m_OKBtn:AddUIEvent("click", callback(self, "OnOKBtn"))
	self.m_SendBtn:AddUIEvent("click", callback(self, "OnSend"))	
	self.m_SelectBtn:AddUIEvent("click", callback(self, "OnSelect"))
	self:InitRefuseBox()
end

function CItemTipsTeamInviteConfirmView.ShowPoint(self)
	self.m_PointLabel:SetActive(true)
end

function CItemTipsTeamInviteConfirmView.OnCancelBtn(self, oBox, bForce)
	if self.m_Args.relation == 7 or bForce == true then
		if self.m_ThirdCallback then
			self.m_ThirdCallback(self.m_InputBox:GetText(), self.m_RefuseTime)
		end
		self.m_IsDoneCancelCb = true
		self:OnClose()
	else
		self.m_UIMode = CItemTipsTeamInviteConfirmView.UIMode.Refuse
		self:RefreshUI()
		
	end
end

function CItemTipsTeamInviteConfirmView.OnOKBtn(self)
	if not self.m_RefuseTime  then
		if self.m_OkCallback then
			self.m_OkCallback()
		end
		self.m_IsDoneCancelCb = true
		self:OnClose()
	end
end

function CItemTipsTeamInviteConfirmView.OnSend(self)
	if self.m_ThirdCallback then
		local sText = self.m_InputBox:GetText()
		if g_MaskWordCtrl:IsContainMaskWord(sText) then
			g_NotifyCtrl:FloatMsg("拒绝理由包含屏蔽字")
			return
		else
			self.m_ThirdCallback(sText, self.m_RefuseTime)
		end
	end
	self.m_IsDoneCancelCb = true
	self:OnClose()
end

function CItemTipsTeamInviteConfirmView.OnMyClose(self)
	if self.m_ThirdCallback then
		self.m_ThirdCallback(self.m_InputBox:GetText(), self.m_RefuseTime)
	end
	self.m_IsDoneCancelCb = true
	self:OnClose()
end

function CItemTipsTeamInviteConfirmView.OnClose(self)
	self:StopCountdownTimer()
	CViewBase.OnClose(self)
end

function CItemTipsTeamInviteConfirmView.SetWindowConfirm(self, args)
	self.m_Args = args

	self.m_ContentLabel:SetText("[654A33]"..args.msg)
	self.m_ContentLabel:SetPivot(args.pivot)

	if next(self.m_Args.simpleRole) ~= nil then
		self.m_NameLabel:SetText(self.m_Args.simpleRole.name)
		self.m_LevelLabel:SetText(string.format("%d", self.m_Args.simpleRole.grade))
		self.m_SchoolIcon:SpriteSchool(self.m_Args.simpleRole.school)
		self.m_IconSprite:SpriteAvatar(self.m_Args.simpleRole.model_info.shape)

		--临时
		self.m_BranchLabel:SetText(g_AttrCtrl:GetSchoolBranchStr(self.m_Args.simpleRole.school, self.m_Args.simpleRole.school_branch))
	end 
	if args.point then
		self.m_PointLabel:SetActive(true)
		self.m_PointLabel:SetText(string.format("积分：%s", args.point))
	end
	self.m_RelationLabel:SetText(g_FriendCtrl:GetRelationString(self.m_Args.relation))

	self.m_CancelCallback = args.cancelCallback
	self.m_OkCallback = args.okCallback
	self.m_ThirdCallback = args.thirdCallback

	self.m_SelectArg = args.selectdata
	self.m_OKBtn:SetText(args.okStr)
	self.m_CancelBtn:SetText(args.cancelStr)

	self.m_ButtonTexts[self.Button.Cancel] = args.cancelStr
	self.m_ButtonTexts[self.Button.OK] = args.okStr

	for k,str in pairs(self.m_ButtonTexts) do
		if string.utfStrlen(str) > 2 then
			self.m_Buttons[k].m_ChildLabel:SetSpacingX(0)
		end
	end

	if args.countdown > 0 then
		self.m_Buttons[args.default].m_ChildLabel:SetSpacingX(0)
		self:StartCountdownTimer()
	end

	self.m_SelectBtnBox:SetSelected(self.m_RefuseTime ~= nil)

	self.m_UIMode = CItemTipsTeamInviteConfirmView.UIMode.Select
 
 	self:RefreshUI()	
end

function CItemTipsTeamInviteConfirmView.RefreshUI(self)
	self.m_OKBtn:SetActive(false)
	self.m_CancelBtn:SetActive(false)
	self.m_SendBtn:SetActive(false)
	self.m_SelectBtnBox:SetActive(false)
	self.m_TipsLabel:SetActive(false)
	self.m_ContentLabel:SetActive(false)
	self.m_InputBox:SetActive(false)
	self.m_PopupBox:SetActive(false)

	if self.m_UIMode == CItemTipsTeamInviteConfirmView.UIMode.Select then
		self.m_OKBtn:SetActive(true)
		self.m_CancelBtn:SetActive(true)
		self.m_ContentLabel:SetActive(true)
		--协同比武不显示
		self.m_SelectBtnBox:SetActive(self.m_Args.uiType ~= 4)

		-- self.m_ContentSprite:SetHeight(100 + self.m_ContentLabel:GetHeight())
		-- self.m_BgSprite:SetHeight(self.m_ContentSprite:GetHeight() + 120)
		if self.m_Args.uiType == 4 then
			self.m_BgSprite:SetHeight(self.m_ContentSprite:GetHeight() + 120)
		end
	else
		self.m_SendBtn:SetActive(true)
		self.m_TipsLabel:SetActive(true)
		self.m_InputBox:SetActive(true)
		self.m_PopupBox:SetActive(true)
		if self.m_Args.uiType == 4 then
			self.m_BgSprite:SetHeight(self.m_ContentSprite:GetHeight() + 170)
		end
		-- self.m_ContentSprite:SetHeight(100 + self.m_TipsLabel:GetHeight())
		-- self.m_BgSprite:SetHeight(self.m_ContentSprite:GetHeight() + 120)
	end
	
end

function CItemTipsTeamInviteConfirmView.StartCountdownTimer(self)
	local update = function()
		local iCountdown = self.m_Args.countdown
		local iDefalut = self.m_Args.default

		if iCountdown > 0 then
			local str = string.format("%s(%ds)",self.m_ButtonTexts[iDefalut],iCountdown)			
			self.m_Buttons[iDefalut]:SetText(str)		
			iCountdown = iCountdown - 1
			self.m_Args.countdown = iCountdown
		else
			self.m_Buttons[iDefalut]:Notify(enum.UIEvent["click"], true)
			self:StopCountdownTimer()
		end
		return iCountdown >= 0
	end
	self:StopCountdownTimer()
	self.m_Timer = Utils.AddTimer(update, 1, 0)
end

function CItemTipsTeamInviteConfirmView.StopCountdownTimer(self)
	if self.m_Timer ~= nil then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
end

function CItemTipsTeamInviteConfirmView.OnSelect(self)
	if self.m_RefuseTime then
		self.m_RefuseTime = nil
		self.m_OKBtn:SetGrey(false)
	else
		self.m_RefuseTime = 5
		self.m_OKBtn:SetGrey(true)
	end
end

function CItemTipsTeamInviteConfirmView.Destroy(self)
	self:StopCountdownTimer()
	if self.m_Args.autoSelectOnDestroy and not self.m_IsDoneCancelCb then
		local iDefalut = self.m_Args.default
		self.m_Buttons[iDefalut]:Notify(enum.UIEvent["click"])
	end
	CViewBase.Destroy(self)
end

function CItemTipsTeamInviteConfirmView.OnReruseClick(self, oBox)
	local subMenu = oBox:GetSelectedSubMenu()
	local clickType = self.m_PopupBox:GetSelectedIndex()
	self.m_InputBox:SetText(self.m_RefuseData[clickType].refuse_string)
	self.m_PopupBox:SetMenuItemLabelSize(subMenu.m_Index, 30, 24)
end

function CItemTipsTeamInviteConfirmView.InitRefuseBox(self)
	self.m_InputBox:SetText(self.m_RefuseData[1].refuse_string)
	self.m_PopupBox:SetCallback(callback(self, "OnReruseClick"))
	for i = 1, #self.m_RefuseData do
		self.m_PopupBox:AddSubMenu(self.m_RefuseData[i].refuse_string)	
	end
	self.m_PopupBox:SetMenuItemLabelSize(1, 30, 24)
end

return CItemTipsTeamInviteConfirmView