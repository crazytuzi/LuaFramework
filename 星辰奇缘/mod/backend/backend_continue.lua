-- @author 黄耀聪
-- @date 2016年8月16日

BackendContinue = BackendContinue or BaseClass(BasePanel)

function BackendContinue:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BackendContinue"

    self.resList = {
        {file = AssetConfig.backend_continue, type = AssetType.Main},
        {file = AssetConfig.backend_textures, type = AssetType.Dep},
    }

	self.timeString = TI18N("活动时间:<color='#00ff00'>%s~%s</color>")
	self.timeFormat = TI18N("%s月%s日")
	self.descFormat = TI18N("活动描述:<color='#ccecf8'>%s</color>")
	self.descString = ""
	self.itemList = {}
    self.rewardItemList = {}
    self.effectList = {}
    self.reloadListener = function() self:ReloadList() end
    self.isMoving = false
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendContinue:__delete()
    self.OnHideEvent:Fire()
    if self.msgExt ~= nil then
        self.msgExt:DeleteMe()
        self.msgExt = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                for _,v1 in ipairs(v.items) do
                    v1.slot:DeleteMe()
                    v1.data:DeleteMe()
                end
                v.btnImage.sprite = nil
            end
        end
        self.itemList = nil
    end
    if self.rewardItemList ~= nil then
        for _,v in pairs(self.rewardItemList) do
            if v ~= nil then
                v.slot:DeleteMe()
            end
        end
        self.rewardItemList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.tabbedLayout ~= nil then
        self.tabbedLayout:DeleteMe()
        self.tabbedLayout = nil
    end
    if self.rechargeImage ~= nil then
        self.rechargeImage.sprite = nil
        self.rechargeImage = nil
    end
    if self.effectList ~= nil then
        for _,v in pairs(self.effectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.effectList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackendContinue:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backend_continue))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.preBtn = t:Find("Prebtn"):GetComponent(Button)
    self.preEnable = t:Find("Prebtn/Enable").gameObject
    self.preDiable = t:Find("Prebtn/Disable").gameObject
    self.nextBtn = t:Find("Nextbtn"):GetComponent(Button)
    self.nextEnable = t:Find("Nextbtn/Enable").gameObject
    self.nextDisable = t:Find("Nextbtn/Disable").gameObject
    self.timeText = t:Find("Title/Time"):GetComponent(Text)
    self.rechargeBtn = t:Find("Reward/Area/Button"):GetComponent(Button)
    self.rechargeImage= t:Find("Reward/Area/Button"):GetComponent(Image)
    self.rechargeText = t:Find("Reward/Area/Button/Text"):GetComponent(Text)
    self.container = t:Find("Reward/Area/Scroll/Container")

    local crystalContainer = t:Find("Slider/Container")

    self.dayContainer = t:Find("Scroll/Container")
    local len = self.dayContainer.childCount
    for i=1,len do
        self.itemList[i] = {}
        local tab = self.itemList[i]
        tab.transform = self.dayContainer:GetChild(i - 1)
        tab.name = tab.transform:Find("Name"):GetComponent(Text)
        local rewardContainer = tab.transform:Find("Reward")
        tab.items = {}
        for j=1,3 do
            tab.items[j] = {trans = rewardContainer:GetChild(j - 1), slot = ItemSlot.New(), data = ItemData.New()}
            NumberpadPanel.AddUIChild(tab.items[j].trans.gameObject, tab.items[j].slot.gameObject)
        end
        tab.btn = tab.transform:Find("Button"):GetComponent(Button)
        tab.btnText = tab.transform:Find("Button/Text"):GetComponent(Text)
        tab.btnImage = tab.transform:Find("Button"):GetComponent(Image)
        tab.crystalImage = crystalContainer:GetChild(i - 1):GetComponent(Image)
    end

    self.slider = t:Find("Slider"):GetComponent(Slider)
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 5, border = 5})
    self.msgExt = MsgItemExt.New(self.rechargeText, 200, 20, 23)
    -- self.tabbedLayout = TabbedPanel.New(self.dayContainer.parent.gameObject, 5, 144, 0.6)
    -- self.cloner:SetActive(false)

    self.nextBtn.onClick:AddListener(function() self:GoNext() end)
    self.preBtn.onClick:AddListener(function() self:GoPre() end)
    self.dayContainer.parent:GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChange() end)
