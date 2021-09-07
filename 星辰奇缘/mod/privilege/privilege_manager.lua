PrivilegeManager = PrivilegeManager or BaseClass(BaseManager)

function PrivilegeManager:__init()
    if PrivilegeManager.Instance ~= nil then
        Log.Error("不可重复实例化 PrivilegeManager")
        return
    end

    PrivilegeManager.Instance = self
    self.lev = nil
    self.charge = 0
    self.hasReceivePrivileges = {}
    self.model = PrivilegeModel.New()

    self.isLookLimitTimePrivilege = false
    self.limitTimePrivilegeInfo = nil

    self.privilegeDic = {}
    for k,v in pairs(DataPrivilege.data_privilege) do
        if self.privilegeDic[v.lev] == nil then self.privilegeDic[v.lev] = {} end
        self.privilegeDic[v.lev][v.type] = v
    end

    self:InitHandler()

    self.grow_type = 980

    --限时特惠，特殊处理时间
    self.startMonth = 5
    self.startDay = 10
    self.endMonth= 1 --5
    self.endDay = 1 --12

    self.canReceiveMonthly = false
    self.monthlyExcessDays = 0

    self.growthFundEvent = EventLib.New()
    self.updateRecharge = EventLib.New()
    self.updateFirstRecharge = EventLib.New()
    self.updateIcon = EventLib.New()
    self.updateIconSecond = EventLib.New()

end

function PrivilegeManager:__delete()
end

function PrivilegeManager:InitHandler()
    self:AddNetHandler(9925, self.on9925)
    self:AddNetHandler(9926, self.on9926)
    self:AddNetHandler(9927, self.on9927)
    self:AddNetHandler(9931, self.on9931)
    self:AddNetHandler(9932, self.on9932)
    self:AddNetHandler(9935, self.on9935)
    self:AddNetHandler(9936, self.on9936)

    EventMgr.Instance:AddListener(event_name.trace_quest_loaded, function()
        -- self:MonthlyCardTrace()
        self.isquestLoaded = true
        if self.monthlyExcessDays > 0 then
            self:MonthlyCardTrace()
        else
            self:send9932()
        end
    end)

    EventMgr.Instance:AddListener(event_name.role_level_change, function() self:GrowthFundCheckRed() end)
end

function PrivilegeManager:send9925()
    -- print("发送了协议9925")
    Connection.Instance:send(9925, {})
end

function PrivilegeManager:on9925(data)
    -- BaseUtils.dump(data, "接收9925")
    if self.lev ~= nil and self.lev ~= data.lev then
        self.lev = data.lev
        EventMgr.Instance:Fire(event_name.privilege_lev_change, self.lev)
    end
    self.lev = data.lev
    self.charge = data.charge
    self.authsfz_charge = data.authsfz_charge or 0

    self.hasReceivePrivileges = {}
    for _,v in pairs(data.list) do
        if v ~= nil then
            self.hasReceivePrivileges[v.val] = true
        end
    end

    local canReceive = false
    if self.lev ~= nil then
        -- for i=1,self.lev do
        for _,v in pairs(DataPrivilege.data_section) do
            if v.lev <= self.lev and self.hasReceivePrivileges[v.lev] == nil then
                canReceive = true
                break
            end
        end
    end
    if canReceive then
        ShopManager.Instance.redPoint[3][2] = true
        ShopManager.Instance.onUpdateRT:Fire()
        ShopManager.Instance.onUpdateRedPoint:Fire()
    end

    self.updateRecharge:Fire()
    self.updateIcon:Fire()
end

function PrivilegeManager:send9926(lev)
    Connection.Instance:send(9926, {lev = lev})
end

function PrivilegeManager:on9926(data)
    --BaseUtils.dump(data, "接收9926")
    if data.flag == 1 then
        self.hasReceivePrivileges[data.lev] = true
    end
    ShopManager.Instance.onUpdateRT:Fire()
    self.updateFirstRecharge:Fire()
    self.updateIconSecond:Fire()
end

function PrivilegeManager:send9927()
    -- print("PrivilegeManager:send9927()--"..debug.traceback())
    Connection.Instance:send(9927, {})
end

function PrivilegeManager:on9927(data)
    --BaseUtils.dump(data, "接收9927")
    self.limitTimePrivilegeInfo = data
    EventMgr.Instance:Fire(event_name.limit_time_privilege_change)
    -- BibleManager.Instance:sendProtoForCheckRedPoint()

    self:GrowthFundCheckRed()
    self:CheckLimitTimePrivilegeState()
