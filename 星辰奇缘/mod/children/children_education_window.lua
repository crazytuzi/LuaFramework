--作者:hzf
--01/09/2017 20:25:00
--功能:子女学习课程界面

ChildrenEducationWindowv = ChildrenEducationWindowv or BaseClass(BaseWindow)
function ChildrenEducationWindowv:__init(model)
	self.model = model
    self.windowId = WindowConfig.WinID.child_study_win
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.effectPath = "prefabs/effect/20106.unity3d"
	self.resList = {
		{file = AssetConfig.childreneducationwindow, type = AssetType.Main},
		{file = AssetConfig.childrentextures, type = AssetType.Dep},
		{file = AssetConfig.attr_icon, type = AssetType.Dep},
		{file = AssetConfig.ridebg, type = AssetType.Dep},
		{file = AssetConfig.pet_textures, type = AssetType.Dep},
		{file = self.effectPath, type = AssetType.Dep},
	}

	self.OnOpenEvent:Add(function() self:OnOpen() end)
	self.OnHideEvent:Add(function() self:OnHide() end)

	self.currindex = 0
	self.currsubindex = 0
	self.hasInit = false

	self.studyList = {}
	self.needSlot = {}
	self.subTab = {}
	self.item_id = 0

	self.previewsetting = {
        name = "ChildrenEducationWindowv"
        ,orthographicSize = 0.3
        ,width = 200
        ,height = 250
        ,offsetY = -0.14
    }

	-- 选职业前，根据职业类型和性别，定一个大概职业baseid
	self.defaultClasses = {
		[ChildrenEumn.ClassesType.Phy] = 1001,
		[ChildrenEumn.ClassesType.Mag] = 1005,
		[ChildrenEumn.ClassesType.Aid] = 1009,
	}

	self.listener = function() self:Update() end
	self.itemListener = function() self:UpdateCost() end

	self.loaders = {}
	self.imgLoader1 = nil
	self.imgLoader2 = nil
end

function ChildrenEducationWindowv:__delete()
	for k,v in pairs(self.loaders) do
		v:DeleteMe()
	end
	self.loaders = nil

	if self.imgLoader1 ~= nil then
		self.imgLoader1:DeleteMe()
		self.imgLoader1 = nil
	end

	if self.imgLoader2 ~= nil then
		self.imgLoader2:DeleteMe()
		self.imgLoader2 = nil
	end

	self:EndJumpButton()
	self:EndJumpButton1()
	self:EndTime()
	self:HideEffect()
	self.baseIcon.sprite = nil
	self.highIcon.sprite = nil
	self.classesImg.sprite = nil
	self:OnHide()
	if self.SubBuyBtn ~= nil then
		self.SubBuyBtn:DeleteMe()
		self.SubBuyBtn = nil
	end
	if self.previewComp ~= nil then
		self.previewComp:DeleteMe()
		self.previewComp = nil
	end

	for i,v in ipairs(self.studyList) do
		v:DeleteMe()
	end
	self.studyList = nil

	for i,v in ipairs(self.needSlot) do
		v:DeleteMe()
	end
	self.needSlot = nil

	for k,v in pairs(self.subTab) do
		v.icon.sprite = nil
	end
	self.subTab = nil

	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function ChildrenEducationWindowv:OnHide()
	self:EndTime()
	self:EndJumpButton()
	self:EndJumpButton1()
	ChildrenManager.Instance.OnChildStudyUpdate:Remove(self.listener)
	ChildrenManager.Instance.OnChildClassesUpdate:Remove(self.listener)
	ChildrenManager.Instance.OnChildDataUpdate:Remove(self.listener)
	EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemListener)
	if self.effect ~= nil then
		self.effect:SetActive(false)
	end
end

function ChildrenEducationWindowv:OnOpen()
	ChildrenManager.Instance.OnChildStudyUpdate:Add(self.listener)
	ChildrenManager.Instance.OnChildClassesUpdate:Add(self.listener)
	ChildrenManager.Instance.OnChildDataUpdate:Add(self.listener)
	EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemListener)
	self:Update()
end

function ChildrenEducationWindowv:Close()
	self.model:CloseEduWindow()
end

