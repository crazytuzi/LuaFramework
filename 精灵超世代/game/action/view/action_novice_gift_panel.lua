---------------------------------
-- @Author: yuanqi@shiyue.com
-- @Editor: 
-- @date 2020/03/28
-- @description: 新手直购商城
---------------------------------
ActionNoviceGiftPanel =class("ActionNoviceGiftPanel",function(...)
    return ccui.Widget:create()
end)

function ActionNoviceGiftPanel:ctor(bid, type)
    self.holiday_bid = bid
    
    self.type = type
    self.action_type = type
    self.ctrl = ActionController:getInstance()
    self.cell_data_list = {}
    self:configUI()
    self:register_event()
end

function ActionNoviceGiftPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_novice_gift_panel"))
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_con = self.main_container:getChildByName("title_con")
    self.time_val = self.title_con:getChildByName("time_val")
    self.time_title = self.title_con:getChildByName("time_title")
    self.good_cons = self.main_container:getChildByName("charge_con")
    -- 战斗预览按钮
    self.battle_preview_btn = self.title_con:getChildByName("battle_preview_btn")
    self.preview_btn_label = self.battle_preview_btn:getChildByName("preview_btn_label")
    self.preview_btn_label:setString(TI18N("战斗预览"))
    
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)
    self.title_img = self.title_con:getChildByName("title_img")
    if self.holiday_bid ~= nil or self.holiday_bid ~= 0 and self.action_type ~= nil or self.action_type ~= 0 then
        local tab_vo = self.ctrl:getActionSubTabVo(self.holiday_bid)
        if tab_vo then
            if tab_vo.reward_title == "" then
                tab_vo.reward_title = "txt_cn_welfare_banner127"
            end
            local res = PathTool.getWelfareBannerRes(tab_vo.reward_title, false)
            if not self.item_load1 then
                self.item_load1 = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load1)
            end
        end
    end
    self:updateScrollviewList()
end

function ActionNoviceGiftPanel:updateScrollviewList()
    if self.child_scrollview == nil then
        local scroll_view_size = self.good_cons:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 15,                     -- y方向的间隔
            item_width = ActionNoviceGiftItem.Width,                -- 单元的尺寸width
            item_height = ActionNoviceGiftItem.Height,               -- 单元的尺寸height
            row = 0,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 4,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.child_scrollview = CommonScrollViewSingleLayout.new(self.good_cons, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.child_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.child_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.child_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.child_scrollview:setSwallowTouches(false)
    self.child_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionNoviceGiftPanel:createNewCell(width, height)
    local cell = ActionNoviceGiftItem.new()
	return cell
end

--获取数据数量
function ActionNoviceGiftPanel:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionNoviceGiftPanel:updateCellByIndex(cell, index)
    if not self.cell_data_list then return end
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ActionNoviceGiftPanel:createList(data)
    if not data then
        return
    end
    
    local item_list = {}
    self.everyday_data = nil
    for i, v in ipairs(data.aim_list) do
        --99是和后端 运营协议好的数字  99 为每日礼的
        if v.aim == 99 then 
            self.everyday_data = v
        else
            v.sort_index = 1
            if v.status == 1 then
                v.sort_index = 0
            elseif v.status == 2 then
                v.sort_index = 2
            end
            table.insert(item_list,v)    
        end
    end
    local sort_func = SortTools.tableLowerSorter({"sort_index", "aim"})
    table.sort(item_list, sort_func)
    self.cell_data_list = item_list
    self.child_scrollview:reloadData()
    self:setLessTime(data.remain_sec)

    -- --每日礼的红点
    -- if self.everyday_data and self.everyday_data.status ~= 2 then
    --     addRedPointToNodeByStatus(self.everyday_btn, true)
    -- else
    --     addRedPointToNodeByStatus(self.everyday_btn, false)
    -- end
end

--设置倒计时
function ActionNoviceGiftPanel:setLessTime(less_time)
    if tolua.isnull(self.time_val) then
        return
    end
    self.time_val:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_val:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    self.time_val:stopAllActions()
                else
                    self:setTimeFormatString(less_time)
                end
            end))))
    else
        self:setTimeFormatString(less_time)
    end
