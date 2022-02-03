-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
VipController = VipController or BaseClass(BaseController)

VIPTABCONST = {
    CHARGE = 1,     -- 充值
    ACC_CHARGE = 2, -- 累充
    VIP = 3,        -- VIP
    DAILY_GIFT = 4, -- 每日礼包
    PRIVILEGE = 5,  -- 特权商城
}

VIPREDPOINT = {
    MONTH_CARD = 1, --月卡
    VIP_TAB = 2, --VIP   TAB
    DAILY_AWARD = 3, -- 每日礼
    PRIVILEGE = 4, -- 特权礼包
}

function VipController:config()
    self.model = VipModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self.vip_redpoint_status = {}
    self.vip_privilege_redpoint = {} --vip特权 item 红点
    self.is_first = true

    self.gift_red_list = {} -- 每日礼包和特权礼包的红点
end

function VipController:setPrivilegeRedpoint(index,status)
    self.vip_privilege_redpoint[index] = status
end
function VipController:getPrivilegeRedpoint(index)
    local status = self.vip_privilege_redpoint[index]
    return status
end

function VipController:getIsFirst(  )
    local data_info = Config.FunctionData.data_info
    local bool = MainuiController:getInstance():checkIsOpenByActivate(data_info[10].activate)
    if bool == false then return false end

    local list = Config.VipData.data_get_reward
    local role_vo = RoleController:getInstance():getRoleVo()
    local status = false
    for i,v in pairs(list) do
        local buy_status = self.model:getVIPIsBuyStatus(v.lev)
        if buy_status == nil and v.lev <= role_vo.vip_lev then
            status = true
            break
        end
    end
    if status == true and self.is_first then
        return self.is_first
    end
    return false
end

function VipController:setIsFirst( status )
    self.is_first = status
end

function VipController:getModel()
    return self.model
end

function VipController:registerEvents()
    if self.login_event_success == nil then
        self.login_event_success = self.dispather:Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.login_event_success)
            self.login_event_success = nil

            self.role_vo = RoleController:getInstance():getRoleVo()
        end)
    end
end

function VipController:registerProtocals()
    self:RegisterProtocal(16700, "handle16700")    --获取充值列表信息
    self:RegisterProtocal(16710, "handle16710") --VIP礼包领取信息
    self:RegisterProtocal(16711, "handle16711") --VIP等级奖励领取
    self:RegisterProtocal(16712, "handle16712") --获取永久累充信息
    self:RegisterProtocal(16713, "handle16713") --领取累充奖励
    self:RegisterProtocal(21005, "handle21005") --三倍返利信息
    self:RegisterProtocal(21006, "handle21006") --每日礼包数据
    self:RegisterProtocal(24501, "handle24501") --购买VIP特权礼包
    self:RegisterProtocal(24502, "handle24502") --VIP特权礼包数据

    self:RegisterProtocal(16707, "handle16707")
    self:RegisterProtocal(16708, "handle16708")
end

--============================== --
--desc:根据vip等级去设置不同的图标状态
--time:2017-08-12 05:06:36
--@return
--============================== --
function VipController:changeVipFuncionIcon()
end

-- --============================== --
-- --desc:设置超值首充图标的状态
-- --time:2018-04-10 10:13:26
-- --@return
-- --============================== --
function VipController:changeFirstRechargeStatus(temp_max_dun_id)
end


--获取充值列表信息
function VipController:sender16700()
    local protocal = {}
    self:SendProtocal(16700, protocal)
end

function VipController:handle16700( data )
    self.dispather:Fire(VipEvent.UPDATE_CHARGE_LIST,data.list)
end

--三倍返利信息
function VipController:sender21005(  )
    local protocal = {}
    self:SendProtocal(21005, protocal)
end

function VipController:handle21005( data )
    self.dispather:Fire(VipEvent.THREE_RECHARGE,data)
end

-- 请求每次礼包数据
function VipController:sender21006(  )
    local protocal = {}
    self:SendProtocal(21006, protocal)
end

function VipController:handle21006( data )
    if data then
        self.model:setDailyGiftData(data.first_gift)
        self.dispather:Fire(VipEvent.DAILY_GIFT_INFO)
    end
end

-- 请求购买VIP特权礼包
function VipController:sender24501( id )
    local protocal = {}
    protocal.id = id
    self:SendProtocal(24501, protocal)
end

function VipController:handle24501( data )
    if data.msg then
        message(data.msg)
    end
end

-- 请求VIP特权礼包数据
function VipController:sender24502(  )
    self:SendProtocal(24502, {})
end

function VipController:handle24502( data )
    if data then
        self.model:setPrivilegeList(data.list)
        local status = self.model:getPrivilegeRedStatus()
        self:setTipsGiftStatus(VIPREDPOINT.PRIVILEGE, status)
        self.dispather:Fire(VipEvent.PRIVILEGE_INFO)
    end
end

--VIP界面月卡领取
function VipController:sender16707()
    self:SendProtocal(16707, {})
end
function VipController:handle16707(data)
    local status = false
    if data.status == 1 then
        status = true
    end
    self.model:setMonthCard(data.status)
    self:setTipsGiftStatus(VIPREDPOINT.MONTH_CARD, status)
    self.dispather:Fire(VipEvent.SUPRE_CARD_GET,data.status)
