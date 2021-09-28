require "Core.Module.Common.Panel"

require "Core.Manager.Item.ActivityDataManager";

require "Core.Module.Activity.controlls.ActivityBottomPanelCtr"
require "Core.Module.Activity.controlls.RiChangActivityPanelCtr"
require "Core.Module.Activity.controlls.RiChangFBPanelCtr"
require "Core.Module.Activity.controlls.TimeActivityPanelCtr"

ActivityPanel = class("ActivityPanel", Panel);
function ActivityPanel:New()
	self = {};
	setmetatable(self, {__index = ActivityPanel});
	return self
end


function ActivityPanel:_Init()
	
	ActivityDataManager.Init();
	self:_InitReference();
	self:_InitListener();
end

function ActivityPanel:_InitReference()
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
	self._btnRiChangActivity = UIUtil.GetChildInComponents(btns, "btnRiChangActivity");
	self._btnRiChangFB = UIUtil.GetChildInComponents(btns, "btnRiChangFB");
	self._btnTimeActivity = UIUtil.GetChildInComponents(btns, "btnTimeActivity");
	
	self.btn_help = UIUtil.GetChildInComponents(btns, "btn_help");
	self.btnZL = UIUtil.GetChildInComponents(btns, "btnZL");
	
	self.txtOffLine = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtOffLine");
	self.btnOffLine = UIUtil.GetChildInComponents(btns, "btnOffLine");
	
	self._trsToggle = UIUtil.GetChildByName(self._trsContent, "Transform", "trsToggle");
	
	
	self.tab1Point = UIUtil.GetChildByName(self._trsToggle, "UISprite", "btnRiChangActivity/npoint");
	self.tab2Point = UIUtil.GetChildByName(self._trsToggle, "UISprite", "btnRiChangFB/npoint");
	self.tab3Point = UIUtil.GetChildByName(self._trsToggle, "UISprite", "btnTimeActivity/npoint");
	
	self.noticeParent = UIUtil.GetChildByName(self._trsContent, "Transform", "noticeParent");
	self._goNoticeMask = UIUtil.GetChildByName(self.noticeParent, "Transform", "mask");
	
	self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");
	--self.tipPanel = UIUtil.GetChildByName(self.mainView, "Transform", "tipPanel");
	--self.infosPanelCtr = InfosPanelCtr:New();
	--self.infosPanelCtr:Init(self.tipPanel)
	
	self.hyIcon = UIUtil.GetChildByName(self.mainView, "Transform", "hyIcon");
	self.hyvalueTxt = UIUtil.GetChildByName(self.hyIcon, "UILabel", "valueTxt");
	
	self._riChangActivityPanel = UIUtil.GetChildByName(self.mainView, "Transform", "RiChangActivityPanel");
	self._riChangFBPanel = UIUtil.GetChildByName(self.mainView, "Transform", "RiChangFBPanel");
	self._timeActivityPAnel = UIUtil.GetChildByName(self.mainView, "Transform", "TimeActivityPAnel");
	self._bottomPanel = UIUtil.GetChildByName(self.mainView, "Transform", "bottomPanel");
	
	
	
	self.riChangActivityPanelCtr = RiChangActivityPanelCtr:New();
	self.riChangActivityPanelCtr:Init(self._riChangActivityPanel);
	
	self.riChangFBPanelCtr = RiChangFBPanelCtr:New();
	self.riChangFBPanelCtr:Init(self._riChangFBPanel);
	
	self.timeActivityPanelCtr = TimeActivityPanelCtr:New();
	self.timeActivityPanelCtr:Init(self._timeActivityPAnel);
	
	self.activityBottomPanelCtr = ActivityBottomPanelCtr:New();
	self.activityBottomPanelCtr:Init(self._bottomPanel);
	
	
	-- self:OpenSubPanel(ActivityNotes.PANEL_RICHANGACTIVITY);
	FixedUpdateBeat:Add(self.UpTime, self);
	ActivityProxy.TryGetActivityData();
	
	MessageManager.AddListener(ActivityDataManager, ActivityDataManager.MESSAGE_SERVERDATA_CHANGE, ActivityPanel.ServerDataChange, self);
	MessageManager.AddListener(ActivityDataManager, ActivityDataManager.MESSAGE_SERVERDATA_AV_CHANGE, ActivityPanel.ServerAvDataChange, self);
	MessageManager.AddListener(RCActivityItem, RCActivityItem.MESSAGE_SHOWINFO, ActivityPanel.ShowItemInfo, self);
	MessageManager.AddListener(InstanceDataManager, InstanceDataManager.MESSAGE_0X0F01_CHANGE, ActivityPanel.ServerDataChange, self);
	MessageManager.AddListener(PlayerManager, PlayerManager.OffLineChg, ActivityPanel.UpdateOffLineTime, self);
	
	MessageManager.AddListener(PlayerManager, PlayerManager.SelfLevelChange, ActivityPanel._LevelChange, self)
	MessageManager.AddListener(GuildNotes, GuildNotes.RSP_NTF_LEVELUP, ActivityPanel.ServerDataChange, self)
	MessageManager.AddListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_NEED_UP_INSTREDS, ActivityPanel.ServerDataChange, self)
	MessageManager.AddListener(TaskManager, TaskNotes.TASK_REWARD_CHANCE, ActivityPanel.ServerDataChange, self)
	MessageManager.AddListener(PVPManager, PVPManager.MESSAGE_VIP_BUY_TIME_CHANGE, ActivityPanel.ServerDataChange, self)
	
	self:_OnClickNotice()
