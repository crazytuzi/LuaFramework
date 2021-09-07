EquipStrengthTransSecondTab = EquipStrengthTransSecondTab or BaseClass(BasePanel)

function EquipStrengthTransSecondTab:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.equip_strength_trans_right_con, type = AssetType.Main}
    }
    self.model = EquipStrengthManager.Instance.model
    self.has_init = false

    self.item_list = nil

    --装备类型对应表 "武器" 1,"戒指" 2,"项链" 3,"手镯" 4,"衣服" 5,"腰带" 6,"裤子" 7,"鞋子" 8,
    self.equiptype = {
        [1] = 1
        ,[2] = 1
        ,[3] = 1
        ,[4] = 1
        ,[5] = 1
        ,[21] = 1
        ,[22] = 1
        ,[6] = 2
        ,[7] = 3
        ,[9] = 4
        ,[10] = 5
        ,[11] = 6
        ,[12] = 7
        ,[14] = 8
    }


    self.updateListener = function()
        if self.has_init == false then
            return
        end
        self:update_cost()
    end

    self.trans_reset_back = function(data)
        if self.has_init == false then
            return
        end
        self:update_save_state(data)
    end

    self.on_equip_update = function()
        self:update_cur_selected_equip()
    end

    self.on_update_save = function()
        self.right_bottom_txt.gameObject:SetActive(true)
        self.right_btn_save.gameObject:SetActive(false)
    end

    return self
end

function EquipStrengthTransSecondTab:__delete()
    if self.top_left_slot ~= nil then
        self.top_left_slot:DeleteMe()
        self.top_left_slot = nil
    end

    if self.bottom_slot_1 ~= nil then
        self.bottom_slot_1:DeleteMe()
        self.bottom_slot_1 = nil
    end

    if self.bottom_slot_2 ~= nil then
        self.bottom_slot_2:DeleteMe()
        self.bottom_slot_2 = nil
    end

    if self.bottom_slot_3 ~= nil then
        self.bottom_slot_3:DeleteMe()
        self.bottom_slot_3 = nil
    end

    self.has_init = false
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.equip_item_change, self.on_equip_update)
    EventMgr.Instance:RemoveListener(event_name.equip_build_resetval_save_ok, self.on_update_save)
    EventMgr.Instance:RemoveListener(event_name.equip_strength_trans_attr_back, self.trans_reset_back)

    if self.trans_btn ~= nil then
        self.trans_btn:DeleteMe()
        self.trans_btn = nil
    end

    self.item_list = nil

    self.gameObject = nil
    self:AssetClearAll()
end

