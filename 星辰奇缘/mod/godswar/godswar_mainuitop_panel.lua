-- ---------------------------------
-- 诸神之战 主界面顶部展示
-- hosr
-- ---------------------------------

GodsWarMainUiTopPanel = GodsWarMainUiTopPanel or BaseClass(BasePanel)

function GodsWarMainUiTopPanel:__init(model)
	self.model = model
	self.effect1 = nil
	self.effect2 = nil
	self.effectPath = "prefabs/effect/20054.unity3d"
	self.resList = {
		{file = AssetConfig.godswarmainuitop, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
		{file = self.effectPath, type = AssetType.Main},
	}
	self.listener = function() self:Update() end
	self.timeListener = function() self:UpdateTime() end
	self.resultListener = function(result) self:UpdateResult(result) end
	self.timeVal = 0
end

function GodsWarMainUiTopPanel:__delete()
	self:EndTime()
	MainUIManager.Instance.MainUIIconView:Set_ShowTop(true,{})
	MainUIManager.Instance.MainUIIconView:showbaseicon5()
	EventMgr.Instance:RemoveListener(event_name.godswar_ready_update, self.listener)
	EventMgr.Instance:RemoveListener(event_name.godswar_team_update, self.listener)
	EventMgr.Instance:RemoveListener(event_name.godswar_fighter_update, self.listener)
	EventMgr.Instance:RemoveListener(event_name.godswar_time_update, self.timeListener)
	EventMgr.Instance:RemoveListener(event_name.godswar_fightresult_update, self.resultListener)
end

function GodsWarMainUiTopPanel:OnShow()

	MainUIManager.Instance.MainUIIconView:hidebaseicon5()
    MainUIManager.Instance.MainUIIconView:Set_ShowTop(false,{17})

	self:Update()
end

function GodsWarMainUiTopPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarmainuitop))
    self.gameObject.name = "GodsWarMainUiTopPanel"
    UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView.gameObject, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main"):GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)

    self.bgRect = self.transform:Find("Main/Bg"):GetComponent(RectTransform)
    self.bgRect.sizeDelta = Vector2(440, 80)

    self.name1 = self.transform:Find("Main/Name1"):GetComponent(Text)
    self.state1 = self.transform:Find("Main/State1"):GetComponent(Text)

    -- self.name1Rect = self.name1.gameObject:GetComponent(RectTransform)
    -- self.name1Rect.anchorMax = Vector2(0.5, 1)
    -- self.name1Rect.anchorMin = Vector2(0.5, 1)
    -- self.name1Rect.sizeDelta = Vector2(130, 47)
    -- self.name1Rect.anchoredPosition = Vector3(-86, -27, 0)
    -- self.state1Rect = self.state1.gameObject:GetComponent(RectTransform)
    -- self.state1Rect.anchoredPosition = Vector3(-86, -12, 0)

    self.name2 = self.transform:Find("Main/Name2"):GetComponent(Text)
    self.state2 = self.transform:Find("Main/State2"):GetComponent(Text)

    -- self.name2Rect = self.name2.gameObject:GetComponent(RectTransform)
    -- self.name2Rect.anchorMax = Vector2(0.5, 1)
    -- self.name2Rect.anchorMin = Vector2(0.5, 1)
    -- self.name2Rect.sizeDelta = Vector2(130, 47)
    -- self.name2Rect.anchoredPosition = Vector3(81, -27, 0)
    -- self.state2Rect = self.state2.gameObject:GetComponent(RectTransform)
    -- self.state2Rect.anchoredPosition = Vector3(81, -12, 0)

    self.state1.text = TI18N("未准备")
    self.state2.text = TI18N("未准备")

    self.time = self.transform:Find("Main/Time/Val"):GetComponent(Text)
    self.time.text = string.format(TI18N("%s,开启倒计时:<color='#00ff00'>%s</color>"), GodsWarEumn.ShowStr(), "00:00")

    -- self.timeRect = self.transform:Find("Main/Time"):GetComponent(RectTransform)
    -- self.timeRect.sizeDelta = Vector2(265, 30)
    -- self.timeRect.anchoredPosition = Vector3(0, -50, 0)
    -- self.imgRect = self.transform:Find("Main/Time/Image"):GetComponent(RectTransform)
    -- self.imgRect.anchoredPosition = Vector3(-128, 0, 0)

    self.effect1 = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect1.transform:SetParent(self.transform:Find("Main"))
    self.effect1.transform.localScale = Vector3(2, 1.6, 1)
    self.effect1.transform.localPosition = Vector3(-133, -65, -400)
    Utils.ChangeLayersRecursively(self.effect1.transform, "UI")
    self.effect1:SetActive(false)

    self.effect2 = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect2.transform:SetParent(self.transform:Find("Main"))
    self.effect2.transform.localScale = Vector3(2, 1.6, 1)
    self.effect2.transform.localPosition = Vector3(20, -65, -400)
    Utils.ChangeLayersRecursively(self.effect2.transform, "UI")
    self.effect2:SetActive(false)

    self:OnShow()
	EventMgr.Instance:AddListener(event_name.godswar_ready_update, self.listener)
	EventMgr.Instance:AddListener(event_name.godswar_team_update, self.listener)
	EventMgr.Instance:AddListener(event_name.godswar_fighter_update, self.listener)
	EventMgr.Instance:AddListener(event_name.godswar_time_update, self.timeListener)
	EventMgr.Instance:AddListener(event_name.godswar_fightresult_update, self.resultListener)
