-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      任务和成就使用的单元
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
TaskItem = class("TaskItem", function()
    return ccui.Layout:create()
end)

function TaskItem:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("task/task_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.btn_img_res = PathTool.getResFrame("common", "common_1018")
    self.container = self.root_wnd:getChildByName("container")
    self.task_desc = self.container:getChildByName("task_desc")

    self.btn_container = self.container:getChildByName("btn_container")
    self.goto_btn = self.btn_container:getChildByName("goto_btn")
    self.goto_btn_label = self.goto_btn:getChildByName("label")
    self.goto_btn_label:setString(TI18N("前往"))

    self.progress = self.btn_container:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setPercent( 0 )
    self.value = self.btn_container:getChildByName("value")
    self.value:setString(string.format("%s/%s", 0,0))

    self.completed_img = self.container:getChildByName("completed_img")
    self.goods_con = self.container:getChildByName("goods_con")
    local scroll_view_size = self.goods_con:getContentSize()
    local setting = {
        item_class = BackPackItem, -- 单元类
        start_x = 0, -- 第一个单元的X起点
        space_x = 8.5, -- x方向的间隔
        start_y = 11, -- 第一个单元的Y起点
        space_y = 4, -- y方向的间隔
        item_width = BackPackItem.Width * 0.7, -- 单元的尺寸width
        item_height = BackPackItem.Height * 0.7, -- 单元的尺寸height
        row = 1, -- 行数，作用于水平滚动类型
        col = 0, -- 列数，作用于垂直滚动类型
        scale = 0.7
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con,cc.p(0, 0),ScrollViewDir.horizontal,ScrollViewStartPos.top,scroll_view_size,setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_list = {}

    self:registerEvent()
end

function TaskItem:registerEvent()
    self.goto_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data ~= nil and self.data.config ~= nil then
                if self.data.finish == TaskConst.task_status.un_finish then
                    if self.data.progress ~= nil then
                        for i, v in ipairs(self.data.progress) do
                            if v.finish == FALSE then
                                TaskController:getInstance():handleTaskProgress(self.data, i)
                                break
                            end
                        end
                    end
                elseif self.data.finish == TaskConst.task_status.finish then
                    if self.data.type == TaskConst.type.quest then
                        TaskController:getInstance():requestSubmitTask(self.data.id)
                    elseif self.data.type == TaskConst.type.feat then
                        TaskController:getInstance():requestSubmitFeat(self.data.id)
                    end
                end
            end
        end
    end)
	-- 退出的时候移除一下吧.要不然可能有些人不会手动移除,就会报错
	self:registerScriptHandler(function(event)
		if "enter" == event then
		elseif "exit" == event then	
            if self.data ~= nil then
                if self.update_self_event ~= nil then
                    self.data:UnBind(self.update_self_event)
                    self.update_self_event = nil
                end
                self.data = nil
            end
		end 
	end)
end

function TaskItem:setData(data)
    if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end
    self.data = data
    if self.update_self_event == nil then
        self.update_self_event = self.data:Bind(TaskEvent.UpdateSingleQuest, function() 
            self:updateSelf()
        end)
    end
    self:updateSelf()
    self:fillAwardsItems()
end

--[[
    @desc:创建展示物品
    author:{author}
    time:2018-05-26 13:56:08
    return
]]
function TaskItem:fillAwardsItems()
    if self.data == nil or self.data.config == nil or self.data.config.commit_rewards == nil then return end
    local list = {}
    for k, v in ipairs(self.data.config.commit_rewards) do
        local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
        if vo then
            vo.quantity = v[2]
            table.insert(list, vo)
        end
    end
    if list ~= nil and next(list) ~= nil and #list <= 2 then
        self.item_scrollview:setClickEnabled(false)
    else
        self.item_scrollview:setClickEnabled(true)
    end
    self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
        for k, v in pairs(list) do
            v.effect = false
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
    self.item_scrollview:setData(list)
end

function TaskItem:updateSelf()
    if self.data == nil then return end
    self.id = self.data.id
    self.finish_sort = self.data.finish_sort
    
    self.completed_img:setVisible(self.data.finish == TaskConst.task_status.completed)
    self.btn_container:setVisible(self.data.finish ~= TaskConst.task_status.completed)

    local btn_img_res = PathTool.getResFrame("common", "common_1018")
    local outline_index = 167
    if self.data.finish == TaskConst.task_status.un_finish then
        self.goto_btn_label:setString(TI18N("前往"))
        self.goto_btn_label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
        --self.goto_btn_label:enableOutline(cc.c4b(0x29, 0x4a, 0x15, 0xff),2)
    elseif self.data.finish == TaskConst.task_status.finish then
        self.goto_btn_label:setString(TI18N("提交"))
        btn_img_res = PathTool.getResFrame("common", "common_1017")
        self.goto_btn_label:enableShadow(Config.ColorData.data_new_color4[3],cc.size(0, -2),2)

        --self.goto_btn_label:enableOutline(cc.c4b(0x76, 0x45, 0x19, 0xff),2)
    end
    if self.btn_img_res ~= btn_img_res then
        self.btn_img_res = btn_img_res
        self.goto_btn:loadTexture(btn_img_res, LOADTEXT_TYPE_PLIST)
    end
    
    if self.data.finish ~= TaskConst.task_status.completed then
        if self.data.progress ~= nil then
            local progress = self.data.progress[1]
            if progress ~= nil then
                self.value:setString(string.format("%s/%s", MoneyTool.GetMoneyString(progress.value), MoneyTool.GetMoneyString(progress.target_val)))
                self.progress:setPercent( 100 * progress.value/progress.target_val )
            end
        end
    end
    self.task_desc:setString(self.data:getTaskContent())
end

function TaskItem:suspendAllActions()
    if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end
end

function TaskItem:DeleteMe()
    for i,v in ipairs(self.item_list) do
        v:DeleteMe()
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    self.item_list = nil
    if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end