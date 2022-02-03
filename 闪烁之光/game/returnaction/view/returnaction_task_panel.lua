--******** 文件说明 ********
-- @Author:      xhj 
-- @description: 回归任务
-- @DateTime:    2019-12-13 10:01:02
-- *******************************
local _table_insert = table.insert
ReturnActionTaskPanel = class("ReturnActionTaskPanel", function()
    return ccui.Widget:create()
end)
local controller = ReturnActionController:getInstance()
local model = controller:getModel()
local const_data = Config.HolidayReturnNewData.data_constant
local string_format = string.format
function ReturnActionTaskPanel:ctor(bid)
	self.holiday_bid = bid
	self:configUI()
    self:register_event()
    self.task_items = {}
    self.dic_task_list = {}
    self.dic_limit_list = {}
    --scrollview列表
    self.limit_list = {}
    -- 时间的label
    self.time_desc_list = {}
end

function ReturnActionTaskPanel:configUI( )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("returnaction/returnaction_task_panel"))
	self.root_wnd:setPosition(-40,-66)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    local main_container = self.root_wnd:getChildByName("main_container")
    local title_con = main_container:getChildByName("title_con")
    title_con:getChildByName("label_time_key"):setString(TI18N("剩余时间:"))
    self.label_time = title_con:getChildByName("label_time")
    self.label_time:setString("")

    self.desc_txt = title_con:getChildByName("desc_txt")
    self.desc_txt:setPosition(cc.p(56,56))
    self.icon = title_con:getChildByName("icon")
    self.icon_count = title_con:getChildByName("icon_count")
    self.icon_count:setString("")
    self.banner_spr = title_con:getChildByName("title_img")
    local btn_rule = title_con:getChildByName("btn_rule")
    btn_rule:setVisible(false)

    local goods_item = main_container:getChildByName("goods_item")
    local scroll_view_size = goods_item:getContentSize()
    local setting = {
        start_x = 4,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 3,                   -- y方向的间隔
        item_width = 694,               -- 单元的尺寸width
        item_height = 141,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(goods_item, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(true)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createTeskCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfTeskCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateTeskCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    self:setLoadBanner()
    controller:sender27905()
end
function ReturnActionTaskPanel:createTeskCell()
	local cell = ReturnActionTaskItem.new()
    return cell
end
function ReturnActionTaskPanel:numberOfTeskCells()
	if not self.task_items then return 0 end
    return #self.task_items
end
function ReturnActionTaskPanel:updateTeskCellByIndex(cell, index)
	if not self.task_items then return end
    local cell_data = self.task_items[index]
    if not cell_data then return end
    
    local time_desc = cell:setData(cell_data)
    self.time_desc_list[index] = time_desc
    self:updateTimeByIndex(index, time_desc)
end

function ReturnActionTaskPanel:setLoadBanner()
    local holiday_data = model:getReturnActionData(self.holiday_bid)
    local str = "txt_cn_returnaction2"
    local title = ""
    if holiday_data then
        str = holiday_data.panel_res
        title = holiday_data.tips
    end

    self.desc_txt:setString(title)
	local res = PathTool.getReturnActionRes(str)
	if not self.load_banner then
		self.load_banner = loadSpriteTextureFromCDN(self.banner_spr, res, ResourcesType.single, self.load_banner)
	end
end

function ReturnActionTaskPanel:register_event()
	if not self.task_event then
        self.task_event = GlobalEvent:getInstance():Bind(ReturnActionEvent.Task_Event,function(data)
            if data and self.label_time then
                setCountDownTime(self.label_time,data.endtime - GameNet:getInstance():getTime())    
            end
            
            local quest_list = model:getActionTaskQuestList()
            self:setConfigData(quest_list)
        end)
    end
    if not self.task_updata_event then
        self.task_updata_event = GlobalEvent:getInstance():Bind(ReturnActionEvent.Task_Updata_Event,function()
            local quest_list = model:getActionTaskQuestList()
            self:setConfigData(quest_list)
        end)
    end

    if not self.limin_task_event  then
        self.limin_task_event = GlobalEvent:getInstance():Bind(ReturnActionEvent.Limin_Task_Event,function (data)
            if not data then return end
            local period = model:getActionPeriod()
            local key = getNorKey(period, data.id)
            local config = Config.HolidayReturnNewData.data_task_fun(key)
            if config and self.dic_limit_list[config.f_id] then
                self.dic_limit_list[config.f_id].finish = TaskConst.task_status.completed
                self.dic_limit_list[config.f_id].sort = TaskConst.task_status.completed

                local config_list = Config.HolidayReturnNewData.data_lanterm_adventure_task_list[period][config.f_id]
                --如果有下一个任务档次
                if config_list[config.s_id + 1] then
                    local key = getNorKey(period, config_list[config.s_id + 1].id)
                    local new_config = Config.HolidayReturnNewData.data_task_fun(key)
                    if new_config and self.dic_task_list[new_config.id] then
                        self:setConfigData({self.dic_task_list[new_config.id]})
                    else   
                        self:sortItemList()
                    end
                else
                    self:sortItemList()
                end
            end
        end)
    end
end

function ReturnActionTaskPanel:setConfigData(quest_list)    
    if not quest_list then return end
    local period = model:getActionPeriod()
    for i,v in ipairs(quest_list) do
        self.dic_task_list[v.id] = v
        local key = getNorKey(period, v.id)
        local config = Config.HolidayReturnNewData.data_task_fun(key)
        if config and v.finish ~= TaskConst.task_status.over then
            local task = self.dic_limit_list[config.f_id] --父类id
            if task == nil then
                task = {}
                self.dic_limit_list[config.f_id] = task
                _table_insert(self.task_items, task)
            end
            
            local is_chang = true
            if task.config then
                if config.s_id > task.config.s_id then
                    --当前 序号比记录大 那么如果记录 未领取奖励 不能替换 
                    if task.finish ~= TaskConst.task_status.completed then
                        is_chang = false
                    end
                elseif config.s_id < task.config.s_id then
                    --当前 序号比记录小  如果 当前已领取奖励 不能替换
                    if v.finish == TaskConst.task_status.completed  then
                        is_chang = false
                    end 
                end
            end
            
            if is_chang then
                -- task.id = config.id
                task.config = config
                task.id = config.f_id
                if v.finish == TaskConst.task_status.finish then
                    task.sort = 0
                elseif v.finish == TaskConst.task_status.un_finish then
                    task.sort = 1
                else
                    task.sort = v.finish
                end
                
                task.finish = v.finish --总状态 (0:未完成 1:已完成 2:已奖励, 3:已过期)"}
                task.title = config.title
                task.desc = config.desc
                --目标值当前值(x/n)
                task.target_val = v.target_val
                task.value = v.value
                task.end_time = v.ref_time 
                task.award = config.award
            end
        end 
    end

    self:sortItemList()
end

function ReturnActionTaskPanel:sortItemList()
    local sort_func = SortTools.tableLowerSorter({"sort","id"})
    table.sort(self.task_items, sort_func)
    self.item_scrollview:reloadData()
end


function ReturnActionTaskPanel:updateTimeByIndex(index, time_desc)
    -- body 
    local cell_data = self.task_items[index]
    if cell_data then
        if time_desc then
            local time = cell_data.end_time - GameNet:getInstance():getTime()
            if time < 0 then
                time = 0
            end
            time_desc:setString(string_format("%s%s", TI18N("剩余"), TimeTool.getDayOrHour(time)))
        end
    end
end

function ReturnActionTaskPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

function ReturnActionTaskPanel:DeleteMe()
	doStopAllActions(self.label_time)
	if self.task_event then
        GlobalEvent:getInstance():UnBind(self.task_event)
        self.task_event = nil
    end
    if self.task_updata_event then
        GlobalEvent:getInstance():UnBind(self.task_updata_event)
        self.task_updata_event = nil
    end
    if self.limin_task_event then
        GlobalEvent:getInstance():UnBind(self.limin_task_event)
        self.limin_task_event = nil
    end

	if self.load_banner then 
        self.load_banner:DeleteMe()
        self.load_banner = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
end

------------------------------------------
-- 子项
ReturnActionTaskItem = class("ReturnActionTaskItem", function()
    return ccui.Widget:create()
end)

function ReturnActionTaskItem:ctor()
    self:configUI()
    self:register_event()
end

function ReturnActionTaskItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("returnaction/returnaction_task_item"))
    self:setContentSize(cc.size(694,141))
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.title_name = main_container:getChildByName("title_name")
    self.title_name:setString("")
    self.title_desc = main_container:getChildByName("title_desc")
    self.title_desc:setString("")
    self.time_lab = main_container:getChildByName("time_lab")
    self.time_lab:setString("")
    
    self.get_spr = main_container:getChildByName("get_spr")
    self.get_spr:setVisible(false)
    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto:getChildByName("Text_8"):setString(TI18N("前往"))
    self.btn_goto:setVisible(false)
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_get:getChildByName("Text_8"):setString(TI18N("领取"))
    self.btn_get:setVisible(false)
    
    self.sign_item = BackPackItem.new(nil,true,nil,0.9)
    main_container:addChild(self.sign_item)
    self.sign_item:setPosition(cc.p(71, 69))
    self.sign_item:setDefaultTip()

end
function ReturnActionTaskItem:register_event()
    registerButtonEventListener(self.btn_get, function()
        if self.data and self.data.config then
        	controller:sender27907(self.data.config.id)
        end
    end ,true, 1)
    registerButtonEventListener(self.btn_goto, function()
    	if self.data and self.data.config and self.data.config.source_id then
	    	StrongerController:clickCallBack(self.data.config.source_id)
	    end
    end ,true, 1)
end

function ReturnActionTaskItem:setData(data)
	if not data then return end

    self.data = data
    self.title_name:setString(data.title)
    
    if self.time_lab then
        self.time_lab:setVisible(data.status ~= TaskConst.task_status.completed)
    end

	local target_val = data.target_val or 0
	local value = data.value or 0
	local str = string_format("%s (%d/%d)",data.desc,value,target_val)
    self.title_desc:setString(str)
    if data.award and data.award[1] then
        if self.sign_item then
        	self.sign_item:setBaseData(data.award[1][1],data.award[1][2])
        end
    end
    self.btn_goto:setVisible(data.finish == 0)
	self.btn_get:setVisible(data.finish == 1)
    self.get_spr:setVisible(data.finish == 2)

    return self.time_lab
end

function ReturnActionTaskItem:DeleteMe()
	if self.sign_item then 
       self.sign_item:DeleteMe()
       self.sign_item = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
