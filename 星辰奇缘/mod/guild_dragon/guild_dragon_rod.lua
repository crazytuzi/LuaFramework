-- @author 黄耀聪
-- @date 2017年11月13日, 星期一

GuildDragonRod = GuildDragonRod or BaseClass(BaseWindow)

function GuildDragonRod:__init(model)
    self.model = model
    self.name = "GuildDragonRod"
    self.windowId = WindowConfig.WinID.guilddragon_rod

    self.resList = {
        {file = AssetConfig.guilddragon_rod, type = AssetType.Main}
        , {file = AssetConfig.guilddragon_textures, type = AssetType.Dep}
        , {file = AssetConfig.rolebgnew, type = AssetType.Dep}
        , {file = AssetConfig.rolebgstand, type = AssetType.Dep}
        , {file = AssetConfig.rank_textures, type = AssetType.Dep}
    }

    self.updateLister = function(index) if index == 4 then self:Update() end end

    self.slayerList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildDragonRod:__delete()
    self.OnHideEvent:Fire()
    if self.slayerList ~= nil then
        for _,slayer in pairs(self.slayerList) do
            slayer:DeleteMe()
        end
        self.slayerList = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    local show = self.transform:Find("Main/Show")
    show:Find("RoleBg"):GetComponent(Image).sprite = nil
    show:Find("RoleStandBg"):GetComponent(Image).sprite = nil
    self:AssetClearAll()
end

