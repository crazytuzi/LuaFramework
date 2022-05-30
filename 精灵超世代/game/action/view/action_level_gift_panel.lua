-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      限时等级礼包 -->限时礼包-等级礼包（限时直购）需求_任思仪.xlsx
-- <br/>Create: 2018年12月11日
ActionLevelGiftPanel = class("ActionLevelGiftPanel", function()
    return ccui.Widget:create()
end)


local table_sort = table.sort
local string_format = string.format
--@ bid 活动id 参照 holiday_role_data 表
--@ type 活动类型 参照 ActionType.Wonderful 定义
--@ container ActionLevelGiftPanel 的父节点
function ActionLevelGiftPanel:ctor(bid, type)
    self.parent = container
    self.holiday_bid = bid
    self.type = type
    self.ctrl = ActionController:getInstance()
    self.role_vo = RoleController:getInstance():getRoleVo()
    self:configUI()
    self:register_event()

    --列表数据
    self.cell_data_list = {}
    --self.dic_cell_datas[id] = 数据
    self.dic_cell_datas = {}
end

function ActionLevelGiftPanel:configUI(  )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_level_gift_panel"))
    self.root_wnd:setPosition(-40,-66)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.title_img = self.main_container:getChildByName("title_img")
    local tab_vo = self.ctrl:getActionSubTabVo(self.holiday_bid)
    if tab_vo then
        if tab_vo.aim_title == nil or tab_vo.aim_title == "" then
            tab_vo.aim_title = "txt_cn_action_level_gift"
        end
        local res = PathTool.getTargetRes("bigbg/action/levelgift",tab_vo.aim_title,false,false)
        if not self.item_load1 then
            self.item_load1 = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load1)
        end
    end


    self.level_img = self.main_container:getChildByName("level_img")
    if not self.item_load then
        local level = 18
        local res = PathTool.getTargetRes("bigbg/action/levelgift", level, false, false)
        self.item_load = loadSpriteTextureFromCDN(self.level_img, res, ResourcesType.single, self.item_load)
    end

    self.scrollview_con = self.main_container:getChildByName("scrollview_con")

    local time_node = self.main_container:getChildByName("time_node")
    self.time_val = createRichLabel(24, Config.ColorData.data_color4[1], cc.p(0, 0.5), cc.p(0,0),nil,nil,1000)
    time_node:addChild(self.time_val)
    self:setLessTime(tab_vo.remain_sec)

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_label = self.comfirm_btn:getChildByName("label")
end

function ActionLevelGiftPanel:register_event(  )
    -- if not self.update_action_even_event  then
    --     self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_LEVEL_UP_GIFT,function (data)
    --         if not data then return end
    --         self:setData(data)
    --     end)
    -- end

    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn() end ,true, 2)
end

--购买
function ActionLevelGiftPanel:onComfirmBtn()
    -- body
end

function ActionLevelGiftPanel:setData(data)

    --写到到数据
    for i,v in ipairs(data.gifts) do
        if self.dic_cell_datas[v.id] == nil then
            local config = Config.LevGiftData.data_level_welfare_fun(v.id)
            if config then
                local data = {}
                data.id = v.id
                data.config = config
                table.insert(self.cell_data_list, data)
                self.dic_cell_datas[v.id] = data 
            end
        end
        if self.dic_cell_datas[v.id] then
            if v.num >= self.dic_cell_datas[v.id].config.num then
                --已领数量已经满了
                v.status = 0        
            end
            self.dic_cell_datas[v.id].status = v.status --状态
            if v.status == 0 then --不可领取
                self.dic_cell_datas[v.id].order = 3                
            else
                self.dic_cell_datas[v.id].order = v.status
            end
            self.dic_cell_datas[v.id].num = v.num --全服数量

        end
    end
    local sort_func = SortTools.tableLowerSorter({"order","id"})
    table_sort(self.cell_data_list, sort_func )
    
    self:updateScrollviewList()
end

function ActionLevelGiftPanel:updateScrollviewList()
    if self.common_scrollview == nil then
        local scroll_view_size = self.scrollview_con:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 688,                -- 单元的尺寸width
            item_height = 150,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 4,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.common_scrollview = CommonScrollViewSingleLayout.new(self.charge_con, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.common_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.common_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.common_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.common_scrollview:reloadData()
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionLevelGiftPanel:createNewCell(width, height)
    local cell = ccui.Widget:create()
    cell.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_acc_level_up_gift_item"))
    cell:addChild(cell.root_wnd)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0,0)
    cell:setContentSize(cc.size(width, height))
    cell.main_container = cell.root_wnd:getChildByName("main_container")
    cell.title = cell.main_container:getChildByName("title")
    cell.portion_count = cell.main_container:getChildByName("portion_count")

    --按钮
    cell.btn_go = cell.main_container:getChildByName("btn_go")
    cell.btn_go:setTitleText(TI18N("领取"))
    local btn_label = cell.btn_go:getTitleRenderer()
    if btn_label ~= nil then
        btn_label:enableOutline(Config.ColorData.data_color4[277], 2)
    end
    cell.pic_has = cell.main_container:getChildByName("pic_has")
    -- cell.pic_has:setVisible(false)

    --列表
    cell.item_scrollview = cell.main_container:getChildByName("item_scrollview")
    cell.item_scrollview:setScrollBarEnabled(false)
    cell.item_scrollview:setSwallowTouches(false)
    cell.item_scrollview_size = cell.item_scrollview:getContentSize()
    registerButtonEventListener(cell.btn_go, function() self:setCellTouched(cell) end ,false, 2)

    --道具列表
    cell.item_list = {}
    return cell
