-- @author 黄耀聪
-- @date 2016年8月16日

BackendTextList = BackendTextList or BaseClass(BasePanel)

function BackendTextList:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BackendTextList"

    self.resList = {
        {file = AssetConfig.backend_text_list, type = AssetType.Main},
        {file = AssetConfig.backend_textures, type = AssetType.Dep},
    }

	self.timeString = TI18N("<color='#00ff00'>%s~%s</color>")
	self.timeFormat = TI18N("%s月%s日%s:%s")
    self.itemList = {}
    self.reloadListener = function() self:ReloadList() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendTextList:__delete()
    self.OnHideEvent:Fire()
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

function BackendTextList:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backend_text_list))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.titleText = t:Find("Title/Text"):GetComponent(Text)
    self.titleRect = t:Find("Title/Text"):GetComponent(RectTransform)
    self.timeText = t:Find("Time/Time"):GetComponent(Text)
    self.descText = t:Find("Desc/Desc"):GetComponent(Text)
    self.descRect = t:Find("Desc"):GetComponent(RectTransform)
    self.content = t:Find("Content")
    self.container = self.content:Find("Scroll/Container")
    self.cloner = self.content:Find("Scroll/Cloner").gameObject
    self.scrollHeight = self.content:Find("Scroll").rect.height
    self.containerHeight = self.container.sizeDelta.y

    self.effect = nil

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 5, border = 5})
    self.cloner:SetActive(false)
end

function BackendTextList:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendTextList:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backend_campaign_change, self.reloadListener)

    self.campId = self.openArgs.campId
    self.menuId = self.openArgs.menuId

    self.menuData = self.model.backendCampaignTab[self.campId].menu_list[self.menuId]
    self.btnSplitList = StringHelper.Split(self.menuData.button_text, "|")

    if self.menuData.is_button == BackendEumn.ButtonType.Countdown then
        if self.timerId ~= nil then LuaTimer.Delete(self.timerId) end
        self.timerId = LuaTimer.Add(5 * 1000, function() self:ReloadList() end)
    end

    self:ReloadList()
	self:OnTime()
    self:InitInfo()
    self:DoLocate()
end

function BackendTextList:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function BackendTextList:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backend_campaign_change, self.reloadListener)
end

function BackendTextList:ReloadList()
    local model = self.model
    local datalist = {}
    local menuData = self.menuData
    for _,v in pairs(menuData.camp_list) do
        table.insert(datalist, v)
    end
    table.sort(datalist, function(a,b) return a.n < b.n end)

    self.layout:ReSet()
    local bool = false
    local bool1 = false
    for i,v in ipairs(datalist) do
        local tab = self.itemList[i]
        if tab == nil then
            local obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            tab = BackendTextItem.New(model, obj)
            self.itemList[i] = tab
        end
        self.layout:AddCell(tab.gameObject)
        v.campId = self.campId
        v.menuId = self.menuId
        bool = (bool1 ~= (v.status == 0))
        tab:update_my_self(v, self.btnSplitList, bool)
        bool1 = v.status == 0
    end
    for i=#datalist + 1,#self.itemList do
        self.itemList[i]:SetActive(false)
    end
end

function BackendTextList:OnTime()
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

function BackendTextList:InitInfo()
    self.titleText.text = self.menuData.title2
    self.descText.text = self.menuData.rule_str
    local h = self.titleRect.sizeDelta.y
    self.titleRect.sizeDelta = Vector2(math.ceil(self.titleText.preferredWidth) + 10, h)

    local height = math.ceil(self.descText.preferredHeight)
    if height < 30 then
        height = 30
    end
    self.descRect.sizeDelta = Vector2(545.5, height)

    self.content.sizeDelta = Vector2(549, 352.1 - height)
end

function BackendTextList:DoLocate()
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

-- @author 黄耀聪
-- @date 2016年8月16日

BackendTextItem = BackendTextItem or BaseClass()

function BackendTextItem:__init(model, gameObject)
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

function BackendTextItem:__delete()
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
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
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
end

