-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: gongjianjun@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      商城的逻辑控制层
-- <br/>Create: 2017-05-11
-- --------------------------------------------------------------------
MallController = MallController or BaseClass(BaseController)

function MallController:config()
    self.model = MallModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self.is_first_login = true
    self.temp_data = nil
end

function MallController:setFirstLogin( status )
    self.is_first_login = status
end

function MallController:setExchangeBuyData(data)
    self.temp_data = data
end


function MallController:getModel()
    return self.model
end

function MallController:registerEvents()
    if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Top_Update_Data, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            self.role_vo = RoleController:getInstance():getRoleVo()
            if self.role_vo ~= nil then
                local data = BattleDramaController:getInstance():getModel():getDramaData()
                local max_dun_id = Config.CityData.data_base[1].activate[1][2]
                if data.max_dun_id and data.max_dun_id >= max_dun_id then --功能开启了
                    ---判断一下需要红点提示的物品买没买 仅在钻石商城
                    local config = Config.ExchangeData.data_shop_list[1]
                    if config.login_red and next(config.login_red)~=nil then 
                        self:sender13401(1)
                    end
                end
            end
        end)
    end 
end

function MallController:registerProtocals()
    self:RegisterProtocal(13401, "handle13401")  --商城进入数据请求 
    self:RegisterProtocal(13402, "handle13402")  --普通商店购买
    self:RegisterProtocal(13403, "handle13403")  --神秘商店请求
    self:RegisterProtocal(13404, "handle13404")  --服务端推送神秘商店可以刷新
    self:RegisterProtocal(13405, "handle13405")  --神秘商城刷新列表
    
    self:RegisterProtocal(13407, "handle13407")  --神秘商店购买
    self:RegisterProtocal(13419, "handle13419")
    self:RegisterProtocal(13420, "handle13420")  --商店刷新状态

    --活动商城 协议
    self:RegisterProtocal(16660, "handle16660")  --获取商城道具信息
    self:RegisterProtocal(16661, "handle16661")  --购买道具协议

    -- 自选礼包商店
    self:RegisterProtocal(27800, "handle27800")  -- 自选礼包商店数据
    self:RegisterProtocal(27801, "handle27801")  -- 0元购自选礼包
    self:RegisterProtocal(21022, "handle21022")  -- 已开启的充值商店列表
    self:RegisterProtocal(21023, "handle21023")  -- 0元购周、月礼包
    self:RegisterProtocal(21024, "handle21024")  -- 商业街红点
end

--打开主界面
--bid 需求的物品bid
function MallController:openMallPanel(bool, name, bid)
    if bool == true then
        local build_vo = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.shop)
        if build_vo and build_vo.is_lock then
            message(build_vo.desc)
            return
        end

        name = name or MallConst.MallType.GodShop
        local shop_cfg = Config.ExchangeData.data_shop_list[name]
        self.need_bid = bid
        --[[ if shop_cfg.score_sort > 0 then -- 积分商店
            self:openScoreShopWindow(true, name)
        else ]]
            if not self.mall_panel  then
                self.mall_panel = MallWindow2.New()
            end
            self.mall_panel:open(name)
        --end
    else
        if self.mall_panel then 
            self.mall_panel:close()
            self.mall_panel = nil
        else
            self:openScoreShopWindow(false)
        end
    end
end

--打开活动商城
--@ bid 活动对应的bid 不传默认打开 第一个
function MallController:openMallActionWindow(bool, bid)
    if bool == true then
        if not self.mall_action_window  then
            self.mall_action_window = MallActionWindow.New()
        end
        self.mall_action_window:open(bid)
    else
        if self.mall_action_window then 
            self.mall_action_window:close()
            self.mall_action_window = nil
        end
    end
end


--打开单个商店面板
function MallController:openMallSingleShopPanel(bool, setting)
    if bool == true then
        if not self.mall_single_shop_panel  then
            self.mall_single_shop_panel = MallSingleShopPanel.New()
        end
        self.mall_single_shop_panel:open(setting)
    else
        if self.mall_single_shop_panel then 
            self.mall_single_shop_panel:close()
            self.mall_single_shop_panel = nil
        end
    end
