-- @author hze
-- @date #2019/09/16#
-- 祈愿宝阁

PrayTreasureMainPanel = PrayTreasureMainPanel or BaseClass(BasePanel)

function PrayTreasureMainPanel:__init(model, parent)
    self.resList = {
        {file = AssetConfig.pray_treasure_main_panel, type = AssetType.Main}
        ,{file = AssetConfig.praytreasuretextures, type = AssetType.Dep}
    }
    self.model = model
    self.parent = parent
    self.mgr = self.model.mgr

    self.itemList = {}
    self.evilStatus = 0
    self.currentIndex = 1

    self._updateItemNumListener = function() self:SetItemNum() end
    self._updateReloadListener = function() self:ReloadData() end
    self.rotationListener = function(id) self:RotationTimer(id) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function PrayTreasureMainPanel:__delete()
    self.OnHideEvent:Fire()

    if self.itemList ~= nil then
        for i, v in ipairs(self.itemList) do
            v:DeleteMe()
        end
    end

    if self.iconLoader then
        self.iconLoader:DeleteMe()
    end

    if self.oneIconLoader then
        self.oneIconLoader:DeleteMe()
    end

    if self.tenIconLoader then
        self.tenIconLoader:DeleteMe()
    end
end

function PrayTreasureMainPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pray_treasure_main_panel))
    self.gameObject.name = "PrayTreasureMainPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.container = self.transform:Find("Contanier")

    for i = 1, 10 do
        self.itemList[i] = PrayTreasureMainItem.New(self.model, self.container:GetChild(i - 1).gameObject)
    end

    self.iconLoader = SingleIconLoader.New(self.transform:Find("Extra/Icon").gameObject)
    self.iconOwnerTxt = self.transform:Find("Extra/NumBg/Text"):GetComponent(Text)

    self.extraBtn = self.transform:Find("Extra"):GetComponent(Button)
    self.extraBtn.onClick:AddListener(function() 
        -- TipsManager.Instance:ShowItem({gameObject = self.extraBtn.gameObject, itemData = DataItem.data_get[self.lossItemId], extra = {nobutton = true, inbag = false}})
        TipsManager.Instance:ShowItem({gameObject = self.extraBtn.gameObject, itemData = DataItem.data_get[self.lossItemId]})
    end)

    self.btn1 = self.transform:Find("OneButton"):GetComponent(Button)
    self.btn1.onClick:AddListener(function() self:OnPrayClick(1) end)
    self.oneTxt = self.transform:Find("One/Text"):GetComponent(Text)
    self.oneIconLoader = SingleIconLoader.New(self.transform:Find("One/Icon").gameObject)
    -- self.oneTxt.text = TI18N("购买") .. DataCampPray.data_other[3].value1[1][2]
    self.oneTxt.text = TI18N("购买1个")

    self.btn2 = self.transform:Find("TenButton"):GetComponent(Button)
    self.btn2.onClick:AddListener(function() self:OnPrayClick(2) end)
    self.tenTxt = self.transform:Find("Ten/Text"):GetComponent(Text)
    self.tenIconLoader = SingleIconLoader.New(self.transform:Find("Ten/Icon").gameObject)
    -- self.tenTxt.text = TI18N("购买") .. DataCampPray.data_other[9].value1[1][2]
    self.tenTxt.text = TI18N("购买10个")

    self.lossItemId = DataCampPray.data_other[2].value1[1]

    self.oneIconLoader:SetSprite(SingleIconType.Item, self.lossItemId)
    self.tenIconLoader:SetSprite(SingleIconType.Item, self.lossItemId)
    self.iconLoader:SetSprite(SingleIconType.Item, self.lossItemId)
end

function PrayTreasureMainPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PrayTreasureMainPanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()

    -- BaseUtils.dump(self.openArgs)

    self.campId = self.openArgs[1]
    self.campaignData = DataCampaign.data_list[self.campId]

    self:ReloadData()
    self:SetItemNum()
end

function PrayTreasureMainPanel:OnHide()
    self:RemoveListeners()
    if self.timerId then
        LuaTimer.Delete(self.timerId)
    end

    if self.itemList then
        for i, v in pairs (self.itemList) do
            v:ShowEndEffect(false)
        end
    end
    
    if self.evilStatus == 1 or self.evilStatus == 2 then
        self.model.prayTreasureMode = true
        self.mgr:Send21202(self.evilStatus)
        LuaTimer.Add(500, function() 
            self.evilStatus = 0
            self.mgr:Send21203() 
        end)
    elseif self.evilStatus == 3 then
        self.model.prayTreasureMode = true
        LuaTimer.Add(500, function()
            self.evilStatus = 0
            self.mgr:Send21203()
        end
    )

    end
end

function PrayTreasureMainPanel:AddListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._updateItemNumListener)    
    self.mgr.updatePrayTreasureEvent:AddListener(self._updateReloadListener)
    self.mgr.getPrayTreasureRewardEvent:AddListener(self.rotationListener)