end



function ActivityPanel:_Opened()
	
	self:OpenSubPanel(self.tab, self.activity_id, self.needToPage)
	self:UpdateOffLineTime();
end

function ActivityPanel:OnClickOffLine()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.ACTIVITY_OFFLINE_BTN);
	MessageProxy.AddOffLineTIme();
end

local FormatTime = function(min)
   
   if min == nil then
    min =0;
   end 

	if min > 60 then
		local h = math.floor(min / 60);
		local m = math.floor(min -(h * 60));
		return LanguageMgr.Get("time/hhmm", {h = h, m = m});
		
	end
	return LanguageMgr.Get("time/mm", {m = min});
end

function ActivityPanel:UpdateOffLineTime()
	self.txtOffLine.text = LanguageMgr.Get("offline/activity/time", {time = FormatTime(PlayerManager.OffLineData.time)});
end 

-- 这个值是需要累积的
function ActivityPanel:ServerAvDataChange()
	
	self.hyvalueTxt.text = ActivityDataManager.GetAvt();
	
end

function ActivityPanel:_LevelChange()
	self:ServerDataChange();
end

function ActivityPanel:ServerDataChange()
	
	
	self.riChangActivityPanelCtr:ServerDataChange();
	self.riChangFBPanelCtr:ServerDataChange();
	self.timeActivityPanelCtr:ServerDataChange();
	self.activityBottomPanelCtr:ServerDataChange();
	
	self:ServerAvDataChange();
	
	
	local b1 = ActivityDataManager.Check_activity_type_ShowPoint(ActivityDataManager.TYPE_DAY_ACTIVITY);
	local b2 = ActivityDataManager.Check_activity_type_ShowPoint(ActivityDataManager.TYPE_DAY_FB);
	local b3 = ActivityDataManager.Check_activity_type_ShowPoint(ActivityDataManager.TYPE_TIME_ACTIVITY);
	
	
	self.tab1Point.gameObject:SetActive(b1);
	self.tab2Point.gameObject:SetActive(b2);
	self.tab3Point.gameObject:SetActive(b3);
	
end

function ActivityPanel:ShowItemInfo(data)
	
    ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY_TIP,data.id);
	
end

function ActivityPanel:UpTime()
	
	self._trsContent.gameObject:SetActive(false);
	self._trsContent.gameObject:SetActive(true);
	FixedUpdateBeat:Remove(self.UpTime, self)
end


function ActivityPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	
	self._onClickBtn_help = function(go) self:_OnClickBtn_help(self) end
	UIUtil.GetComponent(self.btn_help, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_help);
	
	self._onClickbtnZL = function(go) self:_OnClickbtnZL(self) end
	UIUtil.GetComponent(self.btnZL, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnZL);
	
	
	
	
	self._onClickNoticeMask = function(go) self:_OnClickNotice(self) end
	UIUtil.GetComponent(self._goNoticeMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickNoticeMask);
	
	self._onClickBtnOffLine = function(go) self:OnClickOffLine(self) end
	UIUtil.GetComponent(self.btnOffLine, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnOffLine);
	
	self._onClickBtnRiChangActivity = function(go) self:_OnClickBtnRiChangActivity(self) end
	UIUtil.GetComponent(self._btnRiChangActivity, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRiChangActivity);
	self._onClickBtnRiChangFB = function(go) self:_OnClickBtnRiChangFB(self) end
	UIUtil.GetComponent(self._btnRiChangFB, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRiChangFB);
	self._onClickBtnTimeActivity = function(go) self:_OnClickBtnTimeActivity(self) end
	UIUtil.GetComponent(self._btnTimeActivity, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTimeActivity);
end

function ActivityPanel:_OnClickBtn_help()
	
	self.noticeParent.gameObject:SetActive(true);
	self.noticeParentShow = true;
	
	
end

function ActivityPanel:_OnClickbtnZL()
	ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITYOPENTIMELOGPANEL);
end



function ActivityPanel:_OnClickNotice()
	
	self.noticeParent.gameObject:SetActive(false);
	self.noticeParentShow = false;
	
end

function ActivityPanel:_OnClickBtn_close()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
end

function ActivityPanel:_OnClickBtnRiChangActivity()
	self:OpenSubPanel(ActivityNotes.PANEL_RICHANGACTIVITY);
end

function ActivityPanel:_OnClickBtnRiChangFB()
	self:OpenSubPanel(ActivityNotes.PANEL_RICHANGFB);
end

function ActivityPanel:_OnClickBtnTimeActivity()
	self:OpenSubPanel(ActivityNotes.PANEL_TIMEACTIVITY);
end

function ActivityPanel:SetBtnToggleActive(btn, bool)
	local toggle = UIUtil.GetComponent(btn, "UIToggle");
	toggle.value =(bool);
end

function ActivityPanel:SetOpenSubPanel(tab, activity_id, needToPage)
	self.tab = tab;
	self.activity_id = activity_id;
	self.needToPage = needToPage;
	
	
end

function ActivityPanel:OpenSubPanel(tab, activity_id, needToPage)
	
	
	self._panelIndex = tab;
	
	
	if(tab == ActivityNotes.PANEL_RICHANGACTIVITY) then
		
		self:SetBtnToggleActive(self._btnRiChangActivity, true);
		-- self:SetBtnToggleActive(self._btnRiChangFB, false);
		-- self:SetBtnToggleActive(self._btnTimeActivity, false);
		self.riChangActivityPanelCtr:Show();
		self.riChangFBPanelCtr:Hide();
		self.timeActivityPanelCtr:Hide();
		
		self.riChangActivityPanelCtr:SetSelect(activity_id, needToPage);
		
		SequenceManager.TriggerEvent(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, 1);
		
		self.btnZL.gameObject:SetActive(false);
		
	elseif(tab == ActivityNotes.PANEL_RICHANGFB) then
		-- self:SetBtnToggleActive(self._btnRiChangActivity, false);
		self:SetBtnToggleActive(self._btnRiChangFB, true);
		-- self:SetBtnToggleActive(self._btnTimeActivity, false);
		self.riChangActivityPanelCtr:Hide();
		self.riChangFBPanelCtr:Show();
		self.timeActivityPanelCtr:Hide();
		
		self.riChangFBPanelCtr:SetSelect(activity_id, needToPage);
		
		SequenceManager.TriggerEvent(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, 2);
		
		self.btnZL.gameObject:SetActive(false);
		
	elseif(tab == ActivityNotes.PANEL_TIMEACTIVITY) then
		-- self:SetBtnToggleActive(self._btnRiChangActivity, false);
		-- self:SetBtnToggleActive(self._btnRiChangFB, false);
		self:SetBtnToggleActive(self._btnTimeActivity, true);
		
		self.riChangActivityPanelCtr:Hide();
		self.riChangFBPanelCtr:Hide();
		self.timeActivityPanelCtr:Show();
		
		self.timeActivityPanelCtr:SetSelect(activity_id, needToPage);
		SequenceManager.TriggerEvent(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, 3);
		
		self.btnZL.gameObject:SetActive(true);
	end
