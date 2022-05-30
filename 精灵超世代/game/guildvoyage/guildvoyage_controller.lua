-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-23
-- --------------------------------------------------------------------
GuildvoyageController = GuildvoyageController or BaseClass(BaseController)

function GuildvoyageController:config()
    self.model = GuildvoyageModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function GuildvoyageController:getModel()
    return self.model
end

function GuildvoyageController:registerEvents()
    if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            self.role_vo = RoleController:getInstance():getRoleVo()
            if self.role_vo ~= nil then
                self:requestInitProtocal(true)
                if self.role_assets_event == nil then
                    self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                        if key == "guild_lev" then
                            self:requestInitProtocal()
                        end
                    end)
                end 
            end
        end)
    end 

    if self.re_link_game_event == nil then
	    self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            self:openMainWindow(false)
            self:openGuildvoyageOrderEscortWindow(false)
            self:openChoosePartnerWindow(false)
            self:requestInitProtocal(true)
        end)
    end 
end

--==============================--
--desc:登录时候请求,或者更新时候请求
--time:2018-06-26 11:28:24
--@force:
--@return 
--==============================--
function GuildvoyageController:requestInitProtocal(force)
    if self.role_vo == nil then return end
    local config = Config.GuildShippingData.data_const.guild_lev
    if config == nil then return end
    if self.role_vo.gid == 0 or self.role_vo.guild_lev < config.val then
        self.model:clearGuildVoyageInfo()
    else
        if force == true then
            self:requestOrderList()
        else
            local base_info = self.model:getBaseInfo()
            if base_info == nil or next(base_info) == nil then
                self:requestOrderList()
            end
        end
    end
end

function GuildvoyageController:registerProtocals()
    self:RegisterProtocal(23800, "handle23800")     -- 基础订单信息
    self:RegisterProtocal(23801, "handle23801")     -- 订单详情,航海线路中点击船只,或者接受护送订单返回
    self:RegisterProtocal(23802, "handle23802")     -- 护送订单   
    self:RegisterProtocal(23803, "handle23803")     -- 秒掉完成耗时
    -- self:RegisterProtocal(23804, "handle23804")     -- 购买付费订单
    -- self:RegisterProtocal(23805, "handle23805")     -- 新增订单(废弃)
    self:RegisterProtocal(23806, "handle23806")     -- 公会互助列表
    self:RegisterProtocal(23807, "handle23807")     -- 互助加速

    self:RegisterProtocal(23808, "handle23808")     -- 捐献物品
    self:RegisterProtocal(23809, "handle23809")     -- 领取订单奖励
    self:RegisterProtocal(23810, "handle23810")     -- 帮内求助
    self:RegisterProtocal(23811, "handle23811")     -- 更新船只信息,状态和时间

    self:RegisterProtocal(23812, "handle23812")     -- 刷新订单
    self:RegisterProtocal(23813, "handle23813")     -- 订单记录日志
    self:RegisterProtocal(23814, "handle23814")     -- 最近的一次订单公告

    self:RegisterProtocal(23815, "handle23815")     -- 今天已接订单数
end

--==============================--
--desc:打开主界面
--time:2018-06-23 11:35:57
--@status:
--@index:
--@return 
--==============================--
function GuildvoyageController:openMainWindow(status, index)
    if status == false then
        if self.main_window then
            self.main_window:close()
            self.main_window = nil
        end
    else
        if self.role_vo == nil or self.role_vo.gid == 0 then 
            message(TI18N("你当前还没有加入任何公会!"))
            return 
        end
        local config = Config.GuildShippingData.data_const.guild_lev 
        if config == nil then 
            message(TI18N("公会远航数据异常!"))
            return
        end
        if self.role_vo.guild_lev < config.val then
            message(config.desc)
            return 
        end
        if self.main_window == nil then
            self.main_window = GuildvoyageMainWindow.New()
        end
        self.main_window:open(index)
    end
end

