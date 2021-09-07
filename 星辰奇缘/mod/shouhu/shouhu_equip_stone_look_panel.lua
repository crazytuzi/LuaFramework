--守护宝石查看界面
--20170302
--zzl

ShouhuStoneLookWindow  =  ShouhuStoneLookWindow or BaseClass(BasePanel)

function ShouhuStoneLookWindow:__init(model)
    self.name  =  "ShouhuStoneLookWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.shouhu_stone_look_win, type  =  AssetType.Main}
    }

    self.is_open = false
    return self
end

function ShouhuStoneLookWindow:__delete()
    self.slot_item_1.slot:DeleteMe()
    self.slot_item_2.slot:DeleteMe()
    self.slot_item_3.slot:DeleteMe()

    self.is_open = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function ShouhuStoneLookWindow:InitPanel()
    self.is_open = true

    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_stone_look_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ShouhuStoneLookWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon")

    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseStoneLookPanel() end)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseStoneLookPanel() end)

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
        for k,v in pairs(self.model.cur_stone_look_dic) do
            local temp_data = self.model:get_stone_cfg_data(v.type)
            if index == 1 then
                self.slot1.gameObject:SetActive(true)
                self:Set_slot_item(self.slot_item_1, temp_data)
            elseif index == 2 then
                self.slot2.gameObject:SetActive(true)
                self:Set_slot_item(self.slot_item_2, temp_data)
            elseif index == 3 then
                self.slot3.gameObject:SetActive(true)
                self:Set_slot_item(self.slot_item_3, temp_data)
            end
            index = index + 1
        end
    end

    self.TxtDescI18N:SetActive(true)
    self.MainCon:FindChild("TxtDescI18N"):GetComponent(Text).text = TI18N("1、升级装备可同时<color='#ffff00'>提升</color>宝石等级上限\n2、拆除宝石可重新镶嵌\n3、拆除守护装备宝石将<color='#ffff00'>不会退还</color>银币")
    self.MainCon:GetComponent(RectTransform).sizeDelta = Vector2(480, 270)
end


--创建slotitem
function ShouhuStoneLookWindow:Create_slot_item(trans)
    local item = {}
    item.SlotCon = trans:FindChild("SlotCon").gameObject
    item.slot = self:create_slot(item.SlotCon)
    item.TxtName = trans:FindChild("TxtName"):GetComponent(Text)
    item.TxtProp = trans:FindChild("TxtName"):GetComponent(Text)
    return item
end

--为每一个slotcon创建slot
function ShouhuStoneLookWindow:create_slot(slotCon)
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
function ShouhuStoneLookWindow:Set_slot_item(item, data)
    self:set_stone_slot_data(item.slot, data.base_id)
    local baseData = DataItem.data_get[data.base_id]
    local cfg_data = nil
    item.TxtName.text = baseData.name
    item.TxtProp.text = string.format("%s+%s", KvData.attr_name_show[data.attrs[1].attr], data.attrs[1].val)
    item.myData = data
end

--设置宝石道具各自数据
function ShouhuStoneLookWindow:set_stone_slot_data(slot, base_id)
    local cell = ItemData.New()
    local itemData = DataItem.data_get[base_id] --设置数据
    cell:SetBase(itemData)
    slot:SetAll(cell, nil)
end