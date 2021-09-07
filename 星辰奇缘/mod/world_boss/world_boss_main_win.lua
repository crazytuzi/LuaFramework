WorldBossMainWindow  =  WorldBossMainWindow or BaseClass(BaseWindow)

function WorldBossMainWindow:__init(model)
    self.name  =  "WorldBossMainWindow"
    self.model  =  model
    -- 缓存
    self.windowId = WindowConfig.WinID.world_boss

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end

    self.resList  =  {
        {file  =  AssetConfig.world_boss_window, type  =  AssetType.Main}
        ,{file  =  AssetConfig.world_boss_head_icon, type  =  AssetType.Dep}
        ,{file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep}
    }

    self.item_list = nil
    self.fresh_timer = nil
    self.selectedItem = nil
    self.last_cfg_id = nil
    self.timer_id = 0

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

     self.is_open = false
    self.is_active = false

    return self
end


function WorldBossMainWindow:OnShow()
    if self.previewComp1 ~= nil then
        self.previewComp1:Show()
    end
     WorldBossManager.Instance:request13000()
     self.is_active = true
end


function WorldBossMainWindow:OnHide()
    if self.previewComp1 ~= nil then
        self.previewComp1:Hide()
    end
    self.is_active = false
end

function WorldBossMainWindow:__delete()
    if self.slot_1 ~= nil then
        self.slot_1:DeleteMe()
        self.slot_1 = nil
    end
    if self.slot_2 ~= nil then
        self.slot_2:DeleteMe()
        self.slot_2 = nil
    end
    if self.slot_3 ~= nil then
        self.slot_3:DeleteMe()
        self.slot_3 = nil
    end
    if self.slot_4 ~= nil then
        self.slot_4:DeleteMe()
        self.slot_4 = nil
    end
    if self.slot_5 ~= nil then
        self.slot_5:DeleteMe()
        self.slot_5 = nil
    end

    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:Release()
        end
    end
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end
    self.is_open = false

    self:stop_timer()

    self.last_cfg_id = nil

    self.selectedItem = nil
    self.item_list = nil
    self.fresh_timer = nil

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function WorldBossMainWindow:InitPanel()

    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.world_boss_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "WorldBossMainWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon").gameObject
    self.CloseButton = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self.model:CloseWorldBossUI() end)

    self.Con_left = self.MainCon.transform:FindChild("Con_left").gameObject
    self.MaskLayer = self.Con_left.transform:FindChild("MaskLayer").gameObject
    self.ScrollLayer = self.MaskLayer.transform:FindChild("ScrollLayer").gameObject
    self.LayoutLayer = self.ScrollLayer.transform:FindChild("LayoutLayer").gameObject
    self.Item = self.LayoutLayer.transform:FindChild("Item").gameObject
    self.Item:SetActive(false)
    self.TxtReward = self.Con_left.transform:FindChild("TxtReward"):GetComponent(Text)

    self.Con_right = self.MainCon.transform:FindChild("Con_right").gameObject
    self.Con_right.transform:Find("previewBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")

    self.ImgTitle =  self.Con_right.transform:FindChild("ImgTitle").gameObject
    self.TxtName = self.ImgTitle.transform:FindChild("TxtName"):GetComponent(Text)
    self.Preview = self.Con_right.transform:FindChild("Preview").gameObject
    self.ImgBadge1 = self.Con_right.transform:FindChild("ImgBadge1"):GetComponent(Button)
    self.ImgBadge2 = self.Con_right.transform:FindChild("ImgBadge2"):GetComponent(Button)
    self.MidCon = self.Con_right.transform:FindChild("MidCon").gameObject
    self.Slot1 = self.MidCon.transform:FindChild("Slot1").gameObject
    self.Slot2 = self.MidCon.transform:FindChild("Slot2").gameObject
    self.Slot3 = self.MidCon.transform:FindChild("Slot3").gameObject
    self.Slot4 = self.MidCon.transform:FindChild("Slot4").gameObject
    self.Slot5 = self.MidCon.transform:FindChild("Slot5").gameObject
    self.BtnFight = self.Con_right.transform:FindChild("BtnFight"):GetComponent(Button)

    self.BtnFight.onClick:AddListener(function() self:on_goto_fight() end)

    self.ImgBadge1.onClick:AddListener(function() self:open_first_killer_tips() end)
    self.ImgBadge2.onClick:AddListener(function() self:open_honor_killer_list() end)

    self.is_open = true

    WorldBossManager.Instance:request13000()


    self.is_active = true
