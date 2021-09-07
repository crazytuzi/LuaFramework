OpenServerBabyTipsPanel = OpenServerBabyTipsPanel or BaseClass(BasePanel)

function OpenServerBabyTipsPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = OpenServerManager.Instance

    self.resList = {
        {file = AssetConfig.open_server_baby_tips, type = AssetType.Main}
    }

    self.personData = {}
    self.guildData = {}

    self.layoutSetting = {
        axis = BoxLayoutAxis.X
        , cspacing = 5
        , border = 10
    }

    self.itemDataListPerson = {}
    self.itemDataListGuild = {}
    self.itemSlotListPerson = {}
    self.itemSlotListGuild = {}
    self.itemListPerson = {}
    self.itemListGuild = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:Add(self.openListener)
    self.OnHideEvent:Add(self.hideListener)
end

function OpenServerBabyTipsPanel:__delete()
    self.OnHideEvent:Fire()
    if self.itemSlotListPerson ~= nil then
        for i,v in pairs(self.itemSlotListPerson) do
            if v ~= nil then
                v:DeleteMe()
                self.itemSlotListPerson[i] = nil
                v = nil
            end
        end
        self.itemSlotListPerson = nil
    end
    if self.itemDataListPerson ~= nil then
        for i,v in pairs(self.itemDataListPerson) do
            if v ~= nil then
                v:DeleteMe()
                self.itemDataListPerson[i] = nil
                v = nil
            end
        end
        self.itemDataListPerson = nil
    end
    if self.itemDataListGuild ~= nil then
        for i,v in pairs(self.itemDataListGuild) do
            if v ~= nil then
                v:DeleteMe()
                self.itemDataListGuild[i] = nil
                v = nil
            end
        end
        self.itemDataListGuild = nil
    end
    if self.itemSlotListGuild ~= nil then
        for i,v in pairs(self.itemSlotListGuild) do
            if v ~= nil then
                v:DeleteMe()
                self.itemSlotListGuild[i] = nil
                v = nil
            end
        end
        self.itemSlotListGuild = nil
    end
    if self.guildLayout ~= nil then
        self.guildLayout:DeleteMe()
        self.guildLayout = nil
    end
    if self.personLayout ~= nil then
        self.personLayout:DeleteMe()
        self.personLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerBabyTipsPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_baby_tips))
    self.gameObject.name = "BabyTips"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.titleText = t:Find("Main/Title"):GetComponent(Text)
    self.btn = t:Find("Panel"):GetComponent(Button)
    self.honorRect = t:Find("Main/Personal/Honor"):GetComponent(RectTransform)
    self.personalGiftRect = t:Find("Main/Personal/Gift"):GetComponent(RectTransform)
    self.personalContainer = t:Find("Main/Personal/Gift/ScrollLayer/Container")
    self.personalNameText = t:Find("Main/Personal/Honor/Name"):GetComponent(Text)
    self.personalCloner = t:Find("Main/Personal/Gift/ScrollLayer/Cloner").gameObject
    self.guildContainer = t:Find("Main/Guild/ScrollLayer/Container")
    self.guildCloner = t:Find("Main/Guild/ScrollLayer/Cloner").gameObject
    self.bottomDescRect = t:Find("Main/Bottom/Desc"):GetComponent(RectTransform)
    self.bottomDescText = t:Find("Main/Bottom/Desc"):GetComponent(Text)

    self.bottomDescText.text = TI18N("1.当前宝贝相同公会的角色可获得<color=#00FF00>公会奖励</color>\n2.公会新秀不能获得该奖励\n3.公会有多个宝贝上榜，成员只获得<color=#00FF00>最高排名奖励</color>")

    self.btn.onClick:AddListener(function() self.model:CloseBabyGiftTips() end)
    self.guildCloner:SetActive(false)
    self.personalCloner:SetActive(false)
    -- self.bottomDescRect.anchoredPosition = Vector2(0, 0)

    self.OnOpenEvent:Fire()
