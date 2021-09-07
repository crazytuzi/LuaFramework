EquipStrengthFirstRole = EquipStrengthFirstRole or BaseClass(BasePanel)

function EquipStrengthFirstRole:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.equip_strength_role, type = AssetType.Main},
        {file = AssetConfig.rolebgnew, type = AssetType.Dep},
        {file = AssetConfig.equip_strength_dianhua_badges, type = AssetType.Dep},
        {file = string.format(AssetConfig.effect, 20242), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    self.on_role_fc_chang = function()
        self:update_zhanli()
    end
    self.on_equip_update = function(equips)
        if equips.type == 1 or (equips.type == 0 and self.parent.cur_tab_index ~= 1 ) or equips.type == nil then
            self:update_equip_data(false)
            self:update_bottom_info()
        end
    end

    self.on_item_update = function()
        self:update_equip_data(true)
        self:update_bottom_info()
    end

    self.on_equip_slot = function()
        self:update_equip_slot()
    end

    self.OnHideEvent:Add(function()
        if self.previewComp ~= nil then
            self.previewComp:Hide()
        end

        if self.guideEffect ~= nil then
            self.guideEffect:SetActive(false)
        end
    end)
    self.OnOpenEvent:Add(function()
        if self.previewComp ~= nil then
            self.previewComp:Show()
        end

        self.parent:CheckGuidePoint()
    end)

    self.lastBadageId = -1

    self.has_init = false
    self.selectIndex = 0
    self.guideEffect = nil

    return self
end

function EquipStrengthFirstRole:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    if self.guideEffect ~= nil then
        self.guideEffect:DeleteMe()
        self.guideEffect = nil
    end

    EventMgr.Instance:RemoveListener(event_name.role_looks_change, self.on_looks_update)
    EventMgr.Instance:RemoveListener(event_name.role_attr_change, self.on_role_fc_chang)
    EventMgr.Instance:RemoveListener(event_name.equip_item_change, self.on_equip_update)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
    EventMgr.Instance:RemoveListener(event_name.equip_dianhua_save_success, self.updateBadgeListener)
    EventMgr.Instance:RemoveListener(event_name.equip_dianhua_success, self.updateBadgeListener)
    EventMgr.Instance:RemoveListener(event_name.equip_last_lev_attr_update, self.on_equip_slot)

    self.Weapon_slot:DeleteMe()
    self.Ring_slot:DeleteMe()
    self.Necklace_slot:DeleteMe()
    self.Bracelet_slot:DeleteMe()
    self.Coat_slot:DeleteMe()
    self.Belt_slot:DeleteMe()
    self.Pants_slot:DeleteMe()
    self.Shoe_slot:DeleteMe()

    if self.fly_effect ~= nil then
        self.fly_effect:DeleteMe()
        self.fly_effect = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.has_init = false
    self:AssetClearAll()
end

function EquipStrengthFirstRole:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_role))
    self.gameObject.name = "EquipStrengthFirstRole"
    self.transform = self.gameObject.transform

    self.transform:SetParent(self.parent.gameObject.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(-221, -9, 0)

    self.transform:SetAsFirstSibling()

    self.transform:Find("ImgBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")

    self.Preview = self.transform:FindChild("Preview").gameObject

    self.EquipGirds = self.transform:FindChild("EquipGirds")
    self.WeaponParent = self.EquipGirds:FindChild("Weapon")
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
            self.selectIndex = i
            self.parent:CheckGuidePoint()
        end)
    end

    self.Fight = self.transform:FindChild("Fight")
    self.Fight_Value = self.Fight:FindChild("Value"):GetComponent(Text)

    --套装con
    self.RoleBottomConSuit = self.transform:FindChild("RoleBottomConSuit")
    self.RoleBottomConSuit_btn = self.RoleBottomConSuit:GetComponent(Button)
    self.ImgProg = self.RoleBottomConSuit:FindChild("ImgProg")
    self.ImgProgBar = self.ImgProg:FindChild("ImgProgBar").gameObject
    self.ImgProgBar_rect = self.ImgProgBar.gameObject.transform:GetComponent(RectTransform)
    self.TxtProg = self.ImgProg:FindChild("TxtProg"):GetComponent(Text)

    self.RoleBottomConSuit_btn.onClick:AddListener(function() self:ClickRoleBottomSuit() end)

    --强化con
    self.RoleBottomStrength = self.transform:FindChild("RoleBottomStrength")
    self.RoleBottomStrength_btn = self.RoleBottomStrength:GetComponent(Button)
    self.RoleBottomStrength_btn.onClick:AddListener(function() self:ClickRoleBottomStrength() end)
    self.strength_icon_list = {}
    self.strength_icon_txt_list = {}
    for i=1,6 do
        local icon = self.RoleBottomStrength:FindChild(string.format("ImgIcon%s",i))
        local iconTxt = icon:FindChild("Text"):GetComponent(Text)
        self.strength_icon_list[i+6] = icon
        self.strength_icon_txt_list[i+6] = iconTxt
    end

    --精炼con
    self.RoleBottomDianhua = self.transform:FindChild("RoleBottomDianhua")
    self.RoleBottomDianhua_Map = self.RoleBottomDianhua:FindChild("LeftTupu")
    self.RoleBottomDianhua_Supian = self.RoleBottomDianhua:FindChild("RightSuipian")

    self.RoleBottomDianhua_Map_btn = self.RoleBottomDianhua:FindChild("LeftTupu"):GetComponent(Button)
    self.RoleBottomDianhua_Supian_btn = self.RoleBottomDianhua:FindChild("RightSuipian"):GetComponent(Button)

    self.RoleBottomDianhua_img1 = self.RoleBottomDianhua_Map:FindChild("ImgMap"):GetComponent(Image)
    self.RoleBottomDianhua_img2 = self.RoleBottomDianhua_Supian:FindChild("ImgFragment"):GetComponent(Image)
    if self.imgLoader == nil then
        local go = self.RoleBottomDianhua_img1.gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 20024)

    self.fly_effect = BibleRewardPanel.ShowEffect(20242, self.RoleBottomDianhua_Supian.transform, Vector3.one, Vector3(0, 0, -400))

    self.has_init = true

    self:RefreshDianhuaBadge()
    self.updateBadgeListener = function()
        self:RefreshDianhuaBadge()
    end

    self.RoleBottomDianhua_Supian_btn.onClick:AddListener(function()
        -- NoticeManager.Instance:FloatTipsByString(TI18N("功能尚未开启敬请期待"))
        -- local npcBase = BaseUtils.copytab(DataUnit.data_unit[20073])
        -- MainUIManager.Instance:OpenDialog({baseid = 20073, name = npcBase.name}, {base = npcBase}, true, true)
        EquipStrengthManager.Instance.model:OpenEquipDianhuaBadgeUI()
    end)

    self.RoleBottomDianhua_Map_btn.onClick:AddListener(function()
        EquipStrengthManager.Instance.model:OpenEquipDianhuaBooksUI()
    end)

    self.RoleBottomConSuit.gameObject:SetActive(false)
    self.RoleBottomStrength.gameObject:SetActive(false)
    self.RoleBottomDianhua.gameObject:SetActive(false)

    self.on_looks_update = function(looks)
        self:UpdatePreview()
    end

    EventMgr.Instance:AddListener(event_name.role_looks_change, self.on_looks_update)

    self:update_equip_data(false)
    self:UpdatePreview()


    --更新战力

    EventMgr.Instance:AddListener(event_name.role_attr_change, self.on_role_fc_chang)
    self:update_zhanli()
    EventMgr.Instance:AddListener(event_name.equip_item_change, self.on_equip_update)

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_item_update)

    EventMgr.Instance:AddListener(event_name.equip_last_lev_attr_update, self.on_equip_slot)

    EventMgr.Instance:AddListener(event_name.equip_dianhua_save_success, self.updateBadgeListener)
    EventMgr.Instance:AddListener(event_name.equip_dianhua_success, self.updateBadgeListener)
    self:update_bottom_con()
    self.parent:CheckGuidePoint()
