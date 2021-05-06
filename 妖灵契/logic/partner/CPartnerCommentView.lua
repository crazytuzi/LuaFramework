local CPartnerCommentView = class("CPartnerCommentView", CViewBase)

function CPartnerCommentView.ctor(self, cb)
	CViewBase.ctor(self, "UI/partner/PartnerCommentView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CPartnerCommentView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_PartnerBox = self:NewUI(2, CBox)
	self.m_CommentItem = self:NewUI(3, CPartnerCommentItem)
	self.m_Table = self:NewUI(4, CTable)
	self.m_Input = self:NewUI(5, CInput)
	self.m_CommentBtn = self:NewUI(6, CButton)
	self.m_TitleBox = self:NewUI(7, CBox)
	self.m_GreySpr = self:NewUI(8, CSprite)

	self.m_NameLabel = self.m_PartnerBox:NewUI(1, CLabel)
	--self.m_RareSpr = self.m_PartnerBox:NewUI(2, CSprite)
	self.m_BorderSpr = self.m_PartnerBox:NewUI(3, CSprite)
	self.m_IconSpr = self.m_PartnerBox:NewUI(4, CSprite)

	self.m_CommentItem:SetActive(false)
	self.m_TitleBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CommentBtn:AddUIEvent("click", callback(self, "OnComment"))
	self.m_GreySpr:AddUIEvent("click", function() g_NotifyCtrl:FloatMsg("你今天已经评论过该伙伴") end)
end

function CPartnerCommentView.RefreshData(self, partnertype, list, hotlist, is_comment)
	local pdata = data.partnerdata.DATA[partnertype]
	self.m_ID = partnertype
	if pdata then
		self.m_NameLabel:SetText(pdata.name)
		self.m_IconSpr:SpriteAvatar(pdata.icon)
		g_PartnerCtrl:ChangeRareBorder(self.m_BorderSpr, pdata.rare)
		self:UpdateComment(list, hotlist)
		self.m_GreySpr:SetActive(is_comment == 1)
	end
end

function CPartnerCommentView.UpdateComment(self, list, hotlist)
	self.m_Table:Clear()
	local flag = false
	local isblack = true
	local hottList = {}
	local normalList = {}
	
	for _, data in ipairs(hotlist) do
		if data["pid"] ~= g_AttrCtrl.pid and g_MaskWordCtrl:IsContainHideStr(data["msg"]) then
		else
			table.insert(hottList, data)
		end
	end
	for _, data in ipairs(list) do
		if data["pid"] ~= g_AttrCtrl.pid and g_MaskWordCtrl:IsContainHideStr(data["msg"]) then
		else
			table.insert(normalList, data)
		end
	end

	if #hottList > 0 then
		local titleobj = self:CreateTitle("最佳评论", isblack)
		isblack = not isblack
		self.m_Table:AddChild(titleobj)
		for k, data in ipairs(hottList) do
			local oItem = self.m_CommentItem:Clone()
			oItem:SetActive(true)
			oItem:SetData(data, self.m_ID, 1)
			oItem:SetBGColor(isblack)
			isblack = not isblack
			self.m_Table:AddChild(oItem)
		end
	end
	if #normalList > 0 then
		local titleobj = self:CreateTitle("更多评论", isblack)
		isblack = not isblack
		self.m_Table:AddChild(titleobj)
		table.sort(normalList, function(a, b) return a.create_time > b.create_time end)
		for k, data in ipairs(normalList) do
			local oItem = self.m_CommentItem:Clone()
			oItem:SetActive(true)
			oItem:SetData(data, self.m_ID, 0)
			oItem:SetBGColor(isblack)
			isblack = not isblack
			self.m_Table:AddChild(oItem)
		end
	end
	self.m_Table:Reposition()
end

function CPartnerCommentView.CreateTitle(self, text, isblack)
	local titleobj = self.m_TitleBox:Clone()
	titleobj.m_Label = titleobj:NewUI(1, CLabel)
	--titleobj.m_BGSpr = titleobj:NewUI(2, CSprite)
	titleobj:SetActive(true)
	titleobj.m_Label:SetText(text)
	-- if isblack then
	-- 	titleobj.m_BGSpr:SetSpriteName("bg_ciji_di")
	-- else
	-- 	titleobj.m_BGSpr:SetSpriteName("bg_fenge") 
	-- end
	return titleobj
end

function CPartnerCommentView.OnComment(self)
	local msg = self.m_Input:GetText()
	
	if msg == "" then
		g_NotifyCtrl:FloatMsg("请输入发送内容")
		return
	end
	if g_MaskWordCtrl:IsContainMaskWord(msg) then
		g_NotifyCtrl:FloatMsg("内容含敏感词汇，请修改后进行评论")
		return
	else
		netpartner.C2GSAddPartnerComment(self.m_ID, msg)
	end
	self.m_Input:SetText("")
end

return CPartnerCommentView
