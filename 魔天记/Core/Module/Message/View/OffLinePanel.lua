require "Core.Module.Common.Panel"

OffLinePanel = Panel:New()

function OffLinePanel:IsPopup()
    return false;
end

function OffLinePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function OffLinePanel:_InitReference()

	self._txtExp = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtExp");
	self._txtTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTime");
	self._txtLev = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtLev");
	self._txtNum = UIUtil.GetChildByName(self._trsContent,"UILabel","txtNum");
	self._txtDesc = UIUtil.GetChildByName(self._trsContent,"UILabel","txtDesc");
	self._txtDesc.text = LanguageMgr.Get("offline/desc");
	
	self._btnTime = UIUtil.GetChildByName(self._trsContent, "UISprite", "btnTime");
	self._btnCancel = UIUtil.GetChildByName(self._trsContent, "UISprite", "btnCancel");

end

function OffLinePanel:_InitListener()
	self._onClickBtnTime = function(go) self:_OnClickBtnTime(self) end
	UIUtil.GetComponent(self._btnTime, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTime);

	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

	MessageManager.AddListener(PlayerManager, PlayerManager.OffLineChg, OffLinePanel.UpdateDisplay, self)
end

function OffLinePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function OffLinePanel:_DisposeListener()

	UIUtil.GetComponent(self._btnTime, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTime = nil;

	UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;

	MessageManager.RemoveListener(PlayerManager, PlayerManager.OffLineChg, OffLinePanel.UpdateDisplay)

end

function OffLinePanel:_DisposeReference()

end


function OffLinePanel:_OnClickBtnTime()
	MessageProxy.AddOffLineTIme();
end

function OffLinePanel:_OnClickBtnClose()
	ModuleManager.SendNotification(MessageNotes.CLOSE_OFFLINE_PANEL);
end

function OffLinePanel:_Opened()
    self:UpdateDisplay();
end

function OffLinePanel:UpdateDisplay()
	self._txtTime.text = LanguageMgr.Get("offline/time", {time = OffLinePanel.FormatTime(PlayerManager.OffLineData.offTime), time2 = OffLinePanel.FormatTime(PlayerManager.OffLineData.time)});
	self._txtExp.text = LanguageMgr.Get("offline/exp", PlayerManager.OffLineData);
	if PlayerManager.OffLineData.lv2 ~= PlayerManager.OffLineData.lv then
		self._txtLev.text = LanguageMgr.Get("offline/lv", PlayerManager.OffLineData);
	else
		self._txtLev.text = "";
	end
	self._txtNum.text = BackpackDataManager.GetProductTotalNumBySpid(500112) .. ""
end

function OffLinePanel.FormatTime(min)
	if min > 60 then
		local h = math.floor(min / 60);
        local m = math.floor(min - (h * 60));
		return LanguageMgr.Get("time/hhmm", {h = h, m = m});

	end
	return LanguageMgr.Get("time/mm", {m = min});
end