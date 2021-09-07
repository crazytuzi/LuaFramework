--2016/07/31
--zzl
--每日礼包
BibleDailyGiftPanel = BibleDailyGiftPanel or BaseClass(BasePanel)

function BibleDailyGiftPanel:__init(model, parent)
    self.resList = {
        {file = AssetConfig.bible_daily_gift_panel, type = AssetType.Main}
        ,{file = AssetConfig.bible_daily_gfit_bg1, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- ,{file = AssetConfig.bible_daily_gfit_bg2, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = AssetConfig.button1, type = AssetType.Dep}
    }
    self.model = model
    self.parent = parent
    self.mgr = BibleManager.Instance
    self.itemList = nil
    self.timerId = 0
    self.openListener = function()
        -- BibleManager.Instance:send9933()

        if self.openArgs ~= self.model.lastSelect then
            self:Hiden()
            return
        end
        BibleManager.Instance.redPointDic[1][16] = false
        BibleManager.Instance.onUpdateRedPoint:Fire()
        self:StartTimer()
    end
    self.hideListener = function()
        self:StopTimer()
    end

    self.OnHideEvent:AddListener(self.hideListener)
    self.OnOpenEvent:AddListener(self.openListener)
    self.OnUpdateInfo = function(data)
        self:UpdateInfo(data)
    end
end

function BibleDailyGiftPanel:__delete()
    self:StopTimer()
    -- self.transform:Find("TopCon"):Find("ImgBg"):GetComponent(Image).sprite = nil
    -- self.transform:Find("ImgBigBg"):GetComponent(Image).sprite = nil
    if self.itemList ~= nil then
        for i=1,#self.itemList do
            local item = self.itemList[i]
            item.slot:DeleteMe()
        end
    end

    EventMgr.Instance:RemoveListener(event_name.update_cash_gift_info, self.OnUpdateInfo)
    self.itemList = nil
    self.is_open  =  false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function BibleDailyGiftPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_daily_gift_panel))
    self.gameObject:SetActive(false)
    self.gameObject.name = "DailyGiftPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    self.transform:Find("TopCon/ImgBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_daily_gfit_bg1, "DailyGiftBg")
    -- self.transform:Find("ImgBigBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_daily_gfit_bg2, "DailyGiftBigBg")

    local Bottom = self.transform:FindChild("Bottom")
    self.itemList = {}
    for i=1,3 do
        local temp = Bottom:FindChild(string.format("Item%s",i))
        local item = self:CreateBottomItem(temp, i)
        table.insert(self.itemList, item)
    end

    local TimeCon = self.transform:FindChild("TimeCon")
    self.TimeHour = TimeCon:FindChild("TimeHour"):FindChild("HourText"):GetComponent(Text)
    self.TimeMin = TimeCon:FindChild("TimeMin"):FindChild("MinText"):GetComponent(Text)
    self.TimeSec = TimeCon:FindChild("TimeSec"):FindChild("SecText"):GetComponent(Text)

    EventMgr.Instance:AddListener(event_name.update_cash_gift_info, self.OnUpdateInfo)

    BibleManager.Instance.redPointDic[1][16] = false
    BibleManager.Instance.onUpdateRedPoint:Fire()
    self:UpdateInfo()
    self:StartTimer()
end

--更新界面显示
function BibleDailyGiftPanel:UpdateInfo()
    local data = self.model.bibleDailyGiftSocketData
    local temp_dic = {}
    for i=1,#data.rewards do
        local socket_data = data.rewards[i]
        temp_dic[socket_data.group] = socket_data
    end

    local temp_list = {}
    for i=1, #DataChargeGift.data_cash_gift do
        local cfg_data = DataChargeGift.data_cash_gift[i]
        if cfg_data.min <= RoleManager.Instance.RoleData.lev and cfg_data.max >= RoleManager.Instance.RoleData.lev then
            table.insert(temp_list, cfg_data)
        end
    end

    table.sort(temp_list, function(a,b)
        return a.gold < b.gold
    end)

    for i=1,#self.itemList do
        local cfg_data = temp_list[i]
        local item = self.itemList[i]
        self:SetBottomItem(item, cfg_data)
        if temp_dic[cfg_data.group] == nil then
            self:SetItemBuyState(item, false)
        else
            self:SetItemBuyState(item, true)
        end
    end
end

--为底部每个item创建一个table
function BibleDailyGiftPanel:CreateBottomItem(itemTransform, index)
    local item = {}
    item.buyState = false
    item.index = index
    item.transform = itemTransform
    item.gameObject = itemTransform.gameObject
    item.SlotCon = itemTransform:FindChild("SlotCon").gameObject
    item.slot = self:CreatSlot(item.SlotCon)
    item.TxtCostI18N = itemTransform:FindChild("TxtCostI18N"):GetComponent(Text)
    item.BtnTxt = itemTransform:FindChild("Button"):FindChild("Text"):GetComponent(Text)
    item.Btn = itemTransform:FindChild("Button"):GetComponent(Button)
    item.Btn.onClick:AddListener(function()
        if item.buyState then
            --已经购买过
            NoticeManager.Instance:FloatTipsByString(TI18N("今日已经购买过"))
            return
        end
        self:OnClickBottomBtn(item)
    end)
    return item
end

--为item设置数据
function BibleDailyGiftPanel:SetBottomItem(item, data)
    item.data = data
    item.BtnTxt.text = string.format("%s%s", data.gold/10, TI18N("元购买"))
    local baseData = DataItem.data_get[data.list[1][1]]
    self:SetSlotData(item.slot, baseData, true)
end

--设置item的购买状态
function BibleDailyGiftPanel:SetItemBuyState(item, state)
    item.buyState = state
    if state then
        --已经买过
        item.BtnTxt.text = TI18N("已购买")
        item.BtnTxt.color = ColorHelper.DefaultButton4
        item.Btn.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    else
        item.BtnTxt.color = ColorHelper.DefaultButton3
        item.Btn.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    end
end

--为每个武器创建slot
function BibleDailyGiftPanel:CreatSlot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con.transform)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

