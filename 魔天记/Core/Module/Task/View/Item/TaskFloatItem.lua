TaskFloatItem = class("TaskFloatItem");

local color = {
    [1] = { ["tc"] = Color.New(228 / 255, 249 / 255, 255 / 255), ["bc"] = Color.New(133 / 255, 219 / 255, 255 / 255), ["ec"] = Color.New(79 / 255, 101 / 255, 277 / 255, 50 / 255) },
    [2] = { ["tc"] = Color.New(255 / 255, 255 / 255, 255 / 255), ["bc"] = Color.New(255 / 255, 237 / 255, 116 / 255), ["ec"] = Color.New(255 / 255, 120 / 255, 0 / 255, 50 / 255) },
    [3] = { ["tc"] = Color.New(255 / 255, 255 / 255, 255 / 255), ["bc"] = Color.New(255 / 255, 237 / 255, 116 / 255), ["ec"] = Color.New(255 / 255, 120 / 255, 0 / 255, 50 / 255) },
    [4] = { ["tc"] = Color.New(255 / 255, 255 / 255, 255 / 255), ["bc"] = Color.New(255 / 255, 237 / 255, 116 / 255), ["ec"] = Color.New(255 / 255, 120 / 255, 0 / 255, 50 / 255) },
    [5] = { ["tc"] = Color.New(236 / 255, 255 / 255, 228 / 255), ["bc"] = Color.New(88 / 255, 255 / 255, 66 / 255), ["ec"] = Color.New(30 / 255, 142 / 255, 4 / 255, 50 / 255) },
    [20] = { ["tc"] = Color.New(228 / 255, 249 / 255, 255 / 255), ["bc"] = Color.New(133 / 255, 219 / 255, 255 / 255), ["ec"] = Color.New(79 / 255, 101 / 255, 277 / 255, 50 / 255) },
}


function TaskFloatItem:Init(transform, data)
    self.transform = transform;
    self:_Init();
end

function TaskFloatItem:_Init()
    self._boxCollider = UIUtil.GetComponent(self.transform, "BoxCollider");
    self._bg = UIUtil.GetChildByName(self.transform, "UISprite", "bg");

    self._trsHolder = UIUtil.GetChildByName(self.transform, "Transform", "trsHolder");

    local txts = UIUtil.GetComponentsInChildren(self.transform, "UILabel");
    self._txtTaskType = UIUtil.GetChildInComponents(txts, "txtTaskType");
   

    self._txtTaskName = UIUtil.GetChildInComponents(txts, "txtTaskName");
    self._txtTaskStatus = UIUtil.GetChildInComponents(txts, "txtTaskStatus");

    self._trsItem = UIUtil.GetChildByName(self.transform, "Transform", "trsItem");
    self._trsItemIcon = UIUtil.GetChildByName(self._trsItem, "UISprite", "icon");
    self._taskItem = PropsItem.New();
    self._taskItem:Init(self._trsItem.gameObject);

    self._itemClick = function(go) self:_OnItemClick(); end;
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._itemClick);

    self._icoPay = UIUtil.GetChildByName(self.transform, "Transform", "icoPay");
    self._payClick = function(go) self:_OnPayClick(); end;
    UIUtil.GetComponent(self._icoPay, "LuaUIEventListener"):RegisterDelegate("OnClick", self._payClick);
    self._icoPay.gameObject:SetActive(false);

    self._effTaskActive = UIUtil.GetChildByName(self.transform, "UIWidget", "ui_task_new");
    --self._effTaskFinish = UIUtil.GetChildByName(self.transform, "Transform", "ui_task_finish");

    self._needAnchorEffect = true;

    self._effTaskActive.gameObject:SetActive(false);
    --self._effTaskFinish.gameObject:SetActive(false);
    --UpdateBeat:Add(self.OnUpdate, self)

    self._msgTips = UIUtil.GetChildByName(self.transform, "Transform", "msg");
    self._msgTips.gameObject:SetActive(false);
end

function TaskFloatItem:Dispose()
    self:_Dispose();
end

