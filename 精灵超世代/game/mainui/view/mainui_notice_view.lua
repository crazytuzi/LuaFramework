-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--     一些提示行的父节点
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
MainUiNoticeView = class("MainUiNoticeView", function()
	return ccui.Layout:create()
end) 

local table_insert = table.insert
local table_remove = table.remove

function MainUiNoticeView:ctor()
    self:initConfig()
    self:createRootWnd()
    self:registerEvent()
end

function MainUiNoticeView:initConfig()
    self.finish_list = {}
    self.be_in_show = false
    self.cur_info = {}
    self.resources_load_finish = false
    self.world_buff_list = {}
end

function MainUiNoticeView:createRootWnd()
    self:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self:setAnchorPoint(cc.p(0, 0))
    ViewManager:getInstance():addToLayerByTag(self, ViewMgrTag.MSG_TAG, 10) 

    self.item = createCSBNote(PathTool.getTargetCSB("task/task_notice_item"))
    self.item:setAnchorPoint(cc.p(0.5, 1))
    self.item:setPosition(SCREEN_WIDTH*0.5, display.getTop())
    self:addChild(self.item)

    self.container = self.item:getChildByName("container")
    self.container:setVisible(false)
    self.task_img = self.container:getChildByName("task_img")
    self.task_name = self.container:getChildByName("task_name") 
    self.task_desc = self.container:getChildByName("task_desc") 

    -- 移动的位移
    self.target_height = self.container:getContentSize().height
    self.container:setPositionY(self.target_height)
end

function MainUiNoticeView:registerEvent()
    if self.update_quest_finish_event == nil then
        self.update_quest_finish_event = GlobalEvent:getInstance():Bind(TaskEvent.UpdateTaskList, function(is_new, task_list)
            self:fillFinishData(task_list, TaskConst.type.quest)
        end)
    end

    if self.update_feat_finish_event == nil then
        self.update_feat_finish_event = GlobalEvent:getInstance():Bind(TaskEvent.UpdateFeatList, function(feat_list)
            self:fillFinishData(feat_list, TaskConst.type.feat)
        end)
    end

    if self.update_exp_finish_event == nil then
        self.update_exp_finish_event = GlobalEvent:getInstance():Bind(TaskEvent.TASK_EXP_FINISH_TIPS_EVENT, function(feat_list)
            self:fillFinishData(feat_list, TaskConst.type.exp)
        end)
    end

    self.container:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:doMoveOut()
            if self.cur_info then
                TaskController:getInstance():openTaskMainWindow(true, self.cur_info.type)
            end
        end
    end)
end

--==============================--
--desc:填充待显示的完成数据
--time:2018-07-19 09:59:04
--@list:
--@type:
--@return 
--==============================--
function MainUiNoticeView:fillFinishData(list, type)
    -- 引导中不出来
    if GuideController:getInstance():isInGuide() then return end
    -- 剧情中也不出来
    if StoryController:getInstance():getModel():isStoryState() then return end 

    if list == nil or next(list) == nil then return end
    for i,v in ipairs(list) do
        table_insert(self.finish_list, {id=v, type=type})
    end
    self:doMoveFinishItem()
end

function MainUiNoticeView:doMoveFinishItem()
    if self.be_in_show == true then return end
    if self.finish_list == nil or next(self.finish_list) == nil then return end
    self.be_in_show = true
    local cur_data = table_remove(self.finish_list, 1)
    if cur_data then
        local task_model = TaskController:getInstance():getModel()
        if cur_data.type == TaskConst.type.quest then
            self.cur_info = task_model:getTaskById(cur_data.id)
        elseif cur_data.type == TaskConst.type.feat then
            self.cur_info = task_model:getFeatById(cur_data.id)
        elseif cur_data.type == TaskConst.type.exp then
            self.cur_info = task_model:getTaskExpListById(cur_data.id)
        end
    end

    if self.cur_info and self.cur_info.config then
        local res_name = "quest_item_icon"
        if self.cur_info.type == TaskConst.type.feat then --成就任务
            self.task_name:setString(TI18N("成就达成"))
            res_name = "quest_item_icon_2"
        elseif self.cur_info.type == TaskConst.type.exp then --历练任务
            self.task_name:setString(self.cur_info.config.name)
            if self.cur_info.config.hide == TRUE then
                res_name = "quest_item_icon_4"
                --差特效
                self:showItemEffect(true)
            else
                res_name = "quest_item_icon_3"
            end
        else
            self.task_name:setString(TI18N("日常完成"))
            res_name = "quest_item_icon"
        end

        local str = self.cur_info:getTaskContent()
        if StringUtil.SubStringGetTotalIndex(str) > 14 then
            str = StringUtil.SubStringUTF8(str, 1, 14)
            str = str.."..."
        end
        self.task_desc:setString(str)


        self.load_resources = createResourcesLoad(PathTool.getPlistImgForDownLoad("bigbg/quest", res_name), ResourcesType.single, function() 
            loadSpriteTexture(self.task_img, PathTool.getPlistImgForDownLoad("bigbg/quest", res_name), LOADTEXT_TYPE)
        end, self.load_resources)

        self:doMoveIn()
    end
end

function MainUiNoticeView:doMoveIn()
    self.container:setVisible(true)
    self.container:setOpacity(0)
    self.container:setPositionY(self.target_height)

    local fadein = cc.FadeIn:create(0.3)
    local move_to = cc.MoveTo:create(0.3, cc.p(0, 0))
    local delay = cc.DelayTime:create(3) 
    local fadeout = cc.FadeOut:create(0.3) 
    local move_out = cc.MoveTo:create(0.3, cc.p(0, self.target_height))
    local call_fun = cc.CallFunc:create(function() 
        self:doMoveOut()
    end)
    self.container:runAction(cc.Sequence:create(cc.Spawn:create(fadein, move_to),delay,cc.Spawn:create(fadeout, move_out),call_fun))
end

function MainUiNoticeView:doMoveOut()
    self.be_in_show = false
    self.container:stopAllActions()
    self.container:setVisible(false)
    self.container:setOpacity(0)
    self.container:setPositionY(self.target_height)
    if self.load_resources then
        self.load_resources:DeleteMe()
        self.load_resources = nil
    end
    self:showItemEffect(false)
    self:doMoveFinishItem()
end

function MainUiNoticeView:showItemEffect(bool)
    if bool == true then
        if self.play_effect == nil then
            local x, y = self.task_img:getPosition()
            self.play_effect = createEffectSpine("E50104", cc.p(x,y), cc.p(0.5, 0.5), true, PlayerAction.action_1)
            -- self.play_effect:setScale(scale)
            self.container:addChild(self.play_effect, 1)
        end    
    else
        if self.play_effect then 
            self.play_effect:setVisible(false)
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    end
end

function MainUiNoticeView:DeleteMe()
    if self.load_resources then
        self.load_resources:DeleteMe()
        self.load_resources = nil
    end
    self:showItemEffect(false)
    doStopAllActions(self.container)
    if self.update_quest_finish_event then
        GlobalEvent:getInstance():UnBind(self.update_quest_finish_event)
        self.update_quest_finish_event = nil
    end
    if self.update_feat_finish_event then
        GlobalEvent:getInstance():UnBind(self.update_feat_finish_event)
        self.update_feat_finish_event = nil
    end
    if self.update_exp_finish_event then
        GlobalEvent:getInstance():UnBind(self.update_exp_finish_event)
        self.update_exp_finish_event = nil
    end
    if not tolua.isnull(self) then
        self:removeAllChildren()
        self:removeFromParent()
    end
end