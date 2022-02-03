-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      历练ui
-- <br/> 2019年5月29日
--
-- --------------------------------------------------------------------

TaskExpPanel = class("TaskExpPanel",function()
    return ccui.Layout:create()
end)

local controller = TaskController:getInstance()
local model = controller:getModel()

local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort

function TaskExpPanel:ctor()

    self.exp_type_list = {
        [1] = TaskConst.exp_type.total,
        [2] = TaskConst.exp_type.pvp,
        [3] = TaskConst.exp_type.common,
        [4] = TaskConst.exp_type.special
    }

    self.tab_list = {}
    self.dic_max_count = {}
    --初始化
    for k,_type in pairs(self.exp_type_list) do
        self.dic_max_count[_type] = 0
    end
    
    local type_list = Config.RoomFeatData.data_type_list
    if type_list then
        --计算每种类型的数量
        for _type,list in pairs(type_list) do
            self.dic_max_count[_type] = #list
        end
        local total_count = 0
        for k,count in pairs(self.dic_max_count) do
            total_count = total_count + count
        end
        self.dic_max_count[TaskConst.exp_type.total] = total_count
    end

    self:configUI()
    self:registerEvent()
end

function TaskExpPanel:configUI( )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("task/task_exp_panel"))
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.tab_btn = self.container:getChildByName("tab_btn")
    local tab_name_list = {
        [1] = TI18N("总览"),
        [2] = TI18N("竞技历练"),
        [3] = TI18N("战斗历练"),
        [4] = TI18N("特殊历练")
    }

   
    local tab_btn_obj = self.container:getChildByName("tab_btn")
    local res = PathTool.getResFrame("taskexp", "task_exp_08")
    for i=1,4 do
        local tab_btn = {}
        local item = tab_btn_obj:getChildByName("tab_btn_"..i)
        tab_btn.btn = item
        tab_btn.exp_type = self.exp_type_list[i]
        tab_btn.select_bg = item:getChildByName("select_img")
        tab_btn.select_bg:setVisible(false)
        tab_btn.title = item:getChildByName("label")
        if tab_name_list[i] then
            tab_btn.title:setString(tab_name_list[i])
        end
        --进度条
        local bar_node = item:getChildByName("bar_node")
        local sprite = createSprite(res, 0, 0, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
        tab_btn.progress = cc.ProgressTimer:create(sprite)
        tab_btn.progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        bar_node:addChild(tab_btn.progress)
        bar_node:setScale(-1, 1)
        tab_btn.progress:setPercentage(i*25)

        --百分比
        tab_btn.per_label = item:getChildByName("per_label")
        -- tab_btn.icon = item:getChildByName("icon")
        tab_btn.per_label:setString((i * 25).."%")
        self.tab_list[i] = tab_btn
    end

    self.exp_container = self.container:getChildByName("exp_container")
    -- self.role_vo = RoleController:getInstance():getRoleVo()
end

function TaskExpPanel:registerEvent()
    for index, tab_btn in ipairs(self.tab_list) do
       registerButtonEventListener(tab_btn.btn, function() self:changeTabType(tab_btn.exp_type) end ,false, 1) 
    end

    --新的任务更新
    if self.task_exp_update_event == nil then
        self.task_exp_update_event = GlobalEvent:getInstance():Bind(TaskEvent.TASK_EXP_UPDATE_EVENT,function()
            self:updateExpList(true)
        end)
    end

    if self.task_exp_update_time_event == nil then
        self.task_exp_update_time_event = GlobalEvent:getInstance():Bind(TaskEvent.TASK_EXP_UPDATE_TINE_EVENT,function()
            self:updateProgressInfo()
            self:updateExpList(true)
        end)
    end
end

-- @_type 参考 RoleConst.Tab_type 定义
--@check_repeat_click 是否检查重复点击
function TaskExpPanel:changeTabType(exp_type, must_reset)
    if not must_reset and self.select_exp_type and self.select_exp_type == exp_type then return end
    for i,v in ipairs(self.tab_list) do
        if v.exp_type == exp_type then
            v.select_bg:setVisible(true)
        else
            v.select_bg:setVisible(false)
        end
    end
    self.select_exp_type = exp_type
    self:updateExpList()
end

function TaskExpPanel:updateProgressInfo()
    local task_list = model:getTaskExpList()
    local dic_count = {}
    for k,v in pairs(task_list) do
        --已完成提交的任务
        if v.finish == TaskConst.task_status.completed then
            if dic_count[v.config.type] == nil then
                dic_count[v.config.type] = 1
            else
                dic_count[v.config.type] = dic_count[v.config.type] + 1
            end
        end
    end
    local tot_count = 0
    for k,count in pairs(dic_count) do
        tot_count = tot_count + count
    end
    dic_count[TaskConst.exp_type.total] = tot_count

    --dic_count 表示目前已经拥有完成任务数据
    --self.dic_max_count 表示完成的任务的总数

    for i,tab_btn in pairs(self.tab_list) do
        local cur_count = dic_count[tab_btn.exp_type] or 0
        local max_count = self.dic_max_count[tab_btn.exp_type] or 0
        if max_count == 0 then
            --分母为0表示没有.那完成度 100%
            tab_btn.progress:setPercentage(100)
            tab_btn.per_label:setString("100%")
        else
            local per = cur_count*100/max_count
            if per > 100 then
                per = 100
            end
            tab_btn.progress:setPercentage(per)
            per = math.floor(per)
            tab_btn.per_label:setString(per.."%")
        end
    end
end


--创建历练列表 
-- @ is_keep_pos --是否保存当前位置刷新
function TaskExpPanel:updateExpList(is_keep_pos)
    if not self.select_exp_type then return end
    if not self.list_view then
        local scroll_view_size = cc.size(628,608)
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 4,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 628,               -- 单元的尺寸width
            item_height = 140,              -- 单元的尺寸height
            delay = 1,
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }
        local size = self.exp_container:getContentSize()
        self.list_view = CommonScrollViewSingleLayout.new(self.exp_container, cc.p(size.width * 0.5, size.height * 0.5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0.5,0.5))

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    self.show_list = {}
    local task_list = model:getTaskExpList()
    for k,v in pairs(task_list) do
        if v.config then
            if self.select_exp_type == TaskConst.exp_type.total or self.select_exp_type == v.config.type then
                if v.finish == TaskConst.task_status.un_finish then --进行中
                    v.sort = 2
                    if v.config.hide == FALSE then
                        --不隐藏才能显示
                        table_insert(self.show_list, v)
                    end
                elseif v.finish == TaskConst.task_status.finish then --已完成
                    v.sort = 1
                    table_insert(self.show_list, v)    
                else --已提交
                    v.sort = 3
                    table_insert(self.show_list, v)    
                end
            end
        end
    end
    
    local sort_func = SortTools.tableCommonSorter({{"sort", false}, {"id", false}})
    table_sort(self.show_list, sort_func)
    
    self.list_view:reloadData(nil, nil, is_keep_pos)
    

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.exp_container, true)
    else
        commonShowEmptyIcon(self.exp_container, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function TaskExpPanel:createNewCell(width, height)
    local cell = taskExpItem.new(width, height)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function TaskExpPanel:numberOfCells()
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function TaskExpPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if data then
        cell:setData(data)
    end
end

-- --点击cell .需要在 createNewCell 设置点击事件
-- function TaskExpPanel:onCellTouched(cell)
--     local index = cell.index
--     local data = self.show_list[index]
--     if data then

--     end
-- end

function TaskExpPanel:addToParent(status)
    self:setVisible(status)

    self:updateProgressInfo()
    self:changeTabType(TaskConst.exp_type.total, true)
    if status == true then
        -- self.ctrl:requestActivityInfo() -- 设置当前面板的时候做一次协议请求
    end
end

function TaskExpPanel:DeleteMe()
    if self.list_view then
        self.list_view:DeleteMe()
        self.list_view = nil
    end

    if self.task_exp_update_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.task_exp_update_event)
        self.task_exp_update_event = nil
    end
    if self.task_exp_update_time_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.task_exp_update_time_event)
        self.task_exp_update_time_event = nil
    end

