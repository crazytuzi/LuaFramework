-- 公会副本
-- ljh 20170301
GuildDungeonSoldierWindow = GuildDungeonSoldierWindow or BaseClass(BaseWindow)

function GuildDungeonSoldierWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.guilddungeonsoldierwindow
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.guilddungeonsoldierwindow, type = AssetType.Main}
        ,{file = AssetConfig.guilddungeon_textures, type = AssetType.Dep}
        ,{file = AssetConfig.rank_textures, type = AssetType.Dep}
        ,{file = AssetConfig.world_boss_head_icon, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 10096), type = AssetType.Main}
    }


    -----------------------------------------------------------
    self.soldierItemList = {}
    self.soldierItemRewardItemList = {}
    self.soldierItemEffectList = {}

    self.cellObjList = {}

    self.watchRewardItemList = {}

    self.rewardItemList = {}
    self.headLoaderList = {}

    self.descTips = {TI18N("1.每场战斗造成的伤害会<color='#ffff00'>累积</color>")
                , TI18N("2.英雄榜<color='#ffff00'>前3名</color>会获得兄弟币奖励")
            }

    -----------------------------------------------------------
    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self._Update = function() self:Update() end
    self._UpdateSoldier = function() self:UpdateSoldier() self:UpdateRewardItem() end
    self._UpdateRank = function() self:UpdateRank() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function GuildDungeonSoldierWindow:__delete()
    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    for k,v in pairs(self.rewardItemList) do
        v:DeleteMe()
        v = nil
    end
    for k,v in pairs(self.watchRewardItemList) do
        v:DeleteMe()
        v = nil
    end

    for soldierItemRewardItemIndex,soldierItemRewardItem in pairs(self.soldierItemRewardItemList) do
        for k,v in pairs(soldierItemRewardItem) do
            v:DeleteMe()
            v = nil
        end
    end

    self.OnHideEvent:Fire()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.cellObjList ~= nil then
        for _,v in pairs(self.cellObjList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.cellObjList = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GuildDungeonSoldierWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddungeonsoldierwindow))
    self.gameObject.name = "GuildDungeonSoldierWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.mainTransform:FindChild("Close"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.soldierPanel = self.mainTransform:Find("SoldierPanel").gameObject
    self.rankPanel = self.mainTransform:Find("RankPanel").gameObject

    self.titleText = self.mainTransform:Find("Title/Text"):GetComponent(Text)
    self.timeText = self.mainTransform:FindChild("SoldierPanel/TimeItem/TimeText"):GetComponent(Text)

    self.soldierContainer = self.mainTransform:Find("SoldierPanel/Panel/Container").gameObject
    self.soldierCloner = self.soldierContainer.transform:Find("Cloner").gameObject
    self.soldierCloner:SetActive(false)
    self.soldierNothing = self.mainTransform:Find("SoldierPanel/Panel/Nothing").gameObject
    self.mainTransform:Find("SoldierPanel/Panel"):GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChanged() end)

    self.upArrow = self.mainTransform:FindChild("SoldierPanel/UpArrow").gameObject
    self.downArrow = self.mainTransform:FindChild("SoldierPanel/DownArrow").gameObject

    self.mainTransform:FindChild("SoldierPanel/DescButton"):GetComponent(Button).onClick:AddListener(function()
            TipsManager.Instance:ShowText({gameObject = self.mainTransform:FindChild("SoldierPanel/DescButton").gameObject, itemData = self.descTips})
        end)

    self.infoContainer = self.mainTransform:Find("RankPanel/Panel/Container").gameObject
    self.infoContainerRect = self.infoContainer:GetComponent(RectTransform)
    self.cloner = self.infoContainer.transform:Find("Cloner").gameObject
    self.vScroll = self.mainTransform:Find("RankPanel/Panel").gameObject:GetComponent(ScrollRect)
    self.nothing = self.mainTransform:Find("RankPanel/Panel/Nothing").gameObject

    self.setting_data = {
       item_list = self.cellObjList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.infoContainer  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.infoContainer:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.vScroll:GetComponent(RectTransform).sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.Layout = LuaBoxLayout.New(self.infoContainer, {axis = BoxLayoutAxis.Y, cspacing = 0})

    local obj = nil
    for i=1,15 do
        obj = GameObject.Instantiate(self.cloner)
        obj.name = tostring(i)
        self.Layout:AddCell(obj)
        self.cellObjList[i] = GuildDungeonRankItem.New(self.model, obj, self.assetWrapper)
    end

    self.rewardPanelContainer = self.mainTransform:FindChild("RankPanel/RewardPanel/Container")
    for i=1, 12 do
        local itemSlot = self.rewardItemList[i]
        if itemSlot == nil then
            itemSlot = ItemSlot.New()
            itemSlot.transform:SetParent(self.rewardPanelContainer)
            itemSlot.transform.localScale = Vector3(1, 1, 1)

            self.rewardItemList[i] = itemSlot
        end
    end

    self.watchRewardPanel = self.mainTransform:Find("WatchRewardPanel").gameObject
    self.watchRewardPanel:SetActive(false)
    self.watchRewardPanelContainer = self.mainTransform:Find("WatchRewardPanel/Container")
    self.watchRewardPanel:GetComponent(Button).onClick:AddListener(function() self.watchRewardPanel:SetActive(false) end)


    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup").gameObject
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, { notAutoSelect = true })
end

function GuildDungeonSoldierWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function GuildDungeonSoldierWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDungeonSoldierWindow:OnOpen()
    if self.openArgs ~= nil and #self.openArgs > 1 then
        self.chapter_id = self.openArgs[1]
        self.strongpoint_id = self.openArgs[2]
        self.data = self.openArgs[3]
        if #self.openArgs > 3 then
            self.tabGroup:ChangeTab(self.openArgs[4])
        end
    end

    self:Update()

    GuildDungeonManager.Instance.OnUpdateRank:Add(self._UpdateRank)
    GuildDungeonManager.Instance:Send19502(self.chapter_id, self.strongpoint_id)

    GuildDungeonManager.Instance.OnUpdate:Add(self._UpdateSoldier)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 5000, function() GuildDungeonManager.Instance:Send19500() end)
end

function GuildDungeonSoldierWindow:OnHide()
    GuildDungeonManager.Instance.OnUpdateRank:Remove(self._UpdateRank)
    GuildDungeonManager.Instance.OnUpdate:Remove(self._UpdateSoldier)

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function GuildDungeonSoldierWindow:ChangeTab(index)
    if self.view_index == index then return end
    self.view_index = index

    if self.view_index == 1 then
        self.soldierPanel:SetActive(true)
        self.rankPanel:SetActive(false)

        self:UpdateSoldier()
    else
        self.soldierPanel:SetActive(false)
        self.rankPanel:SetActive(true)

        self:UpdateRank()
        self:UpdateRewardItem()
    end
end

function GuildDungeonSoldierWindow:Update()
    self.titleText.text = DataGuildDungeon.data_strongpoint[string.format("%s_%s", self.chapter_id, self.strongpoint_id)].strongpoint_name
    self:UpdateSoldier()
    self:UpdateRank()
    self:UpdateRewardItem()
end

function GuildDungeonSoldierWindow:UpdateSoldier()
    local data = nil
    if self.model.guild_dungeon_chapter.chapters ~= nil then
        for chapterIndex, chapter in ipairs(self.model.guild_dungeon_chapter.chapters) do
            if chapter.chapter_id == self.chapter_id then
                for strongpointIndex, strongpoint in ipairs(chapter.strongpoints) do
                    if strongpoint.strongpoint_id == self.strongpoint_id then
                        data = strongpoint.monsters
                    end
                end
            end
        end
    end
    if data == nil then
        return
    end

    self.activeTime = self.model:CheckTime()

    -- local data = self.data.monsters
    if #data == 0 then
        self.soldierNothing:SetActive(true)
    else
        self.soldierNothing:SetActive(false)
    end

    data = BaseUtils.copytab(data)
    local function sortfun(a,b)
        return a.challenge == 1 and b.challenge ~= 1
            or (a.challenge ~= 1 and b.challenge ~= 1 and a.challenge == 3 and b.challenge ~= 3)
            or (a.challenge ~= 1 and b.challenge ~= 1 and a.challenge ~= 3 and b.challenge ~= 3 and a.challenge == 2 and b.challenge ~= 2)
            or (a.challenge == 1 and b.challenge == 1 and a.unique < b.unique)
            or (a.challenge == 2 and b.challenge == 2 and a.unique < b.unique)
            or (a.challenge == 3 and b.challenge == 3 and a.unique < b.unique)
    end

    table.sort(data, sortfun)

    for index, value in ipairs(data) do
        local soldierItem = self.soldierItemList[index]
        if soldierItem == nil then
            soldierItem = GameObject.Instantiate(self.soldierCloner)
            soldierItem.transform:SetParent(self.soldierContainer.transform)
            soldierItem.transform.localScale = Vector3(1, 1, 1)

            local battleEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 10096)))
            battleEffect.transform:SetParent(soldierItem.transform:Find("StateIcon"))
            battleEffect.transform.localRotation = Quaternion.identity
            Utils.ChangeLayersRecursively(battleEffect.transform, "UI")
            battleEffect.transform.localScale = Vector3(150, 150, 1)
            battleEffect.transform.localPosition = Vector3(0, -20, -400)

            self.soldierItemList[index] = soldierItem
            self.soldierItemRewardItemList[index] = {}
            self.soldierItemEffectList[index] = { gameObject = battleEffect, active = false }
        end

        soldierItem:SetActive(true)
        self:UpdateItem(index, soldierItem, value)
    end

    for i=#data+1, #self.soldierItemList do
        self.soldierItemList[i]:SetActive(false)
    end

    local color = "#00ff00"
    if self.model.guild_dungeon_chapter.times == 0 then
        color = "#ff0000"
    end
    self.timeText.text = string.format(TI18N("今日可挑战次数：<color='%s'>%s/%s</color>"), color, self.model.guild_dungeon_chapter.times, 2)

    self:OnValueChanged()