end

--刷新徽章
function EquipStrengthFirstRole:RefreshDianhuaBadge()
    if self.has_init == false then
        return
    end
    local tempTadgeId = EquipStrengthManager.Instance.model:GetCurEquipBadge()
    local badgeId = tempTadgeId == 0 and 1 or tempTadgeId

    while badgeId > 0 do
        local nextCfgData = DataEqm.data_dianhua_suit[string.format("%s_%s", badgeId, RoleManager.Instance.RoleData.classes)]
        if nextCfgData.ignore == 0 then
            badgeId = badgeId - 1
        else
            break
        end
    end

    local nextBadgeId = badgeId
    while true do
        local nextCfgData = DataEqm.data_dianhua_suit[string.format("%s_%s", nextBadgeId, RoleManager.Instance.RoleData.classes)]
        if nextBadgeId > 0 and (nextCfgData == nil or nextCfgData.ignore == 1) then
            break
        else
            nextBadgeId = nextBadgeId + 1
        end
    end

    self.RoleBottomDianhua_img2.sprite = self.assetWrapper:GetSprite(AssetConfig.equip_strength_dianhua_badges,nextBadgeId)

    if tempTadgeId < 3  then
        self.RoleBottomDianhua:Find("RightSuipian/TxtFragment"):GetComponent(Text).text = string.format(TI18N("%s徽章\n<color='#3166ad'>%s</color>"), EquipStrengthManager.Instance.model.dianhua_name[nextBadgeId], TI18N("未激活"))
    else
        self.RoleBottomDianhua:Find("RightSuipian/TxtFragment"):GetComponent(Text).text = string.format(TI18N("%s徽章"), EquipStrengthManager.Instance.model.dianhua_name[nextBadgeId])
    end

    if nextBadgeId > self.lastBadageId and self.lastBadageId ~= -1 then
        EquipStrengthManager.Instance.model:OpenEquipDianhuaBadgeUI()
    end

    self.lastBadageId = nextBadgeId