end

-- 子项
taskExpItem = class("taskExpItem", function()
    return ccui.Widget:create()
end)

function taskExpItem:ctor(width, height)
    self:configUI(width, height)
    self:register_event()
end

function taskExpItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("task/task_exp_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container

    --领取按钮
    self.comfirm_btn = main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("领取"))
    self.comfirm_btn:getChildByName("label"):enableOutline(cc.c4b(0x76, 0x45, 0x19, 0xff),2)
    --分享
    self.share_btn = main_container:getChildByName("share_btn")
    self.share_btn:getChildByName("label"):setString(TI18N("分享"))

    self.pic_has = main_container:getChildByName("pic_has")

    --标题
    self.title = main_container:getChildByName("title")
    --时间
    self.recrod_time_bg = main_container:getChildByName("recrod_time_bg")
    self.recrod_time = main_container:getChildByName("recrod_time")
    
    --道具
    self.item_list = {}
    for i=1,2 do
        local item_node = main_container:getChildByName("item_node_"..i)
        self.item_list[i] = BackPackItem.new(false, true, false, 0.6, false, true, true)
        item_node:addChild(self.item_list[i])
    end

    self.task_desc = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 1), cc.p(26, 85), nil, nil, 270)
    main_container:addChild(self.task_desc)
end

function taskExpItem:register_event( )
    registerButtonEventListener(self.comfirm_btn, function() self:onClickComfirmBtn() end,true, 1)
    registerButtonEventListener(self.share_btn, function(param, sender, event_type) self:onClickShareBtn(sender) end,true, 1)