function TaskFloatItem:_Dispose()
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._itemClick = nil;

    UIUtil.GetComponent(self._icoPay, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._payClick = nil;

    self._taskItem:Dispose();

    --UpdateBeat:Remove(self.OnUpdate, self)
end

function TaskFloatItem:AdjustSize()
    local w = self._boxCollider.size.x;
    local textHeight = self._txtTaskStatus.height;
    local h = 30 - self._txtTaskStatus.transform.localPosition.y + textHeight + 5;

    self._boxCollider.center = Vector3.New(0, -(h - 60) / 2, 0);
    self._boxCollider.size = Vector3.New(w, h, 1);
    --self._bg.widht = w;
    self._bg.height = h;
    self._effTaskActive.height = h;
end

function TaskFloatItem:UpdateItem(data)
    self._data = data;
    if data then
        if data.__cname == "TaskInfo" then
            self.transform.gameObject.name = data.id;
            --任务标签 标签
            local task = data;
            local config = task:GetConfig();
            local name = "";
            if task.type == TaskConst.Type.REWARD then
                name = LanguageMgr.GetColor(config.quality, config.name);
            elseif task.type == TaskConst.Type.DAILY then
                name = config.name .. LanguageMgr.Get("task/name/daily", {num = TaskManager.data.dailyNum});
            else
                name = config.name;
            end
            
            local str = name .. " " .. LanguageMgr.Get("task/st/ti/"..task.status);
            self._txtTaskName.text = str;
            
            self:UpdateTaskType();
            --获取状态内容文本
            local statusStr = "";
            if(task.status == TaskConst.Status.UNACCEPTABLE)then
                statusStr = LanguageMgr.Get("task/st/0", {lv = config.min_lev});
            elseif (task.status == TaskConst.Status.IMPLEMENTATION) then 
                statusStr = TaskUtils.GetTaskDesc(task,config);
            elseif (task.status == TaskConst.Status.FINISH) then
                if (task.type == TaskConst.Type.MAIN and config.auto_complete) or task.type == TaskConst.Type.DAILY or task.type == TaskConst.Type.REWARD or task.type == TaskConst.Type.GUILD then
                    statusStr = TaskUtils.GetTaskDesc(task,config);
                else
                    local npcId = config.com_npcid;
                    local npcCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_NPC)[npcId];
                    local mapCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP)[npcCfg.map];
                    statusStr = LanguageMgr.Get("task/st/2", { npc = npcCfg.name, map = mapCfg.name});
                end
            end

            self._txtTaskStatus.text = "[bccbff]".. statusStr .."[-]";

            self:UpdateItemStatus();

            local exItem = nil;
            if config.product_icon > 0 then
                exItem = ProductInfo:New()
                exItem:Init( { spId = config.product_icon, am = 1 });
            elseif config.product_icon == -1 then
                exItem = TaskUtils.GetTaskCareerAwrad(task);
            end

            if exItem then
                self._taskItem:UpdateItem(exItem);
                self._taskItem:SetVisible(true);
            else
                self._taskItem:SetVisible(false);
            end

            local showPay = false;
            if task.status == TaskConst.Status.IMPLEMENTATION then
                showPay = config.canfly_ing;
            elseif task.status == TaskConst.Status.FINISH then
                showPay = config.canfly_end;
            end

            --self._icoPay.gameObject:SetActive(showPay);
            self:SetPayIconDisplay(showPay);
        else
            self.transform.gameObject.name = "0";
            --todo 标签
            local todo = data;
            self._txtTaskName.text = LanguageMgr.Get(todo.data.label, todo.data);
            if todo.data.desc then
                self._txtTaskStatus.text = todo.data.desc;
            else
                self._txtTaskStatus.text = LanguageMgr.Get("task/todo/desc/" .. todo.type, todo.data, true);
            end

            self:UpdateTaskType();

            self._effTaskActive.gameObject:SetActive(false);
            --self._effTaskFinish.gameObject:SetActive(false);

            self._taskItem:SetVisible(false);

            self._lastTaskSt = -1;

            --self._icoPay.gameObject:SetActive(false);
            self:SetPayIconDisplay(false);
        end
    --else
        --data is nil
    end

    self:UpdateMsgTips();

    self:AdjustSize();
    
end