function ChildrenEducationWindowv:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childreneducationwindow))
	self.gameObject.name = "ChildrenEducationWindowv"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
	self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

	 local tab = self.transform:Find("Main/TabButtonGroup")
	for i = 1, 5 do
		local index = i
		local item = ChildrenStudyItem.New(tab:GetChild(i - 1).gameObject, self, index)
		table.insert(self.studyList, item)
	end

	self.preview = self.transform:Find("Main/PrewviewCon").gameObject
	self.preview:GetComponent(Button).onClick:AddListener(function() self:PlayIdleAction() end)
	self.transform:Find("Main/Name"):GetComponent(Button).onClick:AddListener(function() self:Rename() end)
	self.name = self.transform:Find("Main/Name/Text"):GetComponent(Text)

	self.transform:Find("Main/PrewviewCon/bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.ridebg, "RideBg")
	self.slider = self.transform:Find("Main/Slider"):GetComponent(Slider)
	self.growthText = self.transform:Find("Main/GrowthText"):GetComponent(Text)
	self.classButton = self.transform:Find("Main/ClassButton").gameObject
	self.classButton:GetComponent(Button).onClick:AddListener(function() self:ClickClasses() end)
	self.classesText = self.transform:Find("Main/ClassesText"):GetComponent(Text)
	self.classesImg = self.transform:Find("Main/ClassesText/Image"):GetComponent(Image)
	self.hasButton = self.transform:Find("Main/HasPlanButton").gameObject
	self.hasButton:GetComponent(Button).onClick:AddListener(function() self:OpenPlan() end)
	self.hasButton:SetActive(false)
	self.planButton = self.transform:Find("Main/PlanButton").gameObject
	self.planButton:GetComponent(Button).onClick:AddListener(function() self:OpenPlan() end)
	self.planButton:SetActive(false)
	self.transform:Find("Main/PlanButton/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon61")
	self.resetButton = self.transform:Find("Main/ResetButton").gameObject
	self.resetButton:GetComponent(Button).onClick:AddListener(function() self:ClickReset() end)
	self.resetButton:SetActive(true)

	self.baseTxt = self.transform:Find("Main/LearnCon/Basecourse/Text"):GetComponent(Text)
	self.highTxt = self.transform:Find("Main/LearnCon/Hightcourse/Text"):GetComponent(Text)

	self.transform:Find("Main/LearnCon/Basecourse"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon35")
	self.transform:Find("Main/LearnCon/Hightcourse"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon33")

	self.baseIcon = self.transform:Find("Main/SecondCon/CurrentNum"):GetComponent(Image)
	self.highIcon = self.transform:Find("Main/SecondCon/FullNum"):GetComponent(Image)

	self.currentNumText = self.transform:Find("Main/SecondCon/CurrentNum/Text"):GetComponent(Text)
	self.fullNumText = self.transform:Find("Main/SecondCon/FullNum/Text"):GetComponent(Text)
	self.infoButton = self.transform:Find("Main/SecondCon/InfoButton"):GetComponent(Button)
	-- self.transform:Find("Main/InfoButton").localPosition = Vector3(-148, -138, 0)
	-- self.transform:Find("Main/InfoButton").sizeDelta = Vector2(32, 32)
	self.detailTxt = self.transform:Find("Main/SecondCon/Detaile"):GetComponent(Text)
	self.fixText = self.transform:Find("Main/SecondCon/Text").gameObject

	self.titleTxt = self.transform:Find("Main/ThirdCon/Title/Text"):GetComponent(Text)
	self.desc1Text = self.transform:Find("Main/ThirdCon/Desc1Text"):GetComponent(Text)
	self.desc2Text = self.transform:Find("Main/ThirdCon/Desc2Text"):GetComponent(Text)

	self.desc3Obj = self.transform:Find("Main/ThirdCon/Desc3Text").gameObject
	self.freeTxtObj = self.transform:Find("Main/ThirdCon/FreeText").gameObject
	self.freeTxt = self.freeTxtObj:GetComponent(Text)
	self.freeTxtObj:SetActive(false)
	self.needObj = self.transform:Find("Main/ThirdCon/Need").gameObject

	local btn = self.transform:Find("Main/SecondCon/InfoButton"):GetComponent(Button)
	btn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = btn.gameObject, itemData = {
            TI18N("1.学习<color='#ffff00'>1节基础课</color>可增加<color='#ffff00'>3节高级课</color>学习上限"),
            TI18N("2.课程学习进度与成年资质相对应："),
            TI18N("    品德-物防、智慧-法力、体质-生命、"),
            TI18N("    敏捷-速度、力量-物攻"),
            TI18N("3.进度最高为<color='#ffff00'>100</color>，进度越高成年时资质越好"),
            }})
        end)

	self.SecondTabButtonGroup = self.transform:Find("Main/SecondTabButtonGroup")
	self.subtabgroup = TabGroup.New(self.SecondTabButtonGroup.gameObject, function (tab) self:OnSubTabChange(tab) end, {notAutoSelect = true, noCheckRepeat = true})

	self.TipsPanel = self.transform:Find("Main/TipsPanel")
	self.TipsPanel:GetComponent(Button).onClick:AddListener(function() self.TipsPanel.gameObject:SetActive(false) end)
	self.staticText = self.transform:Find("Main/TipsPanel/Conbg/staticText"):GetComponent(Text)
    self.minText = self.transform:Find("Main/TipsPanel/Conbg/minText"):GetComponent(Text)
    self.extgrowthText = self.transform:Find("Main/TipsPanel/Conbg/growthText"):GetComponent(Text)
    -- self.transform:Find("Main/TipsPanel/Conbg/otherText"):GetComponent(Text).text = "0~39          40~59         60~74          75~100"
    -- for i=1, 4 do
    -- 	local IMGitem = self.transform:Find("Main/TipsPanel/Conbg/otherText"):GetChild(i-1)
    -- 	IMGitem.anchorMax = Vector2(0, 0.5)
    -- 	IMGitem.anchorMin = Vector2(0, 0.5)
    -- 	local Hscaleval = ctx.ScreenHeight/540
    -- 	local Wscaleval = ctx.ScreenWidth/960
    -- 	local scaleval = Hscaleval/Wscaleval
    -- 	if i ~= 4 then
    -- 		IMGitem.anchoredPosition = Vector2(58.4*scaleval+(i-1)*82*scaleval, 0)
    -- 	else
    -- 		IMGitem.anchoredPosition = Vector2(58.4*scaleval+2*82*scaleval+92*scaleval, 0)
    -- 	end
    -- end
    self.TipsgrowthIcon = self.transform:Find("Main/TipsPanel/Conbg/growthText/Image"):GetComponent(Image)
    self.Growthicon = self.transform:Find("Main/LearnCon/Growth/icon"):GetComponent(Image)

    self.transform:Find("Main/SliderButton"):GetComponent(Button).onClick:AddListener(function() self.TipsPanel.gameObject:SetActive(true) end)
    self.transform:Find("Main/LearnCon"):GetComponent(Button).onClick:AddListener(function() self.TipsPanel.gameObject:SetActive(true) end)
    self.transform:Find("Main/InfoButton"):GetComponent(Button).onClick:AddListener(function() self.TipsPanel.gameObject:SetActive(true) end)

	self.subTab = {}
	for i = 1, 2 do
		local item = {}
		local t = self.transform:Find("Main/SecondTabButtonGroup"):GetChild(i - 1)
		item.Button = t:GetComponent(Button)
		item.NotifyPoint = t:Find("NotifyPoint").gameObject
		item.Name = t:Find("Name"):GetComponent(Text)
		item.icon = t:Find("icon"):GetComponent(Image)
		table.insert(self.subTab, item)
	end

	for i = 1, 2 do
	    local slot = ItemSlot.New()
	    UIUtils.AddUIChild(self.transform:Find("Main/ThirdCon/Need/" .. i).gameObject, slot.gameObject)
	    table.insert(self.needSlot, slot)
	end

	self.learnButton = self.transform:Find("Main/ThirdCon/Button"):GetComponent(Button)
	self.moneyNum = self.transform:Find("Main/ThirdCon/NeedText"):GetComponent(Text)
	self.itemName = self.transform:Find("Main/ThirdCon/NameText"):GetComponent(Text)
	self.learnButton.onClick:AddListener(function() self:ClickLearn() end)
	self.learnTxt = self.transform:Find("Main/ThirdCon/Button/Text"):GetComponent(Text)
	self.SubBuyBtn = BuyButton.New(self.learnButton.gameObject, TI18N("学习课程"))
	self.SubBuyBtn.protoId = 18623
	self.SubBuyBtn.key = "ChildEducate"

	self.Toggle = self.transform:Find("Main/ThirdCon/Toggle"):GetComponent(Toggle)
    self.Toggle.isOn = PlayerPrefs.GetInt("ChildLearnNotice") ~= -1
    self.Toggle.onValueChanged:AddListener(function(val)
        self:OnToggleChange(val)
    end)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.name = "Effect"
    self.effect.transform:SetParent(self.planButton.gameObject.transform)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 0, -400)
    self.effect:SetActive(false)

	self:OnOpen()
