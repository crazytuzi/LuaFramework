EquipStrengthHufuWindow  =  EquipStrengthHufuWindow or BaseClass(BasePanel)

function EquipStrengthHufuWindow:__init(model)
    self.name  =  "EquipStrengthHufuWindow"
    self.model  =  model
    -- self.windowId = WindowConfig.WinID.eqmaddlucky

    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.equip_strength_material_win, type  =  AssetType.Main}
    }

    self.selectedEquipData = nil
    self.is_open = false
    self.myData = nil

    return self
end

function EquipStrengthHufuWindow:__delete()
    for k,v in pairs(self.itemList) do
        v:Release()
        v:DeleteMe()
    end
    self.itemList = nil

    self.top_slot:DeleteMe()
    self.mid_slot_item_1.slot:DeleteMe()
    self.mid_slot_item_2.slot:DeleteMe()
    self.mid_slot_item_3.slot:DeleteMe()

    self.selectedEquipData = nil
    self.is_open = false
    self.myData = nil
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function EquipStrengthHufuWindow:InitPanel()
    self.is_open = true

    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_material_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "EquipStrengthHufuWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon")

    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    -- CloseBtn.onClick:AddListener(function() self.model:CloseEquipHufuUI() end)
    CloseBtn.onClick:AddListener(function() self:on_click_put_ma() end)


    self.LeftCon = self.MainCon:FindChild("LeftCon")
    self.TopSlot = self.LeftCon:FindChild("TopSlot").gameObject
    self.ImgTitle = self.LeftCon:FindChild("ImgTitle")
    self.TxtTitle = self.ImgTitle:FindChild("TxtTitle"):GetComponent(Text)

    self.top_slot = self:create_equip_slot(self.TopSlot)

    self.top_slot:SetSelectSelfCallback(function()
        self:on_click_top_slot()
    end)

    self.MidSlot1 = self.LeftCon:FindChild("MidSlot1")
    self.MidSlot2 = self.LeftCon:FindChild("MidSlot2")
    self.MidSlot3 = self.LeftCon:FindChild("MidSlot3")

    self.mid_slot_item_1 = self:create_mid_slot_item(self.MidSlot1)
    self.mid_slot_item_2 = self:create_mid_slot_item(self.MidSlot2)
    self.mid_slot_item_3 = self:create_mid_slot_item(self.MidSlot3)

    self.mid_slot_item_1.slot:SetSelectSelfCallback(function()
        self:on_click_mid_slot(1)
    end)
    self.mid_slot_item_2.slot:SetSelectSelfCallback(function()
        self:on_click_mid_slot(2)
    end)
    self.mid_slot_item_3.slot:SetSelectSelfCallback(function()
        self:on_click_mid_slot(3)
    end)

    self.BottomDesc1 = self.LeftCon:FindChild("BottomDesc1"):GetComponent(Text)
    self.BottomDesc2 = self.LeftCon:FindChild("BottomDesc2"):GetComponent(Text)



    self.RightCon = self.MainCon:FindChild("RightCon")
    self.MaskCon = self.RightCon:FindChild("MaskCon")
    self.ScrollLayer = self.MaskCon:FindChild("ScrollLayer")
    self.LayoutLayer = self.ScrollLayer:FindChild("LayoutLayer")
    self.Item = self.LayoutLayer:FindChild("Item").gameObject
    self.Item:SetActive(false)

    self.BtnPutMateria = self.RightCon:FindChild("BtnPutMateria"):GetComponent(Button)
    self.ImgTanhao = self.RightCon:FindChild("ImgTanhao"):GetComponent(Button)
    self.TxtUn = self.RightCon:FindChild("TxtUn").gameObject
    self.BtnPutMateria.onClick:AddListener(function() self:on_click_put_ma() end)
    self.ImgTanhao.onClick:AddListener(function() self:on_click_tanhao() end)



    self:update_right_material_list()
    self:update_last_selected()
end

----------------------------------------各种更新
--更新显示上次选中
function EquipStrengthHufuWindow:update_last_selected()
    self:update_mid_slot(self.mid_slot_item_1, self.model.select_luck_data_1)
    self:update_mid_slot(self.mid_slot_item_2, self.model.select_luck_data_2)
    self:update_mid_slot(self.mid_slot_item_3, self.model.select_luck_data_3)


    self.mode_select_luck_data_1 = self.model.select_luck_data_1
    self.mode_select_luck_data_2 = self.model.select_luck_data_2
    self.mode_select_luck_data_3 = self.model.select_luck_data_3
    ---设置下list的数量显示0

    self.model_select_hufu_data = self.model.select_hufu_data
    if self.model_select_hufu_data == nil then
        self.top_slot:SetAll(nil, nil)
    else
        self:set_stone_slot_data(self.top_slot, self.model_select_hufu_data)
    end
