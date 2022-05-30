-- --------------------------------------------------------------------
-- 周活动
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
WeeklyActivitiesController = WeeklyActivitiesController or BaseClass(BaseController)

function WeeklyActivitiesController:config()
    self.model = WeeklyActivitiesModel.New(self)
    self.dispather = GlobalEvent:getInstance()  
    self.mainui_ctrl = MainuiController:getInstance()
    self.weeklyactivities_win = nil      
    self.tip_status = {}          
end

function WeeklyActivitiesController:getModel()
    return self.model
end


function WeeklyActivitiesController:registerEvents()
    if self.add_goods_event == nil then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
            self:weeklyGameUpdateTipsStatus()
        end)
    end
    
    if  self.del_goods_event == nil then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
            self:weeklyGameUpdateTipsStatus()
        end)
    end

    if self.modify_goods_event == nil then 
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
            self:weeklyGameUpdateTipsStatus()
        end)
    end
end

function WeeklyActivitiesController:registerProtocals()
    self:RegisterProtocal(29200, "handle_29200") --请求周活动数据
    self:RegisterProtocal(29201, "handle_29201") --灵泉培育请求
    self:RegisterProtocal(29202, "handle_29202") --下发任务信息
    self:RegisterProtocal(29203, "handle_29203") --商城数据
    self:RegisterProtocal(29204, "handle_29204") --购买结果
    self:RegisterProtocal(29205, "handle_29205") --兑换数据
    self:RegisterProtocal(29206, "handle_29206") --兑换结果
    self:RegisterProtocal(29207, "handle_29207") --石室数据
    self:RegisterProtocal(29208, "handle_29208") --左右跳协议
    self:RegisterProtocal(29209, "handle_29209") --抽奖结果
    self:RegisterProtocal(29210, "handle_29210") --地宫数据
    self:RegisterProtocal(29211, "handle_29211") --地宫探索数据
    self:RegisterProtocal(12742, "handle12742")
    --self:RegisterProtocal(12900, "handle_12900") --请求获取排行榜数据
end

--请求周活动数据
function WeeklyActivitiesController:send_29200()
    local protocal = {}
    self:SendProtocal(29200,protocal)
end
--请求石室数据
function WeeklyActivitiesController:send_29207()
    local protocal = {}
    self:SendProtocal(29207,protocal)
end

function WeeklyActivitiesController:handle_29207( data )
    if data then
        --self:updateTipsStatus()
        GlobalEvent:getInstance():Fire(WeeklyActivitiesEvent.INIT_STONE_CHAMBER, data)
    end
end
--石室左右跳请求
function WeeklyActivitiesController:send_29208()
    local protocal = {}
    protocal.id = 0
    self:SendProtocal(29208,protocal)
end

function WeeklyActivitiesController:handle_29208( data )
    if data then
        GlobalEvent:getInstance():Fire(WeeklyActivitiesEvent.AROUND_JUMP, data)
    end
end

function WeeklyActivitiesController:send_29209()
    local protocal = {}
    self:SendProtocal(29209,protocal)
end
--石室抽奖返回
function WeeklyActivitiesController:handle_29209( data )
    if data then
        GlobalEvent:getInstance():Fire(WeeklyActivitiesEvent.LOTTERY_RESULTS, data)
    end
end

--请求地宫数据
function WeeklyActivitiesController:send_29210()
    local protocal = {}
    self:SendProtocal(29210,protocal)
end

--获取地宫数据
function WeeklyActivitiesController:handle_29210( data )
    if data then
        if data.tier_num == 0 then
            self:updateItemTipsStatus( 1 , true )
            self.is_show_activice_item1 = true
        end
        GlobalEvent:getInstance():Fire(WeeklyActivitiesEvent.INIT_UNDERGROUND_DATA, data)
    end
end

--请求灵泉培育
function WeeklyActivitiesController:send_29201(item_id,buy_id)
    local protocal = {}
    protocal.id = 0--item_id
    protocal.buy_id = buy_id
    self:SendProtocal(29201,protocal)
end


function WeeklyActivitiesController:send_29211(item_id,buy_id)
    local protocal = {}
    protocal.id = 0--item_id
    protocal.buy_id = buy_id
    self:SendProtocal(29211,protocal)
end

function WeeklyActivitiesController:handle_29211( data )
    if data then
        GlobalEvent:getInstance():Fire(WeeklyActivitiesEvent.EXPLORE_DATA, data)
    end
end
--返回周活动数据
function WeeklyActivitiesController:handle_29200( data )
    if data then
        dump(data,"handle_29200")
        self.model:setWeeklyActivityData( data )
        GlobalEvent:getInstance():Fire(WeeklyActivitiesEvent.UPDATE_WEEK_DATA, data)
        local hasTime = data.end_time-GameNet:getInstance():getTime() --剩余时间
        local isStart = GameNet:getInstance():getTime() - data.start_time >= -3   -- 是否开启
        local activice_id = self.model:getWeeklyActivityId()
        if activice_id > 0 and hasTime > 0 and isStart then
            delayOnce(function ( )
                if self.weeklyactivities_win then 
                    self.weeklyactivities_win:close()
                    self.weeklyactivities_win = nil
                    return
                end
                self.mainui_ctrl:addFunctionIconById(MainuiConst.icon.WeekAction)
                self:weeklyGameUpdateTipsStatus()
                if activice_id == 1 then
                    self:send_29210()
                end
            end,0.5)
        end
    end
end

function WeeklyActivitiesController:weeklyGameUpdateTipsStatus()
    local activice_id = self.model:getWeeklyActivityId()
    if activice_id == 0 then return end
    local item_ids = {17447,17449,17451}
    local count = BackpackController:getInstance():getModel():getItemNumByBid(item_ids[activice_id]) or 0
    --return count > 0
    self.is_show_activice_item1 = count > 0
    self:updateItemTipsStatus( 1 , self.is_show_activice_item1 )

