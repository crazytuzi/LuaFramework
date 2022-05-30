---------------------------------
-- @Author: yuanqi@shiyue.com
-- @Editor:
-- @description: 周活动商城
---------------------------------
WeeklyShopPanel =class("WeeklyShopPanel",function(...)
    return ccui.Widget:create()
end)

function WeeklyShopPanel:ctor(bid)
    self.ctrl = WeeklyActivitiesController:getInstance()
    self.model = self.ctrl:getModel()
    local cfg = Config.WeekActData.data_info[bid]
    self.activity_id = cfg.action_type
    self.icon = cfg.ico
    self.cell_data_list = {}
    self:configUI()
    self:register_event()
end

function WeeklyShopPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_novice_gift_panel"))
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_con = self.main_container:getChildByName("title_con")
    self.time_val = self.title_con:getChildByName("time_val")
    self.time_val:setPosition(510, 20)
    self.time_title = self.title_con:getChildByName("time_title")
    self.time_title:setPosition(500, 20)
    self.good_cons = self.main_container:getChildByName("charge_con")
    -- 战斗预览按钮
    self.battle_preview_btn = self.title_con:getChildByName("battle_preview_btn")
    self.battle_preview_btn:setVisible(false)
    --self.preview_btn_label = self.battle_preview_btn:getChildByName("preview_btn_label")
    --self.preview_btn_label:setString(TI18N("战斗预览"))

    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.title_img = self.title_con:getChildByName("title_img")
    local res = PathTool.getWelfareBannerRes("txt_cn_welfare_banner"..self.icon, false)
    if not self.item_load1 then
        self.item_load1 = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load1)
    end

    self:updateScrollviewList()
end

function WeeklyShopPanel:updateScrollviewList()
    if self.child_scrollview == nil then
        local scroll_view_size = self.good_cons:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 15,                     -- y方向的间隔
            item_width = WeeklyShopGiftItem.Width,                -- 单元的尺寸width
            item_height = WeeklyShopGiftItem.Height,               -- 单元的尺寸height
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
function WeeklyShopPanel:createNewCell(width, height)
    local cell = WeeklyShopGiftItem.new()
    return cell
end

--获取数据数量
function WeeklyShopPanel:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function WeeklyShopPanel:updateCellByIndex(cell, index)
    if not self.cell_data_list then return end
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function WeeklyShopPanel:createList(data)
    if not data then
        return
    end
    dump(data)
    local item_list = data.info_list
    --排序规则
    table.sort(item_list, function(a,b)
        local hasTimeA =  a.limit - a.num
        local hasTimeB =  b.limit - b.num
        if hasTimeA > 0 and hasTimeB <= 0 then
            return true
        elseif hasTimeB > 0 and hasTimeA <= 0 then
            return false
        else
            return a.uId < b.uId
        end
    end)

    self.cell_data_list = item_list
    self.child_scrollview:reloadData()

    local end_time = WeeklyActivitiesController:getInstance():getModel():getWeeklyActivityData().end_time
    local time = end_time-GameNet:getInstance():getTime()
    self:setLessTime(time)
end

--设置倒计时
function WeeklyShopPanel:setLessTime(less_time)
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

function WeeklyShopPanel:setTimeFormatString(time)
    self.rest_time = time
    if time > 0 then
        self.time_val:setString(TimeTool.GetTimeFormatDayIIIIII(time))
    else
        self.time_val:setString(TI18N("已结束"))
    end
end

function WeeklyShopPanel:register_event()
    if not self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(WeeklyActivitiesEvent.UPDATE_WEEK_SHOP_DATA,function(data)
            self:createList(data)
        end)
    end
    self.ctrl:send_29203()
end

function WeeklyShopPanel:DeleteMe()
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

WeeklyShopGiftItem = class("WeeklyShopGiftItem",function()
    return ccui.Widget:create()
end)

WeeklyShopGiftItem.Width = 680
WeeklyShopGiftItem.Height = 134

