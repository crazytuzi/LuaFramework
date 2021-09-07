-- --------------------------
-- 孩子学习计划
-- hosr
-- --------------------------
ChildrenStudyPlanPanel = ChildrenStudyPlanPanel or BaseClass(BaseWindow)

function ChildrenStudyPlanPanel:__init(model)
	self.model = model
    self.windowId = WindowConfig.WinID.childplan

	self.resList = {
		{file = AssetConfig.childstudyplan, type = AssetType.Main},
		{file = AssetConfig.childrentextures, type = AssetType.Dep},
		{file = AssetConfig.pet_textures, type = AssetType.Dep},
	}

	self.OnOpenEvent:Add(function() self:OnOpen() end)
	self.OnHideEvent:Add(function() self:OnHide() end)

	self.growCycleList = {}
	self.sliderList = {}
	self.sliderValList = {}
	self.sliderNameList = {}
	self.countEasyList = {}
	self.countHardList = {}
	self.growObjList = {}
	self.growIconList = {}

	self.lastMinVal = 0

	self.all_end = 0 -- 德
	self.all_mag = 0 -- 智
	self.all_con = 0 -- 体
	self.all_agi = 0 -- 敏
	self.all_str = 0 -- 力

	-- 当前的基础值
	self.study_str_easy = 0
	self.study_con_easy = 0
	self.study_agi_easy = 0
	self.study_mag_easy = 0
	self.study_end_easy = 0

	-- 当前的高级值
	self.study_str_hard = 0
	self.study_con_hard = 0
	self.study_agi_hard = 0
	self.study_mag_hard = 0
	self.study_end_hard = 0

	self.study_str_plan_easy = 0
	self.study_con_plan_easy = 0
	self.study_agi_plan_easy = 0
	self.study_mag_plan_easy = 0
	self.study_end_plan_easy = 0

	self.study_str_plan_hard = 0
	self.study_con_plan_hard = 0
	self.study_agi_plan_hard = 0
	self.study_mag_plan_hard = 0
	self.study_end_plan_hard = 0

	-- 手动加的基础值
	self.add_easy_end = 0
	self.add_easy_mag = 0
	self.add_easy_con = 0
	self.add_easy_agi = 0
	self.add_easy_str = 0

	-- 手动加的高级值
	self.add_hard_end = 0
	self.add_hard_mag = 0
	self.add_hard_con = 0
	self.add_hard_agi = 0
	self.add_hard_str = 0
	self.listener = function() self:Update() end
end

function ChildrenStudyPlanPanel:__delete()
    ChildrenManager.Instance.OnChildStudyUpdate:Remove(self.listener)
    self:EndJump()
    self:EndLoop()

    if self.autoImg ~= nil then
    	self.autoImg.sprite = nil
    	self.autoImg = nil
    end

    if self.sureImg ~= nil then
    	self.sureImg.sprite = nil
    	self.sureImg = nil
    end

	for i,v in ipairs(self.growIconList) do
		v.sprite = nil
	end
	self.growIconList = nil
	self.growCycleList = nil
	self.sliderList = nil
	self.sliderValList = nil
	self.sliderNameList = nil
	self.countEasyList = nil
	self.countHardList = nil
	self.growObjList = nil
end

function ChildrenStudyPlanPanel:OnShow()
	self:Update()
end

function ChildrenStudyPlanPanel:OnHide()
end

function ChildrenStudyPlanPanel:Close()
	self.model:CloseStudyPlan()
end

function ChildrenStudyPlanPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childstudyplan))
	self.gameObject.name = "ChildrenStudyPlanPanel"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

	self.tipsPanel = self.transform:Find("TipsPanel").gameObject
	self.tipsDesc = self.transform:Find("TipsPanel/Conbg/desc"):GetComponent(Text)
	self.tipsPanel:SetActive(false)
	self.tipsPanel:GetComponent(Button).onClick:AddListener(function() self.tipsPanel:SetActive(false) end)

	local top = self.transform:Find("Main/Top")
	for i = 1, 4 do
		local cycle = top:Find(string.format("Gorw%s/Cycle", i)).gameObject
		cycle:SetActive(false)
		table.insert(self.growCycleList, cycle)
	end

	self.tips25 = top:Find("Tips25").gameObject
	self.tips25:SetActive(false)
	self.tips75 = top:Find("Tips75").gameObject
	self.tips75:SetActive(false)

	self.currEasyNum = top:Find("Base/Text"):GetComponent(Text)
	self.currHardNum = top:Find("Grade/Text"):GetComponent(Text)

	self.desc = self.transform:Find("Main/Desc"):GetComponent(Text)
	self.transform:Find("Main/RuleBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickRule() end)
	self.transform:Find("Main/TipsBtn1"):GetComponent(Button).onClick:AddListener(function() self:ClickRule() end)
	self.transform:Find("Main/TipsBtn2"):GetComponent(Button).onClick:AddListener(function() self:ClickRule() end)
	self.transform:Find("Main/SaveButton"):GetComponent(Button).onClick:AddListener(function() self:ClickPlan() end)
	self.transform:Find("Main/AutoButton"):GetComponent(Button).onClick:AddListener(function() self:ClickAuto() end)
	self.cancelButton = self.transform:Find("Main/CancelButton").gameObject
	self.cancelButton:GetComponent(Button).onClick:AddListener(function() self:Cancel() end)
	self.autoImg = self.transform:Find("Main/AutoButton"):GetComponent(Image)
	self.autoTxt = self.transform:Find("Main/AutoButton/Text"):GetComponent(Text)
	self.sureImg = self.transform:Find("Main/SaveButton"):GetComponent(Image)
	self.sureTxt = self.transform:Find("Main/SaveButton/Text"):GetComponent(Text)

	local mid = self.transform:Find("Main/Mid")
	for i = 1, 5 do
		local index = i
		local item = mid:Find(string.format("Item%s", i))
		item:Find("Base/LeftBtn"):GetComponent(CustomButton).onClick:AddListener(function() self:EasyLeft(index) end)
		item:Find("Base/RightBtn"):GetComponent(CustomButton).onClick:AddListener(function() self:EasyRight(index) end)
		item:Find("Best/LeftBtn"):GetComponent(CustomButton).onClick:AddListener(function() self:HardLeft(index) end)
		item:Find("Best/RightBtn"):GetComponent(CustomButton).onClick:AddListener(function() self:HardRight(index) end)
		item:Find("Base/LeftBtn"):GetComponent(CustomButton).onHold:AddListener(function() self:EasyLeftHold(index) end)
		item:Find("Base/RightBtn"):GetComponent(CustomButton).onHold:AddListener(function() self:EasyRightHold(index) end)
		item:Find("Best/LeftBtn"):GetComponent(CustomButton).onHold:AddListener(function() self:HardLeftHold(index) end)
		item:Find("Best/RightBtn"):GetComponent(CustomButton).onHold:AddListener(function() self:HardRightHold(index) end)
		item:Find("Base/LeftBtn"):GetComponent(CustomButton).onUp:AddListener(function() self:EasyUp(index) end)
		item:Find("Base/RightBtn"):GetComponent(CustomButton).onUp:AddListener(function() self:EasyUp(index) end)
		item:Find("Best/LeftBtn"):GetComponent(CustomButton).onUp:AddListener(function() self:HardUp(index) end)
		item:Find("Best/RightBtn"):GetComponent(CustomButton).onUp:AddListener(function() self:HardUp(index) end)

		local slider = item:Find("Slider"):GetComponent(Slider)
		-- slider.wholeNumbers = true
		-- slider.maxValue = 100

		table.insert(self.sliderNameList, item:Find("Slider/Name"):GetComponent(Text))
		table.insert(self.sliderValList, item:Find("Slider/Val"):GetComponent(Text))
		table.insert(self.sliderList, slider)
		table.insert(self.countEasyList, item:Find("Base/Val"):GetComponent(Text))
		table.insert(self.countHardList, item:Find("Best/Val"):GetComponent(Text))
		-- item:Find("Base/Val"):GetComponent(Button).onClick:AddListener(function() self:ClickBaseVal(index) end)
		-- item:Find("Best/Val"):GetComponent(Button).onClick:AddListener(function() self:ClickHardVal(index) end)

		local g = item:Find("Gorw")
		g.gameObject:SetActive(false)
		table.insert(self.growObjList, g.gameObject)
		table.insert(self.growIconList, g:Find("Icon"):GetComponent(Image))
	end

    self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = nil,
        min_result = 1,
        max_by_asset = 50,
        max_result = 50,
        textObject = nil,
        returnKeep = true,
        funcReturn = nil,
        callback = nil,
        show_num = true,
        -- returnText = TI18N("购买"),
    }

    self:OnShow()
    ChildrenManager.Instance.OnChildStudyUpdate:Add(self.listener)
end

function ChildrenStudyPlanPanel:ClickRule()
	self.tipsDesc.text = string.format(TI18N("3.当前子女职业为<color='#ffff00'>%s</color>，建议按照<color='#ffff00'>[推荐计划]</color>培养"), KvData.classes_name[self.child.classes])
	self.tipsPanel:SetActive(true)
end

function ChildrenStudyPlanPanel:CheckAutoPlanOverFlow(plan)
	local base = plan.base_plan
	local hard = plan.hard_plan

	local add_easy_end = base[1] - self.study_end_easy
	local add_easy_mag = base[2] - self.study_mag_easy
	local add_easy_con = base[3] - self.study_con_easy
	local add_easy_agi = base[4] - self.study_agi_easy
	local add_easy_str = base[5] - self.study_str_easy

	local add_hard_end = hard[1] - self.study_end_hard
	local add_hard_mag = hard[2] - self.study_mag_hard
	local add_hard_con = hard[3] - self.study_con_hard
	local add_hard_agi = hard[4] - self.study_agi_hard
	local add_hard_str = hard[5] - self.study_str_hard

	if add_easy_end < 0 or add_easy_mag < 0 or add_easy_con < 0 or add_easy_agi < 0 or add_easy_str < 0
		or add_hard_end < 0 or add_hard_mag < 0 or add_hard_con < 0 or add_hard_agi < 0 or add_hard_str < 0 then
		return true
	end
	return false
end

function ChildrenStudyPlanPanel:Reset()
	ChildrenManager.Instance:Require18636(self.child.child_id, self.child.platform, self.child.zone_id)
	self:Close()
end