end

function ActionNoviceGiftPanel:setTimeFormatString(time)
    self.rest_time = time
    if time > 0 then
        self.time_val:setString(TimeTool.GetTimeFormatDayIIIIII(time))
    else
        self.time_val:setString("00:00:00")
    end
end

function ActionNoviceGiftPanel:register_event()
    if not self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function(data)
            if data.bid == self.holiday_bid then
                self:createList(data)
            end
        end)
    end
    registerButtonEventListener(self.battle_preview_btn, function()
        TimesummonController:getInstance():send23219(self.holiday_bid)
    end, true)
end

function ActionNoviceGiftPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true then
        ActionController:getInstance():cs16603(self.holiday_bid)
    end
end

function ActionNoviceGiftPanel:DeleteMe()
    if self.child_scrollview then
        self.child_scrollview:DeleteMe()
    end
    if self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end
    if self.item_load1 then
        self.item_load1:DeleteMe()
        self.item_load1 = nil
    end
end

ActionNoviceGiftItem = class("ActionNoviceGiftItem",function()
    return ccui.Widget:create()
end)

ActionNoviceGiftItem.Width = 680
ActionNoviceGiftItem.Height = 164

function ActionNoviceGiftItem:ctor()
    self.ctrl = ActionController:getInstance()
    self.touch_limit_buy = true
    self.good_list_data = {}
    self:configUI()
    self:register_event()
end

function ActionNoviceGiftItem:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_novice_gift_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)
    self:setContentSize(cc.size(ActionNoviceGiftItem.Width, ActionNoviceGiftItem.Height))

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_label = self.main_container:getChildByName("title_label")

    self.goods_con = self.main_container:getChildByName("goods_con")
    self.has_bg = self.main_container:getChildByName("has_bg")
    self.has_bg:setVisible(false)

    self.btn = createButton(self.main_container, TI18N('购买'), 580, 57, cc.size(168, 62), PathTool.getResFrame('common', 'common_1026'), 24)
    self.btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=22 shadow=0,0,2,#920eb3>0元</div>"))
    self.btn:setScale(0.8)
    -- self.btn:setPositionY(self.btn:getPositionY()-15)

    self:updateScrollviewList()
    self.limit_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(1,0.5), cc.p(660,140), nil, nil, nil)
    self.main_container:addChild(self.limit_label)

    -- self.old_price = createRichLabel(20, 175, cc.p(0.5,0.5), cc.p(590,95), nil, nil, nil)
    -- self.main_container:addChild(self.old_price)

    -- self.price_line = createScale9Sprite(PathTool.getResFrame("welfare", "welfare_40"), 50, 10, LOADTEXT_TYPE_PLIST, self.old_price)
    -- self.price_line:setAnchorPoint(cc.p(0.5, 0.5))
    -- self.price_line:setContentSize(cc.size(150, 2))
end

