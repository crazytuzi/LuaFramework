-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      日常主界面的成就标签页
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------

FeatPanel = class("FeatPanel",function()
    return ccui.Layout:create()
end)

function FeatPanel:ctor(ctrl)
    self.ctrl = ctrl
    self.model = self.ctrl:getModel()
    self.size = cc.size(637, 782)
    self.scroll_view = createImage(self,"",2,12,cc.p(0, 0), true, 1, true)
    self.scroll_view:setContentSize(self.size)

    local setting = {
        item_class = FeatItem,
        start_x = 11,
        space_x = 0,
        start_y = 0,
        space_y = 4,
        item_width = 610,
        item_height = 148,
        row = 1,
        col = 1,
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.scroll_view,cc.p(0, 10),ScrollViewDir.vertical,ScrollViewStartPos.top,cc.size(self.size.width, self.size.height-20),setting)
end

function FeatPanel:registerEvent()
end

function FeatPanel:addToParent(status)
    self:handleDynamicEvent(status)
    self:setVisible(status)
    if status == true then
        self:updateFeatList(true)
    end
end

function FeatPanel:handleDynamicEvent(status)
    if not status then
        if self.update_feat_list ~= nil then
            GlobalEvent:getInstance():UnBind(self.update_feat_list)
            self.update_feat_list = nil
        end
    else
        if self.update_feat_list == nil then
            self.update_feat_list = GlobalEvent:getInstance():Bind(TaskEvent.UpdateFeatList, function()
                self:updateFeatList()
            end)
        end
    end
end

function FeatPanel:updateFeatList()
    local list = self.model:getFeatList()
    self.item_scrollview:setData(list)
end

function FeatPanel:DeleteMe()
    self:handleDynamicEvent(false)
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
end

-- --------------------------------------------------------------------
-- @author: yuanqi(必填, 创建模块的人员)
-- @description:
--      成就使用的单元
--
-- --------------------------------------------------------------------
FeatItem = class("FeatItem", function()
    return ccui.Layout:create()
end)

function FeatItem:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("task/feat_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.btn_img_res = PathTool.getResFrame("common", "common_1098")
    self.container = self.root_wnd:getChildByName("container")
    self.task_desc = self.container:getChildByName("task_desc")

    self.btn_container = self.container:getChildByName("btn_container")
    self.goto_btn = self.btn_container:getChildByName("goto_btn")
    self.goto_btn_label = self.goto_btn:getChildByName("label")
    self.goto_btn_label:setString(TI18N("前往"))

    self.progress = self.btn_container:getChildByName("progress")
    --self.progress:setScale9Enabled(true)
    self.progress:setPercent( 0 )
    self.value = self.btn_container:getChildByName("value")
    self.value:setString(string.format("%s/%s", 0,0))

    self.completed_img = self.container:getChildByName("completed_img")

    self.item_list = {}

    self:registerEvent()
end

function FeatItem:registerEvent()
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

function FeatItem:setData(data)
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
function FeatItem:fillAwardsItems()
    if self.data == nil or self.data.config == nil or self.data.config.commit_rewards == nil then return end
    for i, item in ipairs(self.item_list) do
        item:setVisible(false)
    end
    for i,v in ipairs(self.data.config.commit_rewards) do
        local bid = v[1];
        local num = v[2];
        local item = self.item_list[i]
        if item == nil then
            item = BackPackItem.new(false, true, false, 0.7, false, true)
            local _x = (BackPackItem.Width * 0.7 + 20) * (i -1) + 58
            item:setPosition(_x, 46);
            self.container:addChild(item)
            self.item_list[i] = item
        else
            item:setVisible(true);
        end
        item:setBaseData(bid, num);
    end
end

function FeatItem:updateSelf()
    if self.data == nil then return end
    self.id = self.data.id
    self.finish_sort = self.data.finish_sort
    
    self.completed_img:setVisible(self.data.finish == TaskConst.task_status.completed)
    self.btn_container:setVisible(self.data.finish ~= TaskConst.task_status.completed)

    local btn_img_res = PathTool.getResFrame("common", "common_1017")
    local outline_index = 167
    if self.data.finish == TaskConst.task_status.un_finish then
        self.goto_btn_label:setString(TI18N("前往"))
        self.goto_btn_label:enableShadow(Config.ColorData.data_new_color4[3],cc.size(0, -2),2)

        --self.goto_btn_label:enableOutline(cc.c4b(0x29, 0x4a, 0x15, 0xff),2)
    elseif self.data.finish == TaskConst.task_status.finish then
        self.goto_btn_label:setString(TI18N("提交"))
        btn_img_res = PathTool.getResFrame("common", "common_1018")
        self.goto_btn_label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)

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
                --BT适配
                local value = progress.value
                local target_val = progress.target_val

                if self.data.config.progress 
                    and self.data.config.progress[1] 
                    and self.data.config.progress[1].cli_label == "evt_power" then
                    value = changeBtValueForPower(progress.value)
                    target_val = changeBtValueForPower(progress.target_val)
                end
                ----
                self.value:setString(string.format("%s/%s", MoneyTool.GetMoneyString(value), MoneyTool.GetMoneyString(target_val)))
                self.progress:setPercent( 100 * progress.value/progress.target_val )
            end
        end
    end
    self.task_desc:setString(self.data:getTaskContent())
end

function FeatItem:suspendAllActions()
    if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end
end

function FeatItem:DeleteMe()
    for i,v in ipairs(self.item_list) do
        v:DeleteMe()
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