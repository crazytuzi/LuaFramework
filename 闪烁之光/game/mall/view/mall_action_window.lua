-- --------------------------------------------------------------------
-- 活动商城
-- 
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      活动商城..因为可能会有多个活动.和原本商城有区别.我复制一份出来专门做活动的..逻辑和 mallwindow差不多的
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
MallActionWindow = MallActionWindow or BaseClass(BaseView)
local color_data = {
    [1] = cc.c4b(0xcf,0xb5,0x93,0xff), --默认的颜色
    [2] = cc.c4b(0xff,0xed,0xd6,0xff), --点击的颜色
}
local table_sort = table.sort
local string_format = string.format

function MallActionWindow:__init()
    self.ctrl = MallController:getInstance()
    self.role_vo = RoleController:getInstance():getRoleVo()
    self.is_full_screen = true
    self.win_type = WinType.Full    
    self.layout_name = "mall/mall_action_window"           
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("mall","mall"), type = ResourcesType.plist },
    }


    self.tab_list = {}
    self.cur_tab = nil
    self.cur_index = nil
    self.data_list = {}
end

function MallActionWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_2",true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end
    
    self.mainContainer = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer , 1) 

    self.main_panel = self.mainContainer:getChildByName("main_panel")

    self.tableContainer = self.main_panel:getChildByName("tab_container")
    local tab_btn = nil
    for i=1, 4 do
        tab_btn = self.tableContainer:getChildByName(string.format("tab_btn_%s",i))
        tab_btn.red = tab_btn:getChildByName("tab_tips")
        tab_btn.red:setVisible(false)
        tab_btn.red_num = tab_btn:getChildByName("red_num")
        tab_btn.red_num:setVisible(false)
        tab_btn.select_bg = tab_btn:getChildByName("select_bg")
        tab_btn.select_bg:setVisible(false)
        tab_btn.unselect_bg = tab_btn:getChildByName("unselect_bg")
        tab_btn.label = tab_btn:getChildByName("title")
        tab_btn:setBright(false)
        tab_btn.index = i
        tab_btn:setVisible(false)
        self.tab_list[i] = tab_btn
    end

    self.container = self.main_panel:getChildByName("container")
    self.btn = self.container:getChildByName("btn")
    self.btn_label = createRichLabel(24,1,cc.p(0.5,0.5),cc.p(self.btn:getContentSize().width/2,self.btn:getContentSize().height/2))
    self.btn_label:setString(TI18N("刷新"))
    self.btn:addChild(self.btn_label)
    self.btn:setVisible(false)
    self.coin_bg = self.container:getChildByName("Image_50")
    self.coin = self.container:getChildByName("coin")
    self.count = self.container:getChildByName("count")
    self.add_btn = self.container:getChildByName("add_btn")
    self.add_btn:setVisible(false)
    --self.time = self.container:getChildByName("time")
    self.refresh_count = self.container:getChildByName("refresh_count")
    self.refresh_count:setString("")
    self.tips_btn = self.container:getChildByName('tips_btn')
    self.tips_btn:setVisible(false)
    self.time = createRichLabel(22,58,cc.p(1,0.5),cc.p(650,self.count:getPositionY()))
    self.container:addChild(self.time)
    self.time:setVisible(false)

    self.good_cons = self.container:getChildByName("good_cons")

    self.winTitle = self.main_panel:getChildByName("win_title")
    self.winTitle:setString(TI18N("活动商城"))

    self.close_btn = self.main_panel:getChildByName("close_btn")
end


function MallActionWindow:register_event()
    registerButtonEventListener(self.close_btn, function() self:onCloseBtn() end ,true, 2)
    
    for k, tab_btn in ipairs(self.tab_list) do
        registerButtonEventListener(tab_btn, function() self:changeTabView(tab_btn.index, true) end ,false, 3)
    end

    --获取所有活动数据
    self:addGlobalEvent(MallEvent.Update_Action_event, function(data)
        self:updateData(data)
    end)

    --获取所有活动数据
    self:addGlobalEvent(MallEvent.Buy_Action_Shop_Success_event, function(data)
        if not self.action_data_list then return end
        if self.cur_index and self.action_data_list[self.cur_index] then
            if self.action_data_list[self.cur_index].bid == data.bid then
                local exchange_list = self.action_data_list[self.cur_index].exchange_list
                local list = self.common_scrollview:getActiveCellList()
                for i,cell in ipairs(list) do
                    if cell.index and exchange_list[cell.index].aim == data.aim then
                        exchange_list[cell.index].buy_count = data.buy_count
                        self.common_scrollview:resetItemByIndex(cell.index)
                    end
                end
            end
        end
    end)

    if self.role_assets_event == nil then
        self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ACTION_ASSETS, function(key, value)
            if not self.action_data_list then return end
            if self.cur_index and self.action_data_list[self.cur_index] then
                if key == self.action_data_list[self.cur_index].need_id then
                    self.count:setString(value)
                end  
            end
        end)
    end
