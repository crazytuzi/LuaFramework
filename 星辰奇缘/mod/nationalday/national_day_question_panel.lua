--2016/9/24
--zzl
--国庆智多星
NationalDayQuestionPanel = NationalDayQuestionPanel or BaseClass(BasePanel)

function NationalDayQuestionPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = BibleManager.Instance

    self.resList = {
        {file = AssetConfig.national_day_question_panel, type = AssetType.Main}
        ,{file = AssetConfig.nationaquestionbg, type = AssetType.Main}
        ,{file = AssetConfig.guidesprite, type = AssetType.Main}
    }
    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.timerId = 0
end

function NationalDayQuestionPanel:__delete()
    self:StopTimer()
    self.OnHideEvent:Fire()
    if self.slotList ~= nil then
        for i = 1, #self.slotList do
            self.slotList[i].slot:DeleteMe()
        end
        self.slotList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function NationalDayQuestionPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.national_day_question_panel))
    self.gameObject.name = "NationalDayQuestionPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.RightCon)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.one

    self.ImgTop = self.transform:Find("ImgTop")
    -- self.ImgTop:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.nationaquestionbg, "nationaldayi18n3")
    self.ImgTop:GetComponent(Image).enabled = false
    local obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.nationaquestionbg))
    UIUtils.AddBigbg(self.ImgTop.transform, obj)
    obj.transform:SetAsFirstSibling()

    self.TimeTxt = self.ImgTop:Find("TimeTxt"):GetComponent(Text)
    self.TxtDesc = self.transform:Find("ImgTxtDescBg"):Find("TxtDescI18N"):GetComponent(Text)
    self.ImgTop.gameObject:SetActive(true)
    local ImgMM = self.transform:Find("ImgMM")
    ImgMM:GetComponent(Image).sprite =self.assetWrapper:GetSprite(AssetConfig.guidesprite, "guidesprite")
    ImgMM.gameObject:SetActive(true)

    local TimeCon = self.transform:FindChild("BottomCon"):FindChild("TimeCon")
    TimeCon.gameObject:SetActive(false)
    self.TimeHour = TimeCon:FindChild("TimeHour"):FindChild("HourText"):GetComponent(Text)
    self.TimeMin = TimeCon:FindChild("TimeMin"):FindChild("MinText"):GetComponent(Text)
    self.TimeSec = TimeCon:FindChild("TimeSec"):FindChild("SecText"):GetComponent(Text)

    local cfgData = DataCampaign.data_list[329]
    self.TimeTxt.text = string.format(TI18N("%s年%s月%s号~%s年%s月%s号"), cfgData.cli_start_time[1][1], cfgData.cli_start_time[1][2], cfgData.cli_start_time[1][3], cfgData.cli_end_time[1][1], cfgData.cli_end_time[1][2], cfgData.cli_end_time[1][3])

    local msgTxt = MsgItemExt.New(self.TxtDesc, 418, 16, 21)
    msgTxt:SetData(DataCampaign.data_list[329].cond_desc)

    local rewards = DataCampaign.data_list[329].reward
    self.Container = self.transform:Find("ImgTxtDescBg"):Find("MaskCon"):Find("ScrollCon"):Find("Container")
    local slotCon = self.Container:Find("SlotCon1").gameObject
    self.slotList = {}
    for i = 1, #rewards do
        local slotTab = self:CreateSlotCon(i, rewards[i], slotCon)
        table.insert(self.slotList, slotTab)
    end
    local newW = 75*#rewards
    self.Container:GetComponent(RectTransform).sizeDelta = Vector2(newW, 60)

    -- self.leftTime = 150000
    -- self:StartTimer()
end

--创建一个slotTab的表
function NationalDayQuestionPanel:CreateSlotCon(index, data, go)
    local slotTab = {}
    slotTab.gameObject = GameObject.Instantiate(go)
    slotTab.transform = slotTab.gameObject.transform
    slotTab.transform:SetParent(self.Container)
    slotTab.transform.localScale = Vector3.one
    slotTab.gameObject:SetActive(true)

    slotTab.slot = self:CreateEquipSlot(slotTab.transform)
    local baseData = DataItem.data_get[data[1]]
    self:SetStoneSlotData(slotTab.slot, baseData)
    slotTab.slot:SetNum(data[2])
    slotTab.transform.localPosition = Vector3.one
    slotTab.transform.localScale = Vector3.one
    local newX = (index - 1)*75
    local rect = slotTab.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(newX, 0)
    return slotTab
end

function NationalDayQuestionPanel:CreateEquipSlot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con)
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
function NationalDayQuestionPanel:SetStoneSlotData(slot, data, _nobutton)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if nobutton == nil then
        slot:SetAll(cell, {_nobutton = true})
    else
        slot:SetAll(cell, {nobutton = _nobutton})
    end
end

function NationalDayQuestionPanel:OnOpen()

end

function NationalDayQuestionPanel:OnHide()

end

------计时器逻辑
function NationalDayQuestionPanel:StartTimer()
    self:StopTimer()
    self.timerId = LuaTimer.Add(0, 1000, function() self:TimerTick() end)
end

function NationalDayQuestionPanel:StopTimer()
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
end

function NationalDayQuestionPanel:TimerTick()
    self.leftTime = self.leftTime - 1
    if self.leftTime <= 0 then
        self:StopTimer()
    else
        local _, myHour, myMinute, mySecond = BaseUtils.time_gap_to_timer(self.leftTime)
        myHour = myHour >= 10 and tostring(myHour) or string.format("0%s", myHour)
        myMinute = myMinute >= 10 and tostring(myMinute) or string.format("0%s", myMinute)
        mySecond = mySecond >= 10 and tostring(mySecond) or string.format("0%s", mySecond)
        self.TimeHour.text = myHour
        self.TimeMin.text = myMinute
        self.TimeSec.text = mySecond
    end
end