end

function PrivilegeManager:GrowthFundCheckRed()
    self.growthFundCanReceive = false
    local data = self.growthFundStatus or {}
    if data.gold == 1980 or data.gold == 980 then
        self.growthFundCanReceive = true
        local tab = {}
        local lev = RoleManager.Instance.RoleData.lev
        for i,v in ipairs(DataGrowthFund.data_growth) do
            if lev < v.lev then
                tab[i] = true
            else
                tab[i] = false
            end
        end
        for i,v in ipairs(data.rewards) do
            tab[v.id] = true
        end
        local b = false
        for i,v in ipairs(tab) do
            b = b or (v ~= true)
        end
        BibleManager.Instance.redPointDic[1][18] = b
    else
        BibleManager.Instance.redPointDic[1][18] = false
    end
    BibleManager.Instance.onUpdateRedPoint:Fire()
end

function PrivilegeManager:CheckLimitTimePrivilegeState()
    if self.limitTimePrivilegeInfo ~= nil and self.limitTimePrivilegeInfo.flag == 1 then
        if self.isLookLimitTimePrivilege == false then
            self.isLookLimitTimePrivilege = true
            BibleManager.Instance.redPointDic[1][9] = true
        end
        local cfg_data = DataSystem.data_daily_icon[204]
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        if BaseUtils.IsInTimeRange(PrivilegeManager.Instance.startMonth,PrivilegeManager.Instance.startDay,PrivilegeManager.Instance.endMonth,PrivilegeManager.Instance.endDay) == false then --限时特惠
            iconData.iconPath = cfg_data.res_name
            -- if SettingManager.Instance.model.gaWin ~= nil then
            --     table.insert(SettingManager.Instance.model.funcTab, function() self:OnLimitTimeOpen() end)
            -- else
            --     self:OnLimitTimeOpen()
            -- end
            BibleManager.Instance:AutoPopWin(9)
        else
            iconData.iconPath = "204_1"
        end
        iconData.clickCallBack = function()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1, 9})
        end
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        iconData.timestamp = self.limitTimePrivilegeInfo.max_time - (self.limitTimePrivilegeInfo.keep_time + (BaseUtils.BASE_TIME - math.max(self.limitTimePrivilegeInfo.login_time, self.limitTimePrivilegeInfo.start_time))) + Time.time - 1800
        iconData.timeoutCallBack = timeout_callback
        iconData.timeoutCallBack = function()
            MainUIManager.Instance:DelAtiveIcon2(204)
        end
        MainUIManager.Instance:AddAtiveIcon2(iconData)
    else
        BibleManager.Instance.redPointDic[1][9] = false
        MainUIManager.Instance:DelAtiveIcon2(204)
    end
end

--  返回值 1 表示未达成
--  返回值 2 表示未领取
--  返回值 3 表示已领取
function PrivilegeManager:GetPrivilegeState(lev)
    if self.charge < DataPrivilege.data_section[lev].min then
        return 1
    elseif self.hasReceivePrivileges[lev] ~= true then
        return 2
    else
        return 3
    end
end

function PrivilegeManager:GetValueByType(type)
    local val = {}
    local args = {}

    for k,v in pairs(self.privilegeDic) do
        if v[type] ~= nil and self.lev ~= nil and v[type].lev ~= nil and v[type].lev <= self.lev then
            table.insert(args, v[type].args)
            table.insert(val, v[type].val)
        end
    end

    -- local max = 0
    -- for i,v in ipairs(val) do
    --     if v > max then max = v end
    -- end

    return #val,args
end

-- 领取月卡奖励
function PrivilegeManager:send9931()
  -- print("发送9931")
    Connection.Instance:send(9931, {})
end

function PrivilegeManager:on9931(data)
    --BaseUtils.dump(data, "接收9931")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 月卡状态
function PrivilegeManager:send9932()
    Connection.Instance:send(9932, {})
end

function PrivilegeManager:on9932(data)
    --BaseUtils.dump(data, "<color=#00FF00>接收9932</color>")
    self.canReceiveMonthly = (data.reward == 1)
    self.monthlyExcessDays = data.day

    if self.isquestLoaded then
        self:MonthlyCardTrace()
    end

    if self.monthlyExcessDays > 0 then
        GivepresentManager.Instance.MaxGiveNum = 6
    else
        GivepresentManager.Instance.MaxGiveNum = 5
    end

    EventMgr.Instance:Fire(event_name.monthly_gift_change)
