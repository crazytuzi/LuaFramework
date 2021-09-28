require "Core.Module.Common.Panel";
require "Core.Module.Common.PropsItem";
require "Core.Module.DaysTarget.View.Item.DaysTargetDayItem";
require "Core.Module.DaysTarget.View.Item.DaysTargetItem";

DaysTargetPanel = Panel:New()
local _insert = table.insert;

function DaysTargetPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function DaysTargetPanel:_InitReference()
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

	--self._scollview = UIUtil.GetChildByName(self._trsContent, "UIScrollView", "trsList")

	self._txtTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTime");
	self._txtDesc = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDesc");
	self._txtDescTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDesc/txtDescTitle");

	self._trsAward = UIUtil.GetChildByName(self._trsContent, "Transform", "trsAward");
	self._btnAward = UIUtil.GetChildByName(self._trsAward, "UIButton", "btnAward");
	self._txtAward = UIUtil.GetChildByName(self._trsAward, "UILabel", "txtAward");
	self._txtTips = UIUtil.GetChildByName(self._trsAward, "UILabel", "txtTips");
	self._txtAward.gameObject:SetActive(false);

	--self._daysPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "phalanx");
	--self._daysPhalanx = Phalanx:New();
	--self._daysPhalanx:Init(self._daysPhalanxInfo, DaysTargetDayItem);

	self._listPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "trsList/phalanx");
	self._listPhalanx = Phalanx:New();
	self._listPhalanx:Init(self._listPhalanxInfo, DaysTargetItem);

	self._awardPhalanxInfo = UIUtil.GetChildByName(self._trsAward, "LuaAsynPhalanx", "phalanx");
	self._awardPhalanx = Phalanx:New();
	self._awardPhalanx:Init(self._awardPhalanxInfo, PropsItem);

	DaysTargetProxy.GetCurrentDay();

	self:InitView();
	
end

function DaysTargetPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

	self._onClickBtnAward = function(go) self:_OnClickBtnAward() end
	UIUtil.GetComponent(self._btnAward, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAward);    

	MessageManager.AddListener(DaysTargetNotes, DaysTargetNotes.RSP_AWARD, DaysTargetPanel.OnRspInfo, self);
	MessageManager.AddListener(DaysTargetNotes, DaysTargetNotes.ENV_DAYS_SELECT, DaysTargetPanel.OnDaySelect, self);
	MessageManager.AddListener(DaysTargetNotes, DaysTargetNotes.RSP_AWARD_CHG , DaysTargetPanel.OnAwardChg, self);
	
	--self._timer = Timer.New( function(val) self:OnUpdate(val) end, 5, -1, false);
	--self._timer:Start();
end

function DaysTargetPanel:_Dispose()	
	self:_DisposeListener();
	self:_DisposeReference();
end

function DaysTargetPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;

	UIUtil.GetComponent(self._btnAward, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnAward = nil;

	MessageManager.RemoveListener(DaysTargetNotes, DaysTargetNotes.RSP_AWARD, DaysTargetPanel.OnRspInfo);
	MessageManager.RemoveListener(DaysTargetNotes, DaysTargetNotes.ENV_DAYS_SELECT, DaysTargetPanel.OnDaySelect);
	MessageManager.RemoveListener(DaysTargetNotes, DaysTargetNotes.RSP_AWARD_CHG, DaysTargetPanel.OnAwardChg);

	--self._timer:Stop();
	--self._timer = nil;
end

function DaysTargetPanel:_DisposeReference()
	--self._daysPhalanx:Dispose();
	self._listPhalanx:Dispose();
	self._awardPhalanx:Dispose();
end

function DaysTargetPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(DaysTargetNotes.CLOSE_DAYSTARGET_PANEL);
end

function DaysTargetPanel:_Opened()
	DaysTargetProxy.ReqInfo();
end

local cfgs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TACT_SEVENDAY);
function DaysTargetPanel:InitView()
	local days = {};
	for k, v in pairs(cfgs) do
		_insert(days,v);
	end
	--table.sort(days, function(a,b) return a.id < b.id end);

	--self._daysPhalanx:Build(#days, 1, days);
	self.days = days;
end

function DaysTargetPanel:OnRspInfo()
	--选择当前的天数
	local day = 1 --math.max(DaysTargetProxy.GetCacheDay(), 1);	
	self:OnDaySelect(self.days[day]);
end

function DaysTargetPanel:OnDaySelect(data)
	--[[
	if KaiFuManager.GetKaiFuHasDate() < data then
		MsgUtils.ShowTips("daysRank/day/notOpen", {day = data, title = LanguageMgr.Get("daysRank/title/".. data)});
		return;
	end
	
	local items = self._daysPhalanx:GetItems();
	for i,v in ipairs(items) do
		v.itemLogic:SetSelect(data);
	end
	]]
	self:UpdateDisplay(data);
end

function DaysTargetPanel:OnUpdate()
	self:UpdateTime();
end

function DaysTargetPanel:UpdateDisplay(info)
	if self._info ~= info then
		self._info = info;
		local list = DaysTargetProxy.GetDayList(info.type);
		local count = #list;
		self._listPhalanx:Build(count, 1, list);

		local awards = {};

	    for i, v in ipairs(self._info.total_reward) do 
	        local item = string.split(v, "_");
	        local d = ProductInfo:New();
	        d:Init({spId = tonumber(item[1]), am = tonumber(item[2])});
	        _insert(awards, d);
	    end
		self._awardPhalanx:Build(1, #awards, awards);

		self._txtDescTitle.text = LanguageMgr.Get("daysTarget/dayTitle", {num = info.type});
		self._txtTips.text = info.reward_des;
		--self:UpdateRedPoint();
		self:UpdateAward();
		self:UpdateTime();
	end
end

function DaysTargetPanel:UpdateAward()
	local day = self._info.type;
	local cur = DaysTargetProxy.GetDayFinishNum(day);
	local dayStatus = DaysTargetProxy.GetDayAward(day) or 0;
	self._btnAward.gameObject:SetActive(dayStatus == 0 and cur >= self._info.num);
	self._txtAward.gameObject:SetActive(dayStatus == 1);
	self._txtDesc.text = LanguageMgr.Get("daysTarget/dayAward", {cur = cur, num = self._info.num});
end

function DaysTargetPanel:OnAwardChg()
	self:UpdateAward();
	--self:UpdateRedPoint();
	self:UpdateList();
end

function DaysTargetPanel:UpdateRedPoint()
	local items = self._daysPhalanx:GetItems();
	local item = nil;
    for i,v in ipairs(items) do
        item = v.itemLogic;
        item:UpdateRedPoint();
    end
end

function DaysTargetPanel:UpdateList()
	--[[
	local items = self._listPhalanx:GetItems();
	local item = nil;
    for i,v in ipairs(items) do
        item = v.itemLogic;
        item:UpdateStatus();
    end
    ]]
    local list = DaysTargetProxy.GetDayList(self._info.type);
	local count = #list;
	self._listPhalanx:Build(count, 1, list);
end
--[[
function DaysTargetPanel:UpdateTime()
	if self._endTime then
		if self._endTime > 0 then
			self._endTime = self._endTime - os.time() + self._osTime;
			self._txtTime.text = LanguageMgr.Get("daysRank/time", {tStr = DaysTargetPanel.FormatTime(self._endTime) });
		else
			self._txtTime.text = LanguageMgr.Get("daysRank/time/end");
		end
	else
		self._txtTime.text = "";
	end
end

function DaysTargetPanel.FormatTime(t)
	if t > 3600 then
		local h = math.floor(t / 3600);
        local m = math.floor((t - h * 3600) / 60);
		return string.format("%d小时%d分钟", h, m);
	end
	return string.format("%d分钟", math.floor(t / 60));
end
]]

function DaysTargetPanel:UpdateTime()
	if self._info then
		--local now = math.max(DaysTargetProxy.GetCacheDay(), 1);
		local d = self._info.effective_time;
		self._txtTime.text = LanguageMgr.Get("daysTarget/time", {d = d, tStr = DaysTargetPanel.GetTimeStr(d) });
	end
end

function DaysTargetPanel.GetTimeStr(day)
	local act = TimeLimitActManager.GetAct(302);
	if act then
		local date = os.date("*t", act.endTime);
		date.day = date.day - day + 1;
		return os.date('%Y-%m-%d', os.time(date)) .." - ".. os.date('%Y-%m-%d', act.endTime);
	else
		return "";
	end
end

function DaysTargetPanel.GetDaysDesc(a, b)
	local time = GetTime();
	local date = os.date("*t", time);
	date.day = date.day + b - a;
	local endTime = os.time({year = date.year, month = date.month, day = date.day, hour = 23, min = 59, sec = 59})
	return endTime - time;
	--return os.date("%Y-%m-%d 23:59:59", os.time(date));
end

function DaysTargetPanel:_OnClickBtnAward()
	if self._info then
		DaysTargetProxy.ReqGetDayAward(self._info.type);
	end
end

function DaysTargetPanel.OpenSys(id)
    SystemManager.Nav(id)
end