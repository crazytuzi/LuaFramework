healthyApi = {}

function healthyApi:getHealthyCfg()
    if self.healthy == nil then
        self.healthy = G_requireLua("healthy/healthy")
    end
    return self.healthy
end

--是否是法定节假日
function healthyApi:isHoliday()
    local healthy = self:getHealthyCfg()
    if healthy and healthy.holiday then
        local dt = os.date("*t", base.serverTime)
        local year_holiday = healthy.holiday[dt.year]
        if year_holiday and year_holiday[dt.month] then
            --特殊节日判断
            for k, day in pairs(year_holiday[dt.month].rest) do
                if type(day) == "number" then
                    if day == dt.day then
                        return true
                    end
                elseif type(day) == "table" then
                    if dt.day >= day[1] and dt.day <= day[2] then
                        return true
                    end
                end
            end
            --特殊工作日判断
            for k, day in pairs(year_holiday[dt.month].work) do
                if type(day) == "number" then
                    if day == dt.day then
                        return false
                    end
                elseif type(day) == "table" then
                    if dt.day >= day[1] and dt.day <= day[2] then
                        return false
                    end
                end
            end
        end
    end
    return self:isWeekend()
end

--获取玩家健康充值状态
function healthyApi:getHealthyRechargeStatus(money)
    if verifyApi:isOpen() == false then
        return true
    end
    if self:isUserGuest() == true then --游客账号不提升充值服务
        return false, 0
    end
    local flag, status = verifyApi:isAdult()
    if flag == true then
        return true
    end
    if status == 3 then --未满8岁不提供充值服务
        return false, 0
    end
    local healthy = self:getHealthyCfg()
    if healthy.rlimit[status] and money then
        local perPay, mPay = healthy.rlimit[status][1], healthy.rlimit[status][2]
        money = tonumber(money)
        if money > perPay then
            return false, 1, perPay
        end
        local hasPay = playerVoApi:getMonthlyPay()
        if (money + hasPay) > mPay then
            return false, 2, mPay
        end
    end
    return true
end

--检测是否已沉迷
--1：超过累计体验时间，2：处于不能登录游戏时间
function healthyApi:isHealthy()
    if verifyApi:isOpen() == false then --没有开启的话认为是健康
        do return true end
    end
    local healthy = self:getHealthyCfg()
    local olts = playerVoApi:getDailyOnlineTime()
    if self:isUserGuest() == true then --游客账号登录
        if olts >= healthy.vt then --超过体验时间
            return false, 1, healthy.vt / 3600
        end
    else
        local flag, status = verifyApi:isAdult()
        if flag == true then
            return true
        else
            local weets = G_getWeeTs(base.serverTime)
            local olHour = math.floor((base.serverTime - weets) / 3600)
            if olHour >= healthy.logout[1] or olHour < healthy.logout[2] then
                return false, 2, healthy.logout
            end
            local isRest = self:isHoliday()
            local pt = (isRest == true) and healthy.playTime[1] or healthy.playTime[2]
            if olts >= (pt * 3600) then
                return false, 1, pt
            end
        end
    end
    return true
end

function healthyApi:checkHealthyShow()
    local flag, status, arg = self:isHealthy()
    if flag == true and self.healthyView then
        self.healthyView:close()
        self.healthyView = nil
    end
    if self.showed == true or verifyApi.showed == true then
        do return end
    end
    if flag == true then --非沉迷则直接返回
        do return end
    end
    if F_stayMainUI() == false then --健康提示在游戏主基地页面展示
        do return end
    end
    local str = ""
    if status == 1 then --超过每日游戏体验时间
        str = "您今日累计在线时长已超过"..arg.."小时，请您注意身心健康，点击确定按钮即可退出游戏"
    elseif status == 2 then --超过游戏登录时间
        str = "为了您的身心健康，每日"..arg[1] .. "时至次日"..arg[2] .. "时系统不再为您提供游戏服务，给您带来的不便敬请谅解！点击确定按钮即可退出游戏"
    end
    --点击退出游戏
    local function confirm()
        F_exitGame()
    end
    self.healthyView = smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), "健康提示", str, nil, 4, nil, confirm)
    self.showed = true
end

--是否是周末
function healthyApi:isWeekend()
    local wd = F_getWeekDay(base.serverTime)
    if wd == 6 or wd == 0 then
        return true
    end
    return false
end

function healthyApi:setIsguest(flag)
    self.guest = flag
end

function healthyApi:isUserGuest()
    return self.guest
end

function healthyApi:clear()
    self.healthy = nil
    self.showed = nil
    self.healthyView = nil
    self.guest = nil
end
