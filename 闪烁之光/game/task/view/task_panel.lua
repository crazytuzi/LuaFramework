-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      日常主界面的任务标签页
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------

TaskPanel = class("TaskPanel",function()
    return ccui.Layout:create()
end)

function TaskPanel:ctor(ctrl)
    self.ctrl = ctrl
    self.model = self.ctrl:getModel()
    self.awards_list = {}
    self.box_list = {109, 108, 108, 110}
    self.role_vo = RoleController:getInstance():getRoleVo()

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("task/task_panel"))
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    local activity_container = self.container:getChildByName("activity_container")
    local progress_container = activity_container:getChildByName("progress_container")
    self.progress = progress_container:getChildByName("progress")
    self.progress:setScale9Enabled(true)

    -- local title = activity_container:getChildByName("title")
    -- title:setString(TI18N("活跃度"))

    self.value = activity_container:getChildByName("value")
    self.value:setString("100/200")

    local res_id
    for i = 1, Config.ActivityData.data_get_length do
        local awards = activity_container:getChildByName("awards_" .. i)
        if awards ~= nil then
            awards.effect_container = awards:getChildByName("effect_container")
            awards.target_value = awards:getChildByName("target_value")
            awards.is_show_tips = true
            awards.status = TaskConst.action_status.normal
            if Config.ActivityData.data_get[i] ~= nil then
                awards.config = Config.ActivityData.data_get[i]
                awards.target_value:setString(awards.config.activity)
            end
            -- 按照配置的活跃度储存
            self.awards_list[i] = awards
        end
    end

    self.quest_container = self.container:getChildByName("quest_container")
    self.size = self.quest_container:getContentSize()
    local setting = {
        item_class = TaskItem,
        start_x = 8,
        space_x = 0,
        start_y = 0,
        space_y = 4,
        item_width = 616,
        item_height = 121,
        row = 1,
        col = 1,
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.quest_container,cc.p(0, 10),ScrollViewDir.vertical,ScrollViewStartPos.top,cc.size(self.size.width, self.size.height-20),setting)

    self:registerEvent()
end

function TaskPanel:registerEvent()
    for k, awards in ipairs(self.awards_list) do
        awards:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    if sender.config ~= nil then
                        if sender.is_show_tips == true then
                            CommonAlert.showItemApply(TI18N("当前活跃度奖励"),sender.config.rewards,nil,TI18N("确定"),nil,nil,TI18N("奖励"),nil,nil,true,nil, nil,{off_y=50})
                        else
                            if self.role_vo and self.role_vo.activity >= sender.config.activity then
                                self.ctrl:requestGetActivityAwards(sender.config.activity)
                            end
                        end
                    end
                end
            end
        )
    end
end

function TaskPanel:addToParent(status)
    self:setVisible(status)
    self:handleDynamicEvent(status)

    if status == true then
        self.ctrl:requestActivityInfo() -- 设置当前面板的时候做一次协议请求
        self:updateActivity(false)
        self:updateTaskList(true)
    end
end

function TaskPanel:handleDynamicEvent(status)
    if not status then
        if self.role_assets_event ~= nil then
            if self.role_vo ~= nil then
                self.role_vo:UnBind(self.role_assets_event)
            end
            self.role_assets_event = nil
        end
        if self.update_activity_event ~= nil then
            GlobalEvent:getInstance():UnBind(self.update_activity_event)
            self.update_activity_event = nil
        end
        if self.update_task_list ~= nil then
            GlobalEvent:getInstance():UnBind(self.update_task_list)
            self.update_task_list = nil
        end
    else
        if self.role_vo ~= nil then
            if self.role_assets_event == nil then
                self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value) 
                    if key == "activity" then
                        self:updateActivity(true)
                    end
                end)
            end
        end
        if self.update_activity_event == nil then
            self.update_activity_event = GlobalEvent:getInstance():Bind(TaskEvent.UpdateActivityInfo,function(data)
                self:updateActivityData(data)
            end)
        end
        if self.update_task_list == nil then
            self.update_task_list = GlobalEvent:getInstance():Bind(TaskEvent.UpdateTaskList,function(is_new)
                self:updateTaskList(is_new)
            end)
        end
    end
end

function TaskPanel:updateActivity(need_update)
    if self.role_vo ~= nil then
        local activity_config = Config.ActivityData.data_get[Config.ActivityData.data_get_length]
        local max_activity = 100
        if activity_config ~= nil then
            max_activity = activity_config.activity
        end
        self.value:setString(self.role_vo.activity .. "/" .. max_activity)
        self.progress:setPercent(self.role_vo.activity / max_activity * 100)

        if need_update == true then
            self:updateActivityData(self.model:getActivityData())
        end
    end
end

--[[
    @desc:更新活跃宝箱
    author:{author}
    time:2018-05-22 16:02:57
    --@data: 
    return
]]
function TaskPanel:updateActivityData(data)
    if self.role_vo == nil then
        return
    end
    local data_list = data

    -- 判断这个活跃度的宝箱是否已经领取了
    local function check_activity(activity)
        if data_list == nil then
            return false
        end
        return data_list[activity]
    end

    for i, item in ipairs(self.awards_list) do
        if item and item.config and not tolua.isnull(item.effect_container) then
            if check_activity(item.config.activity) == true then
                item.is_show_tips = true
                item.status = TaskConst.action_status.finish
            else
                if item.config.activity <= self.role_vo.activity then
                    item.is_show_tips = false
                    item.status = TaskConst.action_status.activity
                else
                    item.is_show_tips = true
                    item.status = TaskConst.action_status.un_activity
                end
            end

            local box_action = PlayerAction.action_1
            if item.status == TaskConst.action_status.finish then
                box_action = PlayerAction.action_3
            elseif item.status == TaskConst.action_status.activity then
                box_action = PlayerAction.action_2
            end
            if not tolua.isnull(item.effect_container.box) then
                if item.box_action ~= box_action then
                    if item.effect_container.box.setAnimation then
                        item.effect_container.box:clearTracks()
                        item.effect_container.box:setToSetupPose()
                        item.effect_container.box:setAnimation(0, box_action, true)
                    end
                    item.box_action = box_action
                end
            else
                delayRun(self.container, 2 * i / display.DEFAULT_FPS, function()
                    local res_id = PathTool.getEffectRes(self.box_list[i])
                    local box = createEffectSpine(res_id, cc.p(item.effect_container:getContentSize().width * 0.5, 3), cc.p(0.5, 0), true, box_action)
                    item.effect_container:addChild(box)
                    item.effect_container.box = box
                    item.box_action = box_action
                end)
            end
        end
    end
end

--[[
    @desc:更新任务列表，是否需要重新更新列表
    author:{author}
    time:2018-05-22 19:11:28
    --@is_new:如果为true,则重新排序吧，否则就直接更新位置
    return
]]
function TaskPanel:updateTaskList(is_new)
    if is_new == true then
        local list = self.model:getTaskList()
        self.item_scrollview:setData(list)
    else
        local sort_func = SortTools.tableLowerSorter({"finish_sort", "id"})
        self.item_scrollview:resetPosition(sort_func)
    end
end

function TaskPanel:DeleteMe()
	doStopAllActions(self.container)
    self:handleDynamicEvent(false)
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
end
