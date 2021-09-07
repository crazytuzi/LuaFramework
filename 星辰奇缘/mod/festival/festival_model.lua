FestivalModel = FestivalModel or BaseClass(Model)

function FestivalModel:__init()
    self.festivalListInit = false
end

function FestivalModel:__delete()
end

function FestivalModel:CheckFestival()
    local currentYear = os.date("%Y", BaseUtils.BASE_TIME)
    local currentMonth = tonumber(os.date("%m", BaseUtils.BASE_TIME))
    local currentDay = tonumber(os.date("%d", BaseUtils.BASE_TIME))

    if self.festivalListInit ~= true then
        local cmp = function(a,b)
            if a.mount ~= b.mount then
                return a.mount < b.mount
            else
                return a.day < b.day
            end
        end
        self.festivalList = {}
        for k,v in pairs(DataFestival.data_festival) do
            if k ~= "0_0" then
                table.insert(self.festivalList, v)
            end
        end

        ----处理周三礼包
        local wednesday = DataFestival.data_festival["0_0"]
        local year = currentYear
        local month = 1
        local day = 1
        local time = os.time{year=year, month=1, day=1, hour=0}
        local weekday = tonumber(os.date("%w", time))
        local weektime = 7 * 24 * 3600

        if weekday ~= 3 then
            -- day = 10 - weekday + day
            day = day + (3 - weekday) % 7
            time = time + ((3 - weekday) % 7) * 24 * 3600
        end

        while year == currentYear do
            if DataFestival.data_festival[string.format("%s_%s", month, day)] == nil then
                local data = BaseUtils.copytab(wednesday)
                data.mount = month
                data.day = day
                table.insert(self.festivalList, data)
            end

            time = time + weektime
            month = tonumber(os.date("%m", time))
            day = tonumber(os.date("%d", time))
            if month == 1 then
                year = os.date("%Y", time)
            end
        end

        table.sort(self.festivalList, cmp)
        -- table.insert(self.festivalList, BaseUtils.copytab(festivalList[1]))
        self.festivalListInit = true
    end

    local cmpRes = BaseUtils.BinarySearch({mount = currentMonth, day = currentDay}, self.festivalList, function(a,b) return self:CmpDate(a,b) end)

    FestivalManager.Instance.isTodayFestival = (cmpRes.target ~= nil)

    if cmpRes.target ~= nil then    -- 今天是节日
        FestivalManager.Instance.festivalToGetIndex = cmpRes.index
    else
        FestivalManager.Instance.festivalToGetIndex = cmpRes.index % #self.festivalList + 1
    end
end

function FestivalModel:CmpDate(a, b)
    if a.mount == b.mount then
        if a.day < b.day then return 1
        elseif a.day == b.day then return 0
        else return -1
        end
    elseif a.mount < b.mount then return 1
    else return -1
    end
end