end

-- 打开职业选择界面
function ChildrenEducationWindowv:ClickClasses()
	self.model:OpenChooseClasses()
end

function ChildrenEducationWindowv:OnTabChange(index)
	if self.currindex ~= 0 then
		self.studyList[self.currindex]:Select(false)
	end
	self.currindex = index
	self.studyList[self.currindex]:Select(true)
	self:UpdateDetail()
	self:ReloadSubTab()
end

function ChildrenEducationWindowv:UpdateDetail()
	if self:HasPlan() then
		local val = ""
		if self.currindex == 1 then
			val = string.format("<color='#225ee7'>%s</color>(<color='#ffff9a'>%s</color>/%s) <color='#b031d5'>%s</color>(<color='#ffff9a'>%s</color>/%s)", TI18N("基础"), self.child.study_end_easy, self.child.study_end_plan_easy, TI18N("高级"), self.child.study_end_hard, self.child.study_end_plan_hard)
		elseif self.currindex == 2 then
			val = string.format("<color='#225ee7'>%s</color>(<color='#ffff9a'>%s</color>/%s) <color='#b031d5'>%s</color>(<color='#ffff9a'>%s</color>/%s)", TI18N("基础"), self.child.study_mag_easy, self.child.study_mag_plan_easy, TI18N("高级"), self.child.study_mag_hard, self.child.study_mag_plan_hard)
		elseif self.currindex == 3 then
			val = string.format("<color='#225ee7'>%s</color>(<color='#ffff9a'>%s</color>/%s) <color='#b031d5'>%s</color>(<color='#ffff9a'>%s</color>/%s)", TI18N("基础"), self.child.study_con_easy, self.child.study_con_plan_easy, TI18N("高级"), self.child.study_con_hard, self.child.study_con_plan_hard)
		elseif self.currindex == 4 then
			val = string.format("<color='#225ee7'>%s</color>(<color='#ffff9a'>%s</color>/%s) <color='#b031d5'>%s</color>(<color='#ffff9a'>%s</color>/%s)", TI18N("基础"), self.child.study_agi_easy, self.child.study_agi_plan_easy, TI18N("高级"), self.child.study_agi_hard, self.child.study_agi_plan_hard)
		elseif self.currindex == 5 then
			val = string.format("<color='#225ee7'>%s</color>(<color='#ffff9a'>%s</color>/%s) <color='#b031d5'>%s</color>(<color='#ffff9a'>%s</color>/%s)", TI18N("基础"), self.child.study_str_easy, self.child.study_str_plan_easy, TI18N("高级"), self.child.study_str_hard, self.child.study_str_plan_hard)
		end
		self.detailTxt.text =  val
		self.fixText:SetActive(true)
	else
		if self.child.is_init == 1 then
			self.detailTxt.text =  TI18N("请先制定学习计划")
			self.fixText:SetActive(false)
		else
			self.detailTxt.text =  ""
			self.fixText:SetActive(false)
		end
	end
