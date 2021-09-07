-- @author 黄耀聪
-- @date 2016年7月28日

BackendBackgroundList = BackendBackgroundList or BaseClass(BasePanel)

function BackendBackgroundList:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BackendBackgroundList"

    self.resList = {
        {file = AssetConfig.backend_background_list, type = AssetType.Main},
        {file = AssetConfig.backend_textures, type = AssetType.Dep},
    }

	self.timeString = TI18N("<color='#00ff00'>%s~%s</color>")
	self.timeFormat = TI18N("%s月%s日%s:%s")
    self.itemList = {}
    self.reloadListener = function() self:ReloadList() end

    self.bigbgToFile = {
        ["BackendBgI18N"] = AssetConfig.backend_big_bg,
    }

    self.effectList = {}

    for _,v in pairs(self.bigbgToFile) do
        table.insert(self.resList, {file = v, type = AssetType.Main})
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendBackgroundList:__delete()
    self.OnHideEvent:Fire()
    if self.titleBgImage ~= nil then
        self.titleBgImage.sprite = nil
        self.titleBgImage = nil
    end
    if self.titleImage ~= nil then
        self.titleImage.sprite = nil
        self.titleImage = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.effectList ~= nil then
        for _,v in pairs(self.effectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.effectList = nil
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

function BackendBackgroundList:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backend_background_list))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.titleBg = t:Find("Title/Bg")
    self.titleImage = t:Find("Title/Title"):GetComponent(Image)
    self.timeText = t:Find("Title/Desc/Time/Content"):GetComponent(Text)
    self.descText = t:Find("Title/Desc/Desc/Content"):GetComponent(Text)
    self.descRect = t:Find("Title/Desc/Desc"):GetComponent(RectTransform)
    self.infoRect = t:Find("Title/Desc"):GetComponent(RectTransform)

    self.container = t:Find("Scroll/Container")
    self.cloner = t:Find("Scroll/Cloner").gameObject
    self.scrollHeight = t:Find("Scroll").rect.height
    self.containerHeight = self.container.sizeDelta.y

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})

    self.cloner:SetActive(false)
end

function BackendBackgroundList:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendBackgroundList:OnOpen()
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

function BackendBackgroundList:OnHide()
    self:RemoveListeners()
end

function BackendBackgroundList:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backend_campaign_change, self.reloadListener)
end

function BackendBackgroundList:ReloadList()
    local model = self.model
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
            tab = BackendBgItem.New(model, obj)
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

function BackendBackgroundList:OnTime()
	local model = self.model
	local start_time = self.menuData.start_time
	local end_time = self.menuData.end_time

	local s_m = os.date("%m", start_time)
	local s_d = os.date("%d", start_time)
	local s_H = os.date("%H", start_time)
	local s_M = os.date("%M", start_time)
	local e_m = os.date("%m", end_time)
	local e_d = os.date("%d", end_time)
	local e_H = os.date("%H", end_time)
	local e_M = os.date("%M", end_time)

	self.timeText.text = string.format(self.timeString, string.format(self.timeFormat, tostring(s_m), tostring(s_d), tostring(s_H), tostring(s_M)), string.format(self.timeFormat, tostring(e_m), tostring(e_d), tostring(e_H), tostring(e_M)))
end

function BackendBackgroundList:InitInfo()
    self.descText.text = ColorHelper.Fill(ColorHelper.ButtonLabelColor.Blue, self.menuData.rule_str)
    local height = math.ceil(self.descText.preferredHeight) + 5
    if height < 60 then
        height = 60
    end
    self.descRect.sizeDelta = Vector2(353.9, height - self.descText.gameObject.transform.anchoredPosition.y)
    self.infoRect.sizeDelta = Vector2(368.5, self.descRect.sizeDelta.y - self.descRect.anchoredPosition.y)

    if self.bigbgToFile[self.menuData.top_banner] ~= nil then
        -- self.titleBgImage.sprite = self.assetWrapper:GetSprite(self.bigbgToFile[self.menuData.top_banner], self.menuData.top_banner)
        UIUtils.AddBigbg(self.titleBg, GameObject.Instantiate(self:GetPrefab(self.bigbgToFile[self.menuData.top_banner])))
    else
        -- self.titleBgImage.sprite = self.assetWrapper:GetSprite(AssetConfig.backend_big_bg, "BackendBgI18N")
        UIUtils.AddBigbg(self.titleBg, GameObject.Instantiate(self:GetPrefab(AssetConfig.backend_big_bg)))
    end

    local sprite = self.assetWrapper:GetSprite(AssetConfig.backend_textures, self.menuData.title_ico)
    if sprite == nil then
        self.titleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.backend_textures, "I18N_SingleRecharge")
    else
        self.titleImage.sprite = sprite
    end
end

function BackendBackgroundList:DoLocate()
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


BackendBgItem = BackendBgItem or BaseClass()

function BackendBgItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    local t = self.transform
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.progressText = t:Find("Progress"):GetComponent(Text)
    self.btn = t:Find("Button"):GetComponent(Button)
    self.container = t:Find("Reward/Container")
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 5})
    self.slider = t:Find("Slider"):GetComponent(Slider)
    self.sliderText = t:Find("Slider/Text"):GetComponent(Text)

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

function BackendBgItem:__delete()
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