end

--==============================--
--desc:引导需要
--time:2018-07-19 07:41:55
--@return 
--==============================--
function MallController:getMallRoot()
    if self.mall_panel then
        return self.mall_panel.root_wnd
    end
end

function MallController:getNeedBid(  )
    return self.need_bid
end

--设置需求的物品bid (给不在商城建筑里的商城类型设置
function MallController:setNeedBid( bid )
    self.need_bid = bid
end

--打开商城批量购买界面
function MallController:openMallBuyWindow( bool,data)
    if bool == true then
        if data then
            if data.shop_type == MallConst.MallType.Recovery or data.shop_type == MallConst.MallType.ActionShop or 
               data.shop_type == MallConst.MallType.FestivalAction or data.shop_type == MallConst.MallType.SuitShop or data.shop_type == MallConst.MallType.ActionYearMonsterExchange then
                if not self.mall_buy_win then
                    self.mall_buy_win = MallBuyWindow.New()
                end
                self.mall_buy_win:open()
                self.mall_buy_win:setData(data)
            else
                local price_val = 0
                if data['discount'] and data.discount > 0 then
                    price_val = data.discount
                else
                    price_val = data.price
                end
                local is_can_buy_num = self.model:checkMoenyByType(data.pay_type, price_val)
                if is_can_buy_num <= 0 then
                    local pay_config = nil
                    if type(data.pay_type) == 'number' then
                        pay_config = Config.ItemData.data_get_data(data.pay_type)
                    else
                        pay_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id[data.pay_type])
                    end
                    if pay_config then
                        if pay_config.id == Config.ItemData.data_assets_label2id.gold or pay_config.id == Config.ItemData.data_assets_label2id.gold then
                            if FILTER_CHARGE then
                                message(TI18N("钻石不足"))
                            else
                                local function fun()
                                    VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
                                    --self:openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
                                end
                                local str = string.format(TI18N('%s不足，是否前往充值'), pay_config.name)
                                CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
                            end
                        else
                            BackpackController:getInstance():openTipsSource(true, pay_config)
                        end
                    end
                else
                    if not self.mall_buy_win  then
                        self.mall_buy_win = MallBuyWindow.New()
                    end
                    self.mall_buy_win:open()
                    self.mall_buy_win:setData(data)
                end
            end
        end
    else
        if self.mall_buy_win then 
            self.mall_buy_win:close()
            self.mall_buy_win = nil
        end
    end
end


--==============================--
--desc:热卖商城的礼包查看界面
--time:2017-11-16 03:52:24
--@bool:
--@data:
--@return 
--==============================--
function MallController:openMallGiftPanel(bool,data)
    if bool == true then 
        if not self.mall_gift_panel then 
            self.mall_gift_panel = MallGiftPanel.New()
        end
        self.mall_gift_panel:open(data)
    else 
        if self.mall_gift_panel then 
            self.mall_gift_panel:close()
            self.mall_gift_panel = nil
        end
    end
end

function MallController:sender13401(type)
    local protocal ={}
    protocal.type = type
    self:SendProtocal(13401,protocal)
end

function MallController:handle13401( data )
    -- MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.shop, status and self.is_first_login)
    GlobalEvent:getInstance():Fire(MallEvent.Open_View_Event,data)
end

function MallController:sender13402(eid,num)
    local protocal ={}
    protocal.eid = eid
    protocal.num= num
    self:SendProtocal(13402,protocal)
end
function MallController:handle13402( data )
    --Debug.info(data)
    showAssetsMsg(data.msg)
    if data.code == 1 then
        GlobalEvent:getInstance():Fire(MallEvent.Buy_Success_Event,data)
    end
end

--神秘商店请求
function MallController:sender13403(type)
    local protocal ={}
    protocal.type = type
    self:SendProtocal(13403,protocal)
end
function MallController:handle13403( data )
    message(data.msg)
    GlobalEvent:getInstance():Fire(MallEvent.Get_Buy_list,data)   
