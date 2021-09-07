FashionFaceRewardItem = FashionFaceRewardItem or BaseClass()

function FashionFaceRewardItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.data = nil

    self.parent = parent
    self.txtLev = self.transform:FindChild("TxtLev"):GetComponent(Text)
    self.txtName = self.transform:FindChild("TxtVal_1"):GetComponent(Text)
    self.slotCon = self.transform:FindChild("SlotCon").gameObject
    self.slot = self:CreateSlot(self.slotCon)
end

function FashionFaceRewardItem:Release()

end

--更新内容
function FashionFaceRewardItem:update_my_self(_data, _index)
    self.data = _data
    self.txtLev.text = tostring(self.data.lev)
    self.txtName.text = self.data.name
    local base_data = DataItem.data_get[self.data.gain[1][1]]
    self:SetSlotData(self.slot, base_data)
end

--创建slot
function FashionFaceRewardItem:CreateSlot(slot_con)
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
function FashionFaceRewardItem:SetSlotData(slot, data)
    if data == nil then
        slot:SetAll(nil, nil)
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    slot:SetAll(cell, nil)
end