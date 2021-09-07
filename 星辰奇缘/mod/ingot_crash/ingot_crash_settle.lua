-- @author 黄耀聪
-- @date 2017年7月4日, 星期二

IngotCrashSettle = IngotCrashSettle or BaseClass(BaseWindow)

function IngotCrashSettle:__init(model)
    self.model = model
    self.name = "IngotCrashSettle"

    self.windowId = WindowConfig.WinID.ingot_crash_settle

    self.resList = {
        {file = AssetConfig.guildsiege_settle, type = AssetType.Main},
        {file = AssetConfig.guildsiege, type = AssetType.Dep},
    }

    self.effectList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function IngotCrashSettle:__delete()
    self.OnHideEvent:Fire()
    if self.rewardList ~= nil then
        for _,v in pairs(self.rewardList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.data:DeleteMe()
            end
        end
        self.rewardList = nil
    end
    if self.infoExt ~= nil then
        self.infoExt:DeleteMe()
        self.infoExt = nil
    end
    if self.rewardLayout ~= nil then
        self.rewardLayout:DeleteMe()
        self.rewardLayout = nil
    end
    if self.rotateTimerId ~= nil then
        LuaTimer.Delete(self.rotateTimerId)
        self.rotateTimerId = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self:AssetClearAll()
end

function IngotCrashSettle:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildsiege_settle))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.starList = {}
    for i=1,3 do
        local tab = {}
        tab.transform = t:Find("Main/Star" .. i)
        tab.gameObject = tab.transform.gameObject
        tab.image = tab.gameObject:GetComponent(Image)
        self.starList[i] = tab
        tab.gameObject:SetActive(false)
    end

    self.closeBtn = t:Find("Panel1"):GetComponent(Button)
    self.infoExt = MsgItemExt.New(t:Find("Main/Info"):GetComponent(Text), 400, 19, 22)
    self.win = t:Find("Main/Win").gameObject
    self.loss = t:Find("Main/Loss").gameObject
    self.light = t:Find("Main/Light").gameObject

    self.rewardList = {}
    self.rewardContainer = t:Find("Main/Reward")
    local length = self.rewardContainer.childCount

    self.rewardLayout = LuaBoxLayout.New(self.rewardContainer, {cspacing = 0, border = 5, axis = BoxLayoutAxis.X})
    for i=1,length do
        local tab = {}
        tab.transform = self.rewardContainer:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.slot = ItemSlot.New()
        NumberpadPanel.AddUIChild(tab.transform, tab.slot.gameObject)
        tab.data = ItemData.New()
        self.rewardList[i] = tab
    end

    self.tipsText = t:Find("Main/I18NTips"):GetComponent(Text)

    self.closeBtn.onClick:AddListener(function()
        -- if self.model.status ~= GuildSiegeEumn.Status.Disactive then
        if (IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Kickout or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess)
            and (IngotCrashManager.Instance.num or 0) <= 16 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_content)
        else
            WindowManager.Instance:CloseWindow(self)
        end
    end)
    self.infoExt.contentTxt.alignment = 0
    self.infoExt.contentTrans.pivot = Vector2(0,1)
end

function IngotCrashSettle:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IngotCrashSettle:OnOpen()
    self:RemoveListeners()

    BaseUtils.dump(self.openArgs, "奖励结算")
    self:Reload()
    self:CountDown()
end

function IngotCrashSettle:OnHide()
    self:RemoveListeners()
end

function IngotCrashSettle:RemoveListeners()
end

function IngotCrashSettle:Reload()
    local data = self.openArgs

    self.infoExt:SetData(data.msg)
    local size = self.infoExt.contentTrans.sizeDelta
    self.infoExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, -28)

    self.win:SetActive(data.is_win == 1)
    self.loss:SetActive(data.is_win ~= 1)

    local rewardList = {}
    for i,v in ipairs(data.reward) do
        if v.val > 0 then
            table.insert(rewardList, v)
        end
    end

    for i,reward in ipairs(rewardList) do
        local tab = self.rewardList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.rewardList[1].gameObject)
            tab.transform = tab.gameObject.transform
            tab.data = ItemData.New()
            tab.slot = ItemSlot.New(tab.transform:GetChild(0).gameObject)
            NumberpadPanel.AddUIChild(tab.transform, tab.slot.gameObject)
            self.rewardList[i] = tab
        end
        tab.data:SetBase(DataItem.data_get[reward.assets])
        tab.slot:SetAll(tab.data)
        tab.slot:SetNum(reward.val)
        self.rewardLayout:AddCell(tab.gameObject)
    end
    for i=#rewardList + 1,#self.rewardList do
        self.rewardList[i].gameObject:SetActive(false)
    end

    if data.is_win == 1 then
        self:Rotate()
    end
end

function IngotCrashSettle:CountDown()
    self.counter = 10
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 1000, function()
        self.tipsText.text = string.format(TI18N("点击空白处关闭(%s秒)"), self.counter)
        self.counter = self.counter - 1
        if self.counter < 0 then
            WindowManager.Instance:CloseWindow(self)
        end
    end)
end

function IngotCrashSettle:Rotate()
    self.rotateCounter = 0
    if self.rotateTimerId ~= nil then
        LuaTimer.Delete(self.rotateTimerId)
        self.rotateTimerId = nil
    end
    self.rotateTimerId = LuaTimer.Add(0, 20, function()
        self.rotateCounter = self.rotateCounter + 1
        if self.rotateCounter > 360 then
            self.rotateCounter = self.rotateCounter - 360
        end
        self.light.transform.localRotation = Quaternion.Euler(0, 0, self.rotateCounter)
    end)
end
