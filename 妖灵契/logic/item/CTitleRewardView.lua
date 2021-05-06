local CTitleRewardView = class("CTitleRewardView", CViewBase)

function CTitleRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/TitleRewardView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CTitleRewardView.OnCreateView(self)	
	self.m_Container = self:NewUI(1, CBox)
	self.m_ItemParentBox = self:NewUI(2, CBox)
	self.m_ItemCloneBox = self:NewUI(3, CBox)
	self.m_ItemWidget = self:NewUI(4, CWidget)
	self.m_MaskBtn = self:NewUI(5, CBox)
	self.m_BGTopTextrue = self:NewUI(6, CTexture)
	self.m_BGTopTextrue.m_Tween = self.m_BGTopTextrue:GetComponent(classtype.TweenWidth)
	self.m_TitleTextrue = self:NewUI(7, CTexture)
	self.m_TipsLabel = self:NewUI(8, CLabel)
	self.m_ScrollView = self:NewUI(9, CScrollView)
	self.m_DragScrollBox = self:NewUI(10, CBox)
	self.m_TitleSprite = self:NewUI(11, CSprite)
	self.m_TitleLabel = self:NewUI(12, CLabel)
	self.m_TitleDownSprite = self:NewUI(13, CSprite)
	self.m_DescLabel = self:NewUI(14, CLabel)
	self.m_UseBtn = self:NewUI(15, CButton)
	self.m_IsAni = false
	self.m_IsOpenAni = false
	self.m_StartOpenTimer = nil
	self.m_IgnoreCloseAni = false
	self.m_CurrentID = nil
	self.m_BoxList = {}
	self:InitContent()
	UITools.ResizeToRootSize(self.m_Container)
end

function CTitleRewardView.InitContent(self)
	self.m_ItemCloneBox:SetActive(false)
	self.m_UseBtn:AddUIEvent("click", callback(self, "OnUse"))
	self.m_MaskBtn:AddUIEvent("click", callback(self, "OnCustomClose"))
	self.m_DragScrollBox:AddUIEvent("click", callback(self, "OnCustomClose"))
	self:SetData()
end

--显示的格式是{sid = 10001, count = 22 }
function CTitleRewardView.SetData(self)
	local titleInfo = g_TitleCtrl.m_NewTitle[1]
	if titleInfo then
		local titleName = nil
		local spriteName = nil
		local tempTitleData = data.titledata.DATA[titleInfo.tid]
		self.m_CurrentID = titleInfo.tid
		-- self.m_UseBtn:SetActive(tempTitleData.type == 0)
		local sName = tempTitleData.name
		if titleInfo.name ~= nil and titleInfo.name ~= "" then
			sName = titleInfo.name
		end
		if tempTitleData.text_color ~= "" then
			titleName = string.format("[%s]%s[-]", tempTitleData.text_color, sName)
		else
			titleName = sName
		end
		spriteName = tempTitleData.icon
		if spriteName ~= nil and spriteName ~= "" then
			self.m_TitleSprite:SpriteTitle(spriteName)
			self.m_TitleDownSprite:SpriteTitle(spriteName)
			self.m_TitleLabel:SetActive(false)
			self.m_TitleSprite:SetActive(true)
			self.m_TitleDownSprite:SetActive(true)
		elseif titleName ~= nil then
			self.m_TitleDownSprite:SetActive(false)
			self.m_TitleSprite:SetActive(false)
			self.m_TitleLabel:SetActive(true)
			self.m_TitleLabel:SetText(titleName)
		end
		self.m_TitleSprite:MakePixelPerfect()
		self.m_TitleDownSprite:MakePixelPerfect()
		self.m_DescLabel:SetText(tempTitleData.desc)
		table.remove(g_TitleCtrl.m_NewTitle, 1)
		self:StartOpenOffect()
	else
		self:CloseView()
	end
end

function CTitleRewardView.OnCustomClose(self)
	if not self.m_IsAni and not self.m_IsOpenAni then
		if self.m_TweenTimer then
			Utils.DelTimer(self.m_TweenTimer)
			self.m_TweenTimer = nil
		end
		self:DoAni()
	end
end

function CTitleRewardView.OpenDOTween(self)
	local defaultCloseTime = tonumber(data.globaldata.GLOBAL.reward_list_view_close_time.value)
	if defaultCloseTime ~= 0 then		
		if self.m_TweenTimer then
			Utils.DelTimer(self.m_TweenTimer)
			self.m_TweenTimer = nil
		end
		self.m_TweenTimer = Utils.AddTimer(callback(self, "DoAni") , 0, defaultCloseTime)
	end
