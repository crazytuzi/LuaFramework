require "Core.Module.Common.Panel";
local XuanBaoPanel = class("XuanBaoPanel", Panel);
local XuanBaoTypeItem = require "Core.Module.XuanBao.View.XuanBaoTypeItem";
local XuanBaoItem = require "Core.Module.XuanBao.View.XuanBaoItem";

function XuanBaoPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function XuanBaoPanel:_InitReference()
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

	self._trsXuanBao = UIUtil.GetChildByName(self._trsContent, "Transform", "trsXuanBao");
	self._btnAward = UIUtil.GetChildByName(self._trsXuanBao, "UIButton", "btnAward");
	self._txtAward = UIUtil.GetChildByName(self._trsXuanBao, "UILabel", "txtAward");
	self._txtEffect = UIUtil.GetChildByName(self._trsXuanBao, "UILabel", "txtEffect");
	self._icoAward = UIUtil.GetChildByName(self._trsXuanBao, "UISprite", "icoAward");
	self._icoStatus = UIUtil.GetChildByName(self._trsXuanBao, "UISprite", "icoStatus");
	self._icoStatus.alpha = 0;

	self._typesPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "phalanx");
	self._typesPhalanx = Phalanx:New();
	self._typesPhalanx:Init(self._typesPhalanxInfo, XuanBaoTypeItem);

	self._listScrollView = UIUtil.GetChildByName(self._trsContent, "UIScrollView", "trsList");
	self._listPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "trsList/phalanx");
	self._listPhalanx = Phalanx:New();
	self._listPhalanx:Init(self._listPhalanxInfo, XuanBaoItem);
	--[[
	self._awardPhalanxInfo = UIUtil.GetChildByName(self._trsAward, "LuaAsynPhalanx", "phalanx");
	self._awardPhalanx = Phalanx:New();
	self._awardPhalanx:Init(self._awardPhalanxInfo, PropsItem);
	]]

	--self:InitView();
	
end

function XuanBaoPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose() end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

	self._onClickBtnAward = function(go) self:_OnClickBtnAward() end
	UIUtil.GetComponent(self._btnAward, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAward);    

	MessageManager.AddListener(XuanBaoNotes, XuanBaoNotes.RSP_INFO, XuanBaoPanel.OnRspInfo, self);
	MessageManager.AddListener(XuanBaoNotes, XuanBaoNotes.ENV_TYPE_SELECT, XuanBaoPanel.OnTypeSelect, self);
	MessageManager.AddListener(XuanBaoNotes, XuanBaoNotes.RSP_AWARD_CHG , XuanBaoPanel.UpdateTypes, self);
	--MessageManager.AddListener(XuanBaoNotes, XuanBaoNotes.RSP_TYPE_AWARD_CHG , XuanBaoPanel.UpdateTypes, self);
end

function XuanBaoPanel:_Dispose()	
	self:_DisposeListener();
	self:_DisposeReference();
end

function XuanBaoPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;

	UIUtil.GetComponent(self._btnAward, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnAward = nil;

	MessageManager.RemoveListener(XuanBaoNotes, XuanBaoNotes.RSP_INFO, XuanBaoPanel.OnRspInfo);
	MessageManager.RemoveListener(XuanBaoNotes, XuanBaoNotes.ENV_TYPE_SELECT, XuanBaoPanel.OnTypeSelect);
	MessageManager.RemoveListener(XuanBaoNotes, XuanBaoNotes.RSP_AWARD_CHG, XuanBaoPanel.UpdateTypes);
	--MessageManager.RemoveListener(XuanBaoNotes, XuanBaoNotes.RSP_TYPE_AWARD_CHG, XuanBaoPanel.UpdateTypes);

end

function XuanBaoPanel:_DisposeReference()
	self._typesPhalanx:Dispose();
	self._listPhalanx:Dispose();
	--self._awardPhalanx:Dispose();
end

function XuanBaoPanel:_OnClickBtnClose()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(XuanBaoNotes.CLOSE_XUANBAOPANEL);
end

function XuanBaoPanel:_OnClickBtnAward()
	XuanBaoProxy.ReqGetDayAward(self._data.id)
end

function XuanBaoPanel:_Opened()
	XuanBaoProxy.ReqInfo();
end

function XuanBaoPanel:OnRspInfo()
	self:UpdateDisplay();
	
	SequenceManager.TriggerEvent(SequenceEventType.Guide.XUANBAO_UPDATE);
end

function XuanBaoPanel:OnAwardChg()
	self:UpdateDetail();
	self:UpdateRedPoint();
end

function XuanBaoPanel:UpdateDisplay()
	local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_XUANBAOTYPE);
	local list = {};
	for k, v in pairs(cfg) do
		table.insert(list, v);
	end

	table.sort(list , function(a,b) return a.type < b.type end);

	self._typesPhalanx:Build(#list, 1, list);

	local idx = 1;
	for i, v in ipairs(list) do
		if v.activation > 0 and XuanBaoManager.GetTypeAwardSt(v.activation) > 1 then
			idx = i;
		end
	end

	self:OnTypeSelect(list[idx]);
	self:UpdateRedPoint();
end

function XuanBaoPanel:OnTypeSelect(data)
	if self._data ~= data then
		self._data = data;
		self:UpdateDetail();

		local items = self._typesPhalanx:GetItems();
		for i,v in ipairs(items) do
			v.itemLogic:SetSelect(data);
		end

		self._listScrollView:ResetPosition();
	end
end

function XuanBaoPanel:UpdateDetail()
	if self._data then
		self:UpdateList();

		local d = self._data;
		--self._txtAward = d.reward_des;
		self._txtEffect.text = d.reward_function;
		self._icoAward.spriteName = d.reward_icon; 

		self:UpdateAward();
	end
end

function XuanBaoPanel:UpdateAward()
	local cur = XuanBaoManager.GetTypeFinishNum(self._data.type);
	local status = XuanBaoManager.GetTypeAwardSt(self._data.type) or 0;
	self._btnAward.gameObject:SetActive(status < 2 and cur >= self._data.num);
	self._icoStatus.alpha = status == 2 and 1 or 0;
	self._txtAward.text = self._data.reward_des .. "(" .. LanguageMgr.Get("common/numMax", {num = cur, max = self._data.num}) .. ")";
end

function XuanBaoPanel:UpdateList()
	local list = XuanBaoManager.GetTypeList(self._data.type);
	local count = #list;
	self._listPhalanx:Build(count, 1, list);
end

function XuanBaoPanel:UpdateRedPoint()
	local items = self._typesPhalanx:GetItems();
    for i, v in ipairs(items) do
        v.itemLogic:UpdateRedPoint();
    end
end

function XuanBaoPanel:UpdateTypes()
	local items = self._typesPhalanx:GetItems();
    for i, v in ipairs(items) do
        v.itemLogic:UpdateStatus();
    end
    self:OnAwardChg();
end

return XuanBaoPanel;