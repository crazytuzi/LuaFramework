require "Core.Module.Common.Panel"
require "Core.Module.MainUI.View.Item.MainUISystemItem"

local MainSysExpandPanel = class("MainSysExpandPanel", Panel);

function MainSysExpandPanel:IsPopup()
	return true;
end

function MainSysExpandPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function MainSysExpandPanel:_InitReference()

	self._bg = UIUtil.GetChildByName(self._trsContent, "UISprite", "bg");

    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "phalanx", true);
    self._trsPhalanx = self._phalanxInfo.transform;
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, MainUISystemItem);

    self._trsFullMask = UIUtil.GetChildByName(self._transform, "Transform", "trsFullMask");
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._trsFullMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

	self._gameObject:SetActive(false);
end

function MainSysExpandPanel:_InitListener()
	MessageManager.AddListener(MainUINotes, MainUINotes.EVENT_SYSITEM_CLICK, MainSysExpandPanel.OnItemClick, self);
end

function MainSysExpandPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function MainSysExpandPanel:_DisposeListener()
	MessageManager.RemoveListener(MainUINotes, MainUINotes.EVENT_SYSITEM_CLICK, MainSysExpandPanel.OnItemClick);
end

function MainSysExpandPanel:_DisposeReference()
    self._phalanx:Dispose();
    self._phalanx = nil;

    UIUtil.GetComponent(self._trsFullMask, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
end

function MainSysExpandPanel:_OnClickBtnClose()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.SYS_EXPAND_CLOSE);
	ModuleManager.SendNotification(MainUINotes.CLOSE_SYS_EXPAND_PANEL);
end

function MainSysExpandPanel:OnItemClick(data)
	if data.id ~= self.openParam then
		SystemManager.Nav(data.id);
		self:_OnClickBtnClose();
	end
end

function MainSysExpandPanel:_Opened()
	self._gameObject:SetActive(true);

	self.cfg = SystemManager.GetCfg(self.openParam);

	local btnId = tostring(self.openParam);
	local trsIcon = nil;
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
	--local sysListGo = panel:GetTransformByPath("UI_SysPanel/trsSys/sysPhalanx").gameObject;
    --trsIcon = UIUtil.GetChildByName(sysListGo, btnId);
    --if trsIcon == nil then
        if panel:ActPanelIsExpand() then
        	trsIcon = GuideContent._GetActItem1(btnId);
        else
        	trsIcon = GuideContent._GetActItem2(btnId);
        end
        if trsIcon then
            trsIcon = UIUtil.GetChildByName(trsIcon.gameObject, "icon");
        end
    --end

    if trsIcon then
    	self.trsIcon = trsIcon;
    else
    	error("can't find icon parent - " .. btnId);
    end

	self:UpdateDisplay();
	SequenceManager.TriggerEvent(SequenceEventType.Guide.SYS_EXPAND_OPEN);
end

function MainSysExpandPanel:SetOpenParam(param)
	self.openParam = param;
end

function MainSysExpandPanel:UpdateDisplay()
	local iconPos = self.trsIcon.position;
	self._trsContent.localPosition = self._transform:InverseTransformPoint(iconPos);
	LuaDOTween.DOLocalMoveY(self._trsContent, self._trsContent.localPosition.y - 30, 0.3, false)

	local list = {};
	for i,v in ipairs(self.cfg.group) do
		if SystemManager.IsOpen(v) then
			table.insert(list, SystemManager.GetCfg(v));
		end
	end

	local count = #list;
	self._phalanx:Build(1, count, list);

	self._bg.width = count * 80 + 20;

	local pos = self._trsPhalanx.localPosition;
	pos.x = -40 * (count - 1);
	self._trsPhalanx.localPosition = pos;

	self:UpdateRedPoint();
end

function MainSysExpandPanel:UpdateRedPoint()
	local items = self._phalanx:GetItems();
	local item = nil;
	local b = false;
    for i,v in ipairs(items) do
        item = v.itemLogic;
        b = SystemManager.GetRedPoint(item:GetId());
        item:SetHasMsgFlg(b);
    end
end


return MainSysExpandPanel;