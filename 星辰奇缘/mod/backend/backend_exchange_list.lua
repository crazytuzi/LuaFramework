-- @author 黄耀聪
-- @date 2016年8月26日

BackendExchangeList = BackendExchangeList or BaseClass(BasePanel)

function BackendExchangeList:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BackendExchangeList"

    self.resList = {
        {file = AssetConfig.backend_exchange_list, type = AssetType.Main},
        {file = AssetConfig.backend_exchange_bg, type = AssetType.Main},
    }

    self.timeString = TI18N("<color='#00ff00'>%s~%s</color>")
    self.timeFormat = TI18N("%s年%s月%s日%s:%s")
    self.itemList = {}
    self.reloadListener = function() self:ReloadList() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendExchangeList:__delete()
    self.OnHideEvent:Fire()
    if self.titleBgImage ~= nil then
        self.titleBgImage.sprite = nil
        self.titleBgImage = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackendExchangeList:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backend_exchange_list))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.titleBg = t:Find("Title/Bg")
    self.timeText = t:Find("Title/Desc/Time/Content"):GetComponent(Text)
    self.descText = t:Find("Title/Desc/Desc/Content"):GetComponent(Text)
    self.descRect = t:Find("Title/Desc/Desc"):GetComponent(RectTransform)
    self.scoreText = t:Find("Title/Value"):GetComponent(Text)
    self.infoRect = t:Find("Title/Desc"):GetComponent(RectTransform)
    self.receiveBtn = t:Find("Title/Button"):GetComponent(Button)
    self.receiveText = t:Find("Title/Button/Text"):GetComponent(Text)
    self.container = t:Find("Scroll/Container")
    self.cloner = t:Find("Scroll/Cloner").gameObject
    self.scrollHeight = t:Find("Scroll").rect.height
    self.containerHeight = self.container.sizeDelta.y

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})

    self.cloner:SetActive(false)

    self.msgExt = MsgItemExt.New(self.receiveText, 200, 20, 23)
    self.scoreExt = MsgItemExt.New(self.scoreText, 200, 15, 18)

    UIUtils.AddBigbg(self.titleBg, GameObject.Instantiate(self:GetPrefab(AssetConfig.backend_exchange_bg)))
    self.receiveBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1}) end)
end

function BackendExchangeList:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendExchangeList:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backend_campaign_change, self.reloadListener)

    self.campId = self.openArgs.campId
    self.menuId = self.openArgs.menuId

    self.menuData = self.model.backendCampaignTab[self.campId].menu_list[self.menuId]
    self.btnSplitList = StringHelper.Split(self.menuData.button_text, "|")

    self:ReloadList()
    self:OnTime()
    self:InitInfo()
    self:DoLocate()
end

function BackendExchangeList:OnHide()
    self:RemoveListeners()
end

function BackendExchangeList:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backend_campaign_change, self.reloadListener)
end

function BackendExchangeList:ReloadList()
    local model = self.model

    model.rechargeScore = self.menuData.camp_list[1].value or 0
    self.scoreExt:SetData(string.format(TI18N("充值积分:%s"), tostring(model.rechargeScore)))
    local size = self.scoreExt.contentRect.sizeDelta
    self.scoreExt.contentRect.anchoredPosition = Vector2(-58.6 - size.x / 2, 24 + size.y / 2)

    local datalist = {}
    local menuData = self.menuData
    for _,v in pairs(menuData.camp_list) do
        table.insert(datalist, v)
    end
    table.sort(datalist, function(a,b) return a.n < b.n end)

    self.layout:ReSet()
    for i,v in ipairs(datalist) do
        local tab = self.itemList[i]
        if tab == nil then
            local obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            tab = BackendExchangeItem.New(model, obj)
            self.itemList[i] = tab
        end
        v.campId = self.campId
        v.menuId = self.menuId
        self.layout:AddCell(tab.gameObject)
        tab:update_my_self(v, self.btnSplitList)
    end
    for i=#datalist + 1,#self.itemList do
        self.itemList[i]:SetActive(false)
    end
end

