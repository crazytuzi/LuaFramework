local CCreateOrgView = class("CCreateOrgView", CViewBase)

function CCreateOrgView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/CreateOrgView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CCreateOrgView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CreateBtn = self:NewUI(2, CButton)
	self.m_FlagBgGrid = self:NewUI(3, CGrid)
	self.m_CostLabel = self:NewUI(4, CLabel)
	self.m_NameInput = self:NewUI(5, CInput)
	self.m_FlagBgSprite = self:NewUI(6, CSprite)
	self.m_ResultLabel = self:NewUI(7, CLabel)
	self.m_TipsLabel = self:NewUI(8, CLabel)
	-- self.m_AimInput = self:NewUI(9, CInput)
	self.m_MainPage = self:NewUI(9, CBox)
	self.m_FlagNameInput = self:NewUI(10, CInput)
	self.m_FlagBgCell = self:NewUI(11, CBox)
	self.m_ChangeFlagPage = self:NewUI(12, CBox)
	self.m_ChangeFlagBtn = self:NewUI(13, CButton)
	self.m_ShowFlagBtn = self:NewUI(14, CButton)
	self.m_CancelBtn = self:NewUI(15, CButton)
	self:InitContent()
end

function CCreateOrgView.InitContent(self)
	self.m_MainPage:SetActive(true)
	self.m_ChangeFlagPage:SetActive(false)
	self.m_MaxNameLen = g_OrgCtrl:GetRule().max_name_len
	self.m_minNameLen = g_OrgCtrl:GetRule().min_name_len
	self.m_FlagNameInput:AddUIEvent("change", callback(self, "OnChangeFlagName"))

	self.m_TipsLabel:SetText(string.format("输入%d-%d汉字", self.m_minNameLen, self.m_MaxNameLen))
	self.m_CostColor = self.m_CostLabel:GetColor()

	self.m_FlagBgCell:SetActive(false)
	self.m_ChangeFlagBtn:AddUIEvent("click", callback(self, "OnChangeFlag"))
	self.m_ShowFlagBtn:AddUIEvent("click", callback(self, "OnShowFlag"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CreateBtn:AddUIEvent("click", callback(self, "OnClickCreate"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickCancel"))

	self.m_CostLabel:SetText(string.numberConvert(g_OrgCtrl:GetRule().cost))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	self.m_ResultLabel:SetText("")
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotifyAttrChange"))
	self:SetTextColor()
	self:InitGrid()
end

function CCreateOrgView.OnShowFlag(self)
	self:OnChangeFlagBg(self.m_SelectedBox)
	self.m_MainPage:SetActive(false)
	self.m_ChangeFlagPage:SetActive(true)
end

function CCreateOrgView.OnClickCancel(self)
	self.m_MainPage:SetActive(true)
	self.m_ChangeFlagPage:SetActive(false)
end

function CCreateOrgView.OnChangeFlag(self)
	self.m_SelectedBox = self.m_CurrentBox
	self.m_FlagBgSprite:SetSpriteName(self.m_SelectedBox.m_Sprite:GetSpriteName())
	self.m_MainPage:SetActive(true)
	self.m_ChangeFlagPage:SetActive(false)
end

function CCreateOrgView.OnChangeFlagName(self)
	self.m_ResultLabel:SetText(self.m_FlagNameInput:GetText())
end

function CCreateOrgView.InitGrid(self)
	for i,v in ipairs(data.orgdata.FlagSort) do
		local oFlagBox = self.m_FlagBgCell:Clone()
		self.m_FlagBgGrid:AddChild(oFlagBox)
		oFlagBox.m_OnSelectSprite = oFlagBox:NewUI(1, CSprite)
		oFlagBox.m_Sprite = oFlagBox:NewUI(2, CButton)
		oFlagBox.m_ID = v
		oFlagBox.m_OnSelectSprite:SetActive(false)
		oFlagBox.m_Sprite:SetSpriteName(g_OrgCtrl:GetFlagIcon(v))
		oFlagBox.m_Sprite:AddUIEvent("click", callback(self, "OnChangeFlagBg", oFlagBox))
		oFlagBox:SetActive(true)
		if i == 1 then
			self.m_SelectedBox = oFlagBox
			self.m_FlagBgSprite:SetSpriteName(self.m_SelectedBox.m_Sprite:GetSpriteName())
		end
	end
end

function CCreateOrgView.OnChangeFlagBg(self, oFlagBox)
	if self.m_CurrentBox ~= nil then
		self.m_CurrentBox.m_OnSelectSprite:SetActive(false)
	end
	self.m_CurrentBox = oFlagBox
	self.m_CurrentBox.m_OnSelectSprite:SetActive(true)
end

function CCreateOrgView.SetTextColor(self)
	if g_OrgCtrl:GetRule().cost > g_AttrCtrl.goldcoin then
		self.m_CostLabel:SetColor(Color.red)
	else
		self.m_CostLabel:SetColor(self.m_CostColor)
	end
end

function CCreateOrgView.OnNotifyAttrChange(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:SetTextColor()
	end
end

function CCreateOrgView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.GetOrgMainInfo then
		COrgMainView:ShowView()
		self:OnClose()
	else

	end
end

function CCreateOrgView.OnClickCreate(self)
	local orgName = self.m_NameInput:GetText()
	local len = #CMaskWordTree:GetCharList(orgName)
	-- local orgAim = self.m_AimInput:GetText()
	local orgAim = ""
	local flagName = self.m_FlagNameInput:GetText()
	local flagLen = #CMaskWordTree:GetCharList(flagName)
	if len < self.m_minNameLen or len > self.m_MaxNameLen then
		g_NotifyCtrl:FloatMsg(string.format("名字长度为%d~%d汉字", self.m_minNameLen, self.m_MaxNameLen))
	elseif g_MaskWordCtrl:IsContainMaskWord(orgName) then
		g_NotifyCtrl:FloatMsg("名字存在敏感词，请重新输入")
	elseif not string.isIllegal(orgName) then
		g_NotifyCtrl:FloatMsg("名字存在特殊字符，请重新输入")
	-- elseif g_MaskWordCtrl:IsContainMaskWord(orgAim) then
	-- 	g_NotifyCtrl:FloatMsg("公告存在敏感词，请重新输入")
	elseif flagName == "" then
		g_NotifyCtrl:FloatMsg("请输入字号")
	elseif flagLen > g_OrgCtrl:GetRule().max_flag_len then
		g_NotifyCtrl:FloatMsg(string.format("字号长度超出%s汉字", g_OrgCtrl:GetRule().max_flag_len))
	elseif g_MaskWordCtrl:IsContainMaskWord(flagName) then
		g_NotifyCtrl:FloatMsg("字号存在敏感词，请重新输入")

	elseif g_OrgCtrl:GetRule().cost > g_AttrCtrl.goldcoin then
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
	elseif data.globalcontroldata.GLOBAL_CONTROL.org.open_grade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(data.globalcontroldata.GLOBAL_CONTROL.org.open_grade .. "级开启该功能")
	else
		netorg.C2GSCreateOrg(orgName, flagName, self.m_SelectedBox.m_ID, orgAim)
	end
end

return CCreateOrgView