-- 推荐
function ChildrenStudyPlanPanel:ClickAuto()
	if self.child == nil then
		return
	end
	local data = DataChild.data_study_plan[self.child.classes]

	if self:CheckAutoPlanOverFlow(data) then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("已学课程偏离推荐计划，可继续按照设定计划培养，或者<color='#ffff00'>重置课程</color>后重新学习")
        data.cancelLabel = TI18N("重置课程")
        data.sureLabel = TI18N("取消")
        data.cancelCallback = function() LuaTimer.Add(200, function() self:Reset() end) end
        NoticeManager.Instance:ConfirmTips(data)
		return
	end

	local base = data.base_plan
	local hard = data.hard_plan

	self.add_easy_end = base[1] - self.study_end_plan_easy
	self.add_easy_mag = base[2] - self.study_mag_plan_easy
	self.add_easy_con = base[3] - self.study_con_plan_easy
	self.add_easy_agi = base[4] - self.study_agi_plan_easy
	self.add_easy_str = base[5] - self.study_str_plan_easy

	self.add_hard_end = hard[1] - self.study_end_plan_hard
	self.add_hard_mag = hard[2] - self.study_mag_plan_hard
	self.add_hard_con = hard[3] - self.study_con_plan_hard
	self.add_hard_agi = hard[4] - self.study_agi_plan_hard
	self.add_hard_str = hard[5] - self.study_str_plan_hard

	self:UpdateVal(false, true)
end

function ChildrenStudyPlanPanel:ClickPlan()
	if self:CalculateEasyAll() < 25 then
		NoticeManager.Instance:FloatTipsByString(TI18N("基础课程不足25，无法保存"))
		return
	end

	if self:CalculateHardAll() > 75 then
		NoticeManager.Instance:FloatTipsByString(TI18N("最多学习<color='#ffff00'>75</color>节高级课程"))
		return
	end

	if self:CalculateEasyAll() + self:CalculateHardAll() ~= 100 then
		NoticeManager.Instance:FloatTipsByString(TI18N("学习课程数不足100，无法保存"))
		return
	end

	local info = {}
	info.study_str_plan_easy = self.study_str_plan_easy + self.add_easy_str
	info.study_con_plan_easy = self.study_con_plan_easy + self.add_easy_con
	info.study_agi_plan_easy = self.study_agi_plan_easy + self.add_easy_agi
	info.study_mag_plan_easy = self.study_mag_plan_easy + self.add_easy_mag
	info.study_end_plan_easy = self.study_end_plan_easy + self.add_easy_end
	info.study_str_plan_hard = self.study_str_plan_hard + self.add_hard_str
	info.study_con_plan_hard = self.study_con_plan_hard + self.add_hard_con
	info.study_agi_plan_hard = self.study_agi_plan_hard + self.add_hard_agi
	info.study_mag_plan_hard = self.study_mag_plan_hard + self.add_hard_mag
	info.study_end_plan_hard = self.study_end_plan_hard + self.add_hard_end


	-- 防止老号在点推荐计划时，推荐的比已学的低
	if info.study_end_plan_easy < self.study_end_easy then
		NoticeManager.Instance:FloatTipsByString(TI18N("已学<color='#ffff00'>基础品德</color>课程超出计划，不能保存，请修改计划"))
		return
	end
	if info.study_mag_plan_easy < self.study_mag_easy then
		NoticeManager.Instance:FloatTipsByString(TI18N("已学<color='#ffff00'>基础智慧</color>课程超出计划，不能保存，请修改计划"))
		return
	end
	if info.study_con_plan_easy < self.study_con_easy then
		NoticeManager.Instance:FloatTipsByString(TI18N("已学<color='#ffff00'>基础体质</color>课程超出计划，不能保存，请修改计划"))
		return
	end
	if info.study_agi_plan_easy < self.study_agi_easy then
		NoticeManager.Instance:FloatTipsByString(TI18N("已学<color='#ffff00'>基础敏捷</color>课程超出计划，不能保存，请修改计划"))
		return
	end
	if info.study_str_plan_easy < self.study_str_easy then
		NoticeManager.Instance:FloatTipsByString(TI18N("已学<color='#ffff00'>基础力量</color>课程超出计划，不能保存，请修改计划"))
		return
	end

	if info.study_end_plan_hard < self.study_end_hard then
		NoticeManager.Instance:FloatTipsByString(TI18N("已学<color='#ffff00'>高级品德</color>课程超出计划，不能保存，请修改计划"))
		return
	end
	if info.study_mag_plan_hard < self.study_mag_hard then
		NoticeManager.Instance:FloatTipsByString(TI18N("已学<color='#ffff00'>高级智慧</color>课程超出计划，不能保存，请修改计划"))
		return
	end
	if info.study_con_plan_hard < self.study_con_hard then
		NoticeManager.Instance:FloatTipsByString(TI18N("已学<color='#ffff00'>高级体质</color>课程超出计划，不能保存，请修改计划"))
		return
	end
	if info.study_agi_plan_hard < self.study_agi_hard then
		NoticeManager.Instance:FloatTipsByString(TI18N("已学<color='#ffff00'>高级敏捷</color>课程超出计划，不能保存，请修改计划"))
		return
	end
	if info.study_str_plan_hard < self.study_str_hard then
		NoticeManager.Instance:FloatTipsByString(TI18N("已学<color='#ffff00'>高级力量</color>课程超出计划，不能保存，请修改计划"))
		return
	end
	-- -------------------------------


	local func = function()
		ChildrenManager.Instance:Require18635(self.child.child_id, self.child.platform, self.child.zone_id, info)
	end

	if self.sliderList[self:GetMinIndex()].value < 0.75 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("按照当前学习计划培养，子女成年时将<color='#ffff00'>不能达到红色成长</color>，是否继续保存？\n（建议查看<color='#ffff00'>推荐计划</color>）")
        data.sureLabel = TI18N("仍然保存")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() func() end
        NoticeManager.Instance:ConfirmTips(data)
	else
		func()
	end
end

