-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 
-- --------------------------------------------------------------------
ActionModel = ActionModel or BaseClass()

local color_text = {
    [1] = Config.ColorData.data_new_color4[17],
    [2] = Config.ColorData.data_new_color4[17],
}
local table_insert = table.insert
local table_sort = table.sort
function ActionModel:__init(ctrl)
	self.ctrl = ctrl
    self:config()
end

function ActionModel:config()
    self.seven_days_quest = {}      -- 7天排行任务
    self.seven_red_status_list = {}     -- 7天排行任务
    --跨服排行任务
    self.corssserver_days_quest = {} -- 跨服排行的任务
    self.crossserver_red_status_list = {} --跨服排行的红的的任务
    -- 基金红点数据
    self.fund_red_list = {}

    --显示玩法的icon数据 --by lwc
    self.dic_limit_icon_data = {}
end

function ActionModel:updateLimitIconData(data)
    if self.dic_limit_icon_data then
        if data.status == ActionStatus.un_finish then
            self.dic_limit_icon_data[data.id] = nil
        else
            self.dic_limit_icon_data[data.id] = data
        end
    end
end

function ActionModel:getLimitIconData()
    return self.dic_limit_icon_data
end

--- 更新7天任务
function ActionModel:updateSevenQuestList(task_list, is_init)
    local taskVo, config = nil
    local is_new = false
    if is_init == true then
        self.seven_days_quest = {}
    end
    for i, v in ipairs(task_list) do
        config = Config.DaysRankData.data_rank_quest_id[v.id]
        if config ~= nil then
            if self.seven_days_quest[v.id] == nil then
                self.seven_days_quest[v.id] = TaskVo.New(v.id, TaskConst.type.action)
            end
            taskVo = self.seven_days_quest[v.id]
            taskVo:updateData(v)
        end
    end
    self:updateGuildRedStatus()
end

function ActionModel:updateGuildRedStatus()
    local red_status = false
    if self.seven_days_quest == nil or next(self.seven_days_quest) == nil then
        red_status = false
    else
        for k,vo in pairs(self.seven_days_quest) do
            if vo.finish == TaskConst.task_status.finish then
                red_status = true
                break
            end
        end
    end 
    
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.seven_rank, red_status)
end

function ActionModel:delSevenQuest(id)
    self.seven_days_quest[id] = nil
    self:updateGuildRedStatus()
end

function ActionModel:getSevenQuestByID(id)
    return self.seven_days_quest[id]
end

function ActionModel:updateSevenLoginData(data)
    self.seven_login_data = data
end

function ActionModel:getSevenLoginData()
    return self.seven_login_data
end

--==============================--
--desc:获取当前可领取7天登录的最大天数
--time:2018-09-11 08:59:52
--@return 
--==============================--
function ActionModel:getMaxSevenDay()
    if self.seven_login_data == nil or self.seven_login_data.status_list == nil then 
        return 
    end

    local status_list = self.seven_login_data.status_list
    table.sort( status_list, function(a, b) 
        return a.day < b.day
    end)
    local day = nil
    for i,v in ipairs(status_list) do
        if v.status == 2 then
            day = v
            break
        end
    end
    if day == nil then
        day = status_list[#status_list]
    end
    return day
end

--==============================--
--desc:获取7天登录/8天登录类型
--@return 
--==============================--
function ActionModel:getSevenDayType()
    if self.seven_login_data == nil or self.seven_login_data.type == nil then 
        return 
    end

    local type = self.seven_login_data.type
    return type
end


function ActionModel:updataFestvalRedStatus(bid,data)
    local red_status = self:getRedPointStatus(data)
    local festval_bid = MainuiConst.icon.festval
    if bid == ActionRankCommonType.festval_day then
        festval_bid = MainuiConst.icon.festval_spring
    elseif bid == ActionRankCommonType.lover_day then
        festval_bid = MainuiConst.icon.festval_lover
    end
    MainuiController:getInstance():setFunctionTipsStatus(festval_bid, red_status)
end
function ActionModel:getRedPointStatus(data)
    if not data then return false end
    local red_status = false 
    for k,v in pairs(data) do
        if v.status == 1 then
            red_status = true 
        end
    end
    return red_status
end

function ActionModel:updataCombineLoginRedStatus(data)
    if not data then return end
    local red_status = false 
    for k,v in pairs(data) do
        if v.status == 1 then
            red_status = true 
        end
    end
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.combine_login, red_status)
end

function ActionModel:updataPreferentialRedStatus( status, id )
    if true then return end -- 暂时屏蔽掉 不需要

    id = id or MainuiConst.icon.preferential
    if status then
        if self.prefer_fisrt_flag == nil then
            self.prefer_fisrt_flag = {}
        end
        if not self.prefer_fisrt_flag[id] then
            self.prefer_fisrt_flag[id] = true
        else
            status = false
        end
    end
    MainuiController:getInstance():setFunctionTipsStatus(id, status)
end

-- 七天排行的分类
function ActionModel:checkIsCrossServerRankList(id)
    -- body
    if id >=1 and id <= 7 then
        return false
    elseif id>=8 and id<=14 then
        return true
    else
        return false
    end
end