--==============================--
--desc:打开订单
--time:2018-06-29 02:16:00
--@status:
--@order_id:
--@return 
--==============================--
function GuildvoyageController:openGuildvoyageOrderEscortWindow(status, order_type, order_id)
    if status == false then
        if self.order_escort_window then
            self.order_escort_window:close()
            self.order_escort_window = nil
        end
        self.cur_check_order_id = nil
    else
        if order_type == nil or order_id == nil then return end
        order_type = order_type or GuildvoyageConst.escort_type.prepare

        -- 订单的时候保存一下当前订单id,为了做宝物的帮内求助使用
        if order_type == GuildvoyageConst.escort_type.prepare then
            self.cur_check_order_id = order_id
        end

        if self.order_escort_window == nil then
            self.order_escort_window = GuildvoyageOrderEscortWindow.New(order_type)
        end 
        self.order_escort_window:open(order_id)
    end
end

--==============================--
--desc:远航伙伴选择界面
--time:2018-07-02 02:32:33
--@status:
--@return 
--==============================--
function GuildvoyageController:openChoosePartnerWindow(status, partner_list)
    if status == false then
        if self.choose_window then
            self.choose_window:close()
            self.choose_window = nil
        end
    else
        if self.choose_window == nil then
            self.choose_window = GuildvoyageChoosePartnerWindow.New()
        end
        self.choose_window:open(partner_list)
    end
end

--==============================--
--desc:打开公会远航捐献面板
--time:2018-07-02 05:14:55
--@status:
--@order_id:
--@item_bid:
--@return 
--==============================--
function GuildvoyageController:openGuildvoyageDonateWindow(status, rid, srv_id, order_id, item_bid, item_sum)
    if status == false then
        if self.donate_window then
            self.donate_window:close()
            self.donate_window = nil
        end
    else
        if self.donate_window == nil then
            self.donate_window = GuildvoyageDonateWindow.New()
        end
        self.donate_window:open(rid, srv_id, order_id, item_bid, item_sum)
    end
end

--==============================--
--desc:打开远航护送最后结算面板
--time:2018-07-02 07:21:26
--@status:
--@data:
--@return 
--==============================--
function GuildvoyageController:openGuildvoyageResultWindow(status, order_id, is_success, is_double)
    if status == false then
        if self.result_window then
            self.result_window:close()
            self.result_window = nil
        end
    else
        if order_id == nil then return end
        if self.result_window == nil then
            self.result_window = GuildvoyageResultWindow.New()
        end
        self.result_window:open(order_id, is_success, is_double)
    end
end

--==============================--
--desc:打开公会远航日志的
--time:2018-09-05 04:31:00
--@status:
--@return 
--==============================--
function GuildvoyageController:openGuildVoyageLogWindow(status)
    if status == false then
        if self.log_window then
            self.log_window:close()
            self.log_window = nil
        end
    else
        if self.log_window == nil then
            self.log_window = GuildVoyageLogWindow.New()
        end
        self.log_window:open()
    end
end

--==============================--
--desc:请求订单
--time:2018-06-26 04:37:33
--@return 
--==============================--
function GuildvoyageController:requestOrderList()
    self:SendProtocal(23800, {}) 
    self:SendProtocal(23814, {}) 
    self:SendProtocal(23815, {})
end

function GuildvoyageController:requestEscortLeftTimes()
    self:SendProtocal(23815, {})
end

--==============================--
--desc:初始化订单信息
--time:2018-06-26 11:31:20
--@data:
--@return 
--==============================--
function GuildvoyageController:handle23800(data)
    self.model:initGuildVoyageOrderList(data)
end

--==============================--
--desc:请求购买订单
--time:2018-06-26 04:47:26
--@return 
--==============================--
-- function GuildvoyageController:requestBuyOrder()
-- end