end

--------------------------------初始化逻辑

--为slot设置data self.transform:FindChild("RoleBottomDianhua")
function EquipStrengthFirstRole:set_equip_slot_data(slot, data)
    local cell = ItemData.New()
    cell:SetBase(data)
    slot:SetAll(cell, nil)
end



--------------------------------装备逻辑
--更新背包面包选中的那个装备
function EquipStrengthFirstRole:update_cur_selected_equip()
    if self.has_init == false then
        return
    end

    if EquipStrengthManager.Instance.model.strength_data ~= nil then
        for i=1,#self.equip_dic do
            local eq = self.equip_dic[i]
            if eq.itemData.type == EquipStrengthManager.Instance.model.strength_data.type then
                self:on_selected_equip_slot(self.equip_dic[i])
                EquipStrengthManager.Instance.model.strength_data = nil
                break
            end
        end
    elseif EquipStrengthManager.Instance.model.dianhua_data ~= nil then
        for i=1,#self.equip_dic do
            local eq = self.equip_dic[i]
            if eq.itemData.type == EquipStrengthManager.Instance.model.dianhua_data.type then
                self:on_selected_equip_slot(self.equip_dic[i])
                EquipStrengthManager.Instance.model.dianhua_data = nil
                break
            end
        end
    else
        if self.last_selected_slot == nil then
            self:on_selected_equip_slot(self.equip_dic[1])
        else
            self:on_selected_equip_slot(self.last_selected_slot)
        end
    end
end