end

function GodsWarMainUiTopPanel:Update()
	self.myData = GodsWarManager.Instance.myData
	if self.myData == nil or self.myData.tid == 0 then
		self.name1.text = TI18N("暂无")
	else
		self.name1.text = string.format("%s\n<color='#31f2f9'>%s</color>", self.myData.name, BaseUtils.GetServerNameMerge(self.myData.platform, self.myData.zone_id))
	end

	self.readyData = GodsWarManager.Instance.readyData
	self.readyDataOther = GodsWarManager.Instance.readyDataOther

	self.effect1:SetActive(false)
	self.effect2:SetActive(false)
	if self.readyData == nil or self.readyData.tid == 0 then
		self.state1.text = TI18N("未准备")
	else
		if self.readyData.status == 0 then
			self.state1.text = TI18N("未准备")
		else
			if not GodsWarEumn.IsCompleteRount() then
				self.effect1:SetActive(true)
			end
			self.state1.text = TI18N("<color='#ffff00'>已准备</color>")
		end
	end

	if self.readyDataOther == nil or self.readyDataOther.tid == 0 then
		self.state2.text = TI18N("未准备")
	else
		if self.readyDataOther.status == 0 then
			self.state2.text = TI18N("未准备")
		else
			if not GodsWarEumn.IsCompleteRount() then
				self.effect2:SetActive(true)
			end
			self.state2.text = TI18N("<color='#ffff00'>已准备</color>")
		end
	end

	self.myFighter = GodsWarManager.Instance.myFighter
	if self.myFighter == nil then
		self.name2.text = TI18N("暂无")
	else
		if self.myFighter.flag == 2 then
			self.name2.text = TI18N("轮空")
			self.state2.text = TI18N("<color='#ffff00'>开始后获得奖励</color>")
		else
			self.name2.text = string.format("%s\n<color='#31f2f9'>%s</color>", self.myFighter.name, BaseUtils.GetServerNameMerge(self.myFighter.platform, self.myFighter.zone_id))
		end
	end

	local status = GodsWarManager.Instance.status
	if GodsWarEumn.IsCompleteRount() then
		self:EndTime()
		self.state1.text = ""
		self.state2.text = ""
		if self.myFighter ~= nil and self.myFighter.flag == 2 then
			self.time.text = string.format(TI18N("%s轮空，自动获胜"), GodsWarEumn.ShowStr())
		else
			self.time.text = string.format(TI18N("%s已结束，请自行离场"), GodsWarEumn.ShowStr())
		end
	else
		self:UpdateTime()
	end
end

function GodsWarMainUiTopPanel:UpdateResult(result)
	if result == 0 then
		self.state1.text = TI18N("<color='#ff0000'>失败方</color>")
		self.state2.text = TI18N("<color='#00ff00'>胜利方</color>")
	else
		self.state1.text = TI18N("<color='#00ff00'>胜利方</color>")
		self.state2.text = TI18N("<color='#ff0000'>失败方</color>")
	end
	self:EndTime()
	self.time.text = string.format(TI18N("%s已结束，请自行离场"), GodsWarEumn.ShowStr())
end

function GodsWarMainUiTopPanel:UpdateTime()
	self.timeVal = GodsWarManager.Instance:GetLeftTime()
	self:BeginTime()
end

function GodsWarMainUiTopPanel:BeginTime()
	self:EndTime()
	if self.timeVal > 0 then
		self.timeId = LuaTimer.Add(0, 1000, function() self:Loop() end)
	end
end

function GodsWarMainUiTopPanel:Loop()
	self.timeVal = self.timeVal - 1
	if self.timeVal < 0 then
		self:EndTime()
	else
		local str = BaseUtils.formate_time_gap(self.timeVal, ":", 0, BaseUtils.time_formate.MIN)
		if GodsWarManager.Instance.flag == 1 then
			self.time.text = string.format(TI18N("%s,开启倒计时:<color='#00ff00'>%s</color>"), GodsWarEumn.ShowStr(), str)
		else
			self.time.text = string.format(TI18N("%s,剩余时间:<color='#00ff00'>%s</color>"), GodsWarEumn.ShowStr(), str)
		end
	end
end

function GodsWarMainUiTopPanel:EndTime()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function GodsWarMainUiTopPanel:ClickSelf()
	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_main, {3, 1})
end