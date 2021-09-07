-- @author 黄耀聪
-- @date 2016年7月13日

SevendayManager = SevendayManager or BaseClass(BaseManager)

function SevendayManager:__init()
    if SevendayManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    SevendayManager.Instance = self
    self.model = SevendayModel.New()

    self.onUpdateTarget = EventLib.New()
    self.onUpdateOther = EventLib.New()
    self.onUpdateCharge = EventLib.New()
    self.onUpdateDiscount = EventLib.New()
    self.onUpdateRed = EventLib.New()
    self.onUpdateTime = EventLib.New()
    self.redPointDic = {}   -- 用位来记录那个页签有红点，二进制数000表示三个水平页签都没有红点
    self.lastDays = 0

    self:InitHandler()
end

function SevendayManager:__delete()
end

function SevendayManager:InitHandler()
    self:AddNetHandler(10235, self.on10235)
    self:AddNetHandler(10236, self.on10236)
    self:AddNetHandler(10237, self.on10237)
    self:AddNetHandler(10238, self.on10238)
    self:AddNetHandler(10239, self.on10239)
    self:AddNetHandler(10240, self.on10240)
    self:AddNetHandler(10241, self.on10241)
    self:AddNetHandler(10242, self.on10242)
    self:AddNetHandler(14104, self.on14104)
    self:AddNetHandler(14105, self.on14105)
    self:AddNetHandler(14106, self.on14106)

    self:AddNetHandler(14107, self.on14107)

    BibleManager.Instance.onUpdateSevenday:AddListener(function() self:CheckRedPoint() end)
    EventMgr.Instance:AddListener(event_name.mainui_btn_init, function() self:send10240() end)
    EventMgr.Instance:AddListener(event_name.seven_day_charge_upgrade, function() self:CheckRedPoint() end)
end

function SevendayManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

-- 更新目标进度
function SevendayManager:send10235()
  -- print("发送10235")
    Connection.Instance:send(10235, {})
end

function SevendayManager:on10235(data)
    -- BaseUtils.dump(data)

    local model = self.model
    model.targetTab = model.targetTab or {}
    for _,gold in ipairs(data.goal_list) do
        model.targetTab[gold.id] = model.targetTab[gold.id] or {}
        for k,v in pairs(gold) do
            model.targetTab[gold.id][k] = v
        end
        local tab = model.targetTab[gold.id]
        tab.rankValue = (tab.rewarded or 0) * 16 + (1 - tab.finish or 0) * 4
    end
    self.onUpdateTarget:Fire()
    self.onUpdateOther:Fire()
    self:CheckRedPoint()
end

-- 领取目标奖励
function SevendayManager:send10236(day, id)
  -- print("发送10236")
    local dat = {day = day, id = id}
    -- BaseUtils.dump(dat)
    Connection.Instance:send(10236, dat)
end

function SevendayManager:on10236(data)
    -- BaseUtils.dump(data, "接收10236")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 同步目标奖励领取情况
function SevendayManager:send10237()
  -- print("发送10237")
    Connection.Instance:send(10237, {})
end

function SevendayManager:on10237(data)
    -- BaseUtils.dump(data, "接收10237")

    local model = self.model
    model.targetTab = model.targetTab or {}
    for _,v in ipairs(data.day_reward) do
        -- if model.targetTab[v.quest_id].rewarded == nil then
        --     table.insert(idList, v.quest_id)
        -- end
        model.targetTab[v.quest_id].rewarded = 1
        local tab = model.targetTab[v.quest_id]
        tab.rankValue = (tab.rewarded or 0) * 16 + (tab.finish or 0) * 4
    end
    self.onUpdateTarget:Fire()
    self:CheckRedPoint()
end

-- 推送折扣数据
function SevendayManager:send10238()
    Connection.Instance:send(10238, {})
end