end

--关闭
function MallActionWindow:onCloseBtn()
    self.ctrl:openMallActionWindow(false)--关闭
end

function MallActionWindow:openRootWnd(bid)
    self.first_bid = bid 
    self.ctrl:send16660()
    -- self:changeTabView(index)
end

function MallActionWindow:updateData(data)
    if not data then return end
    if data.holiday_exchanges and next(data.holiday_exchanges) == nil then return end
    --记录道具信息
    self.dic_item_config = {}
    --商城数据
    self.action_data_list = {}
    self.cur_index = 1
    table_sort( data.holiday_exchanges , function(a,b) return a.bid < b.bid end )
    for i,v in ipairs(data.holiday_exchanges) do
        if self.tab_list[i] then
            self.tab_list[i].label:setString(v.exchange_name)
            self.tab_list[i]:setVisible(true)
            if self.first_bid and self.first_bid == v.bid then
                self.cur_index = i
            end
        end
        for _,v in ipairs(v.exchange_list) do
            --查找解锁的
            v.sort_lock = 0 --不锁
            if v.aim_args and next(v.aim_args) ~= nil then
                for __,args in ipairs(v.aim_args) do
                    --解锁类型 args.aim_args_val == 1 表示解锁
                    if args.aim_args_key == 3 and args.aim_args_val ~= 1 then
                        v.sort_lock = 1 --表示锁上了
                        break
                    end
                end
            end
        end
        local sort_func = SortTools.tableCommonSorter({{"sort_lock", false}, {"aim", false}})
        table_sort(v.exchange_list , sort_func )
        self.action_data_list[i] = v
    end

    self:changeTabView(self.cur_index)
end

--设置倒计时
function MallActionWindow:setLessTime( less_time )
    if tolua.isnull(self.time) then return end
    self.time:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.time:stopAllActions()
            else
                self:setTimeFormatString(less_time)
            end
        end)
        )))
    else
        self:setTimeFormatString(less_time)
    end
end

function MallActionWindow:setTimeFormatString(time)
    self.rest_time = time
    if time > 0 then
        self.time:setString(string.format(TI18N("剩余时间: %s"),TimeTool.GetTimeFormatDayIIIIII(time)))
    else
        self.time:setString("剩余时间: 0")
    end
end


function MallActionWindow:changeTabView( index , is_check)
    if is_check and self.cur_index == index then return end
    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(cc.c4b(0xcf,0xb5,0x93,0xff))
            self.cur_tab.label:enableOutline(cc.c4b(0x2a,0x16,0x0e,0xff),2)
        end
        self.cur_tab.select_bg:setVisible(false)
    end
    self.cur_index = index
    self.cur_tab = self.tab_list[index]
    
    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(cc.c4b(0xff,0xed,0xd6,0xff))
            self.cur_tab.label:enableOutline(cc.c4b(0x2a,0x16,0x0e,0xff),2)
        end
        self.cur_tab.select_bg:setVisible(true)
    end

    self.tips_btn:setVisible(false)

    self:updateScrollviewList()

    self:updateInfo()
end

--更新主界面信息
function MallActionWindow:updateInfo()
    local need_id = self.action_data_list[self.cur_index].need_id
    local config = Config.ItemData.data_get_data(need_id)
    if config and need_id ~= 0 then
        local res = PathTool.getItemRes(config.icon, false)
        if self.record_cost_res == nil or self.record_cost_res ~= res then
            loadSpriteTexture(self.coin, res, LOADTEXT_TYPE) 
        end
        self.coin_bg:setVisible(true)
        self.coin:setVisible(true)
        self.count:setVisible(true)
    else
        self.coin_bg:setVisible(false)
        self.coin:setVisible(false)
        self.count:setVisible(false)
    end
    local count = self.role_vo:getActionAssetsNumByBid(need_id)
    self.count:setString(count)

    self.time:setVisible(true)
    local time = self.action_data_list[self.cur_index].end_time - GameNet:getInstance():getTime()
    if time < 0 then
        time = 0
    end
    self:setLessTime(time)