function ActionNoviceGiftItem:updateScrollviewList()
    if self.good_scrollview == nil then
        local scroll_view_size = self.goods_con:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 10,                     -- x方向的间隔
            start_y = 12,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = BackPackItem.Width*0.7,                -- 单元的尺寸width
            item_height = BackPackItem.Height*0.7,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 0,                         -- 列数，作用于垂直滚动类型
            delay = 4,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.good_scrollview = CommonScrollViewSingleLayout.new(self.goods_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.good_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.good_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.good_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.good_scrollview:setSwallowTouches(false)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionNoviceGiftItem:createNewCell(width, height)
    local cell = BackPackItem.new()
    cell:setDefaultTip()
    cell:setSwallowTouches(false)
    cell:setScale(0.7)
	return cell
end

--获取数据数量
function ActionNoviceGiftItem:numberOfCells()
    if not self.good_list_data then return 0 end
    return #self.good_list_data
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionNoviceGiftItem:updateCellByIndex(cell, index)
    if not self.good_list_data then return end
    cell.index = index
    local cell_data = self.good_list_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
    if cell_data and cell_data.id == 3 then
        cell:setDoubleIcon(true)
    else
        cell:setDoubleIcon(false)
    end
end

function ActionNoviceGiftItem:setData(data)
    self.data = data
    local item_list = {}

    local list = {}
    for k, v in ipairs(data.item_list) do
        local vo = deepCopy(Config.ItemData.data_get_data(v.bid))
        if vo then
            vo.quantity = v.num
            table.insert(list, vo)
        end
    end
    self.good_list_data = list
    self.good_scrollview:reloadData()

    local discount_list = keyfind('aim_args_key', 26, data.aim_args) or nil
    local new_price_list = keyfind('aim_args_key', 27, data.aim_args) or nil

    local current_price = 0 
    if new_price_list then
        -- local str = string.format(TI18N("原价: %d元"), discount_list.aim_args_val or 0)
        -- self.old_price:setString(str)
        local price_str = string.format("<div fontColor=#ffffff fontsize=22 shadow=0,-2,2,#920eb3>%s %s</div>", GetSymbolByType(), new_price_list.aim_args_val or 0)
        self.btn:setRichText(price_str)
        current_price = new_price_list.aim_args_val
    end

    self.title_label:setString(data.aim_str)

    local _type = self:getValByKey(data.aim_args,7) or 0
    local max_num = self:getValByKey(data.aim_args,2) or 0
    local cur_num = self:getValByKey(data.aim_args,6) or 0
    local str = ""
    if _type == 1 then --周限购
        if max_num and max_num ~= 0 and cur_num  then 
            str = string.format(TI18N("<div>每周限购%s个:  (</div><div fontcolor=#0cff01>%s<div>/%s)"),max_num,cur_num,max_num)
        end
    elseif _type == 2 then --累计限购
        if max_num and max_num ~= 0 and cur_num  then 
            str = string.format(TI18N("<div>总限购%s个:  (</div><div fontcolor=#0cff01>%s<div>/%s)"), max_num,cur_num,max_num)
        end
    elseif _type == 3 then --活动周期限购
        if max_num and max_num ~= 0 and cur_num  then 
            str = string.format(TI18N("<div>限购:  (</div><div fontcolor=#0cff01>%s<div>/%s)"), cur_num,max_num)
        end
    end
    self.limit_label:setString(str)

    if data.sort_index == 2 then
        self.btn:setGrayAndUnClick(true, false)
        local price_str = string.format("<div fontColor=#ffffff fontsize=22 shadow=0,-2,2,#920eb3>%s %s</div>", GetSymbolByType(), current_price or 0)
        self.btn:setRichText(price_str)
    else
        self.btn:setGrayAndUnClick(false, true)
        local price_str = string.format("<div fontColor=#ffffff fontsize=22 shadow=0,-2,2,#920eb3>%s %s</div>", GetSymbolByType(), current_price or 0)
        self.btn:setRichText(price_str)
    end
end

function ActionNoviceGiftItem:getValByKey(aim_args, key)
    if not aim_args then
        return 0
    end
    local val = 0
    for i, v in ipairs(aim_args) do
        if v.aim_args_key == key then
            val = v.aim_args_val
        end
    end
    return val
end

function ActionNoviceGiftItem:register_event()
    self.btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if self.data then
                if self.data.status == 0 and self.touch_limit_buy == true then
                    self.touch_limit_buy = nil
                    local new_price = keyfind('aim_args_key', 27, self.data.aim_args) or {}
                    sdkOnPay(new_price.aim_args_val, 1, self.data.aim, self.data.aim_str)
                    if self.send_limit_buy_ticket == nil then
                        self.send_limit_buy_ticket = GlobalTimeTicket:getInstance():add(function()
                            self.touch_limit_buy = true
                            if self.send_limit_buy_ticket ~= nil then
                                GlobalTimeTicket:getInstance():remove(self.send_limit_buy_ticket)
                                self.send_limit_buy_ticket = nil
                            end
                        end,2)
                    end
                elseif self.data.status == 2 then
                    message(TI18N("已经购买完了"))
                end
            end
        end
    end)
end

function ActionNoviceGiftItem:DeleteMe()
    if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end
    if self.send_limit_buy_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.send_limit_buy_ticket)
        self.send_limit_buy_ticket = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end