function EquipStrengthFirstRole:update_slot_redpoint()
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        local slot = self.equip_dic[v.id]

        local red_point = false
        if self.parent.cur_tab_index == 4 then
            -- 精炼的红点显示单纯是精炼的
            red_point = EquipStrengthManager.Instance.model:check_can_dianhua(v)

            if EquipStrengthManager.Instance.model:check_has_equip_changeclasses_dianhua() then
                red_point = true
            end
        else
            local cfg_data = DataBacksmith.data_forge[string.format("%s_%s_%s",v.base_id,RoleManager.Instance.RoleData.sex, RoleManager.Instance.RoleData.classes)]
            if cfg_data ~= nil then
                local next_cfg_base_data = DataItem.data_get[cfg_data.next_id]
                local baseData = DataItem.data_get[cfg_data.base_id]
                local next_cfg_base_data = DataItem.data_get[cfg_data.next_id]
                local curEquipType = baseData.type
                red_point = false
                if (curEquipType == BackpackEumn.ItemType.cloth or curEquipType == BackpackEumn.ItemType.waistband or curEquipType == BackpackEumn.ItemType.trousers or curEquipType == BackpackEumn.ItemType.shoe) then
                    --衣服、腰带、裤子、鞋子 特殊处理
                    if cfg_data.need_lev <= RoleManager.Instance.RoleData.lev and cfg_data.need_break_times <= RoleManager.Instance.RoleData.lev_break_times then
                        red_point = true
                    end
                else
                    if next_cfg_base_data.lev <= RoleManager.Instance.RoleData.lev and cfg_data.need_break_times <= RoleManager.Instance.RoleData.lev_break_times then
                        red_point = true
                    end
                end
            end
        end
        slot:ShowLevel(true)
        slot:ShowState(red_point)
    end
end

--更新装备slot数据
function EquipStrengthFirstRole:update_equip_slot()
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        local slot = self.equip_dic[v.id]
        local base_data = DataItem.data_get[v.base_id]
        local temp_lev = EquipStrengthManager.Instance.model:check_equip_is_last_lev(v)
        self:set_equip_slot_data(slot, v)
        slot:SetLevel(temp_lev)
    end

    self:update_slot_redpoint()

    if self.last_selected_slot ~= nil then
        self.last_selected_slot:ShowSelect(true)
    end
end

--更新装备数据
function EquipStrengthFirstRole:update_equip_data(is_item_update)
    self.is_item_update = is_item_update


    for k,v in pairs(BackpackManager.Instance.equipDic) do
        local slot = self.equip_dic[v.id]
        local base_data = DataItem.data_get[v.base_id]

        local temp_lev = EquipStrengthManager.Instance.model:check_equip_is_last_lev(v)

        self:set_equip_slot_data(slot, v)
        slot:SetLevel(temp_lev)
        self.slot_data_dic[slot] = v
    end

    if EquipStrengthManager.Instance.model.strength_data ~= nil then
        for i=1,#self.equip_dic do
            local eq = self.equip_dic[i]
            if eq.itemData.type == EquipStrengthManager.Instance.model.strength_data.type then
                self:on_selected_equip_slot(self.equip_dic[i])
                break
            end
        end
        --没找到对应类型的，则打开第一个
        if self.last_selected_slot == nil then
            self:on_selected_equip_slot(self.equip_dic[1])
        else
            self:on_selected_equip_slot(self.last_selected_slot)
        end
        EquipStrengthManager.Instance.model.strength_data = nil
    elseif EquipStrengthManager.Instance.model.dianhua_data ~= nil then
        for i=1,#self.equip_dic do
            local eq = self.equip_dic[i]
            if eq.itemData.type == EquipStrengthManager.Instance.model.dianhua_data.type then
                self:on_selected_equip_slot(self.equip_dic[i])
                break
            end
        end
        --没找到对应类型的，则打开第一个
        if self.last_selected_slot == nil then
            self:on_selected_equip_slot(self.equip_dic[1])
        else
            self:on_selected_equip_slot(self.last_selected_slot)
        end
        EquipStrengthManager.Instance.model.dianhua_data = nil
    elseif self.last_selected_slot ~= nil then
        --判断下上次操作是不是锻造
        if self.parent.cur_tab_index == 1 then
            local slot_data = self.slot_data_dic[self.last_selected_slot]
            if slot_data.lev < RoleManager.Instance.RoleData.lev then
                self:on_selected_equip_slot(self.last_selected_slot)
            else
                local next_build_slot = nil
                for k,v in pairs(self.equip_dic) do
                    local equip_data = self.slot_data_dic[v]
                    if equip_data.lev < RoleManager.Instance.RoleData.lev and equip_data.lev < 40 then
                        next_build_slot = v
                        break
                    end
                end
                if next_build_slot == nil then
                    self:on_selected_equip_slot(self.last_selected_slot)
                else
                    self:on_selected_equip_slot(next_build_slot)
                end
            end
        else
            self:on_selected_equip_slot(self.last_selected_slot)
        end
    else
        self:on_selected_equip_slot(self.equip_dic[1])
    end


    self:update_slot_redpoint()
