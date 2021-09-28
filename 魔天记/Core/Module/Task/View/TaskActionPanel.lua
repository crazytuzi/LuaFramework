require "Core.Module.Common.Panel";

TaskActionPanel = Panel:New()

function TaskActionPanel:IsPopup()
    return false;
end

function TaskActionPanel:IsFixDepth()
    return true;
end

function TaskActionPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function TaskActionPanel:GetUIOpenSoundName( )
    return ""
end

function TaskActionPanel:_InitReference()    
    self._trsTips = UIUtil.GetChildByName(self._trsContent, "Transform", "trsTips");
	self._btnAction = UIUtil.GetChildByName(self._trsTips, "UIButton", "btnAction");
    self._trsItem = UIUtil.GetChildByName(self._trsTips, "Transform", "trsItem");
    self._txtName = UIUtil.GetChildByName(self._trsTips, "UILabel", "txtName");
    self._txtAction = UIUtil.GetChildByName(self._btnAction, "UILabel", "txtAction");

    self._progress = UIUtil.GetChildByName(self._trsContent, "UISlider", "progress");
    self._txtProgress = UIUtil.GetChildByName(self._progress, "UILabel", "txtProgress");

    self._item = PropsItem:New();
    self._item:Init(self._trsItem, nil);

    self._autoTime = 0;

    self._time = 0;
    self._curTime = 0;
    self._doing = false;
    self._progress.value = 0;
    self._progress.gameObject:SetActive(false);

    UpdateBeat:Add(self.OnUpdate, self);
end

function TaskActionPanel:_InitListener()
    self._onClickAction = function(go) self:_OnClickBtnAction(self) end
	UIUtil.GetComponent(self._btnAction, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickAction);
end

function TaskActionPanel:SetData(data, param)
    self._data = data;
    self._param = param;
    self._task = TaskManager.GetTaskById(data);
    local cfg = self._task:GetConfig();
    self._cfg = cfg;

    local itemId = 0;
    if cfg.target_type == TaskConst.Target.USE_ITEM then
        itemId = tonumber(cfg.target[1]);
    elseif cfg.target_type == TaskConst.Target.COLLECT or cfg.target_type == TaskConst.Target.VACTION then
        itemId = tonumber(cfg.target[2]);
    end
    
    local item = ProductInfo:New();
    item:Init({spId = itemId, am = 1});

    self._item:UpdateItem(item);
    self._txtName.text = LanguageMgr.GetColor(item:GetQuality(), item:GetName());

    local title = cfg.targetParam[1];
    self._txtAction.text = title;
    self._txtProgress.text = LanguageMgr.Get("task/action/title", {title = title});

    self._time = cfg.targetParam[2] and tonumber(cfg.targetParam[2]) or 0;
end

function TaskActionPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function TaskActionPanel:_DisposeReference()

    UpdateBeat:Remove(self.OnUpdate, self);

    if self._doing == true then
        self._doing = false;
    end
    self._item:Dispose();
    self._onClickAction = nil;
    self._btnAction = nil;
end

function TaskActionPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnAction, "LuaUIEventListener"):RemoveDelegate("OnClick");
end

function TaskActionPanel:_OnClickBtnAction()
    self:TryDoAction();
end

function TaskActionPanel:TryDoAction()
    if self._time > 0  then
        self._progress.gameObject:SetActive(true);
        self._trsTips.gameObject:SetActive(false);
        if self._doing == false then
            self._doing = true;
        end
        self._curTime = 0;

        if self._cfg.target_type == TaskConst.Target.COLLECT then
            local role = HeroController.GetInstance();
            role:Play("cast01");
        end

    else
        self:_ActionComplete();
    end
end

function TaskActionPanel:OnUpdate()

    if self._doing then
        if(self._curTime < self._time) then 
            self:SetProgress(self._curTime / self._time)
            self._curTime = self._curTime + Timer.deltaTime;
            return;
        end
        self:SetProgress(1);
        self:_ActionComplete();
    elseif self._autoTime and TaskManager.IsAuto() then
        --自动执行的时候 2秒后TryDoAction
        if self._autoTime > 2 then
            self:TryDoAction();
        else
            self._autoTime = self._autoTime + Timer.deltaTime;    
        end
    end
end

function TaskActionPanel:SetProgress(val)
    self._progress.value = val;
end

function TaskActionPanel:StopAction()
    if self._doing == true then
        self._doing = false;
    end
    self._progress.gameObject:SetActive(false);
    self._trsTips.gameObject:SetActive(true);

    self._autoTime = 0;
end

function TaskActionPanel:_ActionComplete()
    self:StopAction();

    SequenceManager.TriggerEvent(SequenceEventType.Base.TASK_ACTION, self._data);

    if self._cfg.target_type == TaskConst.Target.COLLECT then
        local role = HeroController.GetInstance();
        role:Stand();

        local obj = GameSceneManager.map:GetSceneObjById(self._param);
        if obj then
            obj:Finish();
        end
    end

    SequenceManager.TriggerEvent(SequenceEventType.Base.TASK_ACTION_UPDATE);
end
