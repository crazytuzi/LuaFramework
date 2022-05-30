-- --------------------------------------------------------------------
-- @author: lwc
-- 满减商城 --需求 任思义
-- <br/>Create: 2019年3月22日
-- --------------------------------------------------------------------
ActionLimitFullExchangePanel = class("ActionLimitFullExchangePanel", function()
    return ccui.Widget:create()
end)


local controller = ActionController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
--@ bid 活动id 参照 holiday_role_data 表
--@ type 活动类型 参照 ActionType.Wonderful 定义
function ActionLimitFullExchangePanel:ctor(bid, type)
    self.holiday_bid = bid
    self.type = type

    self.data = nil
    self.end_count = 0 --最终价格 也是结算价格
    self.original_count = 0 -- 当前价格
    self.discount_count = 0 -- 减免价格
    self.full_exchange_list = {}
    local config_list = Config.HolidayFullExchangeData.data_holiday_full_exchange
    if config_list then
       for k,v in pairs(config_list) do
            if v.val ~= 0 then --过滤了0减免的
                table_insert(self.full_exchange_list, v)
            end
        end
        table_sort( self.full_exchange_list, function(a, b) return a.min < b.min  end)
    end

    self.limit_list = {}
    self.dic_limit_list = {}

    self:configUI()
    self:register_event()
     --scrollview列表
    self:loadResources()
end

function ActionLimitFullExchangePanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("actionfullexchange","actionfullexchange"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("num","type28"), type = ResourcesType.plist }
    } 
    self.resources_load = ResourcesLoad.New(false) 
    self.resources_load:addAllList(self.res_list, function()
        local pos_x = {20, 240, 484}
        self.remove_full_num_label = {}
        self.remove_reduce_num_label = {}
        for i,v in ipairs(self.full_exchange_list) do
            if i <= 3 then
                self.remove_full_num_label[i], self.remove_reduce_num_label[i] = self:initNumUI(pos_x[i], 672, v.min, v.val)        
            end
        end
    end)
end

function ActionLimitFullExchangePanel:configUI( )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_limit_full_exchange_panel"))
    self.root_wnd:setPosition(-40,-105)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container_size = self.main_container:getContentSize()


    self.title_img = self.main_container:getChildByName("title_img")
    self.time_val = self.main_container:getChildByName("time_val")
    self.time_title = self.main_container:getChildByName("time_title")
    self.goods_con = self.main_container:getChildByName("goods_con")

    self.buy_btn = self.main_container:getChildByName("buy_btn")


    self.time_title:setString(TI18N("暖春出游季 购物大酬宾"))
    local tab_vo = controller:getActionSubTabVo(self.type, self.holiday_bid)
    local title_str = nil
     if tab_vo then
        --网络传过来的优先拿网络的
        if tab_vo.aim_title ~= nil and tab_vo.aim_title ~= "" then
            title_str = tab_vo.aim_title
        end
    end
    if title_str == nil then
        title_str = "txt_cn_limit_full_exchange"
    end
    local res = PathTool.getPlistImgForDownLoad("bigbg/action",title_str)
    self.item_load = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load)

    -- -- 活动剩余时间
    -- local time = 0
    -- if tab_vo then
    --     time = tab_vo.remain_sec or 0
    -- end
    -- if time < 0 then
    --     time = 0
    -- end
    -- self:setLessTime(time)
    
    if self.item_scrollview == nil then
        local scroll_view_size = self.goods_con:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 355,                -- 单元的尺寸width
            item_height = 173,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 2,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.goods_con, cc.p(scroll_view_size.width * 0.5,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0.5, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    -- self.item_scrollview:reloadData()

    self.buy_btn = self.main_container:getChildByName("buy_btn")
    --原价
    self.original_price = createRichLabel(22, cc.c4b(0xff,0xf6,0xe4,0xff), cc.p(0,0.5), cc.p(185,35), nil, nil, 900)
    -- 折扣
    self.discount_price = createRichLabel(22, cc.c4b(0xff,0xf6,0xe4,0xff), cc.p(0,0.5), cc.p(345,35), nil, nil, 900)
    self.main_container:addChild(self.original_price)
    self.main_container:addChild(self.discount_price)

    local size = self.buy_btn:getContentSize()
    self.end_price = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(size.width * 0.5 ,size.height * 0.5), nil, nil, 900)
