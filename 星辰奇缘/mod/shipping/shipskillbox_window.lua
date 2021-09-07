ShipSkillboxWindow = ShipSkillboxWindow or BaseClass(BaseWindow)

function ShipSkillboxWindow:__init(model)
    self.model = model
    self.name = "ShipSkillboxWindow"
    self.windowId = WindowConfig.WinID.chest_box_win
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.prac_skill_chestbox, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.is_open = false
    self.MainCon = nil
    self.MidCon = nil
    self.Item = nil
    self.ImgConfirmBtn = nil

    self.item_list = {}
    self.run_type = 0
    self.total_count = 1
    self.ttime = 0.4
    self.result_idx = nil

    self.count_add = 0
    self.index_count = 1
    self.total_item_num = 15
    self.reward_index = nil
    self.notify_scroll_msg = nil

    self.last_index = nil
    self.last_item = nil

    self.rollTimer = nil

    self.slotlist = {}
    ------------------------------------------------

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function ShipSkillboxWindow:__delete()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    if self.rollTimer ~= nil then
        LuaTimer.Delete(self.rollTimer)
        self.rollTimer = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()

    self:OnHide()

    if self.run_type ~= 3 then
        SkillManager.Instance:Send10814()
    end
    self.is_open = false
    self.last_item = nil
    self.result_idx = nil
    if self.targetData == nil then
        ShippingManager.Instance:Req13716(self.openArgs)
    end
end

function ShipSkillboxWindow:InitPanel(openArgs)
    -- self.openArgs = {}
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.prac_skill_chestbox))
    self.gameObject.name = "ShipSkillboxWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.MainCon = self.transform:FindChild("MainCon").gameObject
    self.MidCon = self.MainCon.transform:Find("MidCon").gameObject
    self.Item = self.MidCon.transform:Find("Item").gameObject

    self.closeBtn = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.ImgConfirmBtn = self.MainCon.transform:Find("ImgConfirmBtn").gameObject
    self.ImgConfirmBtn:GetComponent(Button).onClick:AddListener(function() self:on_click_confirm_btn() end)
    self.ImgConfirmBtn:SetActive(true)

    ---------------------------------------------
    self:OnShow()
    self:BeginRoll()
end

function ShipSkillboxWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function ShipSkillboxWindow:OnShow()
    for k,v in pairs(DataShipping.data_box) do
        local item = GameObject.Instantiate(self.Item)
        local itemT = item.transform
        itemT:SetParent(self.MidCon.transform)
        itemT.localScale = Vector3.one
        local equipSlot = ItemSlot.New()
        UIUtils.AddUIChild(itemT:Find("SlotItemCon").gameObject, equipSlot.gameObject)
        local itemData = ItemData.New()
        itemData:SetBase(BackpackManager.Instance:GetItemBase(20025))
        equipSlot:SetAll(itemData)
        equipSlot:SetNotips(false)
        table.insert(self.slotlist, equipSlot)
        item:SetActive(true)
        itemT:Find("Text"):GetComponent(Text).text = v.num
        table.insert(self.item_list, {trans = itemT, data = v})
    end
end

function ShipSkillboxWindow:OnHide()
    -- SkillManager.Instance.OnUpdatePracSkillChestBox:Remove(self._chestbox_update)
end

function ShipSkillboxWindow:BeginRoll()
    if self.rollTimer ~= nil then
        return
    end
    self.rollTimer = LuaTimer.Add(0,100, function()
        self:MoveToNext()
    end)
    LuaTimer.Add(3000, function()
        if self.gameObject ~= nil then
            ShippingManager.Instance:Req13716(self.openArgs)
        end
    end)
end

function ShipSkillboxWindow:StopRoll(targetData)
    self.targetData = targetData
    for i,v in ipairs(self.item_list) do
        if targetData.id == v.data.id then
            self.result_idx = i
        end
    end
    if self.rollTimer ~= nil then
        LuaTimer.Delete(self.rollTimer)
        self.rollTimer = nil
    end
    self:MoveToNext()
end

function ShipSkillboxWindow:MoveToNext()
    if self.gameObject == nil then
        return
    end
    if self.last_item == nil then
        self.last_index = 1
        self.last_item = self.item_list[1]
        -- self.last_item.trans:Find("ImgSelect").gameObject:SetActive(true)
    else
        self.last_item.trans:Find("ImgSelect").gameObject:SetActive(false)
        self.last_index = (self.last_index)%15 + 1
        self.last_item = self.item_list[self.last_index]
    end
    self.last_item.trans:Find("ImgSelect").gameObject:SetActive(true)
    if self.result_idx ~= nil then
        if self.last_index ~= self.result_idx then
            local time = self.result_idx - self.last_index
            if time < 0 then
                time = time + 15
            end
            local speed = 100 * math.max(1, 3/time)
            LuaTimer.Add( speed, function()
                self:MoveToNext()
            end)
        else
            local getData = DataShipping.data_box[self.targetData.id]
            -- NoticeManager.Instance:FloatTipsByString(string.format("今日还可以开启%s个", getData.num))
        end
    end
end

function ShipSkillboxWindow:on_click_confirm_btn()
    -- self:BeginRoll()

    if self.result_idx ~= nil then
        self:OnClickClose()
    end
end