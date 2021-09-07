SummerFruitToHelpWindow = SummerFruitToHelpWindow or BaseClass(BaseWindow)

function SummerFruitToHelpWindow:__init(model)
    self.model = model

    self.resList = {
        {file = AssetConfig.summer_to_help_window, type = AssetType.Main}
        ,{file  =  AssetConfig.summer_res, type  =  AssetType.Dep}
    }
    self.name = "ShippingWindow"

    self.update_item = function()
        self:LoadData()
    end
end

function SummerFruitToHelpWindow:__delete()
    -- body
    self.slot:DeleteMe()

end


function SummerFruitToHelpWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.summer_to_help_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    self.closebtn = self.transform:Find("Main/CloseButton")

    self.item_name = self.transform:Find("Main/ItemCon/FruitItem1/ItemName"):GetComponent(Text)
    self.SlotCon = self.transform:Find("Main/ItemCon/FruitItem1/SlotCon/Con")
    self.slot = self:create_equip_slot(self.SlotCon)

    self.nametext = self.transform:Find("Main/ItemCon/descText"):GetComponent(Text)
    self.helpbtn = self.transform:Find("Main/ItemCon/helpbtn")
    self.rewardnum = self.transform:Find("Main/ItemCon/rewcon/rewardText"):GetComponent(Text)

    self.helpbtn:GetComponent(Button).onClick:AddListener(function ()
        local fruit_cfg_data = DataCampFruit.data_fruit_base[self.map_id]
        SummerManager.Instance:request14024(self.model.to_help_data.r_id, self.model.to_help_data.r_platform, self.model.to_help_data.r_zone_id,  self.map_id, 1, fruit_cfg_data.item_id, fruit_cfg_data.num)
    end)

    self.closebtn:GetComponent(Button).onClick:AddListener(function ()
        self.model:CloseFruitToHelpUI()
    end)
    self:update_data()
end

function SummerFruitToHelpWindow:update_data()
    local cur_data = self.model.to_help_data.list[1]
    self.map_id = cur_data.id

    local fruit_cfg_data = DataCampFruit.data_fruit_base[self.map_id]

    local base_data = DataItem.data_get[fruit_cfg_data.item_id]

    self.item_name.text = string.format( "<color='#00ff22'>%s</color>", base_data.name)

    self:set_slot_data(self.slot, base_data)
    local has_num = BackpackManager.Instance:GetNotExpireItemCount(fruit_cfg_data.item_id)
    self.slot:SetNum(has_num, fruit_cfg_data.num)

    self.nametext.text = string.format("<color='#00ff22'>%s</color>%s", self.model.to_help_data.name, TI18N("需要你的帮助："))

    local lev_key = string.format("%s_%s", fruit_cfg_data.plant_exp_mode, RoleManager.Instance.RoleData.lev)
    local lev_cfg_data = DataLevup.data_levupmode[lev_key]
    local exp_val = lev_cfg_data.exp*fruit_cfg_data.help_exp_radio/1000

    self.rewardnum.text = string.format("%s", math.ceil(exp_val))
end




--创建slot
function SummerFruitToHelpWindow:create_equip_slot(slot_con)
    local _slot = ItemSlot.New()
    _slot.gameObject.transform:SetParent(slot_con)
    _slot.gameObject.transform.localScale = Vector3.one
    _slot.gameObject.transform.localPosition = Vector3.zero
    _slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = _slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return _slot
end

--对slot设置数据
function SummerFruitToHelpWindow:set_slot_data(slot, data, _nobutton)
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