-- 2B610D <div div fontColor=#ffffff fontsize=24 outline=2,#C45A14>*%s</div> <img src=%s visible=true scale=0.35 />
    self.buy_btn:addChild(self.end_price)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionLimitFullExchangePanel:createNewCell(width, height)
   local cell = ActionLimitFullExchangeItem.new(width, height)
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ActionLimitFullExchangePanel:numberOfCells()
    if not self.limit_list then return 0 end
    return #self.limit_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ActionLimitFullExchangePanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.limit_list[index]
    if not cell_data then return end
    local time_desc = cell:setData(cell_data)
end

--点击cell .需要在 createNewCell 设置点击事件
function ActionLimitFullExchangePanel:onCellTouched(cell)
    -- if not cell.index then return end
    -- local cell_data = self.limit_list[cell.index]
    -- if not cell_data then return end
    self:countPrice()
end


--活动时间
function ActionLimitFullExchangePanel:holidayTime(data)
    if data.args then
        local start_time,end_time
        local start_list = keyfind('args_key', 1, data.args) or nil
        if start_list then
            start_time = start_list.args_val
        end
        local end_list = keyfind('args_key', 2, data.args) or nil
        if end_list then
            end_time = end_list.args_val
        end                
        if start_time and end_time then
            local time_str = string_format(TI18N("活动时间：%s 至 %s"),TimeTool.getYMD2(start_time),TimeTool.getYMD2(end_time))
            self.time_val:setString(time_str)
        end
    end
end
--设置倒计时
function ActionLimitFullExchangePanel:setLessTime(less_time)
    if tolua.isnull(self.time_val) then
        return
    end
    doStopAllActions(self.time_val)
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_val:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    doStopAllActions(self.time_val)
                    self:setTimeFormatString(0)
                else
                    self:setTimeFormatString(less_time)
                end
            end))))
    else
        self:setTimeFormatString(0)
    end
end

function ActionLimitFullExchangePanel:setTimeFormatString(time)
    if time > 0 then
        local str = string_format("%s: %s", TI18N("活动时间"), TimeTool.GetTimeFormatDayIIIIII(time))
        self.time_val:setString(str)
    else
        self.time_val:setString(TI18N("活动时间: 00:00:00"))
    end
end

function ActionLimitFullExchangePanel:register_event(  )
    registerButtonEventListener(self.buy_btn, function() self:onBuyBtn() end,true, 2)

    if not self.limin_common_event  then
        self.limin_common_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            if not data then return end
            if data.bid == self.holiday_bid then

                self.data = data
                self:holidayTime(data)
                self:initData()
            end
        end)
    end
end

-- function ActionLimitFullExchangePanel:( ... )
--     -- body
-- end

function ActionLimitFullExchangePanel:onBuyBtn()
    --购买
    if not self.limit_list then return end
    local ids = {}
    for i,v in ipairs(self.limit_list) do
        if v.add_count and v.add_count > 0 then
            table_insert(ids, {id = v.aim, num = v.add_count})
        end
    end

    if self.end_count > 0 then
        local confrim = function()
            controller:sender16665(self.holiday_bid, ids)
        end
        local item_id = Config.ItemData.data_assets_label2id.gold
        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
        local str = string_format("是否消耗<img src='%s' scale=0.3 />%s购买商品?", iconsrc, self.end_count)

        CommonAlert.show(str, TI18N("确定"), confrim, TI18N("取消"),nil, CommonAlert.type.rich)
    else
        message(TI18N("你还没购买东西呢！"))
    end
end

