-- --------------------------------------------------------------------
-- 福利
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
WelfareController = WelfareController or BaseClass(BaseController)

function WelfareController:config()
    self.model = WelfareModel.New(self)
    self.dispather = GlobalEvent:getInstance()

    self.welfare_list = {}
    self.welfare_status_list = {}                   -- 福利状态列表
    self.welfare_cache_red = {}                     -- 福利缓存红点状态
end

function WelfareController:getModel()
    return self.model
end

function WelfareController:registerEvents()
    if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil
            --self:requestInitProto()

            self.role_vo = RoleController:getInstance():getRoleVo()
            if self.role_assets_event == nil then
                self.role_update_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                    if key == "lev" then
                        self:updateWelfareRedStatus(value)
                    end
                end)
            end
        end)
    end

    --断线重连请求月卡
    if self.re_link_game_event == nil then
        self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            self:openMainWindow(false)
            -- 判断精彩活动图标在不在,请求精彩活动的数据
            --[[local vo = MainuiController:getInstance():getFunctionIconById(MainuiConst.icon.welfare)
            if vo ~= nil then
                self:sender16705() --月卡信息
            end--]]
        end)
    end

    if self.welfare_fund_event == nil then
        self.welfare_fund_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATA_WELFARE_FUND__STATUS_EVENT, function(data)
            local id_list = {}
            self.fund_one_icon,self.fund_two_icon = false,false
            if data ~= nil and next(data) ~= nil then
                for k,v in pairs(data) do
                    if v.id == WelfareIcon.fund_one then
                        self.fund_one_icon = true 
                    elseif v.id == WelfareIcon.fund_two then
                        self.fund_two_icon = true
                    end
                end
                 self:sender24703(0)
            end 
        end)
    end


end

function WelfareController:registerProtocals()
    self:RegisterProtocal(14100, "handle14100")     --签到信息
    self:RegisterProtocal(14101, "handle14101")     --领取签到奖励

    self:RegisterProtocal(16705, "handle16705")     --月卡信息
    self:RegisterProtocal(16706, "handle16706")     --领取月卡

    self:RegisterProtocal(21002, "handle21002")     --今日充值次数

    -- self:RegisterProtocal(10946, "handle10946")     -- 微信有礼

    --召唤福利
    -- self:RegisterProtocal(23210, "handle23210")
    -- self:RegisterProtocal(23211, "handle23211")

    --调查问卷
    self:RegisterProtocal(24600, "handle24600")
    self:RegisterProtocal(24601, "handle24601")
    self:RegisterProtocal(24602, "handle24602")
    self:RegisterProtocal(24603, "handle24603")
    self:RegisterProtocal(24604, "handle24604")

    self:RegisterProtocal(21007, "handle21007")

    -- 每日礼
    self:RegisterProtocal(21008, "handle21008")
    self:RegisterProtocal(21009, "handle21009")

    -- 手机绑定奖励状态
    self:RegisterProtocal(16635, "handle16635")
    self:RegisterProtocal(16636, "handle16636")

    -- 微信公众号
    self:RegisterProtocal(16633, "handle16633")
    self:RegisterProtocal(16634, "handle16634")

    self:RegisterProtocal(21021,"handle21021")
    
    --福利界面基金
    self:RegisterProtocal(24703,"handle24703")
    --订阅特权
    self:RegisterProtocal(10989,"handle10989")
    --订阅特权红点
    self:RegisterProtocal(10987,"handle10987")

end

--==============================--
--desc:登录请求的协议
--time:2019-01-28 09:51:57
--@return 
--==============================--
function WelfareController:requestInitProto()
    self:sender14100() --签到红点
    self:sender16705() --月卡信息
    self:sender24600() --问卷
    self:sender21008() --每日礼
    self:sender16635() --手机绑定奖励状态
    self:sender16633()
end

--签到信息
function WelfareController:sender14100()
    self:SendProtocal(14100, {})
end

--月卡信息
function WelfareController:sender16705()
	self:SendProtocal(16705, {})
end 

--调查问卷状态
function WelfareController:sender24600()
	self:SendProtocal(24600, {})
end 

-- 请求每日礼状态
function WelfareController:sender21008()
	self:SendProtocal(21008, {})
end 

-- 请求手机绑定信息
function WelfareController:sender16635()
	self:SendProtocal(16635, {})
end

