--2016/7/21
--zzl
--宠物符石刻印
PetStoneMarkWindow  =  PetStoneMarkWindow or BaseClass(BasePanel)

function PetStoneMarkWindow:__init(model)
    self.name  =  "PetStoneMarkWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.pet_stone_mark_panel, type  =  AssetType.Main}
        ,{file = string.format(AssetConfig.effect, 20049), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.slotConList = nil
    self.leftItemList = nil
    self.lastSelectedItem = nil
    self.last_selected_slot = nil
    self.model.curPetStoneMarkData = nil
    self.updateItems = function() self:UpdateItems() end
    self.updatePet = function() self:UpdatePet() end
    return self
end


function PetStoneMarkWindow:__delete()
    if self.slotConList ~= nil then
        for k, v in pairs(self.slotConList) do
            v:DeleteMe()
        end
    end
    if self.rightTopSlot ~= nil then
        self.rightTopSlot:DeleteMe()
    end
    if self.leftItemList ~= nil then
        for k, v in pairs(self.leftItemList) do
            v:Release()
        end
    end
    EventMgr.Instance:RemoveListener(event_name.pet_stone_update, self.updatePet)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateItems)
    self.slotConList = nil
    self.leftItemList = nil
    self.lastSelectedItem = nil
    self.model.curPetStoneMarkData = nil
    self.last_selected_slot = nil
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end

    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end
    self:AssetClearAll()
end


function PetStoneMarkWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_stone_mark_panel))
    self.gameObject.name  =  "PetStoneMarkWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:ClosePetStoneMarkWindow() end)

    local Main = self.transform:FindChild("Main")

    local CloseButton = Main:FindChild("CloseButton"):GetComponent(Button)
    CloseButton.onClick:AddListener(function() self.model:ClosePetStoneMarkWindow() end)

    local LeftCon = Main:FindChild("LeftCon")
    self.UnOpen = LeftCon:FindChild("UnOpen")
    self.MaskCon = LeftCon:FindChild("MaskCon")
    local ScrollCon = self.MaskCon:FindChild("ScrollCon")
    self.item_con = ScrollCon:FindChild("Container")
    self.leftItemList = {}
    for i=1,11 do
        local go = self.item_con:FindChild(string.format("Item%s", i)).gameObject
        local item = PetStoneMarkItem.New(go, self)
        table.insert(self.leftItemList, item)
    end

    self.single_item_height = self.leftItemList[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = ScrollCon:GetComponent(RectTransform).sizeDelta.y

    self.setting_data = {
       item_list = self.leftItemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.item_con  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    local vScroll = ScrollCon:GetComponent(ScrollRect)
    vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)


    local RightCon = Main:FindChild("RightCon")
    local TopCon = RightCon:FindChild("TopCon")
    local SlotCon = TopCon:FindChild("SlotCon")
    self.rightTopSlot = self:CreateEquipSlot(SlotCon)

    self.top_right_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20049)))
    self.top_right_effect.transform:SetParent(SlotCon)
    self.top_right_effect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.top_right_effect.transform, "UI")
    self.top_right_effect.transform.localScale = Vector3(1, 1, 1)
    self.top_right_effect.transform.localPosition = Vector3(30, -30, -400)
    self.top_right_effect:SetActive(false)

    self.TxtStoneName = TopCon:FindChild("TxtStoneName"):GetComponent(Text)
    self.TxtStoneType = TopCon:FindChild("TxtStoneType"):GetComponent(Text)
    self.TxtLeftProp = TopCon:FindChild("TxtLeftProp"):GetComponent(Text)
    self.TxtLeftEffect = TopCon:FindChild("TxtLeftEffect"):GetComponent(Text)
    self.TxtRightProp = TopCon:FindChild("TxtRightProp"):GetComponent(Text)
    self.TxtRightEffect = TopCon:FindChild("TxtRightEffect"):GetComponent(Text)

    self.TxtStoneDesc = RightCon:FindChild("TxtStoneDesc"):GetComponent(Text)
    local BottomCon = RightCon:FindChild("BottomCon")
    local BtnLearn = RightCon:FindChild("BtnLearn"):GetComponent(Button)
    BtnLearn.onClick:AddListener(function()
        if self.last_selected_slot == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("请选择要刻印的符石"))
            return
        end
        local stoneMarkData = PetManager.Instance.model.curPetStoneMarkData
        local item = self.last_selected_slot.itemData

        if stoneMarkData ~= nil then
            local temp_data = BackpackManager.Instance:GetItemByBaseid(item.base_id)
            if #temp_data == 0 then
                NoticeManager.Instance:FloatTipsByString(TI18N("该符石已经消耗完"))
                return
            end

            for i=1,#stoneMarkData.stoneData.attr do
                local attr_data = stoneMarkData.stoneData.attr[i]
                if attr_data.name == 100 then
                    if item.effect_client[1].val_client[1] == attr_data.val then
                        --相同特效
                        local confirmData = NoticeConfirmData.New()
                        confirmData.type = ConfirmData.Style.Normal
                        confirmData.sureLabel = TI18N("刻印")
                        confirmData.cancelLabel = TI18N("取消")
                        confirmData.sureCallback = function()
                            PetManager.Instance:Send10544(stoneMarkData.petData.id, stoneMarkData.stoneData.id, temp_data[1].id)
                        end
                        confirmData.content = TI18N("当前符石拥有<color='#ffff00'>相同特效</color>，刻印只能改变<color='#00ff00'>附加属性值</color>，是否要进行刻印？")
                        NoticeManager.Instance:ConfirmTips(confirmData)
                        return
                    end
                end
            end
            PetManager.Instance:Send10544(stoneMarkData.petData.id, stoneMarkData.stoneData.id, temp_data[1].id)
            TipsManager.Instance.model:Closetips()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("当前没有可以刻印的符石，无法使用"))
        end
    end)
    local ToggleGroup = BottomCon:FindChild("ToggleGroup")
    local ScrollView = BottomCon:FindChild("ScrollView")
    local Container = ScrollView:FindChild("Container")
    local ItemPage = Container:FindChild("ItemPage")

    self.pageInitedList = {false, false, false}
    self.pageNum = 3
    self.perPageItemNum = 8
    self.sellScrollRect = ScrollView:GetComponent(ScrollRect)
    self.itemPageTemplate = ItemPage.gameObject-- 分页模板
    -- 初始化各自布局排版
    local setting = {
        axis = BoxLayoutAxis.X
        ,spacing = 20
    }
    self.boxXLayout = LuaBoxLayout.New(Container.gameObject, setting)
    self.itemPageTemplate:SetActive(false)

    self.pageObjList = {}
    self.slotConList = {}
    -- 生成分页
    for i=1,self.pageNum do
        local itemPage = GameObject.Instantiate(self.itemPageTemplate)
        itemPage.name = "itemPage"..i
        self.pageObjList[i] = itemPage
        self.boxXLayout:AddCell(itemPage)
        itemPage.transform.localScale = Vector3.one

        for i=1,self.perPageItemNum do
            local slotCon = itemPage.transform:FindChild(string.format("SlotCon%s", i))
            local slot = self:CreateEquipSlot(slotCon)
            slot.clickSelfFunc = function(data)
                if self.last_selected_slot ~= nil then
                    self.last_selected_slot:ShowSelect(false)
                end
                self.last_selected_slot = slot
                self.last_selected_slot:ShowSelect(true)
                if data ~= nil then
                    local effectData = DataSkill.data_get_pet_stone[data.effect_client[1].val_client[1]]
                    self.TxtRightEffect.text = string.format("%s %s", TI18N("特效"), effectData.name)
                    self.TxtStoneDesc.text = effectData.desc
                end

            end
            table.insert(self.slotConList, slot)
        end
    end
    self.tabbedPanel = TabbedPanel.New(self.sellScrollRect.gameObject, self.pageNum, 320)
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction)
        self:OnMoveEnd(currentPage, direction)
    end)

    self.toggleList = {nil, nil, nil}
    for i=1,self.pageNum do
        self.toggleList[i] = ToggleGroup:Find("Toggle"..i):GetComponent(Toggle)
        self.toggleList[i].isOn = false
    end
    self.toggleList[1].isOn = true

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateItems)

    EventMgr.Instance:AddListener(event_name.pet_stone_update, self.updatePet)

    self:UpdateInfo()
