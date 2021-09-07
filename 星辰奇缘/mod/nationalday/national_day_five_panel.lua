--2016/9/21
--zzl
--国庆五环任务
NationalDayFivePanel = NationalDayFivePanel or BaseClass(BasePanel)

function NationalDayFivePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = BibleManager.Instance

    self.resList = {
        {file = AssetConfig.national_day_five_panel, type = AssetType.Main}
        -- ,{file = AssetConfig.nationafivebg, type = AssetType.Main}
    }
    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
    self.openDay = {
        [9] = {[30] = true}
        ,[10] = {[2] = true ,[4] = true ,[6] = true}
    }
    self.hasInit = false
end

function NationalDayFivePanel:__delete()
    self.hasInit = false
    for i = 1, #self.slotList do
        self.slotList[i].slot:DeleteMe()
    end
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function NationalDayFivePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.national_day_five_panel))
    self.gameObject.name = "NationalDayFivePanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.one

    self.ImgTop = self.transform:Find("ImgTop")

    -- self.ImgTop:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.nationafivebg, "nationaldayi18n2")

    -- local obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.nationafivebg))
    -- UIUtils.AddBigbg(self.ImgTop.transform, obj)
    -- obj.transform:SetAsFirstSibling()


    self.TimeTxt = self.ImgTop:Find("TimeTxt"):GetComponent(Text)
    self.TxtDesc = self.transform:Find("TxtDesc"):GetComponent(Text)
    self.ImgTop.gameObject:SetActive(true)

    self.BottomCon = self.transform:Find("BottomCon")
    self.MaskCon = self.BottomCon:Find("MaskCon")
    self.ScrollCon = self.MaskCon:Find("ScrollCon")
    self.Container = self.ScrollCon:Find("Container")
    self.SlotCon = self.Container:Find("SlotCon")
    self.BtnGo = self.BottomCon:Find("BtnGo"):GetComponent(Button)
    self.BtnGoTxt = self.BottomCon:Find("BtnGo"):Find("Text"):GetComponent(Text)

    self.BtnGo.onClick:AddListener(
        function()
            if self:CheckOpen() then
                local key = BaseUtils.get_unique_npcid(65, 1)
                SceneManager.Instance.sceneElementsModel:Self_AutoPath(10001, key, nil, nil, true)
                self.model:CloseMainUI()
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("今天未开启五彩遍山河哦，去参加蛋糕欢乐送吧"))
            end
        end
    )

    local cfgData = DataCampaign.data_list[328]
    self.TimeTxt.text = string.format(TI18N("%s年%s月%s号~%s年%s月%s号"), cfgData.cli_start_time[1][1], cfgData.cli_start_time[1][2], cfgData.cli_start_time[1][3], cfgData.cli_end_time[1][1], cfgData.cli_end_time[1][2], cfgData.cli_end_time[1][3])
    local msgTxt = MsgItemExt.New(self.TxtDesc, 529, 16, 21)
    msgTxt:SetData(TI18N("<color='#ffff00'>庆典使用的气球被一伙来历不明的人抢走了，组起来一起去夺回五彩气球吧，给他们点颜色瞧瞧</color>{face_1,30}\n\n1、<color='#00ff00'>30级</color>以上组成<color='#00ff00'>三人以上</color>队伍即可参与挑战\n3、每次任务<color='#00ff00'>共5环</color>，成功完成即可获得奖励\n3、活动时间为<color='#00ff00'>30号、2号、4号、6号</color>的<color='#00ff00'>9：00~23：30</color>，奖励丰厚，不要错过哦！"))

    local newW = 70*#cfgData.reward
    self.Container:GetComponent(RectTransform).sizeDelta = Vector2(newW, 60)
    self.slotList = {}
    for i = 1, #cfgData.reward do
        local slotTab = self:CreateSlotCon(i, cfgData.reward[i])
        table.insert(self.slotList, slotTab)
    end
    self.hasInit = true
    self:OnOpen()
end

--创建一个slotTab的表
function NationalDayFivePanel:CreateSlotCon(index, data)
    local slotTab = {}
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
    local newX = (index - 1)*70
    local rect = slotTab.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(newX, 0)
    return slotTab
end

function NationalDayFivePanel:CreateEquipSlot(slot_con)
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
function NationalDayFivePanel:SetStoneSlotData(slot, data, _nobutton)
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

--检查是否已经开启
function NationalDayFivePanel:CheckOpen()
    local y = tonumber(os.date("%y", BaseUtils.BASE_TIME)) + 2000
    local m = tonumber(os.date("%m", BaseUtils.BASE_TIME))
    local d = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    local state = false

    for k, v in pairs(DataBraveTrival.data_fight) do
        if v.day[1][1] == y and v.day[1][2] == m and v.day[1][3] == d then
            state = true
            break
        end
    end
    return state
end

function NationalDayFivePanel:OnOpen()
    if self.hasInit == false then
        return
    end
    if self:CheckOpen() then
        self.BtnGoTxt.text = TI18N("前往挑战")
    else
        self.BtnGoTxt.text = TI18N("未开启")
    end
end

function NationalDayFivePanel:OnHide()

end



