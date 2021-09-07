EquipStrengthStoneLookWindow  =  EquipStrengthStoneLookWindow or BaseClass(BaseWindow)

function EquipStrengthStoneLookWindow:__init(model)
    self.name  =  "EquipStrengthStoneLookWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.equip_strength_stone_look_win, type  =  AssetType.Main}
    }

    self.is_open = false
    self.kongType = 0
    return self
end

function EquipStrengthStoneLookWindow:__delete()
    if self.slot_item_1 ~= nil then
        if self.slot_item_1.slot ~= nil then
            self.slot_item_1.slot:DeleteMe()
            self.slot_item_1.slot = nil
        end
        self.slot_item_1 = nil
    end

    if self.slot_item_2 ~= nil then
        if self.slot_item_2.slot ~= nil then
            self.slot_item_2.slot:DeleteMe()
            self.slot_item_2.slot = nil
        end
        self.slot_item_2 = nil
    end

    if self.slot_item_3 ~= nil then
        if self.slot_item_3.slot ~= nil then
            self.slot_item_3.slot:DeleteMe()
            self.slot_item_3.slot = nil
        end
        self.slot_item_3 = nil
    end

    self.is_open = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function EquipStrengthStoneLookWindow:InitPanel()
    self.is_open = true

    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_stone_look_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "EquipStrengthStoneLookWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon")

    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseEquipStoneLookUI() end)

    self.slot1 = self.MainCon:FindChild("Stone1")
    self.slot2 = self.MainCon:FindChild("Stone2")
    self.slot3 = self.MainCon:FindChild("Stone3")
    self.TxtDescI18N = self.MainCon:FindChild("TxtDescI18N").gameObject

    self.slot1.gameObject:SetActive(false)
    self.slot2.gameObject:SetActive(false)
    self.slot3.gameObject:SetActive(false)

    self.slot_item_1 = self:Create_slot_item(self.slot1)
    self.slot_item_2 = self:Create_slot_item(self.slot2)
    self.slot_item_3 = self:Create_slot_item(self.slot3)

    if self.model.cur_stone_look_dic ~= nil then
        local index = 1
        if self.kongType == 1 then
             for k,v in pairs(self.model.cur_stone_look_dic) do
                if index == 1 then
                    self.slot1.gameObject:SetActive(true)
                    self:Set_slot_item(self.slot_item_1, v[1])
                elseif index == 2 then
                    self.slot2.gameObject:SetActive(true)
                    self:Set_slot_item(self.slot_item_2, v[1])
                elseif index == 3 then
                    self.slot3.gameObject:SetActive(true)
                    self:Set_slot_item(self.slot_item_3, v[1])
                end
                index = index + 1
            end
        elseif self.kongType == 2 then
            for k,v in pairs(self.model.cur_stone_look_dic) do
                if index == 1 then
                    self.slot1.gameObject:SetActive(true)
                    self:Set_slot_item(self.slot_item_1, k)
                elseif index == 2 then
                    self.slot2.gameObject:SetActive(true)
                    self:Set_slot_item(self.slot_item_2, k)
                elseif index == 3 then
                    self.slot3.gameObject:SetActive(true)
                    self:Set_slot_item(self.slot_item_3, k)
                end
                index = index + 1
            end
        end
    end
    if self.kongType == 1 then
        self.TxtDescI18N:SetActive(true)
        self.MainCon:FindChild("TxtDescI18N"):GetComponent(Text).text = TI18N("1、英雄宝石可通过<color='#ffff00'>无尽试炼</color>获得\n2、拆除宝石时会损失<color='#ffff00'>一定比例</color>的英雄宝石\n3、6级及以上的英雄宝石在装备进阶时会损失<color='#ffff00'>一部分</color>经验")
        self.MainCon:GetComponent(RectTransform).sizeDelta = Vector2(480, 270)
    elseif self.kongType == 2 then
        self.TxtDescI18N:SetActive(false)
        self.MainCon:GetComponent(RectTransform).sizeDelta = Vector2(480, 217)
    end
end


--创建slotitem
function EquipStrengthStoneLookWindow:Create_slot_item(trans)
    local item = {}
    item.SlotCon = trans:FindChild("SlotCon").gameObject
    item.slot = self:create_slot(item.SlotCon)
    item.TxtName = trans:FindChild("TxtName"):GetComponent(Text)
    item.TxtProp = trans:FindChild("TxtName"):GetComponent(Text)
    return item
end

--为每一个slotcon创建slot
function EquipStrengthStoneLookWindow:create_slot(slotCon)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slotCon.transform)
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

--设置slotItem数据
function EquipStrengthStoneLookWindow:Set_slot_item(item, base_id)
    self:set_stone_slot_data(item.slot, base_id)
    local data = DataItem.data_get[base_id]
    local cfg_data = nil
    if self.kongType == 1 then
        cfg_data = DataBacksmith.data_hero_stone_base[base_id]
    elseif self.kongType == 2 then
        cfg_data = DataBacksmith.data_gem_base[base_id]
    end
    item.TxtName.text = data.name
    item.TxtProp.text = KvData.GetAttrStringNoColor(cfg_data.attr[1].attr_name, cfg_data.attr[1].val1)
    item.myData = data
end

--设置宝石道具各自数据
function EquipStrengthStoneLookWindow:set_stone_slot_data(slot, base_id)
    local cell = ItemData.New()
    local itemData = DataItem.data_get[base_id] --设置数据
    cell:SetBase(itemData)
    slot:SetAll(cell, nil)
end