end

function CTitleRewardView.DoAni(self)
	if Utils.IsNil(self) then
		Utils.DelTimer(self.m_TweenTimer)
		self.m_TweenTimer = nil
		return
	end
	self:SetData()
	return true
	-- if self.m_IgnoreCloseAni then
		-- self:CloseView()
	-- 	return
	-- end

	-- --暂时隐藏动画
	-- self.m_IsAni = true
	-- local mainmenuview = CMainMenuView:GetView()
	-- local notifyView = CNotifyView:GetView()
	-- local bHaveItem = false
	-- local bHavePartner = false
	-- local bHaveHouse = false
	-- local divTime = 0.1
	-- local cnt = 0
	-- for i = #self.m_BoxList, 1, -1 do
	-- 	local oBox = self.m_BoxList[i]
	-- 	local oPos
	-- 	oBox.m_QualitySprite:SetActive(false)
	-- 	oBox.m_CountLabel:SetActive(false)
	-- 	oBox.m_NameLabel:SetActive(false)
	-- 	if oBox.m_EffectBox then
	-- 		oBox.m_EffectBox:SetActive(false)
	-- 	end
	-- 	if oBox.m_EffectShanBox.m_Animator then
	-- 		oBox.m_EffectShanBox.m_Animator.enabled = false
	-- 	end		
	-- 	local obox = oBox:Clone()
	-- 	local sid = oBox.m_Sid
	-- 	local partnerId = oBox.m_PartnerID
	-- 	local housepartnerId = oBox.m_HousePartnerID
	-- 	local isDown = true
	-- 	if mainmenuview then
	-- 		if oBox.m_HousePartnerID then
	-- 			local btn = mainmenuview.m_RB.m_HouseBtn 
	-- 			oPos = btn:GetPos()
	-- 			isDown = false
	-- 			bHaveHouse = true
	-- 		elseif g_ItemCtrl:GetItemSubTypeBySid(sid) == define.Item.ItemSubType.Partnerequip or
	-- 			(sid == 1010 and partnerId ~= nil) then
	-- 			local btn = mainmenuview.m_RB.m_PartnerBtn 
	-- 			oPos = btn:GetPos()
	-- 			isDown = false
	-- 			bHavePartner = true
	-- 		else
	-- 			local btn = mainmenuview.m_RB.m_ItemBtn 
	-- 			oPos = btn:GetPos()
	-- 			bHaveItem = true
	-- 		end
	-- 	else
	-- 		oPos = Vector3.New(0, 0, 0)
	-- 	end
	-- 	if notifyView then
	-- 		obox:SetParent(notifyView.m_RewardListBox.m_Transform)
	-- 	else
	-- 		self:CloseView()
	-- 		return
	-- 	end		
	-- 	obox:SetPos(oBox:GetPos())		
	-- 	local wrap = function()
	-- 		if not Utils.IsNil(obox) then				
	-- 			--DOTween.DOScale(obox.m_Transform, Vector3.New(0, 0, 0), 2)	
	-- 			local tween = DOTween.DOMove(obox.m_Transform, oPos, 1.5)						
	-- 			DOTween.SetEase(tween, enum.DOTween.Ease.InOutQuad)
	-- 			DOTween.OnComplete(tween, function ()
	-- 				--只执行一次
	-- 				if mainmenuview and i == #self.m_BoxList and bHaveItem then
	-- 					mainmenuview:BagItemDoTweenScale()
	-- 				end
	-- 				if mainmenuview and i == #self.m_BoxList and bHavePartner then
	-- 					mainmenuview:TweenPartnerBtn()
	-- 				end
	-- 				if mainmenuview and i == #self.m_BoxList and bHaveHouse then
	-- 					mainmenuview:TweenHouseBtn()
	-- 				end
	-- 				obox:Destroy()
	-- 			end)	
	-- 		end
	-- 	end
	-- 	Utils.AddTimer(wrap, 0, cnt * divTime)
	-- 	cnt = cnt + 1
	-- end
	-- self:CloseView()
end