function WelfareController:sender16633()
	self:SendProtocal(16633, {})
end

function WelfareController:handle14100( data )
    self.dispather:Fire(WelfareEvent.Update_Sign_Info,data)
     --红点
    local is_show =false
    local recharge_count = self.model:getRechargeCount()
    if (data.status ==0) or (recharge_count >0 and data.status ==1) then 
        is_show = true
    end
    self:setWelfareStatus(WelfareIcon.sign,is_show)
end

--领取签到奖励
function WelfareController:sender14101(  )
    local protocal ={}
    self:SendProtocal(14101,protocal)
end

function WelfareController:handle14101( data )
    message(data.msg)
    if data.code == 1 then 
        self.dispather:Fire(WelfareEvent.Sign_Success,data)
         --红点
        local is_show =false
        local recharge_count = self.model:getRechargeCount()
        if (data.status ==0) or (recharge_count >0 and data.status ==1) then 
            is_show = true
        end
        self:setWelfareStatus(WelfareIcon.sign,is_show)
    end
end

function WelfareController:handle16705( data )
    self.model:setYueka(data)
    self.dispather:Fire(WelfareEvent.Update_Yueka,data)

    local supre_status = false --至尊月卡
    local honor_status = false --荣耀月卡
    local yueka_status = false --月卡集合
    if data.card1_is_reward == 1 then
        supre_status = true
    end
    if data.card2_is_reward == 1 then
        honor_status = true
    end
    if supre_status == true or honor_status == true then
        yueka_status = true
    end
    
    -- self:setWelfareStatus(WelfareIcon.supre_yueka,supre_status)
    -- self:setWelfareStatus(WelfareIcon.honor_yueka,honor_status)
    self:setWelfareStatus(WelfareIcon.yueka,yueka_status)
end
--领取月卡
function WelfareController:sender16706(card_type)
    local protocal = {}
    protocal.card_type = card_type
    self:SendProtocal(16706,protocal)
end
function WelfareController:handle16706( data )
    message(data.msg)
    if data.code == 1 then
        self.dispather:Fire(WelfareEvent.Update_Get_Yueka, data.card_type)
        local info = self.model:getYueka()
        if data.card_type == 1 then
            if info then
                info.card1_is_reward = 2
            end
        elseif data.card_type == 2 then
            if info then
                info.card2_is_reward = 2
            end
        end
        
        if info and info.card1_is_reward == 1 or info.card2_is_reward == 1 then
            self:setWelfareStatus(WelfareIcon.yueka,true)
        else
            self:setWelfareStatus(WelfareIcon.yueka,false)
        end
    end
end

--今日充值次数
function WelfareController:sender21002(  )
    local protocal ={}
    self:SendProtocal(21002,protocal)
end

function WelfareController:handle21002( data )
    self.model:setRechargeCount(data.count)
    self:sender14100() --更新下签到红点
end

--福利界面基金红点相关
function WelfareController:sender24703( id )
    local protocal = {}
    protocal.id = id
    self:SendProtocal(24703, protocal)
end

function WelfareController:handle24703( data )
    if data then
        for i,v in ipairs(data.ids) do
            if v.status ~= 0  then  
                WelfareController:getInstance():setWelfareStatus(v.id,v.status == 1)
            end
        end
    end
end

--游戏开始请求订阅特权红点
function WelfareController:sender10987()
    local protocal = {}
    self:SendProtocal(10987, protocal)
end

function WelfareController:handle10987( data )
    if data and data.is_point ~= nil then
        WelfareController:getInstance():setWelfareStatus(WelfareIcon.subscribe, data.is_point == 1)
    end
end

--进入面板取消红点
function WelfareController:sender10988()
    local protocal = {}
    self:SendProtocal(10988, protocal)
end

--订阅特权信息
function WelfareController:sender10989()
    local protocal = {}
    self:SendProtocal(10989, protocal)
end

function WelfareController:handle10989( data )
    if data then
        -- self.model:setSubscribeData(data)
        GlobalEvent:getInstance():Fire(WelfareEvent.Update_Subscribe_data, data)
    end
end

