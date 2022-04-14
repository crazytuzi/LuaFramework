RealNameModel = RealNameModel or class("RealNameModel", BaseModel)

function RealNameModel:ctor()
    RealNameModel.Instance = self
    self:Reset()

end

function RealNameModel:Reset()
    if self.timeDown then
        GlobalSchedule:Stop(self.timeDown)
        self.timeDown = nil
    end
    if self.timeDown2 then
        GlobalSchedule:Stop(self.timeDown2)
        self.timeDown2 = nil
    end
    if self.OnLineSchedule then
        GlobalSchedule:Stop(self.OnLineSchedule)
        self.OnLineSchedule = nil
    end
    self.serverTime = 0
    self.isRegisterd = true -- 是否实名认证了
    self.isFrist = true
    self.OnlineTime = 0 -- 在线时长
    self.isAdult = false
    self.isShowTips = true

    self.playInfo = nil
    self.realNameInfo = nil
    self.curCharge = nil
    self.age = 0
    self.islimitCharge = false --是否开启最大充值限制
    self.limitTime = String2Table(Config.db_game["realname_timeout"].val)[1]

end

function RealNameModel:GetInstance()
    if RealNameModel.Instance == nil then
        RealNameModel()
    end
    return RealNameModel.Instance
end


function RealNameModel:dctor()
    if self.timeDown then
        GlobalSchedule:Stop(self.timeDown)
        self.timeDown = nil
    end

    if self.timeDown2 then
        GlobalSchedule:Stop(self.timeDown2)
        self.timeDown2 = nil
    end
end
--是否满足实名条件
function RealNameModel:IsRealNameCondition(data)
   local role = RoleInfoModel.GetInstance():GetMainRoleData()
    self.isRegisterd = data.is_registerd
    self.isFrist = data.is_first
    self.OnlineTime = data.online_time
    self.isAdult = data.is_adult
    if self.isRegisterd then  --已经注册了
        GlobalEvent:Brocast(RealNameEvent.RealNameShowIcon,false)
        if self.isAdult == false then  --未成年
            if self.OnlineTime < self.limitTime then
                self:StartCountDown2()
            else
               -- GlobalEvent:Brocast(RealNameEvent.OpenRealNamePanel,nil)
                local function btn_func2()
                   -- Application.Quit()
                end
                Dialog.ShowOne("Tip","You have been online over 5 hours and in-game income will be cut by half. As the system deem that they may need proper rest to ensure a healthy gaming environment.","Confirm",btn_func2)
            end
        end
    else  --未注册
        if self.timeDown then
            GlobalSchedule:Stop(self.timeDown)
            self.timeDown = nil
        end
        if self.OnlineTime < self.limitTime then
            self:StartCountDown()
        end
        GlobalEvent:Brocast(RealNameEvent.RealNameShowIcon,true)
        --if self.isFrist  then --首次
        --    if role.level >= 1 or self.OnlineTime >= 10800 then
        --      --  GlobalEvent:Brocast(RealNameEvent.OpenRealNamePanel,nil)
        --        GlobalEvent:Brocast(RealNameEvent.RealNameShowIcon,true)
        --    end
        --else
        --    GlobalEvent:Brocast(RealNameEvent.RealNameShowIcon,true)
        --end
    end
end



function RealNameModel:StartCountDown()
  --  18000 - self.OnlineTime
    self.curTime = os.time() + (self.limitTime - self.OnlineTime)
    self.timeDown = GlobalSchedule:Start(handler(self, self.StartTimeConutDown),0.2,-1)
end