function EquipStrengthTransSecondTab:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_trans_right_con))
    self.gameObject.name = "EquipStrengthTransSecondTab"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(154, -9, 0)


    self.TopCon = self.transform:FindChild("TopCon")
    self.LeftCon = self.TopCon:FindChild("LeftCon")
    self.BtnLook = self.LeftCon:FindChild("ImgTitle"):FindChild("ButtonLook"):GetComponent(Button)
    self.ConUnSelected = self.LeftCon:FindChild("ConUnSelected")
    self.ConSelected = self.LeftCon:FindChild("ConSelected")
    self.left_selected_bg = self.LeftCon:FindChild("ImgSelectedBg").gameObject
    self.top_left_SlotCon = self.ConSelected:FindChild("SlotCon"):FindChild("SlotCon").gameObject
    self.top_left_effect = self.ConSelected:FindChild("SlotCon"):FindChild("20049").gameObject
    self.top_left_TxtName = self.ConSelected:FindChild("TxtName"):GetComponent(Text)
    self.top_left_TxtLev = self.ConSelected:FindChild("TxtLev"):GetComponent(Text)
    self.top_left_TxtVal_1 = self.ConSelected:FindChild("TxtVal_1"):GetComponent(Text)
    self.top_left_TxtVal_2 = self.ConSelected:FindChild("TxtVal_2"):GetComponent(Text)
    self.top_left_TxtVal_3 = self.ConSelected:FindChild("TxtVal_3"):GetComponent(Text)
    self.top_left_TxtVal_4 = self.ConSelected:FindChild("TxtVal_4"):GetComponent(Text)
    self.top_left_TxtVal_5 = self.ConSelected:FindChild("TxtVal_5"):GetComponent(Text)

    self.top_left_txtVal_list = {}
    for i=1,5 do
        local txtVal = self.ConSelected:FindChild(string.format("TxtVal_%s", i)):GetComponent(Text)
        table.insert(self.top_left_txtVal_list, txtVal)
    end

    self.top_left_txtstrength_list = {}
    for i=1,5 do
        local txtVal = self.ConSelected:FindChild(string.format("TxtStrength_%s", i)):GetComponent(Text)
        table.insert(self.top_left_txtstrength_list, txtVal)
    end

    self.RightCon = self.TopCon:FindChild("RightCon")
    self.ImgTitle = self.RightCon:FindChild("ImgTitle")
    self.ImgTitle_txt = self.ImgTitle:FindChild("Txt"):GetComponent(Text)
    self.ImgTitle_txt.text = TI18N("附加特效")
    self.ImgSelected = self.RightCon:FindChild("ImgSelectedBg").gameObject
    self.right_mid_txt = self.RightCon:FindChild("TxtMid"):GetComponent(Text)
    self.right_bottom_txt = self.RightCon:FindChild("TxtBottom"):GetComponent(Text)
    self.right_btn_save = self.RightCon:FindChild("BtnSave"):GetComponent(Button)
    -- self.right_bottom_txt.text = TI18N("<color='#ffff00'>洗练特效</color>可重置装备特效（不会删除特效）")
    self.right_mid_txt.text = ""
    self.ItemMaskCon = self.RightCon:FindChild("ItemMaskCon")
    self.ScrollLayer = self.ItemMaskCon:FindChild("ScrollLayer")
    self.ItemCon = self.ScrollLayer:FindChild("ItemCon")
    self.Clone = self.ItemCon:FindChild("Clone").gameObject
    self.Clone.transform:Find("TxtDesc"):GetComponent(Text).text = TI18N("无装备特效")

    self.top_left_effect:SetActive(false)
    Utils.ChangeLayersRecursively(self.top_left_effect.transform, "UI")

    self.BottomCon = self.transform:FindChild("BottomCon")
    self.bottom_LeftCon = self.BottomCon:FindChild("LeftCon")
    self.bottom_left_Slot1 = self.bottom_LeftCon:FindChild("Slot1")
    self.bottom_left_Slot2 = self.bottom_LeftCon:FindChild("Slot2")
    self.bottom_left_Slot3 = self.bottom_LeftCon:FindChild("Slot3")
    self.bottom_left_up = self.bottom_LeftCon:FindChild("Up")
    self.bottom_left_up_btn = self.bottom_left_up:GetComponent(Button)
    self.bottom_left_up_btn.onClick:AddListener(function() self:WashEffect() end)
    self.bottom_left_up_tick = self.bottom_left_up.transform:FindChild("Bg/Tick").gameObject
    self.bottom_left_up_effectTxt = self.bottom_left_up:FindChild("EffectTxt"):GetComponent(Text)

    self.bottom_left_SlotCon1 = self.bottom_left_Slot1:FindChild("SlotCon").gameObject
    self.bottom_left_SlotCon2 = self.bottom_left_Slot2:FindChild("SlotCon").gameObject
    self.bottom_left_SlotCon3 = self.bottom_left_Slot3:FindChild("SlotCon").gameObject

    self.bottom_left_TxtName1 = self.bottom_left_Slot1:FindChild("TxtName"):GetComponent(Text)
    self.bottom_left_TxtName2 = self.bottom_left_Slot2:FindChild("TxtName"):GetComponent(Text)
    self.bottom_left_TxtName3 = self.bottom_left_Slot3:FindChild("TxtName"):GetComponent(Text)

    self.bottom_left_icon1 = self.bottom_left_Slot1:FindChild("ImgIcon"):GetComponent(Image)
    self.bottom_left_icon2 = self.bottom_left_Slot2:FindChild("ImgIcon"):GetComponent(Image)
    self.bottom_left_icon3 = self.bottom_left_Slot3:FindChild("ImgIcon"):GetComponent(Image)

    self.bottom_left_TxtVal1 = self.bottom_left_Slot1:FindChild("TxtVal"):GetComponent(Text)
    self.bottom_left_TxtVal2 = self.bottom_left_Slot2:FindChild("TxtVal"):GetComponent(Text)
    self.bottom_left_TxtVal3 = self.bottom_left_Slot3:FindChild("TxtVal"):GetComponent(Text)

    self.bottom_left_TxtVal1.text = ""
    self.bottom_left_TxtVal2.text = ""
    self.bottom_left_TxtVal3.text = ""
    self.bottom_left_icon1.gameObject:SetActive(false)
    self.bottom_left_icon2.gameObject:SetActive(false)
    self.bottom_left_icon3.gameObject:SetActive(false)

    self.left_selected_bg:SetActive(false)

    self.BuildCon = self.BottomCon:FindChild("BuildCon")
    self.LookCon = self.BuildCon:FindChild("LookCon")
    self.BottomLookBtn = self.LookCon:FindChild("ButtonLook"):GetComponent(Button)
    self.BuildCon_BtnBuild = self.BuildCon:FindChild("BtnBuild").gameObject
    self.BuildCon_BtnBuild:SetActive(true)
    self.trans_btn = BuyButton.New(self.BuildCon_BtnBuild, TI18N("洗炼"))
    self.trans_btn.key = "EquipStrengthWash"
    self.trans_btn.protoId = 10614
    self.trans_btn:Show()

    --为所有的slot_con创建slot
    self.top_left_slot = self:create_equip_slot(self.top_left_SlotCon)
    self.bottom_slot_1 = self:create_equip_slot(self.bottom_left_SlotCon1)
    self.bottom_slot_2 = self:create_equip_slot(self.bottom_left_SlotCon2)
    self.bottom_slot_3 = self:create_equip_slot(self.bottom_left_SlotCon3)

    --为所有按钮添加监听器逻辑
    self.on_click_build = function()
        self:on_click_build_btn()
    end
    self.on_bottom_prices_back = function(prices)
        self:update_price_back(prices)
    end

    self.on_buybtn_click = function()
        self:on_transform_click()
    end

    self.BtnLook.gameObject:SetActive(true)
    self.BtnLook.onClick:AddListener(function()
        self.top_left_slot.itemData.show_extra = true
        self.top_left_slot:ClickSelf()
    end)

    self.LookCon.gameObject:SetActive(true)
    self.BottomLookBtn.onClick:AddListener(function()
        self.top_left_slot.itemData.show_extra = true
        self.top_left_slot:ClickSelf()
    end)

    self.BuildCon_BtnBuild:GetComponent(RectTransform).anchoredPosition = Vector2(0, -23.2)

    self.right_btn_save.onClick:AddListener(function()
        EquipStrengthManager.Instance:request10616(self.cur_selected_data.id)
    end)

    self.ConUnSelected.gameObject:SetActive(true)
    self.ConSelected.gameObject:SetActive(false)

    self.has_init = true

    self:update_right_equip(self.parent.cur_select_equip_data)
    self:update_right_extra_prop(self.parent.cur_select_equip_data)

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateListener)
    EventMgr.Instance:AddListener(event_name.equip_item_change, self.on_equip_update)
    EventMgr.Instance:AddListener(event_name.equip_build_resetval_save_ok, self.on_update_save)
    EventMgr.Instance:AddListener(event_name.equip_strength_trans_attr_back, self.trans_reset_back)
    EquipStrengthManager.Instance.onAppointEffect:AddListener(function() self:update_right_equip(self.parent.cur_select_equip_data)  end)