end

-- 加载当前课程可选的难度
function ChildrenEducationWindowv:ReloadSubTab()
	-- 切换课程后，更新可选难度的相关信息
	self:UpdateMode()

	-- 切换课程后，默认选择简单难度
	if self.currsubindex == 0 then
		self.subtabgroup:ChangeTab(1)
	else
		self.subtabgroup:ChangeTab(self.currsubindex)
	end
end

function ChildrenEducationWindowv:OnSubTabChange(index)
	self.currsubindex = index
	self:ReloadThirdCon()

	if self.currsubindex == 1 and self.child.free_study == 0 then
		self:UpadteTime()
	else
		self:EndTime()
		self.learnTxt.text = TI18N("学习课程")
	end
end

-- 加载当前难度描述和所需道具
function ChildrenEducationWindowv:ReloadThirdCon()
	local key = string.format("%s_%s", ChildrenEumn.PosToIndex[self.currindex], self.currsubindex)
	self.studyData = DataChild.data_study[key]
	self:UpdateCost()
end

function ChildrenEducationWindowv:ClickLearn()
	if self.child ~= nil then
		if self.child.free_study == 0 and self.currsubindex == 1 and self.count > 0 then
			NoticeManager.Instance:FloatTipsByString(TI18N("刚学习完基础课程，需要休息一下{face_1,33}"))
			return
		end

		if self.child.classes == 0 then
			NoticeManager.Instance:FloatTipsByString(TI18N("先选择职业才能学习"))
			return
		end

		local finish = false
		local val = ""
		if self.child.is_init == 1 then
			if self.currindex == 1 then
				if self.currsubindex == 1 then
					if not self:HasPlan() and self.child.study_end_plan_easy == 0 then
						NoticeManager.Instance:FloatTipsByString(TI18N("请先制定子女<color='#ffff00'>学习计划</color>"))
						self:ShowEffect()
						return
					end
					val = string.format("(%s/%s)", self.child.study_end_easy, self.child.study_end_plan_easy)
					if self.child.study_end_easy >= self.child.study_end_plan_easy then
						finish = true
					end
				elseif self.currsubindex == 2 then
					if not self:HasPlan() and self.child.study_end_plan_hard == 0 then
						NoticeManager.Instance:FloatTipsByString(TI18N("请先制定子女<color='#ffff00'>学习计划</color>"))
						self:ShowEffect()
						return
					end
					val = string.format("(%s/%s)", self.child.study_end_hard, self.child.study_end_plan_hard)
					if self.child.study_end_hard >= self.child.study_end_plan_hard then
						finish = true
					end
				end
			elseif self.currindex == 2 then
				if self.currsubindex == 1 then
					if not self:HasPlan() and self.child.study_mag_plan_easy == 0 then
						NoticeManager.Instance:FloatTipsByString(TI18N("请先制定子女<color='#ffff00'>学习计划</color>"))
						self:ShowEffect()
						return
					end
					val = string.format("(%s/%s)", self.child.study_mag_easy, self.child.study_mag_plan_easy)
					if self.child.study_mag_easy >= self.child.study_mag_plan_easy then
						finish = true
					end
				elseif self.currsubindex == 2 then
					if not self:HasPlan() and self.child.study_mag_plan_hard == 0 then
						NoticeManager.Instance:FloatTipsByString(TI18N("请先制定子女<color='#ffff00'>学习计划</color>"))
						self:ShowEffect()
						return
					end
					val = string.format("(%s/%s)", self.child.study_mag_hard, self.child.study_mag_plan_hard)
					if self.child.study_mag_hard >= self.child.study_mag_plan_hard then
						finish = true
					end
				end
			elseif self.currindex == 3 then
				if self.currsubindex == 1 then
					if not self:HasPlan() and self.child.study_con_plan_easy == 0 then
						NoticeManager.Instance:FloatTipsByString(TI18N("请先制定子女<color='#ffff00'>学习计划</color>"))
						self:ShowEffect()
						return
					end
					val = string.format("(%s/%s)", self.child.study_con_easy, self.child.study_con_plan_easy)
					if self.child.study_con_easy >= self.child.study_con_plan_easy then
						finish = true
					end
				elseif self.currsubindex == 2 then
					if not self:HasPlan() and self.child.study_con_plan_hard == 0 then
						NoticeManager.Instance:FloatTipsByString(TI18N("请先制定子女<color='#ffff00'>学习计划</color>"))
						self:ShowEffect()
						return
					end
					val = string.format("(%s/%s)", self.child.study_con_hard, self.child.study_con_plan_hard)
					if self.child.study_con_hard >= self.child.study_con_plan_hard then
						finish = true
					end
				end
			elseif self.currindex == 4 then
				if self.currsubindex == 1 then
					if not self:HasPlan() and self.child.study_agi_plan_easy == 0 then
						NoticeManager.Instance:FloatTipsByString(TI18N("请先制定子女<color='#ffff00'>学习计划</color>"))
						self:ShowEffect()
						return
					end
					val = string.format("(%s/%s)", self.child.study_agi_easy, self.child.study_agi_plan_easy)
					if self.child.study_agi_easy >= self.child.study_agi_plan_easy then
						finish = true
					end
				elseif self.currsubindex == 2 then
					if not self:HasPlan() and self.child.study_agi_plan_hard == 0 then
						NoticeManager.Instance:FloatTipsByString(TI18N("请先制定子女<color='#ffff00'>学习计划</color>"))
						self:ShowEffect()
						return
					end
					val = string.format("(%s/%s)", self.child.study_agi_hard, self.child.study_agi_plan_hard)
					if self.child.study_agi_hard >= self.child.study_agi_plan_hard then
						finish = true
					end
				end
			elseif self.currindex == 5 then
				if self.currsubindex == 1 then
					if not self:HasPlan() and self.child.study_str_plan_easy == 0 then
						NoticeManager.Instance:FloatTipsByString(TI18N("请先制定子女<color='#ffff00'>学习计划</color>"))
						self:ShowEffect()
						return
					end
					val = string.format("(%s/%s)", self.child.study_str_easy, self.child.study_str_plan_easy)
					if self.child.study_str_easy >= self.child.study_str_plan_easy then
						finish = true
					end
				elseif self.currsubindex == 2 then
					if not self:HasPlan() and self.child.study_str_plan_hard == 0 then
						NoticeManager.Instance:FloatTipsByString(TI18N("请先制定子女<color='#ffff00'>学习计划</color>"))
						self:ShowEffect()
						return
					end
					val = string.format("(%s/%s)", self.child.study_str_hard, self.child.study_str_plan_hard)
					if self.child.study_str_hard >= self.child.study_str_plan_hard then
						finish = true
					end
				end
			end

			if finish then
				local str = string.format("%s-%s课程<color='#ffff00'>%s</color>", ChildrenEumn.StudyName[ChildrenEumn.PosToIndex[self.currindex]], ChildrenEumn.StudyLevelName[self.currsubindex], val)

	            local data = NoticeConfirmData.New()
	            data.type = ConfirmData.Style.Normal
	            data.content = string.format(TI18N("子女已完成学习计划：%s，请按计划学习其它课程，或前往修改计划"), str)
	            data.sureLabel = TI18N("修改计划")
	            data.cancelLabel = TI18N("取消")
	            data.sureCallback = function() self:OpenPlan() end
	            NoticeManager.Instance:ConfirmTips(data)
	            return
			end
		end

		local func = function()
			ChildrenManager.Instance:Require18623(self.child.child_id, self.child.platform, self.child.zone_id, ChildrenEumn.PosToIndex[self.currindex], self.currsubindex)
		end

		if self.currsubindex == 1 and self.child.study_easy >= 25 then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("最佳学习状态为<color='#ffff00'>25节基础课程+75节高级课程</color>，超过25节基础课程，将不利于孩子属性成长")
            data.sureLabel = TI18N("仍然学习")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = func
            NoticeManager.Instance:ConfirmTips(data)
        else
        	if self.currsubindex == 2 then
	        	local has = BackpackManager.Instance:GetItemCount(self.item_id)
	        	-- if has == 0 then
	        	-- 	self.needSlot[1]:SureClick()
	        	-- end
        	end
        	func()
		end
	end
