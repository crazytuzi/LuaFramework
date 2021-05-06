local COrgChangeFlagView = class("COrgChangeFlagView", CViewBase)

function COrgChangeFlagView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgChangeFlagView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function COrgChangeFlagView.OnCreateView(self)
	self.m_FlagNameInput = self:NewUI(1, CInput)
	self.m_CostLabel = self:NewUI(2, CLabel)
	self.m_FlagBgGrid = self:NewUI(3, CGrid)
	self.m_FlagBgCell = self:NewUI(4, CBox)
	self.m_FlagBgScrollView = self:NewUI(6, CScrollView)
	self.m_SumitBtn = self:NewUI(7, CButton)
	self.m_ResultBgSprite = self:NewUI(8, CSprite)
	self.m_ResultLabel = self:NewUI(9, CLabel)
	self.m_Close = self:NewUI(10, CButton)
	self:InitContent()
end

function COrgChangeFlagView.InitContent(self)
	-- self.m_CostColor = self.m_CostLabel:GetColor()
	-- self.m_CostLabel:SetText(string.numberConvert(g_OrgCtrl:GetRule().change_flag_price))
	self:SetTextColor()
	self.m_FlagNameInput:SetText(g_OrgCtrl:GetMyOrgInfo().sflag)
	self.m_FlagNameInput:AddUIEvent("change", callback(self, "OnChangeFlagName"))
	self.m_ResultLabel:SetText(g_OrgCtrl:GetMyOrgInfo().sflag)

	self.m_Close:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SumitBtn:AddUIEvent("click", callback(self, "OnClickSumit"))
	self:SetData()

	self.m_FlagBgCell:SetActive(false)
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotifyAttrChange"))
end

function COrgChangeFlagView.SetData(self)
	local flagBgID = g_OrgCtrl:GetMyOrgInfo().flagbgid
	for i,v in ipairs(data.orgdata.FlagSort) do
		local oFlagBox = self.m_FlagBgCell:Clone()
		self.m_FlagBgGrid:AddChild(oFlagBox)
		oFlagBox.m_OnSelectSprite = oFlagBox:NewUI(1, CSprite)
		oFlagBox.m_Sprite = oFlagBox:NewUI(2, CSprite)
		oFlagBox.m_ID = v
		oFlagBox.m_OnSelectSprite:SetActive(false)
		oFlagBox.m_Sprite:SetSpriteName(g_OrgCtrl:GetFlagIcon(v))
		oFlagBox.m_Sprite:AddUIEvent("click", callback(self, "OnChangeFlagBg", oFlagBox))
		oFlagBox:SetActive(true)
		if v == flagBgID then
			self:OnChangeFlagBg(oFlagBox)
		end
	end
end

function COrgChangeFlagView.OnChangeFlagName(self)
	-- self.m_FlagNameInput:OnInputChange()
	self.m_ResultLabel:SetText(self.m_FlagNameInput:GetText())
end

function COrgChangeFlagView.SetTextColor(self)
	-- if g_OrgCtrl:GetRule().change_flag_price > g_AttrCtrl.goldcoin then
	-- 	self.m_CostLabel:SetColor(Color.red)
	-- else
	-- 	self.m_CostLabel:SetColor(self.m_CostColor)
	-- end
end

function COrgChangeFlagView.OnNotifyAttrChange(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:SetTextColor()
	end
end

function COrgChangeFlagView.OnChangeFlagBg(self, oFlagBox)
	if self.m_CurrentBox ~= nil then
		self.m_CurrentBox.m_OnSelectSprite:SetActive(false)
	end
	self.m_CurrentBox = oFlagBox
	self.m_CurrentBox.m_OnSelectSprite:SetActive(true)
	self.m_ResultBgSprite:SetSpriteName(oFlagBox.m_Sprite:GetSpriteName())
end

function COrgChangeFlagView.OnClickSumit(self)
	local flagName = self.m_FlagNameInput:GetText()
	local len = #CMaskWordTree:GetCharList(flagName)
	if flagName == "" then
		g_NotifyCtrl:FloatMsg("请输入字号")
	elseif g_MaskWordCtrl:IsContainMaskWord(flagName) then
		g_NotifyCtrl:FloatMsg("字号存在敏感词，请重新输入")
	elseif len > g_OrgCtrl:GetRule().max_flag_len then
		g_NotifyCtrl:FloatMsg(string.format("字号长度超出%s汉字", g_OrgCtrl:GetRule().max_flag_len))
	-- elseif g_OrgCtrl:GetRule().change_flag_price > g_AttrCtrl.goldcoin then
	-- 	local windowConfirmInfo = {
	-- 		msg = "您的水晶不足，是否跳转至充值商店？",
	-- 		okStr = "否",
	-- 		cancelStr = "是",
	-- 		cancelCallback = function()
	-- 			g_SdkCtrl:ShowPayView()
	-- 		end
	-- 	}
	-- 	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		g_OrgCtrl:ChangeFlag(self.m_CurrentBox.m_ID, flagName)
	end
end

function COrgChangeFlagView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.ChangeFlag then
		self:OnClose()
	end
end


return COrgChangeFlagView