end
function VipController:sender16708()
    self:SendProtocal(16708, {})
end
function VipController:handle16708(data)
    message(data.msg)
end

--VIP礼包领取信息
function VipController:sender16710(  )
    local protocal = {}
    self:SendProtocal(16710, protocal)
end

function VipController:handle16710( data )
    self.model:setGetGiftList(data.list)
    -- 只要是vip就显示
    if self.role_vo and self.role_vo.vip_lev ~= 0 then
        self:changeVipFuncionIcon()
    end

    local get_list = self.model:getGetGiftList()
    local vip_gift = false
    if self.role_vo and get_list then
        vip_gift = get_list[self.role_vo.vip_lev]
    end
    local item_status = (vip_gift==nil) and self:getIsFirst()

    self:setTipsGiftStatus(VIPREDPOINT.VIP_TAB, item_status)

    self.dispather:Fire(VipEvent.UPDATA_ITEM_REDPOINT)
end

--VIP红点
function VipController:setTipsVIPStstus(bid, status)
    self.vip_redpoint_status[bid] = status
    local redpoint = false
    for i,v in pairs(self.vip_redpoint_status) do
        if v == true then
            redpoint = true
            break
        end
    end
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.charge, redpoint)
end

-- 每日礼包和特权礼包红点
function VipController:setTipsGiftStatus( bid, status )
    self.gift_red_list[bid] = status
    local redpoint = self:getGiftRedStatus()
    self.dispather:Fire(VipEvent.Update_Gift_Red_state)
    Area_sceneController:getInstance():setBuildRedStatus(3, {{bid = bid, status = status}})
    --MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.shop, {bid = bid, status = status})
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.charge, redpoint)
end

function VipController:getGiftRedStatusById( bid )
    return self.gift_red_list[bid]
end

function VipController:getVipRedStatus(  )
    local redpoint = false
    for bid,v in pairs(self.gift_red_list) do
        if (bid == VIPREDPOINT.VIP_TAB or bid == VIPREDPOINT.MONTH_CARD) and v == true then
            redpoint = true
            break
        end
    end
    return redpoint
end

function VipController:getGiftRedStatus(  )
    local redpoint = false
    for i,v in pairs(self.gift_red_list) do
        if v == true then
            redpoint = true
            break
        end
    end
    return redpoint
end

function VipController:getVipRedData(  )
    local red_data = {}
    for k,bid in pairs(VIPREDPOINT) do
        local red_status = self:getGiftRedStatusById(bid)
        table.insert( red_data, {bid = bid, status = red_status} )
    end
    return red_data
end

--VIP等级奖励领取
function VipController:sender16711( lev )
    local protocal = {}
    protocal.lev = lev
    self:SendProtocal(16711, protocal)
end

function VipController:handle16711( data )
    message(data.msg)
end

--累充奖励信息
function VipController:sender16712(  )
    local protocal = {}
    self:SendProtocal(16712, protocal)
end

function VipController:handle16712( data )
    self.charge_sum = data.charge_sum --当前总充值数
    self.model:setAccList(data.list)
    self.dispather:Fire(VipEvent.ACC_RECHARGE_INFO,data)
end

function VipController:getChargeSum(  )
    return self.charge_sum or 0
end

--领取累充奖励
function VipController:sender16713( id )
    local protocal = {}
    protocal.id = id
    self:SendProtocal(16713, protocal)
end

function VipController:handle16713( data )
    message(data.msg)
end


--index是大标签页 VIPTABCONST
--sub_type是vip特权界面的 要跳哪个等级就传哪个等级
function VipController:openVipMainWindow( status,index,sub_type )
	if status then 
        if (FILTER_CHARGE == true) then
            message(TI18N("功能暂未开放，敬请期待"))
            return
        end

        local charge_cfg = Config.ChargeData.data_constant["open_lv"]
        if charge_cfg then
            if self.role_vo and self.role_vo.lev < charge_cfg.val then
                message(charge_cfg.desc)
                return
            end
        end

        if not self.vip_window  then
            self.vip_window = VipMainWindow.New()
        end
        index = index or 1 
        if self.vip_window then
            if self.vip_window:isOpen() == false then
                self.vip_window:open(index, sub_type)
            else
                -- self.vip_window:changeTabView(index)
            end
        end
    else
        if self.vip_window then 
            self.vip_window:close()
            self.vip_window = nil
        end
    end
end
--获取VIP界面是否打开状态
function VipController:getVIPIsOpen()
    local status = false
    if self.vip_window then
        status = self.vip_window:isOpen()
    end
    return status
end
function VipController:jumpChangeTabView(index)
    if self.vip_window then
        self.vip_window:changeTabView(VIPTABCONST.VIP)
    end
end

--==============================--
--desc:切换vip面板的标签页
--time:2018-07-11 11:01:33
--@index:
--@return 
--==============================--
function VipController:changeMainWindowTab(index)
    if self.vip_window then
        self.vip_window:changeTabView(VIPTABCONST.VIP)
    end
end

function VipController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end