end

--服务端推送神秘商店可以刷新
function MallController:handle13404( data )
    -- Debug.info(data)
    -- GlobalEvent:getInstance():Fire(MallEvent.Frash_tips_event)
end
--刷新列表
function MallController:sender13405(type)
    local protocal ={}
    protocal.type = type
    self:SendProtocal(13405,protocal)
end
function MallController:handle13405( data )
    --Debug.info(data)
    message(data.msg)
    if data.code==1 then
         GlobalEvent:getInstance():Fire(MallEvent.Get_Buy_list,data)
    end
end

--神秘商店购买
function MallController:sender13407(order,type,buy_type,num)
    local protocal ={}
    protocal.order = order
    protocal.type = type
    protocal.buy_type = buy_type
    protocal.num = num or 1
    self:SendProtocal(13407,protocal)
end
function MallController:handle13407( data )
    message(data.msg)
    if data.code == 1 then
        GlobalEvent:getInstance():Fire(MallEvent.Buy_One_Success,data)
    end
end

function MallController:send13419(num)
    local protocal = {}
    protocal.num = num
    self:SendProtocal(13419,protocal)
end

function MallController:handle13419(data)
    message(data.msg)
    if data.code == 1 then
        if self.temp_data then
            self:sender13407(self.temp_data.order, self.temp_data.shop_type, 1)
            self.temp_data = nil
        end
    end
end

----------------------------------活动商城协议------------------------------------------
function MallController:send16660()
    local protocal = {}
    self:SendProtocal(16660,protocal)
end

function MallController:handle16660(data)
    message(data.msg)
    GlobalEvent:getInstance():Fire(MallEvent.Update_Action_event,data)
end
--{uint32, bid, "子活动编号;"},
--{uint32, aim, "商品id"},
--{uint32, num, "购买数量"}
function MallController:send16661(bid, aim, num)
    local protocal = {}
    protocal.bid = bid
    protocal.aim = aim
    protocal.num = num
    self:SendProtocal(16661,protocal)
end

function MallController:handle16661(data)
    message(data.msg)
    if data.code == 1 then
        GlobalEvent:getInstance():Fire(MallEvent.Buy_Action_Shop_Success_event,data)
    end
end
----------------------------------活动商城协议结束------------------------------------------

-- 自选礼包（触发式礼包）
function MallController:sender27800(  )
    local protocal = {}
    self:SendProtocal(27800,protocal)
end

function MallController:handle27800( data )
    GlobalEvent:getInstance():Fire(MallEvent.Get_Chose_Shop_Data_Event, data)
end

-- 请求0元购买自选礼包
function MallController:sender27801( package_id )
    local protocal = {}
    protocal.package_id = package_id
    self:SendProtocal(27801,protocal)
end

function MallController:handle27801( data )
    if data.msg then
        message(data.msg)
    end
end

-- 请求已开启的充值商城列表
function MallController:sender21022(  )
    local protocal = {}
    self:SendProtocal(21022,protocal)
end

function MallController:handle21022( data )
    GlobalEvent:getInstance():Fire(MallEvent.Get_Open_Charge_Shop_Event, data)
end

-- 请求购买周、月礼包0元礼包
function MallController:sender21023( package_id )
    local protocal = {}
    protocal.package_id = package_id
    self:SendProtocal(21023,protocal)
end

function MallController:handle21023( data )
    if data.msg then
        message(data.msg)
    end
end

