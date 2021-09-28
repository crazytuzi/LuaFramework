require "Core.Module.Common.Panel"
require "Core.Module.Common.UIAnimationModel"
require "Core.Module.Wing.View.Item.SubWingPanel"
require "Core.Module.Wing.View.Item.SubWingPreviewPanel"
require "Core.Module.Common.UIEffect"


WingPanel = class("WingPanel", Panel);
function WingPanel:New()
	self = {};
	setmetatable(self, {__index = WingPanel});
	return self
end

function WingPanel:_Init()
	WingManager.SortWing()
	-- self._heroInfo = ConfigManager.Clone(PlayerManager.GetPlayerInfo())
	self:_InitReference();
	self:_InitListener();
	self._isUpdate = false
	self._btnWing.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.WingUpdate))
	self._btnPreview.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.WingFashion))
	
end

function WingPanel:_InitReference()
	self._trsWing = UIUtil.GetChildByName(self._trsContent, "trsWing")
	self._trsPreview = UIUtil.GetChildByName(self._trsContent, "trsPreview")
	self._panels = {}
	self._panels[1] = SubWingPanel:New(self._trsWing)
	self._panels[2] = SubWingPreviewPanel:New(self._trsPreview)
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	
	self._btnWing = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnWing")
	self._btnPreview = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnPreview")
	self._tip = UIUtil.GetChildByName(self._trsContent, "btnWing/tip");
	self._effectParent = UIUtil.GetChildByName(self._trsContent, "effectParent")
	self._bg = UIUtil.GetChildByName(self._trsContent, "UITexture", "bg/bg")
	self._uiEffect = UIEffect:New()
	self._uiEffect:Init(self._effectParent, self._bg, 5, "ui_changewing")
end

function WingPanel:_InitListener()
	
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	
	self._onClickBtnWing = function(go) self:_OnClickBtnWing(self) end
	UIUtil.GetComponent(self._btnWing, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnWing);
	self._onClickBtnPreview = function(go) self:_OnClickBtnPreview(self) end
	UIUtil.GetComponent(self._btnPreview, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnPreview);
	MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, WingPanel.SetRedPoint, self)
end

function WingPanel:_OnClickBtnWing()
	self:SelectPanel(1)
end

function WingPanel:_OnClickBtnPreview()
	self:SelectPanel(2)
end

function WingPanel:_OnClickBtn_close()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(WingNotes.CLOSE_WINGPANEL)
end

function WingPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	
	if(self._uiEffect) then
		self._uiEffect:Dispose()
		self._uiEffect = false		
	end
	
	for k, v in ipairs(self._panels) do
		v:Dispose()
	end
	WingProxy.SetCurSelectWingId(0)
end

function WingPanel:_DisposeListener()
	
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	
	UIUtil.GetComponent(self._btnPreview, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnPreview = nil;
	
	UIUtil.GetComponent(self._btnWing, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnWing = nil;
	
	MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, WingPanel.SetRedPoint, self)
	
end

function WingPanel:SetRedPoint()
	if(self._isUpdate) then	
		self._isUpdate = false
		self:UpdateState()
	end
end

function WingPanel:_DisposeReference()
	self._btnUpdateLevel = nil;
	self._btnShowAdvance = nil;
	self._btn_close = nil;
	self._previewTip = nil
end

function WingPanel:UpdateWingPanel(data)
	
	if(self._panels[self._panenIndex]) then
		self._panels[self._panenIndex]:UpdatePanel(data)
	end
	
	if(self._panels[1]) then
		self._panels[1]:StopAdvanceTimer()
	end
	
	self:UpdateState()
end

function WingPanel:SelectPanel(index)
	for i = 1, table.getCount(self._panels) do
		if i == index then
			self._panels[i]:SetEnable(true)
		else
			self._panels[i]:SetEnable(false)
		end
	end
	
	self._panenIndex = index
	self:UpdateWingPanel()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.WING_CHANGE_PANEL, index);
end

function WingPanel:UpdatePanelByActive(data)
	self._panels[2]:UpdatePanelByActive(data)
end

function WingPanel:UpdateState()
	self._tip.gameObject:SetActive(WingManager.CanWingAdvance())
end

function WingPanel:ShowEffect()
	self._uiEffect:Play()
end

function WingPanel:ShowActiveEffect()
	if(self._panels[2]) then
		self._panels[2]:ShowActiveEffect()
	end
end

function WingPanel:ShowUpdateLevelLabel(value)
	if(self._panels[1]) then
		self._panels[1]:ShowUpdateLevelLabel(value)
	end
end

function WingPanel:UpdateLevel()
	self._isUpdate = true
	if(self._panels[1]) then
		self._panels[1]:UpdateLevel()
		self._panels[1]:ShowStarEffect()
		self:UpdateState()		
	end
end

function WingPanel:UpdateExp()
	self._isUpdate = true
	if(self._panels[1]) then
		self._panels[1]:UpdateExp()
		self:UpdateState()
	end
end 