end

--领取
function taskExpItem:onClickComfirmBtn()
    if not self.data then return end
    controller:sender25812(self.data.id)
end

--分享
function taskExpItem:onClickShareBtn(sender)
    if not self.data then return end
    if not self.data.config then return end
    local setting = {}
    setting.world_pos = sender:convertToWorldSpace(cc.p(0.5, 0.5))
    setting.callback = function(share_type) self:shareCallback(share_type) end
    controller:openTaskSharePanel(true, setting)
end

function taskExpItem:shareCallback(share_type)
    if not self.data then return end
    if not self.data.config then return end
    if share_type == VedioConst.Share_Btn_Type.eWorldBtn then --分享到世界
        RoleController:getInstance():send25817(self.data.config.id, ChatConst.Channel.World)
    elseif share_type == VedioConst.Share_Btn_Type.eGuildBtn then --分享公会
        RoleController:getInstance():send25817(self.data.config.id, ChatConst.Channel.Gang)
    elseif share_type == VedioConst.Share_Btn_Type.eCrossBtn then --跨服分享
        RoleController:getInstance():send25817(self.data.config.id, ChatConst.Channel.Cross)
    end
end

function taskExpItem:addCallBack(callback)
    self.callback = callback
end

function taskExpItem:setData(data)
    self.data = data
    
    if self.data.config then
        self.title:setString(self.data.config.name)
        self.task_desc:setString(self.data.config.desc)
        local item_data = self.data.config.commit_rewards
        for i=1,2 do
            if self.item_list[i] then
                if item_data[i] then
                    self.item_list[i]:setVisible(true)
                    self.item_list[i]:setBaseData(item_data[i][1], item_data[i][2])
                else
                    self.item_list[i]:setVisible(false)
                end
            end
        end
    end

    if data.finish then
        if data.finish == TaskConst.task_status.finish then --完成未领取
            self:updateFinish()
        elseif data.finish == TaskConst.task_status.un_finish then --未完成
            self:updateUnFinish()
        else --显示已全部完成
            self:updateAllFinish()
        end
    end
end

--更新完成状态 未领取
function taskExpItem:updateFinish()
    self.share_btn:setVisible(false)
    self.pic_has:setVisible(false)
    self.comfirm_btn:setVisible(true)
    self:showProgress(false)

    self.recrod_time:setVisible(false)
    self.recrod_time_bg:setVisible(false)
end

--显示未完成状态
function taskExpItem:updateUnFinish()
    self.share_btn:setVisible(false)
    self.pic_has:setVisible(false)
    self.comfirm_btn:setVisible(false)

    self.recrod_time:setVisible(false)
    self.recrod_time_bg:setVisible(false)
    --进度条 
    local target_val = 0
    local value = 0
    if self.data.progress[1] then
        target_val = self.data.progress[1].target_val
        value = self.data.progress[1].value
    end
    local per =  value * 100 / target_val
    local str = string_format("(%s/%s)", MoneyTool.GetMoneyString(value), MoneyTool.GetMoneyString(target_val))
    self:showProgress(true, per, str)
end

--显示全部已经完成显示分享按钮
function taskExpItem:updateAllFinish()
    self.share_btn:setVisible(true)
    self.pic_has:setVisible(true)
    self.comfirm_btn:setVisible(false)
    self:showProgress(false)
    self.recrod_time:setVisible(true)
    self.recrod_time_bg:setVisible(true)
    
    self.recrod_time:setString(TimeTool.getYMD3(self.data.finish_time or 0))
end

function taskExpItem:showProgress(status, percent, label)
    if status then
        if self.comp_bar == nil then
            local size = cc.size(115, 19)
            local res = PathTool.getResFrame("common","common_90005")
            local res1 = PathTool.getResFrame("common","common_90006")
            local bg,comp_bar = createLoadingBar(res, res1, size, self.main_container, cc.p(0.5,0.5), 540, 64, true, true)
            self.comp_bar_bg = bg
            self.comp_bar = comp_bar
        else
            self.comp_bar_bg:setVisible(true)
        end

        if not self.comp_bar_label then
            local size = cc.size(115, 19)
            local text_color = cc.c3b(0x64,0x32,0x23)
            self.comp_bar_label = createLabel(18, text_color, nil, size.width/2, size.height/2 + 30, "", self.comp_bar, 2, cc.p(0.5, 0.5))
        end

        self.comp_bar:setPercent(percent)
        self.comp_bar_label:setString(label)  
    else
        if self.comp_bar_bg then
            self.comp_bar_bg:setVisible(false)
        end
    end
end

function taskExpItem:DeleteMe()
    for i,item in ipairs(self.item_list) do
        item:DeleteMe()
    end
    
    self:removeAllChildren()
    self:removeFromParent()
end