function RealNameModel:StartTimeConutDown()
    --self.OnlineTime = self.OnlineTime + 1
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.curTime);
    if table.isempty(timeTab) then
        if self.timeDown then
            GlobalSchedule:Stop(self.timeDown)
            self.timeDown = nil
        end
       -- RealNameController:GetInstance():RequestRealNameInfo()
        local function btn_func2()
        end
        Dialog.ShowOne("Tip","You have been online over 5 hours and in-game income will be cut by half. As the system deem that they may need proper rest to ensure a healthy gaming environment.","Confirm",btn_func2)
    else
        --dump(timeTab)
        --print2(self.OnlineTime)
        local sce = 0
        if timeTab.hour then
            sce = timeTab.hour * 3600
        end
        if timeTab.min then
            sce = sce + timeTab.min*60
        end
        if timeTab.sec then
            sce = sce+timeTab.sec
        end
        if sce <= 7200 and self.isShowTips then
            self.isShowTips = false
            local function btn_func2()
                -- Application.Quit()
            end
            Dialog.ShowOne("Tip","You have been online over 3 hours and in-game income will be cut by half when over 5 hours. As the system deem that they may need proper rest to ensure a healthy gaming environment.","Confirm",btn_func2)
        end
    end


   -- print2(self.OnlineTime)
   -- if  self.OnlineTime > 10800 then  --在线时间
   --     if self.timeDown then
   --         GlobalSchedule:Stop(self.timeDown)
   --         self.timeDown = nil
   --     end
   --     RealNameController:GetInstance():RequestRealNameInfo()
   -- end
end

function RealNameModel:StartCountDown2()
    self.curTime2 = os.time() + (self.limitTime - self.OnlineTime)
    self.timeDown2 = GlobalSchedule:Start(handler(self, self.StartTimeConutDown2),0.2,-1)
end

function RealNameModel:StartTimeConutDown2()
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.curTime2);
    if table.isempty(timeTab) then
        if self.timeDown2 then
            GlobalSchedule:Stop(self.timeDown2)
            self.timeDown2 = nil
        end
        local function btn_func2()
        end
        Dialog.ShowOne("Tip","You have been online over 5 hours and in-game income will be cut by half. As the system deem that they may need proper rest to ensure a healthy gaming environment.","Confirm",btn_func2)
    else
        local sce = 0
        if timeTab.hour then
            sce = timeTab.hour * 3600
        end
        if timeTab.min then
            sce = sce + timeTab.min*60
        end
        if timeTab.sec then
            sce = sce+timeTab.sec
        end
        if sce <= 7200 and self.isShowTips then
            self.isShowTips = false
            local function btn_func2()
                    -- Application.Quit()
            end
            Dialog.ShowOne("Tip","You have been online over 3 hours and in-game income will be cut by half when over 5 hours. As the system deem that they may need proper rest to ensure a healthy gaming environment.","Confirm",btn_func2)
        end
       -- logError(sce)
        --if timeTab.hour == 1 and self.isShowTips then
        --    self.isShowTips = false
        --    local function btn_func2()
        --        -- Application.Quit()
        --    end
        --    Dialog.ShowOne("提示","今天您已在线超过3小时，超过5个小时收益将会减半，请注意休息，合理健康游戏！","确定",btn_func2)
        --end
    end

end

function RealNameModel:DealRealNameInfo(data)
    self.realNameInfo = data
    self.isAdult = data.is_adult
    self.age = data.age
    self.isRegisterd = data.is_registerd
    self.curCharge = data.charge
    --self.charge =  data.charge
    self.islimitCharge = data.limit_charge
    self.OnlineTime = data.online_time
    local boo = false
    if data.is_registerd then --实名认证了
        if not data.is_adult then  --未成年 纳入防沉迷
            boo = true
        end
    else --未实名 弹窗
        if self.playInfo.retCode == "AUTHENTICATION_NEVER" then
            GlobalEvent:Brocast(RealNameEvent.OpenRealNamePanel,data)
        else
            boo = true
        end
    end
    if boo then -- 防沉迷
        self:OpenIndulgence()
    end