--type == 0 表示七天排行，type == 1 表示跨服排行
function ActionModel:getCrossServerRankListData(m_type)
    local temp = Config.DaysRankData.data_rank_list
    local list = {}
    for k,v in pairs(temp) do
        if m_type == 0 then
            if (v[1].id >=1 and v[1].id<=7) or (v[1].id >=15 and v[1].id<=19) then
                table.insert(list,v)
            end
        elseif m_type == 1 then
            if v[1].id >=8 and v[1].id<=14 then
                table.insert(list,v)
            end
        end
    end
    return deepCopy(list)
end


--获取七日目标的周期数
function ActionModel:setSevenGoldPeriod(period)
    self.sevenPeriod = period
end
function ActionModel:getSevenGoldPeriod()
    return self.sevenPeriod or 1
end
--七天目标检查红点   --当前天数以下的
function ActionModel:checkRedPoint(day)
    if day < 1 or day > 7 then return end
    day = day or 1

    --福利
    self.welfareRetPoint = {}
    for i=1, day do
        local welfare = self:getSevenGoalWelfareList(i)
        self.welfareRetPoint[i] = false
        for k,v in pairs(welfare) do
            if v.status == 1 then
                self.welfareRetPoint[i] = true
                break
            end
        end
    end
    --每日目标
    self.growRetPoint = {}
    for i=1,day do
        local grow = self:getServerGrowListData(i)
        self.growRetPoint[i] = false
        for k,v in pairs(grow) do
            if v.status == 1 then
                self.growRetPoint[i] = true
                break
            end
        end
    end

    --超值礼包
    self.giftRetPoint = {}
    for i=1,day do
        local grow = self:getServerGiftListData(i)
        self.giftRetPoint[i] = false
        for k,v in pairs(grow) do
            if v.status == 1 then
                self.giftRetPoint[i] = true
                break
            end
        end
    end

    self.halfRedPoint = {}
    -- 0、还有领取  1、已领取
    for i=1,day do
        local half = self:getHalfGiftList(i)
        self.halfRedPoint[i] = false
        for k,v in pairs(half) do
            if k == 1 and v.status == 0 then
                self.halfRedPoint[i] = true
                break
            end
        end
    end

    --宝箱
    self.boxRedPoint = {}
    local box = self:getSevenGoalBoxList()
    for i,v in pairs(box) do
        self.boxRedPoint[i] = false
        if v.status == 1 then
            self.boxRedPoint[i] = true
        end
    end

    local redStatus = false
    local redStatus1 = false
    local redStatus2 = false
    local redStatus3 = false
    local redStatus4 = false
    local redStatus5 = false

    for i,v in pairs(self.welfareRetPoint) do
        if v == true then
            redStatus1 = true
            break
        end
    end
    for i,v in pairs(self.growRetPoint) do
        if v == true then
            redStatus2 = true
            break
        end
    end
    for i,v in pairs(self.giftRetPoint) do
        if v == true then
            redStatus3 = true
            break
        end
    end
    for i,v in pairs(self.halfRedPoint) do
        if v == true then
            redStatus5 = true
            break
        end
    end

    for i,v in pairs(self.boxRedPoint) do
        if v == true then
            redStatus4 = true
            break
        end
    end
    redStatus = redStatus1 or redStatus2 or redStatus3 or redStatus4 or redStatus5

    local icon_id = MainuiConst.icon.seven_goal
    if self:getSevenGoldPeriod() == 1 then
        icon_id = MainuiConst.icon.seven_goal
    elseif self:getSevenGoldPeriod() == 2 then
        icon_id = MainuiConst.icon.seven_goal1
    elseif self:getSevenGoldPeriod() == 3 then
        icon_id = MainuiConst.icon.seven_goal2
    elseif self:getSevenGoldPeriod() == 7 then
        icon_id = MainuiConst.icon.seven_goal4
    else
        icon_id = MainuiConst.icon.seven_goal3
    end
    MainuiController:getInstance():setFunctionTipsStatus(icon_id, redStatus)
end

--红点状态
function ActionModel:getRedPointWelfareStatus(day)
    local status = false
    if self.welfareRetPoint and self.welfareRetPoint[day] then
        status = self.welfareRetPoint[day] or false
    end
    return status
end
--更新
function ActionModel:updataRedPointWelfareStatus(day, status)
    if self.welfareRetPoint and self.welfareRetPoint[day] then
        status = status or false
        self.welfareRetPoint[day] = status
    end
end

function ActionModel:getRedPointGrowStatus(day)
    local status = false
    if self.growRetPoint and self.growRetPoint[day] then
        status = self.growRetPoint[day] or false
    end
    return status
end
--更新
function ActionModel:updataRedPointGrowStatus(day, status)
    if self.growRetPoint and self.growRetPoint[day] then
        status = status or false
        self.growRetPoint[day] = status
    end
end

function ActionModel:getRedPointGiftStatus(day)
    local status = false
    if self.giftRetPoint and self.giftRetPoint[day] then
        status = self.giftRetPoint[day] or false
    end
    return status
end
--更新
function ActionModel:updataRedPointGiftStatus(day, status)
    if self.giftRetPoint and self.giftRetPoint[day] then
        status = status or false
        self.giftRetPoint[day] = status
    end
end

--福利礼包
function ActionModel:getRedPointHalfStatus(day)
    local status = false
    if self.halfRedPoint and self.halfRedPoint[day] then
        status = self.halfRedPoint[day] or false
    end
    return status
end
--更新
function ActionModel:updataRedPointHalfStatus(day, status)
    if self.halfRedPoint and self.halfRedPoint[day] then
        status = status or false
        self.halfRedPoint[day] = status
    end
end

