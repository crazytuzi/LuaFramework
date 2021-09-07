--2016/7/18
--zzl
--暑期登录
 SummerLoginDayItem =  SummerLoginDayItem or BaseClass()

function  SummerLoginDayItem:__init(gameObject, parent, _index)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.data = nil
    self.parent = parent
    self.transform.localScale = Vector3.one

    local itr = self.gameObject.transform

    self.transform = self.gameObject.transform

    self.DayNoImage = self.transform:FindChild("DayNoImage")
    self.DayNoImageTxt = self.DayNoImage:FindChild("Text"):GetComponent(Text)

    self.reward_list = {}
    self.slot_list = {}
    for i=1,4 do
        local slot_con =self.transform:FindChild(string.format("RewardItem%s", i))
        local slot = self:create_equip_slot(slot_con)
        table.insert(self.reward_list, slot_con)
        table.insert(self.slot_list, slot)
    end

    self.TimeCon = self.transform:FindChild("TimeCon")
    self.TimeConTxt = self.TimeCon:FindChild("TxtTime"):GetComponent(Text)
    self.TimeCon.gameObject:SetActive(false)

    self.ReadyOpenText = self.transform:FindChild("ReadyOpenText").gameObject

    self.transform:FindChild("ReadyOpenText"):GetComponent(Text).text = TI18N("明日可领")
    self.GetBtnCon = self.transform:FindChild("GetBtnCon")
    self.GetBtn = self.GetBtnCon:FindChild("Button"):GetComponent(Button)
    self.GetBtnTxt = self.GetBtn.transform:FindChild("Text"):GetComponent(Text)
    self.ReceivedText = self.GetBtnCon:FindChild("ReceivedText"):GetComponent(Text)

    self.BuyBtnCon = self.transform:FindChild("BuyBtnCon")
    self.BuyBtn = self.BuyBtnCon:FindChild("Button"):GetComponent(Button)
    self.TxtCostVal1 = self.BuyBtnCon:FindChild("TxtCostVal1"):GetComponent(Text)
    self.TxtCostVal2 = self.BuyBtnCon:FindChild("TxtCostVal2"):GetComponent(Text)

    self.TimeConTxt.text = "" --限时优惠 23:55:15

    -- self.ReceivedText.text = ""
    self.TxtCostVal1.text = ""
    self.TxtCostVal2.text = ""


    self.GetBtn.onClick:AddListener(function()
        SummerManager.Instance:request14029(self.data.day)
    end)
    self.BuyBtn.onClick:AddListener(function()
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function()
            SummerManager.Instance:request14030(self.can_by_id)
        end
        confirmData.content = TI18N("是否花费钻石购买礼包？")
        NoticeManager.Instance:ConfirmTips(confirmData)
    end)

    self.cool_timer_id = 0
end

function  SummerLoginDayItem:Release()
    self:stop_cool_timer()
    if self.slot_list ~= nil then
        for k, v in pairs(self.slot_list) do
            v:DeleteMe()
        end
    end
end

function  SummerLoginDayItem:Refresh()

end