function CTitleRewardView.RePosition(self)
	-- self.m_BGTopTextrue:SetSize(self.m_Container:GetWidth(), 448)
	-- local list = self.m_BoxList
	-- if #list > 0 then

	-- 	for i,v in ipairs(list) do
	-- 		v:SetActive(false)
	-- 	end
	-- 	local w, h = 120, 110	
	-- 	if #list <= 6 then
	-- 		local startX = (w / 2) - (w * (#list / 2))
	-- 		for i = 1, #list do				
	-- 			list[i]:SetLocalPos(Vector3.New(startX + (i - 1) * w , 0 , 0))				
	-- 		end			
	-- 	else
	-- 		local offStartY = 0
	-- 		if #list <= 6 then
	-- 			offStartY = 0
	-- 		elseif #list >6 and #list <= 12 then
	-- 			offStartY = h / 2
	-- 		else
	-- 			offStartY = h - 20
	-- 		end
	-- 		for i = 1, #list do
	-- 			local startX = (w / 2) - (w * (6 / 2))
	-- 			if i <= 6 then					
	-- 				for i = 1, #list do				
	-- 					list[i]:SetLocalPos(Vector3.New(startX + (i - 1) * w , offStartY , 0))				
	-- 				end	
	-- 			else
	-- 				local row 
	-- 				if i % 6 == 0 then
	-- 					row = i / 6
	-- 				else
	-- 					row = math.floor(i / 6) + 1
	-- 				end	
	-- 				local startSecond
	-- 				if row % 2 == 1 then
	-- 					startSecond = startX 
	-- 				else
	-- 					startSecond = startX + w / 2
	-- 				end 
	-- 				local col
	-- 				if i % 6 == 0 then
	-- 					col = 6
	-- 				else
	-- 					col = i % 6
	-- 				end
	-- 				local startY = -(row - 1) * h
	-- 				list[i]:SetLocalPos(Vector3.New(startSecond + (col - 1) * w , startY + offStartY , 0))				
	-- 			end
	-- 		end
	-- 	end
	-- end
end

function CTitleRewardView.SetTweenCompleteCB(self, cb)
	self.m_TweenCompleteCB = cb
end

function CTitleRewardView.CloseView(self)
	local oView = CItemTipsMainView:GetView()
	if oView and oView.m_OpenView == self then
		oView:CloseView()
	end
	if self.m_TweenCompleteCB then
		self.m_TweenCompleteCB()
		self.m_TweenCompleteCB = nil
	end
	CViewBase.CloseView(self)
end

function CTitleRewardView.Destroy(self)
	if self.m_StartOpenTimer then
		Utils.DelTimer(self.m_StartOpenTimer)
		self.m_StartOpenTimer = nil
	end	
	CViewBase.Destroy(self)
end

function CTitleRewardView.StartOpenOffect(self)
	self.m_ItemCloneBox:SetActive(false)
	self.m_ItemCloneBox:DelayCall(0.4, "SetActive", true)
	self.m_TitleTextrue:SetLocalScale(Vector3.New(2, 2, 2))
	self.m_TitleTextrue:SetAlpha(0.2)
	self.m_TiTleVectorAction = CActionVector.New(self.m_TitleTextrue, 0.2, "SetLocalScale", Vector3.New(2, 2, 2), Vector3.New(1, 1, 1))
	g_ActionCtrl:AddAction(self.m_TiTleVectorAction)
	self.m_TiTleFloatAction = CActionFloat.New(self.m_TitleTextrue, 0.2, "SetAlpha", 0.2, 1)
	g_ActionCtrl:AddAction(self.m_TiTleFloatAction)

	self.m_BGTopTextrue:SetLocalScale(Vector3.New(0, 1, 0))
	DOTween.DOScale(self.m_BGTopTextrue.m_Transform, Vector3.New(1, 1, 1), 0.3)
	
	-- self.m_BGTopTextrue:SetWidth(0)
	-- self.m_BGTopTextrue.m_Tween.to = self.m_Container:GetWidth()
	-- self.m_BGTopTextrue.m_Tween:Toggle()

	-- for i,v in ipairs(self.m_BoxList) do
	-- 	v:DelayCall(i * 0.1 + 0.3, "SetActive", true)
	-- end

	if self.m_StartOpenTimer then
		Utils.DelTimer(self.m_StartOpenTimer)
		self.m_StartOpenTimer = nil
	end
	self.m_IsOpenAni = true
	self.m_TipsLabel:SetActive(false)
	local openTime = #self.m_BoxList * 0.1 + 1
	local cb = function ()
		self.m_IsOpenAni = false
		self.m_TipsLabel:SetActive(true)
	end
	self.m_StartOpenTimer = Utils.AddTimer(cb, 0, openTime)
end

function CTitleRewardView.OnUse(self)
	printc("OnUse: " .. self.m_CurrentID)
	nettitle.C2GSUseTitle(self.m_CurrentID, define.Title.HandleType.ShowTitle)
	self:OnCustomClose()
end

return CTitleRewardView