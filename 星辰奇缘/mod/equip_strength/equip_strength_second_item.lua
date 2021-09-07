EquipStrengthSecondItem = EquipStrengthSecondItem or BaseClass()

function EquipStrengthSecondItem:__init(parent, origin_item)
    self.parent = parent
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(origin_item.transform.parent.gameObject, self.gameObject)

    self.gameObject:SetActive(true)
    self.transform = self.gameObject.transform

    self.Txt_Name = self.transform:FindChild("Txt_Name"):GetComponent(Text)
    self.TxtState = self.transform:FindChild("TxtState"):GetComponent(Text)

    self.ImgStoneGo1 = self.transform:FindChild("ImgStone1")
    self.ImgStoneGo2 = self.transform:FindChild("ImgStone2")
    self.ImgStoneGo3 = self.transform:FindChild("ImgStone3")

    self.imgLoaders = {}

    self.ImgStone1 = self.ImgStoneGo1:GetComponent(Image)
    self.ImgStone2 = self.ImgStoneGo2:GetComponent(Image)
    self.ImgStone3 = self.ImgStoneGo3:GetComponent(Image)

    self.ImgSelected = self.transform:FindChild("ImgSelected").gameObject
    self.EquipIconCon = self.transform:FindChild("EquipIconCon").gameObject
    self.ImgPoint = self.transform:FindChild("ImgPoint").gameObject

    self.ImgPoint:SetActive(false)
    self.TxtState.text = ""

    self.ImgStone1.gameObject:SetActive(false)
    self.ImgStone2.gameObject:SetActive(false)
    self.ImgStone3.gameObject:SetActive(false)

    self.ImgSelected:SetActive(false)

    self.transform:GetComponent(Button).onClick:AddListener(function() self.parent:update_right_for_item(self) end)
end

function EquipStrengthSecondItem:Release()
    self.ImgStone1.sprite = nil
    self.ImgStone2.sprite = nil
    self.ImgStone3.sprite = nil

    for _,imglader in pairs(self.imgLoaders) do
         if imglader ~= nil then
            imglader:DeleteMe()
            imglader = nil
        end
    end
    if self.stone_slot ~= nil then
        self.stone_slot:DeleteMe()
        self.stone_slot = nil
    end
end

function EquipStrengthSecondItem:InitPanel(_data)

end