function WeeklyShopGiftItem:ctor()
    self.ctrl = ActionController:getInstance()
    self.touch_limit_buy = true
    self.good_list_data = {}
    self:configUI()
    self:register_event()
end

function WeeklyShopGiftItem:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/weekly_shop_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)
    self:setContentSize(cc.size(WeeklyShopGiftItem.Width, WeeklyShopGiftItem.Height))

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.goods_con = self.main_container:getChildByName("goods_con")
    self.has_bg = self.main_container:getChildByName("has_bg")
    self.has_bg:setVisible(false)

    self.btn = createButton(self.main_container, TI18N('购买'), 580, 57, cc.size(168, 62), PathTool.getResFrame('common', 'common_1026'), 24)
    self.btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=22 shadow=0,0,2,#920eb3>0元</div>"))
    self.btn:setScale(0.8)

    self:updateScrollviewList()
    self.limit_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(1,0.5), cc.p(660,100), nil, nil, nil)
    self.main_container:addChild(self.limit_label)
end

function WeeklyShopGiftItem:updateScrollviewList()
    if self.good_scrollview == nil then
        local scroll_view_size = self.goods_con:getContentSize()
        local setting = {
            start_x = 10,                     -- 第一个单元的X起点
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
function WeeklyShopGiftItem:createNewCell(width, height)
    local cell = BackPackItem.new()
    cell:setDefaultTip()
    cell:setSwallowTouches(false)
    cell:setScale(0.7)
    return cell
end

--获取数据数量
function WeeklyShopGiftItem:numberOfCells()
    if not self.good_list_data then return 0 end
    return #self.good_list_data
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function WeeklyShopGiftItem:updateCellByIndex(cell, index)
    if not self.good_list_data then return end
    cell.index = index
    local cell_data = self.good_list_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function WeeklyShopGiftItem:setData(data)
    if not data then
        return
    end
    self.data = data
    --道具列表
    local list = {}
    for k, v in ipairs(data.item_list) do
        local vo = deepCopy(Config.ItemData.data_get_data(v.item_id))
        if vo then
            vo.quantity = v.num
            table.insert(list, vo)
        end
    end
    self.good_list_data = list
    self.good_scrollview:reloadData()
    --剩余
    local str = string.format(TI18N("<div>限购:  (</div><div fontcolor=#0cff01>%s<div>/%s)"), data.num,data.limit)
    self.limit_label:setString(str)
    --标价
    local price_str = ""
    --购买按钮
    if data.num < data.limit then
        if data.is_free ~= 2 then
            price_str = string.format("<div fontColor=#ffffff fontsize=22 shadow=0,-2,2,#920eb3>%s %s</div>", GetSymbolByType(), data.price or 0)
        else
            price_str = string.format("<img src=%s visible=true scale=0.40 /><div fontColor=#ffffff fontsize=22 shadow=0,-2,2,#920eb3> %s</div>", PathTool.getItemRes(3), data.price or 0)
        end
        self.btn:setGrayAndUnClick(false)
    else
        if data.is_free ~= 2 then
            price_str = string.format("<div fontColor=#ffffff fontsize=22>%s %s</div>", GetSymbolByType(), data.price or 0)
        else
            price_str = string.format("<img src=%s visible=true scale=0.40 /><div fontColor=#ffffff fontsize=22> %s</div>", PathTool.getItemRes(3), data.price or 0)
        end
        self.btn:setGrayAndUnClick(true)
    end
    self.btn:setRichText(price_str)
end

function WeeklyShopGiftItem:register_event()
    self.btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if self.data then
                if self.data.num < self.data.limit then
                    if self.data.is_free == 0 then
                        sdkOnPay(self.data.price, 1, self.data.product_id, self.data.name)
                    else
                        WeeklyActivitiesController:getInstance():send_29204(self.data.uId)
                    end
                else
                    message(TI18N("已经购买完了"))
                end
            end
        end
    end)
end

function WeeklyShopGiftItem:DeleteMe()
    if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end