-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      日常主界面，包含了任务和成就
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
TaskMainWindow = TaskMainWindow or BaseClass(BaseView)

function TaskMainWindow:__init()
    self.ctrl = TaskController:getInstance()
    self.model = self.ctrl:getModel()
    self.win_type = WinType.Full
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("quest","quest"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("taskexp","taskexp"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("taskdaily","taskdaily"), type = ResourcesType.plist },
    }
    self.tab_info_list = {
        {label = TI18N("日常"),notice = TI18N("日常任务11级开启"),index = TaskConst.type.quest,status = true},
        {label = TI18N("成就"),notice = TI18N("日常任务15级开启"),index = TaskConst.type.feat,status = true},
        {label = TI18N("进阶历练"),notice = TI18N("日常任务15级开启"),index = TaskConst.type.exp,status = true}
    }
    self.panel_list = {}
    self.cur_panel = nil

    self.role_vo = RoleController:getInstance():getRoleVo()
end

function TaskMainWindow:open_callback()
end

function TaskMainWindow:register_event()
    self:addGlobalEvent(TaskEvent.UpdateUIRedStatus, function(key, value)
        self:updateUIRedStatus(key)
    end)

    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "lev" then
                    self:checkTabUnlockInfo(value)
                    self:updateUIRedStatus(TaskConst.update_type.exp)
                end
            end)
        end
    end
end

function TaskMainWindow:openRootWnd(index)
    index = index or TaskConst.type.quest
        
    self:checkTabUnlockInfo()

    self:setSelecteTab(index, true)
    self:updateUIRedStatus(TaskConst.update_type.feat)
    self:updateUIRedStatus(TaskConst.update_type.quest)
    self:updateUIRedStatus(TaskConst.update_type.exp)
end


function TaskMainWindow:checkTabUnlockInfo(lev)
    if not self.role_vo then return end
    local config = Config.RoomFeatData.data_const.experience_open_limit
    self.tab_info_list[TaskConst.type.exp].status = true
    if config then
        local lev = lev or self.role_vo.lev
        if lev < config.val then
            self.tab_info_list[TaskConst.type.exp].status = false 
            self:setTabBtnTouchStatus(false, TaskConst.type.exp)
            self.tab_btn_list[TaskConst.type.exp].notice = config.desc
        else
            self:setTabBtnTouchStatus(true, TaskConst.type.exp)
        end
    end
end

function TaskMainWindow:updateUIRedStatus(type)
    if type == TaskConst.update_type.feat then
        local feat_status = self.model:getRedStatus(TaskConst.update_type.feat)
        self:setTabTips(feat_status, TaskConst.type.feat)
    elseif type == TaskConst.update_type.exp then
        local status = false
        if self.tab_info_list[TaskConst.type.exp].status then
            status = self.model:getRedStatus(TaskConst.update_type.exp)
        end
        self:setTabTips(status, TaskConst.type.exp)
    else
        local task_status = self.model:getRedStatus(TaskConst.update_type.quest)
        if task_status == false then
            task_status = self.model:getRedStatus(TaskConst.update_type.activity)
        end
        self:setTabTips(task_status, TaskConst.type.quest)
    end
end

function TaskMainWindow:selectedTabCallBack(index)
    if index == TaskConst.type.exp and not self.tab_info_list[index].status then
        return 
    end

    if index == TaskConst.type.quest then
        self:changeTitleName(TI18N("日常"))
    elseif index == TaskConst.type.feat then
        self:changeTitleName(TI18N("成就"))
    elseif index == TaskConst.type.exp then
        self:changeTitleName(TI18N("进阶历练"))
    end

    self:changePanel(index)
end

function TaskMainWindow:changePanel(index)
    if self.cur_panel ~= nil then
        self.cur_panel:addToParent(false)
        self.cur_panel = nil
    end
    if self.panel_list[index] == nil then
        if index == TaskConst.type.quest then
            self.panel_list[index] = TaskPanel.new(self.ctrl)
        elseif index == TaskConst.type.feat then
            self.panel_list[index] = FeatPanel.new(self.ctrl)
        elseif index == TaskConst.type.exp then
            self.panel_list[index] = TaskExpPanel.new()
        end
        self.container:addChild(self.panel_list[index])
    end
    self.cur_panel = self.panel_list[index]
    if self.cur_panel ~= nil then
        self.cur_panel:addToParent(true)
    end
end

function TaskMainWindow:close_callback()
    for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end

    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
        self.role_vo = nil
    end

    self.panel_list = nil
    self.ctrl:openTaskMainWindow(false)
end