end

--选中某个装备
function EquipStrengthFirstRole:on_selected_equip_slot(slot)

    if self.last_selected_slot ~= nil then
        self.last_selected_slot:ShowSelect(false)
    end
    self.last_selected_slot = slot

    self.last_selected_slot:ShowSelect(true)

    self.parent:update_right(self.slot_data_dic[slot], self.is_item_update)
end


--更新战力
function EquipStrengthFirstRole:update_zhanli()
    self.Fight_Value.text = tostring(RoleManager.Instance.RoleData.fc)
end

--单个武器更新
function EquipStrengthFirstRole:update_bottom_info()

    --更新底部显示
    self:update_bottom_con()
end

--更新底部
function EquipStrengthFirstRole:update_bottom_con()
    EquipStrengthManager.Instance.model:count_backsmith_info(BackpackManager.Instance.equipDic)
    EquipStrengthManager.Instance.model:count_strength_info(BackpackManager.Instance.equipDic)

    self.RoleBottomConSuit.gameObject:SetActive(false)
    self.RoleBottomStrength.gameObject:SetActive(false)
    self.RoleBottomDianhua.gameObject:SetActive(false)


    if self.parent.cur_tab_index == 1 or self.parent.cur_tab_index == 2 then
        --锻造
        self.RoleBottomConSuit.gameObject:SetActive(true)

        --铸造
        local percent = EquipStrengthManager.Instance.model.backsmith_count/8
        self.ImgProgBar_rect.sizeDelta = Vector2(190*percent, self.ImgProgBar_rect.rect.height)

        local backsmith_lev = EquipStrengthManager.Instance.model.backsmith_lev
        if backsmith_lev > EquipStrengthManager.Instance.model.max_backsmith_lev then
            backsmith_lev = EquipStrengthManager.Instance.model.max_backsmith_lev
        end

        self.TxtProg.text = string.format("%s%s:%s/%s", backsmith_lev, TI18N("级套装"), EquipStrengthManager.Instance.model.backsmith_count, 8)
    elseif self.parent.cur_tab_index == 3 then
        --强化
        self.RoleBottomStrength.gameObject:SetActive(true)
        --强化
        if EquipStrengthManager.Instance.model.strength_lev == 7 and EquipStrengthManager.Instance.model.strength_count ~= 8 then
            --全空
            for k, v in pairs(self.strength_icon_list) do
                local green = v:FindChild("ImgHas").gameObject
                local oringe = v:FindChild("ImgCur").gameObject
                green:SetActive(false)
                oringe:SetActive(false)
            end
        else
            for k, v in pairs(self.strength_icon_list) do
                local green = v:FindChild("ImgHas").gameObject
                local oringe = v:FindChild("ImgCur").gameObject
                green:SetActive(false)
                oringe:SetActive(false)
            end
            --得判断下是否满足全部强12激活
            if EquipStrengthManager.Instance.model.strength_lev >= 12 and EquipStrengthManager.Instance.model.strength_count == 8 then
                --10 11 12 13 14 15
                for k, v in pairs(self.strength_icon_list) do
                    if k+3 >  EquipStrengthManager.Instance.model.max_strength_lev then
                        v.gameObject:SetActive(false)
                    else
                        v.gameObject:SetActive(true)
                        self.strength_icon_txt_list[k].text = tostring(k+3)
                        if k+3 < EquipStrengthManager.Instance.model.strength_lev then
                            local green = v:FindChild("ImgHas").gameObject
                            local oringe = v:FindChild("ImgCur").gameObject
                            green:SetActive(true)
                            oringe:SetActive(false)
                        elseif k+3 == EquipStrengthManager.Instance.model.strength_lev then
                            local green = v:FindChild("ImgHas").gameObject
                            local oringe = v:FindChild("ImgCur").gameObject
                            green:SetActive(false)
                            oringe:SetActive(true)
                        end
                    end
                end
            else
                --7 8 9 10 11 12
                for k, v in pairs(self.strength_icon_list) do
                    v.gameObject:SetActive(true)
                    self.strength_icon_txt_list[k].text = tostring(k)
                    if k < EquipStrengthManager.Instance.model.strength_lev then
                        local green = v:FindChild("ImgHas").gameObject
                        local oringe = v:FindChild("ImgCur").gameObject
                        green:SetActive(true)
                        oringe:SetActive(false)
                    elseif k == EquipStrengthManager.Instance.model.strength_lev then
                        local green = v:FindChild("ImgHas").gameObject
                        local oringe = v:FindChild("ImgCur").gameObject
                        green:SetActive(false)
                        oringe:SetActive(true)
                    end
                end
            end
        end
    elseif self.parent.cur_tab_index == 4 then
        --精炼
        self.RoleBottomDianhua.gameObject:SetActive(true)
    end
