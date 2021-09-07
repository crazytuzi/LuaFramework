BibleManager = BibleManager or BaseClass(BaseManager)

function BibleManager:__init()
    if BibleManager.Instance ~= nil then
        return
    end

    BibleManager.Instance = self
    self.model = BibleModel.New()

    self.servenDayData = nil
    self.on14100_callback = nil
    self.on14102_callback = nil

    self.baseids = {}
    self.type = 1

    local data_lev_gift = DataAgenda.data_lev_gift
    local baseList = {}
    for _,v in pairs(data_lev_gift) do
        baseList[v.base_id] = 1
    end
    for k,_ in pairs(baseList) do
        table.insert(self.baseids, k)
    end
    table.sort(self.baseids, function(a, b) return a < b end)

    self.redPointDic = {{[1] = true, [2] = false, [3] = true ,[8]=false ,[9] = false, [16] = false, [26] = true}, {false}, {}, {}}

    --值越小优先级越低
    self.popWinDic = {
            [1] = 2
            ,[2] = 1
            ,[3] = 1
            ,[4] = 1
            ,[5] = 1
            ,[6] = 1
            ,[7] = 1
            ,[8] = 1
            ,[9] = 3
            ,[10] = 1
            ,[11] = 1
            ,[15] = 1
            ,[16] = 1
            ,[20] = 4
            ,[21] = 1
    }
    self.hasPopDic = {} --记录窗体是否弹过
    self.curPopWinKey = 0

    self:InitHandler()

    self.showgrowEffect = EventLib.New() --成长基金特效显示

    self.onUpdateRedPoint = EventLib.New()

    self.onUpdateDaily = EventLib.New()
    self.onUpdateSevenday = EventLib.New()
    self.onUpdateLevelup = EventLib.New()
    self.onUpdateInvest = EventLib.New()
    self.onUpdateTotal =EventLib.New()
    self.onUpdateStatusList = EventLib.New()
    self.onUpdateTrible = EventLib.New()

    self.onUpdateRecharge = EventLib.New()
    self.onUpdateLucky = EventLib.New()

    self.onUpdateGetReward = EventLib.New()

    self.replyDailyEvent = EventLib.New()

    self.onRealName = EventLib.New()

    self.directBuyUpdateEvent = EventLib.New() --直购礼包活动

    self.markRoleLev = RoleManager.Instance.RoleData.lev

    self.timer_id = 0

    self.totalStatusList = nil
    self.requireId = nil

    self.IsTotalRedPoint = false
    self.isCanChongZhi = false
    self.months = nil
    self.rechargeData = nil

    self.nowNum = nil

    self.rechargeRedPointListerner = function() self:CheckRechargeRedPoint() end

    self.firstOpen = false
    self.isShowRechargeTab = false

    self.isRealName = nil --是否实名制


end

function BibleManager:__delete()

end

