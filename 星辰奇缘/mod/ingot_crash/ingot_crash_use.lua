IngotCrashUse = IngotCrashUse or BaseClass(BasePanel)

function IngotCrashUse:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "IngotCrashUse"

    self.resList = {
        {file = AssetConfig.ingotcrash_use, type = AssetType.Main},
        {file = AssetConfig.ingotcrash_textures, type = AssetType.Dep},
    }

    self.idList = {
        {id = 96105, name = TI18N("大力丸"), effectDesc = TI18N("所有守护输出提升<color='#ffff00'>8%</color>")},
        {id = 96110, name = TI18N("幸运丸"), effectDesc = TI18N("本场战斗中随机一名守护获得<color='#ffff00'>保命</color>效果一次")},
    }

    self.beginFightListener = function(type) self:BeginFight(type) end
    self.endFightListener = function(type) self:EndFight(type) end
    self.updateListener = function() self:Reload() end
    self.sceneListener = function() self:SceneLoad() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function IngotCrashUse:__delete()
    self.OnHideEvent:Fire()
    if self.countDownEffect ~= nil then
        self.countDownEffect:DeleteMe()
        self.countDownEffect = nil
    end
    if self.beginFightEffect ~= nil then
        self.beginFightEffect:DeleteMe()
        self.beginFightEffect = nil
    end
    if self.enterSceneEffect ~= nil then
        self.enterSceneEffect:DeleteMe()
        self.enterSceneEffect = nil
    end
    self:AssetClearAll()
end

function IngotCrashUse:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ingotcrash_use))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.luckyImage = self.transform:Find("Lucky"):GetComponent(Image)
    self.luckyButton = self.luckyImage.gameObject:GetComponent(Button)
    self.powerImage = self.transform:Find("Power"):GetComponent(Image)
    self.powerButton = self.powerImage.gameObject:GetComponent(Button)
    self.numImage = self.transform:Find("Num"):GetComponent(Image)

    self.btnList = {
        {
            img = self.powerImage,
            btn = self.powerButton,
            timeText = self.transform:Find("Time2"):GetComponent(Text),
        },
        {
            img = self.luckyImage,
            btn = self.luckyButton,
            timeText = self.transform:Find("Time1"):GetComponent(Text),
        },
    }

    for i=1,2 do
        local j = i
        self.btnList[i].btn.onClick:AddListener(function() self:OnClick(j) end)
    end

    -- self.damakuPanel = IngotCrashDamaku.New(self.model, self.gameObject)
    -- self.damakuPanel:Show()
end

function IngotCrashUse:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IngotCrashUse:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFightListener)
    IngotCrashManager.Instance.onUpdateInfo:AddListener(self.updateListener)
    EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)

    IngotCrashManager.Instance:send20012()
    self.numImage.gameObject:SetActive(false)
    self:Reload()
    self:SceneLoad()
end

function IngotCrashUse:GoTimer()
    self.counter = (self.counter or 0) + 1
    if BaseUtils.BASE_TIME - ((IngotCrashManager.Instance.combat_stemp or BaseUtils.BASE_TIME) - 20) == 1 then
        self.model.canWalk = false
        if self.countDownEffect == nil then
            self.countDownEffect = BibleRewardPanel.ShowEffect(20397, self.transform, Vector3.one, Vector3(0, 200, 0))
        else
            self.countDownEffect:SetActive(false)
            self.countDownEffect:SetActive(true)
        end
        IngotCrashManager.Instance:SceneEnter()
    elseif BaseUtils.BASE_TIME - ((IngotCrashManager.Instance.combat_stemp or BaseUtils.BASE_TIME) - 20) == 6 then
        self.model.canWalk = true
        if self.countDownEffect ~= nil then
            self.countDownEffect:SetActive(false)
        end
        if self.enterSceneEffect == nil then
            self.enterSceneEffect = BibleRewardPanel.ShowEffect(20398, self.transform, Vector3.one, Vector3(0, 200, 0))
        else
            self.enterSceneEffect:SetActive(false)
            self.enterSceneEffect:SetActive(true)
        end
        IngotCrashManager.Instance:SceneEnter()
        IngotCrashManager.Instance.onUpdateMove:Fire()
    elseif BaseUtils.BASE_TIME - ((IngotCrashManager.Instance.combat_stemp or BaseUtils.BASE_TIME) - 20) == 7 then
        if self.enterSceneEffect ~= nil then
            self.enterSceneEffect:SetActive(false)
        end
        if self.beginFightEffect == nil then
            self.beginFightEffect = BibleRewardPanel.ShowEffect(20399, self.transform, Vector3.one, Vector3(30, 200, 0))
        else
            self.beginFightEffect:SetActive(false)
            self.beginFightEffect:SetActive(true)
        end
    end
