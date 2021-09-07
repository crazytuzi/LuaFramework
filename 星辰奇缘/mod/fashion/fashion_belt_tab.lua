FashionBeltTab = FashionBeltTab or BaseClass(BasePanel)

function FashionBeltTab:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.fashion_belt_tab, type = AssetType.Main}
        ,{file = string.format(AssetConfig.effect, 20053), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    self.has_init = false

    self.item_list = nil
    self.current_data_list = nil

    self.last_selected_item_list = nil

    self.buy_btn_state = 0

    self.on_save_fashion = function()
        -- self:on_click_put_on_btn()
    end

    self.on_bottom_prices_back = function(prices)
        -- self.parent:on_price_back(prices)
    end
    self.lastSelectedData = nil
    self.unActiveCostDic = nil
    self.on_item_update = function()
        if self.unActiveCostDic ~= nil then
            self:UpdateClothCost(self.unActiveCostDic)
        end
    end
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_item_update)
    return self
end

function FashionBeltTab:__delete()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
    self.lastSelectedData = nil
    self.unActiveCostDic = nil
    if self.last_selected_item_list ~= nil then
        for k, v in pairs(self.last_selected_item_list) do
            v:Release()
        end
    end

    if self.ClothCostSlot ~= nil then
        self.ClothCostSlot:DeleteMe()
        self.ClothCostSlot = nil
    end

    self.gameObject = nil
    self.has_init = false
    if self.item_list ~= nil then
        for k,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
   end
    self.last_selected_item_list = nil
    self.current_data_list = nil

    self:AssetClearAll()
end

function FashionBeltTab:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_belt_tab))
    self.gameObject.name = "FashionBeltTab"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.ConRight)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(0, 0, 0)


    --底部
    self.ConClothBottom = self.transform:Find("ConClothBottom")
    self.BttomTxtLock = self.ConClothBottom:FindChild("TxtLock"):GetComponent(Text)
    self.BttomTxtLock.text = ""
    self.ClothSaveBtn = self.ConClothBottom:Find("BtnPutOn"):GetComponent(Button)
    self.ClothSaveBtnTxt = self.ConClothBottom:Find("BtnPutOn/Text"):GetComponent(Text)
    self.ClothCostCon = self.ConClothBottom:Find("TxtCon")
    self.ClothCostTxt = self.ConClothBottom:Find("TxtCon/Slot1/TxtName"):GetComponent(Text)
    self.ClothCostGetBtn = self.ConClothBottom:Find("TxtCon/BtnGet"):GetComponent(Button)
    self.ClothCostGetBtnTxt = self.ConClothBottom:Find("TxtCon/BtnGet/Text"):GetComponent(Text)
    self.ClothCostSlotCon = self.ConClothBottom:Find("TxtCon/Slot1/SlotCon")
    self.ClothCostSlot = self:CreateSlot(self.ClothCostSlotCon)
    self.ClothCostGetBtn.gameObject:SetActive(true)
    self.ClothCostCon.gameObject:SetActive(false)

    self.BtnUpEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20053)))
    self.BtnUpEffect.transform:SetParent(self.ClothCostGetBtn.transform)
    self.BtnUpEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.BtnUpEffect.transform, "UI")
    self.BtnUpEffect.transform.localScale = Vector3(1.5, 0.8, 1)
    self.BtnUpEffect.transform.localPosition = Vector3(-47.4, -19, -400)
    self.BtnUpEffect.gameObject:SetActive(false)

    self.ClothCostGetBtn.onClick:AddListener(function()
        --检查下该商品，商城是否有卖，有则弹出购买界面
        if self.unActiveCostDic ~= nil then
            local costDic = self.unActiveCostDic
            local baseId = 0
            local needNum = 0
            for k, need in pairs(costDic) do
                if need ~= 0 then
                    baseId = k
                     needNum = need
                end
            end
            if baseId ~= 0 then
                local hasNum = BackpackManager.Instance:GetItemCount(baseId)
                if hasNum >= needNum then
                    --使用
                    local temp = BackpackManager.Instance:GetItemByBaseid(baseId)[1]
                    BackpackManager.Instance:Use(temp.id, 1, baseId)
                else
                    local base_data = DataItem.data_get[baseId]
                    local dropstr = ""
                    for i, data in ipairs(base_data.tips_type) do
                        if data.tips == 2 then
                            dropstr = data.val
                            break
                        end
                    end
                    local canBuy = false
                    for code,argstr,label,desc,icon in string.gmatch(dropstr, "{(%d-);(.-);(.-);(.-);(%d-)}") do
                        local args = StringHelper.Split(argstr, "|")
                        local tempCode = code
                        if #args == 0 then
                            table.insert(args,tonumber(argstr))
                        end
                        if tonumber(tempCode) == TipsEumn.DropCode.OpenWindow then
                            if #args == 3 then
                                if  tonumber(args[1]) == WindowConfig.WinID.shop and tonumber(args[2]) == 1 and tonumber(args[3]) == 4 then
                                    canBuy = true
                                    break
                                end
                            end
                        end
                    end
                    if canBuy then
                        --可以买,直接打开便捷购买
                        ShopManager.Instance.model:OpenQuickBuyPanel(baseId)
                    else
                        local info = {itemData = base_data, gameObject = self.ClothCostGetBtn.gameObject}
                        TipsManager.Instance:ShowItem(info)
                    end
                end
            end
        end
    end)

    --底部保存购买按钮
    self.ConBottom = self.transform:FindChild("ConBottom")
    self.TxtLock = self.ConBottom:FindChild("TxtLock"):GetComponent(Text)
    self.BtnChongneng = self.ConBottom:FindChild("BtnChongneng"):GetComponent(Button)
    self.BtnBuy = self.ConBottom:FindChild("BtnSave"):GetComponent(Button)

    self.BtnChongneng.onClick:AddListener( function() self:on_click_chongneng() end)
    self.BtnBuy.onClick:AddListener( function() self:on_click_buy() end)

    ----套装选项卡
    self.ClothTab = self.transform:FindChild("ClothTab")
    self.MaskLayer = self.ClothTab:FindChild("MaskLayer")
    self.ScrollLayer = self.MaskLayer.transform:FindChild("ScrollLayer")
    self.LayoutLayer = self.ScrollLayer.transform:FindChild("LayoutLayer")
    self.LayoutLayer_rect = self.LayoutLayer:GetComponent(RectTransform)
    self.origin_item = self.LayoutLayer:FindChild("Item").gameObject
    self.origin_item:SetActive(false)

    self.has_init = true

    self.last_selected_item_list = {}

    self:update_item_list(self.parent.model:get_belt_data_list())