function  SummerLoginDayItem:update_my_self(_data, item_index)
    self.data = _data

    self.DayNoImageTxt.text = string.format("%s%s%s", TI18N("第"), _data.day,TI18N("天"))

    self.GetBtnTxt.text = TI18N("领取")
    self:stop_cool_timer()

    for i=1,#self.reward_list do
        self.reward_list[i].gameObject:SetActive(false)
    end

    self.TimeCon.gameObject:SetActive(false)
    self.ReadyOpenText:SetActive(false)

    if self.parent.cur_data.num < _data.day then
        self.BuyBtnCon.gameObject:SetActive(false)
        self.GetBtnCon.gameObject:SetActive(false)

        if self.parent.cur_data.num >= 10 and (self.parent.cur_data.num+2 == _data.day or self.parent.cur_data.num+1 == _data.day) then
            --现在已经累计登录大于10天
            self.ReadyOpenText:SetActive(true)
            if self.parent.cur_data.num+2 == _data.day then
                self.transform:FindChild("ReadyOpenText"):GetComponent(Text).text = TI18N("后日可领")
            elseif self.parent.cur_data.num+1 == _data.day then
                self.transform:FindChild("ReadyOpenText"):GetComponent(Text).text = TI18N("明日可领")
            end
        elseif self.parent.cur_data.num+1 == _data.day and self.parent.cur_data.num < 10  then
            self.ReadyOpenText:SetActive(true)
            self.transform:FindChild("ReadyOpenText"):GetComponent(Text).text = TI18N("明日可领")
        end

         --显示可以领取的奖励slot
        local item_index = 1
        for i=1,#_data.reward do
            local r_data = _data.reward[i]
            if r_data[4] == RoleManager.Instance.RoleData.sex or r_data[4] == 2 then
                local item = self.reward_list[item_index]


                local slot = self.slot_list[item_index]
                item_index = item_index + 1

                local base_data = DataItem.data_get[r_data[1]]
                self:set_slot_data(slot, base_data)
                item.gameObject:SetActive(true)
                slot:SetNum(r_data[3])
            end
        end
    elseif _data.has_get == false then
        --还没领取
        self.BuyBtnCon.gameObject:SetActive(false)
        self.GetBtnCon.gameObject:SetActive(true)
        self.GetBtn.gameObject:SetActive(true)

        --显示可以领取的奖励slot
        local item_index = 1
        for i=1,#_data.reward do
            local r_data = _data.reward[i]
            if r_data[4] == RoleManager.Instance.RoleData.sex or r_data[4] == 2 then
                local item = self.reward_list[item_index]


                local slot = self.slot_list[item_index]
                item_index = item_index + 1

                local base_data = DataItem.data_get[r_data[1]]
                self:set_slot_data(slot, base_data)
                item.gameObject:SetActive(true)
                slot:SetNum(r_data[3])
            end
        end
    else
        --已经领取
        self.can_by_id = 0


        for i=1,#_data.buys do
            local b_data = _data.buys[i]
            if b_data[1] <= RoleManager.Instance.RoleData.lev and b_data[2] >= RoleManager.Instance.RoleData.lev then
                if self.parent.buy_keys[b_data[3]] ~= nil then
                    if self.parent.buy_keys[b_data[3]].time + DataCampLogin.data_buy[b_data[3]].cd > BaseUtils.BASE_TIME then
                        self.can_by_id = b_data[3]
                        break
                    end
                end
            end
        end

        if self.can_by_id == 0 then
            --已经领取，且没得买
            self.BuyBtnCon.gameObject:SetActive(false)
            self.GetBtnCon.gameObject:SetActive(true)
            self.GetBtn.gameObject:SetActive(false)

            --显示可以领取的奖励slot
            local item_index = 1
            for i=1,#_data.reward do
                local r_data = _data.reward[i]
                if r_data[4] == RoleManager.Instance.RoleData.sex or r_data[4] == 2 then
                    local item = self.reward_list[item_index]


                    local slot = self.slot_list[item_index]
                    item_index = item_index + 1

                    local base_data = DataItem.data_get[r_data[1]]
                    self:set_slot_data(slot, base_data)
                    item.gameObject:SetActive(true)
                    slot:SetNum(r_data[3])
                end
            end
        else
            self.TimeCon.gameObject:SetActive(true)
            --开启计时器
            self.left_time = self.parent.buy_keys[self.can_by_id].time + DataCampLogin.data_buy[self.can_by_id].cd - BaseUtils.BASE_TIME
            self:start_cool_timer()

            --已经领取，且有得买
            self.BuyBtnCon.gameObject:SetActive(true)
            self.GetBtnCon.gameObject:SetActive(false)


            local cfg_data = DataCampLogin.data_buy[self.can_by_id]

            local item_index = 1
            for i=1,#cfg_data.reward do
                local r_data = cfg_data.reward[i]
                if r_data[4] == RoleManager.Instance.RoleData.sex or r_data[4] == 2 then
                    local item = self.reward_list[item_index]


                    local slot = self.slot_list[item_index]
                    item_index = item_index + 1

                    local base_data = DataItem.data_get[r_data[1]]
                    self:set_slot_data(slot, base_data)
                    item.gameObject:SetActive(true)
                    slot:SetNum(r_data[3])
                end
            end

            -- for i=1,#cfg_data.reward do
            --     local r_data = cfg_data.reward[i] --{20000, 0, 2}
            --     local item = self.reward_list[i]
            --     local slot = self.slot_list[item_index]
            --     local base_data = DataItem.data_get[r_data[1]]
            --     self:set_slot_data(slot, base_data)
            --     item.gameObject:SetActive(true)
            --     slot:SetNum(r_data[3])
            -- end
            --显示cost
            self.TxtCostVal1.text = tostring(cfg_data.origin_price[1][3])
            self.TxtCostVal2.text = tostring(cfg_data.cost[1][2])
        end
    end
end


--创建slot
function SummerLoginDayItem:create_equip_slot(slot_con)
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
function SummerLoginDayItem:set_slot_data(slot, data, _nobutton)
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


--------播种冷却或等待成熟的计时器
function SummerLoginDayItem:start_cool_timer()
    self:stop_cool_timer()
    self.cool_timer_id = LuaTimer.Add(0, 1000, function() self:cool_timer_tick() end)
end

function SummerLoginDayItem:stop_cool_timer()
    if self.cool_timer_id ~= 0 then
        LuaTimer.Delete(self.cool_timer_id)
        self.cool_timer_id = 0
    end
end

function SummerLoginDayItem:cool_timer_tick()
    self.left_time = self.left_time - 1
    if self.left_time >= 0 then
        local _my_date, _my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(self.left_time)
        local time_str = ""
        if _my_date > 0 then
            _my_date = _my_date >= 10 and _my_date or string.format("0%s", _my_date)
            _my_hour = _my_hour >= 10 and _my_hour or string.format("0%s", _my_hour)
            time_str = string.format("%s%s%s%s", _my_date, TI18N("天"), _my_hour, TI18N("小时"))
        elseif _my_hour > 0 then
            _my_hour = _my_hour >= 10 and _my_hour or string.format("0%s", _my_hour)
            my_minute = my_minute >= 10 and my_minute or string.format("0%s", my_minute)
            time_str = string.format("%s%s%s%s", _my_hour, TI18N("小时"), my_minute, TI18N("分"))
        else
            my_minute = my_minute >= 10 and my_minute or string.format("0%s", my_minute)
            my_second = my_second >= 10 and my_second or string.format("0%s", my_second)
            time_str = string.format("%s:%s", my_minute, my_second)
        end
        self.TimeConTxt.text = string.format("%s: %s", TI18N("剩余"), time_str)
    else
        self.parent:UpdateSummerDay(self.parent.cur_data)
        self:stop_cool_timer()
    end
end
