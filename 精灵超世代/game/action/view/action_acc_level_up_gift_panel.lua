-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      升级有礼 -->  需求_任思仪.xlsx
-- <br/>Create: 2018年12月11日
ActionAccLevelUpGiftPanel = class("ActionAccLevelUpGiftPanel", function()
    return ccui.Widget:create()
end)


local table_sort = table.sort
local string_format = string.format
--@ bid 活动id 参照 holiday_role_data 表
--@ type 活动类型 参照 ActionType.Wonderful 定义
--@ container ActionAccLevelUpGiftPanel 的父节点
function ActionAccLevelUpGiftPanel:ctor(bid, type)
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

function ActionAccLevelUpGiftPanel:configUI(  )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_acc_level_up_gift_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.title_con = self.main_container:getChildByName("title_con")
    self.title_img = self.title_con:getChildByName("title_img")
    local tab_vo = self.ctrl:getActionSubTabVo(self.holiday_bid)
    if tab_vo then
        if tab_vo.aim_title == nil or tab_vo.aim_title == "" then
            tab_vo.aim_title = "txt_cn_action_acc_level_up_gift"
        end
        local res = PathTool.getTargetRes("bigbg/action",tab_vo.aim_title,false,false)
        if not self.item_load1 then
            self.item_load1 = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load1)
        end
    end

    self.quick_fight_btn = self.title_con:getChildByName("quick_fight_btn")
    self.quick_fight_img = self.quick_fight_btn:getChildByName("btn_img")
    local res = PathTool.getItemRes(30053)
    loadSpriteTexture(self.quick_fight_img, res, LOADTEXT_TYPE)
    self.quick_fight_label = self.quick_fight_btn:getChildByName("btn_label")
    self.quick_fight_label:setString(TI18N("快速作战特权"))
    self.quick_fight_lock = self.quick_fight_btn:getChildByName("lock_label")
    self.quick_fight_lock:setString(TI18N("点击激活"))
    self:updateQuickFightBtn()

    self.charge_con = self.main_container:getChildByName("charge_con")
    local time_title = self.title_con:getChildByName("time_title")
    -- local dec =  self.title_con:getChildByName("dec")
    -- dec:setString(TI18N("活动期间，玩家可领取已达档次奖励\n奖励限时限量，先到先得"))
    local time_node = self.title_con:getChildByName("time_node")
    self.time_val = createRichLabel(20, Config.ColorData.data_color4[1], cc.p(1, 0.5), cc.p(0,0),nil,nil,1000)
    time_node:addChild(self.time_val)
    self:setLessTime(tab_vo.remain_sec)
end

function ActionAccLevelUpGiftPanel:updateQuickFightBtn()
    local privilege_data = VipController:getInstance():getModel():getPrivilegeDataById(102)
    if privilege_data and privilege_data.expire_time and privilege_data.status == 1 then --已激活
        setChildUnEnabled(false, self.quick_fight_img)
        self.quick_fight_lock:setVisible(false)
    else
        setChildUnEnabled(true, self.quick_fight_img)
        self.quick_fight_lock:setVisible(true)
    end
end

function ActionAccLevelUpGiftPanel:register_event(  )
    registerButtonEventListener(self.quick_fight_btn, function()
        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.PRIVILEGE)
    end,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    if not self.update_action_even_event  then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_LEVEL_UP_GIFT,function (data)
            if not data then return end
            self:setData(data)
        end)
    end

    if self.update_privilege_event == nil then
        self.update_privilege_event = GlobalEvent:getInstance():Bind(VipEvent.PRIVILEGE_INFO, function()
            self:updateQuickFightBtn()
        end)
    end
end

function ActionAccLevelUpGiftPanel:setData(data)
    local is_redpoint = false
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
        --status 0:不能领取, 1:可领取, 2:已领取
        if self.dic_cell_datas[v.id] then
            if v.status == 1 and  v.num >= self.dic_cell_datas[v.id].config.num then
                --已领数量已经满了 也算不能领取
                v.status = 4        
            end
            
            if v.status == 0 then --不可领取
                self.dic_cell_datas[v.id].order = 2
            elseif v.status == 4 then --可领取但是已经没有得领取了
                self.dic_cell_datas[v.id].order = 3
                v.status = 0
            elseif v.status == 2 then --已领取
                self.dic_cell_datas[v.id].order = 4
            else --可领取
                self.dic_cell_datas[v.id].order = 1
            end
            self.dic_cell_datas[v.id].status = v.status --状态
            --判定是否有红点
            if not is_redpoint and v.status == 1 then
                is_redpoint = true
            end
            self.dic_cell_datas[v.id].num = v.num --全服数量
        end
    end
    local sort_func = SortTools.tableLowerSorter({"order","id"})
    table_sort(self.cell_data_list, sort_func )
    
    self.ctrl:setHolidayStatus(self.holiday_bid, is_redpoint)
    self:updateScrollviewList()
