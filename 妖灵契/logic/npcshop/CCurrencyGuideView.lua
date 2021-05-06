local CCurrencyGuideView = class("CCurrencyGuideView", CViewBase)

function CCurrencyGuideView.ctor(self, cb)
	CViewBase.ctor(self, "UI/NpcShop/CurrencyGuideView.prefab", cb)
	--界面设置
	-- self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CCurrencyGuideView.OnCreateView(self)
	self.m_InfoGrid = self:NewUI(2, CGrid)
	self.m_InfoBox = self:NewUI(3, CBox)

	self:InitContent()
end

function CCurrencyGuideView.InitContent(self)
	self.m_InfoBox:SetActive(false)
	-- self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
	g_ViewCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnViewEvent"))
end

function CCurrencyGuideView.SetData(self, oData)
	-- self.m_CurrencySprite:SetSpriteName(oData.icon)
	-- self.m_CurrencyNameLabel:SetText(oData.name)
	for i,v in ipairs(oData.get_way) do
		local oInfoBox = self:CreateInfoBox()
		self.m_InfoGrid:AddChild(oInfoBox)
		oInfoBox:SetActive(true)
		oInfoBox:SetData(data.npcstoredata.CurrencyGuide[v])
	end
end

function CCurrencyGuideView.CreateInfoBox(self)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_TitleLabel = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_DescLabel = oInfoBox:NewUI(2, CLabel)
	-- oInfoBox.m_IconSprite = oInfoBox:NewUI(3, CSprite)
	oInfoBox.m_GoBtn = oInfoBox:NewUI(4, CButton)
	oInfoBox.m_OpenGradeLabel = oInfoBox:NewUI(5, CLabel)
	oInfoBox.m_GoBtn:AddUIEvent("click", callback(self, "OnClickGo", oInfoBox))
	
	function oInfoBox.SetData(self, oData)
		oInfoBox.m_Data = oData
		oInfoBox.m_TitleLabel:SetText(oData.name)
		oInfoBox.m_DescLabel:SetText(oData.desc)
		-- oInfoBox.m_IconSprite:SetSpriteName(oData.icon)
		local openGrade = data.globalcontroldata.GLOBAL_CONTROL[oData.control_key].open_grade
		if openGrade > g_AttrCtrl.grade then
			oInfoBox.m_OpenGradeLabel:SetText(string.format("%s级开启", openGrade))
			oInfoBox.m_OpenGradeLabel:SetActive(true)
			oInfoBox.m_GoBtn:SetActive(false)
		else
			oInfoBox.m_OpenGradeLabel:SetActive(false)
			oInfoBox.m_GoBtn:SetActive(true)
		end
	end
	return oInfoBox
end

-- function CCurrencyGuideView.OnClickClose(self)
-- 	self:OnClose()
-- end

function CCurrencyGuideView.OnViewEvent(self, oCtrl)
	-- printc("OnViewEvent: " .. oCtrl.m_EventData)
	if oCtrl.m_EventID == define.View.Event.OnShowView then
		if oCtrl.m_EventData == self.m_OpeningCls then
			if self.m_CloseShop then
				CNpcShopView:CloseView()
				g_ViewCtrl:ClearEnvInfo()
			end
			self:OnClose()
		end
	end
end

function CCurrencyGuideView.OnClickGo(self, oInfoBox)
	if g_WarCtrl:IsWar() and oInfoBox.m_Data.go_inwar == 1 then
		g_NotifyCtrl:FloatMsg("战斗中无法进行此操作")
		return
	end
	self.m_OpeningCls = oInfoBox.m_Data.cls_name
	self.m_CloseShop = oInfoBox.m_Data.need_close == 0
	-- printc("OnClickGo: " .. oInfoBox.m_Data.open_id)

	--活动跳转屏蔽
	if not g_ActivityCtrl:ActivityBlockContrl("store_resource") then
    	return
   	end
 	if oInfoBox.m_Data.blockkey and oInfoBox.m_Data.blockkey ~= "" and not g_ActivityCtrl:ActivityBlockContrl(oInfoBox.m_Data.blockkey) then
    	return
   	end

	local openID = oInfoBox.m_Data.open_id
	-- --跳转到商店
	if openID > 500 and openID < 600 or openID == 1034 then
		self:OnClose()
	end
	g_OpenUICtrl:OpenUI(openID)
end

return CCurrencyGuideView