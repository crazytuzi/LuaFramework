require "Core.Module.Common.UITableList";
require "Core.Module.Task.View.Item.TaskFloatItem";

TaskFloatPanelControll = class("TaskFloatPanelControll");
local insert = table.insert


function TaskFloatPanelControll:Init(transform)
    self._transform = transform;
    self._gameObject = transform.gameObject;
    self:_InitReference();
end

function TaskFloatPanelControll:Show()
    -- self._gameObject:SetActive(true);
    SetUIEnable(self._transform, true)
    MessageManager.AddListener(TaskManager, TaskNotes.TASK_UPDATE, TaskFloatPanelControll._UpdateDisplay, self);
    MessageManager.AddListener(TaskManager, TaskNotes.TASK_STATUS_FINISH, TaskFloatPanelControll._OnTaskFinish, self);
    MessageManager.AddListener(TaskManager, TaskNotes.TASK_END, TaskFloatPanelControll._OnTaskEnd, self);
    MessageManager.AddListener(TodoManager, TodoManager.ENV_TODO_CHG, TaskFloatPanelControll._UpdateDisplay, self);
    MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, TaskFloatPanelControll._OnBagChg, self);
    MessageManager.AddListener(TaskManager, TaskNotes.ENV_TASK_ITEM_CHG, TaskFloatPanelControll._UpdateItemStatus, self);
    
    self:_UpdateDisplay();
    self.showing = true;
end

function TaskFloatPanelControll:Close()
    self.showing = false;    
    SetUIEnable(self._transform, false)
    --    self._gameObject:SetActive(false);

    self:RemoveListeners();
end

function TaskFloatPanelControll:_InitReference()
    -- self._taskPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "task_phalanx", true);
    -- self._taskPhalanx = Phalanx:New();
    -- self._taskPhalanx:Init(self._taskPhalanxInfo, TaskFloatItem);
    self._trsList = UIUtil.GetChildByName(self._transform, "Transform", "trsList");
    self._list = UITableList.New();
    self._list:Init(self._trsList, ResID.UI_TaskFloatItem, TaskFloatItem);

    self._effTaskFinish = UIUtil.GetChildByName(self._transform, "Transform", "ui_task_finish");
    if self._effTaskFinish then
        self._effTaskFinish.gameObject:SetActive(false);
    end
end

function TaskFloatPanelControll:Dispose()
    self._gameObject = nil;
    self._transform = nil;

    self:RemoveListeners();
    self._list:Dispose();
end

function TaskFloatPanelControll:RemoveListeners()
    MessageManager.RemoveListener(TaskManager, TaskNotes.TASK_UPDATE, TaskFloatPanelControll._UpdateDisplay);
    MessageManager.RemoveListener(TaskManager, TaskNotes.TASK_STATUS_FINISH, TaskFloatPanelControll._OnTaskFinish);
    MessageManager.RemoveListener(TaskManager, TaskNotes.TASK_END, TaskFloatPanelControll._OnTaskEnd);
    MessageManager.RemoveListener(TodoManager, TodoManager.ENV_TODO_CHG, TaskFloatPanelControll._UpdateDisplay);
    MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, TaskFloatPanelControll._OnBagChg);
    MessageManager.RemoveListener(TaskManager, TaskNotes.ENV_TASK_ITEM_CHG, TaskFloatPanelControll._UpdateItemStatus);
end

function TaskFloatPanelControll:_UpdateDisplay()
    if (self._gameObject and self._gameObject.activeSelf) then
        local data = TodoManager.GetTodoList();
        local task = TaskManager.GetAllTaskList();
        for i, v in ipairs(task) do
            insert(data, v);
        end
        -- local count = table.getn(data);
        -- self._taskPhalanx:Build(count, 1, data);
        self._list:Build(data);
    end
end

function TaskFloatPanelControll:_OnTaskFinish(id)
    
    self:_PlayFinishEff();

    --[[
    local items = self._list:GetItems();
    for i, v in ipairs(items) do
        local item = v.itemLogic;
        if item._data.id == id then
            item:ShowFinishEffect();
            break;
        end
    end
    ]]
end

function TaskFloatPanelControll:_OnTaskEnd(taskId)
    local cfg = TaskManager.GetConfigById(taskId);
    if cfg.type == TaskConst.Type.BRANCH then
        self:_PlayFinishEff();
    end
end

function TaskFloatPanelControll:_PlayFinishEff()
    if self._effTaskFinish.gameObject.activeSelf then
        self._effTaskFinish.gameObject:SetActive(false);
    end
    self._effTaskFinish.gameObject:SetActive(true);
end

function TaskFloatPanelControll:_OnBagChg()
    local items = self._list:GetItems();
    for i, v in ipairs(items) do
        local item = v.itemLogic;
        item:OnBagChg();
    end
end

function TaskFloatPanelControll:_UpdateItemStatus()
    local items = self._list:GetItems();
    for i, v in ipairs(items) do
        local item = v.itemLogic;
        item:UpdateItemStatus();
    end
end