end

function ActionAccLevelUpGiftPanel:updateScrollviewList()
    if self.common_scrollview == nil then
        local scroll_view_size = self.charge_con:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 15,                     -- y方向的间隔
            item_width = 680,                -- 单元的尺寸width
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
function ActionAccLevelUpGiftPanel:createNewCell(width, height)
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
    cell.btn_label = cell.btn_go:getChildByName("label")
    cell.btn_label:setString(TI18N("领取"))
    -- local btn_label = cell.btn_go:getTitleRenderer()
    --if self.btn_label ~= nil then
    --    self.btn_label:enableOutline(Config.ColorData.data_color4[277], 2)
    --end
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
    --回收用
    cell.DeleteMe = function() 
        doStopAllActions(cell.item_scrollview)
        if cell.item_list ~= nil then
            for k,v in pairs(cell.item_list) do
                v:DeleteMe()
            end
            cell.item_list = nil
        end
    end
    return cell
end
--获取数据数量
function ActionAccLevelUpGiftPanel:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionAccLevelUpGiftPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    local config = cell_data.config

    --角色等级
    local role_vo = RoleController:getInstance():getRoleVo()
    local lev = role_vo and role_vo.lev or 0
    local levStr 
    if lev >= config.lev then 
        -- cell.title:setTextColor(cc.c4b(0x2c,0x7d,0x08,0xff))
        levStr = string_format(TI18N("达到%s级 (%s/%s)"), config.lev, config.lev, config.lev)
    else
        -- cell.title:setTextColor(cc.c4b(0x64,0x32,0x23,0xff))
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
    local scale = 0.8
    local offsetX = 10
    local item_count = #config.reward
    local item_width = BackPackItem.Width * scale

    local total_width =  (item_width + offsetX) * item_count
    local max_width = math.max(cell.item_scrollview_size.width, total_width)
    cell.item_scrollview:setInnerContainerSize(cc.size(max_width, cell.item_scrollview_size.height))
    if item_count <= 4 then
        --小于等于4 个不给移动
        cell.item_scrollview:setTouchEnabled(false)
    end
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
        --cell.btn_label:disableEffect(cc.LabelEffect.OUTLINE)
        cell.btn_go:setTouchEnabled(false)
    elseif cell_data.status == 1 then
        --可以领取
        cell.btn_go:setVisible(true)
        cell.pic_has:setVisible(false)
        setChildUnEnabled(false, cell.btn_go)
        --cell.btn_label:enableOutline(Config.ColorData.data_color4[277], 2)
        cell.btn_go:setTouchEnabled(true)
    else
        --已领取
        cell.btn_go:setVisible(false)
        cell.pic_has:setVisible(true)    
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function ActionAccLevelUpGiftPanel:setCellTouched(cell)
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
function ActionAccLevelUpGiftPanel:setLessTime(less_time)
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
function ActionAccLevelUpGiftPanel:setTimeFormatString( time )
    if time > 0 then
        str = string.format(TI18N("剩余时间: <div fontcolor=#14ff32>%s</div>"),TimeTool.GetTimeFormatDayIIIIII(time))
        self.time_val:setString(str)
    else
        self.time_val:setString("")
    end
end


function ActionAccLevelUpGiftPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
    if bool == true then 
        self.ctrl:send21200()
    end
end

function ActionAccLevelUpGiftPanel:DeleteMe()
    if self.item_load1 then 
        self.item_load1:DeleteMe()
        self.item_load1 = nil
    end

    if self.common_scrollview then 
        self.common_scrollview:DeleteMe()
        self.common_scrollview = nil
    end
    
    if self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end

    if self.update_privilege_event then
        GlobalEvent:getInstance():UnBind(self.update_privilege_event)
        self.update_privilege_event = nil
    end
    doStopAllActions(self.time_val) 
end
 