end

--检查下传入的data是不是八彩或者韭菜
function EquipStrengthHufuWindow:check_selected_stone_data(data)
    if data == nil then
        return false
    end
    if data.base_id == 20016 or data.base_id == 20023 then
        return true
    end
    return false
end

--更新左侧
function EquipStrengthHufuWindow:update_left(item)
    if self:check_selected_stone_data(self.mode_select_luck_data_1) or self:check_selected_stone_data(self.mode_select_luck_data_2) or self:check_selected_stone_data(self.mode_select_luck_data_3) then
        self:remove_left_top()

        local _name = ""
        if self.mode_select_luck_data_1 ~= nil then
            _name = self.mode_select_luck_data_1.name
        elseif self.mode_select_luck_data_2 ~= nil then
            _name = self.mode_select_luck_data_2.name
        elseif self.mode_select_luck_data_3 ~= nil then
            _name = self.mode_select_luck_data_3.name
        end
        NoticeManager.Instance:FloatTipsByString(string.format("%s%s%s", TI18N("已放入"), _name, TI18N("成功率100%")))
        return
    end

    if item.type == 1 then
        if item.data.base_id == 20016 or item.data.base_id == 20023 then
            --八彩或韭菜
            if self.mode_select_luck_data_1 ~= nil then
                local item = self.itemList[self.mode_select_luck_data_1.base_id]
                item:update_slot_num(item.my_fen_zi+1)
            end

            self.mode_select_luck_data_1 = nil
            self.mid_slot_item_1.slot:SetAll(nil, nil)
            self.mid_slot_item_1.desc_txt.text = ""

            if self.mode_select_luck_data_2 ~= nil then
                local item = self.itemList[self.mode_select_luck_data_2.base_id]
                item:update_slot_num(item.my_fen_zi+1)
            end

            self.mode_select_luck_data_2 = nil
            self.mid_slot_item_2.slot:SetAll(nil, nil)
            self.mid_slot_item_2.desc_txt.text = ""

            if self.mode_select_luck_data_3 ~= nil then
                local item = self.itemList[self.mode_select_luck_data_3.base_id]
                item:update_slot_num(item.my_fen_zi+1)
            end

            self.mode_select_luck_data_3 = nil
            self.mid_slot_item_3.slot:SetAll(nil, nil)
            self.mid_slot_item_3.desc_txt.text = ""

            self:remove_left_top()
        end
        --幸运石
        local result = self:update_left_mid(item.data)
        if result then
            item:update_slot_num(item.my_fen_zi - 1)
        end
    else
        --护符
        local result = self:update_left_top(item.data)
        if result then
            item:update_slot_num(item.my_fen_zi - 1)
        end
    end

    self:update_left_bottom()
end

--移除左边护符
function EquipStrengthHufuWindow:remove_left_top()
    if self.model_select_hufu_data ~= nil then
        self.top_slot:SetAll(nil, nil)
        local item = self.itemList[self.model_select_hufu_data.base_id]
        item:update_slot_num(item.my_fen_zi+1)
        self.model_select_hufu_data = nil
    end
end

--更新左边顶部
function EquipStrengthHufuWindow:update_left_top(data)
    if self:check_selected_stone_data(self.mode_select_luck_data_1) or self:check_selected_stone_data(self.mode_select_luck_data_2) or self:check_selected_stone_data(self.mode_select_luck_data_3) then
        self:remove_left_top()

        local _name = ""
        if self.mode_select_luck_data_1 ~= nil then
            _name = self.mode_select_luck_data_1.name
        elseif self.mode_select_luck_data_2 ~= nil then
            _name = self.mode_select_luck_data_2.name
        elseif self.mode_select_luck_data_3 ~= nil then
            _name = self.mode_select_luck_data_3.name
        end
        NoticeManager.Instance:FloatTipsByString(string.format("%s%s%s", TI18N("已放入"), _name, TI18N("成功率100%")))
        return
    end

    if self.model_select_hufu_data == nil then
        self.model_select_hufu_data = data
        self:set_stone_slot_data(self.top_slot, data)
        self.top_slot:ShowNum(false)
        return true
    else
        self.top_slot:ShowNum(false)
        return false
    end
    self:update_left_bottom()