end

function PrivilegeManager:MonthlyCardTrace()
    local gold_bind = 0
    for _,v in pairs(DataMonthCard.data_get_reward) do
        gold_bind = v.gold_bind
        break
    end
    if self.canReceiveMonthly then
        if self.monthlyTraceDataId == nil or MainUIManager.Instance.mainuitracepanel.traceQuest.customTab[self.monthlyTraceDataId] == nil then
            local tab = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom()
            self.monthlyTraceDataId = tab.customId
            tab.title = TI18N("<color='#FF8800'>[奖励]月度礼包</color>")
            tab.Desc = string.format(TI18N("领取月度礼包<color='#FFFF00'>%s金币</color>"), tostring(gold_bind))
            -- tab.callback = function() self:send9931() end
            tab.callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {4}) end
            tab.type = CustomTraceEunm.Type.MonthlyCard
        end
        ShopManager.Instance.redPoint[4] = ShopManager.Instance.redPoint[4] or {}
        ShopManager.Instance.redPoint[4][1] = true
        BibleManager.Instance.redPointDic[1] = BibleManager.Instance.redPointDic[1] or {}
        BibleManager.Instance.redPointDic[1][17] = true
        MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(MainUIManager.Instance.mainuitracepanel.traceQuest.customTab[self.monthlyTraceDataId].data)
    else
        ShopManager.Instance.redPoint[4] = ShopManager.Instance.redPoint[4] or {}
        ShopManager.Instance.redPoint[4][1] = false
        BibleManager.Instance.redPointDic[1] = BibleManager.Instance.redPointDic[1] or {}
        BibleManager.Instance.redPointDic[1][17] = false
        if self.monthlyTraceDataId ~= nil then
            MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.monthlyTraceDataId)
            self.monthlyTraceDataId = nil
        end
    end

    ShopManager.Instance.onUpdateRedPoint:Fire()
    BibleManager.Instance.onUpdateRedPoint:Fire()
end

function PrivilegeManager:OnLimitTimeOpen()
    if BibleManager.Instance.model.bibleWin == nil or BibleManager.Instance.model.bibleWin.isOpen ~= true then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1, 9})
    end
end

function PrivilegeManager:RequestInitData()
    self.lev = nil
    self.growthFundCanReceive = false
    self:send9925()
    self:send9935()
end

-- 成长基金状态
function PrivilegeManager:send9935()
    Connection.Instance:send(9935, {})
end

function PrivilegeManager:on9935(data)
    -- BaseUtils.dump(data, "<color='#ffff00'>on9935</color>")
    self.growthFundStatus = data
    self.growthFundEvent:Fire()

    self.growthFundCanReceive = false

    if data.gold == 1980 or data.gold == 980 then
        self.growthFundCanReceive = true
        local tab = {}
        local lev = RoleManager.Instance.RoleData.lev
        for i = 1,8 do
            local key = string.format("%s_%s",data.gold,i)
            local basedata = DataGrowthFund.data_growth[key]
            if lev < basedata.lev then
                tab[i] = true
            else
                tab[i] = false
            end
        end
        for i,v in ipairs(data.rewards) do
            tab[v.id] = true
        end
        local b = false
        for i,v in ipairs(tab) do
            b = b or (v ~= true)
        end
        BibleManager.Instance.redPointDic[1][18] = b
    else
        BibleManager.Instance.redPointDic[1][18] = false
    end
    BibleManager.Instance.onUpdateRedPoint:Fire()
end

-- 成长基金领取
function PrivilegeManager:send9936(id)
    Connection.Instance:send(9936, {id = id})
end

function PrivilegeManager:on9936(data)
    -- BaseUtils.dump(data,"on9936")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        local key = string.format("%s_%s",self.grow_type,data.id)
        NoticeManager.Instance:FlyWithScale({item = {base_id = DataGrowthFund.data_growth[key].reward[1][1]}, begin_pos = Vector3(480, -270, 0), end_pos = Vector3(845, -492, 0), appear_time = 0.4, diappear = 0.5, moving_time = 0.3, stop_time = 0.3})
    end
end

