-- 公会副本 Boss
-- ljh 20170301
GuildDungeonBossWindow = GuildDungeonBossWindow or BaseClass(BaseWindow)

function GuildDungeonBossWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.guilddungeonbosswindow
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.guilddungeonbosswindow, type = AssetType.Main}
        ,{file = AssetConfig.guilddungeon_textures, type = AssetType.Dep}
        ,{file = AssetConfig.rank_textures, type = AssetType.Dep}
        ,{file = AssetConfig.dailyicon, type = AssetType.Dep}
        -- ,{file = AssetConfig.homeTexture, type = AssetType.Dep}
        ,{file = AssetConfig.world_boss_head_icon, type = AssetType.Dep}
        ,{file = AssetConfig.rolebgnew, type = AssetType.Dep}
        ,{file = AssetConfig.rolebgstand, type = AssetType.Dep}
    }


    -----------------------------------------------------------
    -- self.rankItemList = {}
    self.rewardItemList = {}
    self.cellObjList = {}

    self.descTips = {TI18N("1、每场战斗造成的伤害将<color='#ffff00'>累计</color>")
            , TI18N("2、当BOSS<color='#ffff00'>生命值为0</color>时获得胜利")
            , TI18N("3、英雄榜<color='#ffff00'>前3名</color>会获得兄弟币奖励")
        }

    -----------------------------------------------------------
    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self._Update = function() self:Update() end
    self._UpdateBoss = function() self:UpdateBoss() end
    self._UpdateRank = function() self:UpdateRank() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function GuildDungeonBossWindow:__delete()
    for k,v in pairs(self.rewardItemList) do
        v:DeleteMe()
        v = nil
    end

    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end

    self.OnHideEvent:Fire()

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
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

function GuildDungeonBossWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddungeonbosswindow))
    self.gameObject.name = "GuildDungeonBossWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.mainTransform:FindChild("Close"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.bossPanel = self.mainTransform:Find("BossPanel").gameObject
    self.rankPanel = self.mainTransform:Find("RankPanel").gameObject

    self.bossPanel.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.bossPanel.transform:Find("Bg/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgstand, "RoleStandBottom")

    self.titleText = self.mainTransform:Find("Title/Text"):GetComponent(Text)

    local setting = {
        name = "PetView"
        ,orthographicSize = 0.8
        ,width = 300
        ,height = 300
        ,offsetY = -0.4
    }

    self.previewComposite = PreviewComposite.New(nil, setting, {})
    self.previewComposite:BuildCamera(true)
    self.rawImage = self.previewComposite.rawImage
    self.rawImage.transform:SetParent(self.mainTransform)
    self.rawImage.gameObject:SetActive(false)
    self.modelPreview = self.mainTransform:FindChild("BossPanel/Preview")

    self.timeText = self.mainTransform:Find("BossPanel/TimeItem/TimeText"):GetComponent(Text)
    self.slider = self.mainTransform:FindChild("BossPanel/Slider"):GetComponent(Slider)
    self.progressText = self.mainTransform:FindChild("BossPanel/Slider/ProgressTxt"):GetComponent(Text)
    self.task = self.mainTransform:FindChild("BossPanel/Task").gameObject
    self.head = self.mainTransform:FindChild("BossPanel/Head").gameObject

    -- for i=1,3 do
    --     -- local obj = self.mainTransform:FindChild("BossPanel/Item"..i).gameObject
    --     -- self.rankItemList[i] = GuildDungeonRankItem.New(self.model, obj, self.assetWrapper)
    --     self.rankItemList[i] = self.mainTransform:FindChild("BossPanel/Item"..i)
    -- end

    self.rewardPanelContainer = self.mainTransform:FindChild("BossPanel/RewardPanel/Container")
    for i=1, 12 do
        local itemSlot = self.rewardItemList[i]
        if itemSlot == nil then
            itemSlot = ItemSlot.New()
            itemSlot.transform:SetParent(self.rewardPanelContainer)
            itemSlot.transform.localScale = Vector3(1, 1, 1)

            self.rewardItemList[i] = itemSlot
        end
    end

    self.mainTransform:FindChild("BossPanel/OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnGotoButtonClick() end)

    self.mainTransform:FindChild("BossPanel/DescButton"):GetComponent(Button).onClick:AddListener(function()
            TipsManager.Instance:ShowText({gameObject = self.mainTransform:FindChild("BossPanel/DescButton").gameObject, itemData = self.descTips})
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

    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup").gameObject
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end)
end

function GuildDungeonBossWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function GuildDungeonBossWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDungeonBossWindow:OnOpen()
    if self.openArgs ~= nil and #self.openArgs > 1 then
        self.chapter_id = self.openArgs[1]
        self.strongpoint_id = self.openArgs[2]
        self.data = self.openArgs[3]
        if #self.openArgs > 3 then
            self.tabGroup:ChangeTab(self.openArgs[4])
        end
    end

    self:Update()

    GuildDungeonManager.Instance.OnUpdateRank:Add(self._Update)
    GuildDungeonManager.Instance:Send19502(self.chapter_id, self.strongpoint_id)
end

function GuildDungeonBossWindow:OnHide()
    GuildDungeonManager.Instance.OnUpdateRank:Remove(self._Update)
end

function GuildDungeonBossWindow:ChangeTab(index)
    if self.view_index == index then return end
    self.view_index = index

    if self.view_index == 1 then
        self.bossPanel:SetActive(true)
        self.rankPanel:SetActive(false)
    else
        self.bossPanel:SetActive(false)
        self.rankPanel:SetActive(true)
    end
end

function GuildDungeonBossWindow:Update()
    self.titleText.text = DataGuildDungeon.data_strongpoint[string.format("%s_%s", self.chapter_id, self.strongpoint_id)].strongpoint_name
    self:UpdateBoss()
    self:UpdateRank()
end

function GuildDungeonBossWindow:UpdateBoss()
    local color = "#00ff00"
    if self.model.guild_dungeon_chapter.boss_times == 0 then
        color = "#ff0000"
    end
    self.timeText.text = string.format(TI18N("今日可挑战次数：<color='%s'>%s/%s</color>"), color, self.model.guild_dungeon_chapter.boss_times, 1)
    self.slider.value = self.data.percent / 1000
    self.progressText.text = string.format("%s%%", self.data.percent / 10)
    self.task:SetActive(self.data.percent <= 0)

    local data_unit = DataGuildDungeon.data_unit[ string.format("%s_%s_%s", self.chapter_id, self.strongpoint_id, self.data.monsters[1].unique)]
    if data_unit.head_type == 1 then
        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.head:GetComponent(Image).gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet, data_unit.head_id)
        -- self.head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(data_unit.head_id), data_unit.head_id)
    else
        self.head:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.world_boss_head_icon, data_unit.head_id)
    end

    self:UpdateModel()
    -- self:UpdateRankItem()
    self:UpdateRewardItem()
