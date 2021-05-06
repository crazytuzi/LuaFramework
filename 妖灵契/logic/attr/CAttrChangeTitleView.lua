local CAttrChangeTitleView = class("CAttrChangeTitleView", CViewBase)

CAttrChangeTitleView.m_DefaultTitle = nil

function CAttrChangeTitleView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Attr/AttrChangeTitleView.prefab", cb)

	self.m_ExtendClose = "Black"
end

function CAttrChangeTitleView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_WrapContent = self:NewUI(2, CWrapContent)
	self.m_TitleBox = self:NewUI(3, CBox)
	self.m_DescriptionLabel = self:NewUI(4, CLabel)
	self.m_OriginLabel = self:NewUI(5, CLabel)
	self.m_ProgessLabel = self:NewUI(6, CLabel)
	self.m_TimeOutLabel = self:NewUI(7, CLabel)
	self.m_TimeSprite = self:NewUI(8, CSprite)
	self.m_HideBtn = self:NewUI(9, CButton)
	self.m_DesciptionTable = self:NewUI(10, CTable)
	self.m_CantShowLabel = self:NewUI(11, CLabel)
	self.m_ProgressPart = self:NewUI(12, CBox)
	self.m_ShowBtn = self:NewUI(13, CButton)
	self.m_RoleSideBtn = self:NewUI(14, CButton)
	self.m_PartnerSideBtn = self:NewUI(15, CButton)
	self.m_TitleScrollView = self:NewUI(16, CScrollView)
	self:InitContent()
end

function CAttrChangeTitleView.InitContent(self)
	self.m_RoleSideBtn:SetGroup(self.m_RoleSideBtn:GetInstanceID())
	self.m_PartnerSideBtn:SetGroup(self.m_RoleSideBtn:GetInstanceID())

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_HideBtn:AddUIEvent("click", callback(self, "OnHideBtn"))
	self.m_ShowBtn:AddUIEvent("click", callback(self, "OnShowBtn"))
	self.m_RoleSideBtn:AddUIEvent("click", callback(self, "OnChangeSide"))
	self.m_PartnerSideBtn:AddUIEvent("click", callback(self, "OnChangeSide"))

	self.m_TitleBoxArr = {}
	self.m_CurrentBtn = nil
	self.m_CurrentID = nil
	self.m_Data = data.titledata.DATA
	self.m_RoleSideBtn:SetSelected(true)
	self.m_Type = 1
	self:InitTypePart()
	self:SetData()
	self.m_TitleBox:SetActive(false)
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChangeTitle"))
	g_TitleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
end

function CAttrChangeTitleView.InitTypePart(self)
	self.m_WrapContent:SetCloneChild(self.m_TitleBox, 
		function(oChild)
			oChild = self:CreateTitleBox(oChild)
			return oChild
		end
	)
	
	self.m_WrapContent:SetRefreshFunc(function(oChild, idx)
		if idx then
			oChild:SetData(self.m_Data[idx])
			oChild:SetActive(true)
		else
			oChild:SetActive(false)
		end
	end)
end

function CAttrChangeTitleView.IsShowing(self, tid)
	return self.m_OnShowDic[tid]
end

function CAttrChangeTitleView.OnShowBtn(self)
	nettitle.C2GSUseTitle(self.m_CurrentID, define.Title.HandleType.ShowTitle)
end

function CAttrChangeTitleView.OnHideBtn(self)
	nettitle.C2GSUseTitle(self.m_CurrentID, define.Title.HandleType.CancelTitle)
end

function CAttrChangeTitleView.SetData(self)
	self.m_CurrentTitleInfoList = g_AttrCtrl.title_info
	self.m_OnShowDic = {}
	for k,v in pairs(g_AttrCtrl.title_info) do
		self.m_OnShowDic[v.tid] = true
	end
	local sortList = {}
	if self.m_Type == 1 then
		sortList = g_TitleCtrl:GetRoleList()
	else
		sortList = g_TitleCtrl:GetPartnerList()
	end
	self.m_WrapContent:SetData(sortList, true)
	self:ResetSelect()
	for _, titleBox in ipairs(self.m_WrapContent:GetChildList()) do
		if titleBox.m_ID == sortList[1] then
			self:OnClickBtn(titleBox)
		end
	end
	self.m_TitleScrollView:ResetPosition()
end

