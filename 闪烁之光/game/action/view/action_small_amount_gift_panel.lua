-- --------------------------------------------------------------------
-- @author: lwc
--   小额礼包  后端 汉子  运营 圣锋
-- <br/>Create: 2019年11月1日
-- --------------------------------------------------------------------
ActionSmallAmountGiftPanel = class("ActionSmallAmountGiftPanel", function()
    return ccui.Widget:create()
end)

local data_three_gear_gift_const = Config.FunctionData.data_three_gear_gift_const
local controller = ActionController:getInstance()
local string_format = string.format
local table_insert = table.insert
--@ bid 活动id 参照 holiday_role_data 表
--@ type 活动类型 参照 ActionType.Wonderful 定义
function ActionSmallAmountGiftPanel:ctor(bid, type)
    self.holiday_bid = bid
    self.type = type
    self:configUI()
    self:register_event()
end

function ActionSmallAmountGiftPanel:configUI( )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_small_amount_gift_panel"))
    self.root_wnd:setPosition(-40,-67)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container_size = self.main_container:getContentSize()

    local time_title =  self.main_container:getChildByName("time_title")
    time_title:setString(TI18N("剩余时间:"))
    

    self.time_val = self.main_container:getChildByName("time_val")
    local color  = self:colorChangeData(data_three_gear_gift_const[self.holiday_bid].time_color)
    time_title:setTextColor(color)
    time_title:disableEffect(cc.LabelEffect.OUTLINE)
    self.time_val:setTextColor(color)
    self.time_val:disableEffect(cc.LabelEffect.OUTLINE)


    self.goods_con = self.main_container:getChildByName("goods_con")

    -- 横幅图片
    local title_img = self.main_container:getChildByName("title_img")
    local title_str = "txt_cn_action_small_amount_gift_bg"
   
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo then
        --网络传过来的优先拿网络的
        if tab_vo.aim_title ~= nil and tab_vo.aim_title ~= "" then
            title_str = tab_vo.aim_title
        end
    end

    local res = PathTool.getPlistImgForDownLoad("bigbg/action",title_str)
    self.item_load = loadSpriteTextureFromCDN(title_img, res, ResourcesType.single, self.item_load)
    
    if self.item_scrollview == nil then
        local scroll_view_size = self.goods_con:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 236,                -- 单元的尺寸width
            item_height = 460,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.goods_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.item_scrollview:setClickEnabled(false)
    end

    controller:cs16603(self.holiday_bid)
end

function ActionSmallAmountGiftPanel:colorChangeData(value)
    local r,g,b,a = "ff", "ff", "ff", "ff"
    r = string.sub(value,1,2)
    g = string.sub(value,3,4)
    b = string.sub(value,5,6)
    a = string.sub(value,7,8)
    if r=="" then
        r = "ff"
    end
    if g=="" then
        g = "ff"
    end
    if b=="" then
        b = "ff"
    end
    if a=="" then
        a = "ff"
    end
    return cc.c4b(tonumber("0x"..r), tonumber("0x"..g), tonumber("0x"..b), tonumber("0x"..a))
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionSmallAmountGiftPanel:createNewCell(width, height)
   local cell = ActionSmallAmountGiftItem.new(self.holiday_bid, width, height)
   cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ActionSmallAmountGiftPanel:numberOfCells()
    if not self.limit_list then return 0 end
    return #self.limit_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ActionSmallAmountGiftPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.limit_list[index]
    if not cell_data then return end
    local time_desc = cell:setData(cell_data)
end

--设置倒计时
function ActionSmallAmountGiftPanel:setLessTime(less_time)
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
                    self.time_val:setString("00:00:00")
                else
                    self:setTimeFormatString(less_time)
                end
                
            end))))
    else
        self:setTimeFormatString(less_time)
    end
end

function ActionSmallAmountGiftPanel:setTimeFormatString(time)
    if time > 0 then
        self.time_val:setString(TimeTool.GetTimeForFunction(time))
    else
        self.time_val:setString("00:00:00")
    end
end



function ActionSmallAmountGiftPanel:register_event(  )
    if not self.limin_yuan_zhen_event  then
        self.limin_yuan_zhen_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            if not data then return end
            if data.bid == self.holiday_bid then
                self:setData(data)
            end
        end)
    end
end

function ActionSmallAmountGiftPanel:setData(data)
     -- 活动剩余时间
    local time = data.remain_sec or 0
    if time < 0 then
        time = 0
    end
    self:setLessTime(time)

    self.limit_list = data.aim_list or {}

    self.item_scrollview:reloadData()
end

function ActionSmallAmountGiftPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

