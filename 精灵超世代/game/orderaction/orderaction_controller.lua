--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 战令控制模块
-- @DateTime:    2019-04-19 10:07:24
-- *******************************
OrderActionController = OrderActionController or BaseClass(BaseController)

function OrderActionController:config()
    self.model = OrderActionModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function OrderActionController:getModel()
    return self.model
end

function OrderActionController:registerEvents()

end

function OrderActionController:registerProtocals()
    self:RegisterProtocal(25300, "handle25300")
    self:RegisterProtocal(25301, "handle25301")
    self:RegisterProtocal(25303, "handle25303")
    self:RegisterProtocal(25304, "handle25304")
    self:RegisterProtocal(25305, "handle25305")
    self:RegisterProtocal(25306, "handle25306")
    self:RegisterProtocal(25307, "handle25307")
    self:RegisterProtocal(25308, "handle25308")
    self:RegisterProtocal(25309, "handle25309")
end

--任务信息
function OrderActionController:send25300()
    self:SendProtocal(25300, {})
end
--[[
由于第三期的界面改动比较大，所以相对应的有些界面就特殊去处理
]]
function OrderActionController:handle25300(data)
    -- print("data.period....... ",data.period)
    self.model:setCurPeriod(data.period)        --周期数
    self.model:setCurDay(data.cur_day)          --天数
    self.model:setRMBStatus(data.rmb_status)    --是否激活特权
    self.model:setExtraStatus(data.exp_status)  --是否领取额外礼包
    self.model:setCurLev(data.lev)              --当前等级
    self.model:setCurExp(data.exp)              --当前经验
    self.model:setInitTaskData(data.list)       --任务列表
    GlobalEvent:getInstance():Fire(OrderActionEvent.OrderAction_Init_Event,data)
end

--任务更新
function OrderActionController:handle25301(data)
    self.model:updataTeskData(data)
    GlobalEvent:getInstance():Fire(OrderActionEvent.OrderAction_TaskGet_Event)
end
--提交任务
function OrderActionController:send25302(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(25302, proto)
end

--等级奖励
function OrderActionController:send25303()
    self:SendProtocal(25303, {})
end
function OrderActionController:handle25303(data)
    self.model:setLevShowData(data.reward_list)
    GlobalEvent:getInstance():Fire(OrderActionEvent.OrderAction_LevReward_Event,data.lev)
end
--领取等级奖励
function OrderActionController:send25304(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(25304, proto)
end
function OrderActionController:handle25304(data)
    message(data.msg)
end

-- 等级变更（只会主动推）
function OrderActionController:handle25305(data)
    self.model:setCurExp(data.exp)
    self.model:setCurLev(data.lev)
    GlobalEvent:getInstance():Fire(OrderActionEvent.OrderAction_Updata_LevExp_Event,data)
end

--进阶卡情况
function OrderActionController:send25306()
    self:SendProtocal(25306, {})
end
function OrderActionController:handle25306(data)
    self.model:setRMBStatus(data.rmb_status)
    self.model:setExtraStatus(data.exp_status)
    self.model:setGiftStatus(data.list)
    GlobalEvent:getInstance():Fire(OrderActionEvent.OrderAction_BuyGiftCard_Event)
end

--购买等级（成功推送25305）
function OrderActionController:send25307(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(25307, proto)
end
function OrderActionController:handle25307(data)
    message(data.msg)
    if data.flag == 1 then
        self:openBuyLevView(false)
    end
end

--领取额外奖励（成功推25306）
function OrderActionController:send25308()
    self:SendProtocal(25308, {})
end
function OrderActionController:handle25308(data)
    message(data.msg)
end

--是否要弹窗
function OrderActionController:send25309()
    self:SendProtocal(25309, {})
end
function OrderActionController:handle25309(data)
    GlobalEvent:getInstance():Fire(OrderActionEvent.OrderAction_IsPopWarn_Event,data)
end

--打开主界面
function OrderActionController:openOrderActionMainView(status)
	if status == true then
        if not self.order_action_view then
            self.order_action_view = OrderActionMainWindow.New()
        end
        self.order_action_view:open()
    else
        if self.order_action_view then 
            self.order_action_view:close()
            self.order_action_view = nil
        end
    end
end
--
function OrderActionController:getOrderActionMainRoot()
    if self.order_action_view then
        return self.order_action_view
    end
    return nil
end

--打开购买等级
function OrderActionController:openBuyLevView(status)
    if status == true then
        if not self.buy_lev_view then
            self.buy_lev_view = BuyLevWindow.New()
        end
        self.buy_lev_view:open()
    else
        if self.buy_lev_view then 
            self.buy_lev_view:close()
            self.buy_lev_view = nil
        end
    end
end

--奖励总览
function OrderActionController:openUntieRewardView(status)
    if status == true then
        if not self.untie_reward_view then
            self.untie_reward_view = UntieRewardWindow.New()
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
function OrderActionController:openEndWarnView(status,day)
    if status == true then
        if not self.end_warn_view then
            self.end_warn_view = OrderActionEndWarnWindow.New()
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
function OrderActionController:openBuyCardView(status)
    if status == true then
        if not self.buy_card_view then
            self.buy_card_view = UntieRewardWindow1.New()
        end
        self.buy_card_view:open()
    else
        if self.buy_card_view then 
            self.buy_card_view:close()
            self.buy_card_view = nil
        end
    end
end

function OrderActionController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end