end

function BackendContinue:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendContinue:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backend_campaign_change, self.reloadListener)

    self.campId = self.openArgs.campId
    self.menuId = self.openArgs.menuId

    self.menuData = self.model.backendCampaignTab[self.campId].menu_list[self.menuId]
    self.btnSplitList = StringHelper.Split(self.menuData.button_text, "|")

    self:ReloadList()
    self:InitInfo()

    self.dayContainer.anchoredPosition = Vector2(0, 0)
    self:OnValueChange()

    self:DoLocate()
end

function BackendContinue:OnHide()
    self:RemoveListeners()
end

function BackendContinue:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backend_campaign_change, self.reloadListener)
end

function BackendContinue:OnTime()
	local model = self.model
	local start_time = model.backendCampaignTab[self.campId].menu_list[self.menuId].start_time
	local end_time = model.backendCampaignTab[self.campId].menu_list[self.menuId].end_time

	local s_m = os.date("%m", start_time)
	local s_d = os.date("%d", start_time)
	local s_H = os.date("%H", start_time)
	local s_M = os.date("%M", start_time)
	local e_m = os.date("%m", end_time)
	local e_d = os.date("%d", end_time)
	local e_H = os.date("%H", end_time)
	local e_M = os.date("%M", end_time)

	self.timeText.text = self.descString .. string.format(self.timeString, string.format(self.timeFormat, tostring(s_m), tostring(s_d), tostring(s_H), tostring(s_M)), string.format(self.timeFormat, tostring(e_m), tostring(e_d), tostring(e_H), tostring(e_M)))
end

function BackendContinue:InitInfo()
    self.descString = ""
    self.timeText.text = self.descString
	self:OnTime()
	-- self.descString = self.descString ..string.format(self.descFormat, self.model.backendCampaignTab[self.campId].menu_list[self.menuId].rule_str)

    -- self.totalText.text = tostring(self.menuData.)
end

function BackendContinue:ReloadList()
    local count = 0
    for i,v in ipairs(self.itemList) do
        local data = self.menuData.camp_list[i]
        if v.name ~= nil then
            v.name.text = string.format(TI18N("第%s天"), tostring(i))
        end
        if data ~= nil then
            for j=1,3 do
                local tab = v.items[j]
                if data.items[j] ~= nil and DataItem.data_get[data.items[j].base_id] ~= nil then
                    tab.data:SetBase(DataItem.data_get[data.items[j].base_id])
                    tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
                    tab.slot:SetNum(data.items[j].num)
                else
                    tab.slot:Default()
                end
            end
            v.btn.onClick:RemoveAllListeners()
            if data.status == 1 then
                v.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                v.btnText.text = ColorHelper.Fill(ColorHelper.ButtonLabelColor.Blue, TI18N("领取"))
                v.btn.onClick:AddListener(function() BackendManager.Instance:send14053(self.campId, self.menuId, data.n, 1) end)
                count = count + 1
                BaseUtils.SetGrey(v.crystalImage, false)
                if self.effectList[i] == nil then
                    self.effectList[i] = BibleRewardPanel.ShowEffect(20118, v.btn.transform, Vector3(1, 0.75, 1), Vector3(-50, 20, -400))
                end
            else
                v.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                if data.status == 0 then
                    v.btnText.text = ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("未完成"))
                    BaseUtils.SetGrey(v.crystalImage, true)
                elseif data.status == 2 then
                    v.btnText.text = ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("已领取"))
                    count = count + 1
                    BaseUtils.SetGrey(v.crystalImage, false)
                end

                if self.effectList[i] ~= nil then
                    self.effectList[i]:DeleteMe()
                    self.effectList[i] = nil
                end
            end
        else
            for j=1,3 do
                v.items[j].trans.gameObject:SetActive(false)
            end
            v.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            v.btnText.text = TI18N("未达成")
        end
    end

    local len = #self.itemList
    local data = self.menuData.camp_list[len + 1] or {}
    data.items = data.items or {}
    self.layout:ReSet()
    for i,v in ipairs(data.items) do
        local tab = self.rewardItemList[i]
        if tab == nil then
            tab = {}
            tab.slot = ItemSlot.New()
            tab.data = ItemData.New()
            tab.slot.gameObject.transform.sizeDelta = Vector2(64,64)
            self.rewardItemList[i] = tab
        end
        local baseData = DataItem.data_get[data.items[i].base_id]
        if baseData ~= nil then
            if tab.data.base_id ~= baseData.base_id then
                tab.data:SetBase(baseData)
                tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
            end
            tab.slot:SetNum(data.items[i].num)
        else
            tab.slot:Default()
        end
        self.layout:AddCell(tab.slot.gameObject)
    end
    for i=#data.items + 1,#self.rewardItemList do
        self.rewardItemList[i].slot.gameObject:SetActive(false)
    end
    self.rechargeBtn.onClick:RemoveAllListeners()
    self.rechargeBtn.onClick:AddListener(function() BackendManager.Instance:send14053(self.campId, self.menuId, data.n, 1) end)

    if data.status == 0 then
        self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("未完成")))
        self.rechargeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    elseif data.status == 1 then
        self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Green, TI18N("领 取")))
        self.rechargeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    elseif data.status == 2 then
        self.msgExt:SetData(ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("已领取")))
        self.rechargeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    end
    local size = self.msgExt.contentRect.sizeDelta
    self.msgExt.contentRect.anchoredPosition = Vector2(-size.x / 2, size.y / 2)
    self.slider.value = (count - 1) / 6