end

--更新单个装备
function EquipStrengthTransSecondTab:update_cur_selected_equip()
    if self.has_init == true then
        local new_data = BackpackManager.Instance.equipDic[self.cur_selected_data.id]
        if new_data ~= nil then
            self.cur_selected_data = new_data
            self:update_right_equip(self.cur_selected_data)
            self:update_right_extra_prop(self.cur_selected_data)
        end
    end
end


----------------------------------更新逻辑
--更新右边装备
function EquipStrengthTransSecondTab:update_right_equip(data)
    if self.has_init == false then
        return
    end

    self.ImgSelected:SetActive(false)
    self.Clone:SetActive(false)

    self.ConUnSelected.gameObject:SetActive(false)
    self.ConSelected.gameObject:SetActive(true)

    self.cur_selected_data = data

    local temp_lev = EquipStrengthManager.Instance.model:check_equip_is_last_lev(data)

    local base_data = DataItem.data_get[self.cur_selected_data.base_id]
    if self.top_left_slot ~= nil then
        local copy_equip_data = BaseUtils.copytab(BackpackManager.Instance.equipDic[self.cur_selected_data.id])
        copy_equip_data.lev = temp_lev

        self.top_left_slot:ShowEnchant(true)
        self.top_left_slot:SetAll(BackpackManager.Instance.equipDic[self.cur_selected_data.id], {nobutton = true})
    end
    if base_data == nil then
        return
    end

    self.top_left_TxtName.text = ColorHelper.color_item_name(base_data.quality, base_data.name)
    self.top_left_TxtLev.text = string.format("%s%s%s", temp_lev , TI18N("级"), BackpackEumn.ItemTypeName[self.cur_selected_data.type])

    for i=1,#self.top_left_txtVal_list do
        self.top_left_txtVal_list[i].text = ""
    end

    for i=1,#self.top_left_txtstrength_list do
        self.top_left_txtstrength_list[i].text = ""
    end

    self.left_base_attr = {}
    self.strength_base_attr = {}
    local extr_attr = {}
    local wing_attr = {}
    local effect_attr = {}
    for i=1,#self.cur_selected_data.attr  do
        local attr_v = self.cur_selected_data.attr[i]
        if attr_v.type == GlobalEumn.ItemAttrType.base then
            table.insert(self.left_base_attr, attr_v)
        elseif attr_v.type == GlobalEumn.ItemAttrType.enchant then
            self.strength_base_attr[attr_v.name] = attr_v
        elseif attr_v.type == GlobalEumn.ItemAttrType.extra then
            table.insert(extr_attr, attr_v)
        elseif attr_v.type == GlobalEumn.ItemAttrType.effect then
            table.insert(effect_attr, attr_v)
        elseif attr_v.type == GlobalEumn.ItemAttrType.wing_skill then
            table.insert(wing_attr, attr_v)
        end
    end

    table.sort(self.left_base_attr, function(a,b) return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name] end)
    table.sort(effect_attr, function(a,b) return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name] end)

    --基础属性
    local extr_index = 1
    for i=1,#self.left_base_attr do
        local attr_v = self.left_base_attr[i]
        local color =  "#3166ad"
        local strength_str = ""
        if self.strength_base_attr[attr_v.name] ~= nil then
            strength_str = string.format("(+%s)", self.strength_base_attr[attr_v.name].val)
        end
        local val = attr_v.val > 0 and string.format("+%s", attr_v.val) or tostring(attr_v.val)
        self.top_left_txtVal_list[i].text = string.format("<color='%s'>%s</color><color='#ACE92A'>%s</color><color='#b031d5'>%s</color>", color,  KvData.attr_name[attr_v.name], val , strength_str)
        extr_index = i+1
    end

    --额外属性
    local extr_val = ""
    for i=1,#extr_attr do
        local attr_v = extr_attr[i]
        local color =  "#23F0F7"
        local val = attr_v.val > 0 and string.format("+%s", attr_v.val) or tostring(attr_v.val)
        extr_val = string.format("%s<color='%s'>%s%s </color>", extr_val ,color,  KvData.attr_name[attr_v.name], val)
    end

    if extr_val ~= "" then
        self.top_left_txtVal_list[extr_index].text = extr_val
        extr_index = extr_index + 1
    end

    --特效属性
    for i,v in ipairs(effect_attr) do
        local str = ""
        if v.name == 100 then
            -- 技能
            local skillData = DataSkill.data_skill_effect[v.val]
            if skillData == nil then
                skillData = DataSkill.data_skill_role[string.format("%s_%s", v.val, RoleManager.Instance.RoleData.lev)]
                str = string.format("真·%s", skillData.name)
            else
                str = skillData.name
            end
        else
            str = KvData.attr_name[v.name]
        end
        self.top_left_txtVal_list[extr_index].text = string.format(TI18N("<color='#dc83f5'>特效 %s</color>"), str)
        extr_index = extr_index + 1
    end

    --翅膀特技属性
    for i,v in ipairs(wing_attr) do
        local str = ""
        if v.name == 100 then
            -- 技能
            local skillData = DataSkill.data_wing_skill[string.format("%s_1", v.val)]
            str = skillData.name
        else
            str = KvData.attr_name[v.name]
        end
        self.top_left_txtVal_list[extr_index].text = string.format(TI18N("<color='#dc83f5'>特技 %s</color>"), str)
        extr_index = extr_index + 1
    end

    if self.cur_selected_data.lev >= 80 and #effect_attr > 0 then 
        self.bottom_left_up.gameObject:SetActive(true)
    else
        self.bottom_left_up.gameObject:SetActive(false)
    end

    self.appointEffect = self.model.selected_effect_flag
    self:DoWashEffect()