--==============================--
--desc:判断一个福利是否开启了
--time:2019-01-28 03:11:04
--@is_verifyios:
--@return 
--==============================--
function WelfareController:checkCanAdd(bid)
    local config = Config.HolidayClientData.data_info[bid]
    if config == nil then return false end
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo == nil then return false end
    if type(config.open_lev) ~= "table" then return false end
    
    local status = MainuiController:getInstance():checkIsOpenByActivate(config.open_lev)
    if status == false then return false end
    local is_verifyios = config.is_verifyios 

    -- 如果是提审服都要显示
    if is_verifyios == 1 then
        if bid == WelfareIcon.week then
            local status = self.model:getIsOpenWeekGift()
            return status
        end
        return true 
    end   
    if bid == WelfareIcon.bindphone then        -- 手机绑定
        return SHOW_BIND_PHONE 
    elseif bid == WelfareIcon.wechat then       -- 关注微信公众号
        return SHOW_WECHAT_CERTIFY
    elseif bid == WelfareIcon.poste then        -- 百度贴吧
        return SHOW_BAIDU_TIEBA
    elseif bid == WelfareIcon.invicode then     -- 个人推荐码
        return SHOW_SINGLE_INVICODE
    elseif bid == WelfareIcon.share_game then   -- 游戏分享
        return SHOW_GAME_SHARE and RoleController:getInstance():getApkData()
    elseif bid == WelfareIcon.fund_one then
        if self.fund_one_icon == true then
            return true
        else 
            return false
        end
    elseif bid == WelfareIcon.fund_two then 
        if self.fund_two_icon == true then
            return true
        else 
            return false
        end
    else
        return (not MAKELIFEBETTER)
    end
end

--打开福利主界面 bid取WelfareConstants WelfareIcon 跳转指定标签页 
function WelfareController:openMainWindow( status,bid )
	if status then 
        if MAKELIFEBETTER == true then return end  -- 福利面板在提审服不要打开了
        local role_vo = RoleController:getInstance():getRoleVo()
        local data_info = Config.HolidayClientData.data_info
        if data_info and data_info[bid] then
            local status = MainuiController:getInstance():checkIsOpenByActivate(data_info[bid].open_lev)
            if status == false then
                message(TI18N("条件不满足"))
                return
            end
        end

        -- 这里重新设置一下标签
        for k,v in pairs(data_info) do
            if self.welfare_list[v.bid] == nil then
                if self:checkCanAdd(v.bid) == true then
                    sub_vo = WelfareSubTabVo.New()
                    if sub_vo.update then
                        sub_vo:update(v)
                    end
                    self.welfare_list[v.bid] = sub_vo
                end
            end
        end
        if not self.welfare_win  then
            self.welfare_win = WelfareMainWindow.New()
        end
        self.welfare_win:open(bid)
    else
        if self.welfare_win then 
            self.welfare_win:close()
            self.welfare_win = nil
        end
    end
end

-- 引导需要
function WelfareController:getWelfareRoot(  )
    if self.welfare_win then
        return self.welfare_win.root_wnd
    end
end

--==============================--
--desc:获取福利标签列表
--time:2017-09-19 07:12:28
--@type:
--@return 
--==============================--
function WelfareController:getWelfareSubList()
    local welfare_sub_list = {}
    if self.welfare_list ~= nil and next(self.welfare_list) ~= nil then
        for k,v in pairs(self.welfare_list) do
            local need_add = true
            if ActionController:getInstance():isSpecialBid(v.bid) then
                local vo = ActionController:getInstance():getActionSubTabVo(v.bid)
                if vo == nil then
                    need_add = false
                end
            elseif v.bid == WelfareIcon.quest then
                local open = self.model:getQuestOpenData()
                if open and open.status == 0 then
                    need_add = false
                end
            elseif v.bid == WelfareIcon.bindphone then
                local is_over = self:checkBindPhoneStatus()      -- 是否领取过了
                if is_over == true then
                    need_add = false
                end
            end
            if need_add == true then
                table.insert(welfare_sub_list, v )
            end
        end
    end
    if next(welfare_sub_list) ~= nil then
        table.sort( welfare_sub_list, function(a, b) 
            return a.sort_val < b.sort_val
        end )
    end
    return welfare_sub_list
end

-- 升级的时候判断红点
function WelfareController:updateWelfareRedStatus(level)
    if level == nil then return end
    if self.welfare_cache_red == nil or self.welfare_cache_red[level] == nil then return end
    local list = self.welfare_cache_red[level]
    for k,v in pairs(list) do
        self:setWelfareStatus(k, v)
    end
end