function GuildDragonRod:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddragon_rod))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    local rank = main:Find("Rank")
    self.rankTitleText = rank:Find("Title/Text"):GetComponent(Text)
    self.personItem = rank:Find("Cloner").gameObject
    local container = rank:Find("Scroll/Container")
    self.personLayout = LuaBoxLayout.New(container, {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.slayerList[1] = GuildDragonSlayer.New(self.model, self.personItem, self.assetWrapper)
    self.personLayout:AddCell(self.personItem)
    for i=2,10 do
        self.slayerList[i] = GuildDragonSlayer.New(self.model, GameObject.Instantiate(self.personItem), self.assetWrapper)
        self.personLayout:AddCell(self.slayerList[i].gameObject)
    end
    self.personScroll = rank:Find("Scroll"):GetComponent(ScrollRect)

    self.personSetting = {
       item_list = self.slayerList
       ,data_list = {} --数据列表
       ,item_con = container  --item列表的父容器
       ,single_item_height = self.personItem.transform.sizeDelta.y --一条item的高度
       ,item_con_last_y = container.anchoredPosition.y ---父容器改变时上一次的y坐标
       ,scroll_con_height = self.personScroll:GetComponent(RectTransform).rect.height --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.personScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.personSetting) end)

    local show = main:Find("Show")
    self.previewContainer = show:Find("Preview")
    self.nameText = show:Find("Name/Text"):GetComponent(Text)
    self.honorText = show:Find("Honor/Text"):GetComponent(Text)
    self.descExt = MsgItemExt.New(show:Find("Desc/Text"):GetComponent(Text), 266, 19, 22)
    show:Find("RoleBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    show:Find("RoleBg"):GetComponent(Image).color = Color(1, 1, 1)
    show:Find("RoleStandBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgstand, "RoleStandBottom")
    show:Find("RoleStandBg"):GetComponent(Image).color = Color(1, 1, 1)

    self.descExt:SetData(DataHonor.data_get_honor_list[11129].cond_desc)
    local size = self.descExt.contentTrans.sizeDelta
    self.descExt.contentTrans.anchoredPosition3D = Vector3(-size.x / 2, size.y / 2, 0)

    self.nothingObj = rank:Find("Nothing").gameObject
end

function GuildDragonRod:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDragonRod:OnOpen()
    self:RemoveListeners()
    GuildDragonManager.Instance.updateRankEvent:AddListener(self.updateLister)

    GuildDragonManager.Instance:send20504()
    self:Update()

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 500, function() self:UpdateInfo() end)
    end
end

function GuildDragonRod:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function GuildDragonRod:RemoveListeners()
    GuildDragonManager.Instance.updateRankEvent:RemoveListener(self.updateLister)
end

function GuildDragonRod:Update()
    local loot_list = self.model.loot_list or {}
    local datalist = {}
    local delta = 20
    -- if IS_DEBUG then
    --     delta = 2
    -- end

    local rank_index = (GuildDragonManager.Instance:GetMyRank() or {}).rank_index or 0
    if rank_index == 0 then
        rank_index = #loot_list
    end
    for i,v in ipairs(loot_list) do
        if v.rank_index <= 3 or (v.rank_index >= rank_index - delta and v.rank_index <= rank_index + delta) then
            table.insert(datalist, v)
        end
    end

    self.personSetting.data_list = datalist
    -- if next(self.personSetting.data_list) ~= nil then
    --     for i=1,20 do
    --         table.insert(self.personSetting.data_list, BaseUtils.copytab(self.personSetting.data_list[1]))
    --     end
    -- end
    BaseUtils.refresh_circular_list(self.personSetting)

    self.nothingObj:SetActive(next(self.personSetting.data_list) == nil)
    self:ReloadInfo(self.personSetting.data_list[1])

    if next(self.personSetting.data_list) ~= nil then
        local roleData = RoleManager.Instance.RoleData
        local locateIndex = nil
        for index,person in ipairs(self.personSetting.data_list) do
            if person.id == roleData.id and person.platform == roleData.platform and person.zone_id == roleData.zone_id then
                index = locateIndex
                break
            end
        end
        self:DoLocation(locateIndex or 1)
    end
end

function GuildDragonRod:ReloadInfo(firstPlaceData)
    local roleData = RoleManager.Instance.RoleData
    firstPlaceData = firstPlaceData or {role_name = roleData.name, id = roleData.id, platform = roleData.platform, zone_id = roleData.zone_id, sex = roleData.sex, classes = roleData.classes}
    self.nameText.text = firstPlaceData.role_name
    self:ReloadPreview(firstPlaceData)
end

function GuildDragonRod:ReloadPreview(data)
    if data.id == self.lastRoleId and data.platform == self.lastPlatform and data.zone_id == self.lastZoneId then
        return
    end

    if self.previewCallback == nil then
        self.previewCallback = function(composite) self:PreviewCallback(composite) end
    end
    local info = self.model:GetLooks(data.id, data.platform, data.zone_id)

    local modelData = nil
    if info == nil then
        modelData = {type = PreViewType.Role, classes = data.classes, sex = data.sex, looks = {}}
    else
        modelData = {type = PreViewType.Role, classes = data.classes, sex = data.sex, looks = info.looks}
    end

    self.honorText.text = DataHonor.data_get_honor_list[11129].name

    if self.previewComp == nil then
        local setting = setting or {
            name = "GuildDragonRod"
            ,orthographicSize = 0.6
            ,width = 330
            ,height = 340
            ,offsetY = -0.4
            ,noDrag = false
        }
        self.previewComp = PreviewComposite.New(self.previewCallback, setting, modelData)
    else
        self.previewComp:Reload(modelData, self.previewCallback)
    end

    if info ~= nil then
        self.lastRoleId = data.id
        self.lastPlatform = data.platform
        self.lastZoneId = data.zone_id
    end
end

function GuildDragonRod:PreviewCallback(composite)
    composite.rawImage.transform:SetParent(self.previewContainer)
    composite.rawImage.transform.localScale = Vector3.one
    composite.rawImage.transform.localPosition = Vector3.zero
end

function GuildDragonRod:UpdateInfo()
    if GuildDragonManager.Instance:InLootCD() then
        self.rankTitleText.text = string.format(TI18N("%s后可挑战"), BaseUtils.formate_time_gap(self.model.myData.loot_time - BaseUtils.BASE_TIME, ":", 0, BaseUtils.time_formate.MIN))
    else
        self.rankTitleText.text = TI18N("掠夺<color='#ffff00'>其他公会玩家</color>可获得龙币") --TI18N("当前可挑战<color='#c7f9ff'>(挑战后进入3分钟休整期)</color>")
    end
end

function GuildDragonRod:DoLocation(index)
    self.personScroll.onValueChanged:Invoke({0,0})
    if index < 5 then
        self.personSetting.item_con.anchoredPosition = Vector2(0, 0)
        self.personScroll.onValueChanged:Invoke({0,1})
    -- elseif index > #self.personSetting.data_list - 3 then
    --     self.personSetting.item_con.anchoredPosition = Vector2(0, self.personSetting.item_con.sizeDelta.y - self.personSetting.scroll_con_height)
    --     self.personScroll.onValueChanged:Invoke({0,0})
    else
        local h = index * self.personSetting.single_item_height - self.personSetting.scroll_con_height
        local scale = 1 - h / (self.personSetting.item_con.sizeDelta.y - self.personSetting.scroll_con_height)
        self.personSetting.item_con.anchoredPosition = Vector2(0, h)
        self.personScroll.onValueChanged:Invoke({0, scale})
    end
end