function BackendTextItem:update_my_self(data, stringList, isSpecial)
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

    -- BaseUtils.dump(data)
    -- menuData.is_button = 1
    -- print(menuData.is_button)

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
        self.progressText.gameObject:SetActive(true)
        self.slider.gameObject:SetActive(false)
        self.progressText.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
        if data.status == 0 then
            -- if data.tar_val == 0 then
            --     self.slider.value = 0
            -- else
            --     self.slider.value = data.value / data.tar_val
            -- end
            self.progressText.text = stringList[1]
        else
            self.progressText.text = TI18N("已完成")
        end
    elseif menuData.is_button == BackendEumn.ButtonType.Progress then     -- 进度按钮
        if data.status == 0 then
            self.slider.gameObject:SetActive(true)
            self.btn.gameObject:SetActive(false)
            self.progressText.gameObject:SetActive(false)
            if data.tar_val == 0 then
                self.slider.value = 0
                self.sliderText.text = tostring(0/0)
            else
                self.slider.value = data.value / data.tar_val
                self.sliderText.text = string.format("%s/%s", tostring(data.value), ItemSlot.FormatNum(nil, data.tar_val))
            end
        elseif data.status == 1 then
            self.slider.gameObject:SetActive(false)
            self.progressText.gameObject:SetActive(false)
            self.btn.gameObject:SetActive(true)
            self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Green, stringList[1]))
            self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.btn.transform.anchoredPosition = Vector2(self.originalBtnPos.x, 0)
        elseif data.status == 2 then
            self.slider.gameObject:SetActive(false)
            self.btn.gameObject:SetActive(false)
            self.progressText.gameObject:SetActive(true)
            self.progressText.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
            self.progressText.text = TI18N("已完成")
        end
    elseif menuData.is_button == BackendEumn.ButtonType.Normal then   -- 正常按钮
        self.slider.gameObject:SetActive(false)
        self.progressText.gameObject:SetActive(true)
        self.btn.transform.anchoredPosition = Vector2(self.originalBtnPos.x, 0)
        self.progressText.gameObject.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
        if data.status == 0 then
            self.btn.gameObject:SetActive(false)
            -- self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            -- self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Green, string.format("%s", stringList[1])))
            -- self.progressText.text = string.format("%s/%s", tostring(data.value), ItemSlot.FormatNum(nil, data.tar_val))
            if isSpecial then
                if stringList[2] == nil then
                    -- self.progressText.text = ""
                    self.progressText.gameObject:SetActive(false)
                else
                    self.progressText.gameObject:SetActive(true)
                    self.progressText.text = string.format(stringList[2], tostring(data.value))
                end
            else
                self.progressText.gameObject:SetActive(false)
            end
        elseif data.status == 1 then
            self.btn.gameObject:SetActive(true)
            self.progressText.gameObject:SetActive(false)
            self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Blue, stringList[1]))
        elseif data.status == 2 then
            self.btn.gameObject:SetActive(false)
            self.progressText.gameObject:SetActive(true)
            -- self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            -- self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, "已完成"))
            self.progressText.gameObject.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
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
            self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, stringList[1]))
        elseif data.status == 1 then
            self.btn.gameObject:SetActive(true)
            self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Green, stringList[1]))
        elseif data.status == 2 then
            self.btn.gameObject:SetActive(false)
            self.progressText.gameObject:SetActive(true)
            self.progressText.gameObject.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
            self.progressText.text = TI18N("已完成")
        end
    elseif menuData.is_button == BackendEumn.ButtonType.Countdown then      -- 倒计时
        self.progressText.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
        self.btn.transform.anchoredPosition = Vector2(self.originalBtnPos.x, 0)
        self.slider.gameObject:SetActive(false)

        if data.status == 0 then
            self.btn.gameObject:SetActive(false)
            if isSpecial then
                self.progressText.gameObject:SetActive(true)
                local h = 0
                local m = 0
                if model.countDownTab[data.campId] == nil or model.countDownTab[data.campId][data.menuId] == nil then
                    h = 0
                    m = 0
                else
                    _,h,m,_ = BaseUtils.time_gap_to_timer(BaseUtils.BASE_TIME - model.countDownTab[data.campId][data.menuId])
                end
                if h > 0 then
                    self.progressText.text = string.format(stringList[2], string.format(TI18N("%s小时%分钟"), tostring(h), tostring(m)))
                else
                    self.progressText.text = string.format(stringList[2], string.format(TI18N("%s分钟"), tostring(m)))
                end
            else
                self.progressText.gameObject:SetActive(false)
            end
        elseif data.status == 1 then
            self.btn.gameObject:SetActive(true)
            self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.msgExt:SetData(stringList[1])
            self.progressText.text = TI18N("已完成")
        elseif data.status == 2 then
            self.btn.gameObject:SetActive(false)
            self.progressText.text = TI18N("已完成")
        end
    elseif menuData.is_button == BackendEumn.ButtonType.Buy then      -- 购买，其实就是已完成未领取的状态不能加特效
        self.slider.gameObject:SetActive(false)
        self.progressText.transform.anchoredPosition = Vector2(self.originalProgressPos.x, 0)
        self.btn.transform.anchoredPosition = Vector2(self.originalBtnPos.x, 0)
        self.slider.gameObject:SetActive(false)
    end

    local size = self.msgExt.contentRect.sizeDelta
    self.msgExt.contentRect.anchoredPosition = Vector2(-size.x / 2, size.y / 2)

    self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function() self:OnClick() end)
end

function BackendTextItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function BackendTextItem:OnClick()
    if self.data ~= nil then
        if self.menuData.is_button ~= BackendEumn.ButtonType.Buy then
            if self.data.status < 2 then
                BackendManager.Instance:send14053(self.data.campId, self.data.menuId, self.data.n, 1)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("已完成"))
            end
        else
            local confirmData = NoticeConfirmData.New()
            confirmData.content = string.format(TI18N("是否花费<color='#00ff00'>%s</color>{assets_2, %s}购买%s个<color='#ffff00'>%s</color>"), tostring(self.data.loss_items[1].num), tostring(self.data.loss_items[1].base_id), tostring(BaseUtils.NumToChn(self.data.items[1].num)), DataItem.data_get[self.data.items[1].base_id].name)
            confirmData.sureCallback = function() BackendManager.Instance:send14053(self.data.campId, self.data.menuId, self.data.n, 1) end
            NoticeManager.Instance:ConfirmTips(confirmData)
        end
    end
end