function ChildrenStudyPlanPanel:EndLoop()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function ChildrenStudyPlanPanel:EasyLeftHold(index)
	self:EndLoop()
	self.timeId = LuaTimer.Add(0, 200, function() self:EasyLeft(index) end)
end

function ChildrenStudyPlanPanel:EasyRightHold(index)
	self:EndLoop()
	self.timeId = LuaTimer.Add(0, 200, function() self:EasyRight(index) end)
end

function ChildrenStudyPlanPanel:EasyUp(index)
	self:EndLoop()
end

function ChildrenStudyPlanPanel:EasyLeft(index)
	if index == 1 then
		if self.study_end_plan_easy + self.add_easy_end - 1 < 0 then
			NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			return
		end
		if self.study_end_plan_easy + self.add_easy_end - 1 < self.study_end_easy then
			if self.study_end_easy == 0 then
				NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			else
				NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已学习<color='#ffff00'>%s节基础品德课程</color>，计划不能再少了"), self.study_end_easy))
			end
			return
		end
		self.add_easy_end = self.add_easy_end - 1
	elseif index == 2 then
		if self.study_mag_plan_easy + self.add_easy_mag - 1 < 0 then
			NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			return
		end
		if self.study_mag_plan_easy + self.add_easy_mag - 1 < self.study_mag_easy then
			if self.study_mag_easy == 0 then
				NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			else
				NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已学习<color='#ffff00'>%s节基础智慧课程</color>，计划不能再少了"), self.study_mag_easy))
			end
			return
		end
		self.add_easy_mag = self.add_easy_mag - 1
	elseif index == 3 then
		if self.study_con_plan_easy + self.add_easy_con - 1 < 0 then
			NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			return
		end
		if self.study_con_plan_easy + self.add_easy_con - 1 < self.study_con_easy then
			if self.study_con_easy == 0 then
				NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			else
				NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已学习<color='#ffff00'>%s节基础体质课程</color>，计划不能再少了"), self.study_con_easy))
			end
			return
		end
		self.add_easy_con = self.add_easy_con - 1
	elseif index == 4 then
		if self.study_agi_plan_easy + self.add_easy_agi - 1 < 0 then
			NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			return
		end
		if self.study_agi_plan_easy + self.add_easy_agi - 1 < self.study_agi_easy then
			if self.study_agi_easy == 0 then
				NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			else
				NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已学习<color='#ffff00'>%s节基础敏捷课程</color>，计划不能再少了"), self.study_agi_easy))
			end
			return
		end
		self.add_easy_agi = self.add_easy_agi - 1
	elseif index == 5 then
		if self.study_str_plan_easy + self.add_easy_str - 1 < 0 then
			NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			return
		end
		if self.study_str_plan_easy + self.add_easy_str - 1 < self.study_str_easy then
			if self.study_str_easy == 0 then
				NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			else
				NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已学习<color='#ffff00'>%s节基础力量课程</color>，计划不能再少了"), self.study_str_easy))
			end
			return
		end
		self.add_easy_str = self.add_easy_str - 1
	end

	self:UpdateVal()
end

function ChildrenStudyPlanPanel:EasyRight(index)
	if self:CalculateEasyAll() + self:CalculateHardAll() + 1 > 100 then
		NoticeManager.Instance:FloatTipsByString(TI18N("不能学习更多了"))
		return
	end
	if index == 1 then
		if self.all_end + 2 > 100 then
			return
		end
		self.add_easy_end = self.add_easy_end + 1
	elseif index == 2 then
		if self.all_mag + 2 > 100 then
			return
		end
		self.add_easy_mag = self.add_easy_mag + 1
	elseif index == 3 then
		if self.all_con + 2 > 100 then
			return
		end
		self.add_easy_con = self.add_easy_con + 1
	elseif index == 4 then
		if self.all_agi + 2 > 100 then
			return
		end
		self.add_easy_agi = self.add_easy_agi + 1
	elseif index == 5 then
		if self.all_str + 2 > 100 then
			return
		end
		self.add_easy_str = self.add_easy_str + 1
	end

	self:UpdateVal()
end

function ChildrenStudyPlanPanel:HardLeftHold(index)
	self:EndLoop()
	self.timeId = LuaTimer.Add(0, 200, function() self:HardLeft(index) end)
end

function ChildrenStudyPlanPanel:HardRightHold(index)
	self:EndLoop()
	self.timeId = LuaTimer.Add(0, 200, function() self:HardRight(index) end)
end

function ChildrenStudyPlanPanel:HardUp(index)
	self:EndLoop()
end