--==============================--
--desc:设置福利图标的状态,如果图标没有开启 应该不需要设置红点
--time:2017-09-19 05:53:16
--@type:
--@status:
--@return 
--==============================--
function WelfareController:setWelfareStatus(bid, status)
    if not self:checkCanAdd(bid) then          -- 如果不可以开启,则这样处理吧
        local config = Config.HolidayClientData.data_info[bid]
        if config then
            if self.welfare_cache_red[config.open_lev[1][2]] == nil then
                self.welfare_cache_red[config.open_lev[1][2]] = {}
            end
            self.welfare_cache_red[config.open_lev[1][2]][bid] = status
        end
    else
        if self.welfare_status_list == nil then
            self.welfare_status_list = {}
        end
        local num = 0
        if status then 
            num = 1
        end
        local vo = {
            bid = bid, 
            num = num
        }
        local vo1 = {
            bid=bid,
            status=status
        }
        self.welfare_status_list[bid] = vo1

        --贴吧的红点(由于没有用到协议只能特殊处理)
        self:setPosteWelfareStatus(true)

        -- 这是福利功能图标红点
        MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.welfare, vo)

        -- 福利标签的面板
        GlobalEvent:getInstance():Fire(WelfareEvent.UPDATE_WELFARE_TAB_STATUS, vo1)
    end
end

function WelfareController:setPosteWelfareStatus(status)
    if SHOW_BAIDU_TIEBA then
        if status == true and self.welfare_status_list[WelfareIcon.poste] == nil then
            local role_vo = RoleController:getInstance():getRoleVo()
            local data_info = Config.HolidayClientData.data_info[WelfareIcon.poste]
            local status_num = 0
            if data_info then
                local status = MainuiController:getInstance():checkIsOpenByActivate(data_info.open_lev)
                if status == true then
                    local poste_status = SysEnv:getInstance():getBool(SysEnv.keys.welfare_redpoint,true)
                    if poste_status then
                        status_num = 1
                    end
                end
            end
            local vo = {bid = WelfareIcon.poste, num = status_num}
            local redpoint = false
            if status_num == 1 then
                redpoint = true
            end
            WelfareController:getInstance():setWelfareStatus(WelfareIcon.poste, redpoint)
            MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.welfare, vo)
        elseif status == false and self.welfare_status_list[WelfareIcon.poste] then
            SysEnv:getInstance():set(SysEnv.keys.welfare_redpoint, false, nil)
            local vo = {bid = WelfareIcon.poste, num = 0}
            WelfareController:getInstance():setWelfareStatus(WelfareIcon.poste, false)
            MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.welfare, vo)
        end
    end
end

--==============================--
--desc:根据id获取福利的标签页状态,主要是获取是否有红点
--time:2017-09-19 07:17:53
--@id:
--@return:vo 包含 bid 和 status
--==============================--
function WelfareController:getWelfareStatusByID(id)
    if self.welfare_status_list then
        return self.welfare_status_list[id]
    end
end

function WelfareController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

function WelfareController:sender10946()
    -- self:SendProtocal(10946,{})
end

function WelfareController:handle10946(data)
end

function WelfareController:sender23210()
    -- self:SendProtocal(23210,{})
end
function WelfareController:handle23210(data)
end

function WelfareController:sender23211(id)
    -- local protocal ={}
    -- protocal.id = id
    -- self:SendProtocal(23211,protocal)
end
function WelfareController:handle23211(data)

end

function WelfareController:openSureveyQuestView(status)
    if status == true then 
        if not self.sureveyQuestWindow then
            self.sureveyQuestWindow = SureveyQuestWindow.New()
        end
        self.sureveyQuestWindow:open()
    else
        if self.sureveyQuestWindow then 
            self.sureveyQuestWindow:close()
            self.sureveyQuestWindow = nil
        end
    end
end
--调查问卷协议---
function WelfareController:handle24600(data)
    self.model:setQuestOpenData(data)
end
--获取答卷基本内容
function WelfareController:sender24601()
    self:SendProtocal(24601,{})
end
function WelfareController:handle24601(data)
    GlobalEvent:getInstance():Fire(WelfareEvent.Get_SureveyQuest_Basic, data)
end
--获取答卷题目信息
function WelfareController:sender24602()
    self:SendProtocal(24602,{})
end
function WelfareController:handle24602(data)
    GlobalEvent:getInstance():Fire(WelfareEvent.Get_SureveyQuest_Topic_Content, data)
