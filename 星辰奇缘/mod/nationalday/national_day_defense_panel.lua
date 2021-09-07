-- 2016/9/22
-- xjlong
-- 保卫蛋糕
NationalDefensePanel = NationalDefensePanel or BaseClass(BasePanel)

function NationalDefensePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = NationalDayManager.Instance

    self.resList = {
        { file = AssetConfig.national_day_defense_panel, type = AssetType.Main },
        { file = AssetConfig.national_day_i18n1, type = AssetType.Main },
    }

    self.hasInit = false

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
    EventMgr.Instance:AddListener(event_name.nationalday_defense_update, self.openListener)
end

function NationalDefensePanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end

    if self.completeTimerId ~= nil then
        LuaTimer.Delete(self.completeTimerId)
    end

    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.slotList ~= nil then
        for k, v in pairs(self.slotList) do
            v.slot:DeleteMe()
        end
    end
    self.slotList = nil
    self:AssetClearAll()
    EventMgr.Instance:RemoveListener(event_name.nationalday_defense_update, self.openListener)
end

function NationalDefensePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.national_day_defense_panel))
    self.gameObject.name = "NationalDefensePanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.RightCon)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.CountSlider = self.transform:Find("CountSlider"):GetComponent(Slider)
    self.CountValue = self.CountSlider.transform:Find("Value"):GetComponent(Text)
    self.CountSliderText = self.CountSlider.transform:Find("Text"):GetComponent(Text)

    self.ImgTop = self.transform:Find("ImgTop")
    self.TimeTxt = self.transform:Find("TimeTxt"):GetComponent(Text)
    self.TxtDesc = self.transform:Find("TxtDesc"):GetComponent(Text)

    self.ResoultInfo = self.transform:Find("ResoultInfo")
    self.NextTimeDesc = self.ResoultInfo:Find("NextTime/NextTimeDesc"):GetComponent(Text)

    self.CompleteInfo = self.transform:Find("CompleteInfo")
    self.CompleteInfoDesc = self.CompleteInfo:Find("CompleteDesc"):GetComponent(Text)
    self.CompleteTimeDesc = self.CompleteInfo:Find("CompleteTime/CompleteTimeDesc"):GetComponent(Text)
    self.CompleteInfo.gameObject:SetActive(false)

    self.BottomCon = self.transform:Find("BottomCon")
    self.MaskCon = self.BottomCon:Find("MaskCon")
    self.ScrollCon = self.MaskCon:Find("ScrollCon")
    self.Container = self.ScrollCon:Find("Container")
    self.SlotCon = self.Container:Find("SlotCon")
    self.BtnGo = self.BottomCon:Find("BtnGo"):GetComponent(Button)
    self.BtnNone = self.BottomCon:Find("BtnNone"):GetComponent(Button)
    self.ReaminCount = self.BottomCon:Find("ReaminCount"):GetComponent(Text)

    self.BtnGo.onClick:AddListener(
    function()
        local key = BaseUtils.get_unique_npcid(65, 1)
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(10001, key, nil, nil, true)
        self.model:CloseMainUI()
    end
    )

    self.BtnNone.onClick:AddListener(
    function()
        NoticeManager.Instance:FloatTipsByString(TI18N("今天没有开启蛋糕欢乐送哦，去参加五彩遍山河吧"))
    end
    )

    self.infoBtn = self.transform:FindChild("InfoBtn")
    self.infoBtn:GetComponent(Button).onClick:AddListener( function()
        TipsManager.Instance:ShowText( {
            gameObject = self.infoBtn.gameObject,
            itemData =
            {
                TI18N("1.活动开启日每位玩家当日可完成<color='#00ff00'>2</color>轮护送蛋糕，成功护送后会获得<color='#ffff00'>奖励</color>并增加<color='#ffff00'>节日祝福值</color> "),
                TI18N("2.当完成<color='#00ff00'>2</color>轮护送后有几率接到<color='#ffff00'>特殊护送</color>任务，获得奖励更加丰厚{face_1,56} "),
                TI18N("3.当祝福值达到<color='#00ff00'>1000</color>点后，<color='#ffff00'>所有完成护送</color>的小伙伴都会获得国庆大使分享的<color='#ffff00'>水果蛋糕</color> "),
                TI18N("4.祝福值未满<color='#00ff00'>1000</color>点时，可延续至下次活动直至祝福值积满")
            }
        } )
    end )

    local obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.national_day_i18n1))
    UIUtils.AddBigbg(self.ImgTop, obj)
    obj.transform:SetAsFirstSibling()

    local cfgData = DataCampaign.data_list[327]
    self.TimeTxt.text = cfgData.timestr

    self.descExt = MsgItemExt.New(self.TxtDesc, 280, 16, 21)
    self.descExt:SetData(cfgData.content)

    self.CountSliderText.text = TI18N("当前节日祝福值:")

    local newW = 72 * #cfgData.reward
    self.Container:GetComponent(RectTransform).sizeDelta = Vector2(newW, 60)
    self.slotList = { }
    for i = 1, #cfgData.reward do
        local slotTab = self:CreateSlotCon(i, cfgData.reward[i])
        table.insert(self.slotList, slotTab)
    end

    self.hasInit = true
    self:OnOpen()
end

-- 创建一个slotTab的表
function NationalDefensePanel:CreateSlotCon(index, data)
    local slotTab = { }
    slotTab.gameObject = GameObject.Instantiate(self.SlotCon.gameObject)
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
    local newX =(index - 1) * 70
    local rect = slotTab.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(newX, 0)
    return slotTab
