require "Core.Module.Common.Panel"
require "Core.Module.DaysRank.View.Item.DaysRankListItem"


DaysRankListPanel = Panel:New()

function DaysRankListPanel:_Init()
  	self:_InitReference();
  	self:_InitListener();
end

function DaysRankListPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._txtTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsTitle/txtTitle");

    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "trsList/phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, DaysRankListItem);

end

function DaysRankListPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
  	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

    MessageManager.AddListener(DaysRankNotes, DaysRankNotes.RSP_DAYS_DETAIL, DaysRankListPanel.OnRspList, self);

end

function DaysRankListPanel:_Dispose()	
  	self:_DisposeListener();
  	self:_DisposeReference();
end

function DaysRankListPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

    MessageManager.RemoveListener(DaysRankNotes, DaysRankNotes.RSP_DAYS_DETAIL, DaysRankListPanel.OnRspList);
end

function DaysRankListPanel:_DisposeReference()
	self._phalanx:Dispose();
end

function DaysRankListPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(DaysRankNotes.CLOSE_DAYSRANK_LIST_PANEL);
end

function DaysRankListPanel:UpdateType(t)
	DaysRankProxy.ReqRankDetail(t);

	self._txtTitle.text = LanguageMgr.Get("daysRank/title/"..t);
end

function DaysRankListPanel:OnRspList(info)
	local count = #info.list;
	self._phalanx:Build(count, 1, info.list);
end