BibleLevelupPanel = BibleLevelupPanel or BaseClass(BasePanel)

function BibleLevelupPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = BibleManager.Instance

    self.resList = {
        {file = AssetConfig.bible_levelup_panel, type = AssetType.Main}
        , {file = AssetConfig.shop_textures, type = AssetType.Dep}
    }

    self.levelupItemGrid = {nil, nil, nil}
    self.levelupItemList = {nil, nil, nil}
    self.levelupItemRect = {}
    self.levelupItemTitle = {}
    self.levelupItemTitle2 = {}
    self.levelupItemTitle2TimeText = {}
    self.levelupItemTitle2OriginText = {}
    self.levelupItemTitle2NowText = {}
    self.levelupItemTitle2OriginImage = {}
    self.levelupItemTitle2NowImage = {}
    self.levelupItemTitle2Text = {}
    self.levelupItemTitleText = {}
    self.levelupItemTitleButtonRect = {}
    self.levelupItemTitle2ButtonRect = {}
    self.levelupItemTitleButtonText = {}
    self.levelupItemTitleButtonImage = {}
    self.levelupItemTitleButton = {}
    self.levelupItemTitle2Button = {}
    self.levelupItemIconList = {nil, nil, nil}
    self.slotList = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function() self:UpdateLevelup() end

    self.backpackItemChangeListener = function(items)
        local itemDic = BackpackManager.Instance.itemDic
        if self.usebackpackBaseId ~= nil then
            for _,v in pairs(self.model.levelupList) do
                if v ~= nil and v.base_id == self.usebackpackBaseId and (self.usebackpackBaseId == self.model.theLastLevelGiftbaseId or self.usebackpackBaseId == 22517) then
                    self.mgr.redPointDic[1][3] = true
                    self.model:CheckForLevelGift()
                    self:UpdateLevelup()
                    self.usebackpackBaseId = nil
                    break
                end
            end
            self.usebackpackBaseId = nil
        end

        for _,v in pairs(items) do
            if v ~= nil then
                for _,v1 in pairs(self.model.levelupList) do
                    if v1 ~= nil and itemDic[v.id] ~= nil and itemDic[v.id].base_id == v1.base_id then
                        self.mgr.redPointDic[1][3] = true
                        self.model:CheckForLevelGift()
                        self:UpdateLevelup()
                        return
                    end
                end
            end
        end
    end

    self.levelChangeListener = function()
        self.model:CheckForLevelGift()
        self:UpdateLevelup()
    end

    self.model:CheckForLevelGift()

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function BibleLevelupPanel:__delete()
    self.OnHideEvent:Fire()
    if self.tempClockImage ~= nil then
        self.tempClockImage.sprite = nil
    end
    for k,sublist in pairs(self.slotList) do
        for _,v in pairs(sublist) do
            v:DeleteMe()
        end
    end
    if self.levelupItemTitleButtonImage ~= nil then
        for _,v in pairs(self.levelupItemTitleButtonImage) do
            v.sprite = nil
        end
    end
    if self.levelupItemTitle2OriginImage ~= nil then
        for _,v in pairs(self.levelupItemTitle2OriginImage) do
            v.sprite = nil
        end
    end
    if self.levelupItemTitle2NowImage ~= nil then
        for _,v in pairs(self.levelupItemTitle2NowImage) do
            v.sprite = nil
        end
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.levelupLayout ~= nil then
        self.levelupLayout:DeleteMe()
        self.levelupLayout = nil
    end
    if self.levelupItemGrid ~= nil then
        for k,v in pairs(self.levelupItemGrid) do
            if v ~= nil then
                v:DeleteMe()
                self.levelupItemGrid[k] = nil
            end
        end
        self.levelupItemGrid = nil
    end
    self:AssetClearAll()
end

function BibleLevelupPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_levelup_panel))
    self.gameObject.name = "LevelupPanel"
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    local panel = self.transform

    self.levelContainer = panel:Find("Panel/Container")
    local levelupTemplate = panel:Find("Item").gameObject
    levelupTemplate:SetActive(false)
    self.tempClockImage = levelupTemplate.transform:Find("Title2/LimitBg/Clock"):GetComponent(Image)
    self.tempClockImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "weekly")
    if self.levelupLayout == nil then
        self.levelupLayout = LuaBoxLayout.New(self.levelContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 5})
    end

    self.model:CheckForLevelGift()

    local size = DataAgenda.data_lev_gift_length / 5
    for i=1,size do
        local obj = GameObject.Instantiate(levelupTemplate)
        obj.transform:Find("Title/Button").gameObject:SetActive(false)
        obj.name = tostring(i)
        self.levelupItemList[i] = obj
        self.levelupLayout:AddCell(obj)
        self.levelupItemGrid[i] = LuaGridLayout.New(obj.transform:Find("Grid").gameObject, {cspacing = 15, rspacing = 5, column = 5, cellSizeX = 60, cellSizeY = 60})
        self.levelupItemIconList[i] = {}
        self.slotList[i] = {}
        local t = obj.transform
        local iconTemplate = t:Find("Grid/Icon").gameObject
        self.levelupItemRect[i] = t:GetComponent(RectTransform)
        self.levelupItemTitle[i] = t:Find("Title").gameObject
        self.levelupItemTitle2[i] = t:Find("Title2").gameObject
        self.levelupItemTitleText[i] = t:Find("Title/Text"):GetComponent(Text)
        self.levelupItemTitle2Text[i] = t:Find("Title2/Image/Text"):GetComponent(Text)
        self.levelupItemTitleButton[i] = t:Find("Title/Button"):GetComponent(Button)
        self.levelupItemTitleButtonRect[i] = t:Find("Title/Button"):GetComponent(RectTransform)
        self.levelupItemTitleButtonText[i] = t:Find("Title/Button/Text"):GetComponent(Text)
        self.levelupItemTitleButtonImage[i] = t:Find("Title/Button"):GetComponent(Image)
        self.levelupItemTitle2Button[i] = t:Find("Title2/Button"):GetComponent(Button)
        self.levelupItemTitle2ButtonRect[i] = t:Find("Title2/Button"):GetComponent(RectTransform)
        self.levelupItemTitle2OriginText[i] = t:Find("Title2/Price/Origin/Text"):GetComponent(Text)
        self.levelupItemTitle2OriginImage[i] = t:Find("Title2/Price/Origin/Image"):GetComponent(Image)
        self.levelupItemTitle2NowText[i] = t:Find("Title2/Price/Now/Text"):GetComponent(Text)
        self.levelupItemTitle2NowImage[i] = t:Find("Title2/Price/Now/Image"):GetComponent(Image)
        self.levelupItemTitle2TimeText[i] = t:Find("Title2/LimitBg/Text"):GetComponent(Text)

        for j=1,10 do
            local icon = GameObject.Instantiate(iconTemplate)
            icon.name = tostring(j)
            self.levelupItemIconList[i][j] = icon
            self.slotList[i][j] = nil
            self.levelupItemGrid[i]:AddCell(icon)
        end
        self.levelupItemTitleButtonRect[i].anchorMax = Vector2(1,0)
        self.levelupItemTitleButtonRect[i].anchorMin = Vector2(1,0)
        self.levelupItemTitleButtonRect[i].anchoredPosition = Vector2(-16, 26)
        self.levelupItemTitle2ButtonRect[i].anchorMax = Vector2(1,0)
        self.levelupItemTitle2ButtonRect[i].anchorMin = Vector2(1,0)
        self.levelupItemTitle2ButtonRect[i].anchoredPosition = Vector2(-16, 26)
        obj:SetActive(false)
    end

    self.OnOpenEvent:Fire()
end

function BibleLevelupPanel:OnOpen()
    self:UpdateLevelup()
    self:RemoveListener()
    self.mgr.onUpdateLevelup:AddListener(self.updateListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.backpackItemChangeListener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levelChangeListener)

    self.mgr.notShowedLevelGift = false
    self.mgr.redPointDic[1][3] = false

    self.mgr.onUpdateRedPoint:Fire()
end

function BibleLevelupPanel:RemoveListener()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.backpackItemChangeListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levelChangeListener)

    self.mgr.onUpdateLevelup:RemoveListener(self.updateListener)
end