function CAttrChangeTitleView.CreateTitleBox(self, oBox)
	oBox.m_Btn = oBox:NewUI(1, CBox)
	oBox.m_TitleLabel = oBox:NewUI(2, CLabel)
	oBox.m_OnShowSprite = oBox:NewUI(3, CSprite)
	oBox.m_StatusSprite = oBox:NewUI(4, CSprite)
	oBox.m_TitleSprite = oBox:NewUI(5, CSprite)
	oBox.m_OnSelectSprite = oBox:NewUI(6, CSprite)

	oBox.m_OnSelectSprite:SetActive(false)
	oBox.m_ParentView = self
	oBox.m_Btn:AddUIEvent("click", callback(self, "OnClickBtn", oBox))
	
	function oBox.Refresh(self, oInfo)
		local titleName = nil
		local tempTitleData = data.titledata.DATA[oInfo.tid]
		local sName = tempTitleData.name
		if oInfo.name ~= nil and oInfo.name ~= "" then
			sName = oInfo.name
		end
		if tempTitleData.text_color ~= "" then
			titleName = string.format("[%s]%s[-]", tempTitleData.text_color, sName)
		else
			titleName = string.format("[FFCD00]%s[-]", sName)
		end
		if oInfo == nil or oInfo.progress < oBox.m_Data.condition_value or oInfo.create_time == 0 then
			oBox.m_TitleSprite:SetGrey(true)
			oBox.m_StatusSprite:SetGrey(true)
			titleName = string.format("[e0e0e0]%s[-]", sName)
		else
			oBox.m_TitleSprite:SetGrey(false)
			oBox.m_StatusSprite:SetGrey(false)
		end
		oBox.m_TitleLabel:SetText(titleName)
		oBox.m_OnSelectSprite:SetActive(oBox.m_ParentView.m_CurrentID == oBox.m_ID)
		oBox.m_OnShowSprite:SetActive(oInfo ~= nil and oBox.m_ParentView:IsShowing(oInfo.tid))
	end

	function oBox.SetData(self, oData)
		oBox.m_Data = oData
		if oData.icon ~= "" then
			oBox.m_TitleSprite:SpriteTitle(oData.icon)
			oBox.m_TitleSprite:MakePixelPerfect()
			oBox.m_TitleSprite:SetActive(true)
			oBox.m_TitleLabel:SetActive(false)
		else
			oBox.m_TitleLabel:SetActive(true)
			oBox.m_TitleSprite:SetActive(false)
		end
		oBox.m_ID = oData.id
		oBox:Refresh(g_TitleCtrl:GetTitleInfo(oBox.m_Data.id))
	end
	return oBox
end

function CAttrChangeTitleView.OnChangeSide(self)
	if self.m_PartnerSideBtn:GetSelected() then
		self.m_Type = 2
	elseif self.m_RoleSideBtn:GetSelected() then
		self.m_Type = 1
	end
	self:SetData()
end

function CAttrChangeTitleView.OnClickBtn(self, oBox)
	self:ResetSelect()
	self.m_CurrentID = oBox.m_ID
	oBox.m_OnSelectSprite:SetActive(true)
	self.m_DescriptionLabel:SetText(oBox.m_Data.desc)
	self.m_OriginLabel:SetText(oBox.m_Data.access)
	local titleInfo = g_TitleCtrl:GetTitleInfo(oBox.m_Data.id)
	self.m_ProgessLabel:SetText(string.format("当前进度：%s/%s", titleInfo.progress, oBox.m_Data.condition_value))
	
	if oBox.m_Data.duration_time ~= 0 and titleInfo.left_time ~= 0 then
		self.m_TimeOutLabel:SetText("过期时间:" .. os.date("%Y/%m/%d %H:%M", titleInfo.left_time))
		self.m_TimeSprite:SetActive(true)
	else
		self.m_TimeSprite:SetActive(false)
	end

	self.m_HideBtn:SetActive(false)
	self.m_ShowBtn:SetActive(false)
	self.m_ProgressPart:SetActive(false)
	if titleInfo.progress < oBox.m_Data.condition_value or titleInfo.create_time == 0 then
		self.m_CantShowLabel:SetActive(true)
		self.m_ProgressPart:SetActive(true)
	else
		self.m_CantShowLabel:SetActive(false)
		if self:IsShowing(oBox.m_Data.id) then
			self.m_HideBtn:SetActive(true)
		else
			self.m_ShowBtn:SetActive(true)
		end
	end
	if oBox.m_Data.type == 1 then
		self.m_HideBtn:SetActive(false)
		self.m_ShowBtn:SetActive(false)
		self.m_CantShowLabel:SetActive(true)
		self.m_CantShowLabel:SetText("相关伙伴为跟随状态时默认显示")
	else
		self.m_CantShowLabel:SetText("您未获得该称谓")
	end
	self.m_DesciptionTable:Reposition()
end

function CAttrChangeTitleView.ResetSelect(self)
	for _, titleBox in ipairs(self.m_WrapContent:GetChildList()) do
		titleBox.m_OnSelectSprite:SetActive(false)
	end
end

function CAttrChangeTitleView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Title.Event.OnGetTitleList then
		self:SetData()
	elseif oCtrl.m_EventID == define.Title.Event.OnUpdateTitleInfo then
		--self.m_TitleBoxDic[oCtrl.m_EventData]:SetData(self.m_Data[oCtrl.m_EventData])
	elseif oCtrl.m_EventID == define.Title.Event.RemoveTitles then
		self:SetData()
	end
end

function CAttrChangeTitleView.OnChangeTitle(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if self.m_CurrentTitleInfoList ~= g_AttrCtrl.title_info then
			if #self.m_CurrentTitleInfoList > #g_AttrCtrl.title_info then
				g_NotifyCtrl:FloatMsg("隐藏成功")
			else
				g_NotifyCtrl:FloatMsg("展示成功")
			end
			self:SetData()
		end
	end
end

return CAttrChangeTitleView