end

--更新左边中间
function EquipStrengthHufuWindow:update_left_mid(data)
    local cfg_data = DataBacksmith.data_enchant_luck[data.base_id]
    if self.mode_select_luck_data_1 == nil then
        self.mode_select_luck_data_1 = data
        self:update_mid_slot(self.mid_slot_item_1, data)
        return true
    elseif self.mode_select_luck_data_2 == nil then
        self.mode_select_luck_data_2 = data
        self:update_mid_slot(self.mid_slot_item_2, data)
        return true
    elseif self.mode_select_luck_data_3 == nil then
        self.mode_select_luck_data_3 = data
        self:update_mid_slot(self.mid_slot_item_3, data)
        return true
    end
    return false
end

--更新中部某个slot
function EquipStrengthHufuWindow:update_mid_slot(item, data)
    if data ~= nil then
        local cfg_data = DataBacksmith.data_enchant_luck[data.base_id]
        self:set_stone_slot_data(item.slot, data)
        item.slot:ShowNum(false)
        item.desc_txt.text = string.format("%s+%s%s", TI18N("成功率"), cfg_data.ratio/10 , "%")
    else
        item.slot:SetAll(nil, nil)
        item.slot:ShowNum(false)
        item.desc_txt.text = ""
    end
end

--更新左边底部
function EquipStrengthHufuWindow:update_left_bottom()
    local radio = 0
    if self.mode_select_luck_data_1 ~= nil then
        radio = radio + DataBacksmith.data_enchant_luck[self.mode_select_luck_data_1.base_id].ratio
    end
    if self.mode_select_luck_data_2 ~= nil then
        radio = radio + DataBacksmith.data_enchant_luck[self.mode_select_luck_data_2.base_id].ratio
    end
    if self.mode_select_luck_data_3 ~= nil then
        radio = radio + DataBacksmith.data_enchant_luck[self.mode_select_luck_data_3.base_id].ratio
    end
    radio = radio/10

    self.BottomDesc1.text = string.format("<color='#FFFF9A'>%s:</color>%s<color='#8DE92A'>+%s%s</color>", TI18N("幸运石"),TI18N("成功率"), radio, "%")

    if self.model_select_hufu_data ~= nil then
        self.BottomDesc2.text = string.format("<color='#FFFF9A'>%s:</color>%s<color='#4dd52b'>[%s]</color>", TI18N("保护符"), TI18N("失败不降低强化等级"), TI18N("激活"))
    else
        self.BottomDesc2.text = string.format("<color='#FFFF9A'>%s:</color>%s<color='#EE3900'>[%s]</color>", TI18N("保护符"), TI18N("失败不降低强化等级"), TI18N("未激活"))
    end
    -- self.BottomDesc2
end

