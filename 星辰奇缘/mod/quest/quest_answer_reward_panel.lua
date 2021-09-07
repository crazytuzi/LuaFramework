-- --------------------------------
-- 答题结束统计界面
-- hosr
-- --------------------------------
QuestAnswerReward = QuestAnswerReward or BaseClass(BasePanel)

function QuestAnswerReward:__init()
    self.path = "prefabs/ui/finishcount/finishrewardwin.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
    }
    self.slots = {}
    self.X_list = {201, 163, 126, 89, 55, 22}
    self.closeId = 0
    self.type = 0
end

function QuestAnswerReward:__delete()
    for i,v in ipairs(self.slots) do
        v:DeleteMe()
    end
    self.slots = nil

    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    if self.closeId ~= 0 then
        LuaTimer.Delete(self.closeId)
        self.closeId = 0
    end
end

function QuestAnswerReward:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "QuestAnswerReward"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.titleTxt = self.transform:Find("MainCon/ImgTitle/TxtTitle"):GetComponent(Text)
    self.titleTxt.text = TI18N("答题")

    self.transform:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("MainCon/ImgShareBtn").gameObject:SetActive(false)
    local sureBtn = self.transform:Find("MainCon/ImgConfirmBtn").gameObject
    sureBtn:SetActive(true)
    sureBtn:GetComponent(Button).onClick:AddListener(function() self:Close() end)
    sureBtn.transform.localPosition = Vector3(0, -120, 0)

    self.contentTxt = self.transform:Find("MainCon/MidCon/TxtPassVal1"):GetComponent(Text)
    self.contentTxt.text = ""

    self.slotContainer = self.transform:Find("MainCon/MidCon/MaskScroll/ConSlot")
    self.slotContainerRect = self.slotContainer:GetComponent(RectTransform)
    self.slotContainerRect.anchoredPosition = Vector2.zero
    self.BaseSlot = self.slotContainer:Find("SlotConbase").gameObject
    self:InitSlot()

    self:OnShow()
end

function QuestAnswerReward:OnShow()
    if self.type == 0 then
        self.titleTxt.text = TI18N("伴侣答题")
    elseif self.type == 1 then
        self.titleTxt.text = TI18N("情缘答题")
    elseif self.type == 2 then
        self.titleTxt.text = TI18N("师徒答题")
    end

    self:ShowInfo()
    if self.closeId ~= 0 then
        LuaTimer.Delete(self.closeId)
        self.closeId = 0
    end
    self.closeId = LuaTimer.Add(5000, function() self:Close() end)
end

function QuestAnswerReward:Close()
    if self.closeId ~= 0 then
        LuaTimer.Delete(self.closeId)
        self.closeId = 0
    end
    QuestMarryManager.Instance:CloseAward(self.type)
end

function QuestAnswerReward:ShowInfo()
    local rightNum = 0
    local wrongNum = 0
    if self.type == 2 then
        for i,v in ipairs(self.openArgs.stats) do
            if v.result == 2 then
                rightNum = rightNum + 1
            else
                wrongNum = wrongNum + 1
            end
        end
        self.contentTxt.text = string.format(TI18N("共同回答正确题数:<color='#ffff00'>%s</color>"), rightNum)
    else
        for i,v in ipairs(self.openArgs.stats) do
            if v.result == 1 then
                rightNum = rightNum + 1
            else
                wrongNum = wrongNum + 1
            end
        end
        self.contentTxt.text = string.format(TI18N("双方同步题数:<color='#00ffff'>%s</color>    双方不同步题数:<color='#ffff00'>%s</color>"), rightNum, wrongNum)
    end

    self:ShowAward(self.openArgs.gains)
end

function QuestAnswerReward:ShowAward(data)
    local newData = {}
    for i,v in ipairs(data) do
        if newData[v.assets] == nil then
            newData[v.assets] = v.value
        else
            newData[v.assets] = newData[v.assets] + v.value
        end
    end

    local len = 0
    for assets, value in pairs(newData) do
        len = len + 1
        local slot = self.slots[len]
        local item = BackpackManager.Instance:GetItemBase(assets)
        item.quantity = value
        item.bind = 0
        slot:SetAll(item, {nobutton = true})
        slot.gameObject:SetActive(true)
        slot.gameObject.transform.parent.gameObject:SetActive(true)
    end

    local conX = self.X_list[len]
    -- self.slotContainerRect.anchoredPosition = Vector2(conX, 0)

    len = len + 1
    for i = len, 6 do
        self.slots[i].gameObject:SetActive(false)
    end
end

function QuestAnswerReward:InitSlot()
    for i=1, 6 do
        local slot_con = GameObject.Instantiate(self.BaseSlot)
        slot_con.name = string.format("SlotCon%s", i)
        slot_con = slot_con.transform
        -- slot_con.gameObject:SetActive(true)
        slot_con:SetParent(self.slotContainer)
        slot_con.localScale = Vector3.one
        -- local slot = self:create_equip_slot(slot_con)
        local slot = ItemSlot.New()
        local trans = slot.gameObject.transform
        trans:SetParent(slot_con.transform)
        trans.anchoredPosition = Vector2.zero
        trans.localScale = Vector3.one
        table.insert(self.slots, slot)
        -- table.insert(self.slot_con_list, slot_con)
    end
end