-- 商业街红点
function MallController:handle21024( data )
    local variety_red = false
    local weekly_red = false
    local monthly_red = false
    local chose_red = false
    for _,v in pairs(data.list) do
        if v.id == 1 then -- 周礼包
            weekly_red = true
        elseif v.id == 2 then -- 月礼包
            monthly_red = true
        elseif v.id == 3 then -- 自选礼包
            chose_red = true
        elseif v.id == 4 then -- 精灵商店
            variety_red = true
        end
    end
    -- 精灵红点
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.variety, variety_red)
    --[[ if self.model:getMallRedStateByBid(MallConst.Red_Index.Variety) ~= variety_red then
        self.model:updateMallRedStatus(MallConst.Red_Index.Variety, variety_red)
    end
    if self.model:getMallRedStateByBid(MallConst.Red_Index.Weekly) ~= weekly_red then
        self.model:updateMallRedStatus(MallConst.Red_Index.Weekly, weekly_red)
    end
    if self.model:getMallRedStateByBid(MallConst.Red_Index.Monthly) ~= monthly_red then
        self.model:updateMallRedStatus(MallConst.Red_Index.Monthly, monthly_red)
    end
    if self.model:getMallRedStateByBid(MallConst.Red_Index.Chose) ~= chose_red then
        self.model:updateMallRedStatus(MallConst.Red_Index.Chose, chose_red)
    end ]]
end

----------------------------杂货店相关
-- 打开杂货店界面
function MallController:openVarietyStoreWindows( status )
    if status == true then
        if self.variety_store_view == nil then
            self.variety_store_view = VarietyStoreWindows.New()
        end
        if self.variety_store_view:isOpen() == false then
            self.variety_store_view:open()
        end
    else
        if self.variety_store_view then
            self.variety_store_view:close()
            self.variety_store_view = nil
        end
    end
end

-- 引导需要
function MallController:getVarietyStoreRoot(  )
    if self.variety_store_view then
        return self.variety_store_view.root_wnd
    end
end

function MallController:handle13420( data )
    GlobalEvent:getInstance():Fire(MallEvent.Free_Refresh_Data,data)
end

----------------------@皮肤商店
function MallController:openSkinShopWindow(status)
    if status == true then
        if not self.skin_shop_wnd then
            self.skin_shop_wnd = SkinShopWindow.New()
        end
        if self.skin_shop_wnd:isOpen() == false then
            self.skin_shop_wnd:open()
        end
    else
        if self.skin_shop_wnd then
            self.skin_shop_wnd:close()
            self.skin_shop_wnd = nil
        end
    end
end

-----------------------@ 圣羽商店
function MallController:openPlumeShopWindow(status)
    if status == true then
        if not self.plume_shop_wnd then
            self.plume_shop_wnd = PlumeShopWindow.New()
        end
        if self.plume_shop_wnd:isOpen() == false then
            self.plume_shop_wnd:open()
        end
    else
        if self.plume_shop_wnd then
            self.plume_shop_wnd:close()
            self.plume_shop_wnd = nil
        end
    end
end

-------------------@ 积分商店
function MallController:openScoreShopWindow(status, sub_type)
    if status == true then
        if not self.score_shop_wnd then
            self.score_shop_wnd = ScoreShopWindow.New()
        end
        if self.score_shop_wnd:isOpen() == false then
            self.score_shop_wnd:open(sub_type)
        end
    else
        if self.score_shop_wnd then
            self.score_shop_wnd:close()
            self.score_shop_wnd = nil
        end
    end
end

-----------------@ 充值商城
function MallController:openChargeShopWindow( status, sub_type )
    VipController:getInstance():openVipMainWindow(status, VIPTABCONST.CHARGE)
    --[[ if status == true then
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
        
        if not self.charge_shop_wnd then
            self.charge_shop_wnd = ChargeShopWindow.New()
        end
        if self.charge_shop_wnd:isOpen() == false then
            self.charge_shop_wnd:open(sub_type)
        end
    else
        if self.charge_shop_wnd then
            self.charge_shop_wnd:close()
            self.charge_shop_wnd = nil
        end
    end ]]
end

-- 特权钻石购买确认框
function MallController:openChargeSureWindow( status, data )
    if status == true then
        if not self.charge_sure_wnd then
            self.charge_sure_wnd = ChargeSureWindow.New()
        end
        if self.charge_sure_wnd:isOpen() == false then
            self.charge_sure_wnd:open(data)
        end
    else
        if self.charge_sure_wnd then
            self.charge_sure_wnd:close()
            self.charge_sure_wnd = nil
        end
    end
end

function MallController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end