end

--更新右边装备extra_prop
function EquipStrengthTransSecondTab:update_right_extra_prop(data)
    if self.has_init == false then
        return
    end
    self.ImgSelected:SetActive(false)
    self.Clone:SetActive(false)
    self.right_mid_txt.text = ""

    self.ConUnSelected.gameObject:SetActive(false)
    self.ConSelected.gameObject:SetActive(true)

    if self.item_list == nil then
        self.item_list = {}
    else
        for i=1,#self.item_list do
            local item = self.item_list[i]
            if item ~= nil then
                item.gameObject:SetActive(false)
            end
        end
    end

    EquipStrengthManager.Instance:request10615(self.cur_selected_data.id)
    -- self:update_save_state(self.cur_selected_data)
end

--更新洗练保存状态
function EquipStrengthTransSecondTab:update_save_state(data)
    if self.has_init == false then
        return
    end

    if self.cur_selected_data.id ~= data.id then
        return
    end

    local temp_data = nil
    if #data.attr ~= 0 then
        temp_data = data
        --出现保存按钮
        self.right_bottom_txt.gameObject:SetActive(false)
        self.right_btn_save.gameObject:SetActive(true)
    else
        --隐藏保存按钮
        temp_data = self.cur_selected_data
        self.right_bottom_txt.gameObject:SetActive(true)
        self.right_btn_save.gameObject:SetActive(false)
    end

    table.sort(temp_data.attr, function(a,b)
        return a.flag%10 < b.flag%10
    end)

    local index = 1
    for i=1,#temp_data.attr do
        local ad = temp_data.attr[i]
        if ad.type == GlobalEumn.ItemAttrType.effect then
            local item = self.item_list[index]
            if item == nil then
                item = self:CreateItem(self.Clone, index)
                table.insert(self.item_list, item)
            end
            item.gameObject:SetActive(true)
            self:SetItemData(item, ad)
            index = index + 1
        end
    end

    if index > 1 then
        self.Clone:SetActive(false)
        if self.last_selected_prop_item ~= nil and index >= self.last_selected_prop_item.index then
            self:on_selected_prop_item(self.last_selected_prop_item)
        else
            self:on_selected_prop_item(self.item_list[1])
        end
    else
        self.Clone:SetActive(true)
        self:on_selected_prop_item(nil)
    end

    local newH = 50*index
    local rect = self.ItemCon.transform:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(0, newH)
