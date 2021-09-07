-- @author 黄耀聪
-- @date 2017年3月5日

GuildSiegeSettle = GuildSiegeSettle or BaseClass(BaseWindow)

function GuildSiegeSettle:__init(model)
    self.model = model
    self.name = "GuildSiegeSettle"

    self.windowId = WindowConfig.WinID.guild_siege_settle

    self.resList = {
        {file = AssetConfig.guildsiege_settle, type = AssetType.Main},
        {file = AssetConfig.guildsiege, type = AssetType.Dep},
    }

    self.effectList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildSiegeSettle:__delete()
    self.OnHideEvent:Fire()
    if self.rewardList ~= nil then
        for _,v in pairs(self.rewardList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.data:DeleteMe()
            end
        end
    end
    if self.rewardLayout ~= nil then
        self.rewardLayout:DeleteMe()
        self.rewardLayout = nil
    end
    self:AssetClearAll()
end

function GuildSiegeSettle:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildsiege_settle))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.starList = {}
    for i=1,3 do
        local tab = {}
        tab.transform = t:Find("Main/Star" .. i)
        tab.gameObject = tab.transform.gameObject
        tab.image = tab.gameObject:GetComponent(Image)
        self.starList[i] = tab
    end

    self.closeBtn = t:Find("Panel1"):GetComponent(Button)
    self.infoText = t:Find("Main/Info"):GetComponent(Text)
    self.win = t:Find("Main/Win").gameObject
    self.loss = t:Find("Main/Loss").gameObject
    self.light = t:Find("Main/Light").gameObject

    self.rewardList = {}
    self.rewardContainer = t:Find("Main/Reward")
    local length = self.rewardContainer.childCount

    self.rewardLayout = LuaBoxLayout.New(self.rewardContainer, {cspacing = 0, border = 5, axis = BoxLayoutAxis.X})
    for i=1,length do
        local tab = {}
        tab.transform = self.rewardContainer:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.slot = ItemSlot.New()
        NumberpadPanel.AddUIChild(tab.transform, tab.slot.gameObject)
        tab.data = ItemData.New()
        self.rewardList[i] = tab
    end

    self.closeBtn.onClick:AddListener(function()
        -- if self.model.status ~= GuildSiegeEumn.Status.Disactive then
        if true then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_siege_castle_window)
        else
            WindowManager.Instance:CloseWindow(self)
        end
    end)
end

function GuildSiegeSettle:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildSiegeSettle:OnOpen()
    self:RemoveListeners()

    self.data = (self.openArgs or {})[1] or {
        is_win = 1,
        order = 1,
        name = "测试数据",
        star = 2,
        items = {
            {item_id = 90002, num = 200000},
            {item_id = 90000, num = 30},
        }
    }

    self:Reload(self.data)
end

function GuildSiegeSettle:OnHide()
    self:RemoveListeners()
    for _,v in pairs(self.starList) do
        if v.timerId ~= nil then
            LuaTimer.Delete(v.timerId)
        end
    end
end

function GuildSiegeSettle:RemoveListeners()
end

function GuildSiegeSettle:ReloadStar(all, win)
    for i=1,3 do
        -- self.starList[i].gameObject:SetActive(i <= all)
        self.starList[i].image.sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "DarkStar")
    end

    self.starList[1].transform.anchoredPosition = Vector2(-80, 150)
    self.starList[2].transform.anchoredPosition = Vector2(0, 170)
    self.starList[3].transform.anchoredPosition = Vector2(80, 150)

    if win then
        self:PlayStar(all)
    end
end

function GuildSiegeSettle:Reload(data)
    local resString = TI18N("失败")
    if data.is_win == 1 then
        resString = TI18N("成功")
    end
    self.infoText.text = string.format(TI18N("挑战<color='#ffff00'>%s</color>%s星难度%s"), data.name, data.star, resString)

    self.rewardLayout:ReSet()
    for i,v in ipairs(data.items) do
        local tab = self.rewardList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.rewardList[1].gameObject)
            tab.transform = tab.gameObject.transform
            tab.slot = ItemSlot.New(tab.transform:GetChild(0).gameObject)
            tab.data = ItemData.New()
            self.rewardList[i] = tab
        end

        if v.item_id ~= tab.data.base_id then
            tab.data:SetBase(DataItem.data_get[v.item_id])
            tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
        end
        tab.slot:SetNum(v.num)
        self.rewardLayout:AddCell(tab.gameObject)
    end
    for i=#data.items + 1,#self.rewardList do
        self.rewardList[i].gameObject:SetActive(false)
    end
    self.win:SetActive(data.is_win == 1)
    self.loss:SetActive(data.is_win ~= 1)
    self.light:SetActive(data.is_win == 1)

    self:ReloadStar(data.star, data.is_win == 1)
end

function GuildSiegeSettle:PlayStar(all)
    for i=1,all do
        LuaTimer.Add((i - 1) * 500, function()
            if self.effectList[i] == nil then
                self.effectList[i] = BibleRewardPanel.ShowEffect(20324, self.starList[i].transform, Vector3(1, 1, 1), Vector3(0, -3, -900))
            else
                self.effectList[i]:SetActive(true)
            end
        end)
        self.starList[i].timerId = LuaTimer.Add(i * 500, function() self.starList[i].image.sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Star") end)
    end
end
