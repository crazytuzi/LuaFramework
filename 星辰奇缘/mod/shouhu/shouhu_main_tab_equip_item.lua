ShouhuMainTabEquipItem = ShouhuMainTabEquipItem or BaseClass()

function ShouhuMainTabEquipItem:__init(parent, _gameObject, _type)
    self.gameObject = _gameObject
    self.parent = parent
    self.equip_btn = self.gameObject:GetComponent(Button)
    if self.equip_btn ~= nil then
        self.equip_btn.onClick:AddListener(function() self:equip_click() end)
    end


    ---------------slot逻辑
    self.slot = ItemSlot.New()
    self.slot:SetNotips()
    self.cell = ItemData.New()

    self.slot.gameObject.transform:SetParent(self.gameObject.transform)
    self.slot.gameObject.transform.localScale = Vector3.one
    self.slot.gameObject.transform.localPosition = Vector3.zero
    self.slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = self.slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
end

function ShouhuMainTabEquipItem:__delete()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
end

function ShouhuMainTabEquipItem:Release()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
end

function ShouhuMainTabEquipItem:InitPanel(_data)

end

function ShouhuMainTabEquipItem:set_equip_my_sh_data(data)
    self.my_sh_data = data
end

function ShouhuMainTabEquipItem:equip_click()
    if self.my_sh_data ~= nil then
        if self.my_sh_data.look_type == nil then
            self.parent.parent.model.my_sh_selected_equip = self.myData
            self.parent.parent.model:OpenShouhuEquipUI()
        else
            self.parent.model.my_sh_selected_look_equip = self.myData
            self.parent.model:OpenShouhuLookEquipUI()
        end
    end
end

function ShouhuMainTabEquipItem:set_sh_equip_item_data(data)
    self.myData = data

    if self.myData ~= nil then
    local is_new = false
        if self.my_sh_data.look_type == nil then
            if self.my_sh_data.war_id ~= nil then
                is_new = ShouhuManager.Instance.model:check_equip_can_up_stone(self.my_sh_data, self.myData)
                self.equip_btn.enabled = true
            else --没招募
                is_new=false
                self.equip_btn.enabled = false
            end
        else
            self.equip_btn.enabled = true
        end

        self.cell:SetBase(DataItem.data_get[self.myData.base_id])
        self.slot:SetAll(self.cell, nil)
        self.slot:ShowState(is_new)
    else
        self.slot:SetAll(nil)
    end
end