function EquipStrengthSecondItem:SetData(data)
    self.data = data
    self.gameObject:SetActive(true)

    if self.stone_slot == nil then
        self.stone_slot = ItemSlot.New()
        self.stone_slot.gameObject.transform:SetParent(self.EquipIconCon.transform)
        self.stone_slot.gameObject.transform.localScale = Vector3.one
        self.stone_slot.gameObject.transform.localPosition = Vector3.zero
        self.stone_slot.gameObject.transform.localRotation = Quaternion.identity
        local rect = self.stone_slot.gameObject:GetComponent(RectTransform)
        rect.anchorMax = Vector2(1, 1)
        rect.anchorMin = Vector2(0, 0)
        rect.localPosition = Vector3(0, 0, 1)
        rect.offsetMin = Vector2(0, 0)
        rect.offsetMax = Vector2(0, 2)
        rect.localScale = Vector3.one
    end

    local cell = ItemData.New()
    local itemData = DataItem.data_get[data.base_id] --设置数据
    itemData.enchant = data.enchant
    cell:SetBase(itemData)
    self.stone_slot:SetAll(cell, nil)
    self.stone_slot:SetLevel(itemData.lev)
    self.stone_slot:ShowLevel(true)
    self.stone_slot:ShowEnchant(true)
    self.stone_slot:SetAll(BackpackManager.Instance.equipDic[data.id])

    -- self.stone_slot:SetNotips(true)

    self.Txt_Name.text = string.format("<color='%s'>%s</color>", ColorHelper.color[itemData.quality], itemData.name)
    self.TxtState.transform:GetComponent(RectTransform).anchoredPosition = Vector2(14.29, -15)

    local stone_num = 0
    self.ImgStone1.gameObject:SetActive(false)
    self.ImgStone2.gameObject:SetActive(false)
    self.ImgStone3.gameObject:SetActive(false)
    for i=1,#data.attr do
        local ed = data.attr[i]
        if ed.type == GlobalEumn.ItemAttrType.gem then
            --宝石属性
            -- ed.name --孔位 ,
            -- ed.val --宝石base_id，
            local base_data = DataItem.data_get[ed.val]
            stone_num = stone_num + 1
            if stone_num == 1 then
                self.ImgStone1.gameObject:SetActive(true)
                if self.imgLoaders[stone_num] == nil then
                    self.imgLoaders[stone_num] = SingleIconLoader.New(self.ImgStoneGo1.gameObject)
                end
                self.imgLoaders[stone_num]:SetSprite(SingleIconType.Item, base_data.icon)
                self.TxtState.transform:GetComponent(RectTransform).anchoredPosition = Vector2(46, -15)
            elseif stone_num == 2 then
                self.ImgStone2.gameObject:SetActive(true)
                if self.imgLoaders[stone_num] == nil then
                    self.imgLoaders[stone_num] = SingleIconLoader.New(self.ImgStoneGo2.gameObject)
                end
                self.imgLoaders[stone_num]:SetSprite(SingleIconType.Item, base_data.icon)
                self.TxtState.transform:GetComponent(RectTransform).anchoredPosition = Vector2(74, -15)
            elseif stone_num == 3 then
                self.ImgStone3.gameObject:SetActive(true)
                if self.imgLoaders[stone_num] == nil then
                    self.imgLoaders[stone_num] = SingleIconLoader.New(self.ImgStoneGo3.gameObject)
                end
                self.imgLoaders[stone_num]:SetSprite(SingleIconType.Item, base_data.icon)
                break
            end
        end
    end

    if data.lev >= 30 then
        -- 看下背包有没有可镶嵌的宝石
        local state = false

        local allow_list = DataBacksmith.data_gem_limit[data.type].allow
        local temp_dic = EquipStrengthManager.Instance.model:get_first_lev_stones()
        self.base_id_dic = {}

        for i=1,#allow_list do
            local allow_data = allow_list[i]
            local temp_dic_data = temp_dic[allow_data.attr_name]
            if temp_dic_data ~= nil then
                self.base_id_dic[temp_dic_data.id] = true
            end
        end
        for k,v in pairs(BackpackManager.Instance.itemDic) do
            if self.base_id_dic[v.base_id] ~= nil then
                state = true
                break
            end
        end
        -- GetItemByType

        self.TxtState.text = ""
        self.ImgPoint:SetActive(false)

        if stone_num == 0 or (stone_num == 1 and data.lev >= 60) then

            --孔位都是空的 或者有一个孔位同时等级大于等于60
            self.TxtState.text = string.format("<color='#017dd7'>%s</color>", TI18N("有孔位可镶嵌宝石"))

            if RoleManager.Instance.RoleData.lev >= 50 then
                self.ImgPoint:SetActive(true)
            else
                --50级以下背包有就显示红点
                if state then
                    --背包有可镶嵌的宝石
                    self.ImgPoint:SetActive(true)
                else
                    --背包没有可镶嵌的宝石
                    self.ImgPoint:SetActive(false)
                end
            end
        end

        if data.lev >= 70 then
            --英雄宝石孔开启，检查下是否有足够的材料镶嵌
            local hasMarkStone = false
            for i=1,#data.attr do
                local ed = data.attr[i]
                if ed.type == GlobalEumn.ItemAttrType.gem then
                    if ed.name == 112 then
                        hasMarkStone = true
                        break
                    end
                end
            end
            if hasMarkStone == false then
                self.TxtState.text = string.format("<color='#017dd7'>%s</color>", TI18N("有孔位可镶嵌宝石"))
                --还没有镶嵌英雄宝石
                local allowList = DataBacksmith.data_hero_stone_limit[data.type].allow
                local index = 1
                 for k,v in pairs(allowList) do
                    local costData = DataBacksmith.data_hero_stone_cost[v[1]].loss[1]
                    local costNum = costData[2]
                    local hasNum = BackpackManager.Instance:GetItemCount(costData[1])
                    if hasNum >= costNum then
                        self.ImgPoint:SetActive(true)
                        break
                    end
                end

            end
        end
    else
        --等级不足镶嵌
        self.TxtState.text = ""
        self.ImgPoint:SetActive(false)
    end
end