end

function ChildrenEducationWindowv:Update()
	self.child = ChildrenManager.Instance:GetChildhood()
	if self.child == nil then
		return
	end

	self.name.text = self.child.name
	self.base_id = self.child.base_id
	if self.base_id == 0 then
		self.base_id = self.defaultClasses[self.child.classes_type]
	end

	self.hasButton:SetActive(false)
	self.planButton:SetActive(false)
	-- self.resetButton:SetActive(false)
	if self.child.classes == 0 then
		self.classButton:SetActive(true)
		self.classesText.gameObject:SetActive(false)
		self:JumpButton()
	else
		self:EndJumpButton()
		self.classButton:SetActive(false)
		self.classesText.gameObject:SetActive(true)
		self.classesText.text = string.format(TI18N("职业:%s"), KvData.classes_name[self.child.classes])
		self.classesImg.sprite = PreloadManager.Instance:GetClassesSprite(self.child.classes)
		if self.child.is_init == 1 then
			-- self.resetButton:SetActive(true)
			if self:HasPlan() then
				self:EndJumpButton1()
				self.hasButton:SetActive(true)
			else
				self:JumpButton1()
				self.planButton:SetActive(true)
			end
		end
	end

	if self.currindex == 0 then
		self:OnTabChange(1)
	else
		self:OnTabChange(self.currindex)
	end

	self:UpdateInfo()
	self:UpdateSkill()
	self:ShowPreview()
	self:UpdateGrowth()