--更新右边材料列表
function EquipStrengthHufuWindow:update_right_material_list()
    self.last_selected_item = nil
    if self.itemList == nil then
        self.itemList = {}
    end
    if self.itemList ~= nil then
        for k, v in pairs(self.itemList) do
            if v ~= nil then
                v.gameObject:SetActive(false)
            end
        end
    end

    -------------------------幸运石
    -- self.model.cur_equip_data.id
    --幸运石
    local has_broken = self.model:check_equip_has_broken(self.model.cur_equip_data)
    if self.model.cur_equip_data.enchant < 12 then
        has_broken = false
    end
    local cfg_data = DataBacksmith.data_enchant[self.model.cur_equip_data.enchant]
    local temp_luck_list = {}
    for i=1, #cfg_data.allow_luck do
        if temp_luck_list[cfg_data.allow_luck[i]] == nil then
            if has_broken and (cfg_data.allow_luck[i] == 20404 or cfg_data.allow_luck[i] == 20022) then
                --已突破过，只能使用优秀和完美
                temp_luck_list[cfg_data.allow_luck[i]] = BackpackManager.Instance:GetItemByBaseid(cfg_data.allow_luck[i])
            elseif not has_broken and cfg_data.allow_luck[i] ~= 20404 then
                --未突破过，不能使用完美
                temp_luck_list[cfg_data.allow_luck[i]] = BackpackManager.Instance:GetItemByBaseid(cfg_data.allow_luck[i])
            end
        end
    end

    local luck_data_list = {}
    for k, v in pairs(temp_luck_list) do
        if luck_data_list[k] == nil and #v > 0 then
            luck_data_list[k] = v
        end
    end

    local has_good = 0
    for k, v in pairs(luck_data_list) do
        local item = self.itemList[k]
        if item == nil then
            item = EquipStrengthMaterialItem.New(self, self.Item)
            self.itemList[k] = item
        end
        item:set_data(k, 1)
        has_good = 1
        item.gameObject:SetActive(true)
    end


    --------------------------保护符
    local temp_protect_list = {}
    for i=1, #cfg_data.allow_protect do
        if temp_protect_list[cfg_data.allow_protect[i]] == nil then
            temp_protect_list[cfg_data.allow_protect[i]] = BackpackManager.Instance:GetItemByBaseid(cfg_data.allow_protect[i])
        end
    end

    local protect_data_list = {}
    for k, v in pairs(temp_protect_list) do
        if protect_data_list[k] == nil and #v > 0 then
            protect_data_list[k] = v
        end
    end

    for k, v in pairs(protect_data_list) do
        local item = self.itemList[k]
        if item == nil then
            item = EquipStrengthMaterialItem.New(self, self.Item)
            self.itemList[k] = item
        end
        item:set_data(k, 2)
        has_good = 2
        item.gameObject:SetActive(true)
    end

    if has_good == 0 then
        self.TxtUn:SetActive(true)
    else
        self.TxtUn:SetActive(false)
    end
end

----------------------------------------按钮点击事件
--点击放入材料按钮
function EquipStrengthHufuWindow:on_click_put_ma()
    self.model.select_luck_data_1 = self.mode_select_luck_data_1
    self.model.select_luck_data_2 = self.mode_select_luck_data_2
    self.model.select_luck_data_3 = self.mode_select_luck_data_3
    self.model.select_hufu_data = self.model_select_hufu_data
    EventMgr.Instance:Fire(event_name.equip_strength_materail_put)
    self.model:CloseEquipHufuUI()
end

--点击叹号按钮
function EquipStrengthHufuWindow:on_click_tanhao()
end

--点击顶部图标
function EquipStrengthHufuWindow:on_click_top_slot()
    local data = self.model_select_hufu_data
    self.model_select_hufu_data = nil
    self.top_slot:SetAll(nil, nil)
    if data ~= nil then
        local item = self.itemList[data.base_id]
        item:update_slot_num(item.my_fen_zi+1)
    end
    self:update_left_bottom()
end

--点击中间图标
function EquipStrengthHufuWindow:on_click_mid_slot(index)
    local data = nil
    if index == 1 then
        data = self.mode_select_luck_data_1
        self.mode_select_luck_data_1 = nil
        self.mid_slot_item_1.slot:SetAll(nil, nil)
        self.mid_slot_item_1.desc_txt.text = ""
    elseif index == 2 then
        data = self.mode_select_luck_data_2
        self.mode_select_luck_data_2 = nil
        self.mid_slot_item_2.slot:SetAll(nil, nil)
        self.mid_slot_item_2.desc_txt.text = ""
    elseif index == 3 then
        data = self.mode_select_luck_data_3
        self.mode_select_luck_data_3 = nil
        self.mid_slot_item_3.slot:SetAll(nil, nil)
        self.mid_slot_item_3.desc_txt.text = ""
    end

    if data ~= nil then
        local item = self.itemList[data.base_id]
        item:update_slot_num(item.my_fen_zi+1)
    end

    self:update_left_bottom()
end

--为左边中间创建item
function EquipStrengthHufuWindow:create_mid_slot_item(trans)
    local item = {}
    item.slot_con = trans:FindChild("SlotCon").gameObject
    item.slot = self:create_equip_slot(item.slot_con)
    item.desc_txt = trans:FindChild("TxtDesc"):GetComponent(Text)
    return item
end

--为每个武器创建slot
function EquipStrengthHufuWindow:create_equip_slot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con.transform)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    stone_slot:ShowNum(false)
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

--对slot设置数据
function EquipStrengthHufuWindow:set_stone_slot_data(slot, data)
    local cell = ItemData.New()
    cell:SetBase(data)
    slot:SetAll(cell, nil)
    slot:SetNotips(true)
end