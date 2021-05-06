local CPowerGuideMainView = class("CPowerGuideMainView", CViewBase)

function CPowerGuideMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/PowerGuide/PowerGuideMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	--self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_IsAlwaysShow = true
end

function CPowerGuideMainView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_AvaterSprite = self:NewUI(3, CSprite)
	self.m_TargetLevelLabel = self:NewUI(4, CLabel)
	self.m_TargetPowerLabel = self:NewUI(5, CLabel)
	self.m_PowerLabel = self:NewUI(6, CLabel)
	self.m_PowerLevelSprite = self:NewUI(7, CSprite)
	self.m_SingleMenuBox = self:NewUI(8, CBox)
	self.m_ContentGrid = self:NewUI(9, CGrid)
	self.m_ContentBox = self:NewUI(10, CBox)
	self.m_SelectTypeTable = self:NewUI(11, CTable)
	self.m_TypeMenuBox = self:NewUI(12, CPowerGuideTypeMenuBox)
	self.m_ContentScrollView = self:NewUI(13, CScrollView)
	self.m_InfoBtn = self:NewUI(14, CButton)
	self.m_FightGuideGroup = self:NewUI(15, CBox)
	--self.m_ScrollPage = self:NewUI(16, CFactoryPartScroll)  --暂时注释pageview的代码
	self.m_ContentGroup = self:NewUI(17, CBox)
	self.m_ScrollViewList = self:NewUI(18, CScrollView)
	self.m_TabGrid = self:NewUI(19, CGrid)
	self.m_TabCloneBox = self:NewUI(20, CBox)
	self.m_ListTable = self:NewUI(21, CTable)
	self.m_ListTableWidget = self:NewUI(21, CWidget)
	self.m_ListTitleCloneBox = self:NewUI(22, CBox)
	self.m_ListContentCloneBox = self:NewUI(23, CBox)
	self.m_ListPicCloneBox = self:NewUI(24, CBox)
	self.m_RecommendBtn = self:NewUI(25, CButton)
	self.m_MainPage = self:NewUI(26, CBox)
	self.m_RecommendPage = self:NewUI(27, CPartnerRecommendPage)

	self.m_DefualtSelect = nil
	self.m_TabIndex = 1
	self.m_MainMenuList = {}
	self.m_SingleMainMenuList = {}
	self.m_SubMenuList = {}
	self.m_ContentBoxList = {}
	self.m_ListBoxList = {}

	self:InitContent()

	nettask.C2GSFinishAchieveTask("查看成长手册", 1)
end

function CPowerGuideMainView.InitContent(self)
	local controlData = data.globalcontroldata.GLOBAL_CONTROL.partnerrecommend
	self.m_RecommendBtn:SetActive(false)
	self.m_TypeMenuBox:SetActive(false)
	self.m_ContentBox:SetActive(false)
	self.m_ContentGroup:SetActive(false)
	self.m_FightGuideGroup:SetActive(false)
	self.m_ListTitleCloneBox:SetActive(false)
	self.m_ListContentCloneBox:SetActive(false)
	self.m_ListPicCloneBox:SetActive(false)
	self.m_TabCloneBox:SetActive(false)
	self.m_SingleMenuBox:SetActive(false)
	self:InitTabIndex()
	--self:InitScrollPage()
	self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
	self.m_InfoBtn:AddUIEvent("click", callback(self, "OnClickInfo"))
	local isGuide = (g_GuideCtrl:IsCustomGuideFinishByKey("War3MainMenu")) and (not g_GuideCtrl:IsCustomGuideFinishByKey("ArenaPowerGuide"))
	self.m_DefualtSelect = g_PowerGuideCtrl:GetDefaultSelectId(self.m_TabIndex, isGuide)
	if isGuide then
		g_GuideCtrl:ReqCustomGuideFinish("ArenaPowerGuide")
	end
	self:RefreshAll(self.m_DefualtSelect)
end

function CPowerGuideMainView.OnRecommend(self)
	self.m_MainPage:SetActive(false)
	self.m_RecommendPage:SetActive(true)
	self.m_RecommendPage:ShowMain()
end

function CPowerGuideMainView.RefreshAll(self, selectId)
	self:RefreshMyInfo()
	self:RefreshTypeMenu(selectId)
end

