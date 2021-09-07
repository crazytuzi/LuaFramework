-- @author 黄耀聪
-- @date 2016年9月7日

BackendMarryEasy = BackendMarryEasy or BaseClass(BasePanel)

function BackendMarryEasy:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BackendMarryEasy"

    self.resList = {
        {file = AssetConfig.mergeserver_endear_panel, type = AssetType.Main},
        {file = AssetConfig.witch_girl, type = AssetType.Main},
        {file = AssetConfig.mergeserver_textures, type = AssetType.Dep},
        {file = AssetConfig.dailyicon, type = AssetType.Dep}
    }
    self.timeString = TI18N("活动时间:<color='#13fc60'>%s-%s</color>")
    self.dateFormatString = TI18N("%s月%s日")
    self.descFormatString = TI18N("<color=#7EB9F7>活动内容：</color>%s")
    self.reloadListener = function() self:ReloadList() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendMarryEasy:__delete()
    self.OnHideEvent:Fire()
    if self.witchImage ~= nil then
        self.witchImage.sprite = nil
        self.witchImage = nil
    end
    if self.descItem ~= nil then
        for _,v in pairs(self.descItem) do
            if v ~= nil then
                v.iconLoader:DeleteMe()
            end
        end
        self.descItem = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackendMarryEasy:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mergeserver_endear_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t
    t.anchoredPosition = Vector2.zero

    self.witchImage = t:Find("GirlArea"):GetComponent(Image)
    self.witchImage.sprite = self.assetWrapper:GetSprite(AssetConfig.witch_girl, "Witch")
    self.titleText = t:Find("TitleArea/Title/Text"):GetComponent(Text)
    self.timeText = t:Find("TitleArea/Time"):GetComponent(Text)
    self.descText = t:Find("TitleArea/Desc"):GetComponent(Text)

    local descContainer = t:Find("GiftArea/Desc")
    self.descItem = {nil, nil}
    for i=1,2 do
        local tab = {gameObject = nil, trans = nil, iconImage = nil, descText = nil, numText = nil}
        tab.trans = descContainer:Find("Item"..i)
        tab.gameObject = tab.trans.gameObject
        tab.iconLoader = SingleIconLoader.New(tab.trans:Find("Bg/Icon").gameObject)
        tab.descText = tab.trans:Find("Desc"):GetComponent(Text)
        if tab.trans:Find("Bg/NumBg") ~= nil then
            tab.numText = tab.trans:Find("Bg/NumBg/Num"):GetComponent(Text)
        end
        self.descItem[i] = tab
    end

    self.goBuyRoseBtn = t:Find("GiftArea/Show/GoRose"):GetComponent(Button)
    self.goMerryBtn = t:Find("GiftArea/Show/GoMerry"):GetComponent(Button)

    self.goBuyRoseBtn.onClick:AddListener(function() self:OnBuy() end)
    self.goMerryBtn.onClick:AddListener(function() self.model:CloseWindow() QuestManager.Instance.model:FindNpc("44_1") end)
end

function BackendMarryEasy:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendMarryEasy:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backend_campaign_change, self.reloadListener)

    self.campId = self.openArgs.campId
    self.menuId = self.openArgs.menuId

    self.menuData = self.model.backendCampaignTab[self.campId].menu_list[self.menuId]
    self.btnSplitList = StringHelper.Split(self.menuData.button_text, "|")

    self:ReloadList()
    self:InitInfo()
end

function BackendMarryEasy:OnHide()
    self:RemoveListeners()
end

function BackendMarryEasy:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backend_campaign_change, self.reloadListener)
end

function BackendMarryEasy:ReloadList()
    local model = self.model

    local datalist = {}
    local menuData = self.menuData
    -- BaseUtils.dump(menuData, "self.menuData")
    for _,v in pairs(menuData.camp_list) do
        table.insert(datalist, v)
    end
    table.sort(datalist, function(a,b) return a.n < b.n end)

    for i,v in ipairs(datalist) do
        local tab = self.descItem[i]
        if tab ~= nil then
            tab.descText.text = v.str1
        end
    end

    self.descItem[1].descText.text = datalist[1].str1
    self.descItem[1].iconLoader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.dailyicon, "1018"))
    self.descItem[2].descText.text = datalist[2].str1
    self.descItem[2].iconLoader:SetSprite(SingleIconType.Item, DataItem.data_get[datalist[2].items[1].base_id].icon)
    self.descItem[2].numText.text = datalist[2].reward_can
end

function BackendMarryEasy:InitInfo()
    self.titleText.text = self.menuData.title2
    self.descText.text = string.format(self.descFormatString, self.menuData.rule_str)

    local startMonth = tonumber(os.date("%m", self.menuData.start_ime))
    local startDay = tonumber(os.date("%d", self.menuData.start_ime))
    local endMonth = tonumber(os.date("%m", self.menuData.end_time))
    local endDay = tonumber(os.date("%d", self.menuData.end_time))
    self.timeText.text = string.format(self.timeString,
                        string.format(self.dateFormatString,
                            tostring(startMonth),
                            tostring(startDay)),
                        string.format(self.dateFormatString,
                            tostring(endMonth),
                            tostring(endDay)
                        ))
end

function BackendMarryEasy:OnBuy()
    BackendManager.Instance:send14053(self.campId, self.menuId, 2, 1)
end


