require "Core.Module.Common.Panel";
require "Core.Module.Common.PropsItem";
require "Core.Module.Task.View.Item.TaskItem";

TaskPanel = Panel:New()

TaskPanel.Mode = {
    Main = 1;
    DailyAcc = 2;
    Daily = 3;
    --Reward = 4;
}

function TaskPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function TaskPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtDescTitle = UIUtil.GetChildInComponents(txts, "txtDescTitle");
	self._txtDesc = UIUtil.GetChildInComponents(txts, "txtDesc");
	self._txtAwardTitle = UIUtil.GetChildInComponents(txts, "txtAwardTitle");
    self._txtProgress = UIUtil.GetChildInComponents(txts, "txtProgress");

	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnClose = UIUtil.GetChildInComponents(btns, "btnClose");
	self._btnGoNow = UIUtil.GetChildInComponents(btns, "btnGoNow");
    self._btnTest = UIUtil.GetChildInComponents(btns, "btnTest");

    self._btnAccess = UIUtil.GetChildInComponents(btns, "btnAccess");

    local trss = UIUtil.GetComponentsInChildren(self._gameObject, "Transform");
    self._trsDetailView = UIUtil.GetChildInComponents(trss, "taskDetailView");
    
    self._taskPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "task_phalanx", true);
    self._taskPhalanx = Phalanx:New();
    self._taskPhalanx:Init(self._taskPhalanxInfo, TaskItem);

    self._awardPhalanxInfo = UIUtil.GetChildByName(self._trsDetailView, "LuaAsynPhalanx", "product_phalanx", true);
    self._awardPhalanx = Phalanx:New();
    self._awardPhalanx:Init(self._awardPhalanxInfo, PropsItem);

end

function TaskPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	self._onClickBtnGonow = function(go) self:_OnClickBtnGonow(self) end
	UIUtil.GetComponent(self._btnGoNow, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGonow);

    MessageManager.AddListener(TaskItem, TaskNotes.TASK_ITEM_SELECTED, TaskPanel.OnItemClick, self);
    MessageManager.AddListener(TaskManager, TaskNotes.TASK_UPDATE, TaskPanel.UpdateDisplay, self);
end

function TaskPanel:_OnClickBtnClose()
    SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(TaskNotes.CLOSE_TASKPANEL);
end

function TaskPanel:_OnClickBtnGonow()
    if self._selectData then
        local id = self._selectData.id;
        self:_OnClickBtnClose();
        ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
        TaskManager.Auto(id);
    end
end

function TaskPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function TaskPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	UIUtil.GetComponent(self._btnGoNow, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGonow = nil;

    MessageManager.RemoveListener(TaskItem, TaskNotes.TASK_ITEM_SELECTED, TaskPanel.OnItemClick);
    MessageManager.RemoveListener(TaskManager, TaskNotes.TASK_UPDATE, TaskPanel.UpdateDisplay);
end

function TaskPanel:_DisposeReference()
    self._selectId = 0;

	self._btnClose = nil;
	self._btnGoNow = nil;
    self._btnTest = nil;

    self._taskPhalanx:Dispose();
    self._taskPhalanx = nil;
    self._awardPhalanx:Dispose();
    self._awardPhalanx = nil;
end

function TaskPanel:SetSelectType(type)
    self._selectType = type;
end

function TaskPanel:_Opened()
    self:UpdateDisplay();
end

function TaskPanel:UpdateDisplay()
    local data = TaskManager.GetTaskList();
    local count = table.getn(data);
    self._taskPhalanx:Build(count, 1, data);

    if (count > 0) then
        local d = nil;
        for i,v in ipairs(data) do
            if (self._selectType == v.type) then
                d = v;
                break;
            end
        end

        if d == nil then 
            d = data[1];
        end

        self:UpdateSelect(d);
    else
        self._selectData = nil;
        self:UpdateSelect(nil);
    end
end

function TaskPanel:OnItemClick(data)
    --选择以后重置选择类型.更新数据时 优先显示选择类型的任务. 因为后端在任务结束的一瞬间 并没有接取到新任务.
    self._selectType = data.type;
    self:UpdateSelect(data);   
    SequenceManager.TriggerEvent(SequenceEventType.Guide.TASK_ITEM_CLICK, data.type);
end

function TaskPanel:UpdateSelect(data)
    local items = self._taskPhalanx:GetItems();
    for i,v in ipairs(items) do
        local item = v.itemLogic;
        if item.data.id == data.id then
            item:UpdateSelected(true);
        else
            item:UpdateSelected(false);
        end
    end
    
    if self._selectData ~= data then
        self._selectData = data;
        self:UpdateDetail();
    end
    
end

function TaskPanel:UpdateDetail()
    if (self._selectData ~= nil) then
        self._trsDetailView.gameObject:SetActive(true);
        self._task = self._selectData;--TaskManager.GetTaskById(self._selectId);
        if (self._task) then
            local config = self._task:GetConfig();
            self._txtDesc.text = config.task_des;
            
            local awards = TaskUtils.GetTaskAward(self._task);
            self._awardPhalanx:Build(1, 5, awards);

            if self._task.type == TaskConst.Type.MAIN then
                self:UpdateBtns(TaskPanel.Mode.Main);
                self._txtProgress.text = "";
            elseif self._task.type == TaskConst.Type.DAILY then
                --[[
                if(self._task.st == TaskConst.Status.UNACCEPTABLE) then
                    self:UpdateBtns(TaskPanel.Mode.DailyAcc);
                end
                ]]
                self:UpdateBtns(TaskPanel.Mode.Daily);
                self._txtProgress.text = LanguageMgr.Get("task/progress", {num = TaskManager.data.dailyNum});
            --elseif self._task.type == TaskConst.Type.REWARD then
            --    self:UpdateBtns(TaskPanel.Mode.Reward);
            --    self._txtProgress.text = "";
            end
        end
    else
        --no task detail
        self._trsDetailView.gameObject:SetActive(false);
    end
end

function TaskPanel:UpdateBtns(mode)
    if self.btnMode ~= mode then
        self.btnMode = mode;

        if mode == TaskPanel.Mode.Main then
            self._btnGoNow.gameObject:SetActive(true);
            self._btnAccess.gameObject:SetActive(false);

        elseif mode == TaskPanel.Mode.DailyAcc then
            self._btnGoNow.gameObject:SetActive(false);
            self._btnAccess.gameObject:SetActive(true);

        elseif mode == TaskPanel.Mode.Daily then
            self._btnGoNow.gameObject:SetActive(true);
            self._btnAccess.gameObject:SetActive(false);
        --[[
        elseif mode == TaskPanel.Mode.Reward then
            self._btnGoNow.gameObject:SetActive(true);
            self._btnAccess.gameObject:SetActive(false);
        ]]
        end
        
    end
end