function ActionModel:getRedPointBoxStatus(index)
    local status = false
    if self.boxRedPoint and self.boxRedPoint[index] then
        status = self.boxRedPoint[index] or false
    end
    return status
end
--更新
function ActionModel:updataRedPointBoxStatus(index, status)
    if self.boxRedPoint and self.boxRedPoint[index] then
        status = status or false
        self.boxRedPoint[index] = status
    end
end

--七天目标*********** start *****
function ActionModel:initSevenWalfare(index)
    self:setWalfareData(index)
    self:setWalfareGrowUpData(index)
    self:setHalfGiftData(index)
    self:setBoxRewardData(index)
end
--宝箱
function ActionModel:setBoxRewardData(index)
    local data = Config.DayGoalsData.data_all_target[index]
    self.boxRewardData = {}
    if data then
        for i,v in pairs(data) do
            table_insert(self.boxRewardData,v[1])
        end
        table_sort(self.boxRewardData,function(a,b) return a.id < b.id end)
    end
end
function ActionModel:getBoxRewardData()
    return self.boxRewardData or {}
end

--福利
function ActionModel:setWalfareData(index)
    local data = Config.DayGoalsData.data_welfarecollection[index]
    if data then
        self.welfareData = deepCopy(data)
    end
end
--成长目标
function ActionModel:setWalfareGrowUpData(index)
    local data = Config.DayGoalsData.data_growthtarget[index]

    self.welfareGrowData = {}
    self.welfareGiftData = {}
    if data then
        for i,v in ipairs(data) do
            local tab = {}
            local tab1 = {}
            if data[i] then
                for k,val in ipairs(data[i]) do
                    if val.target_type == 1 then
                        table_insert(tab, val)
                    elseif val.target_type == 2 then
                        table_insert(tab1, val)
                    end
                end
            end
            table_insert(self.welfareGrowData,tab)
            table_insert(self.welfareGiftData,tab1)
        end
    end
end
--福利礼包
function ActionModel:setHalfGiftData(index)
    local data = Config.DayGoalsData.data_halfdiscount[index]
    self.walfareHalfData = {}
    for i=1,7 do
        self.walfareHalfData[i] = {}
    end

    if data then
        for i,v in pairs(data) do
            table_insert(self.walfareHalfData[v[1].day], v[1])
        end
        for i=1,7 do
            table_sort(self.walfareHalfData[i],function(a,b) return a.id < b.id end)
        end
    end
end


function ActionModel:getWalfareData(day)
    if self.welfareData and self.welfareData[day] then
        return self.welfareData[day] or {}
    end
    return {}
end
function ActionModel:getWalfareGrowUpData(day)
    if self.welfareGrowData and self.welfareGrowData[day] then
        return self.welfareGrowData[day] or {}
    end
    return {}
end
function ActionModel:getWelfareGiftData(day)
    if self.welfareGiftData and self.welfareGiftData[day] then
        return self.welfareGiftData[day] or {}
    end
    return {}
end
function ActionModel:getWelfareHalfData(day)
    if self.walfareHalfData and self.walfareHalfData[day] then
        return self.walfareHalfData[day] or {}
    end
    return {}
end
--*********** 协议相关*********
--七天目标的福利领取
function ActionModel:setSevenGoalWelfareList(data)
    self.welfareList = {}
    for i=1,7 do
        self.welfareList[i] = {}
    end
    for i, v in pairs(data) do
        if v and v.day and self.welfareList[v.day] then
            table_insert(self.welfareList[v.day],v)
        end
    end
end
function ActionModel:getSevenGoalWelfareList(day)
    if self.welfareList and self.welfareList[day] then
        return self.welfareList[day] or {}
    end
    return {}
end
--更新数据
function ActionModel:updataGoalWelfareList(day, index, status)
    day = day or 1
    index = index or 1
    status = status or false
    self.welfareList[day][index].status = status
end

--七天目标的成长目标
function ActionModel:setSevenGoalGrowList(data)
    local grow_list = {}
    for i=1,7 do
        grow_list[i] = {}
    end
    for i, v in pairs(data) do
        table_insert(grow_list[v.day],v)
    end

    self.serverGrowListData = {}
    self.serverGiftListData = {}
    for i,v in pairs(grow_list) do
        local tab = {}
        local tab1 = {}
        for k,val in pairs(grow_list[i]) do
            if val.target_type == 1 then
                table_insert(tab, val)
            elseif val.target_type == 2 then
                table_insert(tab1, val)
            end
        end
        table_insert(self.serverGrowListData,tab)
        table_insert(self.serverGiftListData,tab1)
    end
end
function ActionModel:getServerGrowListData(day)
    if self.serverGrowListData and self.serverGrowListData[day] then
        return self.serverGrowListData[day] or {}
    end
    return {}
end
--更新数据
function ActionModel:updataGrowListData(day, index, status)
    day = day or 1
    index = index or 1
    status = status or false
    self.serverGrowListData[day][index].status = status
end

function ActionModel:getServerGiftListData(day)
    if self.serverGiftListData and self.serverGiftListData[day] then
        return self.serverGiftListData[day] or {}
    end
    return {}
end
--更新数据
function ActionModel:updataGiftListData(day, index, status)
    day = day or 1
    index = index or 1
    status = status or false
    self.serverGiftListData[day][index].status = status
end