function ActionSmallAmountGiftPanel:DeleteMe(  )
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.item_load1 then 
        self.item_load1:DeleteMe()
        self.item_load1 = nil
    end

    if self.limin_yuan_zhen_event then
        GlobalEvent:getInstance():UnBind(self.limin_yuan_zhen_event)
        self.limin_yuan_zhen_event = nil
    end

    doStopAllActions(self.time_val)
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
end

------------------------------------------
-- 子项
ActionSmallAmountGiftItem = class("ActionSmallAmountGiftItem", function()
    return ccui.Widget:create()
end)

function ActionSmallAmountGiftItem:ctor(action_id, width, height)
    self.action_id = action_id
    self.item_list = {}
    self:configUI(width, height)
    self:register_event()
end

function ActionSmallAmountGiftItem:configUI(width, height)
    self.size = cc.size(width, height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("action/action_small_amount_gift_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    self.root_wnd:setPosition((width - 214) * 0.5 , 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    

    self.title = main_container:getChildByName("title")
    local color = self:colorChangeData(data_three_gear_gift_const[self.action_id].gift_name_color)
    self.title:setTextColor(color)

    self.price_label = main_container:getChildByName("price_label")
    local color1 = self:colorChangeData(data_three_gear_gift_const[self.action_id].origin_buy_color)
    self.price_label:setTextColor(color1)

    self.limit_label = main_container:getChildByName("limit_label")
    local color2 = self:colorChangeData(data_three_gear_gift_const[self.action_id].limit_buy_color)
    self.limit_label:setTextColor(color2)

    --超值
    self.common_30016 = main_container:getChildByName("common_30016")
    local res =  PathTool.getResFrame("common", data_three_gear_gift_const[self.action_id].over_value_c_res)
    if self.common_30016 ~= nil then
        loadSpriteTexture(self.common_30016, res, LOADTEXT_TYPE_PLIST)
    end

    self.tips = main_container:getChildByName("tips")
    local color3 = self:colorChangeData(data_three_gear_gift_const[self.action_id].over_value_color)
    local color4 = self:colorChangeData(data_three_gear_gift_const[self.action_id].over_value_outline)
    self.tips:setTextColor(color3)
    self.tips:enableOutline(color4, 2)
    self.tips:setString(TI18N("超值"))

    self.goods_con = main_container:getChildByName("goods_con")
    self.goods_con_size = self.goods_con:getContentSize()
    self.item_scrollview = createScrollView(self.goods_con_size.width, self.goods_con_size.height, 0, 0, self.goods_con)

    self.comfirm_btn = main_container:getChildByName("comfirm_btn")
    self.comfirm_btn_lable = self.comfirm_btn:getChildByName("label")
end

function ActionSmallAmountGiftItem:register_event( )
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn() end,true, 1)
end

function ActionSmallAmountGiftItem:colorChangeData(value)
    local r,g,b,a = "ff", "ff", "ff", "ff"
    r = string.sub(value,1,2)
    g = string.sub(value,3,4)
    b = string.sub(value,5,6)
    a = string.sub(value,7,8)
    if r=="" then
        r = "ff"
    end
    if g=="" then
        g = "ff"
    end
    if b=="" then
        b = "ff"
    end
    if a=="" then
        a = "ff"
    end
    return cc.c4b(tonumber("0x"..r), tonumber("0x"..g), tonumber("0x"..b), tonumber("0x"..a))
end

function ActionSmallAmountGiftItem:onComfirmBtn()
    if not self.data then return end
    if self.buy_id and self.buy_id ~= 0 then
        local charge_config = Config.ChargeData.data_charge_data[self.buy_id]
        if charge_config then
            sdkOnPay(charge_config.val, nil, charge_config.id, charge_config.name, charge_config.name)
        end
    end
end

function ActionSmallAmountGiftItem:setActionRankCommonType(holiday_bid, type)
    self.holiday_bid = holiday_bid
    self.type = type
end

function ActionSmallAmountGiftItem:setData( data )
    self.data = data
    self.title:setString(data.aim_str)
    local price = 0
    local cur_price = 0
    local limit_count = 0
    local limit_max_count = 0
    local is_hight_value = false  --是否高价值

    self.buy_id = 0

    if data.aim_args then
        for i,v in ipairs(data.aim_args) do
            if v.aim_args_key == 26 then --原价
                price = v.aim_args_val
            elseif v.aim_args_key == 27 then --现价
                cur_price = v.aim_args_val
            elseif v.aim_args_key == 4 then --限购次数
                limit_max_count = v.aim_args_val
            elseif v.aim_args_key == 5 then --已购次数
                limit_count = v.aim_args_val
            elseif v.aim_args_key == 30 then --是否超值
                is_hight_value = (v.aim_args_val == 1)
            elseif v.aim_args_key == 33 then --充值id
                self.buy_id = v.aim_args_val
            end
        end
    end

    self.price_label:setString(TI18N("原价:")..price)
    self.comfirm_btn_lable:setString("¥ "..cur_price)
    self.limit_label:setString(string_format(TI18N("限购: %s/%s"), limit_count, limit_max_count))

    if limit_count >= limit_max_count then
        self.comfirm_btn_lable:disableEffect(cc.LabelEffect.OUTLINE)
        setChildUnEnabled(true, self.comfirm_btn)
        self.comfirm_btn:setTouchEnabled(false)
    else
        setChildUnEnabled(false, self.comfirm_btn)
        self.comfirm_btn_lable:enableOutline(Config.ColorData.data_color4[264], 2) 
        self.comfirm_btn:setTouchEnabled(true)
    end

    if is_hight_value then
        self.common_30016:setVisible(true)
        self.tips:setVisible(true)
    else
        self.common_30016:setVisible(false)
        self.tips:setVisible(false)
    end

    
    if data.item_list then
        doStopAllActions(self.goods_con)
        local count = #data.item_list
        local pos_list, total_height = self:getPosList(count)

        local max_height = math.max(self.goods_con_size.height, total_height)
        self.item_scrollview:setInnerContainerSize(cc.size(self.goods_con_size.width, max_height))
        
        if count >= 5 then
            self.item_scrollview:setTouchEnabled(true)
        else
            self.item_scrollview:setTouchEnabled(false)
        end
        -- if self.item_list then
        --     for i,item in ipairs(self.item_list) do
        --         item:setVisible(false)
        --     end
        -- end

        for i,v in ipairs(data.item_list) do
            if pos_list[i] then
                delayRun(self.goods_con, i / display.DEFAULT_FPS, function ()
                    local item =  self.item_list[i]
                    if not item then
                        item = BackPackItem.new(true, true)
                        item:setAnchorPoint(0.5, 0.5)
                        item:setScale(0.7)
                        self.item_scrollview:addChild(item)
                        self.item_list[i] = item
                    else
                        item:setVisible(true)
                    end
                    item:setPosition(pos_list[i])
                    item:setBaseData(v.bid, v.num, true)
                    item:setDefaultTip(true)
                end)
            end
        end
    end
end

function ActionSmallAmountGiftItem:getPosList(max_count)
    if not self.goods_con_size then return end
    local pos_list = {}
    local total_height = self.goods_con_size.height
    if max_count == 1 then
        table_insert(pos_list, cc.p(self.goods_con_size.width * 0.5, self.goods_con_size.height * 0.5))
    elseif max_count == 2 then
        table_insert(pos_list, cc.p(self.goods_con_size.width * 0.25, self.goods_con_size.height * 0.5))
        table_insert(pos_list, cc.p(self.goods_con_size.width * 0.75, self.goods_con_size.height * 0.5))
    elseif max_count == 3 then
        table_insert(pos_list, cc.p(self.goods_con_size.width * 0.5, self.goods_con_size.height * 0.75))
        table_insert(pos_list, cc.p(self.goods_con_size.width * 0.25, self.goods_con_size.height * 0.25))
        table_insert(pos_list, cc.p(self.goods_con_size.width * 0.75, self.goods_con_size.height * 0.25))
    elseif max_count == 4 then
        table_insert(pos_list, cc.p(self.goods_con_size.width * 0.25, self.goods_con_size.height * 0.75))
        table_insert(pos_list, cc.p(self.goods_con_size.width * 0.75, self.goods_con_size.height * 0.75))
        table_insert(pos_list, cc.p(self.goods_con_size.width * 0.25, self.goods_con_size.height * 0.25))
        table_insert(pos_list, cc.p(self.goods_con_size.width * 0.75, self.goods_con_size.height * 0.25))
    else
        local item_width = self.goods_con_size.width * 0.5
        local item_height = 90
        local math_ceil = math.ceil
        local row = math_ceil(max_count/2)
        total_height = item_height * row
        for i=1,max_count do
            local row = math_ceil(i/2)
            local col = (i-1)%2 
            local x = item_width * col + item_width * 0.5
            local y = total_height - (row-1) * item_height - item_height * 0.5
            table_insert(pos_list, cc.p(x, y))
        end

    end
    return pos_list, total_height
end

function ActionSmallAmountGiftItem:DeleteMe( )
    if self.item_list then
        for i,v in ipairs(self.item_list) do
            v:DeleteMe()
        end
    end
    doStopAllActions(self.goods_con)
    self.item_list = nil
    self:removeAllChildren()
    self:removeFromParent()
end