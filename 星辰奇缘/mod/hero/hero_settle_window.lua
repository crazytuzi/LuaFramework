HeroSettleWindow = HeroSettleWindow or BaseClass(BaseWindow)

function HeroSettleWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.hero_settle_window
    self.mgr = HeroManager.Instance
    self.resList = {
        {file = AssetConfig.warriorSettleWindow, type = AssetType.Main}
    }
    self.slotList = {}
    self.slotObjList = {}
end

function HeroSettleWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.warriorSettleWindow))
    self.gameObject.name = "HeroSettleWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local main = self.gameObject.transform:Find("Main")
    self.containerRect = main:Find("Content/RewardPanel/Container"):GetComponent(RectTransform)
    self.descText = main:Find("Content/Info/Desc/Text"):GetComponent(Text)
    self.descText.alignment = 1
    main:Find("Title/I18N_Text"):GetComponent(Text).text = self.mgr.name
    main:Find("Content/RewardPanel/Title/I18N_Text"):GetComponent(Text).text = TI18N("积分转换奖励")

    local rect = self.descText.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(0.5, 1)
    rect.anchorMin = Vector2(0.5, 1)
    rect.anchoredPosition = Vector2(0, -10)
    rect.sizeDelta = Vector2(400, 35)

    self.additionText = main:Find("Content/Info/Desc/Addition"):GetComponent(Text)

    local container = main:Find("Content/RewardPanel/Container")
    local baseids = {90000, 90010, 90012, 90012}

    for i=1,4 do
        self.slotObjList[i] = container:Find("Slot"..i)
        if self.slotObjList[i] == nil then
            self.slotObjList[i] = GameObject.Instantiate(self.slotObjList[1].gameObject).transform
            self.slotObjList[i]:SetParent(container)
            self.slotObjList[i].gameObject.name = "Slot4"
            self.slotObjList[i].localScale = Vector3.one
            self.slotObjList[i]:GetComponent(RectTransform).anchoredPosition = Vector2(87*(i-1), 0)
            self.slotList[i] = ItemSlot.New(self.slotObjList[i]:Find("ItemSlot").gameObject)
        end
        local cell = DataItem.data_get[baseids[i]]
        local itemdata = ItemData.New()
        itemdata:SetBase(cell)
        itemdata.quantity = 0
        if self.slotList[i] == nil then
            self.slotList[i] = ItemSlot.New()
        end
        -- self.slotList[i]:SetAll(itemdata, {inbag = false, nobutton = true, allowZero = true})
        NumberpadPanel.AddUIChild(self.slotObjList[i].gameObject, self.slotList[i].gameObject)
        self.slotObjList[i].gameObject:SetActive(false)
    end

    self.confirmBtn = main:Find("Confirm"):GetComponent(Button)
    self.confirmText = main:Find("Confirm/Text"):GetComponent(Text)
    self.confirmRect = main:Find("Confirm"):GetComponent(RectTransform)
end

-- self.openArgs = {[1] = data_14212}
function HeroSettleWindow:OnInitCompleted()
    self.revive = self.openArgs.die
    self.restTime = 60

    local func = function()
        WindowManager.Instance:CloseWindow(self)
    end
    local lev = RoleManager.Instance.RoleData.lev

    local desc = ""
    if self.openArgs.is_win == 1 then
        desc = TI18N("大获全胜！你和友方奋力杀敌，终于获得了最终的胜利。这些荣誉属于你！")
    else
        if self.openArgs.die == 0 then
            desc = TI18N("虽败犹荣！你奋战至力竭，败下阵来，但也为友方阵营争取到了优势。请收下这些奖励！")
        else
            desc = TI18N("虽败犹荣！你全力拼杀，虽不能力挽狂澜，但也捍卫了阵营的荣誉。务必收下这些奖励！")
        end
    end
    self.descText.text = desc


    if self.openArgs.is_win == 1 then
        self.confirmText.text = TI18N("确 定")

        if self.revive == 0 then
            self.additionText.text = TI18N("(由于复活次数为0，将自动退出)")
        else
            self.additionText.text = ""
        end
    else
        self.additionText.text = ""
        self.confirmText.text = TI18N("确 定")
    end

    for i,v in ipairs(self.openArgs.show) do
        local cell = DataItem.data_get[v.base_id]
        local itemdata = ItemData.New()
        itemdata:SetBase(cell)
        -- self.slotList[i].gameObject:GetComponent(Button).onClick:RemoveAllListeners()
        self.slotList[i]:SetAll(itemdata, {inbag = false, nobutton = true, allowZero = true})
        self.slotList[i]:SetNum(v.num)
        self.slotObjList[i].gameObject:SetActive(true)
    end
    for i=#self.openArgs.show + 1, #self.slotObjList do
        self.slotObjList[i].gameObject:SetActive(false)
    end

    local h = self.confirmRect.sizeDelta.y
    self.confirmRect.sizeDelta = Vector2(self.confirmText.preferredWidth + 80, h)

    self.containerRect.sizeDelta = Vector2(#self.openArgs.show * 67 + (#self.openArgs.show - 1) * 20, 0)
    self.confirmBtn.onClick:RemoveAllListeners()
    self.confirmBtn.onClick:AddListener(func)
end

function HeroSettleWindow:__delete()
    for _, slotItem in pairs(self.slotList) do
        slotItem:DeleteMe()
    end
    self.slotList = {}

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self:AssetClearAll()
end