--==============================--
--desc:请求提交一个订单
--time:2018-07-03 03:31:22
--@order_id:
--@return 
--==============================--
function GuildvoyageController:requestSubmitVoyage(order_id, is_double)
    is_double = is_double or 0
    local protocal = {}
    protocal.order_id = order_id
    protocal.is_double = is_double
    self:SendProtocal(23809, protocal)
end

function GuildvoyageController:handle23809(data)
    message(data.msg)
    if data.code == TRUE then
        -- 因为可能存在是秒掉订单的,这个时候就需要把这个面板关掉
        self:openGuildvoyageOrderEscortWindow(false) 

        -- 关掉确认面板
        self:openGuildvoyageChooseConfirmWindow(false)

        self.model:changeGuildVoyageStatus(data.order_id, GuildvoyageConst.status.over)

        -- 这里要打开指定结算面板
        self:openGuildvoyageResultWindow(true, data.order_id, data.is_success, data.is_double)
    end
end

--==============================--
--desc:订单的帮内求助
--time:2018-07-02 02:02:43
--@bid:
--@return 
--==============================--
function GuildvoyageController:seekHelpInGuild(bid)
    if bid == nil then return end
    if self.cur_check_order_id == nil then return end
    local protocal = {}
    protocal.order_id = self.cur_check_order_id
    protocal.item_bid = bid
    self:SendProtocal(23810, protocal)
end

function GuildvoyageController:handle23810(data)
    message(data.msg)
end

--==============================--
--desc:更新订单详情......
--time:2018-07-04 11:20:31
--@data:
--@return 
--==============================--
function GuildvoyageController:handle23801(data)
    self.model:updateGuildVoyageOrderList(data)
end

--==============================--
--desc:请求护送订单
--time:2018-07-04 11:37:44
--@order_id:
--@partner_list:
--@return 
--==============================--
function GuildvoyageController:requestEscortOrder(order_id, partner_ids,is_success)
    local protocal = {}
    protocal.order_id = order_id
    protocal.partner_ids = partner_ids
    protocal.is_success = is_success 
    self:SendProtocal(23802, protocal)
end

function GuildvoyageController:handle23802(data)
    message(data.msg)
    if data.code == TRUE then
        self:openGuildvoyageOrderEscortWindow(false)
    end
end

--==============================--
--desc:请求捐献宝物
--time:2018-07-04 04:13:09
--@rid:
--@srv_id:
--@order_id:
--@item_bid:
--@return 
--==============================--
function GuildvoyageController:requestDonateTreasure(rid, srv_id, order_id, item_bid)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.order_id = order_id
    protocal.item_bid = item_bid
    self:SendProtocal(23808, protocal)
end

function GuildvoyageController:handle23808(data)
    message(data.msg)
    if data.code == TRUE then
        self:openGuildvoyageDonateWindow(false)
    end
end

--==============================--
--desc:请求秒掉订单
--time:2018-07-05 11:20:08
--@order_id:
--@return 
--==============================--
function GuildvoyageController:requestFinishOrder(order_id)
    local protocal = {}
    protocal.order_id = order_id
    self:SendProtocal(23803, protocal)
end

function GuildvoyageController:handle23803(data)
    message(data.msg)
    if data.code == TRUE then
        self:openGuildvoyageOrderEscortWindow(false)
        local order_vo = self.model:getOrderById(data.order_id)
        if order_vo then
            self:openGuildvoyageChooseConfirmWindow(true, order_vo)
        end
    end
end

--==============================--
--desc:请求公会互助列表
--time:2018-07-05 06:55:52
--@return 
--==============================--
function GuildvoyageController:requestInteractionList()
    self:SendProtocal(23806, {})
end

--==============================--
--desc:公会互助列表
--time:2018-07-05 06:54:50
--@data:
--@return 
--==============================--
function GuildvoyageController:handle23806(data)
    self.model:updateGuildVoyageInteractionList(data)
end

