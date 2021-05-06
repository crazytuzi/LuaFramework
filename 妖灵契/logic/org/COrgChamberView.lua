local COrgChamberView = class("COrgChamberView", CViewBase)

function COrgChamberView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgChamberView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function COrgChamberView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(2, CGrid)
	self.m_BtnBox = self:NewUI(3, CBox)
	self.m_InfoPage = self:NewPage(4, COrgChamberInfoPage)
	self.m_MemberPage = self:NewPage(5, COrgMemberPage)
	self.m_RedBagPage = self:NewPage(6, COrgRedBagPage)
	self.m_HistoryPage = self:NewPage(7, COrgHistoryPage)
	self.m_OrgBuildPage = self:NewPage(8, COrgBuildPage)
	self.m_HelpBtn = self:NewUI(9, CButton)
	self.m_XiaoRenTexture = self:NewUI(10, CSpineTexture)
	self:InitContent()
end

function COrgChamberView.InitContent(self)
	self.m_XiaoRenTexture:SetActive(false)
	self.m_XiaoRenTexture:ShapeOrg("XiaoRen", objcall(self, function(obj)
		obj.m_XiaoRenTexture:SetActive(true)
		obj.m_XiaoRenTexture:SetAnimation(0, "idle_1", false)
	end))
	self.m_BtnInfoList = {
		{name = "信息", callbackFunc = callback(self, "OnClickInfo"), hint = define.Help.Key.OrgInfo},
		{name = "建设", callbackFunc = callback(self, "OnClickBuild"), hint = define.Help.Key.OrgBuild},
		{name = "红包", callbackFunc = callback(self, "OnClickRedPacket"), hint = nil},
		{name = "成员", callbackFunc = callback(self, "OnClickMember"), hint = nil},
		{name = "动态", callbackFunc = callback(self, "OnClickHistory"), hint = nil},
	}
	self.m_BtnBoxArr = {}

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self:SetBtnData()
	self:OnSelectPage(self.m_BtnBoxArr[1])
	self:RefreshRedBagPoint()
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrlEvent"))
	-- self.m_HelpBtn:SetHint(callback(self, "GetHint"), enum.UIAnchor.Side.Bottom)
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
end

function COrgChamberView.OnClickHelp(self)
	CHelpView:ShowView(function(oView)
		oView:ShowHelp(self:GetHint())
	end)
end

function COrgChamberView.GetHint(self)
	return self.m_CurrentBtn.m_Data.hint
end

function COrgChamberView.SetBtnData(self)
	for i = 1, #self.m_BtnInfoList do
		self.m_BtnBoxArr[i] = self:CreateBtn()
		self.m_BtnBoxArr[i]:SetData(self.m_BtnInfoList[i])
	end
	self.m_BtnBoxArr[2].m_IgnoreCheckEffect = true
	self.m_BtnBox:SetActive(false)
end

function COrgChamberView.CreateBtn(self)
	local oBtnBox = self.m_BtnBox:Clone()
	oBtnBox.m_OnSelectSprite = oBtnBox:NewUI(1, CSprite)
	oBtnBox.m_Label = oBtnBox:NewUI(2, CLabel)
	oBtnBox.m_SelectLabel = oBtnBox:NewUI(3, CLabel)

	self.m_BtnGrid:AddChild(oBtnBox)
	oBtnBox:SetClickSounPath(define.Audio.SoundPath.Tab)
	oBtnBox:AddUIEvent("click", callback(self, "OnSelectPage", oBtnBox))

	function oBtnBox.SetData(self, oData)
		oBtnBox.m_Data = oData
		oBtnBox.m_Label:SetText(oData.name)
		oBtnBox.m_SelectLabel:SetText(oData.name)
	end

	return oBtnBox
end

function COrgChamberView.OnSelectPage(self, oBtnBox)
	if self.m_CurrentBtn ~= nil then
		self.m_CurrentBtn.m_OnSelectSprite:SetActive(false)
		self.m_CurrentBtn.m_Label:SetActive(true)
	end
	self.m_CurrentBtn = oBtnBox
	self.m_CurrentBtn.m_OnSelectSprite:SetActive(true)
	self.m_CurrentBtn.m_Label:SetActive(false)
	self.m_HelpBtn:SetActive(self.m_CurrentBtn.m_Data.hint ~= nil)
	self.m_CurrentBtn.m_Data.callbackFunc()
end

function COrgChamberView.OnClickMember(self)
	g_OrgCtrl:GetMemberList(define.Org.HandleType.OpenMemberView)
end

function COrgChamberView.OnClickInfo(self)
	self:ShowSubPage(self.m_InfoPage)
end

function COrgChamberView.OnClickBuild(self)
	self:ShowSubPage(self.m_OrgBuildPage)
end

function COrgChamberView.OnClickRedPacket(self)
	self:ShowSubPage(self.m_RedBagPage)
end

function COrgChamberView.OnClickHistory(self)
	g_OrgCtrl:GetLog()
end

function COrgChamberView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.OnGetMemberList then
		self:ShowSubPage(self.m_MemberPage)
		self.m_MemberPage:SetData(true)
	elseif oCtrl.m_EventID == define.Org.Event.OnGetLog then
		self:ShowSubPage(self.m_HistoryPage)
		self.m_HistoryPage:SetData()
	elseif oCtrl.m_EventID == define.Org.Event.UpdateOrgInfo then
		self:RefreshRedBagPoint()
	end
end

function COrgChamberView.OnAttrCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshRedBagPoint()
	end
end

function COrgChamberView.RefreshRedBagPoint(self)
	local buildbtn = self.m_BtnBoxArr[2]
	if g_OrgCtrl:IsHasSignReward() or g_OrgCtrl:IsHasBuild() or g_OrgCtrl:IsHasBuildFinish() then
		buildbtn:AddEffect("RedDot")
	else
		buildbtn:DelEffect("RedDot")
	end

	local bagbtn = self.m_BtnBoxArr[3]
	if g_OrgCtrl:IsHasRedBag() then
		bagbtn:AddEffect("RedDot")
	else
		bagbtn:DelEffect("RedDot")
	end
end

return COrgChamberView