--福利礼包礼包购买
function ActionModel:setHalfGiftList(data)
    self.halfGiftList = {}
    for i=1,7 do
        self.halfGiftList[i] = {}
    end
    
    for i=1, 7 do
        local half_list = self:getWelfareHalfData(i)
        for k,m in ipairs(half_list) do
            for b,val in ipairs(data) do
                if m.id == val.day then
                    table_insert(self.halfGiftList[i], val)
                end
            end
        end        
    end
end
function ActionModel:getHalfGiftList(day)
    if self.halfGiftList and self.halfGiftList[day] then
        return self.halfGiftList[day] or {}
    end
    return {}
end
--更新数据
function ActionModel:updataHalfListData(day, index, status)
    day = day or 1
    index = index or 1
    status = status or false
    self.halfGiftList[day][index].status = status
end

--活跃宝箱
function ActionModel:setSevenGoalBoxList(data)
    self.boxList = data
end
function ActionModel:getSevenGoalBoxList()
    if self.boxList then
        table_sort(self.boxList,function(a,b) return a.goal_id < b.goal_id end)
        return self.boxList
    end
    return {}
end
--更新数据
function ActionModel:updataBoxListData(index, status)
    index = index or 1
    status = status or false
    self.boxList[index].status = status
end
--*********** end *********************************************

--幸运值
function ActionModel:setLucklyRewardData()
    local data = Config.DialData.data_get_lucky_award
    self.lucky_num1, self.lucky_num2 = self:sortLucklyData(data)
end
function ActionModel:getLucklyRewardData(index)
    if not self.lucky_num1 or not self.lucky_num2 then return {} end
    if index == 1 then
        return self.lucky_num1 or {}
    elseif index == 2 then
        return self.lucky_num2 or {}
    end
end
--抽奖两个按钮
function ActionModel:setBuyRewardData()
    local data = Config.DialData.data_get_limit_open
    self.buy_num_list1, self.buy_num_list2 = self:sortLucklyData(data, true)
end
function ActionModel:getBuyRewardData(index)
    if not self.buy_num_list1 or not self.buy_num_list2 then return end
    if index == 1 then
        return self.buy_num_list1 or {}
    elseif index == 2 then
        return self.buy_num_list2 or {}
    end
end
function ActionModel:sortLucklyData(data, _type)
    local list1 = {}
    local list2 = {}
    for i,v in pairs(data) do
        if v.type == 1 then
            table_insert(list1,v)
        elseif v.type == 2 then
            table_insert(list2,v)
        end
    end
    if _type then
        table_sort(list1, function(a, b) return b.type2 > a.type2 end)
        table_sort(list2, function(a, b) return b.type2 > a.type2 end)
    else
        table_sort(list1, function(a, b) return b.id > a.id end)
        table_sort(list2, function(a, b) return b.id > a.id end)
    end
    return list1,list2
end
------- 探宝服务器返回----------
--寻宝数据
function ActionModel:setTreasureInitData(data)
    self.treasureInitData = {}
    for i,v in pairs(data) do
        self.treasureInitData[v.type] = v
    end
end
function ActionModel:getTreasureInitData(index)
    if not self.treasureInitData then return {} end
    return self.treasureInitData[index] or {}
end
--更新
function ActionModel:updataTreasureInitData(index, data)
    if not self.treasureInitData then return end
    self.treasureInitData[index].count = data.count
    self.treasureInitData[index].end_time = data.end_time
    self.treasureInitData[index].lucky = data.lucky
    self.treasureInitData[index].lucky_award = data.lucky_award
    self.treasureInitData[index].rand_lists = data.rand_lists
end
--更新日记
function ActionModel:updataTreasureLogData(index, data)
    if not self.treasureInitData then return end
    self.treasureInitData[index].log_list = data
end

--*********探宝红点*********
function ActionModel:lucklyRedPoint()
    self:setLucklyRewardData()
    self.tab_redpoint = {false,false}
    for val = 1, 2 do
        local data = self:getLucklyRewardData(val)
        local serve_data = self:getTreasureInitData(val)
        local status = false
        for i,v in ipairs(data) do
            local _bool = true
            for k,m in ipairs(serve_data.lucky_award) do
                if v.id == m.lucky then
                    _bool = false
                    break
                end
            end
            if serve_data.lucky < v.lucky_val  then
                _bool = false
            end

            if _bool == true then
                status = true
                break
            end
        end
        self:setLucklyTabRedPoint(val,status)
    end
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.lucky_treasure, self.tab_redpoint[1] or self.tab_redpoint[2])
end
--获取幸运探宝页签红点
function ActionModel:setLucklyTabRedPoint(index,status)
    self.tab_redpoint[index] = status
end
function ActionModel:getLucklyTabRedPoint(index)
    if self.tab_redpoint and self.tab_redpoint[index] then
        return self.tab_redpoint[index]
    end
    return false
end

--首充与累充的奖励
function ActionModel:setFirstRechargeData()
    local data = Config.ChargeData.data_first_charge_data
    self.firstRewardData1 = {}
    self.firstRewardData2 = {}
    for i,v in pairs(data) do
        if v.fid == 1 then
            table_insert(self.firstRewardData1,v)
        elseif v.fid == 2 then
            table_insert(self.firstRewardData2,v)
        end
    end
    table_sort(self.firstRewardData1, function(a, b) return b.id > a.id end)
    table_sort(self.firstRewardData2, function(a, b) return b.id > a.id end)
end
function ActionModel:getFirstRechargeData(index)
    if not self.firstRewardData1 or not self.firstRewardData2 then return end
    if index == 1 then
        return self.firstRewardData1 or {}
    elseif index == 2 then
        return self.firstRewardData2 or {}
    end
