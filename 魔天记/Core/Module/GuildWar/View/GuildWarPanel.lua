require "Core.Module.Common.Panel";
require "Core.Module.Common.PropsItem";

GuildWarPanel = Panel:New();

function GuildWarPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function GuildWarPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnClose = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btnDesc = UIUtil.GetChildInComponents(btns, "btnDesc");
    self._btnAwardDesc = UIUtil.GetChildInComponents(btns, "btnAwardDesc");
    self._btnRank = UIUtil.GetChildInComponents(btns, "btnRank");
    self._btnReq = UIUtil.GetChildInComponents(btns, "btnReq");
    self._btnFight = UIUtil.GetChildInComponents(btns, "btnFight");
    self._btnClosePop = UIUtil.GetChildInComponents(btns, "btnClosePop");
    self._btnClosePopAward = UIUtil.GetChildInComponents(btns, "btnClosePopAward");

    self._txtReq = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtReq");

    self._trsInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo");
    self._txtTime1 = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtTime1");
    self._txtTime2 = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtTime2");

    self._trsPop = UIUtil.GetChildByName(self._trsContent, "Transform", "trsPop");
    self._trsPopAward = UIUtil.GetChildByName(self._trsContent, "Transform", "trsPopAward");

    self._trsPop.gameObject:SetActive(false);
    self._trsPopAward.gameObject:SetActive(false);

    self._phalanxInfo = UIUtil.GetChildByName(self._trsInfo, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, PropsItem);

    self._btnReq.gameObject:SetActive(false);
    self._btnFight.gameObject:SetActive(false);
    self._txtReq.gameObject:SetActive(false);

    self:InitDisplay();
end

function GuildWarPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	self._onClickBtnDesc = function(go) self:_OnClickBtnDesc(self) end
	UIUtil.GetComponent(self._btnDesc, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnDesc);
	self._onClickBtnClosePop = function(go) self:_OnClickBtnClosePop(self) end
	UIUtil.GetComponent(self._btnClosePop, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClosePop);
	self._onClickBtnAwardDesc = function(go) self:_OnClickBtnAwardDesc(self) end
	UIUtil.GetComponent(self._btnAwardDesc, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAwardDesc);
	self._onClickBtnClosePopAward = function(go) self:_OnClickBtnClosePopAward(self) end
	UIUtil.GetComponent(self._btnClosePopAward, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClosePopAward);

	self._onClickBtnReq = function(go) self:_OnClickBtnReq(self) end
	UIUtil.GetComponent(self._btnReq, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReq);
	self._onClickBtnFight = function(go) self:_OnClickBtnFight(self) end
	UIUtil.GetComponent(self._btnFight, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFight);
	self._onClickBtnRank = function(go) self:_OnClickBtnRank(self) end
	UIUtil.GetComponent(self._btnRank, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRank);

    MessageManager.AddListener(GuildWarNotes, GuildWarNotes.RSP_ENROLL_INFO, GuildWarPanel.UpdateDisplay, self);
end

function GuildWarPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildWarPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	UIUtil.GetComponent(self._btnDesc, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnDesc = nil;
	UIUtil.GetComponent(self._btnClosePop, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClosePop = nil;
	UIUtil.GetComponent(self._btnAwardDesc, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnAwardDesc = nil;
	UIUtil.GetComponent(self._btnClosePopAward, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClosePopAward = nil;

	UIUtil.GetComponent(self._btnReq, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnAwardDesc = nil;
	UIUtil.GetComponent(self._btnFight, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnFight = nil;
	UIUtil.GetComponent(self._btnRank, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClosePopAward = nil;

    MessageManager.RemoveListener(GuildWarNotes, GuildWarNotes.RSP_ENROLL_INFO, GuildWarPanel.UpdateDisplay);
end

function GuildWarPanel:_DisposeReference()
    self._phalanx:Dispose();
end

function GuildWarPanel:_Opened()
   	GuildWarProxy.ReqEnrollInfo();
end

function GuildWarPanel:InitDisplay()
	self.cfg = GuildDataManager.GetWarConfig();
	local awardArr = self.cfg.award_show;
	local items = TaskUtils.GetItemsByStrArr(awardArr);
	self._phalanx:Build(1, #items , items);
end

function GuildWarPanel:UpdateDisplay(data)
	local isEnroll = data.f > 0;
	local time = GetOffsetTime();
	local cfg = self.cfg;
	local d = os.date("*t", time);

	local enrollStart = GuildDataManager.SplitDateTime(cfg.sign_up_time[1]);
	local enrollEnd = GuildDataManager.SplitDateTime(cfg.sign_up_time[#cfg.sign_up_time]);
	local isInEnrollTime = GuildDataManager.InTime(d, enrollStart) and not GuildDataManager.InTime(d, enrollEnd);
	
	local isInBattleTime = false;
	for i, v in ipairs(cfg.week_time) do 
		local sd = GuildDataManager.SplitDateTime(v.."_"..cfg.start_time);
		local ed = GuildDataManager.SplitDateTime(v.."_"..cfg.end_time);
		if GuildDataManager.InTime(d, sd) and not GuildDataManager.InTime(d, ed) then
			isInBattleTime = true;
			break;
		end
	end
	
	--非战斗时，在报名期间内 没有报名记录
	self._btnReq.gameObject:SetActive(isInBattleTime == false and isInEnrollTime and not isEnroll);
    --self._btnEnd.gameObject:SetActive(v == 1);
    --非战斗时，报名期间内 有报名记录
    self._txtReq.gameObject:SetActive(isInBattleTime == false and isInEnrollTime and isEnroll);
    --战斗期间内 有报名记录
    self._btnFight.gameObject:SetActive(isInBattleTime and isEnroll);

end
 
 

function GuildWarPanel:_OnClickBtnReq()
	GuildWarProxy.ReqEnrollWar();
end

function GuildWarPanel:_OnClickBtnFight()
	GuildWarProxy.ReqPreEnter();
end

function GuildWarPanel:_OnClickBtnRank()
	ModuleManager.SendNotification(GuildWarNotes.OPEN_RANK_PANEL);
end

function GuildWarPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(GuildWarNotes.CLOSE_PANEL);
end

function GuildWarPanel:_OnClickBtnDesc()
	self._trsPop.gameObject:SetActive(true);
end

function GuildWarPanel:_OnClickBtnClosePop()
	self._trsPop.gameObject:SetActive(false);
end

function GuildWarPanel:_OnClickBtnAwardDesc()
	self._trsPopAward.gameObject:SetActive(true);
end

function GuildWarPanel:_OnClickBtnClosePopAward()
	self._trsPopAward.gameObject:SetActive(false);
end