end


--更新转换消耗价格
function EquipStrengthTransSecondTab:update_price_back(prices)
    if self.cur_selected_data == nil then
        return
    end

    self.bottom_left_TxtVal1.text = ""
    self.bottom_left_TxtVal2.text = ""
    self.bottom_left_TxtVal3.text = ""
    self.bottom_left_icon1.gameObject:SetActive(false)
    self.bottom_left_icon2.gameObject:SetActive(false)
    self.bottom_left_icon3.gameObject:SetActive(false)

    -- local cfg_data = DataBacksmith.data_equip_effect_trans[self.cur_selected_data.lev]

    -- for i=1,#cfg_data.loss do
    --     local loss_data = cfg_data.loss[i]
    --     if i == 1 then
    --         -- self.bottom_left_icon1.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures,GlobalEumn.CostTypeIconName[p.assets])
    --         -- self.bottom_left_TxtVal1.text = tostring(price_str)
    --         -- self.bottom_left_icon1.gameObject:SetActive(true)
    --     elseif i == 2 then
    --         -- self.bottom_left_icon2.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures,GlobalEumn.CostTypeIconName[p.assets])
    --         -- self.bottom_left_TxtVal2.text = tostring(price_str)
    --         -- self.bottom_left_icon2.gameObject:SetActive(true)
    --     elseif i == 3 then
    --         -- self.bottom_left_icon3.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures,GlobalEumn.CostTypeIconName[p.assets])
    --         -- self.bottom_left_TxtVal3.text = tostring(price_str)
    --         -- self.bottom_left_icon3.gameObject:SetActive(true)
    --     end
    -- end
end