end
--答卷
function WelfareController:sender24603(list)
    local protocal ={}
    protocal.ret_list = list
    self:SendProtocal(24603,protocal)
end
function WelfareController:handle24603(data)
    message(data.msg)
end
--领取奖励
function WelfareController:sender24604()
    self:SendProtocal(24604,{})
end
function WelfareController:handle24604(data)
    message(data.msg)
    if data.code == 1 then
        GlobalEvent:getInstance():Fire(WelfareEvent.Get_SureveyQuest_Get_Reward, data)
    end
end
--周、月礼包
function WelfareController:sender21007(index)
    local protocal = {}
    protocal.type = index or 1
    self:SendProtocal(21007, protocal)
end
function WelfareController:handle21007(data)
    GlobalEvent:getInstance():Fire(WelfareEvent.Updata_Week_Month_Data, data)
end

function WelfareController:handle21008( data )
    self.model:setDailyAwardStatus(data.status)
    GlobalEvent:getInstance():Fire(WelfareEvent.Update_Daily_Awawd_Data)
end

-- 请求领取每日礼
function WelfareController:sender21009(  )
    local protocal = {}
    self:SendProtocal(21009, protocal)
end
function WelfareController:handle21009( data )
    message(data.msg)
end

function WelfareController:openCertifyBindPhoneWindow(status)
    if not status then
        if self.certify_phone then
            self.certify_phone:close()
        end
        self.certify_phone = nil
    else
        if self.certify_phone == nil then 
            self.certify_phone = CertifyBindPhoneWindow.New()
        end
        self.certify_phone:open()
    end
end

--==============================--
--desc:判断是否需要显示绑定手机标签
--time:2019-01-28 10:26:14
--@return 
--==============================--
function WelfareController:checkBindPhoneStatus()
    if self.bind_phone_data == nil or self.bind_phone_data.code ~= 0 then 
        return true 
    end
    return false
end

--==============================--
--desc:手机绑定信息
--time:2019-01-28 10:33:31
--@return 
--==============================--
function WelfareController:getBindPhoneData()
    return self.bind_phone_data
end 

-- 手机绑定
function WelfareController:handle16635(data)
    self.bind_phone_data = data  --code:0:否 1:是 items:物品列表
    self.bind_phone_data.status = data.code         -- 当前状态
    if data.code == 0 and SHOW_BIND_PHONE then  -- 未绑定的时候显示红点
        self:setWelfareStatus(WelfareIcon.bindphone, true)
    end
end

--==============================--
--desc:请求绑定手机
--time:2019-01-30 02:14:07
--@number:手机号码
--@code:请求验证码的时候未空字符,否则输入验证码
--@return 
--==============================--
function WelfareController:requestBindPhone(number, code)
    local protocal = {}
    protocal.number = number
    protocal.code = code
    self:SendProtocal(16636, protocal)
end

-- 领取手机奖励返回
function WelfareController:handle16636(data)
    if self.bind_phone_data == nil then return end
    message(data.msg)

    self.bind_phone_data.status = data.code     -- 0:失败 1:领取奖励成功 2:发送验证码成功
    if data.code ~= 0 then
        -- 发送手机验证完成
        if data.code == 1 then
            self.bind_phone_data.code = 1           -- 结束
            self:openCertifyBindPhoneWindow(false)
        end
        GlobalEvent:getInstance():Fire(WelfareEvent.UpdateBindPhoneStatus, self.bind_phone_data)
    end
end

-- --------微信公众号
function WelfareController:handle16633(data)
    if SHOW_WECHAT_CERTIFY then
        self.wechat_subscription_data = data
        if data.code == 0 then
            self:setWelfareStatus(WelfareIcon.wechat, true)
        end
    end
end

--- 通知服务端已经激活查看微信公众号了
function WelfareController:tellServerWechatStatus()
    if self.wechat_subscription_data and self.wechat_subscription_data.code == 1 then return end
    self:SendProtocal(16634, {})
end

function WelfareController:handle16634(data)
    if self.wechat_subscription_data then
        self.wechat_subscription_data.code = 1
        self:setWelfareStatus(WelfareIcon.wechat, false)
    end
end

function WelfareController:getWechatData()
    return self.wechat_subscription_data
end

--周礼包根据累计充值100元才会开
function WelfareController:handle21021(data)
    self.model:setIsOpenWeekGift(data.flag)
end