function BackendExchangeList:OnTime()
    local model = self.model
    local start_time = self.menuData.start_time
    local end_time = self.menuData.end_time

    local s_y = os.date("%Y", start_time)
    local s_m = os.date("%m", start_time)
    local s_d = os.date("%d", start_time)
    local s_H = os.date("%H", start_time)
    local s_M = os.date("%M", start_time)
    local e_y = os.date("%Y", end_time)
    local e_m = os.date("%m", end_time)
    local e_d = os.date("%d", end_time)
    local e_H = os.date("%H", end_time)
    local e_M = os.date("%M", end_time)

    self.timeText.text = string.format(self.timeString, string.format(self.timeFormat, tostring(s_y), tostring(s_m), tostring(s_d), tostring(s_H), tostring(s_M)), string.format(self.timeFormat, tostring(e_y), tostring(e_m), tostring(e_d), tostring(e_H), tostring(e_M)))
end

function BackendExchangeList:InitInfo()
    self.descText.text = self.menuData.rule_str
    self.msgExt:SetData(TI18N("充 值"))
    local size = self.msgExt.contentRect.sizeDelta
    self.msgExt.contentRect.anchorMax = Vector2(0.5, 0.5)
    self.msgExt.contentRect.anchorMin = Vector2(0.5, 0.5)
    self.msgExt.contentRect.anchoredPosition = Vector2(-size.x / 2, size.y / 2)
    -- local height = math.ceil(self.descText.preferredHeight) + 5
    -- if height < 60 then
    --     height = 60
    -- end
    -- self.descRect.sizeDelta = Vector2(0, height - self.descText.gameObject.transform.anchoredPosition.y)
    -- self.infoRect.sizeDelta = Vector2(0, self.descRect.sizeDelta.y - self.descRect.anchoredPosition.y)
end

function BackendExchangeList:DoLocate()
    local pos = 0
    for i,v in ipairs(self.menuData.camp_list) do
        if v.status == 1 then
            pos = self.itemList[i].transform.anchoredPosition.y
            break
        end
    end
    self.containerHeight = self.container.sizeDelta.y
    if self.containerHeight < self.scrollHeight then
        pos = 0
    elseif -pos >self.containerHeight - self.scrollHeight then
        pos = self.scrollHeight - self.containerHeight
    end
    self.container.anchoredPosition = Vector2(0, -pos)
end


BackendExchangeItem = BackendExchangeItem or BaseClass()

function BackendExchangeItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    local t = self.transform
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.progressText = t:Find("Progress"):GetComponent(Text)
    self.btn = t:Find("Button"):GetComponent(Button)
    self.container = t:Find("Reward/Container")
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 5})

    self.btnImage = self.btn.gameObject:GetComponent(Image)
    if self.btn.gameObject.transform:Find("Text") ~= nil then
        self.btnText = self.btn.gameObject.transform:Find("Text"):GetComponent(Text)
    else
        self.btnText = self.btn.gameObject.transform:Find("I18N_Text"):GetComponent(Text)
    end
    self.msgExt = MsgItemExt.New(self.btnText, 200, 20, 23)
    self.slotList = {}
    self.dataList = {}

    self.originalBtnPos = self.btn.transform.anchoredPosition
    self.originalProgressPos = self.progressText.transform.anchoredPosition
end