function CPowerGuideMainView.RefreshMyInfo(self)
	local expectationPower = data.powerguidedata.EXPECTATION[g_AttrCtrl.grade].power
	local myPower = g_AttrCtrl:GetTotalPower()
	self.m_AvaterSprite:SpriteAvatar(g_AttrCtrl.model_info.shape)
	self.m_TargetLevelLabel:SetText(string.format("推荐战力"))
	self.m_TargetPowerLabel:SetText(string.format("%d", expectationPower))
	self.m_PowerLabel:SetText(string.format("%d", myPower))
	local powerLevel = "S"
	if myPower > expectationPower then
		powerLevel = "S"
	elseif myPower > expectationPower * 0.8 then	
		powerLevel = "A"
	elseif myPower > expectationPower * 0.6 then			
		powerLevel = "B"
	elseif myPower > expectationPower * 0.4 then			
		powerLevel = "C"
	else
		powerLevel = "D"
	end
	local pic = string.format("text_powerguide_%s", powerLevel)
	self.m_PowerLevelSprite:SetSpriteName(pic)
end

function CPowerGuideMainView.RefreshTypeMenu(self, selectId)
	selectId = selectId or g_PowerGuideCtrl:GetDefaultSelectId(self.m_TabIndex)
	self.m_SubMenuList = {}
	self.m_MainMenuList = {}
	self.m_SingleMainMenuList = {}
	--self.m_RecommendBtn:SetAsLastSibling()
	local menu = g_PowerGuideCtrl:GetPowerGuidTypeList(self.m_TabIndex)
	local TabOpenCache = g_PowerGuideCtrl.m_TabOpenCache
	if not TabOpenCache then
		TabOpenCache = {}
		TabOpenCache[1] = true
		for i = 2, #menu do
			TabOpenCache[i] = false
		end	
		g_PowerGuideCtrl.m_TabOpenCache = TabOpenCache
	end

	self.m_SelectTypeTable:Clear()
	if self.m_TabIndex == 1 then
		for i = 1, #menu do
			local oBox = self.m_SingleMenuBox:Clone()
			oBox:SetActive(true)
			oBox.m_MenuBtn = oBox:NewUI(1, CButton)
			oBox.m_Label = oBox:NewUI(2, CLabel)
			oBox.m_RedDotSprite = oBox:NewUI(3, CSprite)
			oBox.m_Label:SetText(menu[i].type_name)
			oBox.m_MenuBtn:AddUIEvent("click", callback(self, "OnClickSingleBtn", menu[i].id))
			self.m_SelectTypeTable:AddChild(oBox)
			oBox.m_MenuBtn:SetGroup(self.m_SelectTypeTable:GetInstanceID())		
			if menu[i].id == selectId then
				oBox.m_MenuBtn:SetSelected(true)
			end
			oBox.m_RedDotSprite:SetActive(false)
			if menu[i].id == 1001 then
				oBox.m_RedDotSprite:SetActive(g_PowerGuideCtrl:IsPowerHeroRedDot())
			elseif menu[i].id == 1002 then
				oBox.m_RedDotSprite:SetActive(g_PowerGuideCtrl:IsPowerPartnerRedDot())
			end

			oBox.m_MenuBtn.m_Id = menu[i].id
			self.m_SingleMainMenuList[i] = oBox.m_MenuBtn
		end
		--最后插入伙伴攻略
		local controlData = data.globalcontroldata.GLOBAL_CONTROL.partnerrecommend
		if g_AttrCtrl.grade >= controlData.open_grade and controlData.is_open == "y" then
			local oRecommendBtn = self.m_RecommendBtn:Clone()
			oRecommendBtn:SetActive(true)
			oRecommendBtn:AddUIEvent("click", callback(self, "OnRecommend"))
			self.m_SelectTypeTable:AddChild(oRecommendBtn)
			oRecommendBtn:SetGroup(self.m_SelectTypeTable:GetInstanceID())		
			oRecommendBtn.m_Id = 999
			self.m_SingleMainMenuList[#menu + 1] = oRecommendBtn
		end	
	else
		for i = 1, #menu do
			local t = menu[i]
			if t.main_type_list and #t.main_type_list > 0 then
				local typeMenuBox = self.m_TypeMenuBox:Clone(self)
				typeMenuBox:SetActive(true)
				local args = 
				{
					idx = i,
					clickMainCb = callback(self, "ClickMainTypeCallback")
				}			
				typeMenuBox:SetContent(t.type_name, t.main_type_list, self.m_SelectTypeTable:GetInstanceID(), 
					callback(self, "ClickSubTypeCallback"), TabOpenCache[i], selectId, args)	
				table.insert(self.m_MainMenuList, typeMenuBox) 
				self.m_SelectTypeTable:AddChild(typeMenuBox)	
			end	
		end		
	end
	self:RefreshContent(selectId)
end

function CPowerGuideMainView.AddSubMenuBox(self, oBox)
	table.insert(self.m_SubMenuList, oBox)
end

function CPowerGuideMainView.SetSubMenuBoxSelected(self, oBox)
	for k, v in pairs(self.m_SubMenuList) do
		if v and v:GetInstanceID() ~= oBox:GetInstanceID() then
			v.m_SelectSprite:SetActive(false)
		end
	end
end

function CPowerGuideMainView.ClickSubTypeCallback(self, id)
	self:RefreshContent(id)
end

function CPowerGuideMainView.ClickMainTypeCallback(self, idx, bOpen)
	if idx then
		g_PowerGuideCtrl.m_TabOpenCache[idx] = bOpen		
		for i, v in ipairs(g_PowerGuideCtrl.m_TabOpenCache) do			
			if i ~= idx and g_PowerGuideCtrl.m_TabOpenCache[i] == true then				
				g_PowerGuideCtrl.m_TabOpenCache[i] = false
				local oTypeMenu = self.m_MainMenuList[i]				
				if oTypeMenu then					
					oTypeMenu:HideSubMenu()
				end
			end
		end		
	end
end

function CPowerGuideMainView.RefreshContent(self, id)
	self.m_MainPage:SetActive(true)
	self.m_RecommendPage:SetActive(false)
	local fight_list = g_PowerGuideCtrl:GetFightGuideList(id)
	if not fight_list then
		self.m_ContentGroup:SetActive(true)
		self.m_FightGuideGroup:SetActive(false)
		local list = g_PowerGuideCtrl:GetSubMenuContentLis(id)
		if list and #list > 0 then		
			for i = 1, #list do
				local oContentBox = nil
				if i > #self.m_ContentBoxList then
					oContentBox = self.m_ContentBox:Clone()
					oContentBox.m_TargetIconSprite = oContentBox:NewUI(1, CSprite)
					oContentBox.m_TargetLabel = oContentBox:NewUI(2, CLabel)
					oContentBox.m_ProgressSlider = oContentBox:NewUI(3, CSlider)
					oContentBox.m_StarGrid = oContentBox:NewUI(4, CGrid)
					oContentBox.m_GoToBtn = oContentBox:NewUI(5, CButton)
					oContentBox.m_UnlockLabel = oContentBox:NewUI(6, CLabel)
					oContentBox.m_ProgressTipsLabel = oContentBox:NewUI(7, CLabel)
					oContentBox.m_RedDotSprite = oContentBox:NewUI(8, CSprite)
					oContentBox.m_DebugLabel = oContentBox:NewUI(9, CLabel)

					oContentBox.m_StarGrid:InitChild(function(obj, idx)
						local oBox = CBox.New(obj)
						oBox.m_Star = oBox:NewUI(1, CSprite)
						return oBox
					end)

					table.insert(self.m_ContentBoxList, oContentBox)
					self.m_ContentGrid:AddChild(oContentBox)
				else
					oContentBox = self.m_ContentBoxList[i]
				end
				oContentBox.m_GoToBtn:AddUIEvent("click", callback(self, "OnClickGoto", list[i].id))
				oContentBox:SetActive(true)	
				self:SetContentData(oContentBox, list[i])
			end
		
			if #list < #self.m_ContentBoxList then
				for i = #list + 1, #self.m_ContentBoxList do
					local oContentBox = self.m_ContentBoxList[i]
					if oContentBox then
						oContentBox:SetActive(false)
					end
				end
			end

			self.m_ContentGrid:Reposition()
			self.m_ContentScrollView:ResetPosition()
		end	
	else
		self.m_ContentGroup:SetActive(false)
		self.m_FightGuideGroup:SetActive(true)		
		self:SetListScrollViewData(fight_list)
		--self:ScrollPageSetData(fight_list)
	end
end

function CPowerGuideMainView.SetContentData(self, oBox, d)
	if not oBox or not d then
		return
	end
	oBox.m_TargetIconSprite:SetStaticSprite(d.atlas, d.icon)
	oBox.m_TargetLabel:SetText(d.name)
	oBox.m_TargetLabel:SetActive(false)
	oBox.m_TargetLabel:SetActive(true)
	oBox.m_RedDotSprite:SetActive(false)
	oBox.m_DebugLabel:SetActive(false)
	local isRedDot = false
	if d.progress_type == 1 then
		oBox.m_ProgressSlider:SetActive(true)
		oBox.m_ProgressTipsLabel:SetActive(false)
		local progress, cur, max = g_PowerGuideCtrl:GetProgressValue(d.key, d.progress)
		oBox.m_ProgressSlider:SetValue(progress)	
		local isMaxIgonoreRed = false
		if progress == 1 and d.max_ignore_red_dot == 1 then
			isMaxIgonoreRed = true
		end
		if not isMaxIgonoreRed and d.red_func and d.red_func ~= "" and g_PowerGuideCtrl[d.red_func] then			
			isRedDot = g_PowerGuideCtrl[d.red_func](g_PowerGuideCtrl)
		end
		if g_PowerGuideCtrl.m_Debug then
			oBox.m_DebugLabel:SetActive(true)
			oBox.m_DebugLabel:SetText(string.format("%d/%d", cur, max))
		end
				
	else
		oBox.m_ProgressSlider:SetActive(false)
		oBox.m_ProgressTipsLabel:SetActive(true)
		oBox.m_ProgressTipsLabel:SetText(d.progress)	
	end
	for i = 1, 5 do
		local oStar = oBox.m_StarGrid:GetChild(i)
		if i <= d.suggest_star then
			oStar:SetActive(true)
		else
			oStar:SetActive(false)
		end
	end
	if d.unlock_level > g_AttrCtrl.grade then
		oBox.m_GoToBtn:SetActive(false)
		oBox.m_UnlockLabel:SetActive(true)
		oBox.m_UnlockLabel:SetText(string.format("%d级开启", d.unlock_level))
	else
		oBox.m_GoToBtn:SetActive(true)
		oBox.m_UnlockLabel:SetActive(false)
		oBox.m_RedDotSprite:SetActive(isRedDot)
	end
end

function CPowerGuideMainView.OnClickGoto(self, id)
	local d = data.powerguidedata.SUB[id]
	if d then
		if d.special_key and d.special_key == "" then
			if g_ItemCtrl:ItemFindWayToSwitch(d.switch_id) then
				self:CloseView()
			end
		else
			if g_PowerGuideCtrl:SpecialGoto(d.special_key) then
				self:CloseView()
			end				
		end
	end
end

function CPowerGuideMainView.OnClickInfo(self)
	g_AchieveCtrl:C2GSAchieveMain()
	self:CloseView()
end

function CPowerGuideMainView.InitScrollPage(self)
	self.m_ScrollPage:SetPartSize(1, 1)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			local t = data.powerguidedata.FIGHT_GUIDE[dData.id]
			oBox.m_Label1 = oBox:NewUI(1, CLabel)
			oBox.m_Texture1 = oBox:NewUI(2, CTexture)
			oBox.m_Label2 = oBox:NewUI(3, CLabel)
			oBox.m_Texture2 = oBox:NewUI(4, CTexture)
			oBox.m_TitleLabel = oBox:NewUI(5, CLabel)
			oBox.m_Label1:SetText(t.text1)
			oBox.m_Label2:SetText(t.text2)
			oBox.m_Texture1:LoadPath(string.format("Texture/PowerGuide/%s", t.picpath1))
			oBox.m_Texture2:LoadPath(string.format("Texture/PowerGuide/%s", t.picpath2))			
			oBox.m_TitleLabel:SetText(t.name)
			self:SetSizeAndPos(oBox.m_Texture1, t.size1)
			self:SetSizeAndPos(oBox.m_Texture2, t.size2)
			oBox:SetActive(true)			
			return oBox
		end
	end
	self.m_ScrollPage:SetFactoryFunc(factory)
end

function CPowerGuideMainView.ScrollPageSetData(self, list)
	if not list or not next(list) then
		return 
	end
	local function loadData()
		local t = {}
		for k, v in ipairs(list) do
			local d = data.powerguidedata.FIGHT_GUIDE[v]
			if d then
				table.insert(t, d)
			end			
		end	
		return t
	end
	self.m_ScrollPage:SetDataSource(loadData)
	self.m_ScrollPage:RefreshAll()
end

function CPowerGuideMainView.SetSizeAndPos(self, oTextrue, size)
	if not oTextrue or not size or size == "" then
		return
	end
	local list = string.split(size, ",")
	if #list == 4 then
		oTextrue:SetSize(tonumber(list[1]), tonumber(list[2]))
		local pos = oTextrue:GetLocalPos()
		oTextrue:SetLocalPos(Vector3.New(pos.x + tonumber(list[3]), pos.y + tonumber(list[4]), 0))
	end
end

function CPowerGuideMainView.SetListScrollViewData(self, list)
	if not list or not next(list) then
		return 
	end
	local t = {}
	for k, v in ipairs(list) do
		local d = data.powerguidedata.FIGHT_GUIDE[v]
		if d then
			table.insert(t, d)
		end			
	end	
	if #t == 0 then
		return
	end 
	for i, v in ipairs(t) do
		local oBoxPool = self.m_ListBoxList[i]
		if not oBoxPool then
			local titleBox = self.m_ListTitleCloneBox:Clone()
			titleBox.m_TitleLabel = titleBox:NewUI(1, CLabel)
			local contentBox = self.m_ListContentCloneBox:Clone()
			contentBox.m_ContentLabel = contentBox:NewUI(1, CLabel)
			local picBox = self.m_ListPicCloneBox:Clone()
			picBox.m_PicTextrue = picBox:NewUI(1, CTexture)
			oBoxPool = {}
			oBoxPool.m_TitleBox = titleBox
			oBoxPool.m_ContentBox = contentBox
			oBoxPool.m_picBox = picBox
			self.m_ListTable:AddChild(titleBox)
			self.m_ListTable:AddChild(contentBox)
			self.m_ListTable:AddChild(picBox)
			table.insert(self.m_ListBoxList, oBoxPool)
		end
		oBoxPool.m_TitleBox:SetActive(true)
		oBoxPool.m_ContentBox:SetActive(true)
		oBoxPool.m_picBox:SetActive(true)
		oBoxPool.m_TitleBox.m_TitleLabel:SetText(string.format("%d %s", i , v.name))
		oBoxPool.m_ContentBox.m_ContentLabel:SetText(v.text1)
		oBoxPool.m_ContentBox:SetHeight(oBoxPool.m_ContentBox.m_ContentLabel:GetHeight())
		oBoxPool.m_picBox.m_PicTextrue:LoadPath(string.format("Texture/PowerGuide/%s", v.picpath1))
	end	
	local h = 0
	for i = 1, #self.m_ListBoxList do
		local pool = self.m_ListBoxList[i]
		h = h + pool.m_TitleBox:GetHeight()
		h = h + pool.m_ContentBox:GetHeight()
		h = h + pool.m_picBox:GetHeight()
	end
	self.m_ListTableWidget:SetHeight(h)
	self.m_ListTable:Reposition()
	self.m_ScrollViewList:ResetPosition()
end

function CPowerGuideMainView.ShowPartnerCommand(self, iParID, hideother)
	if hideother then
		self.m_SelectTypeTable:Clear()
	end
	self.m_MainPage:SetActive(false)
	self.m_RecommendPage:SetActive(true)
	self.m_RecommendPage:ShowMain()
	self.m_RecommendPage:ShowPartnerCommend(iParID)
end

function CPowerGuideMainView.InitTabIndex(self)
	local t = {}
	for i, v in pairs(data.powerguidedata.TAB_MENU) do
		table.insert(t, v)
	end
	table.sort(t, function(a, b)
		return a.id < b.id
	end)
	for i, v in ipairs(t) do
		local oTab = self.m_TabCloneBox:Clone()
		oTab.m_Label1 = oTab:NewUI(1, CLabel)
		oTab.m_Label2 = oTab:NewUI(2, CLabel)
		oTab.m_SelectSprite = oTab:NewUI(3, CSprite)
		oTab.m_RedDotSprite = oTab:NewUI(4, CSprite)
		oTab.m_Label1:SetText(v.tab_name)
		oTab.m_Label2:SetText(v.tab_name)
		oTab:SetActive(true)
		oTab.m_RedDotSprite:SetActive(false)
		if v.id == 10 then
			oTab.m_RedDotSprite:SetActive(g_PowerGuideCtrl:IsPowerHeroRedDot() or g_PowerGuideCtrl:IsPowerPartnerRedDot())
		end
		self.m_TabGrid:AddChild(oTab)
		oTab:SetGroup(self.m_TabGrid:GetInstanceID())
		oTab:SetSelected(self.m_TabIndex == i)
		oTab:AddUIEvent("click", callback(self, "OnClickTab", i))
	end
end

function CPowerGuideMainView.OnClickTab(self, idx)
	if self.m_TabIndex == idx then
		return
	end
	self.m_TabIndex = idx 
	self:RefreshTypeMenu()
end

function CPowerGuideMainView.OnClickSingleBtn(self, id)
	self:RefreshContent(id)
end

function CPowerGuideMainView.OpenTargetItem(self, tab, main, sub)
	if tab == 1 then
		local oBox = self.m_SingleMainMenuList[main]
		if oBox then
			oBox:SetSelected(true)
			self:OnClickSingleBtn(oBox.m_Id)
		end
	end
end

return CPowerGuideMainView