end

----------------------------翻页逻辑
function PetStoneMarkWindow:OnMoveEnd(currentPage, direction)
    if direction == LuaDirection.Left then
        self.toggleList[currentPage - 1].isOn = false
        self.toggleList[currentPage].isOn = true
    elseif direction == LuaDirection.Right then
        self.toggleList[currentPage + 1].isOn = false
        self.toggleList[currentPage].isOn = true
    end
end


----------------------------更新逻辑
--更新道具
function PetStoneMarkWindow:UpdateItems()
    self:UpdateRightBottom()
end

--更新宠物属性
function PetStoneMarkWindow:UpdatePet()
    -- self:UpdateLeft(2)
    if self.lastSelectedItem ~= nil then
        local last_data = self.lastSelectedItem.data
        for k, v in pairs(self.model.petlist) do
            if v.id == last_data.petData.id then
                for i=1,#v.stones do
                    local stoneData = v.stones[i]
                    if stoneData.id ~=  1 and stoneData.id == last_data.stoneData.id then
                        local temp_data = DataPet.data_pet_grade[string.format("%s_%s", v.base.id, v.grade+1)]
                        if stoneData.id ~= 1 and temp_data == nil then
                            local new_data = {petData = v, stoneData = stoneData}
                            self.lastSelectedItem:update_my_self(new_data)
                        end
                    end
                end
            end
        end
    end
    self:UpdateRightBottom()
end

--更新面板信息
function PetStoneMarkWindow:UpdateInfo()
    self:UpdateLeft(1)
    self:UpdateRightBottom()
end

--更新左边面板信息
function PetStoneMarkWindow:UpdateLeft(updateType)
    --组织下数据
    local leftDataList = {}
    local itemIndex = 1
    for k, v in pairs(self.model.petlist) do
        for i=1,#v.stones do
            local stoneData = v.stones[i]
            local temp_data = DataPet.data_pet_grade[string.format("%s_%s", v.base.id, v.grade+1)]
            if stoneData.id ~= 1 and temp_data == nil then
                table.insert(leftDataList, {petData = v, stoneData = stoneData})
            end
        end
    end

    table.sort( leftDataList, function(a, b)
        if a.petData.id == b.petData.id then
            return a.stoneData.id < b.stoneData.id
        else
            return a.petData.id < b.petData.id
        end
    end)

    self.setting_data.data_list = leftDataList
    if updateType == 1 then
        BaseUtils.refresh_circular_list(self.setting_data)
    elseif updateType == 2 then
        BaseUtils.static_refresh_circular_list(self.setting_data)
    end

    if #leftDataList == 0 then
        self.UnOpen.gameObject:SetActive(true)
        self.MaskCon.gameObject:SetActive(false)
        self.TxtLeftProp.text = TI18N("无")
        self.TxtLeftEffect.text = TI18N("特效 +??")
        self.TxtRightProp.text = TI18N("无")
        self.TxtRightEffect.text = TI18N("特效 +??")
    else
        self.UnOpen.gameObject:SetActive(false)
        self.MaskCon.gameObject:SetActive(true)
        if self.lastSelectedItem ~= nil then
            self:UpdateRight(self.lastSelectedItem)
        else
            self:UpdateRight(self.leftItemList[1])
        end
    end

end