end

--充值的状态
function ActionModel:setFirstBtnStatus(data)
    if data and next(data) then
        self.firstBtnStatus = {}
        for i,v in ipairs(data) do
            self.firstBtnStatus[v.id] = v.status
        end
        local status = false
        for i,v in pairs(data) do
            if v.status == 1 then
                status = true
                break
            end
        end
        MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.first_charge, status)
    end
end
function ActionModel:getFirstBtnStatus(index)
    if not self.firstBtnStatus then return 0 end
    return self.firstBtnStatus[index] or 0
end

------------------@ 基金活动相关
-- 开启中的基金活动id
function ActionModel:setOpenFundIds( id_list )
    local _id_list = id_list or {}
    self.fund_id_list = {}  --主界面图标
    self.welfare_fund_id_list = {}  -- 福利图标  
    for k,v in ipairs(_id_list) do
        local data  = {}
        data.status = v.status
        data.show = v.show
        data.id  = v.id
        if v.show == 1 then
            table.insert(self.fund_id_list,data)
        elseif v.show == 0 then
            table.insert(self.welfare_fund_id_list,data)
        end
    end
    GlobalEvent:getInstance():Fire(ActionEvent.UPDATA_WELFARE_FUND__STATUS_EVENT, self.welfare_fund_id_list)
    self:checkFundRedStatus()
    self:checkWelfareFundRedStatus()
end

--获取是否是福利内基金
function ActionModel:getFundIsInWelfare()
    return self.welfare_fund_id_list or {}
end

-- 获取开启中的基金活动id
function ActionModel:getOpenFundIds(  )
    return self.fund_id_list or {}
end

-- 设置基金的数据
function ActionModel:setFundSrvData( data )
    self.fund_datas = self.fund_datas or {}
    if data and data.id then
        self.fund_datas[data.id] = data
        self:updateFundStatus(data.id, data.status)
    end
end

function ActionModel:setWelfareFundSrvData( data )
    self.welfare_fund_datas = self.welfare_fund_datas or {}
    if not self.welfare_fund_id_list then return end
    if data and data.id and next(self.welfare_fund_id_list) ~= nil then
        self.welfare_fund_datas[data.id] = data
        self:updateWelfareFundStatus(data.id, data.status)
    end
end

-- 获取基金数据
function ActionModel:getFundSrvDataById( id )
    self.fund_datas = self.fund_datas or {}
    return self.fund_datas[id] or {}
end

-- 清除基金缓存数据
function ActionModel:clearFundSrvData(  )
    self.fund_datas = {}
end

function ActionModel:updateFundStatus( id, status )
    self.fund_id_list = self.fund_id_list or {}
    for k,v in pairs(self.fund_id_list) do
        if v.id == id then
            v.status = status
            break
        end
    end
    self:checkFundRedStatus()
end

function ActionModel:updateWelfareFundStatus( id, status )
    self.welfare_fund_id_list = self.welfare_fund_id_list or {}
    for k,v in pairs(self.welfare_fund_id_list) do
        if v.id == id then
            v.status = status
            break
        end
    end
    self:checkWelfareFundRedStatus()
end

-- 检测基金领取红点数据
function ActionModel:checkFundRedStatus(  )
    self.fund_id_list = self.fund_id_list or {}
    for k,v in pairs(self.fund_id_list) do
        if v.id == FundType.type_one then
            self:updateFundRedStatus(FundRedIndex.fund_get_one, v.status == 1)
            self:updateFundRedStatus(FundRedIndex.fund_buy_one, v.status == 0)
        elseif v.id == FundType.type_two then
            self:updateFundRedStatus(FundRedIndex.fund_get_two, v.status == 1)
            self:updateFundRedStatus(FundRedIndex.fund_buy_two, v.status == 0)
        end
    end
end



function ActionModel:checkWelfareFundRedStatus(  )
    self.welfare_fund_id_list = self.welfare_fund_id_list or {}
    for k,v in pairs(self.welfare_fund_id_list) do
        if v.id == WelfareIcon.fund_one or v.id == WelfareIcon.fund_two then
            if v.show == 0 then
                WelfareController:getInstance():setWelfareStatus(v.id,v.status == 1)
            end
        end
    end
end

-- function ActionModel:updateWelfareFundRedStatus( bid, status )
--     local _status = self.welfare_fund_red_list[bid]
--     if _status == status then return end
--     -- 购买的红点只有登陆时才显示，点击之后消失，之后不再显示
--     -- if (bid == FundRedIndex.fund_buy_one or bid == FundRedIndex.fund_buy_two) and _status == false then
--     --     return
--     -- end

--     self.welfare_fund_red_list[bid] = status

--     local red_status = false
--     for k,v in pairs(self.welfare_fund_red_list) do
--         if v == true then
--             red_status = true
--             break
--         end
--     end
--     WelfareController:getInstance():setWelfareStatus(bid,status)

--     --welfareController:getInstance():setFunctionTipsStatus(MainuiConst.icon.welfare, red_status)
--     --GlobalEvent:getInstance():Fire(ActionEvent.UPDATA_FUND_RED_STATUS_EVENT, bid, status)
-- end

function ActionModel:getWelfareFundRedStatusByBid( bid )
    return self.welfare_fund_id_list[bid]
end