end

function OpenServerBabyTipsPanel:OnOpen()
    BaseUtils.dump(self.openArgs, "openArgs")

    self.data = self.mgr.guildBabyList[self.openArgs]
    self.rank = self.data.rank
    if self.data ~= nil then
        self.personData = self.mgr.guildBabyList[self.openArgs].role_reward
        self.guildData = self.mgr.guildBabyList[self.openArgs].guild_reward
    else
        self.guildData = {}
        self.personData = {}
    end
    self:ReloadGifts()
    self:RemoveListeners()
end

function OpenServerBabyTipsPanel:OnHide()
    self:RemoveListeners()
end

function OpenServerBabyTipsPanel:RemoveListeners()
end

function OpenServerBabyTipsPanel:ReloadGifts()
    self.titleText.text = string.format(TI18N("第%s名奖励"), tostring(BaseUtils.NumToChn(self.rank)))
    if self.personLayout == nil then
        self.personLayout = LuaBoxLayout.New(self.personalContainer, self.layoutSetting)
    end
    if self.guildLayout == nil then
        self.guildLayout = LuaBoxLayout.New(self.guildContainer, self.layoutSetting)
    end
    local obj = nil
    for i,v in pairs(self.personData) do
        if self.itemListPerson[i] == nil then
            obj = GameObject.Instantiate(self.personalCloner)
            obj.name = tostring(i)
            self.personLayout:AddCell(obj)
            self.itemListPerson[i] = obj
        end
        obj = self.itemListPerson[i]
        if self.itemDataListPerson[i] == nil then
            self.itemDataListPerson[i] = ItemData.New()
        end
        self.itemDataListPerson[i]:SetBase(DataItem.data_get[v.item_id])
        if self.itemSlotListPerson[i] == nil then
            self.itemSlotListPerson[i] = ItemSlot.New()
            NumberpadPanel.AddUIChild(obj, self.itemSlotListPerson[i].gameObject)
        end
        self.itemSlotListPerson[i]:SetAll(self.itemDataListPerson[i], {inbag = false, nobutton = true})
        self.itemSlotListPerson[i]:SetNum(v.num)
        obj:SetActive(true)
    end
    for i=#self.personData + 1, #self.itemListPerson do
        self.itemListPerson[i]:SetActive(false)
    end

    for i,v in pairs(self.guildData) do
        if self.itemListGuild[i] == nil then
            obj = GameObject.Instantiate(self.personalCloner)
            obj.name = tostring(i)
            self.guildLayout:AddCell(obj)
            self.itemListGuild[i] = obj
        end
        obj = self.itemListGuild[i]
        if self.itemDataListGuild[i] == nil then
            self.itemDataListGuild[i] = ItemData.New()
        end
        self.itemDataListGuild[i]:SetBase(DataItem.data_get[v.item_id])
        if self.itemSlotListGuild[i] == nil then
            self.itemSlotListGuild[i] = ItemSlot.New()
            NumberpadPanel.AddUIChild(obj, self.itemSlotListGuild[i].gameObject)
        end
        self.itemSlotListGuild[i]:SetAll(self.itemDataListGuild[i], {inbag = false, nobutton = true})
        self.itemSlotListGuild[i]:SetNum(v.num)
        obj:SetActive(true)
    end
    for i=#self.guildData + 1, #self.itemListGuild do
        self.itemListGuild[i]:SetActive(false)
    end

    if self.data.honor > 0 then
        self.honorRect.gameObject:SetActive(true)
        self.personalGiftRect.anchoredPosition = Vector2(0,-50)
        self.personalNameText.text = tostring(DataHonor.data_get_honor_list[self.data.honor].name)
    else
        self.honorRect.gameObject:SetActive(false)
        self.personalGiftRect.anchoredPosition = Vector2(0, -37)
    end

    self.bottomDescRect.sizeDelta = Vector2(332, self.bottomDescText.preferredHeight)
end