end

function PrayTreasureMainPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._updateItemNumListener)
    self.mgr.updatePrayTreasureEvent:RemoveListener(self._updateReloadListener)
    self.mgr.getPrayTreasureRewardEvent:RemoveListener(self.rotationListener)
end

function PrayTreasureMainPanel:ReloadData()
    local data = BaseUtils.copytab(self.model.prayTreasureSelectTab)
    for index , item in ipairs(self.itemList) do
        local dat = data[index]
        item:SetData(dat, index)
    end
end

function PrayTreasureMainPanel:SetItemNum()
    self.iconOwnerTxt.text = string.format(TI18N("已拥有：<color='#248813'>%s</color>"), BackpackManager.Instance:GetItemCount(self.lossItemId))
end

function PrayTreasureMainPanel:OnPrayClick(mode)
    local str = ""
    local value = {}
    local count = 1
    if mode == 1 then
        count = 1
        value = DataCampPray.data_other[3].value1[1]
    else
        count = 10
        value = DataCampPray.data_other[9].value1[1]
    end

    if BackpackManager.Instance:GetItemCount(self.lossItemId) >= count 
        or not self.model:GetFullSelectList() 
        or RoleManager.Instance.RoleData.gold < value[2] then
        self.mgr:Send21202(mode)
        return
    else
        -- str = string.format(TI18N("是否确认花费%s{assets_2, %s}购买{item_2, %s, 1, %s}，并获得%s次祈愿机会"), value[2], value[1], self.lossItemId, count, count)
        str = string.format(TI18N("是否确认花费%s{assets_2, %s}购买%s个{assets_2, %s}，并获得%s次祈愿机会"), value[2], value[1], count, self.lossItemId, count)
    end

    local dat = NoticeConfirmData.New()
    dat.type = ConfirmData.Style.Normal
    dat.content = str
    dat.cancelLabel = TI18N("返回")
    dat.sureCallback = function()
        -- self.mgr:Send21202(mode)
        self.model.prayTreasureMode = false
        self:StartRotation(mode)
    end
    NoticeManager.Instance:ConfirmTips(dat)
end

function PrayTreasureMainPanel:StartRotation(mode)
    local index = (((self.descIndex or 1) - 1) % 10 + 1)
    local s = 1 --记录发送协议时机
    local cycle = math.random(1, 9) + 10
    self.descIndex = nil --距离
    self.evilStatus = mode
    local fun = function()  
        if self.descIndex then
            if self.timerId then
                LuaTimer.Delete(self.timerId)
            end
        else
            index = index % 10 + 1
            self:ShowRotationEffect(index)
            self.currentIndex = index

            if s == cycle then
                self.mgr:Send21202(mode)
                self.evilStatus = 3
                s = s + 1
            elseif s < cycle then
                s = s + 1
            end
        end
    end
    if self.timerId then
        LuaTimer.Delete(self.timerId)
    end
    self.timerId = LuaTimer.Add(0, 50, fun)
end

function PrayTreasureMainPanel:RotationTimer(id)
    if id == 0 or id == -1 then
        if self.timerId then
            LuaTimer.Delete(self.timerId)
        end
        return
    end

    local index = 1
    for i , v in ipairs(self.itemList) do
        if v.data.id == id then
            index = i
            break
        end
    end
    local delta = index - self.currentIndex
    if delta <= 5 and delta > 0 then
        delta = delta + 10
    elseif delta <= 0 then
        delta = delta + 10 
    end
    self.descIndex = delta + self.currentIndex

    -- print("index" .. index)
    -- print("self.currentIndex:" .. self.currentIndex)
    -- print("delta:" .. delta)
    -- print("self.descIndex:" .. self.descIndex)

    local time = 50
    for i = self.currentIndex + 1, self.descIndex do
        time = time + (i / self.descIndex) * 500
        LuaTimer.Add(time, function() 
            local index = (i - 1) % 10 + 1 
            self:ShowRotationEffect(index)
            if i == self.descIndex then
                self:EndRotation()
            end
        end)
    end
end

function PrayTreasureMainPanel:ShowRotationEffect(index)
    if self.lastIndex and self.itemList[self.lastIndex] then
        self.itemList[self.lastIndex]:ShowEffect(false)
    end
    self.itemList[index]:ShowEffect(true)
    self.lastIndex = index
end

function PrayTreasureMainPanel:EndRotation()
    if self.descIndex then
        local desIndex = (self.descIndex - 1) % 10 + 1
        if self.itemList[desIndex] then
            self.itemList[desIndex]:ShowEffect(false)
            self.itemList[desIndex]:ShowEndEffect(true)
        end
    end
    LuaTimer.Add(500, function() 
        if self.evilStatus ~= 0 then
            self.evilStatus = 0
            self.mgr:Send21203()
        end
    end)
end