function SevendayManager:on10238(data)
    -- BaseUtils.dump(data, "<color=#00ff00>接收10238</color>")
    local model = self.model
    model.discountTab = model.discountTab or {}

    local tab = {}
    for id,v in pairs(model.discountTab) do
        if v ~= nil then
            table.insert(tab, id)
        end
    end
    for _,id in pairs(tab) do model.discountTab[id] = nil end

    for _,v in ipairs(data.discount) do
        model.discountTab[v.discount_id] = 1
    end
    self.onUpdateDiscount:Fire()
end

-- 购买半价折扣
function SevendayManager:send10239(id)
  -- print("发送10239 " .. tostring(id))
    Connection.Instance:send(10239, {id = id})
end

function SevendayManager:on10239(data)
    -- BaseUtils.dump(data, "接收10239")
    if data.result == 1 then -- 成功
    elseif data.result == 2 then -- 需要充值
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
        NoticeManager.Instance:FloatTipsByString(TI18N("今日充值任意金额即可领取哦{face_1,3}"))
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

-- 七天充值信息
function SevendayManager:send14104()
  -- print("发送14104")
    Connection.Instance:send(14104, {})
end

function SevendayManager:on14104(data)
    -- BaseUtils.dump(data, "接收14104")
    local model = self.model
    model.chargeTab = model.chargeTab or {}
    for _,v in ipairs(data.charge_day) do
        model.chargeTab[v.rewarded] = BaseUtils.copytab(v)
    end
    self.onUpdateCharge:Fire()
    self:CheckRedPoint()
end

-- 领取七天充值
function SevendayManager:send14105(order)
  -- print("发送14105")
    Connection.Instance:send(14105, {order = order})
end

function SevendayManager:on14105(data)
    -- BaseUtils.dump(data, "接收14105")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--获取当日充值金额
function SevendayManager:send14106()
    Connection.Instance:send(14106, {})
end

--获取当日充值金额
function SevendayManager:on14106(data)
    -- BaseUtils.dump(data)
    self.model.todayChargeData = data
    EventMgr.Instance:Fire(event_name.seven_day_charge_upgrade)
end

--获取今日打折剩余数量
function SevendayManager:send14107()
    Connection.Instance:send(14107, {})
end

--获取今日打折剩余数量
function SevendayManager:on14107(data)
    -- BaseUtils.dump(data)
    self.model.halfpriceData = data
    EventMgr.Instance:Fire(event_name.seven_day_halfprice_upgrade)
end

function SevendayManager:InitData()
    self.model:InitData()
    self:send14104()
    self:send10235()
    self:send10237()
    self:send10238()
    self:send10240()
    self:send14106()
end

-- 获取今天充值金额
function SevendayManager:GetRechargeCount()
    return (self.model.todayChargeData or {}).day_charge or 0
end