function ChildrenStudyPlanPanel:HardLeft(index)
	if index == 1 then
		if self.study_end_plan_hard + self.add_hard_end - 1 < 0 then
			NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			return
		end
		if self.study_end_plan_hard + self.add_hard_end - 1 < self.study_end_hard then
			if self.study_end_hard == 0 then
				NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			else
				NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已学习<color='#ffff00'>%s节高级品德课程</color>，计划不能再少了"), self.study_end_hard))
			end
			return
		end
		self.add_hard_end = self.add_hard_end - 1
	elseif index == 2 then
		if self.study_mag_plan_hard + self.add_hard_mag - 1 < 0 then
			NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			return
		end
		if self.study_mag_plan_hard + self.add_hard_mag - 1 < self.study_mag_hard then
			if self.study_mag_hard == 0 then
				NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			else
				NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已学习<color='#ffff00'>%s节高级智慧课程</color>，计划不能再少了"), self.study_mag_hard))
			end
			return
		end
		self.add_hard_mag = self.add_hard_mag - 1
	elseif index == 3 then
		if self.study_con_plan_hard + self.add_hard_con - 1 < 0 then
			NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			return
		end
		if self.study_con_plan_hard + self.add_hard_con - 1 < self.study_con_hard then
			if self.study_con_hard == 0 then
				NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			else
				NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已学习<color='#ffff00'>%s节高级体质课程</color>，计划不能再少了"), self.study_con_hard))
			end
			return
		end
		self.add_hard_con = self.add_hard_con - 1
	elseif index == 4 then
		if self.study_agi_plan_hard + self.add_hard_agi - 1 < 0 then
			NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			return
		end
		if self.study_agi_plan_hard + self.add_hard_agi - 1 < self.study_agi_hard then
			if self.study_agi_hard == 0 then
				NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			else
				NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已学习<color='#ffff00'>%s节高级敏捷课程</color>，计划不能再少了"), self.study_agi_hard))
			end
			return
		end
		self.add_hard_agi = self.add_hard_agi - 1
	elseif index == 5 then
		if self.study_str_plan_hard + self.add_hard_str - 1 < 0 then
			NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			return
		end
		if self.study_str_plan_hard + self.add_hard_str - 1 < self.study_str_hard then
			if self.study_str_hard == 0 then
				NoticeManager.Instance:FloatTipsByString(TI18N("已达到最小值"))
			else
				NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已学习<color='#ffff00'>%s节高级力量课程</color>，计划不能再少了"), self.study_str_hard))
			end
			return
		end
		self.add_hard_str = self.add_hard_str - 1
	end

	self:UpdateVal()
end

function ChildrenStudyPlanPanel:HardRight(index)
	-- if self:CalculateHardAll() + 1 > self:CalculateEasyAll() * 3 then
	-- 	NoticeManager.Instance:FloatTipsByString(TI18N("高级课程学习次数不足，请先学习基础课程"))
	-- 	return
	-- end

	if self:CalculateHardAll() + 1 > 75 then
		NoticeManager.Instance:FloatTipsByString(TI18N("不能学习更多了"))
		return
	end

	if self:CalculateEasyAll() + self:CalculateHardAll() + 1 > 100 then
		NoticeManager.Instance:FloatTipsByString(TI18N("不能学习更多了"))
		return
	end
	if index == 1 then
		if self.all_end + 5 > 100 then
			return
		end
		self.add_hard_end = self.add_hard_end + 1
	elseif index == 2 then
		if self.all_mag + 5 > 100 then
			return
		end
		self.add_hard_mag = self.add_hard_mag + 1
	elseif index == 3 then
		if self.all_con + 5 > 100 then
			return
		end
		self.add_hard_con = self.add_hard_con + 1
	elseif index == 4 then
		if self.all_agi + 5 > 100 then
			return
		end
		self.add_hard_agi = self.add_hard_agi + 1
	elseif index == 5 then
		if self.all_str + 5 > 100 then
			return
		end
		self.add_hard_str = self.add_hard_str + 1
	end

	self:UpdateVal()
end