end

function IngotCrashUse:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.countDownEffect ~= nil then
        self.countDownEffect:SetActive(false)
    end
    if self.beginFightEffect ~= nil then
        self.beginFightEffect:SetActive(false)
    end
    if self.enterSceneEffect ~= nil then
        self.enterSceneEffect:SetActive(false)
    end
end

function IngotCrashUse:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFightListener)
    IngotCrashManager.Instance.onUpdateInfo:RemoveListener(self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
end

function IngotCrashUse:OnClick(index)
    if (self.model.drugTimes[index].times_use or 0) - (self.model.drugTimes[index].times or 0) == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("本场战斗可使用次数已用完"))
    else
        local id = self.idList[index].id
        self.confirmData = self.confirmData or NoticeConfirmData.New()

        local times = self.model.drugTimes[index].times_all
        local cost = {90000,100}
        for i,v in ipairs(self.model.drugTimesTab[id]) do
            if times + 1 >= v.times_min and times + 1 <= v.times_max then
                cost[1] = v.type
                cost[2] = v.price
                break
            end
        end
        self.confirmData.content = string.format(TI18N("是否消耗<color='#00ff00'>%s</color>{assets_2,%s}使用<color='#ffff00'>[%s]</color>？\n效果：%s"), cost[2], cost[1], self.idList[index].name, self.idList[index].effectDesc)
        self.confirmData.sureCallback = function() IngotCrashManager.Instance:send20009(id) end
        NoticeManager.Instance:ConfirmTips(self.confirmData)
    end
end

function IngotCrashUse:BeginFight(type)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    for i,v in ipairs(self.btnList) do
        v.timeText.gameObject:SetActive(false)
        v.btn.gameObject:SetActive(false)
    end
    if self.countDownEffect ~= nil then
        self.countDownEffect:SetActive(false)
    end
    if self.beginFightEffect ~= nil then
        self.beginFightEffect:SetActive(false)
    end
    if self.enterSceneEffect ~= nil then
        self.enterSceneEffect:SetActive(false)
    end
end

function IngotCrashUse:EndFight(type, result)
    -- self:Show()
end

function IngotCrashUse:Reload()
    local showIndexList = {}
    if not CombatManager.Instance.isFighting then
        for i,v in ipairs(self.btnList) do
            v.timeText.gameObject:SetActive(true)
            v.btn.gameObject:SetActive(true)
            local num = (self.model.drugTimes[i].times_use or 0) - (self.model.drugTimes[i].times or 0)
            if num == 0 then
                v.timeText.text = string.format("<color='#ff0000'>0</color>/%s", self.model.drugTimes[i].times_use or 0)
            else
                v.timeText.text = string.format("%s/%s", num, self.model.drugTimes[i].times_use or 0)
            end
        end
    end

    -- self:SetCountDown(IngotCrashManager.Instance.combat_stemp)

    -- self.beginStemp = IngotCrashManager.Instance.combat_stemp - 20

    self.counter = 0
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if not CombatManager.Instance.isFighting then
        self.timerId = LuaTimer.Add(0, 1000, function() self:GoTimer() end)
    end
end

function IngotCrashUse:SceneLoad()
    -- if SceneManager.Instance:CurrentMapId() == 53004 then
    --     self.damakuPanel:Hiden()
    -- else
    --     self.damakuPanel:Show()
    -- end
end