---------------------------------------------监听器
--选中某个装备进行转换监听
function EquipStrengthTransSecondTab:on_transform_click()
    if self.last_selected_prop_item ~= nil then
        if self.last_selected_prop_item.data.type == GlobalEumn.ItemAttrType.effect then
            if self.appointEffect then 
                EquipStrengthManager.Instance:request10629(self.cur_selected_data.id, self.model.selected_effect.effect_type, self.model.selected_effect.val)
            else
                EquipStrengthManager.Instance:request10614(self.cur_selected_data.id)
            end
        else
            EquipStrengthManager.Instance:request10611(self.cur_selected_data.id, self.last_selected_prop_item.data.flag%10)
        end
    elseif self.cur_selected_data ~= nil then
        self.trans_btn:ReleaseFrozon()

        local len = 0
        for i=1,#self.cur_selected_data.attr do
            local ad = self.cur_selected_data.attr[i]
            if ad.name == 101 or ad.name == 102 or ad.name == 103 or ad.name == 104 or ad.name == 105 then
                len = len + 1
            end
        end
        if len == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("只有带特效的装备才能洗炼哦~"))
        else
            self.ImgSelected:SetActive(true)
            NoticeManager.Instance:FloatTipsByString(TI18N("只有带特效的装备才能洗炼哦~"))
        end
    else
        self.trans_btn:ReleaseFrozon()
        self.ImgSelected:SetActive(true)
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择需要转换属性的装备"))
    end
end

--选中某个装备属性item
function EquipStrengthTransSecondTab:on_selected_prop_item(item)
    self.ImgSelected:SetActive(false)
    if self.last_selected_prop_item ~= nil then
        self.last_selected_prop_item.selected_img:SetActive(false)
    end
    self.bottom_left_Slot1.gameObject:SetActive(false)
    self.bottom_left_Slot2.gameObject:SetActive(false)
    self.bottom_left_Slot3.gameObject:SetActive(false)


    self:update_cost()

    self.last_selected_prop_item = item
    if self.last_selected_prop_item ~= nil then
        self.last_selected_prop_item.selected_img:SetActive(true)
    end


    if EquipStrengthManager.Instance.model:check_equip_is_last_lev_state(self.cur_selected_data) then
            self.buy_list = {}
        end
    self.trans_btn:Layout(self.buy_list, self.on_buybtn_click , self.on_bottom_prices_back)

end

--更新底部显示
function EquipStrengthTransSecondTab:update_cost()

    local cfg_data = DataBacksmith.data_equip_effect_trans[self.cur_selected_data.lev]

    self.bottom_left_Slot1.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-77.9, 0)
    self.bottom_left_Slot2.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
    self.bottom_left_Slot3.transform:GetComponent(RectTransform).anchoredPosition = Vector2(79, 0)

    self.buy_list = {}
    for i=1,#cfg_data.loss do
        local loss_data = cfg_data.loss[i]
        local base_data = DataItem.data_get[loss_data[1]]
        local has_num = BackpackManager.Instance:GetItemCount(loss_data[1])
        local need_num = loss_data[2]
        self.buy_list[loss_data[1]] = {need = need_num}
        if i == 1 then
            self.bottom_left_Slot1.gameObject:SetActive(true)
            self:set_equip_slot_data(self.bottom_slot_1,  DataItem.data_get[loss_data[1]], true)
            self.bottom_slot_1:SetNum(has_num,need_num)
            self.bottom_left_TxtName1.text = base_data.name
        elseif i == 2 then
            self.bottom_left_Slot2.gameObject:SetActive(true)
            self:set_equip_slot_data(self.bottom_slot_2,  DataItem.data_get[loss_data[1]], true)
            self.bottom_slot_2:SetNum(has_num,need_num)
            self.bottom_left_TxtName2.text = base_data.name
        elseif i == 3 then
            self.bottom_left_Slot3.gameObject:SetActive(true)
            self:set_equip_slot_data(self.bottom_slot_3,  DataItem.data_get[loss_data[1]], true)
            self.bottom_slot_3:SetNum(has_num,need_num)
            self.bottom_left_TxtName3.text = base_data.name
        end
    end
    self.buy_list = {}
    self.trans_btn:Set_btn_txt(TI18N("洗炼"))
    self.bottom_left_Slot1.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-77.9, -20)
    self.bottom_left_Slot2.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, -20)
    self.bottom_left_Slot3.transform:GetComponent(RectTransform).anchoredPosition = Vector2(79, -20)