end




function ActivityPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function ActivityPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	UIUtil.GetComponent(self._btnRiChangActivity, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnRiChangActivity = nil;
	UIUtil.GetComponent(self._btnRiChangFB, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnRiChangFB = nil;
	UIUtil.GetComponent(self._btnTimeActivity, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTimeActivity = nil;
	UIUtil.GetComponent(self.btnOffLine, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnOffLine = nil;
	
	
	UIUtil.GetComponent(self.btnZL, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickbtnZL = nil;
	
	UIUtil.GetComponent(self._goNoticeMask, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickNoticeMask = nil;
	
	UIUtil.GetComponent(self.btn_help, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_help = nil;
	
	MessageManager.RemoveListener(ActivityDataManager, ActivityDataManager.MESSAGE_SERVERDATA_CHANGE, ActivityPanel.ServerDataChange);
	MessageManager.RemoveListener(RCActivityItem, RCActivityItem.MESSAGE_SHOWINFO, ActivityPanel.ShowItemInfo);
	MessageManager.RemoveListener(ActivityDataManager, ActivityDataManager.MESSAGE_SERVERDATA_AV_CHANGE, ActivityPanel.ServerAvDataChange);
	MessageManager.RemoveListener(InstanceDataManager, InstanceDataManager.MESSAGE_0X0F01_CHANGE, ActivityPanel.ServerDataChange);
	MessageManager.RemoveListener(PlayerManager, PlayerManager.OffLineChg, ActivityPanel.UpdateOffLineTime);
	
	MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfLevelChange, ActivityPanel._LevelChange)
	MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_NTF_LEVELUP, ActivityPanel.ServerDataChange)
	MessageManager.RemoveListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_NEED_UP_INSTREDS, ActivityPanel.ServerDataChange)
	MessageManager.RemoveListener(TaskManager, TaskNotes.TASK_REWARD_CHANCE, ActivityPanel.ServerDataChange)
	MessageManager.RemoveListener(PVPManager, PVPManager.MESSAGE_VIP_BUY_TIME_CHANGE, ActivityPanel.ServerDataChange)
end

function ActivityPanel:_DisposeReference()
	self._btn_close = nil;
	self._btnRiChangActivity = nil;
	self._btnRiChangFB = nil;
	self._btnTimeActivity = nil;
	
	
	self.riChangActivityPanelCtr:Dispose();
	self.riChangActivityPanelCtr = nil;
	
	self.riChangFBPanelCtr:Dispose();
	self.riChangFBPanelCtr = nil;
	
	self.timeActivityPanelCtr:Dispose();
	self.timeActivityPanelCtr = nil;
	
	self.activityBottomPanelCtr:Dispose();
	self.activityBottomPanelCtr = nil;
	--self.infosPanelCtr:Dispose();
	
	
	------------------------------
	self._btn_close = nil;
	self._btnRiChangActivity = nil;
	self._btnRiChangFB = nil;
	self._btnTimeActivity = nil;
	self._trsToggle = nil;
	
	self.mainView = nil;
	self.tipPanel = nil;
	--self.infosPanelCtr = nil;
	--self.infosPanelCtr = nil;
	
	self.hyIcon = nil;
	self.hyvalueTxt = nil;
	
	self._riChangActivityPanel = nil;
	self._riChangFBPanel = nil;
	self._timeActivityPAnel = nil;
	self._bottomPanel = nil;
	
	
	
	self.riChangActivityPanelCtr = nil;
	self.riChangActivityPanelCtr = nil;
	
	self.riChangFBPanelCtr = nil;
	self.riChangFBPanelCtr = nil;
	
	self.timeActivityPanelCtr = nil;
	self.timeActivityPanelCtr = nil;
	
	self.activityBottomPanelCtr = nil;
	self.activityBottomPanelCtr = nil;
	
	
end