end

--重置掉所有选中的item
function FashionBeltTab:reset_belt_selected_items()
    if self.has_init == false then
        return
    end
    for k, v in pairs(self.last_selected_item_list) do
        v:set_select(false)
    end
    self.last_selected_item_list = {}
end

--更新右边数据列表
function FashionBeltTab:update_item_list(data_list)
    if self.has_init == false then
        return
    end

    self.current_data_list = {}
    for k, v in pairs(data_list) do
        table.insert(self.current_data_list, v)
    end


    local priority_sort = function(a, b)
        return a.id > b.id --根据index从大到小排序
    end
    table.sort(self.current_data_list, priority_sort)

    local active_sort = function(a, b)
        if a.active == b.active then
            return a.id > b.id --根据index从大到小排序
        else
            --根据激活从大到小排序
            return a.active > b.active
        end
    end
    table.sort(self.current_data_list, active_sort)


    if self.item_list ~= nil then
        for i=1,#self.item_list do
            local it = self.item_list[i]
            if it.gameObject ~= nil then
                it.gameObject:SetActive(false)
                it:set_select(false)
            end
        end
    else
        self.item_list = {}
    end

    --根据数据量设置LayoutLayer 的高度
    local lineNum = math.floor(#self.current_data_list/3)
    local nextNum = #self.current_data_list%3
    lineNum = nextNum > 0 and (lineNum+1) or lineNum
    local newHeight = lineNum*100
    self.LayoutLayer_rect.sizeDelta = Vector2(self.LayoutLayer_rect.rect.width, newHeight)
    self.LayoutLayer_rect.anchoredPosition = Vector2.zero
    local has_wear_one = false

    for i=1,#self.current_data_list do
        local v = self.current_data_list[i]
        local item = self.item_list[i]
        if item == nil then
            item = FashionBeltItem.New(self, self.origin_item, i)
        else
            item:set_select(false)
            item.gameObject:SetActive(true)
        end
        if v.is_wear == 1 then
            has_wear_one = true
        end
        item:set_item_data(v)
        table.insert(self.item_list, item)
    end

    if self.last_selected_item_list ~= nil then
        for k, v in pairs(self.last_selected_item_list) do
            if v.data ~= nil and v.selected then
                --取消选中
                v:on_select_item(1)
            end
        end
    end



    for i=1,#self.item_list do
        local item = self.item_list[i]

        if item.data.is_wear == 1 then
            item:on_select_item(1)
            item:set_select(true)
        end
    end


    if has_wear_one == false then
        self.parent:update_model()
    else
        local data_list = {}
        for k, v in pairs(self.last_selected_item_list) do
            if v.selected then
                local cfg_data = v.data
                table.insert(data_list, cfg_data)
            end
        end
        self.parent:update_batch_model(data_list)
    end
end


--选中某个腰饰
function FashionBeltTab:update_left(item, _force)
    --_force 不为nil，则是要求不考虑这个item是否选中
    local data_list = {}

    if item.selected == true then
        --脱掉
        item:set_select(false)
        for k, v in pairs(self.last_selected_item_list) do
            if v.selected then
                local cfg_data = v.data
                table.insert(data_list, cfg_data)
            end
        end

        local default_data = self.parent.model:get_default_fashion(item.data.type)
        table.insert(data_list, default_data)
    else
        self.last_selected_item_list[item.data.base_id] = item

        for k, v in pairs(self.last_selected_item_list) do
            --取消相同类型和base_id不同的那个item
            if v.data.base_id ~= item.data.base_id and v.data.type == item.data.type then
                v:set_select(false)
            end
        end
        item:set_select(true)

        for k, v in pairs(self.last_selected_item_list) do
            if v.selected then
                local cfg_data = v.data
                table.insert(data_list, cfg_data)
            end
        end
    end
    if item.selected then
        self.lastSelectedData = item.data
        self.parent:UpdateLeftTopFaceScore(3, item.data.desc, item.data)
    else
        self.lastSelectedData = nil
        self.parent:UpdateLeftTopFaceScore(3, "", nil)
    end
    if _force == nil then
        --更新模型
        self.parent:update_batch_model(data_list)
    end
end


--购买、保存、充能按钮的点击监听
function FashionBeltTab:on_click_buy()
    --得判断下是购买还是保存
    local _head_ornament = 0
    local _belt_ornament = 0
    if self.buy_btn_state == 2 then
        --穿上
        if self.parent.model:check_is_belt_can_wear(self.parent.model.current_head_dress_data) then
            _head_ornament = self.parent.model.current_head_dress_data.base_id
        end
        if self.parent.model:check_is_belt_can_wear(self.parent.model.current_waist_data) then
             _belt_ornament = self.parent.model.current_waist_data.base_id
        end
    end
    FashionManager.Instance:request13202(_head_ornament, _belt_ornament)
end

function FashionBeltTab:on_click_chongneng()
    self.parent.model.belt_type = 2
    self.parent.model:InitFashionBeltConfirmUI()
end

--更新穿戴按钮的样式
function FashionBeltTab:update_put_on_btn()
    if self.has_init == false then
        return
    end
    self.BtnChongneng.gameObject:SetActive(false)
    self.BtnBuy.gameObject:SetActive(false)
    self.TxtLock.text = ""

    if self.parent.model:check_is_belt_data(self.parent.model.current_waist_data) == false and self.parent.model:check_is_belt_data(self.parent.model.current_head_dress_data) == false then
        self.TxtLock.text = TI18N("请选择要穿戴的饰品")
         self.ConClothBottom.gameObject:SetActive(false)
         self.ConBottom.gameObject:SetActive(true)
    else
        local active = 0
        local single = false
        --设置按钮显示状态
        if self.parent.model:check_is_belt_data(self.parent.model.current_waist_data) and self.parent.model:check_is_base_data(self.parent.model.current_head_dress_data) then
            --选择一件
            active = self.parent.model.current_waist_data.active
            single = true
            self:set_buy_btn_state(active, single, self.parent.model.current_waist_data)
        elseif self.parent.model:check_is_belt_data(self.parent.model.current_head_dress_data) and self.parent.model:check_is_base_data(self.parent.model.current_waist_data) then
            --选择一件
            active = self.parent.model.current_head_dress_data.active
            single = true
            self:set_buy_btn_state(active, single, self.parent.model.current_head_dress_data)
        elseif self.parent.model:check_is_belt_data(self.parent.model.current_head_dress_data) and self.parent.model:check_is_belt_data(self.parent.model.current_waist_data) then
            --选择两件
            if (self.parent.model.current_waist_data.active == 1) and (self.parent.model.current_head_dress_data.active == 1) then
                active = 1
            end
            single = false
            self:set_buy_btn_state(active, single)
        end
    end
end

--设置购买保存按钮状态
function FashionBeltTab:set_buy_btn_state(active, single, data)
    self.ConClothBottom.gameObject:SetActive(false)
    self.ConBottom.gameObject:SetActive(true)
    if single then
        --只选了一件
        if active == 1 then
            self.BtnBuy.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
            self.BtnBuy.gameObject:SetActive(true)
            if data ~= nil and data.is_wear == 1 then
                self.buy_btn_state = 1
                self.BtnBuy.transform:FindChild("Text"):GetComponent(Text).text = TI18N("脱 下")
            else
                self.buy_btn_state = 2
                self.BtnBuy.transform:FindChild("Text"):GetComponent(Text).text = TI18N("保 存")
            end
        else
            self.ConClothBottom.gameObject:SetActive(true)
            self.ConBottom.gameObject:SetActive(false)
            --未激活
            local unActiveData = nil
            if self.lastSelectedData == nil then
                if self.parent.model.current_waist_data ~= nil and self.parent.model.current_waist_data.active == 0 then
                    unActiveData = self.parent.model.current_waist_data
                elseif self.parent.model.current_head_dress_data ~= nil and self.parent.model.current_head_dress_data.active == 0 then
                    unActiveData = self.parent.model.current_head_dress_data
                end
            else
                unActiveData = self.lastSelectedData
            end
            self:UpdateClothCost(self.parent.model:count_fashion_loss(unActiveData))
            -- local name_str = ""
            -- if self.parent.model.current_waist_data ~= nil and self.parent.model.current_waist_data.active == 0 then
            --     name_str = string.format("<color='#2fc823'>[%s]</color>", self.parent.model.current_waist_data.name)
            -- end
            -- if self.parent.model.current_head_dress_data ~= nil and self.parent.model.current_head_dress_data.active == 0 then
            --     name_str = string.format("%s<color='#2fc823'>[%s]</color>", name_str, self.parent.model.current_head_dress_data.name)
            -- end
            -- self.TxtLock.text = string.format("%s%s", name_str, TI18N("未激活"))
        end
    elseif active == 1 then
        --激活
        self.BtnBuy.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
        self.BtnBuy.gameObject:SetActive(true)
        if (self.parent.model.current_waist_data.is_wear == 1) and (self.parent.model.current_head_dress_data.is_wear == 1) then
            self.buy_btn_state = 1
            self.BtnBuy.transform:FindChild("Text"):GetComponent(Text).text = TI18N("脱 下")
        else
            self.buy_btn_state = 2
            self.BtnBuy.transform:FindChild("Text"):GetComponent(Text).text = TI18N("保 存")
        end
    else
        self.ConClothBottom.gameObject:SetActive(true)
        self.ConBottom.gameObject:SetActive(false)
        --未激活
        local unActiveData = nil
        if self.lastSelectedData == nil then
            if self.parent.model.current_waist_data ~= nil and self.parent.model.current_waist_data.active == 0 then
                unActiveData = self.parent.model.current_waist_data
            elseif self.parent.model.current_head_dress_data ~= nil and self.parent.model.current_head_dress_data.active == 0 then
                unActiveData = self.parent.model.current_head_dress_data
            end
        else
            unActiveData = self.lastSelectedData
        end
        self:UpdateClothCost(self.parent.model:count_fashion_loss(unActiveData))
        -- local name_str = ""
        -- if self.parent.model.current_waist_data ~= nil and self.parent.model.current_waist_data.active == 0 then
        --     name_str = string.format("<color='#2fc823'>[%s]</color>", self.parent.model.current_waist_data.name)
        -- end
        -- if self.parent.model.current_head_dress_data ~= nil and self.parent.model.current_head_dress_data.active == 0 then
        --     name_str = string.format("%s<color='#2fc823'>[%s]</color>", name_str, self.parent.model.current_head_dress_data.name)
        -- end
        -- self.TxtLock.text = string.format("%s%s", name_str, TI18N("未激活"))
    end
end

--更新底部消耗
function FashionBeltTab:UpdateClothCost(costDic)
    self.unActiveCostDic = costDic
    local baseId = 0
    local needNum = 0
    for k, need in pairs(costDic) do
        if need ~= 0 then
            baseId = k
            needNum = need
        end
    end
    if baseId ~= 0 then
        self.ClothCostCon.gameObject:SetActive(true)
        self.ClothSaveBtn.gameObject:SetActive(false)
        local hasNum = BackpackManager.Instance:GetItemCount(baseId)
        local baseData = DataItem.data_get[baseId]
        self.ClothCostTxt.text = baseData.name
        self:SetSlotData(self.ClothCostSlot, baseData)
        self.ClothCostSlot:SetNum(hasNum, needNum)
        if hasNum >= needNum then
            self.ClothCostGetBtnTxt.text =  TI18N("使 用")
            self.BtnUpEffect.gameObject:SetActive(true)
        else
            self.ClothCostGetBtnTxt.text =  TI18N("获 取")
            self.BtnUpEffect.gameObject:SetActive(false)
        end
    end
end

--slot逻辑
--创建slot
function FashionBeltTab:CreateSlot(slot_con)
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
function FashionBeltTab:SetSlotData(slot, data)
    if data == nil then
        slot:SetAll(nil, nil)
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    slot:SetAll(cell, nil)
end