-- 更新基金红点数据
function ActionModel:updateFundRedStatus( bid, status )
    local _status = self.fund_red_list[bid]
    if _status == status then return end
    -- 购买的红点只有登陆时才显示，点击之后消失，之后不再显示
    if (bid == FundRedIndex.fund_buy_one or bid == FundRedIndex.fund_buy_two) and _status == false then
        return
    end

    self.fund_red_list[bid] = status

    local red_status = false
    for k,v in pairs(self.fund_red_list) do
        if v == true then
            red_status = true
            break
        end
    end
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.fund, red_status)
    GlobalEvent:getInstance():Fire(ActionEvent.UPDATA_FUND_RED_STATUS_EVENT, bid, status)
end

-- 根据红点id获取红点状态
function ActionModel:getFundRedStatusByBid( bid )
    return self.fund_red_list[bid]
end

function ActionModel:sortItemList(list)
    local tempsort = {
        [0] = 2,  -- 0 未领取放中间
        [1] = 1,  -- 1 可领取放前面
        [2] = 3,  -- 2 已领取放最后
    }
    local function sortFunc(objA,objB)
        if objA.status ~= objB.status then
            if tempsort[objA.status] and tempsort[objB.status] then
                return tempsort[objA.status] < tempsort[objB.status]
            else
                return false
            end
        else
            return objA.aim < objB.aim
        end
    end
    table.sort(list, sortFunc)
end


--******** 设置倒计时
function ActionModel:setCountDownTime(node,less_time,is_over)
    if tolua.isnull(node) then return end
    doStopAllActions(node)
    if less_time > 0 then
        self:setTimeFormatString(node,less_time,is_over)
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(node)
                if is_over then
                    node:setString(TI18N("活动已结束"))
                    node:setTextColor(color_text[1])
                else
                    node:setString("00:00:00")
                    node:setTextColor(color_text[2])
                end
            else
                self:setTimeFormatString(node,less_time,is_over)
            end
        end))))
    else
        self:setTimeFormatString(node,less_time,is_over)
    end
end
function ActionModel:setTimeFormatString(node,time,is_over)
    if time > 0 then
        node:setString(TimeTool.GetTimeForFunction(time))
    else
        doStopAllActions(node)
        if is_over then
            node:setString(TI18N("活动已结束"))
            node:setTextColor(color_text[1])
        else
            node:setString("00:00:00")
            node:setTextColor(color_text[2])
        end
    end
end
--*************************

-----------每日红点仅显示一次-----------
function ActionModel:updateGiftRedPointStatus(data)
    local bid = data.bid
    self.gift_id_list = self.gift_id_list or {}
    self.gift_id_list[bid] = data
end

function ActionModel:getGiftRedStatusByBid(bid)
    if not self.gift_id_list then return end
    local list = self.gift_id_list[bid]
    if list then
        return list.status
    end
end

function ActionModel:setGiftRedStatus(data)
    if not self.gift_id_list then return end
    local bid = data.bid
    local status = data.status
    local list = self.gift_id_list[bid]
    if list and list.status ~= status then
        list.status = status
        GlobalEvent:getInstance():Fire(ActionEvent.SHOW_ACTIVITY_RED_POINT, bid, status)
    end
end
------------------------------------------
--神装道具商店
function ActionModel:setColthesDataInit()
    self.hero_clothes_data = {}
end
function ActionModel:setHeroClothesShopData(period)
    local data = Config.HolidayHolyEqmData.data_reward_list
    if data and data[period] then
        self.hero_clothes_data = {}
        for i,v in pairs(data[period]) do
            table_insert(self.hero_clothes_data,v)
        end
        table_sort(self.hero_clothes_data,function(a,b) return a.id < b.id end)
    end
end
function ActionModel:getHeroClothesShopData()
    if self.hero_clothes_data and next(self.hero_clothes_data) ~= nil then
        return self.hero_clothes_data
    end
    return nil
end
function ActionModel:setLimitTypeData(data)
    self.limit_type_data = {}
    for i,v in pairs(data) do
        self.limit_type_data[v.id] = v
    end
end
function ActionModel:getLimitTypeData(id)
    if self.limit_type_data and self.limit_type_data[id] then
        return self.limit_type_data[id]
    end
    return nil
end

--杂货铺数据
function ActionModel:setStoneShopData(data)
    self.stone_shop_data = {}
    for i,v in pairs(data) do
        self.stone_shop_data[v.id] = v
    end
end
function ActionModel:getStoneShopData(id)
    if self.stone_shop_data and self.stone_shop_data[id] then
        return self.stone_shop_data[id]
    end
    return nil
end

--7天连充数据
function ActionModel:setSevenChargeData(data)
    if not data or next(data) == nil then return end

    if not self.seven_charge_list then --7天奖励数据
        self.seven_charge_list = {}
    end
    if not self.daily_reward_list then --7天具体奖励列表
        self.daily_reward_list = {}
    end

    self.cur_day = 1 --当前天数
    if data.args and next(data.args) ~= nil then
        local day_list = keyfind('args_key', 1, data.args) or nil
        if day_list then
            self.cur_day = day_list.args_val
            if self.cur_day > 7 then
                self.cur_day = 7
            end
        end
    end
    self.is_get_resignin = false --是否已补领 0：否 1：是  
    if data.args and next(data.args) ~= nil then
        local day_list = keyfind('args_key', 2, data.args) or nil
        if day_list and day_list.args_val == 1 then
            self.is_get_resignin = true
        end
    end

    if data.aim_list and next(data.aim_list) ~= nil then
        for k, v in pairs(data.aim_list) do
            self.seven_charge_list[k] = v
            self.daily_reward_list[k] = v.item_list
            for a, j in pairs(v.aim_args) do
                local value = j.aim_args_key
                if value == ActionExtType.RechageCurCount then --目标充值数额
                    self.seven_charge_list[k].need_charge = j.aim_args_val
                elseif value == ActionExtType.ExbItemBid then --展位物品bid
                    self.seven_charge_list[k].item_bid = j.aim_args_val
                elseif value == ActionExtType.ExbItemNum then --展位物品num
                    self.seven_charge_list[k].item_num = j.aim_args_val
                elseif value == ActionExtType.ResigninCharge then --补签待充值数额
                    self.seven_charge_list[k].re_signin_charge = j.aim_args_val
                end
            end
        end
    end
