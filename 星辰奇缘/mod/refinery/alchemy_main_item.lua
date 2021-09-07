AlchemyMainItem = AlchemyMainItem or BaseClass()

function AlchemyMainItem:__init(parent, origin_item, index)
    self.parent = parent
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one

    self.gameObject:SetActive(true)
    self.transform = self.gameObject.transform
    self.toggle = self.transform:FindChild("Toggle"):GetComponent(Toggle)
    self.Item1 = self.transform:FindChild("Item1")
    self.Item2 = self.transform:FindChild("Item2")
    self.Item3 = self.transform:FindChild("Item3")
    self.Item4 = self.transform:FindChild("Item4")
    self.Item5 = self.transform:FindChild("Item5")

    self.TxVal = self.Item1:FindChild("TxVal"):GetComponent(Text)
    self.Item1_ImgIcon = self.Item1:FindChild("ImgIcon"):GetComponent(Image)
    -- 大图  hosr
    local bigbg = self.Item1:Find("Bg"):GetComponent(Image)
    bigbg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")

    self.loaders = {}
    local instanceID = self.Item1_ImgIcon.gameObject:GetInstanceID()
    local loader = self.loaders[instanceID]
    if loader == nil then
        loader = SingleIconLoader.New(self.Item1_ImgIcon.gameObject)
        self.loaders[instanceID] = loader
    end
    loader:SetSprite(SingleIconType.Item, 90017)

    self.slot_con_list = {}
    self.slot_list = {}
    self.slot1 = self:create_slot(self.Item1:FindChild("SlotCon"), false)
    self.slot2 = self:create_slot(self.Item2:FindChild("SlotCon"), true)
    self.slot3 = self:create_slot(self.Item3:FindChild("SlotCon"), true)
    self.slot4 = self:create_slot(self.Item4:FindChild("SlotCon"), true)
    self.slot5 = self:create_slot(self.Item5:FindChild("SlotCon"), true)
    table.insert(self.slot_list, self.slot2)
    table.insert(self.slot_list, self.slot3)
    table.insert(self.slot_list, self.slot4)
    table.insert(self.slot_list, self.slot5)

    -- self.slot1:
    self.slot2:SetNotips(true)
    self.slot3:SetNotips(true)
    self.slot4:SetNotips(true)
    self.slot5:SetNotips(true)

    table.insert(self.slot_con_list, self.Item2:FindChild("SlotCon").gameObject)
    table.insert(self.slot_con_list, self.Item3:FindChild("SlotCon").gameObject)
    table.insert(self.slot_con_list, self.Item4:FindChild("SlotCon").gameObject)
    table.insert(self.slot_con_list, self.Item5:FindChild("SlotCon").gameObject)

    self.finish_img_list = {}
    table.insert(self.finish_img_list, self.Item2:FindChild("SlotCon"):FindChild("ImgFinish").gameObject)
    table.insert(self.finish_img_list, self.Item3:FindChild("SlotCon"):FindChild("ImgFinish").gameObject)
    table.insert(self.finish_img_list, self.Item4:FindChild("SlotCon"):FindChild("ImgFinish").gameObject)
    table.insert(self.finish_img_list, self.Item5:FindChild("SlotCon"):FindChild("ImgFinish").gameObject)
    for i=1,#self.finish_img_list do
        self.finish_img_list[i]:SetActive(false)
        self.finish_img_list[i].transform:GetComponent(CanvasGroup).blocksRaycasts = false
    end

    self.cost_con_list = {}
    self.cost_txt_list = {}
    table.insert(self.cost_con_list,self.Item2:FindChild("TxtCost"):GetComponent(Text))
    table.insert(self.cost_con_list,self.Item3:FindChild("TxtCost"):GetComponent(Text))
    table.insert(self.cost_con_list,self.Item4:FindChild("TxtCost"):GetComponent(Text))
    table.insert(self.cost_con_list,self.Item5:FindChild("TxtCost"):GetComponent(Text))
    for i=1,#self.cost_con_list do
        table.insert(self.cost_txt_list, MsgItemExt.New(self.cost_con_list[i], 150, 15, 23))
    end

    for i=1,#self.cost_con_list do
        self.cost_con_list[i].gameObject:SetActive(false)
    end

    self.txt_list = {}
    self.TxtDesc1 = self.Item1:FindChild("TxtDesc"):GetComponent(Text)
    self.TxtDesc2 = self.Item2:FindChild("TxtDesc"):GetComponent(Text)
    self.TxtDesc3 = self.Item3:FindChild("TxtDesc"):GetComponent(Text)
    self.TxtDesc4 = self.Item4:FindChild("TxtDesc"):GetComponent(Text)
    self.TxtDesc5 = self.Item5:FindChild("TxtDesc"):GetComponent(Text)
    table.insert(self.txt_list, self.TxtDesc2)
    table.insert(self.txt_list, self.TxtDesc3)
    table.insert(self.txt_list, self.TxtDesc4)
    table.insert(self.txt_list, self.TxtDesc5)
    self.TxtDesc2.text = ""
    self.TxtDesc3.text = ""
    self.TxtDesc4.text = ""
    self.TxtDesc5.text = ""

    self.txt_time_list = {}
    self.TxtTime2 = self.Item2:FindChild("TxtTime"):GetComponent(Text)
    self.TxtTime3 = self.Item3:FindChild("TxtTime"):GetComponent(Text)
    self.TxtTime4 = self.Item4:FindChild("TxtTime"):GetComponent(Text)
    self.TxtTime5 = self.Item5:FindChild("TxtTime"):GetComponent(Text)
    table.insert(self.txt_time_list, self.TxtTime2)
    table.insert(self.txt_time_list, self.TxtTime3)
    table.insert(self.txt_time_list, self.TxtTime4)
    table.insert(self.txt_time_list, self.TxtTime5)
    self.TxtTime2.text = ""
    self.TxtTime3.text = ""
    self.TxtTime4.text = ""
    self.TxtTime5.text = ""

    self.TxtTime2.color = Color(1/255, 125/255, 215/255, 1)
    self.TxtTime3.color = Color(1/255, 125/255, 215/255, 1)
    self.TxtTime4.color = Color(1/255, 125/255, 215/255, 1)
    self.TxtTime5.color = Color(1/255, 125/255, 215/255, 1)

    local newY = (index - 1)*-118
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(0, newY)

    self.timer_id = 0
    self.hasListener = false