--设置满减数字UI
function ActionLimitFullExchangePanel:initNumUI(x, y, full_num, reduce_num, scale)
    if not x then return end
    if not y then return end
    local full_num = full_num or 0
    local reduce_num = reduce_num or 0
    local scale = scale or 1

    local  obj_tab = {}
    local is_full  = false
    local is_reduce  = false
    local _setPositionCallback = function()
        if is_full and is_reduce then
            local start_x = x
            for i,obj in ipairs(obj_tab) do
                local width = obj:getContentSize().width * scale
                obj:setScale(scale)
                obj:setPositionX(start_x)
                start_x = start_x + width + 2
            end
        end
    end

    local _full_callback = function()
        is_full = true
        _setPositionCallback()
    end

    local _reduce_callback = function()
        is_reduce = true
        _setPositionCallback()
    end

    local full_word_res = PathTool.getResFrame("actionfullexchange", "txt_cn_actionfullexchange_1")
    local reduce_word_res = PathTool.getResFrame("actionfullexchange", "txt_cn_actionfullexchange_2")

    local full_word = createSprite(full_word_res, x, y, self.main_container, cc.p(0, 0.5), LOADTEXT_TYPE_PLIST, 1)
    local reduce_word = createSprite(reduce_word_res, -10000, y, self.main_container, cc.p(0, 0.5), LOADTEXT_TYPE_PLIST, 1)
    local full_label = CommonNum.new(28, self.main_container, nil, 0, cc.p(0, 0.5))
    full_label:setPositionY(y + 27 * 0.5 * scale - 2)
    full_label:setCallBack(_full_callback)

    local reduce_label = CommonNum.new(28, self.main_container, nil, 0, cc.p(0, 0.5))
    reduce_label:setPositionY(y + 27 * 0.5 * scale - 2)
    reduce_label:setCallBack(_reduce_callback)

    table_insert(obj_tab, full_word)
    table_insert(obj_tab, full_label)
    table_insert(obj_tab, reduce_word)
    table_insert(obj_tab, reduce_label)

    full_label:setNum(full_num)
    reduce_label:setNum(reduce_num)
    return full_label, reduce_label
end

--计算价格
function ActionLimitFullExchangePanel:countPrice()
    local total_count = 0
    for i,v in ipairs(self.limit_list) do
        if v.add_count and v.add_count > 0 then
            total_count = total_count + v.show_price * v.add_count
        end
    end
    self.original_count = total_count
    self.discount_count = 0
    if self.full_exchange_list then
        for i,v in ipairs(self.full_exchange_list) do
            if i == 1 and total_count < v.min then
                self.discount_count = 0
                break
            elseif total_count >= v.min and total_count <= v.max then
                self.discount_count = v.val
                break
            end 
            --购买金额大于配置的最大金额
            if i >= #self.full_exchange_list and total_count > v.max then
                self.discount_count = v.val
            end
        end
    end
    self.end_count = self.original_count - self.discount_count

    --写死钻石的
    local item_icon = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id.gold).icon
    local img_str = PathTool.getItemRes(item_icon)

    --原价
    local str = string_format("%s <img src=%s visible=true scale=0.25 />%s", TI18N("原价"), img_str, self.original_count)
    self.original_price:setString(str)
    -- 折扣
    str = string_format("%s <img src=%s visible=true scale=0.25 />%s", TI18N("减免"), img_str, self.discount_count)
    self.discount_price:setString(str)
    
    -- 结算
    str = string_format("<img src=%s visible=true scale=0.25 /><div div fontColor=#ffffff outline=2,#2B610D>%s %s</div>", img_str, self.end_count, TI18N("结算"))
    self.end_price:setString(str)
end


function ActionLimitFullExchangePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
    if bool == true then 
        controller:sender16666(self.holiday_bid)
        controller:cs16603(self.holiday_bid)
    end
end