end
--开启防沉迷
function RealNameModel:OpenIndulgence()
    local isOnline = self.realNameInfo.online_notice
    local isCharge = self.realNameInfo.limit_charge
    local isReduce = self.realNameInfo.redece_gain

    --self.isAdult = data.is_adult
    --self.age = data.age
    --self.isRegisterd = data.is_registerd

    if isOnline then --是否开启在线提醒
        --判断年龄

        self:StartOnLineTips()
    end
    if isCharge then --是否开启充值限制
        local cfg = self:GetCfgCharge()
        self.maxCharge = cfg.max_charge --最大充值
        self.perCharge = cfg.per_charge  --单次充值
    end
    if isReduce then --是否开启减少收益

    end
    Notify.ShowText("You are now affected by anti-addiction measures")
    --logError("开启防沉迷 age:"..self.age)

end

function RealNameModel:StartOnLineTips()
    local cfg = Config.db_realname_time
    --self.maxTime = nil
    --for i, v in pairs(cfg) do
    --    if self.maxTime == nil then
    --        self.maxTime = i
    --    end
    --    if self.maxTime < i then
    --        self.maxTime = i
    --    end
    --end
    --logError(self.maxTime)
    self.maxTime = cfg[#cfg].time
    self.curCfg = cfg[#cfg]
    if self.OnlineTime >= self.maxTime then  --十五分钟弹一次
        self.countTime = (os.time() + 900)
        self.OnlineTime = self.OnlineTime + 900
        self.curCfg = cfg[#cfg]
    else--
        for i = 1, #cfg do
            if self.OnlineTime < cfg[i].time then
                self.countTime = os.time() + (cfg[i].time - self.OnlineTime)
                self.OnlineTime = cfg[i].time
                self.curCfg = cfg[i]
                break
            end
        end
    end
    if self.OnLineSchedule then
        GlobalSchedule:Stop(self.OnLineSchedule)
        self.OnLineSchedule = nil
    end
    self.OnLineSchedule = GlobalSchedule:Start(handler(self, self.StartOnLineCountDown),0.5,-1)
end

function RealNameModel:StartOnLineCountDown()
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.countTime);
    if table.isempty(timeTab) then
        if self.OnLineSchedule then
            GlobalSchedule:Stop(self.OnLineSchedule)
            self.OnLineSchedule = nil
        end
        if self.curCfg then
            local function btn_func2()

            end
            Dialog.ShowOne("Tip",self.curCfg.des,"Confirm",btn_func2)
        end
        self:StartOnLineTips()
    else
        local sce = 0
        if timeTab.hour then
            sce = timeTab.hour * 3600
        end
        if timeTab.min then
            sce = sce + timeTab.min*60
        end
        if timeTab.sec then
            sce = sce+timeTab.sec
        end
       -- logError(sce)
    end

end

function RealNameModel:IsNeedShowTips(time)
    local cfg = Config.db_realname_time
    for i = 1, #cfg do
        if time == cfg[i].time then
            return cfg[i]
        end
    end
    return nil
end



function RealNameModel:GetCfgCharge()
   -- self.age
    local cfg = Config.db_realname
    for i, v in pairs(cfg) do
        if self.age >= v.min and self.age <= v.max then
            return v
        end
    end
    return nil
end

--是否可以充值
function RealNameModel:IsCanCharge(price)
    if not self.realNameInfo then
        return true
    end
    if  not self.realNameInfo.limit_charge then
        return true
    end
    if self.isAdult then
        return true
    end
    --self.maxCharge
    -- self.realNameInfo.charge --累计充值
    if  self.curCharge +  price >  self.maxCharge then
        return false,self.maxCharge
    end
    return true
end

function RealNameModel:IsCanOneCharge(price)
    if not self.realNameInfo then
        return true
    end
    if  not self.realNameInfo.limit_charge then
        return true
    end
    if self.isAdult then
        return true
    end
    if price > self.perCharge then
        return false,self.perCharge
    end
    return true
end

function RealNameModel:StopSchedule()

    if self.OnLineSchedule then
        GlobalSchedule:Stop(self.OnLineSchedule)
        self.OnLineSchedule = nil
    end
end