end

function BackendContinue:TweenTo(pos)
    self.isMoving = true
    local totalWidth = self.dayContainer.sizeDelta.x - self.dayContainer.parent.sizeDelta.x
    local targetX = - pos * totalWidth
    Tween.Instance:MoveX(self.dayContainer, targetX, 0.6, function() self.isMoving = false self.preBtn.enabled = true self.nextBtn.enabled = true end, LeanTweenType.easeOutExpo)
end

function BackendContinue:OnValueChange()
    if not self.isMoving then
        local x = self.dayContainer.anchoredPosition.x
        local totalWidth = self.dayContainer.sizeDelta.x - self.dayContainer.parent.sizeDelta.x
        local pos = -x / totalWidth
        if pos < 0.01 then
            self.preEnable:SetActive(false)
            self.preDiable:SetActive(true)
            self.nextEnable:SetActive(true)
            self.nextDisable:SetActive(false)
        elseif pos > 0.99 then
            self.preEnable:SetActive(true)
            self.preDiable:SetActive(false)
            self.nextEnable:SetActive(false)
            self.nextDisable:SetActive(true)
        else
            self.preEnable:SetActive(true)
            self.preDiable:SetActive(false)
            self.nextEnable:SetActive(true)
            self.nextDisable:SetActive(false)
        end
    end
end

function BackendContinue:GoNext()
    local currentX = self.dayContainer.anchoredPosition.x
    local totalWidth = self.dayContainer.sizeDelta.x - self.dayContainer.parent.sizeDelta.x
    local step = 2
    local pageWidth = self.dayContainer.sizeDelta.x / #self.itemList

    local pos = (-currentX / totalWidth) + step * pageWidth / totalWidth
    if pos > 1 then
        pos = 1
    end
    self.preBtn.enabled = false
    self.nextBtn.enabled = false
    self:TweenTo(pos)
end

function BackendContinue:GoPre()
    local currentX = self.dayContainer.anchoredPosition.x
    local totalWidth = self.dayContainer.sizeDelta.x - self.dayContainer.parent.sizeDelta.x
    local step = 2
    local pageWidth = self.dayContainer.sizeDelta.x / #self.itemList

    local pos = (-currentX / totalWidth) - step * pageWidth / totalWidth
    if pos < 0 then
        pos = 0
    end
    self.preBtn.enabled = false
    self.nextBtn.enabled = false
    self:TweenTo(pos)
end

function BackendContinue:DoLocate()
    local pos = 0
    for i=1,7 do
        if self.menuData.camp_list[i].status == 1 then
            pos = self.itemList[i].transform.anchoredPosition.x
            break
        end
    end
    self.dayContainer.anchoredPosition = Vector2(-pos, 0)
    self:OnValueChange()
end

function BackendContinue:OnClick(data)
    if data.status ~= 2 then
        BackendManager.Instance:send14053(self.campId, self.menuId, data.n, 1)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("已领取"))
    end
end