function BackendBgItem:update_my_self(data, stringList)
    self.data = data
    local menuData = self.model.backendCampaignTab[data.campId].menu_list[data.menuId]
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

    if data.status == 1 then
        if self.effect == nil then
            self.effect = BibleRewardPanel.ShowEffect(20118, self.btn.transform, Vector3(1, 0.75, 1), Vector3(-50, 20, -400))
        end
    else
        if self.effect ~= nil then
            self.effect:DeleteMe()
            self.effect = nil
        end
    end

    -- 按钮状态
    if menuData.is_button == BackendEumn.ButtonType.Hiden then          -- 隐藏按钮
        self.btn.gameObject:SetActive(false)
        -- self.progressText.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
        if data.status == 0 then
            self.progressText.gameObject:SetActive(false)
            self.slider.gameObject:SetActive(true)
            if data.tar_val ~= 0 then
                self.slider.value = data.value / data.tar_val
            else
                self.slider.value = 0
            end
            self.sliderText.text = string.format("%s/%s", tostring(data.value), ItemSlot.FormatNum(nil, data.tar_val))
        else
            self.progressText.gameObject:SetActive(true)
            self.slider.gameObject:SetActive(false)
            self.progressText.text = TI18N("已完成")
        end
    elseif menuData.is_button == BackendEumn.ButtonType.Normal then     -- 正常按钮
        self.btn.gameObject:SetActive(true)
        self.slider.gameObject:SetActive(false)
        self.btn.transform.anchoredPosition = Vector2(self.originalBtnPos.x, 0)
        -- self.progressText.transform.anchoredPosition = self.originalProgressPos
        self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Green, stringList[1]))
        if data.status == 0 then
            self.progressText.gameObject:SetActive(false)
            self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("未达成")))
        elseif data.status == 1 then
            if stringList[2] == nil then
                self.progressText.gameObject:SetActive(false)
            else
                self.progressText.gameObject:SetActive(true)
                self.progressText.text = string.format(stringList[2], tostring(data.value))
            end
            self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        elseif data.status == 2 then
            self.btn.gameObject:SetActive(false)
            self.progressText.gameObject:SetActive(true)
            self.progressText.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
            self.progressText.text = TI18N("已完成")
        end
    elseif menuData.is_button == BackendEumn.ButtonType.Progress then   -- 进度按钮
        self.progressText.gameObject:SetActive(false)
        -- self.progressText.text = string.format("%s%s/%s", stringList[2] or "", tostring(data.value), ItemSlot.FormatNum(nil, data.tar_val))
        if data.status == 0 then
            self.slider.gameObject:SetActive(true)
            self.btn.gameObject:SetActive(false)
            if data.tar_val ~= 0 then
                self.slider.value = data.value / data.tar_val
            else
                self.slider.value = 0
            end
            self.sliderText.text = string.format("%s/%s", tostring(data.value), ItemSlot.FormatNum(nil, data.tar_val))
            -- self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            -- self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("未达成")))
        elseif data.status == 1 then
            self.btn.gameObject:SetActive(true)
            self.slider.gameObject:SetActive(false)
            self.btn.transform.anchoredPosition = Vector2(self.originalBtnPos.x, 0)
            self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Green, stringList[1]))
        elseif data.status == 2 then
            self.btn.gameObject:SetActive(false)
            self.slider.gameObject:SetActive(false)
            self.progressText.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
            self.progressText.text = TI18N("已完成")
        end
    elseif menuData.is_button == BackendEumn.ButtonType.Times then      -- 次数按钮
        self.slider.gameObject:SetActive(false)
        -- if data.reward_num == 1 then
        --     self.progressText.gameObject:SetActive(false)
        --     self.btn.transform.anchoredPosition = Vector2(self.originalBtnPos.x, 0)
        -- elseif data.reward_num < 5000 then
        if data.reward_num < 5000 then
            self.btn.transform.anchoredPosition = self.originalBtnPos
            self.progressText.gameObject:SetActive(true)
            self.progressText.text = string.format(TI18N("%s%s次"), stringList[2] or "",  tostring(data.reward_can))
            self.progressText.gameObject.transform.anchoredPosition = self.originalProgressPos
        else
            self.progressText.gameObject:SetActive(false)
            self.btn.transform.anchoredPosition = Vector2(self.originalBtnPos.x, 0)
        end
        if data.status == 0 then
            self.btn.gameObject:SetActive(true)
            self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("未达成")))
        elseif data.status == 1 then
            self.btn.gameObject:SetActive(true)
            self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Green, string.format("%s", stringList[1])))
        elseif data.status == 2 then
            self.btn.gameObject:SetActive(false)
            self.progressText.gameObject:SetActive(true)
            -- self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            -- self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, "已完成"))
            self.progressText.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
            self.progressText.text = TI18N("已完成")
        end
    end

    local size = self.msgExt.contentRect.sizeDelta
    self.msgExt.contentRect.anchoredPosition = Vector2(-size.x / 2, size.y / 2)

    self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function() self:OnClick() end)
end

function BackendBgItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function BackendBgItem:OnClick()
    if self.data ~= nil then
        if self.data.status < 2 then
            BackendManager.Instance:send14053(self.data.campId, self.data.menuId, self.data.n, 1)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("已完成"))
        end
    end
end