function SevendayManager:CheckRedPoint()
    local model = self.model
    local lev = RoleManager.Instance.RoleData.lev
    self.redPointDic = {}

    if BibleManager.Instance.servenDayData == nil then
        return
    end
    for i,v in ipairs(BibleManager.Instance.servenDayData.seven_day) do
        table.insert(self.redPointDic, 0)
    end

    local red = false
    for i,_ in ipairs(self.redPointDic) do
        local res = 0
        local bool = false
        if model.dayToCharge[i] ~= nil and (self.lastDays == nil or self.lastDays < 15) then
            for _,id in pairs(model.dayToCharge[i]) do
                if model.chargeTab[id] == nil and DataCheckin.data_daily_charge[id].charge <= PrivilegeManager.Instance.charge then
                    bool = true
                    break
                end
            end
        end
        if BibleManager.Instance.servenDayData.seven_day[i].rewarded == 0 then
            bool = true
        end
        if bool then
            res = 1
        else
            res = 0
        end

        if model.dayToIds[i] ~= nil and (self.lastDays == nil or self.lastDays < 15) then
            for _,id in pairs(model.dayToIds[i]) do
                if model.targetTab[id] ~= nil and (model.targetTab[id].finish == 1 and model.targetTab[id].rewarded ~= 1) then
                    res = res + 2
                    break
                end
            end
        end
        self.redPointDic[i] = res

        red = red or (res > 0)
    end

    if red == false then
        if self.model.complete_list ~= nil then
            local state = false
            local finishNum = self.model:GetFinishTargetNum()
            for i = 1, #DataGoal.data_get_complete do
                local hasNotGet = true --还没领取奖励
                local cfgData = DataGoal.data_get_complete[i]
                for k, v in pairs(self.model.complete_list) do
                    if v.count == cfgData.count then
                        hasNotGet = false --已经领取了
                        break
                    end
                end
                if hasNotGet then
                    if finishNum < cfgData.count then
                        hasNotGet = false --次数不够
                    end
                end
                if hasNotGet then
                    state = hasNotGet
                    break
                end
            end
            red = state
        end
    end

    local iconData = DataSystem.data_icon[31]
    if MainUIManager.Instance.MainUIIconView ~= nil then
        local state = self.model:CheckShowRedPoint()
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(31, state)
        local tab = nil
        for i,v in ipairs(MainUIManager.Instance.MainUIIconView.icon_type6_list) do
            if v.id == 31 then
                tab = v
                break
            end
        end
        if self:CheckShow() then
            if self.model.complete_list == nil then
                self:send10242()
            end
            if tab ~= nil then
                tab.lev = 20
            end
        else
            if tab ~= nil then
                tab.lev = 999
            end
        end
        MainUIManager.Instance.MainUIIconView:refresh_icon()
        -- MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(31, not self:CheckShow())
    end



    local  isShowOtherRed = false
    local hasGotList = {}
    if self.model.complete_list ~= nil then
        for i = 1, #DataGoal.data_get_complete do
            local cfgData = DataGoal.data_get_complete[i]
            local hasNotGet = true --还没有领取这个位置的奖励
            for k, v in pairs(self.model.complete_list) do
                if v.count == cfgData.count then
                    -- BaseUtils.SetGrey(self.progBarBoxImgList[i], true)
                    hasGotList[i] = true
                    break
                end
            end
        end
    end

    for i,v in ipairs(DataGoal.data_get_complete) do
        local finishNum = self.model:GetFinishTargetNum()
        if finishNum >= DataGoal.data_get_complete[i].count and hasGotList[i] ~= true then
            isShowOtherRed = true
        end
    end

    if isShowOtherRed == true then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(31, isShowOtherRed)
    end


    self.onUpdateRed:Fire()
end

function SevendayManager:send10240()
  -- print("发送10240")
    Connection.Instance:send(10240, {})
end

function SevendayManager:on10240(data)
    -- BaseUtils.dump(data, "<color=#00FFFF>接收10240</color>")
    -- LuaTimer.Add(10 * 1000, function() self.lastDays = data.day self:CheckRedPoint() end)
    self.lastDays = data.day
    self.onUpdateTime:Fire()
    self:CheckRedPoint()
end

--领取目标完成个数奖励
function SevendayManager:send10241(count)
    Connection.Instance:send(10241, {count = count})
end

--领取目标完成个数奖励
function SevendayManager:on10241(data)
    if data.result == 0 then
        --失败
    elseif data.result == 1 then
        --成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--推送目标个数奖励领取情况
function SevendayManager:send10242()
    Connection.Instance:send(10242, {})
end

--推送目标个数奖励领取情况
function SevendayManager:on10242(data)
    -- {array, single, complete_list, "个数奖励领取情况", [
    --                 {uint16, count, "个数"}
    --             ]}
    -- BaseUtils.dump(data)
    self.model.complete_list = data.complete_list
    EventMgr.Instance:Fire(event_name.seven_day_target_upgrade)
    self:CheckRedPoint()
end

function SevendayManager:CheckShow()
    local bool = false
    bool = bool or (BibleManager.Instance.isShowSevenDay == true)
    bool = bool or (BibleManager.Instance.isShowSevenDay ~= true and (self.lastDays ~= nil and self.lastDays < 15))

    return bool
end

