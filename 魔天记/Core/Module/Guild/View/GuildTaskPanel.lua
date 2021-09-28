require "Core.Module.Common.Panel";
require "Core.Module.Guild.View.Item.GuildTaskItem";

GuildTaskPanel = Panel:New();

function GuildTaskPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function GuildTaskPanel:_InitReference()
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btnGetNum = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnGetNum");
    self._btnGetNum.gameObject:SetActive(false);

    self._trsInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo");
    self._txtDesc = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtDesc");
    self._txtDkp = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleDkp/txtDkp");
    self._txtDkpDay = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleDkpDay/txtDkpDay");
    self._txtHelpNum = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleHelpNum/txtHelpNum");
	self._txtNum = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleNum/txtNum");

    self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildTaskItem);

end

function GuildTaskPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

    self._onClickBtnGetNum = function(go) self:_OnClickBtnGetNum(self) end
    UIUtil.GetComponent(self._btnGetNum, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGetNum);

    MessageManager.AddListener(TaskManager, TaskNotes.TASK_UPDATE, GuildTaskPanel.UpdateList, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.ENV_TASK_DATA_CHG, GuildTaskPanel.UpdateInfo, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_TASK_HELP, GuildTaskPanel.UpdateList, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_MOBAI_TASKNUM, GuildTaskPanel.UpdateTaskNum, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_MOBAI_GETNUM, GuildTaskPanel.OnGetNum, self);
    
     
end

function GuildTaskPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildTaskPanel:_DisposeReference()
    self._phalanx:Dispose();
end

function GuildTaskPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

    UIUtil.GetComponent(self._btnGetNum, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGetNum = nil;

    MessageManager.RemoveListener(TaskManager, TaskNotes.TASK_UPDATE, GuildTaskPanel.UpdateList);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_TASK_DATA_CHG, GuildTaskPanel.UpdateInfo);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_TASK_HELP, GuildTaskPanel.UpdateList);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_MOBAI_TASKNUM, GuildTaskPanel.UpdateTaskNum);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_MOBAI_GETNUM, GuildTaskPanel.OnGetNum);
end

function GuildTaskPanel:_Opened()
	self._txtDesc.text = LanguageMgr.Get("guild/desc");
    self:UpdateList();
    GuildProxy.ReqGuildMoBaiNum();
end

function GuildTaskPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILD_OTHER_PANEL, GuildNotes.OTHER.TASK);
    ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
end

function GuildTaskPanel:UpdateList()
    local list = TaskManager.GetGuildList();
    local count = #list;
    self._phalanx:Build(count, 1, list);
    self:UpdateInfo();
end

function GuildTaskPanel:UpdateInfo()
	local gInfo = GuildDataManager.info;
    self._txtDkp.text = gInfo.dkpAll - gInfo.dkpUse;
    self._txtDkpDay.text = gInfo.dkpDay;
    self._txtHelpNum.text = LanguageMgr.Get("common/numMax", {num = TaskManager.data.guildHelp, max = 3});
	self._txtNum.text = LanguageMgr.Get("common/numMax", {num = TaskManager.data.guildNum, max = TaskManager.data.guildMax});
end

function GuildTaskPanel:UpdateTaskNum(data)
    
    self._btnGetNum.gameObject:SetActive(data.task - data.tec > 0);
end

function GuildTaskPanel:_OnClickBtnGetNum()
    GuildProxy.ReqTaskGetMoBaiNum();
end

function GuildTaskPanel:OnGetNum()
    self._btnGetNum.gameObject:SetActive(false);
end