function TaskFloatItem:SetPayIconDisplay(v)
    self._icoPay.gameObject:SetActive(v);
    self._trsHolder.localPosition = v and Vector3.New(-135.5, 0, 0) or Vector3.New(-185,0,0);
end

function TaskFloatItem:UpdateTaskType()
    local t = 0;
    if self._data.__cname == "TaskInfo" then
        t = self._data.type;
    else
        local todo = self._data;
        t = todo.data.ico;
    end

    local c = color[t];
    if c then
        self._txtTaskType.text = LanguageMgr.Get("task/f/t/".. t);
        self._txtTaskType.applyGradient = true;
        self._txtTaskType.effectColor = c.ec;
        self._txtTaskType.gradientTop = c.tc;
        self._txtTaskType.gradientBottom = c.bc;
    else
        self._txtTaskType.text = "";
    end
end

function TaskFloatItem:UpdateItemStatus()
    local task = self._data;
    --主线 进行中任务显示环绕特效
    self._effTaskActive.gameObject:SetActive(task.type == TaskConst.Type.MAIN and task.isNew);
end


function TaskFloatItem:_OnItemClick(isPay)
    --[[
    if self._data.status == TaskConst.Status.FINISH and self._data.type == TaskConst.Type.REWARD then
        ModuleManager.SendNotification(TaskNotes.OPEN_REWARDTASKPANEL); 
    else
        TaskManager.Auto(self._data.id);    
    end
    ]]
    --Warning("TaskFloatItem:_OnItemClick - > " .. tostring(self._data == nil));
    if self._data == nil then
        return;
    end

    self._data.isNew = false;
    self._data.isTips = false;
    self:UpdateMsgTips();

    self._data:SetPay(isPay ~= nil);

    if self._data.__cname == "TaskInfo" then
        TaskManager.Auto(self._data.id);
    else
        TodoManager.Auto(self._data);
    end

    SequenceManager.TriggerEvent(SequenceEventType.Guide.MAINUI_TASK_AUTO, self._data.id);
    
end

local payItemId = 510000;
function TaskFloatItem:_OnPayClick()
    
    if VIPManager.CanFreePayToDoTask() then
        self:_ConfirmPayTask();
    elseif BackpackDataManager.GetProductTotalNumBySpid(payItemId) > 0 then
        MsgUtils.ShowConfirm(self, "task/payToDo", nil, TaskFloatItem._ConfirmPayTask, nil, nil, nil, nil, nil, true);
    else
        ProductGetProxy.TryShowGetUI(payItemId, nil);
    end

end

function TaskFloatItem:_ConfirmPayTask()
    self:_OnItemClick(true); 
end

function TaskFloatItem:OnBagChg()
    if self._data and self._data.tType == TaskConst.Target.COLLECT_ITEM then
        self:UpdateItem(self._data);
    end
end

function TaskFloatItem:UpdateMsgTips()
    if self._data.isTips then
        self:UpdateMsgContent();
        self._msgTips.gameObject:SetActive(true);
    elseif self._msgTips.gameObject.activeSelf then
        self._msgTips.gameObject:SetActive(false);
    end
end

function TaskFloatItem:UpdateMsgContent()
    local txt = UIUtil.GetChildByName(self._msgTips, "UILabel", "txt");
    if self._data.id == 840080 then
        txt.text = LanguageMgr.Get("guide/GuideTaskTips/1");
    else
        txt.text = "";
    end
end

--[[
function TaskFloatItem:ShowFinishEffect()
    self._effTaskFinish.gameObject:SetActive(false);
    self._effTaskFinish.gameObject:SetActive(true);
    self._playingEff = true;
    self._playingTime = 0;
end

function TaskFloatItem:EndFinishEffect()
    self._playingEff = false;
    self._effTaskFinish.gameObject:SetActive(false);
end

function TaskFloatItem:OnUpdate()
    if self._playingEff then
        self._playingTime = self._playingTime + Timer.deltaTime;
        if self._playingTime > 2 then
           self:EndFinishEffect(); 
        end
    end

    if self._needAnchorEffect then
        UIUtil.SetEffectOrder(self._effTaskFinish.gameObject, self._bg);
        self._needAnchorEffect = false;
    end
end
]]