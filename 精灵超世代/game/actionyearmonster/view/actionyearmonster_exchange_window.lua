--******** 文件说明 ********
-- @Author:      xhj
-- @description: 集字兑换
-- @DateTime:    2020-01-13 10:51:42
-- *******************************


ActionyearmonsterExchangeWindow = ActionyearmonsterExchangeWindow or BaseClass(BaseView)

local controller = ActionyearmonsterController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local roleVo = RoleController:getInstance():getRoleVo()

function ActionyearmonsterExchangeWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("actionyearmonster", "actionyearmonster"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("actionyearmonster", "actionyearmonster_ch"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/actionyearmonster","actionyearmonster_exchang_bg"), type = ResourcesType.single }
    }
    self.layout_name = "actionyearmonster/actionyearmonster_exchange_panel"
    
end

function ActionyearmonsterExchangeWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")
    
    self.banner_bg = self.main_panel:getChildByName("banner_bg")

    self.close_btn = self.main_panel:getChildByName("close_btn")
    
    self.win_title = self.main_panel:getChildByName("win_title")
    self.win_title:setString(TI18N("集字兑换"))
    self.time_label = self.main_panel:getChildByName("label_time_key")
    self.time_label:setString(TI18N("海量奖励，限时兑换"))
    self.time_text = self.main_panel:getChildByName("label_time")
    self.time_text:setVisible(false)
    self.tips = self.main_panel:getChildByName("tips")
    self.tips:setString(TI18N("活动期间，收集指定文字可兑换超值道具组合"))
    self.btn_rule = self.main_panel:getChildByName("look_btn")
    

    self:loadBannerImage()

    local child_goods = self.main_panel:getChildByName("scroll_panel")
    local scroll_view_size = child_goods:getContentSize()
    local setting = {
        item_class = ActionyearmonsterExchangeItem,
        start_x = 2,
        space_x = 0,
        start_y = 0,
        space_y = 0,
        item_width = 596,
        item_height = 129,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.child_scrollview = CommonScrollViewLayout.new(child_goods, cc.p(0,0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.child_scrollview:setSwallowTouches(false)

    controller:sender28217()
    
    
end

--加载banner图片
function ActionyearmonsterExchangeWindow:loadBannerImage()
    -- 横幅图片
    local res = PathTool.getPlistImgForDownLoad("bigbg/actionyearmonster", "actionyearmonster_exchang_bg")
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.banner_bg) then
                loadSpriteTexture(self.banner_bg, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end
end
function ActionyearmonsterExchangeWindow:setPanelData()
    local start_unixtime = self.start_unixtime or 0
    local end_unixtime = self.end_unixtime or 0
    ActionController:getInstance():getModel():setCountDownTime(self.time_text,end_unixtime-GameNet:getInstance():getTime())
end

function ActionyearmonsterExchangeWindow:setItemData()
    if self.child_scrollview then
        local list = self:setConfigData()
        self.child_scrollview:setData(list)
    end
    -- self:setPanelData()
end

function ActionyearmonsterExchangeWindow:setConfigData()
    local list = {}
    local config = Config.HolidayNianData.data_exchange
    if config == nil then
        return list
    end
    for i,v in pairs(config) do
        local buy_data = model:getExchangeDataById(v.id)
        if buy_data then--and buy_data.flag ==1 
            local temp_data = {}
            local day_count = buy_data.last_num or 0      --剩余次数
            temp_data.cfg = v
            temp_data.count = day_count
            temp_data.flag = buy_data.flag
            if temp_data.count <= 0 then
                temp_data.sort = 1000000
            else
                temp_data.sort = v.id
            end
            table_insert(list,temp_data)

            if self.start_unixtime ~= buy_data.start_unixtime then
                self.start_unixtime = buy_data.start_unixtime    
            end
            if self.end_unixtime ~= buy_data.end_unixtime then
                self.end_unixtime = buy_data.end_unixtime    
            end
        end
    end
    
    local sort_func = SortTools.tableCommonSorter({{"flag", true},{"sort",false}})--{"id", false}
    table_sort(list, sort_func)
    return list
end 

function ActionyearmonsterExchangeWindow:register_event()
    if not self.update_exchange_data_event then
        self.update_exchange_data_event = GlobalEvent:getInstance():Bind(ActionyearmonsterEvent.UPDATE_EXCHANGE_DATA_EVENT,function()
            if self.setItemData then
                self:setItemData()
            end
        end)
    end

    registerButtonEventListener(self.close_btn, function()
        controller:openActionyearmonsterExchangeWindow(false)
    end ,true, 2)

    registerButtonEventListener(self.background, function()
        controller:openActionyearmonsterExchangeWindow(false)
    end ,false, 2)

    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        local config = Config.HolidayNianData.data_const.exchange_desc
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end ,true, 1)
end

function ActionyearmonsterExchangeWindow:openRootWnd()
   
end

function ActionyearmonsterExchangeWindow:close_callback(  )
	doStopAllActions(self.time_text)
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    if self.child_scrollview then
        self.child_scrollview:DeleteMe()
    end
    self.child_scrollview = nil

    if self.update_exchange_data_event then
        GlobalEvent:getInstance():UnBind(self.update_exchange_data_event)
        self.update_exchange_data_event = nil
    end

    controller:openActionyearmonsterExchangeWindow(false)
end

------------------------------------------
-- 兑换子项
------------------------------------------
ActionyearmonsterExchangeItem = class("ActionyearmonsterExchangeItem", function()
    return ccui.Widget:create()
end)

function ActionyearmonsterExchangeItem:ctor()
    self:configUI()
    self:register_event()
end

function ActionyearmonsterExchangeItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("actionyearmonster/actionyearmonster_exchange_item"))
    self:setContentSize(cc.size(596,129))
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.txt_task = main_container:getChildByName("txt_task")               --剩余
    self.txt_task:setString("")
    self.btn_exchange = main_container:getChildByName("btn_exchange")       --兑换
    self.txt_exchange = self.btn_exchange:getChildByName("txt_exchange")
    self.txt_exchange:setString(TI18N("兑换"))
    self.img_has_get = main_container:getChildByName("img_has_get")
    self.img_has_get:setVisible(false)

    self.cost_good_cons = main_container:getChildByName("cost_good_cons")
    self.cost_good_cons:setScrollBarEnabled(false)
    
    self.time_lab = createRichLabel(18, 1, cc.p(0.5, 0.5), cc.p(528, 18), 5, nil, 200)
    main_container:addChild(self.time_lab)

    self.get_good_cons = main_container:getChildByName("get_good_cons")
    local scroll_view_size = self.get_good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,
        start_x = 3,
        space_x = 5,
        start_y = 4,
        space_y = 4,
        item_width = BackPackItem.Width*0.80,
        item_height = BackPackItem.Height*0.80,
        row = 1,
        col = 0,
        scale = 0.80
    }
    self.get_item_scrollview = CommonScrollViewLayout.new(self.get_good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.get_item_scrollview:setSwallowTouches(false)
end

function ActionyearmonsterExchangeItem:register_event()
    registerButtonEventListener(self.btn_exchange, function()
        self:btnExchange()
    end ,true, 1)
end

function ActionyearmonsterExchangeItem:btnExchange()
    if self.data and self.data.cfg and self.data.cfg.gain and self.data.cfg.gain[1] and self.data.cfg.loss then
        local temp_count = nil
        for k,v in pairs(self.data.cfg.loss) do
            local num = roleVo:getActionAssetsNumByBid(v[1])
            local need_num = self.loss_num_list[v[1]]
            if num and need_num then
                if temp_count == nil then
                    temp_count = math.floor( num/need_num )
                elseif math.floor( num/need_num ) < temp_count then
                    temp_count = math.floor( num/need_num ) 
                end
            end
        end
        local count = self.data.count
        if temp_count < self.data.count then
            count = temp_count
        end
        
        if count<=0 then
            message(TI18N("道具不足"))
            return
        end
        -- if count == 1 then
        --     local tips_str = string_format(TI18N("是否消耗<div fontColor=#289b14 fontsize= 26>%s</div>兑换物品？"), "")--self.data.name_str
        --     CommonAlert.show(tips_str, TI18N("确定"), function()
        --         if self.data and self.data.charge_id then
        --             controller:sender28216(self.data.charge_id,1)
        --         end
        --     end, TI18N("取消"), nil, CommonAlert.type.rich)
        -- else
            local buy_data = {}
            buy_data.bid = self.data.charge_id
            buy_data.item_bid = self.data.cfg.gain[1][1]
            buy_data.quantity = self.data.cfg.gain[1][2]
            buy_data.shop_type = MallConst.MallType.ActionYearMonsterExchange
            buy_data.limit_num = count -- 限购个数
            buy_data.has_buy = 0
            buy_data.is_show_limit_label = true
            local item_config = Config.ItemData.data_get_data(self.data.cfg.gain[1][1])
            buy_data.name = item_config.name
            buy_data.aim = self.data.charge_id or 0


            buy_data.pay_type = 3
            buy_data.price = 1

            MallController:getInstance():openMallBuyWindow(true,buy_data)
        -- end
    end
end

function ActionyearmonsterExchangeItem:setData(data)
    if not data then return end
    self:setChangeData(data)
end

function ActionyearmonsterExchangeItem:setChangeData(data)
    self.data = data
    self.data.charge_id = data.cfg.id
 
    self.txt_task:setString(TI18N(string_format("剩余:%d", data.count)))

    --加载礼包物品列表
    self.loss_num_list = {}
    for k,v in pairs(data.cfg.loss) do
        self.loss_num_list[v[1]] = v[2]
    end
    self:updateCostItemList(data.cfg.loss)
    self:updateGetItemList(self.get_item_scrollview, data.cfg.gain) 

    self.btn_exchange:setTouchEnabled(data.count ~= 0 and data.flag == 1)
    local time = data.cfg.end_unixtime-GameNet:getInstance():getTime()
    local is_colse = false
    if time<=0 then
        is_colse = true
    end
    if data.count == 0 or data.flag ~= 1 or is_colse == true then
        setChildUnEnabled(true, self.btn_exchange)
        self.txt_exchange:disableEffect(cc.LabelEffect.OUTLINE)
    else
        setChildUnEnabled(false, self.btn_exchange)
        self.txt_exchange:enableOutline(Config.ColorData.data_color4[277], 2)
    end
    
    if data.flag == 1 then
        self.time_lab:setString(string_format(TI18N("限时:<div fontcolor=#6CD228 fontsize=18 >%s</div>"),TimeTool.GetTimeFormatDayIIIIII(time)))
    else
        if is_colse == true then
            self.time_lab:setString(TI18N("已结束"))
        else
            self.time_lab:setString(string_format(TI18N("%s开启"),TimeTool.getMD2(data.cfg.start_unixtime)))
        end
    end
end

function ActionyearmonsterExchangeItem:updateCostItemList(data_list)
    local setting = {}
    setting.scale = 0.7
    setting.max_count = 4
    setting.is_center = false
    setting.space_x = 0
    setting.start_x = -5
    setting.is_show_bg = false
    self.buy_item_list = commonShowSingleRowItemList(self.cost_good_cons, self.buy_item_list, data_list, setting)

    delayRun(self.cost_good_cons, 4/60, function ()
		if self.buy_item_list then
			for k,v in pairs(self.buy_item_list) do
				if v and not tolua.isnull(v) then
                    if v.item_icon and not tolua.isnull(v.item_icon) then
                        v.item_icon:setScale(1.3)
                    end
                    if v.cur_num_lab == nil then
                        local temp_lab = createLabel(20, 1, nil, v:getRoot():getContentSize().width / 2, 5, '', v:getRoot(), nil, cc.p(0.5, 1)) 
                        temp_lab:setScale(1.3)
                        v.cur_num_lab = temp_lab
                    end

                    local item_data = v:getData()
                    
                    if item_data and self.loss_num_list then
                        local num = roleVo:getActionAssetsNumByBid(item_data.id)
                        local need_num = self.loss_num_list[item_data.id]
                        if num and need_num then
                            v.cur_num_lab:setString(string_format( "%d/%d",need_num,num))	
                            if num - need_num>=0 then
                                v:setItemIconUnEnabled(false)
                                v.cur_num_lab:setTextColor(cc.c4b(0x95,0x53,0x22,0xff))
                            else
                                v:setItemIconUnEnabled(true)
                                v.cur_num_lab:setTextColor(cc.c4b(0xd9,0x50,0x14,0xff))
                            end
                        end
                    end
				end
			end
		end
	end)
end

function ActionyearmonsterExchangeItem:updateGetItemList(parent, data_list)
    -- 物品列表
    local list = {}
    for k, v in pairs(data_list) do
        local vo = {}
        vo.bid = v[1]
        vo.quantity = v[2]
        table.insert(list, vo)
    end
    parent:setData(list)
    parent:addEndCallBack(function()
        local list = parent:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip(true, false)
            v:setSwallowTouches(false)
        end
    end)
    if #data_list <= 2 then
        parent:setTouchEnabled(false)
    end
end

function ActionyearmonsterExchangeItem:DeleteMe()
    doStopAllActions(self.cost_good_cons)
    if self.get_item_scrollview then
        self.get_item_scrollview:DeleteMe()
        self.get_item_scrollview = nil
    end
    if self.buy_item_list then
		for i,v in pairs(self.buy_item_list) do
			if v.DeleteMe then
				v:DeleteMe()
			end
        end
        self.buy_item_list = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end