---------------------------------------------------------------
--确定 取消 弹窗


---------------------------------------------------------------

local CItemTipsConfirmWindowView = class("CItemTipsConfirmWindowView", CViewBase)

CItemTipsConfirmWindowView.UIType = 
{
	default = 0,
	shape = 1,
}

CItemTipsConfirmWindowView.Button = {
	Cancel = 0,
	OK = 1,
	Other = 2
}

function CItemTipsConfirmWindowView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsConfirmWindowView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CItemTipsConfirmWindowView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_InfoLabel = self:NewUI(2, CLabel)
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_CancelBtn = self:NewUI(4, CButton)
	self.m_OKBtn = self:NewUI(5, CButton)
	self.m_ThirdBtn = self:NewUI(6, CButton)
	self.m_DefaultWidget = self:NewUI(7, CBox)
	self.m_ShapeWidget = self:NewUI(8, CBox)
	self.m_ShapeIconSprite = self:NewUI(9, CSprite)
	self.m_ShapeSchoolSprite = self:NewUI(10, CSprite)
	self.m_ShapeNameLabel = self:NewUI(11, CLabel)
	self.m_ShapeLevelLabel = self:NewUI(12, CLabel)
	self.m_ShapeContentLabel = self:NewUI(13, CLabel)
	self.m_ContentBgSprite = self:NewUI(14, CSprite)
	self.m_SelectBtnBox = self:NewUI(16, CBox)
	self.m_BgSprite = self:NewUI(17, CSprite)
	self.m_BtnGrid = self:NewUI(18, CGrid)

	self.m_Buttons = {}
	self.m_Buttons[self.Button.Cancel] = self.m_CancelBtn
	self.m_Buttons[self.Button.OK] = self.m_OKBtn
	self.m_Buttons[self.Button.Other] = self.m_ThirdBtn
	self.m_UIType = CItemTipsConfirmWindowView.UIType.default
	self.m_IsDoneCancelCb = false

	self.m_ButtonTexts = {}
	self:InitSelectedBtn()
	self:InitContent()
	g_GuideCtrl:AddGuideUI("confirm_cancel_btn", self.m_CancelBtn)
	g_GuideCtrl:AddGuideUI("confirm_ok_btn", self.m_OKBtn)
end

function CItemTipsConfirmWindowView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnMyClose"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancelBtn"))
	self.m_OKBtn:AddUIEvent("click", callback(self, "OnOKBtn"))
	self.m_ThirdBtn:AddUIEvent("click", callback(self, "OnThirdBtn"))	
end

function CItemTipsConfirmWindowView.InitSelectedBtn(self)
	self.m_SelectLabel = self.m_SelectBtnBox:NewUI(1, CLabel)
	self.m_SelectBtn = self.m_SelectBtnBox:NewUI(2, CButton)
	self.m_SelectBtnBox:SetActive(false)
end

function CItemTipsConfirmWindowView.OnCancelBtn(self)
	self.m_IsDoneCancelCb = true
	if self.m_CancelCallback then
		self.m_CancelCallback()
	end
	self:OnClose()
end

function CItemTipsConfirmWindowView.OnOKBtn(self)
	self.m_IsDoneCancelCb = true
	if self.m_OkCallback then
		self.m_OkCallback()
	end
	self:OnSelectBtn()
	self:OnClose()
end

function CItemTipsConfirmWindowView.OnThirdBtn(self)
	self.m_IsDoneCancelCb = true
	if self.m_ThirdCallback then
		self.m_ThirdCallback()
	end
	self:OnClose()
end

function CItemTipsConfirmWindowView.OnMyClose(self)
	self.m_IsDoneCancelCb = true
	if self.closeCallback then
		self.closeCallback()
	end
	self:OnClose()
end

function CItemTipsConfirmWindowView.OnSelectBtn(self)
	if self.m_SelectCallback then
		if self.m_SelectBtn:GetSelected() then
			self.m_SelectCallback(true)
		else
			self.m_SelectCallback(false)
		end
	end
end

function CItemTipsConfirmWindowView.OnClose(self)
	self:StopCountdownTimer()
	CViewBase.OnClose(self)
end