end

function NationalDefensePanel:CreateEquipSlot(slot_con)
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

-- 对slot设置数据
function NationalDefensePanel:SetStoneSlotData(slot, data, _nobutton)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if nobutton == nil then
        slot:SetAll(cell, { _nobutton = true })
    else
        slot:SetAll(cell, { nobutton = _nobutton })
    end
end

function NationalDefensePanel:OnOpen()
    if self.hasInit == false or self.model.defense_data == nil or self.model.defensecake_data == nil then return end

    local timeNow = BaseUtils.BASE_TIME
    local isOpen = false
    local isPreComplete = self.model.defense_data.finish == 1
    for i, v in ipairs(DataCampCake.data_base_time) do
        local openTime = v.st[1]
        local endTime = v.et[1]
        local openTimeTemp = os.time { year = openTime[1], month = openTime[2], day = openTime[3], hour = openTime[4], min = openTime[5], sec = openTime[6] }
        local endTimeTemp = os.time { year = endTime[1], month = endTime[2], day = endTime[3], hour = endTime[4], min = endTime[5], sec = endTime[6] }
        if timeNow >= openTimeTemp and timeNow < endTimeTemp then
            isOpen = true
            break
        end
    end

    if isOpen then
        self.ResoultInfo.gameObject:SetActive(false)
        self.CountSlider.gameObject:SetActive(true)

        self.BtnGo.gameObject:SetActive(true)
        self.BtnNone.gameObject:SetActive(false)
        self.ReaminCount.gameObject:SetActive(true)

        local count = self.model.defensecake_data.max - self.model.defensecake_data.times
        if count == 0 then
            self.ReaminCount.text = string.format("(<color='#ff0000'>%s</color>/%s)", count, self.model.defensecake_data.max)
        else
            self.ReaminCount.text = string.format("(%s/%s)", count, self.model.defensecake_data.max)
        end

        local curCount = self.model.defense_data.cake
        local maxCount = self.model.defense_data.max
        if maxCount == 0 then
            self.CountSlider.value = 0
        else
            self.CountSlider.value = curCount / maxCount
        end
        self.CountValue.text = curCount .. "/" .. maxCount
    else
        self.CountSlider.gameObject:SetActive(false)
        self.ResoultInfo.gameObject:SetActive(true)

        self.BtnGo.gameObject:SetActive(false)
        self.BtnNone.gameObject:SetActive(true)
        self.ReaminCount.gameObject:SetActive(false)

        local minTime = 99999999
        local msg = ""
        for i, v in ipairs(DataCampCake.data_base_time) do
            local openTime = v.st[1]
            local targetTime = os.time { year = openTime[1], month = openTime[2], day = openTime[3], hour = openTime[4], min = openTime[5], sec = openTime[6] }
            if targetTime > timeNow and(i == 1 or targetTime - timeNow < minTime) then
                minTime = targetTime - timeNow
                msg = string.format(TI18N("%s月%s日%s时"), openTime[2], openTime[3], openTime[4])
            end
        end

        self.NextTimeDesc.text = msg
    end
end

function NationalDefensePanel:OnHide()

end

function NationalDefensePanel:DoResoultCountDown()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self.timerId = LuaTimer.Add(0, 1000, function(id) self:RefreshNextTime(id) end)
end

function NationalDefensePanel:RefreshNextTime(id)
    local timeNow = os.date("*t", BaseUtils.BASE_TIME)
    local msg = BaseUtils.formate_time_gap(0, "", 1, BaseUtils.time_formate.HOUR)

    local isOpen = false
    for i, v in ipairs(DataCampCake.data_base_time) do
        local openTime = v.st[1]
        if openTime[1] == timeNow.year and openTime[2] == timeNow.month and openTime[3] == timeNow.day and timeNow.hour > 5 then
            isOpen = true
            break
        end
    end

    if isOpen then
        LuaTimer.Delete(self.timerId)
    else
        local minTime = 0
        for i, v in ipairs(DataCampCake.data_base_time) do
            local openTime = v.st[1]
            local targetTime = os.time { year = openTime[1], month = openTime[2], day = openTime[3], hour = openTime[4], min = openTime[5], sec = openTime[6] }
            if i == 1 or(targetTime > BaseUtils.BASE_TIME and targetTime - BaseUtils.BASE_TIME < minTime) then
                minTime = targetTime - BaseUtils.BASE_TIME
            end
        end

        msg = BaseUtils.formate_time_gap(minTime, "", 1, BaseUtils.time_formate.HOUR)
        -- msg = os.date("%H:%M:%S", time)
    end
    self.NextTimeDesc.text = msg
end


function NationalDefensePanel:DoCompleteCountDown()
    if self.completeTimerId ~= nil then
        LuaTimer.Delete(self.completeTimerId)
    end
    self.completeTimerId = LuaTimer.Add(0, 1000, function(id) self:RefreshCompleteTime(id) end)
end

function NationalDefensePanel:RefreshCompleteTime(id)
    local remainTime = self.model.defense_data.refre_time - BaseUtils.BASE_TIME
    local msg = "00:00"

    if remainTime <= 0 then
        LuaTimer.Delete(self.completeTimerId)
    else
        msg = os.date("%M:%S", remainTime)
    end
    self.CompleteTimeDesc.text = msg
end