end

function AlchemyMainItem:Release()
    self:stop_timer()
    self.slot1:DeleteMe()
    self.slot2:DeleteMe()
    self.slot3:DeleteMe()
    self.slot4:DeleteMe()
    self.slot5:DeleteMe()
end

function AlchemyMainItem:__delete()
    self:Release()
    self.toggle.onValueChanged:RemoveAllListeners()

    for _, v in pairs(self.loaders) do
        v:DeleteMe()
    end
    self.loaders = {}
end

function AlchemyMainItem:InitPanel(data)

end

function AlchemyMainItem:SetData(data)
    self.data = data

    for i=1,#self.cost_con_list do
        self.cost_con_list[i].gameObject:SetActive(false)
    end
    self.toggle.onValueChanged:RemoveAllListeners()
    if data.is_auto == 1 then
        self.toggle.isOn = true
    else
        self.toggle.isOn = false
    end

    -- if self.hasListener == false then
        self.toggle.onValueChanged:AddListener(function(on)
            local base_data = DataItem.data_get[self.data.show_item_id]
            if on then
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("勾选成功，<color='#23F0F7'>[%s]</color>将被<color='#ffff00'>一键炼制</color>"), base_data.name))
                AlchemyManager.Instance:request14909(self.data.id, 1)
            else
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#23F0F7'>[%s]</color>已取消勾选，<color='#ffff00'>不再一键炼制</color>"), base_data.name))
                AlchemyManager.Instance:request14909(self.data.id, 0)
            end
        end)
    --     self.hasListener = true
    -- end

    --都设置成锁状态
    for i=data.volume+1,4 do

        local cost_txt = self.cost_txt_list[i]
        local cost_str = ""
            for j=1,#self.data.open_cost do
                local cost = self.data.open_cost[j]
                if cost[3] == i then
                    cost_str = string.format("%s{assets_2, %s}",cost[2], cost[1])
                    break
                end
            end
        cost_txt:SetData(cost_str)
        if cost_txt.selfWidth < 105 then
            self.cost_con_list[i].transform:GetComponent(RectTransform).anchoredPosition = Vector2((105 - cost_txt.selfWidth) / 2, 1)
        end
        local slot = self.slot_list[i]
        slot:SetAll(nil)
        slot:ShowAddBtn(false)
        slot:ShowLock(true)
        slot:SetAddCallback(nil)
        slot:SetSelectSelfCallback(nil)
        slot:SetLockCallback(function()
            --请求扩展空间
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format("%s%s", TI18N("增加1格，需要消耗"), cost_str)
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                AlchemyManager.Instance:request14901(self.data.id)
            end
            NoticeManager.Instance:ConfirmTips(data)
        end)
    end

    --设置显示和隐藏状态
    for i=1,#self.slot_con_list do
        if i<= data.volume+1 then
            self.cost_con_list[i].gameObject:SetActive(true)
            self.slot_con_list[i]:SetActive(true)
        else
            self.cost_con_list[i].gameObject:SetActive(false)
            self.slot_con_list[i]:SetActive(false)
        end
    end

    local cfg_data = DataAlchemy.data_base[self.data.id]
    self.TxVal.text = tostring(cfg_data.cost[1][2])

    for i,v in ipairs(self.finish_img_list) do
        v:SetActive(false)
    end

    --设置开启个数
    for i=1,data.volume do
        local slot = self.slot_list[i]
        slot:SetAll(nil)
        slot:ShowAddBtn(true)
        self.cost_con_list[i].gameObject:SetActive(false)
        slot:ShowLock(false)
        slot:SetLockCallback(nil)
        slot:SetSelectSelfCallback(nil)
        slot:SetAddCallback(function()
            AlchemyManager.Instance:request14902(self.data.id)
        end)
    end

    --设置产出
    for i = 1,#data.products do
        local slot = self.slot_list[i]
        self.cost_con_list[i].gameObject:SetActive(false)
        slot:ShowAddBtn(false)
        slot:ShowLock(false)
        slot:SetLockCallback(nil)
        slot:SetAddCallback(nil)
        slot:SetSelectSelfCallback(function()
            -- self:on_switch_stone_hole(gem_data, 2)
            AlchemyManager.Instance:request14903(self.data.id)
        end)

        local base_data = DataItem.data_get[self.data.show_item_id]
        self:set_slot_data(slot, base_data)
    end


    local base_data = DataItem.data_get[self.data.show_item_id]
    local cell = ItemData.New()
    cell:SetBase(base_data)
    self.slot1:SetAll(cell, {nobutton = true})

    self.TxtDesc1.text = base_data.name --ColorHelper.color_item_name(base_data.quality , base_data.name)

    local time_sort = function(a,b)
        return a.time < b.time
    end

    table.sort(data.products , time_sort)

    for i=1,#data.products do
        local left_time = data.products[i].time + data.need_time - BaseUtils.BASE_TIME
        local txt = self.txt_list[i]
        local time_txt = self.txt_time_list[i]
        if left_time <= 0 then
            txt.text = ""
            time_txt.text = ""
            self.finish_img_list[i]:SetActive(true)
            self.finish_img_list[i].transform:SetAsLastSibling()
        else
            if i == 1 then
                txt.text = string.format("<color='%s'>%s</color>", "#017dd7", TI18N("炼制中…"))
            else
                local left_time = data.products[i-1].time + data.need_time - BaseUtils.BASE_TIME
                txt.text = string.format("<color='%s'>%s</color>", ColorHelper.color[0], TI18N("等待中"))
                time_txt.text = ""
            end
        end
    end

    if #data.products+1 <= 4 then
        for i=#data.products+1, 4 do
            local txt = self.txt_list[i]
            local time_txt = self.txt_time_list[i]
            txt.text = ""
            time_txt.text = ""
        end
    end

    if #data.products > 0 then
        --开始计时
        self.tick_index = 1
        self:start_timer()
    else
        self:stop_timer()
    end
