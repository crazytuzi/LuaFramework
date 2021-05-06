local CEmojiLinkView = class("CEmojiLinkView", CViewBase)

function CEmojiLinkView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Chat/EmojiLinkView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
	self.m_IsAlwaysShow = true
	self.m_BehindStrike = true
end

function CEmojiLinkView.OnCreateView(self)
	self.m_BtnGrid = self:NewUI(1, CGrid)
	self.m_EmojiPage = self:NewPage(2, CChatEmojiPage)
	self.m_Container = self:NewUI(3, CWidget)
	self.m_TextBtn = self:NewUI(4, CButton)
	self.m_ItemPage = self:NewPage(5, CChatItemPage)
	self.m_PartnerPage = self:NewPage(6, CChatPartnerPage)
	self.m_AttrCardPage = self:NewPage(7, CChatAttrCardPage)
	self.m_AttrCardBtn = self:NewUI(8,CButton)
	self.m_LeftWidget = self:NewUI(9, CWidget)
	self.m_NormalMsgPage = self:NewPage(10, CChatNormalMsgPage)
	self.m_HistoryPage = self:NewPage(11, CChatHistoryPage)
	self.m_PEPage = self:NewPage(12, CChatPEPage)
	self.m_ParSoulPage = self:NewPage(13, CChatParSoulPage)
	self.m_TextBtn:SetActive(false)
	local t = {"表情",  "伙伴", "符文", "御灵", "道具", "常用", "历史"}
	for k, v in ipairs(t) do
		local oBtn = self.m_TextBtn:Clone()
		oBtn:SetText(v)
		oBtn:SetActive(true)
		oBtn:SetGroup(self.m_BtnGrid:GetInstanceID())
		oBtn.m_Idx = k
		oBtn:AddUIEvent("click", callback(self, "ShowPage", v))
		self.m_BtnGrid:AddChild(oBtn)
	end
	self.m_AttrCardBtn:SetActive(true)
	self.m_AttrCardBtn:AddUIEvent("click", callback(self, "OnSendCard"))
	self.m_BtnGrid:AddChild(self.m_AttrCardBtn)

	self.m_SendFunc = nil
	self:InitContent()
end

function CEmojiLinkView.ShowPage(self, sName)
	if sName == "表情" then
		self:ShowSubPage(self.m_EmojiPage)
	elseif sName == "道具" then
		self:ShowSubPage(self.m_ItemPage)
	elseif sName == "伙伴" then
		self:ShowSubPage(self.m_PartnerPage)
	elseif sName == "名片" then
		self:ShowSubPage(self.m_AttrCardPage)
	elseif sName == "常用" then
		self:ShowSubPage(self.m_NormalMsgPage)
	elseif sName == "历史" then
		self:ShowSubPage(self.m_HistoryPage)
	elseif sName == "符文" then
		self:ShowSubPage(self.m_PEPage)
	elseif sName == "御灵" then
		self:ShowSubPage(self.m_ParSoulPage)
	end
end

function CEmojiLinkView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self:ShowEmojiPage()
	self:UpdateChatView()
	g_LinkInfoCtrl:C2SGetNormalMsg()
	g_LinkInfoCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLinkCtrlEvent"))
end

function CEmojiLinkView.OnLinkCtrlEvent(self, oCtrl)
	printc(oCtrl.m_EventID, oCtrl.m_EventData.linktype, oCtrl.m_EventData.idx)
	if oCtrl.m_EventID == define.Link.Event.UpdateIdx then
		if oCtrl.m_EventData.linktype == "namelink" then
			self:OnSendNameLink(oCtrl.m_EventData.idx)
		end
	end
end

function CEmojiLinkView.UpdateChatView(self)
	local _, h = self.m_LeftWidget:GetSize()
	local oView = CChatMainView:GetView()
	if oView then
		oView:SetLocalPos(Vector3.New(0, h, 0))
	end
end

function CEmojiLinkView.ShowEmojiPage(self)
	self.m_BtnGrid:GetChild(1):SetSelected(true)
	self:ShowSubPage(self.m_EmojiPage)
end

function CEmojiLinkView.OnSendCard(self)
	g_LinkInfoCtrl:GetNameLinkIdx()
end

function CEmojiLinkView.OnSendNameLink(self, idx)
	local linkstr = LinkTools.GenerateNameLinkLink(g_AttrCtrl.name, idx, g_AttrCtrl.pid)
	printc(linkstr)
	self:Send(linkstr)
end

function CEmojiLinkView.SetSendFunc(self, f)
	self.m_SendFunc = f
end

function CEmojiLinkView.Send(self, s)
	if self.m_SendFunc then
		self.m_SendFunc(s)
	end
end

function CEmojiLinkView.CloseView(self)
	g_ViewCtrl:CloseView(self)
	local oView = CChatMainView:GetView()
	if oView then
		oView:SetLocalPos(Vector3.New(0, 0, 0))
	end
end

return CEmojiLinkView