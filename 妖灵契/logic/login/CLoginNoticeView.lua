local CLoginNoticeView = class("CLoginNoticeView", CViewBase)

function CLoginNoticeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Login/LoginNoticeView.prefab", cb)

	self.m_ExtendClose = "Black"
end

function CLoginNoticeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_NoticeBox = self:NewUI(2, CBox)
	self.m_NoticeGrid = self:NewUI(3, CGrid)
	self.m_MainContentTexture = self:NewUI(4, CTexture)
	self.m_MainContentSpr = self:NewUI(5, CSprite)
	self.m_MainTextLabel = self:NewUI(6, CLabel)
	self.m_SubContentTable = self:NewUI(7, CTable)
	self.m_SubContentBox = self:NewUI(8, CBox)
	self.m_ScrollView = self:NewUI(9, CScrollView)
	self.m_ContentBox = self:NewUI(10, CBox)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CurSel = nil
	self.m_NoticeBox:SetActive(false)
	self.m_SubContentBox:SetActive(false)

	self.m_ContentBoxPos = self.m_ContentBox:GetLocalPos()
	self.m_ContentBoxW, self.m_ContentBoxH = self.m_ContentBox:GetSize()
	self:RefreshNotice()
end

function CLoginNoticeView.RefreshNotice(self)
	-- local lNotices = {
	-- 	{
	-- 		title= "系统公告",
	-- 		hot=2,
	-- 		content = cjson.encode({
	-- 			pic = "",
	-- 			text = "ceshi",
	-- 			contents = {
	-- 				{title="title1", text = "text1"},
	-- 				{title="title2", text = "text2"},
	-- 			}
	-- 		})
	-- 	},
	-- 	{
	-- 		title= "系统公告2",
	-- 		hot=1,
	-- 		content = cjson.encode({
	-- 			pic = "Schedule/bg_schedule_1001.png",
	-- 			text = "ceshi2",
	-- 			contents = {
	-- 				{title="title1", text = "text1"},
	-- 				{title="title2", text = "text2"},
	-- 			}
	-- 		})
	-- 	}
	-- }
	-- g_LoginCtrl:SetNoticeList(lNotices)
	local lNotices = g_LoginCtrl:ReadNotices() 
	self.m_NoticeGrid:Clear()
	if lNotices then
		for i, dNotice in ipairs(lNotices) do
			local oBox = self.m_NoticeBox:Clone()
			oBox:SetActive(true)
			oBox.m_Btn = oBox:NewUI(1, CButton)
			oBox.m_HotSpr = oBox:NewUI(2, CSprite)
			oBox.m_NewSpr = oBox:NewUI(3, CSprite)
			oBox.m_Notice = dNotice
			oBox.m_Btn:AddUIEvent("click", callback(self, "SelNoticeBox", oBox))
			oBox.m_NewSpr:SetActive(dNotice.hot == 1)
			oBox.m_HotSpr:SetActive(dNotice.hot == 2)
			oBox.m_Btn:SetText(dNotice.title)
			oBox:SetGroup(self.m_NoticeGrid:GetInstanceID())
			if not self.m_CurSel then
				self:SelNoticeBox(oBox)
			end
			self.m_NoticeGrid:AddChild(oBox)
		end
		self.m_NoticeGrid:Reposition()
	end
end

function CLoginNoticeView.SelNoticeBox(self, oBox)
	oBox:SetSelected(true)
	self.m_CurSel = oBox
	local dNotice = oBox.m_Notice
	local bLoadPic = dNotice.content.pic and #dNotice.content.pic > 0 
	if bLoadPic then
		self.m_MainContentTexture:LoadPath("Texture/"..dNotice.content.pic)
		self:SetUITpye(0)
	else
		self:SetUITpye(1)
	end
	-- self.m_MainContentSpr:SetActive(not bLoadPic)
	-- self.m_MainContentTexture:SetActive(bLoadPic)
	self.m_MainTextLabel:SetText(dNotice.content.text or dNotice.title)
	self.m_ScrollView:ResetPosition()
	self.m_SubContentTable:Clear()
	for i, v in ipairs(dNotice.content.contents) do
		local oSubBox = self.m_SubContentBox:Clone()
		oSubBox:SetActive(true)
		oSubBox.m_TitleLabel = oSubBox:NewUI(1, CLabel)
		oSubBox.m_TextLabel = oSubBox:NewUI(2, CLabel)
		oSubBox.m_TitleLabel:SetText(v.title)
		oSubBox.m_TextLabel:SetText(v.text)
		self.m_SubContentTable:AddChild(oSubBox)
	end
	self.m_SubContentTable:Reposition()
end

function CLoginNoticeView.SetUITpye(self, iType)
	if iType == 1 then
		self.m_MainContentTexture:SetActive(false)
		self.m_ContentBox:SetHeight(548)
		self.m_ContentBox:SetLocalPos(Vector3.New(self.m_ContentBoxPos.x, 258, self.m_ContentBoxPos.z))
	elseif iType == 0 then
		self.m_MainContentTexture:SetActive(true)
		self.m_ContentBox:SetHeight(self.m_ContentBoxH)
		self.m_ContentBox:SetLocalPos(self.m_ContentBoxPos)
	end
end

return CLoginNoticeView