function ChildrenStudyPlanPanel:UpdateVal(isInit, auto)
    self:CalculateAll()

	self.sliderList[1].value = self.all_end / 100
	self.sliderList[2].value = self.all_mag / 100
	self.sliderList[3].value = self.all_con / 100
	self.sliderList[4].value = self.all_agi / 100
	self.sliderList[5].value = self.all_str / 100

	self.sliderValList[1].text = string.format("%s/100", self.all_end)
	self.sliderValList[2].text = string.format("%s/100", self.all_mag)
	self.sliderValList[3].text = string.format("%s/100", self.all_con)
	self.sliderValList[4].text = string.format("%s/100", self.all_agi)
	self.sliderValList[5].text = string.format("%s/100", self.all_str)

	self.countEasyList[1].text = tostring(self.study_end_plan_easy + self.add_easy_end)
	self.countEasyList[2].text = tostring(self.study_mag_plan_easy + self.add_easy_mag)
	self.countEasyList[3].text = tostring(self.study_con_plan_easy + self.add_easy_con)
	self.countEasyList[4].text = tostring(self.study_agi_plan_easy + self.add_easy_agi)
	self.countEasyList[5].text = tostring(self.study_str_plan_easy + self.add_easy_str)

	self.countHardList[1].text = tostring(self.study_end_plan_hard + self.add_hard_end)
	self.countHardList[2].text = tostring(self.study_mag_plan_hard + self.add_hard_mag)
	self.countHardList[3].text = tostring(self.study_con_plan_hard + self.add_hard_con)
	self.countHardList[4].text = tostring(self.study_agi_plan_hard + self.add_hard_agi)
	self.countHardList[5].text = tostring(self.study_str_plan_hard + self.add_hard_str)

	-- if self.add_easy_end == 0 then
	-- 	self.countEasyList[1].text = tostring(self.study_end_plan_easy + self.add_easy_end)
	-- else
	-- 	self.countEasyList[1].text = string.format("%s %s%s", self.study_end_plan_easy, (self.add_easy_end > 0 and "+" or ""), self.add_easy_end)
	-- end

	-- if self.add_easy_mag == 0 then
	-- 	self.countEasyList[2].text = tostring(self.study_mag_plan_easy + self.add_easy_mag)
	-- else
	-- 	self.countEasyList[2].text = string.format("%s %s%s", self.study_mag_plan_easy, (self.add_easy_mag > 0 and "+" or ""), self.add_easy_mag)
	-- end

	-- if self.add_easy_con == 0 then
	-- 	self.countEasyList[3].text = tostring(self.study_con_plan_easy + self.add_easy_con)
	-- else
	-- 	self.countEasyList[3].text = string.format("%s %s%s", self.study_con_plan_easy, (self.add_easy_con > 0 and "+" or ""), self.add_easy_con)
	-- end

	-- if self.add_easy_agi == 0 then
	-- 	self.countEasyList[4].text = tostring(self.study_agi_plan_easy + self.add_easy_agi)
	-- else
	-- 	self.countEasyList[4].text = string.format("%s %s%s", self.study_agi_plan_easy, (self.add_easy_agi > 0 and "+" or ""), self.add_easy_agi)
	-- end

	-- if self.add_easy_str == 0 then
	-- 	self.countEasyList[5].text = tostring(self.study_str_plan_easy + self.add_easy_str)
	-- else
	-- 	self.countEasyList[5].text = string.format("%s %s%s", self.study_str_plan_easy, (self.add_easy_str > 0 and "+" or ""), self.add_easy_str)
	-- end

	-- if self.add_hard_end == 0 then
	-- 	self.countHardList[1].text = tostring(self.study_end_plan_hard + self.add_hard_end)
	-- else
	-- 	self.countHardList[1].text = string.format("%s %s%s", self.study_end_plan_hard, (self.add_hard_end > 0 and "+" or ""), self.add_hard_end)
	-- end

	-- if self.add_hard_mag == 0 then
	-- 	self.countHardList[2].text = tostring(self.study_mag_plan_hard + self.add_hard_mag)
	-- else
	-- 	self.countHardList[2].text = string.format("%s %s%s", self.study_mag_plan_hard, (self.add_hard_mag > 0 and "+" or ""), self.add_hard_mag)
	-- end

	-- if self.add_hard_con == 0 then
	-- 	self.countHardList[3].text = tostring(self.study_con_plan_hard + self.add_hard_con)
	-- else
	-- 	self.countHardList[3].text = string.format("%s %s%s", self.study_con_plan_hard, (self.add_hard_con > 0 and "+" or ""), self.add_hard_con)
	-- end

	-- if self.add_hard_agi == 0 then
	-- 	self.countHardList[4].text = tostring(self.study_agi_plan_hard + self.add_hard_agi)
	-- else
	-- 	self.countHardList[4].text = string.format("%s %s%s", self.study_agi_plan_hard, (self.add_hard_agi > 0 and "+" or ""), self.add_hard_agi)
	-- end

	-- if self.add_hard_str == 0 then
	-- 	self.countHardList[5].text = tostring(self.study_str_plan_hard + self.add_hard_str)
	-- else
	-- 	self.countHardList[5].text = string.format("%s %s%s", self.study_str_plan_hard, (self.add_hard_str > 0 and "+" or ""), self.add_hard_str)
	-- end

	local study_end = self.study_end_plan_easy * 2 + self.study_end_plan_hard * 5 + self.add_easy_end * 2 + self.add_hard_end * 5
	local study_mag = self.study_mag_plan_easy * 2 + self.study_mag_plan_hard * 5 + self.add_easy_mag * 2 + self.add_hard_mag * 5
	local study_con = self.study_con_plan_easy * 2 + self.study_con_plan_hard * 5 + self.add_easy_con * 2 + self.add_hard_con * 5
	local study_agi = self.study_agi_plan_easy * 2 + self.study_agi_plan_hard * 5 + self.add_easy_agi * 2 + self.add_hard_agi * 5
	local study_str = self.study_str_plan_easy * 2 + self.study_str_plan_hard * 5 + self.add_easy_str * 2 + self.add_hard_str * 5

	local childBase = DataChild.data_child[self.child.base_id]
	local min,max = ChildrenManager.Instance:GetAptRatio(study_end, childBase.pdef_aptitude)
	self.sliderNameList[1].text = string.format(TI18N("物防资质 %s~%s"), min, max)
	min,max = ChildrenManager.Instance:GetAptRatio(study_mag, childBase.magic_aptitude)
	self.sliderNameList[2].text = string.format(TI18N("法力资质 %s~%s"), min, max)
	min,max = ChildrenManager.Instance:GetAptRatio(study_con, childBase.hp_aptitude)
	self.sliderNameList[3].text = string.format(TI18N("生命资质 %s~%s"), min, max)
	min,max = ChildrenManager.Instance:GetAptRatio(study_agi, childBase.aspd_aptitude)
	self.sliderNameList[4].text = string.format(TI18N("速度资质 %s~%s"), min, max)
	min,max = ChildrenManager.Instance:GetAptRatio(study_str, childBase.phy_aptitude)
	self.sliderNameList[5].text = string.format(TI18N("物攻资质 %s~%s"), min, max)

	self.desc.text = string.format(TI18N("计划成长度:<color='#ffff00'>%s</color>/100"), self:CalculateEasyAll() + self:CalculateHardAll())

	self.currEasyNum.text = string.format(TI18N("基础课程:%s"), self:CalculateEasyAll())
	self.currHardNum.text = string.format(TI18N("高级课程:%s"), self:CalculateHardAll())

	for i,v in ipairs(self.growCycleList) do
		v:SetActive(false)
	end
	for i,v in ipairs(self.growObjList) do
		v:SetActive(false)
	end
	local minVal = math.min(study_end, study_str, study_con, study_agi, study_mag)
	local index = self:GetMinIndex()
	if minVal >= 75 then
		self.growIconList[index].sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth5")
		self.growCycleList[4]:SetActive(true)
		if self.lastMinVal < 75 then
			self.lastMinVal = minVal
			self:Jump(self.growCycleList[4])
		end
	elseif minVal >= 60 then
		self.growIconList[index].sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth4")
		self.growObjList[index]:SetActive(true)
		self.growCycleList[3]:SetActive(true)
		if self.lastMinVal < 60 then
			self.lastMinVal = minVal
			self:Jump(self.growCycleList[3])
		end
	elseif minVal >= 40 then
		self.growIconList[index].sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth3")
		self.growObjList[index]:SetActive(true)
		self.growCycleList[2]:SetActive(true)
		if self.lastMinVal < 40 then
			self.lastMinVal = minVal
			self:Jump(self.growCycleList[2])
		end
	else
		self.growIconList[index].sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth2")
		self.growObjList[index]:SetActive(true)
		self.growCycleList[1]:SetActive(true)
	end

	if self:CalculateEasyAll() > 25 then
		self.tips25:SetActive(true)
	else
		self.tips25:SetActive(false)
	end

	if not isInit and not auto and self:CalculateHardAll() >= 75 then
		self.tips75:SetActive(true)
	else
		self.tips75:SetActive(false)
	end

	self.cancelButton:SetActive(self:IsChange())

	local all = self:CalculateEasyAll() + self:CalculateHardAll()
	if not self:HasPlan() and all < 100 then
		self.autoImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
		self.autoTxt.color = ColorHelper.DefaultButton2
	else
		self.autoImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
		self.autoTxt.color = ColorHelper.DefaultButton3
	end

	if not isInit and all == 100 and self:IsChange() then
		self.sureImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
		self.sureTxt.color = ColorHelper.DefaultButton2
	else
		self.sureImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
		self.sureTxt.color = ColorHelper.DefaultButton3
	end