function ActionLimitFullExchangePanel:initData()
    if self.data then
        self.limit_list = {}
        for i,aim_data in ipairs(self.data.aim_list) do
            local limit_data = self.dic_limit_list[aim_data.aim]
            if limit_data == nil then
                self.dic_limit_list[aim_data.aim] = aim_data
                limit_data = self.dic_limit_list[aim_data.aim]
            else
                for k,v in pairs(aim_data) do
                    limit_data[k] = v
                end
            end
            --默认0 
            limit_data.limit_count = 0
            limit_data.had_count = 0
            limit_data.show_price = 0
            limit_data.add_count = 0 --当前的购买次数
            for _,v in ipairs(aim_data.aim_args) do
                if v.aim_args_key == 2 then --购买次数限制
                    limit_data.limit_count = v.aim_args_val
                elseif v.aim_args_key == 6 then --当前已购买次数
                    limit_data.had_count = v.aim_args_val
                elseif v.aim_args_key == 27 then --显示 金额
                    limit_data.show_price = v.aim_args_val
                elseif v.aim_args_key == 7 then --显示限购类型 1:每日限购 2总限购
                    limit_data.limit_buy_type = v.aim_args_val
                end
            end
            --当前可购买次数
            limit_data.buy_count = limit_data.limit_count - limit_data.had_count
            if limit_data.buy_count < 0 then
                limit_data.buy_count = 0
            end
            if limit_data.buy_count == 0 then
                limit_data.sort_index = 2
            else
                limit_data.sort_index = 1
            end
            table_insert(self.limit_list, limit_data)
        end
        local sort_func = SortTools.tableLowerSorter({"sort_index", "aim"})
        table_sort( self.limit_list, sort_func)

        self.item_scrollview:reloadData()
        self:countPrice()
    end
end

function ActionLimitFullExchangePanel:DeleteMe(  )
    if self.item_scrollview then 
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end


    if self.limin_common_event then
        GlobalEvent:getInstance():UnBind(self.limin_common_event)
        self.limin_common_event = nil
    end

    if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    
    if self.remove_full_num_label then
        for i,v in ipairs(self.remove_full_num_label) do
            v:DeleteMe()     
        end
        self.remove_full_num_label = nil
    end
    if self.remove_reduce_num_label then
        for i,v in ipairs(self.remove_reduce_num_label) do
            v:DeleteMe()     
        end
        self.remove_reduce_num_label = nil
    end

    -- doStopAllActions(self.time_val)
end

------------------------------------------
-- 子项
ActionLimitFullExchangeItem = class("ActionLimitFullExchangeItem", function()
    return ccui.Widget:create()
end)

function ActionLimitFullExchangeItem:ctor(width, height)
    self:configUI(width, height)
    self:register_event()
end

function ActionLimitFullExchangeItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("action/action_limit_full_exchange_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")

    self.item_bg_1 = main_container:getChildByName("item_bg_1")
    self.btn_redu = self.item_bg_1:getChildByName("btn_redu")
    self.btn_add = self.item_bg_1:getChildByName("btn_add")
    
    --运营说不好看.暂时隐藏..不用
    self.pic_has = main_container:getChildByName("pic_has")
    self.pic_has:setVisible(false)
    
    --道具
    local item_node = main_container:getChildByName("item_node")
    self.item_info = BackPackItem.new(false, true, false, 0.9, false, true, false)
    self.item_info:setDefaultTip(true,false)
    item_node:addChild(self.item_info)

    self.item_name = main_container:getChildByName("item_name")
    self.item_name:setString("道具名字")
    self.item_price = main_container:getChildByName("item_price")

    self.buy_num = main_container:getChildByName("buy_num")
    self.limit_name = main_container:getChildByName("limit_name")

    self.buy_icon = main_container:getChildByName("buy_icon") --消耗钻石icon

    local res = PathTool.getResFrame("common","common_99998")
    local edit_content = createEditBox(main_container, res,cc.size(90,30), nil, 22, nil, 22, "", nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_content = edit_content
    edit_content:setAnchorPoint(cc.p(0.5,0.5))
    edit_content:setPlaceholderFontColor(cc.c4b(0xff,0xf6,0xe4,0xff))
    edit_content:setFontColor(cc.c4b(0xff,0xf6,0xe4,0xff))
    edit_content:setPosition(cc.p(234, 65))

    local begin_change_label = false
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if begin_change_label then  
                begin_change_label = false
                self.buy_num:setVisible(true)
                local str = pSender:getText()
                pSender:setText("")  
                if str ~= "" and str ~= self.input_text then
                    local num = tonumber(str)
                    if num ~= nil and num > 0 then
                        self:checkShowNum(num)
                    else
                        self:checkShowNum(0)
                        message(TI18N("请输入数字"))
                    end
                else
                    self:checkShowNum(0)
                end 

            end
        elseif strEventName == "began" then
            if not begin_change_label then
                self.buy_num:setVisible(false)
                begin_change_label = true
            end
        elseif strEventName == "changed" then

        end
    end
    edit_content:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

function ActionLimitFullExchangeItem:register_event( )
    registerButtonEventListener(self.btn_redu, function() self:onClickReduBtn() end,true, 1)
    registerButtonEventListener(self.btn_add, function() self:onClickAddBtn() end,true, 1)
end

function ActionLimitFullExchangeItem:onClickReduBtn()
    if not self.data then return end
    if not self.data.add_count then return end
    self.data.add_count = self.data.add_count - 1
    if self.data.add_count < 0 then
        self.data.add_count = 0
    end
    self:updateLabelNum(self.data.add_count)
end

function ActionLimitFullExchangeItem:onClickAddBtn()
    if not self.data then return end
    if not self.data.add_count then return end
    self.data.add_count = self.data.add_count + 1
    if self.data.add_count > self.data.buy_count then
        self.data.add_count = self.data.buy_count
    end
    self:updateLabelNum(self.data.add_count)
end

function ActionLimitFullExchangeItem:checkShowNum(count)
    local count = math.floor(math.abs(count))
    if count < 0 then
        count = 0 
    elseif count > self.data.buy_count then
        count = self.data.buy_count
    end

    self.data.add_count = count
    self:updateLabelNum(self.data.add_count) 
end

function ActionLimitFullExchangeItem:updateLabelNum(count)
    if self.data.buy_count == 0 then
        -- self.item_bg_1:setVisible(false)
        -- self.pic_has:setVisible(true)
        self:setTouchEnable_Redu(true)
        self:setTouchEnable_Add(true)
        self.buy_num:setString(0)
        self.item_info:setItemIconUnEnabled(true)
        self.edit_content:setVisible(false)
        return
    end
    
    if count ==  0 then
        self:setTouchEnable_Redu(true)
        self:setTouchEnable_Add(false)
    elseif count == self.data.buy_count then
        self:setTouchEnable_Redu(false)
        self:setTouchEnable_Add(true)
    else
        self:setTouchEnable_Redu(false)
        self:setTouchEnable_Add(false)
    end
    self.edit_content:setVisible(true)
    -- self.pic_has:setVisible(false)
    self.item_info:setItemIconUnEnabled(false)
    -- self.item_bg_1:setVisible(true)
    self.buy_num:setString(count)
    if self.callback then
        self.callback()
    end
end


function ActionLimitFullExchangeItem:setTouchEnable_Add(bool)
    setChildUnEnabled(bool,self.btn_add)
    self.btn_add:setTouchEnabled(not bool)
end
function ActionLimitFullExchangeItem:setTouchEnable_Redu(bool)
    setChildUnEnabled(bool,self.btn_redu)
    self.btn_redu:setTouchEnabled(not bool)
end

function ActionLimitFullExchangeItem:addCallBack(callback)
    self.callback = callback
end

function ActionLimitFullExchangeItem:setActionRankCommonType(holiday_bid, type)
    self.holiday_bid = holiday_bid
    self.type = type
end

function ActionLimitFullExchangeItem:setData( data )
    self.data = data
    
    local item_data = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id.gold)
    local img_str = PathTool.getItemRes(item_data.icon)
    self.buy_icon:setScale(0.3)
    loadSpriteTexture(self.buy_icon, img_str, LOADTEXT_TYPE)
    
    self.item_name:setString(self.data.aim_str)
    self.item_price:setString(self.data.show_price)

    if self.data.limit_buy_type == 2 then
        self.limit_name:setString(string_format(TI18N("活动限购(%s/%s)"), self.data.had_count, self.data.limit_count))
    else
        self.limit_name:setString(string_format(TI18N("今日限购(%s/%s)"), self.data.had_count, self.data.limit_count))
    end

    if self.data.item_list and next(self.data.item_list) ~= nil then
        self.item_info:setBaseData(self.data.item_list[1].bid, self.data.item_list[1].num, true)
    end

    self:updateLabelNum(self.data.add_count)
end

function ActionLimitFullExchangeItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end