end




-------------------模型逻辑
function EquipStrengthFirstRole:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end

    local setting = {
        name = "EquipStrengthFirstRole"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = SceneManager.Instance:MyData().looks}
    if BaseUtils.IsVerify then
        modelData.isTransform = true
    end
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
end


function EquipStrengthFirstRole:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.Preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.Preview:SetActive(true)
end

function EquipStrengthFirstRole:ClickRoleBottomStrength()
    local strength_lev = EquipStrengthManager.Instance.model.strength_lev
    self.parent:ShowStrengthTips()
    -- if strength_lev >= 13 then
    --     -- 13以上显示另外的界面
    --     self.parent:ShowStrengthTips()
    -- else
    --     local tips = {}
    --     if  strength_lev >= 8 or (strength_lev == 7 and EquipStrengthManager.Instance.model.strength_count == 8) then
    --         table.insert(tips, string.format(TI18N("<color='#ffff00'>已激活强化套装属性:</color>")))
    --         -- local ll = EquipStrengthManager.Instance.model.last_strength_lev[strength_lev]
    --         local ddata = DataEqm.data_enchant_suit[strength_lev]
    --         local attrs1 = ddata.attr
    --         local skills = ddata.skill_prac
    --         for i,v in ipairs(attrs1) do
    --             table.insert(tips, string.format("<color='#00ffff'>%s +%s</color>", KvData.attr_name[v.attr_name], v.val))
    --         end
    --         for i,v in ipairs(skills) do
    --             local id = tonumber(v[1])
    --             local add = tonumber(v[2])
    --             local sdata = DataSkillPrac.data_skill[id]
    --             table.insert(tips, string.format("<color='#00ffff'>%s +%s</color>", sdata.name, add))
    --         end
    --         table.insert(tips, "")
    --     end

    --     if strength_lev < EquipStrengthManager.Instance.model.max_strength_lev then
    --         local next_strength_lev = strength_lev+1
    --         local next_strength_count = EquipStrengthManager.Instance.model.next_strength_count
    --         if EquipStrengthManager.Instance.model.strength_count == 0 and strength_lev == EquipStrengthManager.Instance.model.min_strength_lev then
    --             next_strength_lev = strength_lev
    --             next_strength_count = EquipStrengthManager.Instance.model.strength_count
    --         end
    --         table.insert(tips, string.format("<color='#808080'><size=20>%s</size></color>", TI18N("下级可激活套装属性")))
    --         table.insert(tips, string.format(TI18N("<color='#808080'>全身装备强化%s级</color>"), next_strength_lev))
    --         table.insert(tips, string.format(TI18N("<color='#808080'>(激活进度:%s/8)</color>"), next_strength_count))
    --         table.insert(tips, string.format(TI18N("<color='#808080'>穿上8件 +%s 的装备即可激活以下效果:</color>"), next_strength_lev))
    --         local ddata = DataEqm.data_enchant_suit[next_strength_lev]
    --         local attrs = ddata.attr
    --         local skills = ddata.skill_prac
    --         for i,v in ipairs(attrs) do
    --             table.insert(tips, string.format("<color='#808080'>%s +%s</color>", KvData.attr_name[v.attr_name], v.val))
    --         end
    --         for i,v in ipairs(skills) do
    --             local id = tonumber(v[1])
    --             local add = tonumber(v[2])
    --             local sdata = DataSkillPrac.data_skill[id]
    --             table.insert(tips, string.format("<color='#808080'>%s +%s</color>", sdata.name, add))
    --         end
    --     end
    --     TipsManager.Instance:ShowText({gameObject = self.RoleBottomStrength_btn.gameObject, itemData = tips})
    -- end