function BibleLevelupPanel:OnHide()
    self:RemoveListener()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function BibleLevelupPanel:SetLevelItem(obj, data, i)
    if data == nil then
        obj:SetActive(false)
        return
    else
        obj:SetActive(true)
    end

    local lev = RoleManager.Instance.RoleData.lev

    if data.limitTime == nil then
        self.levelupItemTitle[i]:SetActive(true)
        self.levelupItemTitle2[i]:SetActive(false)
        self.levelupItemTitleText[i].text = data.lev..TI18N("级大礼包")
        self.levelupItemTitleButton[i].gameObject:SetActive(true)
        if lev >= data.lev then
            self.levelupItemTitleButtonText[i].text = TI18N("领取奖励")
            self.levelupItemTitleButtonText[i].color = ColorHelper.DefaultButton3
            self.levelupItemTitleButtonImage[i].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.levelupItemTitleButton[i].enabled = true
            self.levelupItemTitleButton[i].onClick:RemoveAllListeners()
            self.levelupItemTitleButton[i].onClick:AddListener(function()
                local itemDic = BackpackManager.Instance.itemDic
                self.usebackpackId = nil
                self.usebackpackBaseId = nil
                for id,item in pairs(itemDic) do
                    if item.base_id == data.base_id then
                        self.usebackpackId = id
                        self.usebackpackBaseId = data.base_id
                        break
                    end
                end
                if self.usebackpackId ~= nil then
                    BackpackManager.Instance:Send10315(self.usebackpackId, 1)
                else
                    if data.lev == 90 then
                        NoticeManager.Instance:FloatTipsByString(TI18N("完成<color='#ffff00'>世界英雄</color>任务，可领取{item_2, 23200, 1, 1}"))
                        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.biblemain)
                        QuestManager.Instance.model:FindNpc("2_1")
                    elseif data.lev > 10 then
                        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("请先领取%s级礼包"), tostring(data.lev - 10)))
                    else
                        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("背包没有%s级礼包"), tostring(data.lev)))
                    end
                end
            end)
        else
            self.levelupItemTitleButtonText[i].text = data.lev..TI18N("级领取")
            self.levelupItemTitleButtonText[i].color = ColorHelper.DefaultButton4
            self.levelupItemTitleButtonImage[i].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.levelupItemTitleButton[i].enabled = false
        end
    else
        self.levelupItemTitle[i]:SetActive(false)
        self.levelupItemTitle2[i]:SetActive(true)
        self.levelupItemTitle2OriginImage[i].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.worth[1][1])
        self.levelupItemTitle2OriginText[i].text = tostring(data.worth[1][2])
        self.levelupItemTitle2NowImage[i].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.loss[1][1])
        self.levelupItemTitle2NowText[i].text = tostring(data.loss[1][2])
        self.levelupItemTitle2Text[i].text = data.lev..TI18N("级限时大礼包")

        self.levelupItemTitle2Button[i].gameObject:SetActive(true)
        self.levelupItemTitle2Button[i].onClick:RemoveAllListeners()
        self.levelupItemTitle2Button[i].onClick:AddListener(function ()
            BibleManager.Instance:send12009(data.idx)
        end)
    end

    for j=1,10 do
        if data.itemList[j] ~= nil then
            self.levelupItemIconList[i][j]:SetActive(true)
            if self.slotList[i][j] == nil then
                self.slotList[i][j] = ItemSlot.New()
                NumberpadPanel.AddUIChild(self.levelupItemIconList[i][j], self.slotList[i][j].gameObject)
            end

            local cell = DataItem.data_get[data.itemList[j][1]]
            local itemdata = ItemData.New()
            itemdata:SetBase(cell)
            itemdata.quantity = data.itemList[j][2]
            self.slotList[i][j]:SetAll(itemdata, {inbag = false, nobutton = true, isSix = true})
        else
            self.levelupItemIconList[i][j]:SetActive(false)
        end
    end

    if data.limitTime == nil then
        self.levelupItemRect[i].sizeDelta = Vector2(542, 50 + 66 * math.ceil(#data.itemList / 5))
    else
        self.levelupItemRect[i].sizeDelta = Vector2(542, 65 + 66 * math.ceil(#data.itemList / 5))
    end
    self.levelupItemGrid[i].panelRect.anchoredPosition = Vector2(-254.3, 12.1 + 66 * math.ceil(#data.itemList / 5))
end

function BibleLevelupPanel:UpdateLevelup()
    local model = self.model
    local bottom = 0
    BibleManager.Instance:CheckMainUIIconRedPoint()

    self.mgr.onUpdateRedPoint:Fire()

    if self.levelupItemList == nil then
        self:InitLevelup()
    end

    -- BaseUtils.dump(model.levelupShowData, "model.levelupShowData")
    for i,v in ipairs(self.levelupItemList) do
        self:SetLevelItem(v, model.levelupShowData[i], i)
        if model.levelupShowData[i] ~= nil then
            self.levelupItemRect[i].anchoredPosition = Vector2(0, -bottom)
            bottom = bottom + self.levelupItemRect[i].sizeDelta.y
        end
    end
    self.levelContainer:GetComponent(RectTransform).sizeDelta = Vector2(582, bottom)

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 1000, function() self:CalculateTime() end)
end

function BibleLevelupPanel:CalculateTime()
    if self.textList == nil then
        self.textList = {}
    end

    local model = self.model
    local myLevel = RoleManager.Instance.RoleData.lev
    local size = DataAgenda.data_lev_gift_length / 5

    for i,v in ipairs(model.levelupShowData) do
        if v.limitTime ~= nil then
            if BaseUtils.BASE_TIME < v.limitTime then
                local h = math.floor((v.limitTime - BaseUtils.BASE_TIME) / 3600)
                local msg = os.date(string.format("%s:%%M:%%S", tostring(h)), v.limitTime - BaseUtils.BASE_TIME)
                self.levelupItemTitle2TimeText[i].text = TI18N("限时优惠 ")..msg
            elseif BaseUtils.BASE_TIME == v.limitTime then
                self.model:CheckForLevelGift()
                self:UpdateLevelup()
                return
            end
        end
    end
end