end

function WorldBossMainWindow:update_view()
    local rewardable = self.model.world_boss_data.rewardable
    if self.TxtReward == nil then return end --为空不处理 （可能进来了之后这个就被销毁了）
    self.TxtReward.text = string.format("%s<color='%s'>%s</color>", TI18N("今天可获得奖励次数："), ColorHelper.color[1],tostring(rewardable))

    if self.item_list ~= nil then
        for i=1,#self.item_list do
            local item = self.item_list[i]
            if item ~= nil then
                item.gameObject:SetActive(false)
            end
        end
    end
    self.item_list = {}

    local boss_list = self.model.world_boss_data.boss_list

    local lev_sort = function(a, b)
        local a_data = DataBoss.data_base[a.id]
        local b_data = DataBoss.data_base[b.id]
        return a_data.lev < b_data.lev --根据index从小到大排序
    end

    table.sort(boss_list, lev_sort)

    local selected_item = nil
    for i=1, #boss_list do
        local data = boss_list[i]
        local item = self.item_list[i]
        if item == nil then
            item = WorldBossItem.New(self, self.Item, data, i)
            table.insert(self.item_list, item)
        end
        item:set_boss_item_data(data)


        --找到时间到点可打
        if selected_item == nil and item.fresh_left_time <= 0 then
            selected_item = item
        end
    end

    --找不到时间到点可以打的
    if selected_item == nil then
        for i=1, #boss_list do
            local item = self.item_list[i]
            local cfg_data = DataBoss.data_base[item.data.id]
            if RoleManager.Instance.RoleData.lev >= cfg_data.lev then
                selected_item = item
                break
            end
        end
    end

    if selected_item == nil then
        self:update_right_con(self.item_list[1])
    else
        self:update_right_con(selected_item)
    end

    self:stop_timer()
    self:star_timer()


    local newH = 100*#boss_list
    local rect = self.LayoutLayer.transform:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(0, newH)
end

function WorldBossMainWindow:on_goto_fight(g)
    if self.selectedItem ~= nil then
        -- if mod_team.can_run() == false then
        --     mod_notify.append_scroll_win(TI18N("队伍跟随中，无法挑战"))
        --     return
        -- end

        local data = self.selectedItem.data
        if self.selectedItem.fresh_left_time > 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("boss尚未重生，不能挑战"))
            print("boss尚未重生，不能挑战")
            return
        end

        local id_battle_id = BaseUtils.get_unique_npcid(data.id, 3)
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(data.map_id, id_battle_id, nil, nil, true)
        self.model:CloseWorldBossUI()
    end
end

----更新右边面板
function WorldBossMainWindow:update_right_con(item)
    if self.selectedItem ~= nil then
        self.selectedItem.ImgSelected:SetActive(false)
    end
    self.selectedItem = item
    self.selectedItem.ImgSelected:SetActive(true)
    local data = item.data
    local cfg_data = DataBoss.data_base[data.id]
    local unit_data = DataUnit.data_unit[data.id]
    self.model.boss_rank_id = data.id
    self.TxtName.text = unit_data.name

    --更新模型
    self:update_sh_model(data.id)


    ---更新掉落
    self.Slot1:SetActive(false)
    self.Slot2:SetActive(false)
    self.Slot3:SetActive(false)
    self.Slot4:SetActive(false)
    self.Slot5:SetActive(false)

    for i=1,#cfg_data.item_reward do
        local d = cfg_data.item_reward[i]
        local slot_con = nil
        if i == 1 then
            if self.slot_1 == nil then
                self.slot_1 = self:create_drop_slot_item(self.Slot1)
            end
            self:set_drop_slot_data(self.slot_1, self.Slot1, d)
        elseif i == 2 then
            if self.slot_2 == nil then
                self.slot_2 = self:create_drop_slot_item(self.Slot2)
            end
            self:set_drop_slot_data(self.slot_2, self.Slot2, d)
        elseif i == 3 then
            if self.slot_3 == nil then
                self.slot_3 = self:create_drop_slot_item(self.Slot3)
            end
            self:set_drop_slot_data(self.slot_3, self.Slot3, d)
        elseif i == 4 then
            if self.slot_4 == nil then
                self.slot_4 = self:create_drop_slot_item(self.Slot4)
            end
            self:set_drop_slot_data(self.slot_4, self.Slot4, d)
        elseif i == 5 then
            if self.slot_5 == nil then
                self.slot_5 = self:create_drop_slot_item(self.Slot5)
            end
            self:set_drop_slot_data(self.slot_5, self.Slot5, d)
        end
    end

    if #data.first_killer == 0 then
        self.ImgBadge1.gameObject:SetActive(true)
        self.ImgBadge2.gameObject:SetActive(false)
    else
        self.ImgBadge1.gameObject:SetActive(false)
        self.ImgBadge2.gameObject:SetActive(true)
    end