end

function EquipStrengthFirstRole:ClickRoleBottomSuit()
    local tips = {}
    local backsmith_lev = EquipStrengthManager.Instance.model.backsmith_lev
    if backsmith_lev >= 40 then
        local key = string.format("%s_%s", backsmith_lev - 10, RoleManager.Instance.RoleData.classes)
        if EquipStrengthManager.Instance.model.backsmith_count == 8 and backsmith_lev == 90 then
            key = string.format("%s_%s", backsmith_lev, RoleManager.Instance.RoleData.classes)
            table.insert(tips, string.format(TI18N("<color='#ffff00'>已激活套装属性:</color>（当前已达到最高等级）")))
        else
            table.insert(tips, string.format(TI18N("<color='#ffff00'>已激活套装属性:</color>")))
        end

        local attrs1 = DataEqm.data_level_suit[key].attr
        for i,v in ipairs(attrs1) do
            table.insert(tips, string.format("<color='#00ffff'>%s +%s</color>", KvData.attr_name[v.attr_name], v.val))
        end
    end

    if backsmith_lev <= EquipStrengthManager.Instance.model.max_backsmith_lev then
        if backsmith_lev >= 40 then table.insert(tips, "")
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
end

function EquipStrengthFirstRole:CheckGuidePoint()
    if self.WeaponParent ~= nil then
      if MainUIManager.Instance.priority == 3 then
            TipsManager.Instance:ShowGuide({gameObject = self.WeaponParent.gameObject, data = TI18N("选择需要锻造的武器"), forward = TipsEumn.Forward.Right})

            if self.guideEffect == nil then
                self.guideEffect = BibleRewardPanel.ShowEffect(20103,self.WeaponParent.transform,Vector3(0.9,0.9,1), Vector3(34,-32,-400))
            end
            self.guideEffect:SetActive(true)

        elseif MainUIManager.Instance.priority == 1 then
            TipsManager.Instance:ShowGuide({gameObject = self.WeaponParent.gameObject, data = TI18N("选择需要强化的装备"), forward = TipsEumn.Forward.Right})
            if self.guideEffect == nil then
                self.guideEffect = BibleRewardPanel.ShowEffect(20103,self.WeaponParent.transform,Vector3(0.9,0.9,1), Vector3(34,-32,-400))
            end
            self.guideEffect:SetActive(true)
        elseif MainUIManager.Instance.priority == -1 then
            TipsManager.Instance:ShowGuide({gameObject = self.WeaponParent.gameObject, data = TI18N("选择需要精炼的装备"), forward = TipsEumn.Forward.Right})
            if self.guideEffect == nil then
                self.guideEffect = BibleRewardPanel.ShowEffect(20103,self.WeaponParent.transform,Vector3(0.9,0.9,1), Vector3(34,-32,-400))
            end
            self.guideEffect:SetActive(true)
        end
    end

end

function EquipStrengthFirstRole:HideGuideEffect()
    if self.guideEffect ~= nil then
        self.guideEffect:SetActive(false)
    end
end