--对slot设置数据
function BibleDailyGiftPanel:SetSlotData(slot, data, nobutton)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if nobutton == nil then
        slot:SetAll(cell, {nobutton = true})
    else
        slot:SetAll(cell, {nobutton = nobutton})
    end
end


function BibleDailyGiftPanel:OnClickBottomBtn(item)
    if item.data.charge_gold <= PrivilegeManager.Instance.charge then
        --够
        if SdkManager.Instance:RunSdk() then
            -- SdkManager.Instance:ShowChargeView(string.format("StardustRomance3K%s0", tostring(item.data.gold/10)), item.data.gold/10, (item.data.gold/10) * 10, "3")
            SdkManager.Instance:ShowChargeView(ShopManager.Instance.model:GetSpecialChargeData(item.data.gold), item.data.gold/10, (item.data.gold/10) * 10, "3")
        end
    else
        local baseData = DataItem.data_get[item.data.list[1][1]]
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.sureLabel = TI18N("立刻充值")
        data.cancelLabel = TI18N("稍后再充")
        data.showSureEffect = true
        data.sureCallback = function()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
        end
        data.content = string.format("%s<color='#2fc823'>%s</color>{assets_2, 90002}%s<color='#ffff00'>%s</color>%s，超值哦{face_1,29}", TI18N("累充"), item.data.charge_gold, TI18N("可获得购买"), baseData.name, TI18N("福利"))

        NoticeManager.Instance:ConfirmTips(data)
    end
end

------计时器逻辑
function BibleDailyGiftPanel:StartTimer()
    self:StopTimer()
    self.timerId = LuaTimer.Add(0, 1000, function() self:TimerTick() end)
end

function BibleDailyGiftPanel:StopTimer()
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
end

function BibleDailyGiftPanel:TimerTick()
    local timeLeft = self.model.bibleDailyGiftSocketData.max_time - (self.model.bibleDailyGiftSocketData.keep_time + (BaseUtils.BASE_TIME - math.max(self.model.bibleDailyGiftSocketData.login_time,self.model.bibleDailyGiftSocketData.start_time))) - self.model.billeDailyGiftDebugTime
    if timeLeft <= 0 then
        self:StopTimer()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {})
    else
        local _, myHour, myMinute, mySecond = BaseUtils.time_gap_to_timer(timeLeft)
        myHour = myHour >= 10 and tostring(myHour) or string.format("0%s", myHour)
        myMinute = myMinute >= 10 and tostring(myMinute) or string.format("0%s", myMinute)
        mySecond = mySecond >= 10 and tostring(mySecond) or string.format("0%s", mySecond)
        self.TimeHour.text = myHour
        self.TimeMin.text = myMinute
        self.TimeSec.text = mySecond
    end
end