end

function ChildrenEducationWindowv:JumpButton()
	self:EndJumpButton()
	self.tweenId = Tween.Instance:Scale(self.classButton, Vector3.one * 1.2, 0.8, nil, LeanTweenType.easeOutElastic):setLoopPingPong().id
end

function ChildrenEducationWindowv:EndJumpButton()
	if self.tweenId ~= nil then
		Tween.Instance:Cancel(self.tweenId)
		self.tweenId = nil
	end
	self.classButton.transform.localScale = Vector3.one
end

function ChildrenEducationWindowv:JumpButton1()
	self:EndJumpButton1()
	self.tweenId1 = Tween.Instance:Scale(self.planButton, Vector3.one * 1.2, 0.8, nil, LeanTweenType.easeOutElastic):setLoopPingPong().id
end

function ChildrenEducationWindowv:EndJumpButton1()
	if self.tweenId1 ~= nil then
		Tween.Instance:Cancel(self.tweenId1)
		self.tweenId1 = nil
	end
	self.planButton.transform.localScale = Vector3.one
end

function ChildrenEducationWindowv:UpadteTime()
	self:EndTime()
	self.count = math.max(0, self.studyData.study_time - (BaseUtils.BASE_TIME - self.child.study_easy_time))
	self.timerId = LuaTimer.Add(0, 1000, function() self:LoopTime() end)
end

function ChildrenEducationWindowv:LoopTime()
	self.count = self.count - 1
	if self.count <= 0 then
		self:EndTime()
		self.learnTxt.text = TI18N("学习课程")
		self.count = 0
	else
		local date, hour, minute, second = BaseUtils.time_gap_to_timer(self.count)
		local hourStr = hour
		local minuteStr = minute
		local secondStr = second
		if hour < 10 then
			hourStr = "0" .. hour
		end
		if minute < 10 then
			minuteStr = "0" .. minute
		end
		if second < 10 then
			secondStr = "0" .. second
		end
		if hour > 0 then
			self.learnTxt.text = string.format("%s:%s", hourStr, minuteStr)
		else
			self.learnTxt.text = string.format("%s:%s", minuteStr, secondStr)
		end
	end
end

function ChildrenEducationWindowv:EndTime()
	if self.timerId ~= nil then
		LuaTimer.Delete(self.timerId)
		self.timerId = nil
	end
end

function ChildrenEducationWindowv:UpdateInfo()
	self.baseTxt.text = string.format(TI18N("已学习基础课程:%s"), self.child.study_easy)
	if self.child.study_hard < self.child.study_easy * 3 then
		self.highTxt.text = string.format(TI18N("已学习高级课程:<color='#248813'>%s</color>/%s"), self.child.study_hard, self.child.study_easy * 3)
	else
		self.highTxt.text = string.format(TI18N("已学习高级课程:<color='#df3435'>%s</color>/%s"), self.child.study_hard, self.child.study_easy * 3)
	end

	self.growthText.text = string.format(TI18N("养成度:%s/100"), self.child.maturity)
	self.slider.value = self.child.maturity / 100
end

function ChildrenEducationWindowv:UpdateSkill()
	for i,v in ipairs(self.studyList) do
		v:SetData(self.child)
	end
end

-- 更新当前课程难度相关信息
function ChildrenEducationWindowv:UpdateMode()
	local val = 0
	local attr = 0
	local childBase = DataChild.data_child[self.base_id]
	local ci = ChildrenEumn.PosToIndex[self.currindex]
	local assets = ""
	if ci == 1 then
		val = self.child.study_str
		attr = childBase.phy_aptitude
		assets = "AttrIcon4"
	elseif ci == 2 then
		val = self.child.study_con
		attr = childBase.hp_aptitude
		assets = "AttrIcon1"
	elseif ci == 3 then
		val = self.child.study_agi
		attr = childBase.aspd_aptitude
		assets = "AttrIcon3"
	elseif ci == 4 then
		val = self.child.study_mag
		attr = childBase.magic_aptitude
		assets = "AttrIcon5"
	elseif ci == 5 then
		val = self.child.study_end
		attr = childBase.pdef_aptitude
		assets = "AttrIcon6"
	end
	self.currentNumText.text = string.format(TI18N("当前%s:<color='#ffff9a'>%s/100</color>"), ChildrenEumn.StudyName[ci], val)
	self.baseIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, assets)
	self.highIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, assets)

	local min,max = ChildrenManager.Instance:GetAptRatio(val, attr)
	if val == 0 then
		self.fullNumText.text = TI18N("暂未学习")
	else
		self.fullNumText.text = string.format(TI18N("成年%s资质:<color='#ffff9a'>%s~%s</color>"), ChildrenEumn.StudyTypeName[ci], min, max)
	end

	local study_client = DataChild.data_study_client[ci]
	local itemData = DataItem.data_get[study_client.easy_id]
	self.subTab[1].Name.text = itemData.name
    if self.imgLoader1 == nil then
        local go = self.subTab[1].icon.gameObject
        self.imgLoader1 = SingleIconLoader.New(go)
    end
    self.imgLoader1:SetSprite(SingleIconType.Item, itemData.icon)

	itemData = DataItem.data_get[study_client.hard_id]
	self.subTab[2].Name.text = itemData.name
    if self.imgLoader2 == nil then
        local go = self.subTab[2].icon.gameObject
        self.imgLoader2 = SingleIconLoader.New(go)
    end
    self.imgLoader2:SetSprite(SingleIconType.Item, itemData.icon)