end

--为每个slot容器创建slot
function AlchemyMainItem:create_slot(slot_con, state)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con)
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

    -- stone_slot:SetNotips(state)
    return stone_slot
end

--设置slot数据
function AlchemyMainItem:set_slot_data(slot, data, _nobutton)
    local cell = ItemData.New()
    cell:SetBase(data)
    if nobutton == nil then
        slot:SetAll(cell, {nobutton = false})
    else
        slot:SetAll(cell, {nobutton = _nobutton})
    end
end

--开启计时器
function AlchemyMainItem:start_timer()
    self:stop_timer()
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

--停止计时器
function AlchemyMainItem:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

--计时器tick
function AlchemyMainItem:timer_tick()
     -- for i=1,#self.data.products do
        if self.tick_index > #self.txt_time_list then
            self:stop_timer()
            return
        end


        local txt = self.txt_time_list[self.tick_index]
        local txt_desc = self.txt_list[self.tick_index]
        local left_time = self.data.products[self.tick_index].time + self.data.need_time - BaseUtils.BASE_TIME
        if left_time > 0 and left_time <= self.data.need_time then
            local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(left_time)
            if my_hour > 0 then
                txt.text = string.format(TI18N("剩余%s小时%s分"), my_hour, my_minute)
            else
                txt.text = string.format(TI18N("剩余%s分%s秒"), my_minute, my_second)
            end
            txt_desc.text = string.format("<color='%s'>%s</color>", "#017dd7", TI18N("炼制中…"))
        elseif left_time > 0 and left_time > self.data.need_time and #self.data.products == 1 then
            local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(left_time)
            if my_hour > 0 then
                txt.text = string.format(TI18N("剩余%s小时%s分"), my_hour, my_minute)
            else
                txt.text = string.format(TI18N("剩余%s分%s秒"), my_minute, my_second)
            end
            txt_desc.text = string.format("<color='%s'>%s</color>", "#017dd7", TI18N("炼制中…"))
        elseif left_time > self.data.need_time then
            txt.text = string.format("<color='%s'>%s</color>", ColorHelper.color[0], TI18N("等待中"))
        else
            txt_desc.text = ""
            txt.text = ""
            self.finish_img_list[self.tick_index]:SetActive(true)
            self.finish_img_list[self.tick_index].transform:SetAsLastSibling()

            self.parent:update_btn_state(2)

            if #self.data.products <= self.tick_index then
                --停止计时
                self:stop_timer()
            else
                --计算下一个
                self.tick_index = self.tick_index + 1
                if self.tick_index > #self.txt_time_list then
                    self:stop_timer()
                end
            end
        end
    -- end
end