end

function GuildDungeonBossWindow:UpdateModel()
    -- print(string.format("%s %s %s", self.chapter_id, self.strongpoint_id, self.data.monsters[1].monster_id))
    local data_unit = DataUnit.data_unit[self.data.monsters[1].monster_id]
    local scale = DataGuildDungeon.data_unit[ string.format("%s_%s_%s", self.chapter_id, self.strongpoint_id, self.data.monsters[1].unique)].boss_scale
    local data = {type = PreViewType.Npc, skinId = data_unit.skin, modelId = data_unit.res, animationId = data_unit.animation_id, scale = scale / 100, effects = data_unit.effects}
    if self.modelData ~= nil and BaseUtils.sametab(data, self.modelData) then
        return
    end

    self.previewComposite:Reload(data, function(composite) self:PreviewLoaded(composite) end)
    self.modelData = data
end

function GuildDungeonBossWindow:PreviewLoaded(composite)
    local rawImage = composite.rawImage
    rawImage.gameObject:SetActive(true)
    rawImage.transform:SetParent(self.modelPreview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.identity
    -- composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
end

-- function GuildDungeonBossWindow:UpdateRankItem()
--     local datalist = self.model.rankData[string.format("%s_%s", self.chapter_id, self.strongpoint_id)]
--     if datalist == nil then
--         datalist = {}
--     end
--     for i=1,3 do
--         local rankItem = self.rankItemList[i]
--         rankItem:Find("RankValue/RankImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..i)

--         local data = datalist[i]
--         if data == nil then
--             -- self.rankItemList[i].gameObject:SetActive(false)
--             rankItem:Find("Character/Icon").gameObject:SetActive(false)
--             rankItem:Find("Character/Name"):GetComponent(Text).text = ""
--             rankItem:Find("Character/CenterName"):GetComponent(Text).text = "--"

--             rankItem:Find("Character2/Icon").gameObject:SetActive(false)
--             rankItem:Find("Character2/CenterName"):GetComponent(Text).text = "--"

--             rankItem:Find("Score"):GetComponent(Text).text = "--"
--         else
--             -- self.rankItemList[i].gameObject:SetActive(true)
--             -- self.rankItemList[i]:update_my_self(data, i)
--             rankItem:Find("Character/Icon").gameObject:SetActive(true)
--             rankItem:Find("Character/Icon/Image"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
--             rankItem:Find("Character/Name"):GetComponent(Text).text = data.role_name
--             rankItem:Find("Character/CenterName"):GetComponent(Text).text = ""

--             rankItem:Find("Character2/Icon").gameObject:SetActive(false)
--             rankItem:Find("Character2/CenterName"):GetComponent(Text).text = KvData.classes_name[data.classes]

--             rankItem:Find("Score"):GetComponent(Text).text = tostring(data.harm)
--         end
--     end
-- end

function GuildDungeonBossWindow:UpdateRewardItem()
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

function GuildDungeonBossWindow:UpdateRank()
    local datalist = self.model.rankData[string.format("%s_%s", self.chapter_id, self.strongpoint_id)]
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

function GuildDungeonBossWindow:OnGotoButtonClick()
    -- if TeamManager.Instance:MemberCount() >= 3 then
        GuildDungeonManager.Instance:Send19503(self.chapter_id, self.strongpoint_id, self.data.monsters[1].monster_id)
    -- else
    --     NoticeManager.Instance:FloatTipsByString(TI18N("怪物非常强大，请组满3人以上再来挑战"))
    -- end
end