end
--获取当前连充第几天
function ActionModel:getCurChargeDay()
    if self.cur_day then
        return self.cur_day
    end
    return 1
end
--获取是否已补领，即补领次数用完
function ActionModel:getIsGetResignin()
    return self.is_get_resignin or false
end
--获取7天奖励数据
function ActionModel:getSevenChargeData()
    if self.seven_charge_list then
        return self.seven_charge_list
    end
    return nil
end
--获取指定天奖励数据
function ActionModel:getSevenChargeDataByDay(day)
    if self.seven_charge_list then
        for _,v in pairs(self.seven_charge_list) do
            if v.aim == day then
                return v
            end
        end
    end
    return nil
end
--获取指定天的具体奖励列表
function ActionModel:getDailyRewardListById(id)
    if self.daily_reward_list and self.daily_reward_list[id] then
        return self.daily_reward_list[id]
    end
    return nil
end

--皮肤抽奖
function ActionModel:setLotteryItemData(data,id)
    local config = Config.HolidaySkinDrawData.data_lottery_stock
    if config and config[id] then
        local list = {}
        --为0的时候代表未被抽取掉
        for i,v in pairs(config[id]) do
            list[v.sort] = 1
        end
        for i,v in pairs(data) do
           list[v.sort] = 0
        end
        self.lottery_item_data = list
    end
end
--更新
function ActionModel:updataLotteryItemData(id)
    if self.lottery_item_data and self.lottery_item_data[id] then
        self.lottery_item_data[id] = 1
    end
end
function ActionModel:getLotteryItemData(id)
    if self.lottery_item_data and self.lottery_item_data[id] then
        return self.lottery_item_data[id]
    end
    return 0
end

--代金券
function ActionModel:setPerferPrizeByJsonObj(jsonObj)
    jsonObj = jsonObj or {}
    local data = jsonObj.data
    if data == nil then
        return
    end
    if data.banner then
        if data.banner.img then
            self:setPerferDownLoadPng(data.banner.img)
        end
        if data.banner.url then
            self:setPerferJumpurl(data.banner.url)
        end
    end
    if data.coupons then
        self:setSavePerferData(data.coupons)
        local list = {}
        local cur_time = GameNet:getInstance():getTime()
        for i,v in pairs(data.coupons) do
            local end_ts = tonumber(v.end_ts)
            if end_ts > cur_time then
                table.insert(list,v)
            end
        end
        self:setSavePerferData(list)
        local status = #list
        if status >= 1 then
            status = 1
        end
        GlobalEvent:getInstance():Fire(ActionEvent.ACTION_PERFER_ISOPEN, status)
    end
    GlobalEvent:getInstance():Fire(ActionEvent.ACTION_PERFER_GET_DATA_EVENT)
end
function ActionModel:setSavePerferData(data)
    self.perfer_data = data
end
function ActionModel:getSavePerferData()
    if self.perfer_data then
        return self.perfer_data
    end
    return {}
end
--获取网页图片地址
function ActionModel:setPerferDownLoadPng(path)
    self.download_path = path
end
function ActionModel:getPerferDownLoadPng()
    if self.download_path then
        return self.download_path
    end
    return nil
end
--获取跳转的地址
function ActionModel:setPerferJumpurl(url)
    self.jump_url = url
end
function ActionModel:getPerferJumpurl()
    if self.jump_url then
        return self.jump_url
    end
    return nil
end

--设置不放回抽奖camp_id
function ActionModel:setFortuneBagCampId(camp_id)
    self.fortune_bag_camp_id = camp_id
end

--获取不放回抽奖camp_id
function ActionModel:getFortuneBagCampId()
    if self.fortune_bag_camp_id then
        return self.fortune_bag_camp_id
    end
    return 17553
end

-- 设置幸运锦鲤基础数据
function ActionModel:setLuckyDogData(data)
    if data == nil or data.period == nil or data.info == nil then return end

    self.lucky_dog_data = {}
    self.lucky_dog_data.period = data.period
    self.lucky_dog_data.start_time = data.start_time
    self.lucky_dog_data.end_time = data.end_time
    self.lucky_dog_data.info = {}
    for k, v in pairs(data.info) do
        self.lucky_dog_data.info[v.period] = deepCopy(v)
    end
end

function ActionModel:getLuckyDogData()
    return self.lucky_dog_data
end

-- 获取幸运锦鲤当前期数
function ActionModel:getLuckyDogPeriod()
    if self.lucky_dog_data and self.lucky_dog_data.period then
        return self.lucky_dog_data.period
    end
end