end

function ChildrenStudyPlanPanel:GetMinIndex()
	local val = 0
	local index = 0
	for i,v in ipairs(self.sliderList) do
		if v.value * 100 == 0 then
			index = i
			return index
		end

		if val == 0 then
			val = v.value * 100
			index = i
		end

		if v.value * 100 < val then
			val = v.value * 100
			index = i
		end
	end

	return index
end

function ChildrenStudyPlanPanel:Update()
	self.child = ChildrenManager.Instance:GetChildhood()

	self.add_easy_end = 0
	self.add_easy_str = 0
	self.add_easy_agi = 0
	self.add_easy_con = 0
	self.add_easy_mag = 0
	self.add_hard_end = 0
	self.add_hard_mag = 0
	self.add_hard_con = 0
	self.add_hard_agi = 0
	self.add_hard_str = 0

    self.study_str_easy = self.child.study_str_easy
    self.study_con_easy = self.child.study_con_easy
    self.study_agi_easy = self.child.study_agi_easy
    self.study_mag_easy = self.child.study_mag_easy
    self.study_end_easy = self.child.study_end_easy

    self.study_str_hard = self.child.study_str_hard
    self.study_con_hard = self.child.study_con_hard
    self.study_agi_hard = self.child.study_agi_hard
    self.study_mag_hard = self.child.study_mag_hard
    self.study_end_hard = self.child.study_end_hard

    self.study_str_plan_easy = self.child.study_str_plan_easy
    self.study_con_plan_easy = self.child.study_con_plan_easy
    self.study_agi_plan_easy = self.child.study_agi_plan_easy
    self.study_mag_plan_easy = self.child.study_mag_plan_easy
    self.study_end_plan_easy = self.child.study_end_plan_easy

    if self.study_str_plan_easy == 0 then
    	self.study_str_plan_easy = self.study_str_easy
    end
    if self.study_con_plan_easy == 0 then
    	self.study_con_plan_easy = self.study_con_easy
    end
    if self.study_agi_plan_easy == 0 then
    	self.study_agi_plan_easy = self.study_agi_easy
    end
    if self.study_mag_plan_easy == 0 then
    	self.study_mag_plan_easy = self.study_mag_easy
    end
    if self.study_end_plan_easy == 0 then
    	self.study_end_plan_easy = self.study_end_easy
    end

    self.study_str_plan_hard = self.child.study_str_plan_hard
    self.study_con_plan_hard = self.child.study_con_plan_hard
    self.study_agi_plan_hard = self.child.study_agi_plan_hard
    self.study_mag_plan_hard = self.child.study_mag_plan_hard
    self.study_end_plan_hard = self.child.study_end_plan_hard

    if self.study_str_plan_hard == 0 then
    	self.study_str_plan_hard = self.study_str_hard
    end
    if self.study_con_plan_hard == 0 then
    	self.study_con_plan_hard = self.study_con_hard
    end
    if self.study_agi_plan_hard == 0 then
    	self.study_agi_plan_hard = self.study_agi_hard
    end
    if self.study_mag_plan_hard == 0 then
    	self.study_mag_plan_hard = self.study_mag_hard
    end
    if self.study_end_plan_hard == 0 then
    	self.study_end_plan_hard = self.study_end_hard
    end

    self:UpdateVal(true)
end