function BackendExchangeItem:__delete()
    self.btn.onClick:RemoveAllListeners()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.dataList ~= nil then
        for _,v in pairs(self.dataList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.dataList = nil
    end
    if self.slotList ~= nil then
        for _,v in pairs(self.slotList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.slotList = nil
    end
    if self.btnImage ~= nil then
        self.btnImage.sprite = nil
        self.btnImage = nil
    end
    if self.msgExt ~= nil then
        self.msgExt:DeleteMe()
        self.msgExt = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
end

function BackendExchangeItem:update_my_self(data, stringList)
    self.data = data
    local model = self.model
    local menuData = model.backendCampaignTab[data.campId].menu_list[data.menuId]
    self.nameText.text = data.str1

    -- 奖励物品
    self.layout:ReSet()
    for i,v in ipairs(data.items) do
        local slot = self.slotList[i]
        local itemData = self.dataList[i]
        if slot == nil then
            slot = ItemSlot.New()
            itemData = ItemData.New()
            slot.transform.sizeDelta = Vector2(64, 64)
            self.slotList[i] = slot
            self.dataList[i] = itemData
        end
        if DataItem.data_get[v.base_id] ~= nil then
            if itemData.base_id ~= v.base_id then
                itemData:SetBase(DataItem.data_get[v.base_id])
                slot:SetAll(itemData, {inbag = false, nobutton = true})
            end
            slot:SetNum(v.num)
        else
            slot:Default()
        end
        self.layout:AddCell(slot.gameObject)
    end
    for i=#data.items + 1,#self.slotList do
        self.slotList[i].gameObject:SetActive(false)
    end

    -- print(menuData.is_button)
    -- menuData.is_button = 3
    -- BaseUtils.dump(data)
    -- 按钮状态
    if menuData.is_button == BackendEumn.ButtonType.Hiden then          -- 隐藏按钮
        self.btn.gameObject:SetActive(false)
        self.progressText.gameObject:SetActive(true)
        self.progressText.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
        if data.status == 0 then
            self.progressText.text = string.format("%s/%s", tostring(data.value), tostring(data.tar_val))
        else
            self.progressText.text = TI18N("已完成")
        end
    elseif menuData.is_button == BackendEumn.ButtonType.Normal then     -- 正常按钮
        self.btn.gameObject:SetActive(true)
        self.progressText.gameObject:SetActive(false)
        self.btn.transform.anchoredPosition = Vector2(self.originalBtnPos.x, 0)
        self.progressText.transform.anchoredPosition = self.originalProgressPos
        -- self.progressText.text = string.format("%s%s/%s", stringList[2] or "", tostring(data.value), tostring(ItemSlot.FormatNum(nil, data.tar_val)))

        if data.status ~= 2 then
            if model.rechargeScore >= data.val2 then
                self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Green, stringList[1]))
            else
                self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("未达成")))
            end
        else
            self.progressText.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
            self.progressText.gameObject:SetActive(true)
            -- self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            -- self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("已完成")))
            self.progressText.text = TI18N("已完成")
            self.btn.gameObject:SetActive(false)
        end
    elseif menuData.is_button == BackendEumn.ButtonType.Progress then   -- 进度按钮
        self.progressText.gameObject:SetActive(false)
        self.btn.transform.anchoredPosition = Vector2(self.originalBtnPos.x, 0)
        -- self.progressText.text = string.format("%s%s/%s", stringList[2] or "", tostring(data.value), tostring(data.tar_val))
        if data.status ~= 2 then
            if model.rechargeScore >= data.val2 then
                self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Green, stringList[1]))
            else
                self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("未达成")))
            end
            self.btn.gameObject:SetActive(true)
            -- self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            -- self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Green, string.format("%s(%s/%s)", stringList[1], tostring(data.value), tostring(data.tar_val))))
        else
            self.btn.gameObject:SetActive(false)
            -- self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            -- self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, "已完成"))
            self.progressText.text = TI18N("已完成")
            self.progressText.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
        end
    elseif menuData.is_button == BackendEumn.ButtonType.Times then      -- 次数按钮
        self.btn.gameObject:SetActive(true)
        -- self.btn.transform.anchoredPosition = Vector2(self.originalBtnPos.x, 0)
        if data.reward_num < 5000 then
            self.btn.transform.anchoredPosition = self.originalBtnPos
            self.progressText.gameObject:SetActive(true)
            self.progressText.text = string.format(TI18N("%s%s次"), stringList[2] or "",  tostring(data.reward_can))
            self.progressText.gameObject.transform.anchoredPosition = self.originalProgressPos
        else
            self.progressText.gameObject:SetActive(false)
            self.btn.transform.anchoredPosition = Vector2(self.originalBtnPos.x, 0)
        end
        if data.status ~= 2 then
            if model.rechargeScore >= data.val2 then
                self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Green, string.format("%s", stringList[1])))
            else
                self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("未达成")))
            end
            -- self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        else
            self.btn.gameObject:SetActive(false)
            self.progressText.gameObject:SetActive(true)
            -- self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            -- self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, "已完成"))
            self.progressText.text = TI18N("已完成")
            self.progressText.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
        end
    end

    local size = self.msgExt.contentRect.sizeDelta
    self.msgExt.contentRect.anchoredPosition = Vector2(-size.x / 2, size.y / 2)

    self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function() self:OnClick() end)
end

function BackendExchangeItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function BackendExchangeItem:OnClick()
    if self.data ~= nil then
        if self.model.rechargeScore < self.data.val2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("积分不足"))
        elseif self.data.status < 2 then
            BackendManager.Instance:send14053(self.data.campId, self.data.menuId, self.data.n, 1)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("已完成"))
        end
    end
end



