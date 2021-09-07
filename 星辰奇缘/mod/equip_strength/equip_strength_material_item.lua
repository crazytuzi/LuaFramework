EquipStrengthMaterialItem = EquipStrengthMaterialItem or BaseClass()

function EquipStrengthMaterialItem:__init(parent, origin_item)
    self.parent = parent
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(origin_item.transform.parent.gameObject, self.gameObject)

    self.gameObject:SetActive(true)
    self.transform = self.gameObject.transform


    self.ImgTick = self.transform:FindChild("ImgTick").gameObject
    self.SlotCon = self.transform:FindChild("SlotCon").gameObject
    self.ImgTxtBg = self.transform:FindChild("ImgTxtBg")
    self.TxtNum = self.ImgTxtBg:FindChild("TxtNum"):GetComponent(Text)
    self.TxtName = self.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtLev = self.transform:FindChild("TxtLev"):GetComponent(Text)

    self.ImgTick:SetActive(false)

    self.slot = self:create_equip_slot(self.SlotCon)

    self.transform:GetComponent(Button).onClick:AddListener(function() self:on_selected_item() end)

    self.hasCount = 0
end

function EquipStrengthMaterialItem:Release()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
end

function EquipStrengthMaterialItem:InitPanel(_data)

end

--设置数据
function EquipStrengthMaterialItem:set_data(base_id, _type)
    self.base_id = base_id
    self.type = _type

    self.data = BaseUtils.copytab(DataItem.data_get[base_id])
    self.data.base_id = base_id
    self.TxtName.text = self.data.name
    if _type == 1 then
        self.TxtLev.text = string.format("%s+%s%s", TI18N("成功率"), DataBacksmith.data_enchant_luck[base_id].ratio/10, "%")
    else
        self.TxtLev.text = ""
    end
    self:set_stone_slot_data(self.slot , self.data)
    self.slot:SetNum(0,0)

    local left_num = BackpackManager.Instance:GetItemCount(base_id)
    self.hasCount = left_num

    if self.parent.model.select_luck_data_1 ~= nil and self.parent.model.select_luck_data_1.base_id == base_id then
        left_num = left_num - 1
    end

    if self.parent.model.select_luck_data_2 ~= nil and self.parent.model.select_luck_data_2.base_id == base_id then
        left_num = left_num - 1
    end

    if self.parent.model.select_luck_data_3 ~= nil and self.parent.model.select_luck_data_3.base_id == base_id then
        left_num = left_num - 1
    end
    self:update_slot_num(left_num)
end

--设置分子分母
function EquipStrengthMaterialItem:update_slot_num(fenzi)
    self.my_fen_zi = fenzi
    local fenmu = BackpackManager.Instance:GetItemCount(self.base_id)

    if fenmu > 0 then
        self.TxtNum.text = string.format("%s/%s", fenzi, fenmu)
    else
        self.TxtNum.text = string.format("<color='%s'>0</color>", ColorHelper.color[6])
    end
end

--选中item
function EquipStrengthMaterialItem:on_selected_item()
    if self.my_fen_zi > 0 then
        self.parent:update_left(self)
    end
end

--为每个武器创建slot
function EquipStrengthMaterialItem:create_equip_slot(slot_con)
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
function EquipStrengthMaterialItem:set_stone_slot_data(slot, data)
    local cell = ItemData.New()
    cell:SetBase(data)
    slot:SetAll(cell, nil)
end