WarriorSettleWindow = WarriorSettleWindow or BaseClass(BaseWindow)

function WarriorSettleWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.warrior_settle_window
    self.resList = {
        {file = AssetConfig.warriorSettleWindow, type = AssetType.Main}
    }
    self.slotList = {}
    self.slotObjList = {}
end

function WarriorSettleWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.warriorSettleWindow))
    self.gameObject.name = "WarriorSettleWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local main = self.gameObject.transform:Find("Main")
    self.descText = main:Find("Content/Info/Desc/Text"):GetComponent(Text)
    self.descText.alignment = 1

    local rect = self.descText.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(0.5, 1)
    rect.anchorMin = Vector2(0.5, 1)
    rect.anchoredPosition = Vector2(0, -10)
    rect.sizeDelta = Vector2(400, 35)

    self.additionText = main:Find("Content/Info/Desc/Addition"):GetComponent(Text)

    local container = main:Find("Content/RewardPanel/Container")
    local baseids = {90000, 90010, 90012}

    for i=1,3 do
        self.slotObjList[i] = container:Find("Slot"..i)
        local cell = DataItem.data_get[baseids[i]]
        local itemdata = ItemData.New()
        itemdata:SetBase(cell)
        itemdata.quantity = 0
        self.slotList[i] = ItemSlot.New()
        -- self.slotList[i]:SetAll(itemdata, {inbag = false, nobutton = true, allowZero = true})
        NumberpadPanel.AddUIChild(self.slotObjList[i].gameObject, self.slotList[i].gameObject)
    end

    self.confirmBtn = main:Find("Confirm"):GetComponent(Button)
    self.confirmText = main:Find("Confirm/Text"):GetComponent(Text)
    self.confirmRect = main:Find("Confirm"):GetComponent(RectTransform)
end

-- self.openArgs = {[1] = data_14212}
function WarriorSettleWindow:OnInitCompleted()
    BaseUtils.dump(self.openArgs)
    local data = self.openArgs[1]
    self.revive = self.openArgs[2]
    self.restTime = 60

    local func = nil
    local camp = nil
    local lev = RoleManager.Instance.RoleData.lev
    local exchange = DataWarrior.data_exchange_score[lev]

    if data.camp == 1 then
        camp = TI18N("青龙阵营")
    else
        camp = TI18N("白虎阵营")
    end
    if data.victory == 1 then
        self.confirmText.text = TI18N("确定")
        func = function()
            WindowManager.Instance:CloseWindow(self)
        end

        self.descText.text = string.format(TI18N("%s获得了胜利,你在本次勇士战场中总共获得了<color=#FFFF00>%s</color>功勋"), camp, tostring(data.score))

        if self.revive == 0 then
            self.additionText.text = TI18N("(由于复活次数为0，稍后将自动退出战场)")
        else
            self.additionText.text = ""
        end
    else
        self.additionText.text = ""
        self.confirmText.text = TI18N("退出活动")
        func = function()
            WarriorManager.Instance:send14202()
            WindowManager.Instance:CloseWindow(self)
        end
        self.descText.text = string.format(TI18N("%s虽败犹荣，你在本次勇士战场中总共获得了%s功勋"), camp, tostring(data.score))

        self.timerId = LuaTimer.Add(0, 1000, function() self:OnTick() end)
    end

    if data.reward ~= nil then
        for i=1,3 do
            local cell = DataItem.data_get[data.reward[i].assets]
            local itemdata = ItemData.New()
            itemdata:SetBase(cell)
            self.slotList[i].gameObject:GetComponent(Button).onClick:RemoveAllListeners()
            self.slotList[i]:SetAll(itemdata, {inbag = false, nobutton = true, allowZero = true})
            self.slotList[i]:SetNum(data.reward[i].val)
        end
    end
    local h = self.confirmRect.sizeDelta.y
    self.confirmRect.sizeDelta = Vector2(self.confirmText.preferredWidth + 80, h)

    self.confirmBtn.onClick:RemoveAllListeners()
    self.confirmBtn.onClick:AddListener(func)
end

function WarriorSettleWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self:AssetClearAll()
end

function WarriorSettleWindow:OnTick()
    if self.restTime ~= nil and self.restTime > 0 then
        self.restTime = self.restTime - 1
        self.confirmText.text = TI18N("退出活动("..self.restTime.."秒)")
        local h = self.confirmRect.sizeDelta.y
        self.confirmRect.sizeDelta = Vector2(self.confirmText.preferredWidth + 80, h)

        if self.restTime == 0 then
            WarriorManager.Instance:send14202()
            LuaTimer.Delete(self.timerId)
            WindowManager.Instance:CloseWindow(self)
        end
    end
end