--==============================--
--desc:请求互助公会成员的订单,给成员加速
--time:2018-07-05 06:56:51
--@rid:
--@srv_id:
--@order_id:
--@return 
--==============================--
function GuildvoyageController:requestHelpMemberOrder(rid, srv_id, order_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.order_id = order_id
    self:SendProtocal(23807, protocal)
end

--==============================--
--desc:公会互助加速操作返回
--time:2018-07-05 06:55:14
--@data:
--@return 
--==============================--
function GuildvoyageController:handle23807(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:removeGuildVoyageInteraction(data)
    end
end 

--==============================--
--desc:更新船只信息,主要是被互动加速的时候触发
--time:2018-07-05 11:56:43
--@data:
--@return 
--==============================--
function GuildvoyageController:handle23811(data)
    self.model:updateVoyageInfo(data)
end

--==============================--
--desc:刷新订单
--time:2018-09-05 05:02:13
--@return 
--==============================--
function GuildvoyageController:requestRefresh()
    local function callback()
        self:SendProtocal(23812, {})
    end

    local refresh_order_times = self.model:getRefreshTimes()
    if refresh_order_times == nil then refresh_order_times = 0 end
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo == nil then return end

    local refresh_next_times = refresh_order_times + 1
    local refresh_config = Config.GuildShippingData.data_refresh[refresh_next_times]
    if refresh_config == nil then
        message(TI18N("当前刷新次数已到达本日上限"))
    else
        if role_vo.vip_lev < refresh_config.vip_lev then
            local msg = string.format(TI18N("提升至<div fontcolor='#289b14'>vip%s</div>可提高<div fontcolor='#289b14'>1</div>点次数购买上限，是否前往充值提升vip等级"), refresh_config.vip_lev)
            CommonAlert.show(msg, TI18N("我要提升"), function()
                VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
                --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
            end, TI18N("取消"), nil, CommonAlert.type.rich)
        else
            if refresh_config.loss_fee and refresh_config.loss_fee[1] then
                local cost = refresh_config.loss_fee[1] 
                if cost == nil or #cost < 2 then return end

                local item_config = Config.ItemData.data_get_data(cost[1])
                if item_config then
                    local msg = string.format(TI18N("是否花费 <img src=%s visible=true scale=0.35 />%s 刷新远航订单吗？"), PathTool.getItemRes(item_config.icon), cost[2])
                    CommonAlert.show(msg, TI18N("确定"), function()
                        callback()
                    end, TI18N("取消"), nil, CommonAlert.type.rich)
                end
            end
        end
    end 
end

--[[
    @desc: 刷新订单返回,修改指定订单内容
    author:{author}
    time:2018-08-09 16:29:06
    --@data: 
    @return:
]]
function GuildvoyageController:handle23812(data)
    message(data.msg)
end

function GuildvoyageController:handle23814(data)
    self.model:updateLogInfo(data)
end

--==============================--
--desc:请求订单详情
--time:2018-09-05 08:02:11
--@return 
--==============================--
function GuildvoyageController:requestLogList()
    self:SendProtocal(23813, {})
end

function GuildvoyageController:handle23813(data)
    GlobalEvent:getInstance():Fire(GuildvoyageEvent.UpdateLogListEvent, data.list)
end 

function GuildvoyageController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

--==============================--
--desc:今日护送次数
--time:2018-09-06 09:09:27
--@data:
--@return 
--==============================--
function GuildvoyageController:handle23815(data)
    self.model:setDailyTimes(data.time)
end


--[[
    @desc: 订单单双倍选择界面
    author:{author}
    time:2018-08-09 19:59:36
    --@status:
	--@order_id: 
    @return:
]]
function GuildvoyageController:openGuildvoyageChooseConfirmWindow(status, order)
    if status == false then
        if self.choose_confirm then
            self.choose_confirm:close()
            self.choose_confirm = nil
        end
    else
        if self.choose_confirm == nil then
            self.choose_confirm = GuildvoyageChooseConfirmWindow.New()
        end
        if self.choose_confirm:isOpen() == false then
            self.choose_confirm:open(order)
        end
    end
end