end
--获取数据数量
function ActionLevelGiftPanel:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionLevelGiftPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    local config = cell_data.config

    --角色等级
    local role_vo = RoleController:getInstance():getRoleVo()
    local lev = role_vo and role_vo.lev or 0
    local levStr 
    if lev >= config.lev then 
        cell.title:setColor(cc.c4b(0x2c,0x7d,0x08,0xff))
        levStr = string_format(TI18N("达到%s级 (%s/%s)"), config.lev, config.lev, config.lev)
    else
        cell.title:setColor(cc.c3b(0xd6,0x00,0x00))
        levStr = string_format(TI18N("达到%s级 (%s/%s)"), config.lev, lev, config.lev)
    end 
    cell.title:setString(levStr)

    --领取数量
    local count = config.num - cell_data.num
    if count < 0 then
        count = 0
    end
    local str = string_format(TI18N("还剩%s份"), count)
    cell.portion_count:setString(str)

    --物品
    if cell.item_list then
        for i,v in ipairs(cell.item_list) do
            v:setVisible(false)
        end
    end
    --道具列表
    local scale = 0.75
    local offsetX = 10
    local item_count = #config.reward
    local item_width = BackPackItem.Width * scale

    local total_width =  (item_width + offsetX) * item_count
    local max_width = math.max(cell.item_scrollview_size.width, total_width)
    cell.item_scrollview:setInnerContainerSize(cc.size(max_width, cell.item_scrollview_size.height))

    cell.start_x = offsetX * 0.5
    cell.item_scrollview:stopAllActions()
    local item = nil
    local size = #cell.item_list 
    for i, v in ipairs(config.reward) do
        item = cell.item_list[i]
        if item then
            item:setVisible(true)
            local _x = cell.start_x + (i - 1) * (item_width + offsetX) + 8
            item:setPosition(_x, cell.item_scrollview_size.height * 0.5)
            local data = {bid = v[1], num = v[2]}
            item:setBaseData(v[1], v[2], true)
            item:setDefaultTip()
        else
            local dealey = i - size
            if dealey <= 0 then
                dealey = 1
            end
            delayRun(cell.item_scrollview,dealey / display.DEFAULT_FPS,function ()
                if not cell.item_list[i] then
                    item = BackPackItem.new(true, true)
                    item:setAnchorPoint(0, 0.5)
                    item:setScale(scale)
                    item:setSwallowTouches(false)
                    cell.item_scrollview:addChild(item)
                    cell.item_list[i] = item
                    local _x = cell.start_x + (i - 1) * (item_width + offsetX) + 8
                    item:setPosition(_x, cell.item_scrollview_size.height * 0.5)
                    local data = {bid = v[1], num = v[2]}
                    item:setBaseData(v[1], v[2], true)
                    item:setDefaultTip()
                end
            end)
        end
    end

    --按钮
    if cell_data.status == 0 then
        --不可领取
        cell.btn_go:setVisible(true)
        cell.pic_has:setVisible(false)
        setChildUnEnabled(true, cell.btn_go)
        cell.btn_go:setTouchEnabled(false)
    elseif cell_data.status == 1 then
        --可以领取
        cell.btn_go:setVisible(true)
        cell.pic_has:setVisible(false)
        setChildUnEnabled(false, cell.btn_go)
        cell.btn_go:setTouchEnabled(true)
    else
        --已领取
        cell.btn_go:setVisible(false)
        cell.pic_has:setVisible(true)    
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function ActionLevelGiftPanel:setCellTouched(cell)
    if not cell.index then return end
    local cell_data = self.cell_data_list[cell.index]
    if not cell_data then return end
     --按钮
    if cell_data.status == 1 then
        --可领取
        self.ctrl:send21201(cell_data.id)    
    end

end

--设置倒计时
function ActionLevelGiftPanel:setLessTime(less_time)
    if tolua.isnull(self.time_val) then
        return
    end
    local less_time =  less_time or 0
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
function ActionLevelGiftPanel:setTimeFormatString( time )
    if time > 0 then
        str = string.format(TI18N("剩余时间: <div fontcolor=#14ff32>%s</div>"),TimeTool.GetTimeFormatDayIIIIII(time))
        self.time_val:setString(str)
    else
        self.time_val:setString("")
    end
end


function ActionLevelGiftPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
    if bool == true then 
        -- self.ctrl:send21200()
    end
end

function ActionLevelGiftPanel:DeleteMe()
    if self.item_load1 then 
        self.item_load1:DeleteMe()
        self.item_load1 = nil
    end
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    if self.item_scrollview then 
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    if self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end

    doStopAllActions(self.time_val) 
end