end

-- 更新当前课程当前难度消耗相关信息
function ChildrenEducationWindowv:UpdateCost()
	local losss = self.studyData.study_loss
	for i,slot in ipairs(self.needSlot) do
		local loss = losss[i]
		if loss ~= nil then
			local id = loss[1]
			local num = loss[2]
			local has = BackpackManager.Instance:GetItemCount(id)
			local base = BaseUtils.copytab(DataItem.data_get[id])
			slot:SetAll(base)
			if id < 90000 then
				slot:SetNum(has, num)
			else
				slot:SetNum(num)
				local color = "#ff6666"
				if BaseUtils.GetRoleAssetVal(id) >= num then
					color = "#00ff00"
				else
					color = "#ff6666"
				end
				slot.numTxt.text = string.format("<color='%s'>%s</color>", color, slot:FormatNum(num))

				if self.currsubindex == 2 then
					self.item_id = id
				end
			end
			slot.gameObject:SetActive(true)
			if self.currsubindex == 2 then
				local setting = {}
				setting[id] = {need = num}
				self.itemName.text = ColorHelper.color_item_name(DataItem.data_get[id].quality , DataItem.data_get[id].name)
				self.SubBuyBtn:Layout(setting, function() self:ClickLearn() end, function(data) self:SetNeedText(data) end, {freezetime = 0})
				self.SubBuyBtn:Show()
			else
				self.SubBuyBtn:Hiden()
				self.moneyNum.gameObject:SetActive(false)
				self.itemName.gameObject:SetActive(false)
			end
		else
			slot:SetAll(nil)
			slot.gameObject:SetActive(false)
		end
	end

	self.freeTxtObj:SetActive(false)
	self.desc3Obj:SetActive(true)
	self.needObj:SetActive(true)
	if self.currsubindex == 1 then
		self.titleTxt.text = string.format("基础课程:%s", self.studyData.name)
		if self.child.free_study > 0 then
			self.freeTxtObj:SetActive(true)
			self.freeTxt.text = string.format(TI18N("重置免费次数:%s"), self.child.free_study)
			self.desc3Obj:SetActive(false)
			self.needObj:SetActive(false)
		end
	else
		self.titleTxt.text = string.format("高级课程:%s", self.studyData.name)
	end
	if self.currsubindex == 1 then
		self.Toggle.gameObject:SetActive(true)
		self.learnButton.gameObject.transform.anchoredPosition3D = Vector3(153.4, -29.12, 0)
	else
		self.Toggle.gameObject:SetActive(false)
		self.learnButton.gameObject.transform.anchoredPosition3D = Vector3(153.4, -58.2, 0)
	end

	self.desc1Text.text = self.studyData.desc
	self.desc2Text.text = string.format(TI18N("子女%s<color='%s'>+%s</color>"), ChildrenEumn.StudyName[ChildrenEumn.PosToIndex[self.currindex]], ColorHelper.color[1], self.studyData.val)
end

function ChildrenEducationWindowv:ShowPreview()
    local callback = function(composite)
	    self:SetRawImage(composite)
	end

	local npcData = nil
	local modelData = nil
	if self.child.sex == 0 then
		npcData = DataUnit.data_unit[71160]
	else
		npcData = DataUnit.data_unit[71159]
	end
	modelData = {type = PreViewType.Npc, skinId = npcData.skin, modelId = npcData.res, animationId = npcData.animation_id, scale = 1}

	if self.previewComp == nil then
    	self.previewComp = PreviewComposite.New(callback, self.previewsetting, modelData)
    else
    	self.previewComp:Reload(modelData, callback)
	end
	self.previewComp:Show()
end

function ChildrenEducationWindowv:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
    composite.tpose.transform:Rotate(Vector3(0, -30, 0))
    self:PlayIdleAction()
end


function ChildrenEducationWindowv:UpdateGrowth()

    local temp = {}
    table.insert(temp, {self.child.study_str, TI18N("力")})
    table.insert(temp, {self.child.study_con, TI18N("体")})
    table.insert(temp, {self.child.study_agi, TI18N("敏")})
    table.insert(temp, {self.child.study_mag, TI18N("智")})
    table.insert(temp, {self.child.study_end, TI18N("德")})
    local minimum = 0
    local minstr = ""
    for i=1, 5 do
    	local curr = temp[i][1]
    	local minnum = 0
    	for j=1,5 do
    		if temp[j][1] >= curr then
    			minnum = minnum + 1
    		else
    			break
    		end
    	end
    	if minnum == 5 then
    		minimum = curr
    		minstr = temp[i][2]
    		break
    	end
    end
    -- BaseUtils.dump(temp, "排序结果")
  	self.minText.text = string.format(TI18N("最低学习进度：%s <color='#ffff00'>%s</color>/100"), minstr, tostring(minimum))
  	local sprite = nil
  	if minimum <= 39 then
  		sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth2")
  	elseif minimum <= 59 then
  		sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth3")
  	elseif minimum <= 74 then
  		sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth4")
  	else
  		sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth5")
  	end
    self.TipsgrowthIcon.sprite = sprite
    self.Growthicon.sprite = sprite
