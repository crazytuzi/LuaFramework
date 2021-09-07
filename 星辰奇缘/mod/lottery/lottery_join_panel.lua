-- ---------------------------------------
-- 一闷夺宝参与界面
-- hosr
-- ---------------------------------------
LotteryJoinPanel = LotteryJoinPanel or BaseClass(BasePanel)

function LotteryJoinPanel:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.lottery_join, type = AssetType.Main},
        {file = AssetConfig.lottery_res, type = AssetType.Dep},
        {file = AssetConfig.stongbg, type = AssetType.Dep},
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.btnOption = {
        [1] = 10,
        [2] = 50,
        [3] = 100
    }

    self.count = 1
    self.holdTimeId = nil
end

function LotteryJoinPanel:__delete()
    if self.holdTimeId ~= nil then
        LuaTimer.Delete(self.holdTimeId)
        self.holdTimeId = nil
    end
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
end

function LotteryJoinPanel:OnShow()
    self.data = self.openArgs
    self:SetData()
end

function LotteryJoinPanel:Close()
    self.model:CloseJoinPanel()
end

function LotteryJoinPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.lottery_join))
    self.gameObject.name = "LotteryJoinPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    -- 大图 hosr
    self.transform:Find("Main/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Main/InfoBtn"):GetComponent(Button).onClick:AddListener(function() self:OnClickInfo() end)

    self.slider = self.transform:Find("Main/Slider"):GetComponent(Slider)
    self.slider.value = 0

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("Main/Slot").gameObject, self.slot.gameObject)

    self.name = self.transform:Find("Main/Name"):GetComponent(Text)
    self.desc = self.transform:Find("Main/Desc"):GetComponent(Text)
    self.need = self.transform:Find("Main/Need"):GetComponent(Text)
    self.remain = self.transform:Find("Main/Remain"):GetComponent(Text)

    local option = self.transform:Find("Main/Option")
    self.price = MsgItemExt.New(option:Find("Price"):GetComponent(Text), 160, 18)
    self.allprice = MsgItemExt.New(option:Find("AllPrice"):GetComponent(Text), 250, 18)
    self.value = option:Find("Val/Text"):GetComponent(InputField)
    self.valueText = option:Find("Val/Text/Text"):GetComponent(Text)
    self.value.onValueChange:AddListener(function() self:ValueChange() end)
    option:Find("Minus"):GetComponent(CustomButton).onClick:AddListener(function() self:OnClickMinus() end)
    option:Find("Minus"):GetComponent(CustomButton).onUp:AddListener(function() self:OnUpMinus() end)
    option:Find("Minus"):GetComponent(CustomButton).onHold:AddListener(function() self:OnHoldMinus() end)

    option:Find("Plus"):GetComponent(CustomButton).onClick:AddListener(function() self:OnClickPlus() end)
    option:Find("Plus"):GetComponent(CustomButton).onUp:AddListener(function() self:OnUpPlus() end)
    option:Find("Plus"):GetComponent(CustomButton).onHold:AddListener(function() self:OnHoldPlus() end)

    self.setobj = option:Find("Setting").gameObject
    self.valObj = option:Find("Val").gameObject
    option:Find("Setting"):GetComponent(Button).onClick:AddListener(function() self:OpenNumpad() end)

    self.valBtn = option:Find("Val"):GetComponent(Button)
    self.valBtn.onClick:AddListener(function() self:OpenNumpad() end)
    option:Find("JoinButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickJoin() end)

    self.BottomQuickBtn = self.transform:Find("Main/BottomQuickBtn")
    self.Btn5 = self.BottomQuickBtn:Find("Btn5"):GetComponent(Button)
    self.Btn10 = self.BottomQuickBtn:Find("Btn10"):GetComponent(Button)
    self.Btn15 = self.BottomQuickBtn:Find("Btn15"):GetComponent(Button)
    self.Btn20 = self.BottomQuickBtn:Find("Btn20"):GetComponent(Button)
    self.Btn5.onClick:AddListener(function() self.value.text = tostring(self.btnOption[1]) end)
    self.Btn10.onClick:AddListener(function() self.value.text = tostring(self.btnOption[2]) end)
    self.Btn15.onClick:AddListener(function() self.value.text = tostring(self.btnOption[3]) end)
    self.Btn20.onClick:AddListener(function() self.value.text = tostring(20) end)

    self.Btn5Txt = self.BottomQuickBtn:Find("Btn5"):Find("Text"):GetComponent(Text)
    self.Btn10Txt = self.BottomQuickBtn:Find("Btn10"):Find("Text"):GetComponent(Text)
    self.Btn15Txt = self.BottomQuickBtn:Find("Btn15"):Find("Text"):GetComponent(Text)
    self.Btn5Txt.text = tostring(self.btnOption[1])
    self.Btn10Txt.text = tostring(self.btnOption[2])
    self.Btn15Txt.text = tostring(self.btnOption[3])

    self:OnShow()
end

function LotteryJoinPanel:OnClickInfo()
end

function LotteryJoinPanel:OnClickMinus()
    if self.count > 1 then
        self.count = self.count - 1
        self.value.text = tostring(self.count)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("最小参与人次为1"))
        self:OnUpMinus()
    end
