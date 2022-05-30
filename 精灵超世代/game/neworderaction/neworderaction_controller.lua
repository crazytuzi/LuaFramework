-- --------------------------------------------------------------------
-- 全新战令（英灵战令）
--控制模块
-- @author: yuanqi@shiyue.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-02-20
-- --------------------------------------------------------------------
NeworderactionController = NeworderactionController or BaseClass(BaseController)

function NeworderactionController:config()
    self.model = NeworderactionModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function NeworderactionController:getModel()
    return self.model
end

function NeworderactionController:registerEvents()
end

function NeworderactionController:registerProtocals()
    self:RegisterProtocal(28700, "handle28700")
    self:RegisterProtocal(28701, "handle28701")
    self:RegisterProtocal(28703, "handle28703")
    self:RegisterProtocal(28704, "handle28704")
    self:RegisterProtocal(28705, "handle28705")
    self:RegisterProtocal(28706, "handle28706")
    self:RegisterProtocal(28707, "handle28707")
    self:RegisterProtocal(28708, "handle28708")
end

--任务信息
function NeworderactionController:send28700()
    self:SendProtocal(28700, {})
end

function NeworderactionController:handle28700(data)
    self.model:setCurPeriod(data.period) --周期数
    self.model:setCurDay(data.cur_day) --天数
    self.model:setRMBStatus(data.rmb_status) --是否激活特权
    self.model:setCurLev(data.lev) --当前等级
    self.model:setCurExp(data.exp) --当前经验
    self.model:setInitTaskData(data.list) --任务列表
    self.model:setPeriodLev(data.period_lev) --周期开始等级
    self.model:setDayLev(data.day_lev) --天开始等级
    self.model:setWeekLev(data.week_lev) --周开始等级
    self.dispather:Fire(NeworderactionEvent.OrderAction_Init_Event, data)
end

--任务更新
function NeworderactionController:handle28701(data)
    self.model:updataTaskData(data)
    self.dispather:Fire(NeworderactionEvent.OrderAction_TaskGet_Event)
end

--提交任务
function NeworderactionController:send28702(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(28702, proto)
end

--等级奖励
function NeworderactionController:send28703()
    self:SendProtocal(28703, {})
end

function NeworderactionController:handle28703(data)
    self.model:setLevShowData(data.reward_list)
    self.dispather:Fire(NeworderactionEvent.OrderAction_LevReward_Event, data)
end

--领取等级奖励
function NeworderactionController:send28704(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(28704, proto)
end

function NeworderactionController:handle28704(data)
    message(data.msg)
end

-- 等级变更（只会主动推）
function NeworderactionController:handle28705(data)
    self.model:setCurExp(data.exp)
    self.model:setCurLev(data.lev)
    self.dispather:Fire(NeworderactionEvent.OrderAction_Updata_LevExp_Event, data)
end

--进阶卡情况
function NeworderactionController:send28706()
    self:SendProtocal(28706, {})
end

function NeworderactionController:handle28706(data)
    self.model:setRMBStatus(data.rmb_status)
    self.model:setGiftStatus(data.list)
    self.dispather:Fire(NeworderactionEvent.OrderAction_BuyGiftCard_Event)
end

--是否要弹窗
function NeworderactionController:send28707()
    self:SendProtocal(28707, {})
end

function NeworderactionController:handle28707(data)
    self.dispather:Fire(NeworderactionEvent.OrderAction_IsPopWarn_Event, data)
end

--周期重置红点
function NeworderactionController:send28708()
    self:SendProtocal(28708)
end

function NeworderactionController:handle28708(data)
    if data and data.flag and data.flag == 1 then
        self.model:setPeriodRed(true)
    end
    self.model:setPeriodRed(false)
end

--打开主界面
function NeworderactionController:openOrderActionMainView(status)
    if status == true then
        -- local configlv = Config.HolidayNewWarOrderData.data_constant.limit_lev
        -- local configday = Config.HolidayNewWarOrderData.data_constant.open_srv_day
        -- local open_srv_day = RoleController:getInstance():getModel():getOpenSrvDay()
        -- local rolevo = RoleController:getInstance():getModel():getRoleVo()
        -- -- 是否开启planes_war_order_data:
        -- if configday and configlv and rolevo and (open_srv_day < configday.val or rolevo.lev < configlv.val) then
        --     message(string.format(TI18N("角色%d级且开服%d天开启"),configlv.val,configday.val))
        --     return
        -- end

        if not self.new_orderaction_window then
            self.new_orderaction_window = NewOrderactionWindow.New()
        end
        self.new_orderaction_window:open()
    else
        if self.new_orderaction_window then
            self.new_orderaction_window:close()
            self.new_orderaction_window = nil
        end
    end
end

function NeworderactionController:getOrderActionMainRoot()
    if self.order_action_view then
        return self.order_action_view
    end
    return nil
end

--奖励总览
function NeworderactionController:openUntieRewardView(status)
    if status == true then
        if not self.untie_reward_view then
            self.untie_reward_view = NewUntieRewardWindow.New()
        end
        self.untie_reward_view:open()
    else
        if self.untie_reward_view then
            self.untie_reward_view:close()
            self.untie_reward_view = nil
        end
    end
end

--打开活动结束警告界面
function NeworderactionController:openEndWarnView(status, day)
    if status == true then
        if not self.end_warn_view then
            self.end_warn_view = NewOrderActionEndWarnWindow.New()
        end
        self.end_warn_view:open(day)
    else
        if self.end_warn_view then
            self.end_warn_view:close()
            self.end_warn_view = nil
        end
    end
end

--购买进阶卡
function NeworderactionController:openBuyCardView(status)
    if status == true then
        if not self.buy_card_view then
            self.buy_card_view = NewUntieRewardWindow1.New()
        end
        self.buy_card_view:open()
    else
        if self.buy_card_view then
            self.buy_card_view:close()
            self.buy_card_view = nil
        end
    end
end

function NeworderactionController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