end

function WeeklyActivitiesController:isShowWeeklyActivityForItme1(  )
    return self.is_show_activice_item1
end

function WeeklyActivitiesController:setFunctionTipsStatus( index , is_show )
    self.tip_status[index] = is_show
    local is_show_status  = false 
    for k,v in pairs(self.tip_status) do
        if v == true then 
            is_show_status = true
            break
        end
    end
    self.mainui_ctrl:getInstance():setFunctionTipsStatus(MainuiConst.icon.WeekAction,is_show_status )
end

function WeeklyActivitiesController:updateItemTipsStatus( index , is_show )
    if self.weeklyactivities_win then 
        self.weeklyactivities_win:setTabStatus( index, is_show)
    end
    self:setFunctionTipsStatus( index , is_show )
end

--根据Id周活动主界面红点状态
function WeeklyActivitiesController:getTipsStatus(index)
    return self.tip_status[index] or false
end

--灵泉培育返回
function WeeklyActivitiesController:handle_29201( data )
    dump(data,"灵泉培育返回")
    if data then
        self.model:setCultivateCount( data.cultivate_num )
        GlobalEvent:getInstance():Fire(WeeklyActivitiesEvent.UPDATE_CULTIVACE,data)
    end
end

--请求任务消息
function WeeklyActivitiesController:send_29212( )
    print("请求任务消息")
    self:SendProtocal(29212,{})
end

--下发任务信息
function WeeklyActivitiesController:handle_29202( data )
    if data then
        --dump(data,"handle_29202")
        self.model:setWeeklyTaskData( data )
        local b = false
        for k, v in ipairs(data.info_list or {}) do
            if v.state == 1 then
                b = true
                break
            end
        end
        self:updateItemTipsStatus(2, b)
        GlobalEvent:getInstance():Fire(WeeklyActivitiesEvent.UPDATE_WEEK_TASK_DATA,data)
    end
end

--请求领取任务奖励
function WeeklyActivitiesController:send_29202( round, id )
    local protocal = {}
    protocal.round = round
    protocal.id = id
    self:SendProtocal(29202, protocal)
end

--下发商城数据
function WeeklyActivitiesController:handle_29203( data )
    if data then
        --dump(data,"下发商城数据")
        local b = data.info_list and data.info_list[1] and data.info_list[1].limit - data.info_list[1].num > 0
        self:updateItemTipsStatus(3, b)
        GlobalEvent:getInstance():Fire(WeeklyActivitiesEvent.UPDATE_WEEK_SHOP_DATA, data)
    end
end

--请求商城数据
function WeeklyActivitiesController:send_29203()
    self:SendProtocal(29203,{})
end

--返回购买结果
function WeeklyActivitiesController:handle_29204( data )
    if data then
    end
end

--请求购买
function WeeklyActivitiesController:send_29204(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(29204,protocal)
end

--下发兑换数据
function WeeklyActivitiesController:handle_29205( data )
    if data then
        --dump(data,"下发兑换数据")
        self.model:setExchangeData(data)
        GlobalEvent:getInstance():Fire(WeeklyActivitiesEvent.UPDATE_WEEK_EXCHANGE_DATA, data)
    end
end

--请求兑换数据
function WeeklyActivitiesController:send_29205(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(29205,protocal)
end
--返回兑换结果
function WeeklyActivitiesController:handle_29206( data )
	--dump(data,"handle_29206")
    if data then
    end
end

--请求兑换 type 1是当前的兑换，2是上一期 的兑换
function WeeklyActivitiesController:send_29206(type,id,item_id)
    local protocal = {}
    protocal.type = type
    protocal.id = id
    protocal.item_id = item_id or 0
    self:SendProtocal(29206,protocal)
end

--==============================--
--desc:登录请求的协议
--@return 
--==============================--
function WeeklyActivitiesController:requestInitProto()
    --self:sender14100() --签到红点
end

function WeeklyActivitiesController:openMainWindow( status ,index)
    --print("97896795867394--------------------------->>")
    if status then 
        if not self.weeklyactivities_win then
            self.weeklyactivities_win = WeeklyActivitiesMainWindow.New()
        end
        self.weeklyactivities_win:open()
        if index then
            self.weeklyactivities_win:changePanelByIndex(index)
        end
        --self:send_29203()
        --self:send_29205()
    else
        if self.weeklyactivities_win then 
            self.weeklyactivities_win:close()
            self.weeklyactivities_win = nil
        end
    end
end

function WeeklyActivitiesController:openRankWindow( status ,index)
    if status == true then
        if self.cultivate == nil then
            self.cultivate = WeeklyRankWindow.New()
        end
        self.cultivate:open()
        self.cultivate:selectedTabCallBack(index)
    else
        if self.cultivate then 
            self.cultivate:close()
            self.cultivate = nil
        end

    end 
end

--获取排行榜奖励数据
function WeeklyActivitiesController:getRandListData(  )
    local config_award = {
        Config.WeekExploreData.data_rank_reward,
        Config.WaterBreedData.data_rank_reward,
        Config.WeekStoneRoomData.data_rank_reward,
    }
    local activice_id = self.model:getWeeklyActivityId()
    local tmp_list = deepCopy(config_award[activice_id])
    return tmp_list
end

--获取活动说明
function WeeklyActivitiesController:getActiviceDes(  )
    local config_rule = {
        Config.WeekExploreData.data_const["rules"],
        Config.WaterBreedData.data_const["water_breed_tips"],
        Config.WeekStoneRoomData.data_const["rules"],
    }
    local activice_id = self.model:getWeeklyActivityId()
    return config_rule[activice_id].desc
end