function ChildrenStudyPlanPanel:CalculateAll()
    self.all_str = self.study_str_plan_hard * 5 + self.study_str_plan_easy * 2 + self.add_hard_str * 5 + self.add_easy_str * 2
    self.all_agi = self.study_agi_plan_hard * 5 + self.study_agi_plan_easy * 2 + self.add_hard_agi * 5 + self.add_easy_agi * 2
    self.all_end = self.study_end_plan_hard * 5 + self.study_end_plan_easy * 2 + self.add_hard_end * 5 + self.add_easy_end * 2
    self.all_con = self.study_con_plan_hard * 5 + self.study_con_plan_easy * 2 + self.add_hard_con * 5 + self.add_easy_con * 2
    self.all_mag = self.study_mag_plan_hard * 5 + self.study_mag_plan_easy * 2 + self.add_hard_mag * 5 + self.add_easy_mag * 2
end

function ChildrenStudyPlanPanel:CalculateEasyAll()
	local all = self.study_end_plan_easy + self.study_mag_plan_easy + self.study_con_plan_easy + self.study_agi_plan_easy + self.study_str_plan_easy
	+ self.add_easy_end + self.add_easy_mag + self.add_easy_con + self.add_easy_agi + self.add_easy_str
	return all
end

function ChildrenStudyPlanPanel:CalculateHardAll()
	local all = self.study_end_plan_hard + self.study_mag_plan_hard + self.study_con_plan_hard + self.study_agi_plan_hard + self.study_str_plan_hard
	+ self.add_hard_end + self.add_hard_mag + self.add_hard_con + self.add_hard_agi + self.add_hard_str
	return all
end

function ChildrenStudyPlanPanel:IsChange()
	if self.add_easy_mag == 0 and self.add_easy_str == 0 and self.add_easy_con == 0 and self.add_easy_agi == 0 and self.add_easy_end == 0
	and self.add_hard_str == 0 and self.add_hard_agi == 0 and self.add_hard_con == 0 and self.add_hard_mag == 0 and self.add_hard_end == 0 then
		return false
	end
	return true
end

function ChildrenStudyPlanPanel:Cancel()
	self.add_easy_end = 0
	self.add_easy_str = 0
	self.add_easy_agi = 0
	self.add_easy_con = 0
	self.add_easy_mag = 0
	self.add_hard_end = 0
	self.add_hard_mag = 0
	self.add_hard_con = 0
	self.add_hard_agi = 0
	self.add_hard_str = 0
	self:UpdateVal(true)
end

function ChildrenStudyPlanPanel:ClickBaseVal(index)
    self.numberpadSetting.gameObject = self.countEasyList[index].gameObject
    self.numberpadSetting.funcReturn = function(num) self:NumberPadCallback(1, index, num) end
	NumberpadManager.Instance:set_data(self.numberpadSetting)
end

function ChildrenStudyPlanPanel:ClickHardVal(index)
    self.numberpadSetting.gameObject = self.countHardList[index].gameObject
    self.numberpadSetting.funcReturn = function(num) self:NumberPadCallback(2, index, num) end
	NumberpadManager.Instance:set_data(self.numberpadSetting)
end

function ChildrenStudyPlanPanel:NumberPadCallback(type, index, num)

	if type == 1 then
		if index == 1 then
			local val = num - self.study_end_plan_easy
			if self:CalculateEasyAll() + self:CalculateHardAll() + val > 100 then
				NoticeManager.Instance:FloatTipsByString(TI18N("学习课程数不能超过100节"))
				return
			end
			self.add_easy_end = val
		elseif index == 2 then
			local val = num - self.study_mag_plan_easy
			if self:CalculateEasyAll() + self:CalculateHardAll() + val > 100 then
				NoticeManager.Instance:FloatTipsByString(TI18N("学习课程数不能超过100节"))
				return
			end
			self.add_easy_mag = val
		elseif index == 3 then
			local val = num - self.study_con_plan_easy
			if self:CalculateEasyAll() + self:CalculateHardAll() + val > 100 then
				NoticeManager.Instance:FloatTipsByString(TI18N("学习课程数不能超过100节"))
				return
			end
			self.add_easy_con = val
		elseif index == 4 then
			local val = num - self.study_agi_plan_easy
			if self:CalculateEasyAll() + self:CalculateHardAll() + val > 100 then
				NoticeManager.Instance:FloatTipsByString(TI18N("学习课程数不能超过100节"))
				return
			end
			self.add_easy_agi = val
		elseif index == 5 then
			local val = num - self.study_str_plan_easy
			if self:CalculateEasyAll() + self:CalculateHardAll() + val > 100 then
				NoticeManager.Instance:FloatTipsByString(TI18N("学习课程数不能超过100节"))
				return
			end
			self.add_easy_str = val
		end
	elseif type == 2 then
		if index == 1 then
			self.add_hard_end = num - self.study_end_plan_hard
		elseif index == 2 then
			self.add_hard_mag = num - self.study_mag_plan_hard
		elseif index == 3 then
			self.add_hard_con = num - self.study_con_plan_hard
		elseif index == 4 then
			self.add_hard_agi = num - self.study_agi_plan_hard
		elseif index == 5 then
			self.add_hard_str = num - self.study_str_plan_hard
		end
	end
	self:UpdateVal()
	NumberpadManager.Instance:Close()
end

function ChildrenStudyPlanPanel:Jump(obj)
	self:EndJump()
	obj.transform.localScale = Vector3.one * 1.4
	self.tweenId = Tween.Instance:Scale(obj, Vector3.one, 0.8, function() self:EndJump() end, LeanTweenType.easeOutElastic).id
end

function ChildrenStudyPlanPanel:EndJump()
	if self.tweenId ~= nil then
		Tween.Instance:Cancel(self.tweenId)
		self.tweenId = nil
	end
end

function ChildrenStudyPlanPanel:HasPlan()
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
