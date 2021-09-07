-- @author 黄耀聪
-- @date 2016年7月13日

SevendayModel = SevendayModel or BaseClass(BaseModel)

function SevendayModel:__init()
    self.targetTab = {}
    self.discountTab = {}
    self.chargeTab = {}
    self.currentX = 1
    self.currentY = 1

    self.todayChargeData = nil
    self.halfpriceData = nil

    self.dayToIds = {}
    self.dayToCharge = {}
    for k,v in pairs(DataGoal.data_goal) do
        self.dayToIds[v.day] = self.dayToIds[v.day] or {}
        table.insert(self.dayToIds[v.day], k)
    end
    for k,v in pairs(self.dayToIds) do
        table.sort(v, function(a,b) return DataGoal.data_goal[a].sortIndex < DataGoal.data_goal[b].sortIndex end)
    end
    for k,v in pairs(DataCheckin.data_daily_charge) do
        self.dayToCharge[v.day] = self.dayToCharge[v.day] or {}
        table.insert(self.dayToCharge[v.day], k)
    end
    for i,v in ipairs(self.dayToCharge) do
        table.sort(v, function(a,b) return a<b end)
    end

    self.complete_list = nil
end

function SevendayModel:__delete()
end

function SevendayModel:OpenWindow(args)
    if BaseUtils.IsVerify == true then
        return
    end
    if self.mainWin == nil then
        self.mainWin = SevendayWindow.New(self)
    end
    self.mainWin:Open(args)
end

function SevendayModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
        -- self.mainWin = nil
    end
end

function SevendayModel:AddItems(layout, container, cloner, itemlist, datalist, classCallback, setDataCallback)
    for i=1,#datalist do
        local v = datalist[i]
        local tab = itemlist[i]
        if tab == nil then
            local index = i
            itemlist[i] = classCallback(cloner, index)
            tab = itemlist[i]
            layout:AddCell(tab.obj)
        end
        setDataCallback(tab, v)
        tab.obj:SetActive(true)
    end
    cloner:SetActive(false)

    for i=#datalist + 1,#itemlist do
        itemlist[i].obj:SetActive(false)
    end
    local w = cloner.transform.sizeDelta.x
    local h = cloner.transform.sizeDelta.y
    if #datalist > 0 then
        if layout.axis == BoxLayoutAxis.Y then
            container.sizeDelta = Vector2(w, layout.spacing + h * #datalist + layout.border * (#datalist - 1))
        else
            container.sizeDelta = Vector2(layout.spacing + h * #datalist + layout.border * (#datalist - 1), h)
        end
    else
        if layout.axis == BoxLayoutAxis.Y then
            container.sizeDelta = Vector2(w, 0)
        else
            container.sizeDelta = Vector2(0, h)
        end
    end
    -- container.anchoredPosition = Vector2.zero
end

function SevendayModel:InitData()
    self.targetTab = {}
    self.discountTab = {}
    self.chargeTab = {}

    SevendayManager.Instance:send14107()
end

function SevendayModel:GetCurrentDay()
    local days = #BibleManager.Instance.servenDayData.seven_day
    local y = tonumber(os.date("%y", BaseUtils.BASE_TIME))
    local m = tonumber(os.date("%m", BaseUtils.BASE_TIME))
    local d = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    local day8 = BibleManager.Instance.servenDayData.seven_day[8]
    if day8 ~= nil and (day8.year ~= y or day8.month ~= m or day8.day ~= d) then
        days = 8
    end
    return days, day8
end

--获取已完成的目标数量
function SevendayModel:GetFinishTargetNum()
    local num = 0
    if self.targetTab ~= nil then
        for k, v in pairs(self.targetTab) do
            if (v.finish == 1 or v.finish == 2) and (v.id < 810000 or v.id > 810006) then
                num = num + 1
            end
        end
    end
    return num
end

--检查七天登陆图标是否需要显示红点
function SevendayModel:CheckShowRedPoint()
    local redDic = SevendayManager.Instance.redPointDic
    local days, day8 = self:GetCurrentDay()
    for key_day=1,7 do
        -- 旧逻辑，恕我无知啊，实在看不懂
        -- local res = redDic[k]
        -- local state = false
        -- if res ~= nil then
        --     local i = 1
        --     while res ~= 0 do
        --         if res % 2 == 1 then
        --             state = true
        --             break
        --         end
        --         res = math.floor(res / 2)
        --         i = i + 1
        --     end
        -- end

        local state = false
        if days >= key_day then
            --达到登陆天数
            if (BibleManager.Instance.servenDayData.seven_day[key_day] == nil or BibleManager.Instance.servenDayData.seven_day[key_day].rewarded == 0) then
                state = true
            end


            --检查福利目标是否达成，有得领取
            for k, v in pairs(DataGoal.data_goal) do
                if v.tabId == 15 and v.day == key_day then
                    --检查福利里面目标是否达成，有得领取
                    local protoData = self.targetTab[v.id]
                    if protoData ~= nil and protoData.finish == 1 and protoData.rewarded ~= 1 then
                        state = true
                    end
                end
            end

            if state == false then
                local days, day8 = self:GetCurrentDay()
                if self.dayToCharge[key_day] ~= nil and self.todayChargeData ~= nil then
                    --检查充值福利是否达成，有得领取
                    for i,v in ipairs(self.dayToCharge[key_day]) do
                        if key_day == days then
                            --是不是当天的
                            if self.todayChargeData.day_charge >= DataCheckin.data_daily_charge[v].charge then
                                --充值数据满足
                                if self.chargeTab[v] == nil or self.chargeTab[v].rewarded == 0 then
                                    --还没领取
                                    state = true
                                    break
                                end
                            end
                        end
                    end
                end
            end

            -------------------检查目标是否有得领取
            if state == false then
                for i = 2, 3 do
                    local datalist = {}
                    if self.dayToIds[key_day] ~= nil then
                        for _,v in pairs(self.dayToIds[key_day]) do
                            if DataGoal.data_goal[v].tabId == DataGoal.data_tab[key_day].effect[i-1].tabId then
                                table.insert(datalist, v)
                            end
                        end
                        for j=1,#datalist do
                            local protoData = self.targetTab[datalist[j]]
                            if protoData ~= nil and protoData.finish == 1 and protoData.rewarded ~= 1 then
                                state = true
                                break
                            end
                        end
                    end
                end
            end
        end
        if state then
            return state
        end
    end
    return false
end