end

--------------------------------------------------右上侧额外属性操作列表
--创建item
function EquipStrengthTransSecondTab:CreateItem(clone, index)
    local item = {}
    item.gameObject = GameObject.Instantiate(clone)
    item.transform = item.gameObject.transform
    item.transform:SetParent(clone.transform.parent)
    item.transform.localScale = Vector3.one

    item.selected_img = item.transform:FindChild("Imgselected").gameObject

    item.txt = item.transform:FindChild("TxtDesc"):GetComponent(Text)
    item.txt.text = ""
    item.index = index

    local newY = (index - 1)*-50
    local rect = item.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(6, newY)

    item.transform:GetComponent(Button).onClick:AddListener(function()
        self:on_selected_prop_item(item)
    end)

    item.selected_img:SetActive(false)
    item.gameObject:SetActive(true)
    return item
end

--为item设置数据
function EquipStrengthTransSecondTab:SetItemData(item, data)
    item.data = data

    local color = ""
    if data.type == GlobalEumn.ItemAttrType.effect then
        local str = ""
        local desc = ""
        local skillData = nil


        if data.name == 100 then
            -- 技能
            if data.val < 80000 then
                skillData =  DataSkillTalent.data_skill_talent[data.val]

                str = skillData.talent3_name
                desc = skillData.talent3_desc3
            elseif data.val >= 80000 then
                skillData = DataSkill.data_skill_effect[data.val]
                str = skillData.name
                desc = skillData.desc
            end
        elseif data.name == 150 then
            -- 易强化
            skillData = DataSkill.data_skill_effect[81019]
            str = skillData.name
            desc = skillData.desc
        elseif data.name == 151 then
            -- 易成长
            skillData = DataSkill.data_skill_effect[81020]
            str = skillData.name
            desc = skillData.desc
        end

        item.txt.text = str
        self.right_mid_txt.text = string.format("<color='#dc83f5'>%s</color>:%s",str, desc)
    end
end


---------------------------------------------辅助函数
--为每个武器创建slot
function EquipStrengthTransSecondTab:create_equip_slot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con.transform)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
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
function EquipStrengthTransSecondTab:set_equip_slot_data(slot, data, _nobutton)
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

function EquipStrengthTransSecondTab:WashEffect()
    --1. 状态未选择
    --打开可选择特效列表
    --2. 已选择
    --取消选择  a.勾选状态变为未选择 b.tick图隐藏 c.当前选择的特效取消  d.下方文字消失

    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.eqmtappointeffectwinrans, self.cur_selected_data)
end

function EquipStrengthTransSecondTab:DoWashEffect()
    if self.appointEffect then 
        -- local need_num = 0
        -- local cfg_data_origin = DataBacksmith.data_equip_effect_trans[self.cur_selected_data.lev]
        -- for i=1,#cfg_data_origin.loss do
        --     local loss_data_origin = cfg_data_origin.loss[i]
        --     need_num = loss_data_origin[2]
        -- end

        local key = BaseUtils.Key(self.cur_selected_data.lev, RoleManager.Instance.RoleData.classes)
        local cfg_data = DataBacksmith.data_get_target_skill_trans[key]
        if cfg_data == nil then 
            cfg_data = DataBacksmith.data_get_target_skill_trans[BaseUtils.Key(self.cur_selected_data.lev, 0)]
        end
        local tmpStr = "ext_loss" .. self.equiptype[self.cur_selected_data.type]
        local loss_data = cfg_data[tmpStr][1]
        local base_data = DataItem.data_get[loss_data[1]]
        local has_num = BackpackManager.Instance:GetItemCount(loss_data[1])
        local need_num = loss_data[2]
        self.bottom_left_Slot1.gameObject:SetActive(true)
        self:set_equip_slot_data(self.bottom_slot_1,  DataItem.data_get[loss_data[1]], true)
        self.bottom_slot_1:SetNum(has_num,need_num)
        self.bottom_left_TxtName1.text = base_data.name
        self.bottom_left_up_effectTxt.text = self.model.selected_effect.name
    else
        self:update_cost()
    end

    self.bottom_left_up_tick.gameObject:SetActive(self.appointEffect)
    self.bottom_left_up_effectTxt.gameObject:SetActive(self.appointEffect)
end