--更新右边底部
function PetStoneMarkWindow:UpdateRightBottom()
    --初始化数据
    self.itemdata_list = {}
    local item_data_by_baseid = nil
    local item = nil
    local backPackDataList = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.petStoneMark)
    local tempDataList = {}
    for i=1,#backPackDataList do
        if tempDataList[backPackDataList[i].base_id] == nil then
            tempDataList[backPackDataList[i].base_id] = BaseUtils.copytab(backPackDataList[i])
        end
    end

    for i=1,#self.slotConList do
        local slot = self.slotConList[i]
        slot:SetAll(nil)
    end

    for k,v in pairs(tempDataList) do
        v.quantity = BackpackManager.Instance:GetItemCount(v.base_id)
        v.show_num = true
        table.insert(self.itemdata_list, v)
    end

    for i=1,#self.itemdata_list do
        local slot = self.slotConList[i]
        local itemData = self.itemdata_list[i]
        local extra = {white_list = {{id = 1, show = true}, {id = 10, show = false}}, nobutton = true}
        slot:SetAll(itemData, extra)
        slot:SetNotips(true)
        slot:SetGrey(false)
    end

    if self.last_selected_slot ~= nil then
        self.last_selected_slot.clickSelfFunc(self.last_selected_slot.itemData)
    else
        self.slotConList[1].clickSelfFunc(self.slotConList[1].itemData)
    end
end

--更新右边面板信息
function PetStoneMarkWindow:UpdateRight(item)
    if self.lastSelectedItem ~= nil then
        self.lastSelectedItem.ImgSelected:SetActive(false)
    end
    self.lastSelectedItem = item
    self.lastSelectedItem.ImgSelected:SetActive(true)
    self.model.curPetStoneMarkData = item.data

    local baseData = DataItem.data_get[item.stoneData.base_id]
    self:SetSlotData(self.rightTopSlot, baseData)
    self.TxtStoneName.text = ColorHelper.color_item_name(baseData.quality, baseData.name)

    --左边属性
    self.TxtLeftProp.text = ""
    self.TxtLeftEffect.text = TI18N("特效 无")
    self.TxtRightProp.text = ""
    self.TxtRightEffect.text = TI18N("特效 +??")
    local normalName = 0
    for i=1,#item.stoneData.attr do
        local attr_data = item.stoneData.attr[i]
        if attr_data.name == 100 then
            --特效
            local effectData = DataSkill.data_get_pet_stone[attr_data.val]
            self.TxtLeftEffect.text = string.format("%s %s", TI18N("特效"), effectData.name)
        else
            --非特效
            normalName = attr_data.name
            self.TxtLeftProp.text = string.format("%s +%s", KvData.attr_name[attr_data.name], attr_data.val)
        end
    end

    if normalName ~= 0 then
        local maxVal = 0
        local minVal = 0
        for i=1,#DataPet.data_pet_stone_wash_attr do
            local cfgData = DataPet.data_pet_stone_wash_attr[i]
            if cfgData.attr_name == normalName then
                if maxVal == 0 then
                    maxVal = cfgData.val
                else
                    if maxVal < cfgData.val then
                        maxVal = cfgData.val
                    end
                end
                if minVal == 0 then
                    minVal = cfgData.val
                else
                    if minVal > cfgData.val then
                        minVal = cfgData.val
                    end
                end
            end
        end
        self.TxtRightProp.text = string.format("%s +%s~%s", KvData.attr_name[normalName], minVal,maxVal)
    end
    if self.last_selected_slot ~= nil then
        self.last_selected_slot.clickSelfFunc(self.last_selected_slot.itemData)
    end
end

--播放特效
function PetStoneMarkWindow:OnPlayStoneMarkEffect()
    self.top_right_effect:SetActive(false)
    self.top_right_effect:SetActive(true)
    LuaTimer.Add(1200, function()
        if not BaseUtils.is_null(self.top_right_effect) then
            self.top_right_effect:SetActive(false)
        end
    end )
end

----------------------------左边列表item简单逻辑


--设置左边列表item的数据
function PetStoneMarkWindow:SetLeftItemData(item, petData, stoneData)

end


--创建slot
function PetStoneMarkWindow:CreateEquipSlot(slotCon)
    local slot = ItemSlot.New()
    slot.gameObject.transform:SetParent(slotCon)
    slot.gameObject.transform.localScale = Vector3.one
    slot.gameObject.transform.localPosition = Vector3.zero
    slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return slot
end

--对slot设置数据
function PetStoneMarkWindow:SetSlotData(slot, data, _nobutton)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if nobutton == nil then
        slot:SetAll(cell, {nobutton = true})
    else
        slot:SetAll(cell, {nobutton = _nobutton})
    end
end