function BibleManager:InitHandler()
    self:AddNetHandler(14100, self.on14100)
    self:AddNetHandler(14101, self.on14101)
    self:AddNetHandler(14102, self.on14102)
    self:AddNetHandler(14103, self.on14103)
    self:AddNetHandler(14109, self.on14109)

    self:AddNetHandler(12008, self.on12008)
    self:AddNetHandler(12009, self.on12009)
    self:AddNetHandler(15300, self.on15300)
    self:AddNetHandler(15301, self.on15301)
    self:AddNetHandler(15302, self.on15302)
    self:AddNetHandler(15303, self.on15303)
    self:AddNetHandler(9906, self.on9906)
    self:AddNetHandler(9933, self.on9933) --现金礼包

    self:AddNetHandler(9800, self.on9800) --sg活动
    self:AddNetHandler(9801, self.on9801) --sg活动

    self:AddNetHandler(10248,self.on10248)
    self:AddNetHandler(10249,self.on10249)

    self:AddNetHandler(9946,self.on9946)
    self:AddNetHandler(9947,self.on9947)
    self:AddNetHandler(9948,self.on9948)

    self:AddNetHandler(9949,self.on9949)
    self:AddNetHandler(9950,self.on9950)
    self:AddNetHandler(9951,self.on9951)
    self:AddNetHandler(9954,self.on9954)
    self:AddNetHandler(9955,self.on9955)

    self:AddNetHandler(20493,self.on20493)
    self:AddNetHandler(20494,self.on20494)

    self.AddNetHandler()


    EventMgr.Instance:AddListener(event_name.role_asset_change, function()
            self:CheckRechargeRedPoint()
    end)

    EventMgr.Instance:AddListener(event_name.mainui_btn_init, function ()
        self.hasInited = false
        EventMgr.Instance:AddListener(event_name.role_level_change, function()
            self:OnLevelUp()
        end)
        EventMgr.Instance:AddListener(event_name.backpack_item_change, function ()
            self:checkRedPoint()
        end)
        EventMgr.Instance:AddListener(event_name.quest_update, function(data)
            for k,v in pairs(data) do
                if v ~= nil then
                    local dat = DataQuest.data_get[v]
                    local quest = QuestManager.Instance.questTab[v]
                    if dat.sec_type == QuestEumn.TaskType.guide and quest ~= nil and quest.finish == 2 and (quest.progress ~= nil and #quest.progress ~= 0) then
                        local part = math.ceil((dat.lev + 1) / 10)
                        self.redPointDic[2][part] = true
                    end
                end
            end
            self:CheckMainUIIconRedPoint()
        end)

        local questList = QuestManager.Instance.questTab
        for k,v in pairs(questList) do
            if v ~= nil then
                local dat = DataQuest.data_get[v.id]
                if dat.sec_type == QuestEumn.TaskType.guide and v.finish == 2 and (v.progress ~= nil and #v.progress ~= 0) then
                    local part = math.ceil((dat.lev + 1) / 10)
                    self.redPointDic[2][part] = true
                end
            end
        end

        self:send12008()
        self:sendProtoForCheckRedPoint()

        --开始计时帮助按钮下面的冒泡提示
        -- self:start_timer(600)
    end)

    EventMgr.Instance:AddListener(event_name.privilege_lev_change, function()
        local l = PrivilegeManager.Instance:GetValueByType(PrivilegeEumn.Type.addSign)
        if l > 0 then
            self:send14102()
        end
    end)

    EventMgr.Instance:AddListener(event_name.mainui_btn_init, function()
        self:checkDailyGiftRedPoint()
    end)
end

function BibleManager:sendProtoForCheckRedPoint()
    local lev = RoleManager.Instance.RoleData.lev
    if lev >= DataSystem.data_icon[22].lev then
        self.on14102_callback = function()
            local currentDay = tonumber(os.date("%d", BaseUtils.BASE_TIME))
            local currentMonth = tonumber(os.date("%m", BaseUtils.BASE_TIME))
            local lastDay = tonumber(os.date("%d", self.model.dailyCheckData.last_time))
            local lastMonth = tonumber(os.date("%m", self.model.dailyCheckData.last_time))
            if self.model.dailyCheckData.last_time == 0 then
                lastDay = -1
            end
            lev = RoleManager.Instance.RoleData.lev
            if lev >= 24 then
                if currentMonth ~= lastMonth or currentDay > lastDay then
                    if self.autoDataDaily == nil or self.autoDataDaily.inChain ~= true then
                        if self.hasInited ~= true then
                            self:AutoPopWin(1)
                        end
                    end
                else
                    if self.autoDataDaily ~= nil then
                        self.autoDataDaily:DeleteMe()
                        self.autoDataDaily = nil
                    end
                end
            end
            self.hasInited = true
        end
        self:send14100()
        self:send14102()
        self:send15300()
        self:send15302()
    end
end

--等级变化检查现金礼包等级段是否满足显示红点
function BibleManager:checkDailyGiftRedPoint()
    self.redPointDic[1][16] = self.model:CheckDailyGiftShow()
    self.model:CheckForLevelGift()
    self:CheckMainUIIconRedPoint()
end

function BibleManager:checkRedPoint()
    if DataSystem.data_icon[22].lev > RoleManager.Instance.RoleData.lev then
        return
    end

    -- 检查每日签到红点
    if self.model.dailyCheckData ~= nil then
        local lastDay = self.model.dailyCheckData.log[#self.model.dailyCheckData.log]
        self.redPointDic[1][1] = self.redPointDic[1][1] and (lastDay ~= nil and lastDay.rewarded == 0)
    end

    -- 检查七天登录红点
    if self.servenDayData ~= nil then
        self.isShowSevenDay = false
        for k,v in pairs(self.servenDayData.seven_day) do
            if v.rewarded == 0 then
                self.isShowSevenDay = true
                break
            end
        end
        -- self.redPointDic[1][2] = self.redPointDic[1][2] and self.isShowSevenDay
        if #self.servenDayData.seven_day <= 7 then
            -- --登陆第8天处理
            local hasReward = false
            for i=1,#self.servenDayData.seven_day do
                local tempData = self.servenDayData.seven_day[i]
                if tempData.rewarded == 0 then
                    hasReward = true
                end
            end
            if hasReward then
                --还有奖励未领取
                self.isShowSevenDay = true
            end
        end

        -- print("-----========检查七天登陆的数据列表")
        -- BaseUtils.dump(self.servenDayData.seven_day)
    end

    --检查在线奖励红点
    local isShowOnlineRewardRedPoint = false
    local dataItemList = ((CampaignManager.Instance.campaignTree[CampaignEumn.Type.OnLine] or {})[1] or {}).sub or {}
    for i,v in ipairs(dataItemList) do
        if v.status == CampaignEumn.Status.Finish then
            isShowOnlineRewardRedPoint = true
            break
        end
    end
    self.redPointDic[1][8] = isShowOnlineRewardRedPoint

    --self.redPointDic[1][24] = (self.isRealName == 0)

    --Wechat公众号红点
    local dat = DataBible.data_list[27]
    local sTime = dat.sTime[1]
    local start_time = tonumber(os.time {year = sTime[1], month = sTime[2], day = sTime[3], hour = sTime[4], min = sTime[5], sec = sTime[6]})
    if BaseUtils.BASE_TIME <= (start_time + dat.redDay * 86400) or (BaseUtils.BASE_TIME <= CampaignManager.Instance.open_srv_time + dat.redDay * 86400) then
        self.redPointDic[1][27] = self.redPointDic[1][27] or true
    else
        self.redPointDic[1][27] = false
    end

    --直购红点
    self.redPointDic[1][28] = self.model:CheckDirectBuyRedPointStatus(self.model.data20493)
    
    self:CheckRechargeAgainPoint()
    self.model:CheckForLevelGift()
    self:CheckoutDailyRewardRedPoint()
    self:CheckoutTotalRedPoint()
    self:CheckMainUIIconRedPoint()

end

function BibleManager:CheckMainUIIconRedPoint()
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(22, self:isNeedShowRedPoint())
    end
end

function BibleManager:isNeedShowRedPoint()
    local bool = false
    local openLevel = self.model:CheckTabShow()
    for k,v in pairs(self.redPointDic) do
        if k ~= 4 or CampaignManager.Instance.IsShowTabInBible == true then
            for k1,v1 in pairs(v) do
                if k == 1 then
                    bool = bool or (v1 == true and openLevel[k1] ~= false)
                else
                    bool = bool or v1
                end
            end
        end
    end
    return bool and (RoleManager.Instance.RoleData.lev >= 5)
end

function BibleManager:OpenWindow(args)
    if self.firstOpen == false then
        self:CheckRechargeRedPoint()
    end
    -- BaseUtils.dump(args, "打开参数")
    if args == nil then
        args = {}
    end
    self.model.openArgs = args
    if args[1] == nil then
        self.model.currentMain = 1
        self.model.currentSub = 1
    else
        self.model.currentMain = args[1]
        if args[2] == nil then
            self.model.currentSub = 1
        else
            self.model.currentSub = args[2]
            if args[3] == nil then
                self.model.currentTab = 1
            else
                self.model.currentTab = args[3]
            end
        end
    end
    self.model:OpenWindow(args)
end

function BibleManager:send14100(callback)
    Connection.Instance:send(14100, {})
end

function BibleManager:send14101(data, callback)
    self.justGetRewardOrder = data
    self.on14101_callback = callback
    Connection.Instance:send(14101, {order=data})
end

function BibleManager:send14102(callback)
    Connection.Instance:send(14102, {})
end

function BibleManager:send14103(data, callback)
    self.months = nil or data
    if callback ~= nil then
        self.on14103_callback = callback
    end

    Connection.Instance:send(14103, {})
end

function BibleManager:on14100(data)
    -- BaseUtils.dump(data,"on14100")
    self.servenDayData = self.servenDayData or {}
    self.servenDayData.seven_day = {}
    for _,v in pairs(data.seven_day) do
        self.servenDayData.seven_day[v.order] = v
    end
    -- self.servenDayDatadata = data
    self:checkRedPoint()
    --Log.Error(self.servenDayData.seven_day[1].year)

    self.onUpdateSevenday:Fire()
    self.onUpdateRedPoint:Fire()
end

function BibleManager:on14101(data)
    --Log.Error("get data 14101")
    if self.servenDayData ~= nil then
        for i,v in ipairs(self.servenDayData.seven_day) do
            if v.order == self.justGetRewardOrder then
                if data.flag == 1 then
                    v.rewarded = 1
                end
                break
            end
        end
    end
    self:checkRedPoint()
    self.onUpdateRedPoint:Fire()
    if self.on14100_callback ~= nil then
        self.on14100_callback()
    end

    if self.on14101_callback ~= nil then
        self.on14101_callback()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function BibleManager:on14102(data)
    self.model.dailyCheckData = data

    self:checkRedPoint()


    if self.on14102_callback ~= nil then
        self.on14102_callback()
        -- self.on14102_callback = nil
    end
    self.onUpdateDaily:Fire()
    self.onUpdateRedPoint:Fire()
end

function BibleManager:on14103(data)
    if data.flag == 1 then
        self.onUpdateDaily:Fire()
    end
    self.on14103_callback = nil

    if self.months ~= nil then
       WindowManager.Instance:OpenWindowById(WindowConfig.WinID.signreward_window,{self.model.dailyCheckData,self.months})
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)

end

function BibleManager:send14109(isCanChongZhi)
    self.isCanChongZhi = isCanChongZhi or false
    Connection.Instance:send(14109, {})
end

function BibleManager:on14109(data)
    self.replyDailyEvent:Fire(data)
end

function BibleManager:on10248(data)
    self.totalStatusList = {}
    for k,v in pairs(data.list) do
        self.totalStatusList[k] = v
    end

    self:checkRedPoint()
    self.onUpdateStatusList:Fire()
end

function BibleManager:on10249(data)
    if data.flag == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    else
        self.onUpdateTotal:Fire(self.requireId)
        -- self.model.bibleWin:TotalBtnReply(self.requireId)
    end
end

function BibleManager:send10248()
    Connection.Instance:send(10248, {})
end

function BibleManager:send10249(data)
    self.requireId = data.id
    Connection.Instance:send(10249,data)
end

function BibleManager:send12008()
    -- print("请求12008")
    Connection.Instance:send(12008, {})
end

function BibleManager:on12008(data)
    -- print("<color=#FF0000>响应12008</color>")
    -- BaseUtils.dump(data)

    local size = DataAgenda.data_lev_gift_length / 5
    for i=1,size do
        if self.model.levelUnfreeList[i * 10] == nil then
            self.model.levelUnfreeList[i * 10] = {}
        end
        self.model.levelUnfreeList[i * 10].is_buy = 1
    end

    for k,v in pairs(data.buy_list) do
        self.model.levelUnfreeList[v.lev].time = v.time
        self.model.levelUnfreeList[v.lev].is_buy = v.is_buy
    end

    self.model:CheckForLevelGift()
    self.onUpdateLevelup:Fire()
end

function BibleManager:send12009(id)
    -- print("请求12009")
    Connection.Instance:send(12009, {id = id})
end

function BibleManager:on12009(data)
    -- print("响应12009")
    -- BaseUtils.dump(data)
    if data.flag == 1 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
        for _,v in pairs(self.model.levelUnfreeList) do
            if v.id == data.id then
                v.is_buy = 1
            end
        end
        self.model:CheckForLevelGift()

        self.onUpdateLevelup:Fire()
    end
end

function BibleManager:send9906(strCard)
    Connection.Instance:send(9906, {card = strCard})
end

function BibleManager:on9906(data)
    if data.result == 1 then
        --成功
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
-- 5星评价
function BibleManager:send9800(state)
    Connection.Instance:send(9800, {type = state})
end
-- 5星评价
function BibleManager:on9800(data)
    -- body
end
-- 超级VIP
function BibleManager:send9801()
    Connection.Instance:send(9801, {})
end
-- 超级VIP
function BibleManager:on9801(data)
    -- body
end

function BibleManager.ParaseReward(reward,classes_name,sex)
    if classes_name == nil then
        classes_name = RoleManager.Instance.RoleData.classes
    end
    if sex == nil then
        sex = RoleManager.Instance.RoleData.sex
    end

    local rewardData = {}
    for i,v in ipairs(reward) do
        local rd = {}
        local dataItem = DataItem.data_get[v[1]]
        rd.dataItem = dataItem
        rd.count = v[2]
        rd.classes_name = v[3] --
        rd.sex = v[4] --
        if rd.classes_name == 0 then
            if rd.sex == 2 or rd.sex == sex then
                table.insert(rewardData,rd)
            end
        elseif rd.classes_name == classes_name then
            if rd.sex == 2 or rd.sex == sex then
                table.insert(rewardData,rd)
            end
        end
    end
    return rewardData
end

function BibleManager:send15300()
    Connection.Instance:send(15300, {})
end

function BibleManager:on15300(data)

    self.model.invest_data = data.seven_day
    self.model.invest_type = data.id

    self.isShowInvest = false
    for i,v in ipairs(data.seven_day) do
        self.isShowInvest = self.isShowInvest or (v.rewarded == 0)
    end
    local num = 0
    for k,v in pairs(DataInvestment.data_get) do
        if v.id == data.id then
            num = num + 1
        end
    end
    if self.isShowInvest == false and #data.seven_day < num then
        self.isShowInvest = true
    end

    self.model.investCanGet1 = false
    for i,v in ipairs(data.seven_day) do
        if v.rewarded == 0 then
            self.model.investCanGet1 = true
            break
        end
    end
    self.redPointDic[1][4] = self.model.investCanGet1 or self.model.investCanGet2

    self.onUpdateRedPoint:Fire()
    self.onUpdateInvest:Fire()
end

function BibleManager:send15301(order)
    Connection.Instance:send(15301, {order = order})
end

function BibleManager:on15301(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.onUpdateInvest:Fire()
    end
end

function BibleManager:OnLevelUp()
    local lev = RoleManager.Instance.RoleData.lev
    self.redPointDic[1][3] = (self.notShowedLevelGift == true) and (lev % 10 and lev <= 80)
    self:sendProtoForCheckRedPoint()    -- 检查红点
    self.onUpdateRedPoint:Fire()
end

----------帮助按钮下面的冒泡提示计时
--开始战斗倒计时
function BibleManager:start_timer(gap)
    self:stop_timer()
    self.time_count = 0
    self.model.brewModel.warm_tips_time_gap = gap
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

function BibleManager:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

function BibleManager:timer_tick()
    if self.time_count >= self.model.brewModel.warm_tips_time_gap then
        --有队伍，或者战斗中就不提示
        if RoleManager.Instance.RoleData.status == RoleEumn.Status.Normal and  TeamManager.Instance:MemberCount() == 0 and RoleManager.Instance.RoleData.lev <= self.model.brewModel.warm_tips_lev then
            if CombatManager.Instance.isFighting == false then
                if WindowManager.Instance.currentWin == nil then
                    --当前没有窗口打开着
                    if #self.model.brewModel:Get_Warm_Tips_List() > 0 then
                        self.time_count = 0
                        self.model.brewModel.warm_tips_type = 2
                        self.model.brewModel:InitWarmTipsUI()
                        self:stop_timer()
                    end
                end
            end
        end
    else
        self.time_count = self.time_count + 1
    end
end


function BibleManager:send15302()
    Connection.Instance:send(15302, {})
end

function BibleManager:on15302(data)

    self.model.invest_data2 = data.seven_day

    self.isShowInvest2 = false
    for i,v in ipairs(data.seven_day) do
        self.isShowInvest2 = self.isShowInvest2 or (v.rewarded == 0)
    end
    if self.isShowInvest2 == false and #data.seven_day < DataInvestment.data_get2_length then
        self.isShowInvest2 = true
    end

    self.model.investCanGet2 = false
    for i,v in ipairs(data.seven_day) do
        if v.rewarded == 0 then
            self.model.investCanGet2 = true
            break
        end
    end
    self.redPointDic[1][4] = self.model.investCanGet1 or self.model.investCanGet2

    self.onUpdateRedPoint:Fire()
    self.onUpdateInvest:Fire()
end

function BibleManager:send15303(order)
    Connection.Instance:send(15303, {order = order})
end

function BibleManager:on15303(data)
    -- BaseUtils.dump(data, "<color=#00FF00>返回15303</color>")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.onUpdateInvest:Fire()
    end
end

function BibleManager:OnDailyCheckOpen()
    if self.model.bibleWin == nil then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1, 1})
    end
end

--请求购买现金礼包
function BibleManager:send9933()
    Connection.Instance:send(9933, {})
end

--购买现金礼包返回
function BibleManager:on9933(data)
    self.model.bibleDailyGiftSocketData = data
    EventMgr.Instance:Fire(event_name.update_cash_gift_info, data)
    self:checkDailyGiftRedPoint()
    if self.model:CheckDailyGiftShow() and data.flag  == 1 then
        self:AutoPopWin(16)
    end
end

--自动弹窗逻辑
function BibleManager:AutoPopWin(key)
    if (WindowManager.Instance.currentWin ~= nil and WindowManager.Instance.currentWin.windowId == WindowConfig.WinID.campaign_uniwin) -- 如果活动窗口已经打开，则不往下执行
        or RoleManager.Instance.RoleData.lev <= DataSystem.data_icon[22].lev or self.hasPopDic[key] then
        --已经做过弹窗处理
        return
    end
    local nowKey = self.curPopWinKey
    if self.curPopWinKey == 0 then
        nowKey = key
    else
        local curPriority = self.popWinDic[self.curPopWinKey]
        local priority = self.popWinDic[key]
        if curPriority < priority then
            nowKey = key
        end
    end
    self.hasPopDic[key] = true
    if self.curPopWinKey ~= nowKey then
        if SettingManager.Instance.model.gaWin ~= nil then
            table.insert(SettingManager.Instance.model.funcTab, function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1, nowKey}) end)
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1, nowKey})
        end
    end
    self.curPopWinKey = nowKey