end

function GuildDungeonSoldierWindow:UpdateItem(index, item, data)
    -- print(string.format("%s_%s_%s", self.chapter_id, self.strongpoint_id, data.monster_id))
    local data_unit = DataGuildDungeon.data_unit[string.format("%s_%s_%s", self.chapter_id, self.strongpoint_id, data.unique)]
    -- item.transform:Find("Image/Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(data_unit.head_id), data_unit.head_id)

    if data_unit.head_type == 1 then
        local loaderId = item.transform:Find("Image/Icon"):GetComponent(Image).gameObject:GetInstanceID()
        if self.headLoaderList[loaderId] == nil then
            self.headLoaderList[loaderId] = SingleIconLoader.New(item.transform:Find("Image/Icon"):GetComponent(Image).gameObject)
        end
        self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,data_unit.head_id)
        -- item.transform:Find("Image/Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(data_unit.head_id), data_unit.head_id)
    else
        item.transform:Find("Image/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.world_boss_head_icon, data_unit.head_id)
    end

    item.transform:FindChild("NameBg/NameText"):GetComponent(Text).text = DataUnit.data_unit[data_unit.id].name
    item.transform:FindChild("Slider"):GetComponent(Slider).value = data.percent / 1000
    item.transform:FindChild("Slider/ProgressTxt"):GetComponent(Text).text = string.format("%s%%", data.percent / 10)

    if data.challenge == 1 then
        item.transform:FindChild("ClassesText"):GetComponent(Text).text = data_unit.classes
        -- self:UpdateItemClassesText(item, data_unit)
        item.transform:FindChild("StateIcon").gameObject:SetActive(false)
        self.soldierItemEffectList[index].active = false
        item.transform:FindChild("StateText"):GetComponent(Text).text = ""
        item.transform:FindChild("Button").gameObject:SetActive(true)
        item.transform:FindChild("Task").gameObject:SetActive(false)

        if self.model.guild_dungeon_chapter.active == 2 and not self.activeTime then
            item.transform:FindChild("Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            item.transform:FindChild("Button/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "DoubleSword")
            item.transform:FindChild("Button/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton4Str, TI18N("进 攻"))
        else
            item.transform:FindChild("Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            item.transform:FindChild("Button/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "DoubleSword")
            item.transform:FindChild("Button/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("进 攻"))
        end

        item.transform:FindChild("LastHitText"):GetComponent(Text).text = ""
        item.transform:FindChild("WatchRewardButton").gameObject:SetActive(true)
        item.transform:FindChild("RewardTitle").gameObject:SetActive(false)
        item.transform:FindChild("RewardPanel").gameObject:SetActive(false)

        local button = item.transform:FindChild("Button"):GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener(function() self:OnClickSoldierButton(1, data.unique) end)

        button = item.transform:FindChild("WatchRewardButton"):GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener(function() self:OnClickWatchRewardButton(button.transform, data_unit.client_reward) end)
    elseif data.challenge == 2 then
        item.transform:FindChild("ClassesText"):GetComponent(Text).text = ""
        item.transform:FindChild("StateText"):GetComponent(Text).text = TI18N("<color='#ff0000'>不可挑战</color>")
        self.soldierItemEffectList[index].active = false
        item.transform:FindChild("StateIcon").gameObject:SetActive(false)
        item.transform:FindChild("Button").gameObject:SetActive(false)
        item.transform:FindChild("Task").gameObject:SetActive(false)

        item.transform:FindChild("LastHitText"):GetComponent(Text).text = ""
        item.transform:FindChild("WatchRewardButton").gameObject:SetActive(true)
        item.transform:FindChild("RewardTitle").gameObject:SetActive(false)
        item.transform:FindChild("RewardPanel").gameObject:SetActive(false)
    elseif data.challenge == 3 then
        item.transform:FindChild("ClassesText"):GetComponent(Text).text = ""
        item.transform:FindChild("StateText"):GetComponent(Text).text = data.role_name
        self.soldierItemEffectList[index].active = true
        item.transform:FindChild("StateIcon").gameObject:SetActive(true)
        item.transform:FindChild("Button").gameObject:SetActive(true)
        item.transform:FindChild("Task").gameObject:SetActive(false)

        if self.model.guild_dungeon_chapter.active == 2 then
            item.transform:FindChild("Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            item.transform:FindChild("Button/Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "PlayerTips_watchicon")
            item.transform:FindChild("Button/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton4Str, TI18N("观 战"))
        else
            item.transform:FindChild("Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            item.transform:FindChild("Button/Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "PlayerTips_watchicon")
            item.transform:FindChild("Button/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton1Str, TI18N("观 战"))
        end

        item.transform:FindChild("LastHitText"):GetComponent(Text).text = ""
        item.transform:FindChild("WatchRewardButton").gameObject:SetActive(true)
        item.transform:FindChild("RewardTitle").gameObject:SetActive(false)
        item.transform:FindChild("RewardPanel").gameObject:SetActive(false)

        local button = item.transform:FindChild("Button"):GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener(function() self:OnClickSoldierButton(2, data.unique) end)
    elseif data.challenge == 4 then
        item.transform:FindChild("ClassesText"):GetComponent(Text).text = ""
        item.transform:FindChild("StateText"):GetComponent(Text).text = ""
        self.soldierItemEffectList[index].active = false
        item.transform:FindChild("StateIcon").gameObject:SetActive(false)
        item.transform:FindChild("Button").gameObject:SetActive(false)
        item.transform:FindChild("Task").gameObject:SetActive(true)

        item.transform:FindChild("LastHitText"):GetComponent(Text).text = string.format(TI18N("<color='#3166ad'>击杀：</color>%s"), data.role_name)
        item.transform:FindChild("WatchRewardButton").gameObject:SetActive(false)
        item.transform:FindChild("RewardTitle").gameObject:SetActive(true)
        item.transform:FindChild("RewardPanel").gameObject:SetActive(true)

        local list = self.soldierItemRewardItemList[index]
        for i, value in ipairs(data.rewards) do
            local itemSlot = list[i]
            if itemSlot == nil then
                itemSlot = ItemSlot.New()
                local layoutElement = itemSlot.gameObject:AddComponent(LayoutElement)
                layoutElement.preferredHeight = 64
                layoutElement.preferredWidth = 64
                itemSlot.transform:SetParent(item.transform:FindChild("RewardPanel/Container"))
                itemSlot.transform.localScale = Vector3(1, 1, 1)

                list[i] = itemSlot
            end

            local itembase = BackpackManager.Instance:GetItemBase(value.item_id)
            local itemData = ItemData.New()
            itemData:SetBase(itembase)
            itemData.quantity = value.item_num
            itemSlot:SetAll(itemData, {nobutton = true})
            -- itemSlot:SetNotips(true)
            itemSlot.gameObject:SetActive(true)

            -- itemSlot.gameObject:GetComponent(Button).onClick:RemoveAllListeners()
            -- itemSlot.gameObject:GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowTalisman({itemData = DataTalisman.data_get[value.item_id]}) end)
        end

        for i=#data.rewards+1, #list do
            list[i].gameObject:SetActive(false)
        end
    end
end

function GuildDungeonSoldierWindow:UpdateItemClassesText(item, data_unit)
    local classesText = ""
    for index, classes in ipairs(data_unit.classes) do
        if index == 1 then
            classesText = string.format("%s", KvData.classes_name[classes])
        else
            classesText = string.format("%s、%s", classesText, KvData.classes_name[classes])
        end
    end
    item.transform:FindChild("ClassesText"):GetComponent(Text).text = string.format(TI18N("推荐：<color='#248813'>%s</color>"), classesText)
end

function GuildDungeonSoldierWindow:UpdateRank()
    local datalist = self.model.rankData[string.format("%s_%s", self.chapter_id, self.strongpoint_id)]
    -- BaseUtils.dump(datalist, "UpdateRank")
    if datalist == nil then
        datalist = {}
    end
    if #datalist == 0 then
        self.nothing:SetActive(true)
    else
        self.nothing:SetActive(false)
    end

    self.setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.setting_data)
end

function GuildDungeonSoldierWindow:UpdateRewardItem()
    local rewards = self.data.rewards
    for i, value in ipairs(rewards) do
        local itemSlot = self.rewardItemList[i]
        if itemSlot == nil then
            for index = i, i+5 do
                itemSlot = ItemSlot.New()
                itemSlot.transform:SetParent(self.rewardPanelContainer)
                itemSlot.transform.localScale = Vector3(1, 1, 1)

                self.rewardItemList[index] = itemSlot
            end
        end

        local itembase = BackpackManager.Instance:GetItemBase(value.item_id)
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        itemData.quantity = value.item_num
        itemSlot:SetAll(itemData, {nobutton = true})
        -- itemSlot:SetNotips(true)
        itemSlot.gameObject:SetActive(true)

        -- itemSlot.gameObject:GetComponent(Button).onClick:RemoveAllListeners()
        -- itemSlot.gameObject:GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowTalisman({itemData = DataTalisman.data_get[value.item_id]}) end)
    end

    local startIndex = 0
    if #rewards % 6 == 0 then
        startIndex = #rewards + 1
    else
        startIndex = #rewards + (6 - (#rewards % 6)) + 1
    end
    if startIndex < 13 then
        startIndex = 13
    end
    for i=#rewards+1, startIndex-1 do
        local itemSlot = self.rewardItemList[i]
        itemSlot:Default(1)
    end
    for i=startIndex, #self.rewardItemList do
        self.rewardItemList[i].gameObject:SetActive(false)
    end
end

function GuildDungeonSoldierWindow:OnClickSoldierButton(type, unique)
    if self.model.guild_dungeon_chapter.active == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启，敬请期待！"))
    elseif self.model.guild_dungeon_chapter.active == 2 then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启，敬请期待！"))
    elseif not self.activeTime then
        NoticeManager.Instance:FloatTipsByString(TI18N("勇士请于周一至周六11:00~23:00时间段进行挑战"))
    else
        if type == 1 then
            GuildDungeonManager.Instance:Send19501(self.chapter_id, self.strongpoint_id, unique)
        elseif type == 2 then
            GuildDungeonManager.Instance:Send19504(self.chapter_id, self.strongpoint_id, unique)
        end
    end
end

function GuildDungeonSoldierWindow:OnClickWatchRewardButton(transform, reward)
    self.watchRewardPanel:SetActive(true)
    local pos = transform.position
    self.watchRewardPanelContainer.position = Vector2(pos.x - 0.1, pos.y)

    for index, value in ipairs(reward) do
        local watchRewardItem = self.watchRewardItemList[index]
        if watchRewardItem == nil then
            watchRewardItem = ItemSlot.New()
            watchRewardItem.transform:SetParent(self.watchRewardPanelContainer)
            watchRewardItem.transform.localScale = Vector3(1, 1, 1)

            self.watchRewardItemList[index] = watchRewardItem
        end

        local itembase = BackpackManager.Instance:GetItemBase(value[1])
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        itemData.quantity = value[2]
        watchRewardItem:SetAll(itemData)
        watchRewardItem.gameObject:SetActive(true)
    end

    for i=#reward+1, #self.watchRewardItemList do
        self.watchRewardItemList[i].gameObject:SetActive(false)
    end
end

function GuildDungeonSoldierWindow:OnValueChanged()
    local container = self.soldierContainer.transform
    local y = container.anchoredPosition.y
    local height = container.parent.rect.height

    for _,v in pairs(self.soldierItemEffectList) do
        if v ~= nil and v.active and v.gameObject ~= nil and not BaseUtils.is_null(v.gameObject) then
            local item = v.gameObject.transform.parent.parent
            local outY = -item.anchoredPosition.y < y or -item.anchoredPosition.y + item.sizeDelta.y > y + height
            v.gameObject:SetActive(not outY)
        end
    end

    if y < 10 then
        self.upArrow:SetActive(false)
    else
        self.upArrow:SetActive(true)
    end

    if container.rect.height - y > height + 10 then
        self.downArrow:SetActive(true)
    else
        self.downArrow:SetActive(false)
    end
end
