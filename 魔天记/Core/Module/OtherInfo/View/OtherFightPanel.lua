require "Core.Module.Common.Panel";
require "Core.Module.OtherInfo.View.Item.OtherFightItem";

OtherFightPanel = Panel:New();
OtherFightPanel.Sys = {
	SystemConst.Id.EQUIP, 
	SystemConst.Id.REALM, 
	SystemConst.Id.PET,
	--SystemConst.Id.LingYao,
	SystemConst.Id.MOUNT, 
	SystemConst.Id.WING,
	SystemConst.Id.SKILL,
	SystemConst.Id.FABAO,
	SystemConst.Id.Formation
}

function OtherFightPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function OtherFightPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");

    self._txtTargetFight = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTargetFight");
	self._txtMyFight = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMyFight");
	self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
	self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx", true);
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, OtherFightItem);

end

function OtherFightPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

end

function OtherFightPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function OtherFightPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;

end

function OtherFightPanel:_DisposeReference()
    
end

function OtherFightPanel:Update(d)
	self.data = d;
    self:UpdateDisplay();
end

function OtherFightPanel:UpdateDisplay()
	local d = self.data;

	self._txtTargetFight.text = d.total;
	self._txtMyFight.text = d.my_total;

	local count = #OtherFightPanel.Sys;
    self._phalanx:Build(count, 1, OtherFightPanel.Sys);
end

function OtherFightPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(OtherInfoNotes.CLOSE_FIGHT_PANEL);
end

