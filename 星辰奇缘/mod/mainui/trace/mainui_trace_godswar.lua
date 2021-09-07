-- -----------------------------
-- 诸神之战追踪界面
-- hosr
-- -----------------------------
MainuiTraceGodsWar = MainuiTraceGodsWar or BaseClass(BaseTracePanel)

function MainuiTraceGodsWar:__init(main)
	self.main = main

    self.isInit = false
    self.effect = nil
    self.effectPath = "prefabs/effect/20054.unity3d"

    self.resList = {
        {file = AssetConfig.godswarmainuitrace, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
    }
    self.timeVal = 0
    self.listener = function() self:Update() end
    self.timeListener = function() self:UpdateTime() end
end

function MainuiTraceGodsWar:__delete()
	self:EndTime()
    EventMgr.Instance:RemoveListener(event_name.godswar_ready_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.godswar_fighter_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.godswar_team_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.godswar_time_update, self.timeListener)
    self.readyImg.sprite = nil
end

function MainuiTraceGodsWar:OnOpen()
    self.gameObject:SetActive(true)
    self:Update()
end

function MainuiTraceGodsWar:Hiden()
    self.gameObject:SetActive(false)
end

function MainuiTraceGodsWar:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarmainuitrace))
    self.gameObject.name = "MainuiTraceGodsWar"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.mainObj.transform)
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition = Vector2(0, -46)
    self.transform.localPosition = Vector3(self.transform.localPosition.x, self.transform.localPosition.y, 0)

    self.transform:Find("Before/Panel"):GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
    self.name = self.transform:Find("Before/conbg/name"):GetComponent(Text)
    self.desc = self.transform:Find("Before/DescText_2"):GetComponent(Text)
    self.timeTxt = self.transform:Find("Before/ActiveText"):GetComponent(Text)
    self.timeObj = self.timeTxt.gameObject
    self.readyTxt = self.transform:Find("Before/Ready/Text"):GetComponent(Text)
    self.readyImg = self.transform:Find("Before/Ready"):GetComponent(Image)
    self.timeTxt.text = "00:00"

    self.desc = self.transform:Find("Before/DescAcitveText"):GetComponent(Text)
    self.descRect = self.desc.gameObject:GetComponent(RectTransform)
    self.descRect.anchorMax = Vector2.zero
    self.descRect.anchorMin = Vector2.zero
    self.descRect.sizeDelta = Vector2(135, 28)
    self.descRect.anchoredPosition = Vector3(70, 8, 0)

    self.iconImg = self.transform:Find("Before/RuleBgImage").gameObject

    local readyBtn = self.transform:Find("Before/Ready")
    self.transform:Find("Before/Ready"):GetComponent(Button).onClick:AddListener(function() self:OnReady() end)
    self.transform:Find("Before/Quit"):GetComponent(Button).onClick:AddListener(function() self:OnQuit() end)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.transform:SetParent(readyBtn)
    self.effect.transform.localScale = Vector3(2, 1, 1)
    self.effect.transform.localPosition = Vector3(-62, -40, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(false)

    self:OnOpen()
    EventMgr.Instance:AddListener(event_name.godswar_ready_update, self.listener)
    EventMgr.Instance:AddListener(event_name.godswar_fighter_update, self.listener)
    EventMgr.Instance:AddListener(event_name.godswar_team_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.godswar_time_update, self.timeListener)
end

function MainuiTraceGodsWar:Update()
    self.myFighter = GodsWarManager.Instance.myFighter
    if self.myFighter == nil then
        self.name.text = TI18N("暂无")
    else
    self.name.text = string.format("%s(%s)", self.myFighter.name, BaseUtils.GetServerNameMerge(self.myFighter.platform, self.myFighter.zone_id))
        if self.myFighter.flag == 2 then
            self.name.text = TI18N("本轮轮空，自动获胜")
        end
    end
    self.readyData = GodsWarManager.Instance.readyData

    if self.readyData ~= nil and self.readyData.status == 1 then
        self.effect:SetActive(false)
        self.readyTxt.text = TI18N("取消准备")
        self.readyImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    else
        if GodsWarEumn.IsCompleteRount() then
            self.readyImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.effect:SetActive(false)
            self.readyTxt.text = TI18N("比赛结束")
        else
            self.readyTxt.text = TI18N("准备就绪")
            if TeamManager.Instance:IsSelfCaptin() then
                self.effect:SetActive(true)
                self.readyImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            else
                self.readyImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            end
        end
    end

    if GodsWarEumn.IsCompleteRount() then
        self:EndTime()
        self.descRect.anchorMax = Vector2.zero
        self.descRect.anchorMin = Vector2.zero
        self.descRect.sizeDelta = Vector2(215, 29)
        self.descRect.anchoredPosition = Vector3(107, 8, 0)
        if GodsWarEumn.Round(GodsWarManager.Instance.status) == 0 then
            self.desc.text = string.format(TI18N("<color='#ffff00'>%s</color>已结束，请自行离场"), GodsWarEumn.MatchName(GodsWarManager.Instance.status))
        else
            self.desc.text = string.format(TI18N("第<color='#ffff00'>%s</color>轮已结束，请自行离场"), GodsWarEumn.Round(GodsWarManager.Instance.status))
        end
        self.timeObj:SetActive(false)
        self.iconImg:SetActive(false)
    else
        self.timeObj:SetActive(true)
        self.iconImg:SetActive(true)
        self.descRect.anchorMax = Vector2.zero
        self.descRect.anchorMin = Vector2.zero
        self.descRect.sizeDelta = Vector2(135, 29)
        self.descRect.anchoredPosition = Vector3(70, 8, 0)
        self:UpdateTime()
    end
end

function MainuiTraceGodsWar:UpdateTime()
    if GodsWarManager.Instance:GetLeftTime() == 0 then
        self.timeTxt.text = "00:00"
    else
        self.timeVal = GodsWarManager.Instance:GetLeftTime()
        self:BeginTime()
    end

    if GodsWarManager.Instance.flag == 2 then
        self.desc.text = TI18N("离比赛结束剩余")
    else
        self.desc.text = TI18N("离比赛开始还有")
    end
end

function MainuiTraceGodsWar:BeginTime()
	self:EndTime()
    if self.timeVal > 0 then
        self.timeId = LuaTimer.Add(0, 1000, function() self:Loop() end)
    end
end

function MainuiTraceGodsWar:Loop()
	self.timeVal = self.timeVal - 1
	if self.timeVal < 0 then
		self:EndTime()
	else
		self.timeTxt.text = BaseUtils.formate_time_gap(self.timeVal, ":", 0, BaseUtils.time_formate.MIN)
	end
end

function MainuiTraceGodsWar:EndTime()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function MainuiTraceGodsWar:OnReady()
    if not GodsWarEumn.IsCompleteRount() then
        GodsWarManager.Instance:ReadyCheck()
    end
end

function MainuiTraceGodsWar:OnQuit()
    if TeamManager.Instance:HasTeam() and not TeamManager.Instance:IsSelfCaptin() then
        NoticeManager.Instance:FloatTipsByString(TI18N("该操作只能由队长进行哦"))
        return
    end

    if GodsWarManager.Instance.flag == 1 then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureLabel = TI18N("确定")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function()
            GodsWarManager.Instance:Send17920()
        end
        confirmData.content = TI18N("比赛即将开始，是否确定退出")
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        GodsWarManager.Instance:Send17920()
    end
end

function MainuiTraceGodsWar:ClickSelf()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_main, {3, 1})
end