end

function MallActionWindow:updateScrollviewList()
    if self.common_scrollview == nil then
        local scroll_view_size = self.good_cons:getContentSize()
        local setting = {
            start_x = 4,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 306,                -- 单元的尺寸width
            item_height = 147,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 2,                         -- 列数，作用于垂直滚动类型
            delay = 4,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.common_scrollview = CommonScrollViewSingleLayout.new(self.good_cons, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.common_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.common_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.common_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.common_scrollview:reloadData()
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function MallActionWindow:createNewCell(width, height)
    local cell = ccui.Widget:create()
    cell.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/mall_item"))
    cell:addChild(cell.root_wnd)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0,0)
    cell:setContentSize(cc.size(width, height))
    cell:setTouchEnabled(true)
    cell.main_container = cell.root_wnd:getChildByName("main_container")
    cell.main_container:setSwallowTouches(false)
    local count_bg = cell.main_container:getChildByName("count_bg")
    --名字
    cell.name_panel = cell.main_container:getChildByName("name_panel")
    cell.name = cell.name_panel:getChildByName("name")

    --消耗icon
    cell.coin = count_bg:getChildByName("coin")
    cell.price = count_bg:getChildByName("price")
    
    --超值或者折扣图片
    cell.discount = cell.main_container:getChildByName("discount")
    cell.discount:setLocalZOrder(20)
    cell.discount_num = cell.discount:getChildByName("discount_num")
    cell.discount_num:setString(TI18N("超值"))
    --售完图片
    cell.sold = cell.main_container:getChildByName("sold")
    cell.sold:setLocalZOrder(20)

    --变灰
    cell.grey = cell.main_container:getChildByName("grey")

    --不要显示的
    cell.main_container:getChildByName("need_icon"):setVisible(false)
    cell.main_container:getChildByName("need_label"):setVisible(false)

    --限购
    cell.discount_label = createRichLabel(20,58,cc.p(0,0),cc.p(133,25))
    cell.main_container:addChild(cell.discount_label)

    -- 解锁条件
    cell.lock_label = createRichLabel(26,1,cc.p(0.5,0.5),cc.p(width*0.5,height*0.5))
    cell.main_container:addChild(cell.lock_label, 99)

    --道具item
    cell.goods_item = BackPackItem.new(true,true)
    cell.goods_item:setPosition(10+cell.goods_item:getContentSize().width/2,height/2)
    cell.goods_item:setDefaultTip()
    cell.main_container:addChild(cell.goods_item)
    registerButtonEventListener(cell, function() self:setCellTouched(cell) end ,false, 0)

    --回收用
    cell.DeleteMe = function() 
        if cell.goods_item ~= nil then
            cell.goods_item:DeleteMe()
            cell.goods_item = nil
        end
    end

    return cell
end
--获取数据数量
function MallActionWindow:numberOfCells()
    if not self.action_data_list then return 0 end
    return #(self.action_data_list[self.cur_index].exchange_list)
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function MallActionWindow:updateCellByIndex(cell, index)
    cell.index = index
    --结构参考 16660协议
    local cell_data = self.action_data_list[self.cur_index].exchange_list[index]
    if not cell_data then return end

    if self.dic_item_config[cell_data.expend_id] == nil then
        self.dic_item_config[cell_data.expend_id] = Config.ItemData.data_get_data(cell_data.expend_id)
    end
    --消耗配置
    local cost_config = self.dic_item_config[cell_data.expend_id]
    --名字
    cell.name:setString(cell_data.aim_str)
    --消耗icon
    if cost_config then
        local res = PathTool.getItemRes(cost_config.icon, false)
        if cell.record_cost_res == nil or cell.record_cost_res ~= res then
            loadSpriteTexture(cell.coin, res, LOADTEXT_TYPE) 
        end
    end
    --出售价格
    cell.price:setString(cell_data.expend_num)
    
    --超值或者折扣图片
    if cell_data.lable == 1 then
        cell.discount:setVisible(true)
    else
        cell.discount:setVisible(false)
    end

    -- 扩展参数
    local monopoly_need_step_id
    local limit_buy_type = 4

    for k, args in pairs(cell_data.aim_args) do
        if args.aim_args_key == 1 then  --特指 圣夜奇境 活动里面的解锁关卡
            monopoly_need_step_id = args.aim_args_val
        elseif args.aim_args_key == 2 then  --限购类型  日 周 月 限购等
            limit_buy_type = args.aim_args_val
        -- elseif args.aim_args_key == 3 then  --是否解锁 在上面判定了
        end
    end

    local gray_is_show = false
    if cell_data.buy_count >= cell_data.limit_buy then
        cell.sold:setVisible(true)
        cell.grey:setVisible(true)
        cell.discount_label:setString("")
        gray_is_show = true
    else
        cell.sold:setVisible(false)
        cell.grey:setVisible(false)
        self:showLimitBuyInfo(cell, cell_data, limit_buy_type)
    end

    if cell_data.sort_lock == 1 then --锁上的
        cell.grey:setVisible(true)
        if monopoly_need_step_id then --说明活动是 圣夜奇境的 
            local customs_cfg = Config.MonopolyMapsData.data_customs[monopoly_need_step_id]
            if customs_cfg then
                cell.lock_label:setString(string.format(TI18N("<div outline=2,#8D1404>解锁【%s】</div>"), customs_cfg.name))
            end
        else --其他的..需要的添加
            cell.lock_label:setString(string.format(TI18N("<div outline=2,#8D1404>未解锁</div>")))
        end
        
        cell.is_lock = true
    else
        if not gray_is_show then
            cell.grey:setVisible(false)
        end
        cell.lock_label:setString("")
        cell.is_lock = false 
    end

    --道具
    if cell_data.item_list and #cell_data.item_list > 0 then
        local bid = cell_data.item_list[1].bid
        cell.bid = bid
        local num = cell_data.item_list[1].num
        cell.goods_item:setBaseData(bid, num, true)     
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function MallActionWindow:setCellTouched(cell)
    if not cell.index then return end
    local cell_data = self.action_data_list[self.cur_index].exchange_list[cell.index]
    if not cell_data then return end
    if cell.is_lock then return end
    if cell_data.buy_count >= cell_data.limit_buy then
        return
    end
    --按钮 
    local shop_data = {}
    shop_data.shop_type = MallConst.MallType.ActionShop
    shop_data.item_id = cell.bid or 1
    shop_data.name = cell_data.aim_str
    shop_data.limit_num = cell_data.limit_buy
    shop_data.has_buy = cell_data.buy_count
    shop_data.price = cell_data.expend_num
    shop_data.pay_type = cell_data.expend_id
    shop_data.is_show_limit_label = true

    shop_data.bid = self.action_data_list[self.cur_index].bid --子活动编号
    shop_data.aim = cell_data.aim

    if cell_data.item_list and cell_data.item_list[1] then
        shop_data.item_num = cell_data.item_list[1].num or 1
    end    
    self.ctrl:openMallBuyWindow(true,shop_data)
end


function MallActionWindow:showLimitBuyInfo(cell, cell_data, limit_buy_type)
    if not cell then return end
    if limit_buy_type == 1 then
        cell.discount_label:setString(string_format(TI18N("日限购%s/%s个"), cell_data.buy_count, cell_data.limit_buy))
    elseif limit_buy_type == 2 then
        cell.discount_label:setString(string_format(TI18N("周限购%s/%s个"), cell_data.buy_count, cell_data.limit_buy))
    elseif limit_buy_type == 3 then
        cell.discount_label:setString(string_format(TI18N("月限购%s/%s个"), cell_data.buy_count, cell_data.limit_buy))
    else
        cell.discount_label:setString(string_format(TI18N("限购%s/%s个"), cell_data.buy_count, cell_data.limit_buy))
    end
end

function MallActionWindow:close_callback()

    if self.role_assets_event then
        if self.role_vo then
            self.role_vo:UnBind(self.role_assets_event)
        end
        self.role_assets_event = nil
        self.role_vo = nil
    end

    if self.common_scrollview then
        self.common_scrollview:DeleteMe()
        self.common_scrollview = nil
    end

    self.ctrl:openMallActionWindow(false)
end