-- 获取幸运锦鲤当前期数基础数据
function ActionModel:getLuckyDogBaseData(period)
    if self.lucky_dog_data and self.lucky_dog_data.info then
        for k, v in pairs(self.lucky_dog_data.info) do
            if v.period == period then
                return v
            end
        end
    end
end

-- 获取任务数据
function ActionModel:getLuckyDogTaskData(period)
    local ret_list = {}
    local info = self:getLuckyDogBaseData(period)
    if info and info.quests then
        for k, v in pairs(info.quests) do
            local item_data = deepCopy(v)
            item_data.index = k
            item_data.state = info.state
            item_data.period = info.period
            table_insert(ret_list, item_data)
        end
    end
    return ret_list
end

-- 获得幸运锦鲤该期的红点
function ActionModel:getLuckyDogPeriodRed(period)
    if self.lucky_dog_data.info and self.lucky_dog_data.info[period] then
        for k, v in pairs(self.lucky_dog_data.info[period].quests) do
            if v.finish == 1 and self.lucky_dog_data.info[period].state == 1 then
                return true
            end
        end
        return self.lucky_dog_data.info[period].finish == 1
    end
    return false
end

-- 获得幸运锦鲤所有期红点
function ActionModel:getLuckyDogAllRed()
    if self.lucky_dog_data and self.lucky_dog_data.info then
        for k, v in pairs(self.lucky_dog_data.info) do
            if self:getLuckyDogPeriodRed(k) then
                return true
            end
        end
    end
    return false
end

-- 获得是否参与了该期的幸运锦鲤
function ActionModel:getLuckyDogParticipateIn(period)
    if self.lucky_dog_data and self.lucky_dog_data.info and self.lucky_dog_data.info[period] then
        for k, v in pairs(self.lucky_dog_data.info[period].quests) do
            if v.finish == 2 then
                return true
            end
        end
    end
    return false
end

--设置定时领奖数据
function ActionModel:setActionTimeCollectData( data )
    self.action_time_collect_data = data
end

--获取定时领奖数据
function ActionModel:getActionTimeCollectData( )
    return self.action_time_collect_data
end

-- 设置甜蜜大作战数据
function ActionModel:setSweetData( data )
    self.sweet_data = data
    self:calculSweetAwardStatus()
end

function ActionModel:getSweetData(  )
    return self.sweet_data
end

-- 获取最大累计积分值
function ActionModel:getSweetMaxScore(  )
    if self.sweet_data then
        return self.sweet_data.max_acc_score or 0
    end
    return 0
end

-- 计算当前是否有可领取的奖励
function ActionModel:calculSweetAwardStatus(  )
    self.sweet_award_status = fasle
    if self.sweet_data and self.sweet_data.max_acc_score and self.sweet_data.max_acc_score > 0 then
        -- 当前进度
        for k,cfg in pairs(Config.HolidayValentinesData.data_award) do
            -- 配置表为千分比
            local limit_score = cfg.count/1000*self.sweet_data.max_acc_score
            if limit_score <= self.sweet_data.acc_score then -- 可领取
                self.sweet_award_status = true
                for _,v in pairs(self.sweet_data.reward) do
                    if v.id == cfg.id then -- 已领取过了
                        self.sweet_award_status = fasle
                        break
                    end
                end
            end
            if self.sweet_award_status == true then 
                break
            end
        end
    end
end

-- 获取当前是否有奖励可领取
function ActionModel:getSweetAwardStatus(  )
    return self.sweet_award_status or false
end

function ActionModel:setWhiteDayData(data)
    if data == nil then return end
    self.white_day_data = data
end

function ActionModel:getWhiteDayHeadId()
    if self.white_day_data and self.white_day_data.id then
        local tab_vo = ActionController:getInstance():getActionSubTabVo(ActionRankCommonType.white_day)
        if tab_vo then
            local camp_id = tab_vo.camp_id
            local boss_list = Config.HolidayValentineBossData.data_boss_list[camp_id]
            if boss_list then
                local boss_config = boss_list[self.white_day_data.id]
                if boss_config and boss_config.head_icon then
                    return boss_config.head_icon
                end
            end
        end
    end
    return 2017
end

--获取女神试炼伤害值对应的奖励数据
--返回 最大伤害值  和 box个数
function ActionModel:getHarmRewardInfo(harm_count)
    harm_count = harm_count or 0
    if self.white_day_data == nil or self.white_day_data.id == nil then return 0 end
    local config_list = Config.HolidayValentineBossData.data_award_list[self.white_day_data.id]
    if config_list and next(config_list) ~= nil then
        table_sort(config_list, function(a, b)
             return a.min < b.min
        end)
        local len = #config_list
        local max_high = config_list[len].max
        for i,config in ipairs(config_list) do
            if i == 1 and harm_count > config.min and harm_count <= config.max then
                return config.box_count or 0, config, max_high
            elseif i == len and harm_count > config.min then
                return config.box_count or 0, config,max_high
            elseif harm_count > config.min and harm_count <= config.max then
                return config.box_count or 0, config, max_high
            end
        end
    end
    return 0
end

-- 设置超值月卡数据
function ActionModel:setSuperWeekData(data)
    if data == nil then return end
    self.super_week_data = data
end

function ActionModel:getSuperWeekAward()
    if self.super_week_data and self.super_week_data.award_list then
        table_sort(self.super_week_data.award_list, function(a, b)  return a.id < b.id end)
        return self.super_week_data.award_list
    end
    return {}
end

function ActionModel:__delete()
end