end

function LotteryJoinPanel:OnHoldMinus()
    self:OnUpMinus()
    self.holdTimeId = LuaTimer.Add(0, 50, function() self:OnClickMinus() end)
end

function LotteryJoinPanel:OnUpMinus()
    if self.holdTimeId ~= nil then
        LuaTimer.Delete(self.holdTimeId)
        self.holdTimeId = nil
    end
end

function LotteryJoinPanel:OnClickPlus()
    if self.count > (self.data.times_sum - self.data.times_now) then
        self.count = tostring(self.data.times_sum - self.data.times_now)
        NoticeManager.Instance:FloatTipsByString(TI18N("不能超过最大人次"))
        self:OnUpPlus()
        return
    end
    self.count = self.count + 1
    self.value.text = tostring(self.count)
end

function LotteryJoinPanel:OnHoldPlus()
    self:OnUpPlus()
    self.holdTimeId = LuaTimer.Add(0, 50, function() self:OnClickPlus() end)
end

function LotteryJoinPanel:OnUpPlus()
    if self.holdTimeId ~= nil then
        LuaTimer.Delete(self.holdTimeId)
        self.holdTimeId = nil
    end
end

function LotteryJoinPanel:OpenNumpad()
    NumberpadManager.Instance:set_data(self.numberpadSetting)
end

function LotteryJoinPanel:OnClickJoin()
    self.count = tonumber(self.value.text)
    LotteryManager.Instance:Send16902(self.data.idx, self.data.item_idx, self.count)
    self:Close()
end

function LotteryJoinPanel:ValueChange()
    if tonumber(self.value.text) == nil then
        self.value.text = "1"
    else
        if tonumber(self.value.text) > (self.data.times_sum - self.data.times_now) then
            self.value.text = tostring(self.data.times_sum - self.data.times_now)
            NoticeManager.Instance:FloatTipsByString(TI18N("已包下所有剩余次数{face_1,31}"))
        end
    end
    self.count = tonumber(self.value.text)
    self.allprice:SetData(string.format("%s:{assets_1,%s,%s}", TI18N("总消耗"), self.data.gold_type, tonumber(self.value.text) * self.data.gold_once))
end

function LotteryJoinPanel:SetData()
    self.itemData = ItemData.New()
    self.itemData:SetBase(BaseUtils.copytab(DataItem.data_get[self.data.item_id]))
    self.itemData.quantity = self.data.item_count
    self.slot:SetAll(self.itemData)

    self.name.text = ColorHelper.color_item_name(self.itemData.quality, self.itemData.name)
    self.need.text = string.format(TI18N("总需:<color='#00ff00'>%s</color>"), self.data.times_sum)
    self.remain.text = string.format(TI18N("剩余:<color='#00ff00'>%s</color>"), self.data.times_sum - self.data.times_now)
    self.price:SetData(string.format(TI18N("{assets_1,%s,%s}/人次"), self.data.gold_type, self.data.gold_once))
    self.allprice:SetData(string.format("%s:{assets_1,%s,%s}", TI18N("总消耗"), self.data.gold_type, tonumber(self.value.text) * self.data.gold_once))
    self.value.text = tostring(self.count)
    self.valueText.text = tostring(self.count)

    self.slider.value = self.data.times_now / self.data.times_sum

    self:NumberpadSetting()
end

function LotteryJoinPanel:NumberpadSetting()
    self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = self.valBtn.gameObject,
        min_result = 1,
        max_by_asset = self.data.times_sum - self.data.times_now,
        max_result = self.data.times_sum - self.data.times_now,
        textObject = self.value,
        show_num = false,
        -- funcReturn = function() NoticeManager.Instance:FloatTipsByString(TI18N("请确认购买")) end,
        -- callback = self.updatePrice
    }
end