require "Core.Module.Common.Panel";
require "Core.Module.Task.View.Item.RewardTaskItem";

RewardTaskPanel = Panel:New()

function RewardTaskPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    
    self:UpdateDisplay();
end

function RewardTaskPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtBuyTime = UIUtil.GetChildInComponents(txts, "txtBuyTime");
	self._txtRefresh = UIUtil.GetChildInComponents(txts, "txtRefresh");

    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnClose = UIUtil.GetChildInComponents(btns, "btnClose");
	self._btnBuyTime = UIUtil.GetChildInComponents(btns, "btnBuyTime");
    self._btnRefresh = UIUtil.GetChildInComponents(btns, "btnRefresh");

    self._trsScrollView = UIUtil.GetChildByName(self._trsContent, "Transform", "taskListView");
    self._taskPhalanxInfo = UIUtil.GetChildByName(self._trsScrollView, "LuaAsynPhalanx", "task_phalanx", true);
    self._taskPhalanx = Phalanx:New();

    self._taskPhalanx:Init(self._taskPhalanxInfo, RewardTaskItem);

    _time = os.time();

    UpdateBeat:Add(self.OnUpdate, self);
end

function RewardTaskPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	self._onClickBtnBuyTime = function(go) self:_OnClickBtnBuyTime(self) end
	UIUtil.GetComponent(self._btnBuyTime, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBuyTime);
    self._onClickBtnRefresh = function(go) self:_OnClickBtnRefresh(self) end
	UIUtil.GetComponent(self._btnRefresh, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRefresh);
    
    MessageManager.AddListener(TaskManager, TaskNotes.TASK_UPDATE, RewardTaskPanel.UpdateList, self);
    MessageManager.AddListener(TaskManager, TaskNotes.TASK_REWARD_CHANCE, RewardTaskPanel.UpdateCount, self);
    MessageManager.AddListener(TaskNotes, TaskNotes.TASK_REWARD_ITEM_DO, RewardTaskPanel.OnItemDo, self);
    
end

function RewardTaskPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function RewardTaskPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	UIUtil.GetComponent(self._btnBuyTime, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnBuyTime = nil;
    UIUtil.GetComponent(self._btnRefresh, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnRefresh = nil;
    
    MessageManager.RemoveListener(TaskManager, TaskNotes.TASK_UPDATE, RewardTaskPanel.UpdateList);
    MessageManager.RemoveListener(TaskManager, TaskNotes.TASK_REWARD_CHANCE, RewardTaskPanel.UpdateCount);
    MessageManager.RemoveListener(TaskNotes, TaskNotes.TASK_REWARD_ITEM_DO, RewardTaskPanel.OnItemDo);
end

function RewardTaskPanel:_DisposeReference()
    UpdateBeat:Remove(self.OnUpdate, self);

    self._taskPhalanx:Dispose();
end

function RewardTaskPanel:OnItemDo()
    self:_OnClickBtnClose();
    ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
end

function RewardTaskPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(TaskNotes.CLOSE_REWARDTASKPANEL);
end

function RewardTaskPanel:_OnClickBtnBuyTime()
    MsgUtils.UseBDGoldConfirm(20, self, "task/reward/payChance", nil, RewardTaskPanel.OnBuyChance);
end

function RewardTaskPanel:OnBuyChance()
    TaskProxy.ReqRewardBuyTime();
end

function RewardTaskPanel:_OnClickBtnRefresh()
    MsgUtils.UseBDGoldConfirm(20, self, "task/reward/payRefresh", nil, RewardTaskPanel.OnRefresh);
end

function RewardTaskPanel:OnRefresh()
    TaskProxy.ReqRewardRefresh();
end

function RewardTaskPanel:OnUpdate()
    self:UpdateTime();
end

function RewardTaskPanel:UpdateDisplay()
    self:UpdateCount();
    self:UpdateList();
end

function RewardTaskPanel:UpdateCount()
    self.data = TaskManager.data;
    self._txtBuyTime.text = LanguageMgr.Get("task/reward/chance", {num = self.data.rewardNum});
end

local _time = 0;
function RewardTaskPanel:UpdateTime()
    if(self.data == nil) then
        return;
    end

    local time = math.max(self.data.rewardTime - GetGameTime(), 0);
    local timeStr = TimeUtil.SecondToHourMinSecString(time);
    self._txtRefresh.text = LanguageMgr.Get("task/reward/time", {time = timeStr});
end

function RewardTaskPanel:UpdateList()
    local rewardList = TaskManager.GetRewardList();
    local count = table.getn(rewardList);
    if count > 0 then
        self._taskPhalanx:Build(count, 1, rewardList);    
    else
        self._taskPhalanx:Build(1,1,{});
    end
    SequenceManager.TriggerEvent(SequenceEventType.Guide.REWARD_TASK_UPDATE);
end