end

function BibleManager:GetTotalStatusData()
    if self.totalStatusList ~= nil then
        local data = {}
        for k,v in pairs(self.totalStatusList) do
           data[v.id] = true
        end
        return data
    else
        return nil
    end
end

function BibleManager:RequestInitData()
    self.notShowedLevelGift = true

    self.model.tribleData = {}
    self:send10248()
    self:send9946()
    self:send20493()

    -- self:CheckoutTotalRedPoint()
end

-- function BibleManager:SetTotalStatusTotal(id)
--    self.totalStatusList[#self.totalStatusList + 1].id = true
-- end
function BibleManager:CheckoutTotalRedPoint()

        local IsAccetTotalList = BibleManager.Instance:GetTotalStatusData()

        if IsAccetTotalList == nil then
            return
        end
        local allQuest = DataQuest.data_get

        local guideQuestList = {}
        local guideQuestListForShow = {}
        local part = nil
        local ceil = math.ceil
        for k,v in pairs(allQuest) do
            if v.sec_type == QuestEumn.TaskType.guide then
                part = ceil((v.lev + 1) / 10)
                if guideQuestList[part] == nil then
                    guideQuestList[part] = {}
                end
                guideQuestList[part][v.id] = v
            end
        end

        for k,v in pairs(guideQuestList) do
             table.insert(guideQuestListForShow, {key = k, value = {}})
             for _,quest in pairs(v) do
                  table.insert(guideQuestListForShow[#guideQuestListForShow].value, quest)
             end

        -- table.sort(self.guideQuestListForShow[#self.guideQuestListForShow].value, function (a,b)
        --     return self:CompareQuest(a,b)
        -- end)
        end
        table.sort(guideQuestListForShow, function(a, b) return a.key < b.key end)

         for i1,v1 in ipairs(guideQuestListForShow) do
            local quests = v1.value
            local questList = {}
            local world_lev = RoleManager.Instance.world_lev
            for i,v in ipairs(quests) do
                if v.id == 41012 then
                    if world_lev >= 45 then
                        table.insert(questList, v)
                    end
                else
                    table.insert(questList, v)
                end
                -- table.insert(questList, v)
            end

            local CompletedQuest = 0
            local isChange = false
            for i2,v2 in ipairs(questList) do
                local data = DataQuest.data_get[v2.id]

                local quest = BaseUtils.copytab(QuestManager.Instance.questTab[data.id])
                if quest == nil then
                    quest = {finish = 1, follow = 0}
                else
                    isChange = true
                end


                if quest.progress ~= nil then

                else
                    if data.find_break_lev > 0 then
                        if RoleManager.Instance.RoleData.lev < data.lev or RoleManager.Instance.RoleData.lev_break_times < data.find_break_lev then

                        else
                            CompletedQuest = CompletedQuest + 1
                        end
                    else
                        if RoleManager.Instance.RoleData.lev < data.lev then

                        else
                            CompletedQuest = CompletedQuest + 1
                        end
                     end
                end
            end

            if isChange == true then
                 if CompletedQuest >= #questList and IsAccetTotalList[i1 + 1] == nil then
                     self.redPointDic[2][i1 + 1] = true
                 elseif CompletedQuest >= #questList and IsAccetTotalList[i1 + 1] == true then
                     self.redPointDic[2][i1 + 1] = false
                 end
            end
        end
end

function BibleManager:CheckoutDailyRewardRedPoint()
    if self.model.dailyCheckData ~= nil then
       if self.model.dailyCheckData.rand_reward >= 1 then
         self.redPointDic[1][1] = true
       end
    end
end


function BibleManager:redPointDicClearAll()
  for i1,v1 in ipairs(self.redPointDic) do
        for k2,v2 in pairs(v1) do
            v1[k2] = false
        end
  end
end

function BibleManager:send9946()
    Connection.Instance:send(9946, {})
end

function BibleManager:on9946(data)
    -- BaseUtils.dump(data, "<color='#ff8800'>on9946</color>")
    self.model:BuildTribleData(data)
    self.onUpdateTrible:Fire()

    self:send9947()
end

function BibleManager:send9947()
    Connection.Instance:send(9947, {})
end

function BibleManager:on9947(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>on9947</color>")
    self.model:UpdateTribleStatus(data)
    self.onUpdateTrible:Fire()
end

function BibleManager:send9948(id, gift_id)
    Connection.Instance:send(9948, {id = id, gift_id = gift_id})
end

function BibleManager:on9948(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function BibleManager:OnTick()
    self.model:OnCheckTrible()
end

function BibleManager:send9949()
  -- print("发送协议9949")
  Connection.Instance:send(9949,{})
end

function BibleManager:on9949(data)
   -- BaseUtils.dump(data,"回调协议9949")
   self.rechargeData = data
   self.onUpdateLucky:Fire()
end

function BibleManager:send9950()
   -- BaseUtils.dump(data,"发送协议9950")
   local data = {num = self.nowNum}
   Connection.Instance:send(9950,data)
end

function BibleManager:on9950(data)

    local dataList = data.ids
    NoticeManager.Instance:FloatTipsByString(data.msg)


    table.sort(dataList,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        else
            return false
        end
    end)
    if data.flag == 1 then
        self.onUpdateGetReward:Fire(dataList)
    end
end


function BibleManager:send9951()
   Connection.Instance:send(9951,{})
end

function BibleManager:on9951(data)
    self.rewardList = {}
    NoticeManager.Instance:FloatTipsByString(data.msg)

    for k,v in pairs(data.item_id) do
        table.insert(self.rewardList,v)
    end
    if data.flag == 1 then
        self.onUpdateRecharge:Fire(self.rewardList)
    end
end

function BibleManager:send9954()
   Connection.Instance:send(9954,{})
end

function BibleManager:on9954(data)
    self.isRealName = data.flag
end

function BibleManager:send9955()
   Connection.Instance:send(9955,{})
end

function BibleManager:on9955(data)
    BaseUtils.dump(data,"实名制领奖")
    self:checkRedPoint()
    if data.flag == 1 then
        self.onRealName:Fire()
    end
end

--每日直购活动
function BibleManager:send20493()
    -- print("发送20493")
    Connection.Instance:send(20493, {})
end

function BibleManager:on20493(data)
    -- BaseUtils.dump(data, "接收20493")
    local camp_info = self.model.data20493.camp_info or {}
    for i, v in ipairs(data.camp_info) do
        local time = (camp_info[i] or {}).time
        if v.time ~= time then
            self.model:CloseLimitClickDirectBuy(i)
        end
    end
    self:checkRedPoint()
    self.model.data20493 = data
    self.directBuyUpdateEvent:Fire(data)
end

--每日直购活跃奖励
function BibleManager:send20494()
    -- print("发送20494")
    Connection.Instance:send(20494, {})
end

function BibleManager:on20494(data)
    -- BaseUtils.dump(data, "接收20494")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function BibleManager:CheckRechargeRedPoint()
    if RoleManager.Instance.RoleData.turn ~= nil then
        if RoleManager.Instance.RoleData.turn > 0 then
           BibleManager.Instance.redPointDic[1][23] = true
        else
           BibleManager.Instance.redPointDic[1][23] = false
        end
        BibleManager.Instance.onUpdateRedPoint:Fire()
    end
end

function BibleManager:CheckRechargeAgainPoint()
    local dailyCheckData = self.model.dailyCheckData
    if dailyCheckData ~= nil then
        self.canReceive = {}
        local daysInMonth = {
            [false] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
            , [true] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
        }

         local lastDay = tonumber(os.date("%d", dailyCheckData.last_time))
         local lastMonth = tonumber(os.date("%m", dailyCheckData.last_time))
         local currentDay = tonumber(os.date("%d", BaseUtils.BASE_TIME))
         local currentMonth = tonumber(os.date("%m", BaseUtils.BASE_TIME))
         local currentYear = tonumber(os.date("%Y", BaseUtils.BASE_TIME))
         local add_sign = dailyCheckData.add_sign
        local isLeap = false

        if currentYear % 100 == 0 then
            isLeap = (currentYear % 400 == 0)
        else
            isLeap = (currentYear % 4 == 0)
        end

        local days = daysInMonth[isLeap][currentMonth]
        for i=1,days do
            self.canReceive[i] = false
        end

        if currentDay > lastDay or (currentDay == lastDay and add_sign > 0 and dailyCheckData.signed < currentDay) then
            self.canReceive[dailyCheckData.signed + 1] = true
        end


        self.nowRewardId = nil
        if lastDay == currentDay then

            for i,v in ipairs(self.model.dailyCheckData.log) do
                if v.day == currentDay then
                    self.nowRewardId = self.model.dailyCheckData.log[i].rewarded
                end
            end

        else
            self.nowRewardId = self.model.dailyCheckData.signed + 1
        end

        if self.canReceive[self.nowRewardId] ~= true and self.model.dailyCheckData.repeatflag == 0 and RoleManager.Instance.RoleData.lev >= 40 and SevendayManager.Instance.model.todayChargeData ~= nil then
            if SevendayManager.Instance.model.todayChargeData.day_charge > 0 and self.model.dailyCheckData.repeatflag == 0 then
                self.redPointDic[1][1] = true
            end
        end
    end
end

function BibleManager:OnRetrun()
    if self.model.bibleWin ~= nil and self.model.bibleWin.panelList[1] ~= nil and self.model.bibleWin.panelList[1].panelList[24] ~= nil then
        self.model.bibleWin.panelList[1].panelList[24]:OnReturn()
    end
end
