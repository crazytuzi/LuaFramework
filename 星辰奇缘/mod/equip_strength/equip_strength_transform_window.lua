EquipStrengthTransformWindow  =  EquipStrengthTransformWindow or BaseClass(BaseWindow)

function EquipStrengthTransformWindow:__init(model)
    self.name  =  "EquipStrengthTransformWindow"
    self.model  =  model
    self.windowId = WindowConfig.WinID.eqmtrans

    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.equip_strength_prop_transform_win, type  =  AssetType.Main},
        {file = AssetConfig.rolebg, type = AssetType.Dep},
    }

    self.is_open = false

    self.subFirst = nil
    self.subSecond = nil

    self.on_equip_update = function(equips)
        if self.is_open == false then
            return
        end
        self:update_bottom_con()
        self:update_left_equip_list(1)
    end

     self.on_role_fc_chang = function()
        self:update_zhanli()
    end


    self.on_equip_slot = function()
        self:update_equip_slot()
    end

    return self
end

function EquipStrengthTransformWindow:__delete()
    if self.Weapon_slot ~= nil then
        self.Weapon_slot:DeleteMe()
        self.Weapon_slot = nil
    end
    if self.Ring_slot ~= nil then
        self.Ring_slot:DeleteMe()
        self.Ring_slot = nil
    end
    if self.Necklace_slot ~= nil then
        self.Necklace_slot:DeleteMe()
        self.Necklace_slot = nil
    end
    if self.Bracelet_slot ~= nil then
        self.Bracelet_slot:DeleteMe()
        self.Bracelet_slot = nil
    end
    if self.Coat_slot ~= nil then
        self.Coat_slot:DeleteMe()
        self.Coat_slot = nil
    end
    if self.Belt_slot ~= nil then
        self.Belt_slot:DeleteMe()
        self.Belt_slot = nil
    end
    if self.Pants_slot ~= nil then
        self.Pants_slot:DeleteMe()
        self.Pants_slot = nil
    end
    if self.Shoe_slot ~= nil then
        self.Shoe_slot:DeleteMe()
        self.Shoe_slot = nil
    end

    if self.subFirst ~= nil then
        self.subFirst:DeleteMe()
        self.subFirst = nil
    end

    if self.subSecond ~= nil then
        self.subSecond:DeleteMe()
        self.subSecond = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    self.last_selected_slot = nil
    -- EventMgr.Instance:RemoveListener(event_name.role_attr_change, self.on_role_fc_chang)
    EventMgr.Instance:RemoveListener(event_name.equip_item_change, self.on_equip_update)

    EventMgr.Instance:RemoveListener(event_name.equip_last_lev_attr_update, self.on_equip_slot)

    self.is_open = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function EquipStrengthTransformWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_prop_transform_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "EquipStrengthTransformWindow"
    self.transform = self.gameObject.transform:FindChild("MainCon")
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local CloseBtn = self.transform:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseEquipTransUI() end)

    local tabGroup = self.transform:FindChild("TabButtonGroup").gameObject
    self.tab_btn1 = tabGroup.transform:GetChild(0):GetComponent(Button)
    self.tab_btn1.onClick:AddListener(function() self:tabChange(1) end)
    self.tab_btn2 = tabGroup.transform:GetChild(1):GetComponent(Button)
    self.tab_btn2.onClick:AddListener(function() self:tabChange(2) end)

    self.subFirst = EquipStrengthTransFirstTab.New(self)
    self.subSecond = EquipStrengthTransSecondTab.New(self)

    ---------------------------------------------左边的模型
    self.EquipRoleCon = self.transform:FindChild("EquipRoleCon")
    self.EquipRoleCon:Find("ImgBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebg, "RoleBg")
    self.Preview = self.EquipRoleCon:FindChild("Preview").gameObject
    self.EquipGirds = self.EquipRoleCon:FindChild("EquipGirds")
    self.Weapon = self.EquipGirds:FindChild("Weapon"):Find("ItemSlot").gameObject
    self.Ring = self.EquipGirds:FindChild("Ring"):Find("ItemSlot").gameObject
    self.Necklace = self.EquipGirds:FindChild("Necklace"):Find("ItemSlot").gameObject
    self.Bracelet = self.EquipGirds:FindChild("Bracelet"):Find("ItemSlot").gameObject
    self.Coat = self.EquipGirds:FindChild("Coat"):Find("ItemSlot").gameObject
    self.Belt = self.EquipGirds:FindChild("Belt"):Find("ItemSlot").gameObject
    self.Pants = self.EquipGirds:FindChild("Pants"):Find("ItemSlot").gameObject
    self.Shoe = self.EquipGirds:FindChild("Shoe"):Find("ItemSlot").gameObject

    self.Weapon_slot = ItemSlot.New(self.Weapon)
    self.Ring_slot = ItemSlot.New(self.Ring)
    self.Necklace_slot = ItemSlot.New(self.Necklace)
    self.Bracelet_slot = ItemSlot.New(self.Bracelet)
    self.Coat_slot = ItemSlot.New(self.Coat)
    self.Belt_slot = ItemSlot.New(self.Belt)
    self.Pants_slot = ItemSlot.New(self.Pants)
    self.Shoe_slot = ItemSlot.New(self.Shoe)

    self.equip_dic = {}
    table.insert(self.equip_dic, self.Weapon_slot)
    table.insert(self.equip_dic, self.Ring_slot)
    table.insert(self.equip_dic, self.Necklace_slot)
    table.insert(self.equip_dic, self.Bracelet_slot)
    table.insert(self.equip_dic, self.Coat_slot)
    table.insert(self.equip_dic, self.Belt_slot)
    table.insert(self.equip_dic, self.Pants_slot)
    table.insert(self.equip_dic, self.Shoe_slot)
    self.slot_data_dic = {}

    for i=1,#self.equip_dic do
        local temp_slot = self.equip_dic[i]
        temp_slot:SetNotips(true)
        temp_slot:ShowLevel(true)
        temp_slot:SetSelectSelfCallback(function()
            --选中第一个孔位
            self:on_selected_equip_slot(temp_slot)
        end)
    end

    self.Fight = self.EquipRoleCon:FindChild("Fight")
    self.Fight_Value = self.Fight:FindChild("Value"):GetComponent(Text)

    self.RoleBottomConSuit = self.EquipRoleCon:FindChild("RoleBottomConSuit")
    self.RoleBottomConSuit_btn = self.RoleBottomConSuit:GetComponent(Button)
    self.ImgProg = self.RoleBottomConSuit:FindChild("ImgProg")
    self.ImgProgBar = self.ImgProg:FindChild("ImgProgBar").gameObject
    self.ImgProgBar_rect = self.ImgProgBar.gameObject.transform:GetComponent(RectTransform)
    self.TxtProg = self.ImgProg:FindChild("TxtProg"):GetComponent(Text)

    self.RoleBottomConSuit_btn.onClick:AddListener(function()
        local tips = {}
        local backsmith_lev = EquipStrengthManager.Instance.model.backsmith_lev
        if backsmith_lev >= 40 then
            local key = string.format("%s_%s", backsmith_lev - 10, RoleManager.Instance.RoleData.classes)
            local attrs1 = DataEqm.data_level_suit[key].attr
            table.insert(tips, string.format(TI18N("<color='#ffff00'>已激活套装属性:</color>")))
            for i,v in ipairs(attrs1) do
                table.insert(tips, string.format("<color='#00ffff'>%s +%s</color>", KvData.attr_name[v.attr_name], v.val))
            end
            table.insert(tips, "")
        end

        if backsmith_lev <= EquipStrengthManager.Instance.model.max_backsmith_lev then
            if backsmith_lev >= 40 then
                table.insert(tips, "")
            end
            table.insert(tips, string.format(TI18N("<color='#00ff12'>%s级套装属性</color>"), backsmith_lev))
            table.insert(tips, string.format(TI18N("(激活进度:%s/8)"), EquipStrengthManager.Instance.model.backsmith_count))
            table.insert(tips, string.format(TI18N("全身装备等级达到%s级即可激活以下效果:"), backsmith_lev))

            local key = string.format("%s_%s", backsmith_lev, RoleManager.Instance.RoleData.classes)
            local attrs = DataEqm.data_level_suit[key].attr

            for i,v in ipairs(attrs) do
                table.insert(tips, string.format("<color='#00ffff'>%s +%s</color>", KvData.attr_name[v.attr_name], v.val))
            end
        end
        TipsManager.Instance:ShowText({gameObject = self.RoleBottomConSuit_btn.gameObject, itemData = tips})
    end)

    self.RoleBottomStrength = self.EquipRoleCon:FindChild("RoleBottomStrength")
    self.RoleBottomStrength_btn = self.RoleBottomStrength:GetComponent(Button)
    self.RoleBottomStrength_btn.onClick:AddListener(function()
        local tips = {}
        local strength_lev = EquipStrengthManager.Instance.model.strength_lev
        if  strength_lev >= 8 or (strength_lev == 7 and EquipStrengthManager.Instance.model.strength_count == 8) then
            table.insert(tips, string.format(TI18N("<color='#ffff00'>已激活强化套装属性:</color>")))
            -- local ll = EquipStrengthManager.Instance.model.last_strength_lev[strength_lev]
            local ddata = DataEqm.data_enchant_suit[strength_lev]
            local attrs1 = ddata.attr
            local skills = ddata.skill_prac
            for i,v in ipairs(attrs1) do
                table.insert(tips, string.format("<color='#00ffff'>%s +%s</color>", KvData.attr_name[v.attr_name], v.val))
            end
            for i,v in ipairs(skills) do
                local id = tonumber(v[1])
                local add = tonumber(v[2])
                local sdata = DataSkillPrac.data_skill[id]
                table.insert(tips, string.format("<color='#00ffff'>%s +%s</color>", sdata.name, add))
            end
            table.insert(tips, "")
        end

        if strength_lev < EquipStrengthManager.Instance.model.max_strength_lev then
            local next_strength_lev = strength_lev+1
            local next_strength_count = EquipStrengthManager.Instance.model.next_strength_count
            if EquipStrengthManager.Instance.model.strength_count == 0 and strength_lev == EquipStrengthManager.Instance.model.min_strength_lev then
                next_strength_lev = strength_lev
                next_strength_count = EquipStrengthManager.Instance.model.strength_count
            end
            table.insert(tips, string.format("<color='#808080'>%s</color>", TI18N("下级可激活套装属性")))
            table.insert(tips, string.format(TI18N("<color='#808080'>全身装备强化%s级</color>"), next_strength_lev))
            table.insert(tips, string.format(TI18N("<color='#808080'>(激活进度:%s/8)</color>"), next_strength_count))
            table.insert(tips, string.format(TI18N("<color='#808080'>穿上8件 +%s 的装备即可激活以下效果:</color>"), next_strength_lev))

            local ddata = DataEqm.data_enchant_suit[next_strength_lev]
            local attrs = ddata.attr
            local skills = ddata.skill_prac
            for i,v in ipairs(attrs) do
                table.insert(tips, string.format("<color='#808080'>%s +%s</color>", KvData.attr_name[v.attr_name], v.val))
            end
            for i,v in ipairs(skills) do
                local id = tonumber(v[1])
                local add = tonumber(v[2])
                local sdata = DataSkillPrac.data_skill[id]
                table.insert(tips, string.format("<color='#808080'>%s +%s</color>", sdata.name, add))
            end
        end
        TipsManager.Instance:ShowText({gameObject = self.RoleBottomStrength_btn.gameObject, itemData = tips})
    end)
    self.strength_icon_list = {}
    for i=1,6 do
        local icon = self.RoleBottomStrength:FindChild(string.format("ImgIcon%s",i))
        self.strength_icon_list[i+6] = icon
    end


    self:update_left_equip_list()
    self:UpdatePreview()
    --更新战力
    self:update_zhanli()
    self:update_bottom_con()
    self.is_open = true

    if RoleManager.Instance.RoleData.lev >= 70 then
        self:tabChange(EquipStrengthManager.Instance.model.trans_type)
    else
        self:tabChange(1)
    end
    
    EventMgr.Instance:AddListener(event_name.equip_item_change, self.on_equip_update)

    EventMgr.Instance:AddListener(event_name.equip_last_lev_attr_update, self.on_equip_slot)
end

 -- 切换tab逻辑
function EquipStrengthTransformWindow:tabChange(index)
    if self.is_open == false then
        return
    end

    if self.subFirst ~= nil then
        self.subFirst:Hiden()
    end
    if self.subSecond ~= nil then
        self.subSecond:Hiden()
    end

    if index == 1 then
        --转换
        self.subFirst:Show()
        self.cur_tab = self.subFirst

        self:switch_tab_btn(self.tab_btn1)
    elseif index == 2 then
        --洗练
        self.subSecond:Show()
        self.cur_tab = self.subSecond
        -- self.subSecond:update_cur_selected_equip()
        self:switch_tab_btn(self.tab_btn2)
    end
end

function EquipStrengthTransformWindow:switch_tab_btn(btn)
    self.tab_btn1.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn2.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn1.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn2.transform:FindChild("Normal").gameObject:SetActive(true)
    btn.transform:FindChild("Select").gameObject:SetActive(true)
    btn.transform:FindChild("Normal").gameObject:SetActive(false)
end

--更新战力
function EquipStrengthTransformWindow:update_zhanli()
    self.Fight_Value.text = tostring(RoleManager.Instance.RoleData.fc)
end

--更新底部
function EquipStrengthTransformWindow:update_bottom_con()
    EquipStrengthManager.Instance.model:count_backsmith_info(BackpackManager.Instance.equipDic)
    EquipStrengthManager.Instance.model:count_strength_info(BackpackManager.Instance.equipDic)

     --铸造，重铸
    local percent = EquipStrengthManager.Instance.model.backsmith_count/8

    self.ImgProgBar_rect.sizeDelta = Vector2(190*percent, self.ImgProgBar_rect.rect.height)

    local backsmith_lev = EquipStrengthManager.Instance.model.backsmith_lev
    if backsmith_lev > EquipStrengthManager.Instance.model.max_backsmith_lev then
        backsmith_lev = EquipStrengthManager.Instance.model.max_backsmith_lev
    end

    self.TxtProg.text = string.format("%s%s:%s/%s", backsmith_lev, TI18N("级套装"), EquipStrengthManager.Instance.model.backsmith_count, 8)
end

---------------------------------------------监听器

--选中某个装备
function EquipStrengthTransformWindow:on_selected_equip_slot(slot)

    if self.last_selected_slot ~= nil then
        self.last_selected_slot:ShowSelect(false)
    end
    self.last_selected_slot = slot
    self.last_selected_slot:ShowSelect(true)
    self:update_right_equip(self.slot_data_dic[slot])
    self:update_right_extra_prop(self.slot_data_dic[slot])

    if EquipStrengthManager.Instance.model.equip_spare_attr_list[self.cur_select_equip_data.id] == nil then
        --没有这个装备的切换数据则请求一下
        EquipStrengthManager.Instance:request10620(self.cur_select_equip_data.id)
    end
end


---------------------------------------------各种更新逻辑

--更新装备slot数据
function EquipStrengthTransformWindow:update_equip_slot()
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        local slot = self.equip_dic[v.id]
        local base_data = DataItem.data_get[v.base_id]
        local temp_lev = EquipStrengthManager.Instance.model:check_equip_is_last_lev(v)
        self:set_equip_slot_data(slot, v)
        slot:SetLevel(temp_lev)
    end

    self:on_selected_equip_slot(self.last_selected_slot)
end



--更新装备数据
function EquipStrengthTransformWindow:update_left_equip_list(_type)
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        local slot = self.equip_dic[v.id]
        local base_data = DataItem.data_get[v.base_id]
        base_data.enchant = v.enchant
        self:set_equip_slot_data(slot, base_data)

        local temp_lev = EquipStrengthManager.Instance.model:check_equip_is_last_lev(v)
        slot:SetLevel(temp_lev)

        slot:ShowLevel(true)
        self.slot_data_dic[slot] = v
    end

    if _type ~= nil then
        if self.last_selected_slot ~= nil then
            self.last_selected_slot:ShowSelect(true)
        end
        return
    end

    if self.model.is_from_backpack then
        self.model.is_from_backpack = false

        local is_ok = false
        for i=1,#self.equip_dic do
            local eq = self.equip_dic[i]
            local eq_data = self.slot_data_dic[eq]
            for j=1,#eq_data.attr do
                local ad = eq_data.attr[j]
                if ad.type == GlobalEumn.ItemAttrType.effect then
                    self:on_selected_equip_slot(eq)
                    is_ok = true
                    break
                end
            end
            if is_ok then
                break
            end
        end
    else
        --默认选中第一件装备
        if EquipStrengthManager.Instance.model.trans_type == 1 then
            if self.last_selected_slot ~= nil then
                self:on_selected_equip_slot(self.last_selected_slot)
            else
                if self.model.trans_data ~= nil then
                    for i=1,#self.equip_dic do
                        local eq = self.equip_dic[i]
                        if eq.itemData.type == self.model.trans_data.type then
                            self:on_selected_equip_slot(self.equip_dic[i])
                        end
                    end
                end
            end
        else
            --洗炼
            if self.model.trans_data ~= nil then
                for i=1,#self.equip_dic do
                    local eq = self.equip_dic[i]
                    if eq.itemData.type == self.model.trans_data.type then
                        self:on_selected_equip_slot(self.equip_dic[i])
                    end
                end
            else
                local is_ok = false
                for i=1,#self.equip_dic do
                    local eq = self.equip_dic[i]
                    local eq_data = self.slot_data_dic[eq]
                    for j=1,#eq_data.attr do
                        local ad = eq_data.attr[j]
                        if ad.type == GlobalEumn.ItemAttrType.effect then
                            self:on_selected_equip_slot(eq)
                            is_ok = true
                            break
                        end
                    end
                    if is_ok then
                        break
                    end
                end
                if is_ok == false then
                    self:on_selected_equip_slot(self.equip_dic[1])
                end
            end
        end
    end
end

--更新右边装备extra_prop
function EquipStrengthTransformWindow:update_right_extra_prop(data)
    self.cur_select_equip_data = data
    self.subFirst:update_right_extra_prop(data)
    self.subSecond:update_right_extra_prop(data)
end

--更新右边装备
function EquipStrengthTransformWindow:update_right_equip(data)
    self.cur_select_equip_data = data
    self.model.selected_effect = nil 
    self.model.selected_effect_flag = false
    self.subFirst:update_right_equip(data)
    self.subSecond:update_right_equip(data)
end

---------------------------------------------辅助函数
--对slot设置数据
function EquipStrengthTransformWindow:set_equip_slot_data(slot, data, _nobutton)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if nobutton == nil then
        slot:SetAll(cell, {_nobutton = true})
    else
        slot:SetAll(cell, {nobutton = _nobutton})
    end
end


--------------------------------------------------模型逻辑
function EquipStrengthTransformWindow:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "EquipStrengthTransformWindow"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = SceneManager.Instance:MyData().looks}
    self.previewComp = PreviewComposite.New(callback, setting, modelData)
end


function EquipStrengthTransformWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.Preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.Preview:SetActive(true)
end