end

function WorldBossMainWindow:create_drop_slot_item(con)
    local slot = ItemSlot.New()
    slot.gameObject.transform:SetParent(con.transform)
    slot.gameObject.transform.localScale = Vector3.one
    slot.gameObject.transform.localPosition = Vector3.zero
    slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return slot
end

function WorldBossMainWindow:set_drop_slot_data(slot, con, data)
    local cell = ItemData.New()
    local itemData = DataItem.data_get[data.key] --设置数据
    cell:SetBase(itemData)
    slot:SetAll(cell, nil)
    con:SetActive(true)
end

--打开排行榜
function WorldBossMainWindow:open_honor_killer_list()
    self.model:OpenWorldBossRankUI()
end

--打开首杀奖励
function WorldBossMainWindow:open_first_killer_tips()
    if self.selectedItem ~= nil and self.selectedItem.data ~= nil and self.selectedItem.data.id ~= nil then 
        local boss_data = DataBoss.data_base[self.selectedItem.data.id]
        local _itemData = DataItem.data_get[boss_data.first_reward[1].key]
        TipsManager.Instance:ShowItem({gameObject = self.ImgBadge1.gameObject, itemData = _itemData})
    end
end


---------------------------------------计时器逻辑
function WorldBossMainWindow:star_timer()
    self:stop_timer()
    LuaTimer.Add(0, 1000, function(id) self:on_timer_tick(id) end)
end

function WorldBossMainWindow:on_timer_tick(id)
    self.timer_id = id
    if self.is_open == false then
        return
    end
    local item = nil
    if  self.item_list ~= nil then
        for i=1, #self.item_list do
            self.item_list[i]:tick_clock()
            if item == nil and self.item_list[i].fresh_left_time <= 0 then
                item = self.item_list[i]
            end
        end
        if item ~= nil and self.is_active == false then
            if self.selectedItem == nil or (self.selectedItem ~= nil and self.selectedItem.fresh_left_time > 0) then
                self:update_right_con(item)
            end
        end
    end
end

function WorldBossMainWindow:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

---------------------------------------模型逻辑
-- 列表右边逻辑
function WorldBossMainWindow:update_sh_model(id)
    local unit_data = DataUnit.data_unit[id]


    local previewComp = nil
    local callback = function(composite)
        self:on_model_build_completed(composite)
    end
    local setting = {
        name = "WorldBoss"
        ,orthographicSize = 0.7
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Npc, skinId = unit_data.skin, modelId = unit_data.res, animationId = unit_data.animation_id, scale = 1}
    if self.previewComp1 == nil then
        self.previewComp1 = PreviewComposite.New(callback, setting, modelData)

        -- 有缓存的窗口要写这个
        self.OnHideEvent:AddListener(function() self.previewComp1:Hide() end)
        self.OnOpenEvent:AddListener(function() self.previewComp1:Show() end)
    else
        self.previewComp1:Reload(modelData, callback)
    end
end

--模型加载完成
function WorldBossMainWindow:on_model_build_completed(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.Preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end