end

function ChildrenEducationWindowv:Rename()
    ChildrenManager.Instance.model:OpenRename(self.child)
end

function ChildrenEducationWindowv:PlayAction()
    if self.timeId_PlayAction == nil and self.previewComp ~= nil and self.previewComp.tpose ~= nil and self.child ~= nil then
        local model_data = DataChild.data_child[self.child.base_id]
        local animationData = DataAnimation.data_npc_data[model_data.animation_id]
        local action_list = {"1000", "2000", "Idle1" }
        local action_name = action_list[math.random(1, 3)]
        self.previewComp:PlayAnimation(action_name)

        local motion_event = DataMotionEvent.data_motion_event[string.format("%s_%s", action_name, model_data.model_id)]
        if motion_event ~= nil then
            if action_name == "1000" then
                self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function()
                        self.timeId_PlayAction = nil
                        if not BaseUtils.isnull(self.previewComp.tpose) then
                            self.previewComp:PlayMotion(FighterAction.Stand)
                        end
                    end)
            elseif action_name == "2000" then
                self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function()
                        self.timeId_PlayAction = nil
                        if not BaseUtils.isnull(self.previewComp.tpose) then
                            self.previewComp:PlayMotion(FighterAction.Stand)
                        end
                    end)
            else
                self.timeId_PlayAction = LuaTimer.Add(motion_event.total, function() self.timeId_PlayAction = nil end)
            end
        end
    end
end

function ChildrenEducationWindowv:PlayIdleAction()
    if self.timeId_PlayAction == nil and self.previewComp ~= nil and self.previewComp.tpose ~= nil and self.child ~= nil then
        self.previewComp:PlayMotion(FighterAction.Idle)
    end
end
function ChildrenEducationWindowv:SetNeedText(data)
	for k,v in pairs(data) do
		local numText = self.moneyNum

        local go = self.moneyNum.transform:Find("Currency").gameObject
        local id = go:GetInstanceID()
        local loader = self.loaders[id]
        if loader == nil then
	        loader = SingleIconLoader.New(go)
	        self.loaders[id] = loader
        end
        loader:SetSprite(SingleIconType.Item, v.assets)

        self.moneyNum.gameObject:SetActive(true)
        self.itemName.gameObject:SetActive(true)
        if v.allprice < 0 then
            numText.text = "<color=#FF0000>"..tostring(0 - v.allprice).."</color>"
        else
            numText.text = "<color=#FFFF00>"..tostring(v.allprice).."</color>"
        end
	end
	if next(data) == nil then
		self.moneyNum.gameObject:SetActive(false)
		self.itemName.gameObject:SetActive(false)
	end
end

function ChildrenEducationWindowv:OpenPlan()
	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.childplan)
end

function ChildrenEducationWindowv:ClickReset()
	ChildrenManager.Instance:Require18636(self.child.child_id, self.child.platform, self.child.zone_id)
end

function ChildrenEducationWindowv:HasPlan()
	if self.child == nil then
		return false
	end

	if self.child.study_end_plan_easy == 0
		and self.child.study_con_plan_easy == 0
		and self.child.study_mag_plan_easy == 0
		and self.child.study_agi_plan_easy == 0
		and self.child.study_str_plan_easy == 0
		and self.child.study_end_plan_hard == 0
		and self.child.study_con_plan_hard == 0
		and self.child.study_mag_plan_hard == 0
		and self.child.study_agi_plan_hard == 0
		and self.child.study_str_plan_hard == 0
	then
		return false
	end
	return true
end

function ChildrenEducationWindowv:ShowEffect()
	self:HideEffect()
	if self.effect ~= nil then
		self.effect:SetActive(false)
		self.effect:SetActive(true)
	end
	self.timerIdEffect = LuaTimer.Add(2000, function() self:HideEffect() end)
end

function ChildrenEducationWindowv:HideEffect()
	if self.effect ~= nil then
		self.effect:SetActive(false)
	end
	if self.timerIdEffect ~= nil then
		LuaTimer.Delete(self.timerIdEffect)
		self.timerIdEffect = nil
	end
end


function ChildrenEducationWindowv:OnToggleChange(isOn)
    if isOn then
        PlayerPrefs.SetInt("ChildLearnNotice", 1)
        NoticeManager.Instance:FloatTipsByString(TI18N("已开启<color='#ffff00'>[提升-子女课程学习]</color>提醒"))
    else
        PlayerPrefs.SetInt("ChildLearnNotice", -1)
        NoticeManager.Instance:FloatTipsByString(TI18N("已关闭<color='#ffff00'>[提升-子女课程学习]</color>提醒"))
    end
    ImproveManager.Instance:OnStatusChange(true)
end