function CItemTipsConfirmWindowView.SetWindowConfirm(self, args)
	self.m_Args = args

	self.m_DefaultWidget:SetActive(false)
	self.m_ShapeWidget:SetActive(false)
	if self.m_Args.uiType == CItemTipsConfirmWindowView.UIType.shape then
		self.m_ShapeWidget:SetActive(true)
		self.m_ShapeContentLabel:SetText(args.msg)
		self.m_ShapeContentLabel:SetPivot(args.pivot)
		if next(self.m_Args.simpleRole) ~= nil then
			self.m_ShapeNameLabel:SetText(self.m_Args.simpleRole.name)
			self.m_ShapeLevelLabel:SetText(string.format("Lv.%d", self.m_Args.simpleRole.grade))
			self.m_ShapeSchoolSprite:SpriteSchool(self.m_Args.simpleRole.school)
			self.m_ShapeIconSprite:SpriteAvatar(self.m_Args.simpleRole.model_info.shape)
		end 
		--重置高度
		local hOffset = self.m_ShapeContentLabel:GetHeight() - 40
		hOffset = (hOffset > 0 ) and hOffset or 0
		self.m_ContentBgSprite:SetHeight(self.m_ContentBgSprite:GetHeight() + hOffset)
	else
		self.m_DefaultWidget:SetActive(true)
		self.m_TitleLabel:SetText(args.title)
		self.m_InfoLabel:SetPivot(args.pivot)
		self.m_InfoLabel:SetRichText(args.msg)
		self.m_InfoLabel:SetAlignment(args.alignment)
		if args.msgBBCode == true then
			self.m_InfoLabel:SetColor(Color.New(255/255, 255/255, 255/255, 255/255))
		end

		self:ResetSize()
	end

	self.m_CancelCallback = args.cancelCallback
	self.m_OkCallback = args.okCallback
	self.m_ThirdCallback = args.thirdCallback
	self.rTopCloseCallback = args.rTopCloseCallback
	self.m_SelectArg = args.selectdata
	self.m_OKBtn:SetText(args.okStr)
	self.m_CancelBtn:SetText(args.cancelStr)
	self:RefreshSelectBtn()
	if args.thirdStr == "" or self.m_ThirdCallback == nil then
		self.m_ThirdBtn:SetActive(false)
	else
		self.m_ThirdBtn:SetText(args.thirdStr)
		if self.m_BtnGrid:GetCount() == 3 then
			self.m_BtnGrid:SetCellSize(180, 80)			
			self.m_BgSprite:SetWidth(570)
			self.m_ContentBgSprite:SetWidth(520)		
			self.m_InfoLabel:SetWidth(500)
			self.m_InfoLabel:SetLocalPos(Vector3.New(-250, 26, 0))
		end
	end 
	
	self.m_ButtonTexts[self.Button.Cancel] = args.cancelStr
	self.m_ButtonTexts[self.Button.OK] = args.okStr
	self.m_ButtonTexts[self.Button.Other] = args.thirdStr

	for k,str in pairs(self.m_ButtonTexts) do
		if string.utfStrlen(str) > 2 then
			self.m_Buttons[k].m_ChildLabel:SetSpacingX(0)
		end
	end

	if args.countdown > 0 then
		self.m_Buttons[args.default].m_ChildLabel:SetSpacingX(0)
		self:StartCountdownTimer()
	end
end

function CItemTipsConfirmWindowView.ResetSize(self)
	local infow, infoh = self.m_InfoLabel:GetSize()
	local infopos = self.m_InfoLabel:GetLocalPos()
	local addh = math.max(infoh-60, 0)
	local cw, _ = self.m_ContentBgSprite:GetSize()
	self.m_ContentBgSprite:SetSize(cw, 90 + addh)
	self.m_InfoLabel:SetLocalPos(Vector3.New(infopos.x, infopos.y - addh / 2, 0))
	local bw, _ = self.m_BgSprite:GetSize()
	if self.m_Args.selectdata then
		addh = addh + 32
	end	
	self.m_BgSprite:SetSize(bw, 270 + addh)
end

function CItemTipsConfirmWindowView.StartCountdownTimer(self)
	local update = function()
		if Utils.IsNil(self) then
			return
		end
		local iCountdown = self.m_Args.countdown
		local iDefalut = self.m_Args.default

		if iCountdown > 0 then
			local str = string.format("%s(%ds)",self.m_ButtonTexts[iDefalut],iCountdown)			
			self.m_Buttons[iDefalut]:SetText(str)		
			iCountdown = iCountdown - 1
			self.m_Args.countdown = iCountdown
		else
			self.m_Buttons[iDefalut]:Notify(enum.UIEvent["click"])
			self:StopCountdownTimer()
		end
		return iCountdown >= 0
	end
	self.m_Timer = Utils.AddTimer(update, 1, 0)
end

function CItemTipsConfirmWindowView.StopCountdownTimer(self)
	if self.m_Timer ~= nil then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
end

function CItemTipsConfirmWindowView.RefreshSelectBtn(self)
	local args = self.m_SelectArg
	if args then
		self.m_SelectBtnBox:SetActive(true)
		self.m_SelectLabel:SetText(args.text)
		self.m_SelectCallback = args.CallBack
	else
		self.m_SelectBtnBox:SetActive(false)
		self.m_SelectCallback = nil
	end
end

function CItemTipsConfirmWindowView.Destroy(self)
	if not self.m_IsDoneCancelCb then
		if self.m_CancelCallback and self.m_Args.noCancelCbTouchOut ~= true then
			self.m_CancelCallback()
		end
		if self.m_Args.autoSelectOnDestroy then
			local iDefalut = self.m_Args.default
			self.m_Buttons[iDefalut]:Notify(enum.UIEvent["click"])
		end
	end
	CViewBase.Destroy(self)
end

return CItemTipsConfirmWindowView