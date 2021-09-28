require "Core.Module.Common.Panel"
require "Core.Module.Common.CoinBar"
require "Core.Module.NewTrump.View.Item.SubNewTrumpPanel"
require "Core.Module.NewTrump.View.Item.SubNewTrumpRefinePanel"
require "Core.Module.NewTrump.View.Item.SubMobaoPanel"
require "Core.Module.NewTrump.View.Item.NewTrumpItem"
require "Core.Module.NewTrump.View.Item.MobaoItem"
require "Core.Module.Common.UIEffect"



NewTrumpPanel = class("NewTrumpPanel", Panel);
function NewTrumpPanel:New()
	self = {};
	setmetatable(self, {__index = NewTrumpPanel});
	return self
end

function NewTrumpPanel:IsPopup()
	return false
end

function NewTrumpPanel:_Init()
	self:_InitReference();
	self:_InitListener();
	self._coinBar = CoinBar:New(self._trsCoinBar)
	self._panels = {}
	self._panels[1] = SubNewTrumpPanel:New(self._trsTrump)
	self._panels[2] = SubNewTrumpRefinePanel:New(self._trsRefine)
	self._panels[3] = SubMobaoPanel:New(self._trsMobao)
	
	self._btnRefine.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.NewTrumpRefine))
    self._btnMobao.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.Mobao))
	
	self._panenIndex = 1
	self._isShowInfo = false
	self._trsInfo:SetActive(self._isShowInfo)
	self:UpdateList()
    self:UpdateListMobao()
	self._isInit = false
	--    self:UpdatePanel()
	-- self:ChangePanel(self._panenIndex)
end

function NewTrumpPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnTrump = UIUtil.GetChildInComponents(btns, "btnTrump");
	self._btnRefine = UIUtil.GetChildInComponents(btns, "btnRefine");
	self._btnMobao = UIUtil.GetChildInComponents(btns, "btnMobao");
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
	self._toggles = {self._btnTrump, self._btnRefine, self._btnMobao};
	
	local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
	self._trsTrump = UIUtil.GetChildInComponents(trss, "trsTrump");
	self._trsRefine = UIUtil.GetChildInComponents(trss, "trsRefine");
	self._trsMobao = UIUtil.GetChildInComponents(trss, "trsMobao");
	
	self._trsActiveSkill = UIUtil.GetChildInComponents(trss, "trsActiveSkill");
	self._trsPassiveSkill = UIUtil.GetChildInComponents(trss, "trsPassiveSkill");
	self._trsCoinBar = UIUtil.GetChildInComponents(trss, "trsCoinBar");
	self._trsInfo = UIUtil.GetChildInComponents(trss, "trsInfo").gameObject
	self._goInfo = UIUtil.GetChildByName(self._trsContent, "btnInfo").gameObject
	self._goInfoMask = UIUtil.GetChildByName(self._trsContent, "trsInfo/infoMask").gameObject
	self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "scrollView/phalanx")
	self._phalanxInfo2 = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "scrollView/phalanx2")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, NewTrumpItem)
	self._phalanx2 = Phalanx:New()
	self._phalanx2:Init(self._phalanxInfo2, MobaoItem)
	
	self._txtInfo = UIUtil.GetChildByName(self._trsInfo,"UILabel","parent/Label")
	self._uieffectParent = UIUtil.GetChildByName(self._trsContent, "UIEffectPanel")
	self._bg = UIUtil.GetChildByName(self._uieffectParent, "UISprite", "bg")
	self._sucUIEffect = UIEffect:New()
	self._sucUIEffect:Init(self._uieffectParent, self._bg, 3, "ui_trump")
	
	self._tipTrump = UIUtil.GetChildByName(self._trsContent, "btnTrump/tip")
	self._tipRefine = UIUtil.GetChildByName(self._trsContent, "btnRefine/tip")	
end

function NewTrumpPanel:_InitListener()
	self._onClickBtnTrump = function(go) self:_OnClickBtnTrump(self) end
	UIUtil.GetComponent(self._btnTrump, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTrump);
	self._onClickBtnMobao = function(go) self:_OnClickBtnMobao(self) end
	UIUtil.GetComponent(self._btnMobao, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnMobao);
	self._onClickBtnRefine = function(go) self:_OnClickBtnRefine(self) end
	UIUtil.GetComponent(self._btnRefine, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRefine);
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	self._onClickBtnInfo = function(go) self:_OnClickBtnInfo(self) end
	UIUtil.GetComponent(self._goInfo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnInfo);
	self._onClickBtnInfoMask = function(go) self:_OnClickBtnInfo(self) end
	UIUtil.GetComponent(self._goInfoMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnInfo);
end

function NewTrumpPanel:_OnClickBtnInfo()
	self._isShowInfo = not self._isShowInfo
	if(not self._isInit) then
		self._txtInfo.text = LanguageMgr.Get("NewTrump/NewTrumpPanel/notice")
	end
	self._trsInfo:SetActive(self._isShowInfo)
end

function NewTrumpPanel:_OnClickBtnTrump()
	self:ChangePanel(1)
	SequenceManager.TriggerEvent(SequenceEventType.Guide.TRUMP_CHANGE_PANEL, 1)
end

function NewTrumpPanel:_OnClickBtnRefine()
	self:ChangePanel(2)
	SequenceManager.TriggerEvent(SequenceEventType.Guide.TRUMP_CHANGE_PANEL, 2)
end

function NewTrumpPanel:_OnClickBtnMobao()
	self:ChangePanel(3)
end

function NewTrumpPanel:_OnClickBtn_close()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(NewTrumpNotes.CLOSE_NEWTRUMPPANEL)
end

function NewTrumpPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	if(self._coinBar) then
		self._coinBar:Dispose()
		self._coinBar = nil
	end
	
	if(self._phalanx) then
		self._phalanx:Dispose()
		self._phalanx = nil
	end
	if(self._phalanx2) then
		self._phalanx2:Dispose()
		self._phalanx2 = nil
	end
	
	for k, v in pairs(self._panels) do
		self._panels[k]:Dispose()
	end
	self._panels = nil
	
	NewTrumpManager.SetCurrentSelectTrump(nil)
	PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.NewTrump)
end

function NewTrumpPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnTrump, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTrump = nil;
	UIUtil.GetComponent(self._btnMobao, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnMobao = nil;
	UIUtil.GetComponent(self._btnRefine, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnRefine = nil;
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	UIUtil.GetComponent(self._goInfo, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnInfo = nil;
	UIUtil.GetComponent(self._goInfoMask, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnInfoMask = nil;
end

function NewTrumpPanel:_DisposeReference()
	self._btnTrump = nil;
	self._btnRefine = nil;
	self._btnMobao = nil;
	self._btn_close = nil;
	self._trsTrump = nil;
	self._trsRefine = nil;
	self._trsMobao = nil;
	self._trsCoinBar = nil
	self._tipTrump = nil
	self._tipRefine = nil
	if(self._sucUIEffect) then
		self._sucUIEffect:Dispose()
		self._sucUIEffect = nil
	end
end

function NewTrumpPanel:OpenSubPanel(tab)
	tab = tab or 1;
	self:ChangePanel(tab);
end

function NewTrumpPanel:UpdatePanel()
	self:ChangePanel(self._panenIndex)
    if self._panenIndex ~= 3 then
	    self:UpdateList()
    else
	    self:UpdateListMobao()
    end
end

function NewTrumpPanel:UpdateList()
    local data = NewTrumpManager.GetAllTrumpData()
	self._phalanx:Build(table.getCount(data), 1, data)
	local currentTrump = NewTrumpManager.GetCurrentSelectTrump()
	if(currentTrump == nil) then
		local item = self._phalanx:GetItem(1)
		if(item) then
			item.itemLogic:SetToggleActive(true)
		end
	else
		local items = self._phalanx:GetItems()
		for k, v in ipairs(items) do
			if currentTrump.id == v.data.id then
				v.itemLogic:SetToggle(true)
				break
			end
		end
	end
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_DATA_INITED, self._name)
end
function NewTrumpPanel:UpdateListMobao()
    local data = NewTrumpManager.GetMobaoConfigs()
    data = ConfigManager.SortForField(data, 'order')
    table.sort(data, function(a, b)
        local aAble = NewTrumpManager.IsMobaoEnable(a.id)
        local bAble = NewTrumpManager.IsMobaoEnable(b.id)
        if aAble ~= bAble then return aAble end
        return a.order < b.order
    end)
	self._phalanx2:Build(table.getCount(data), 1, data)
	local currentMobao = NewTrumpManager.GetCurrentMobao()
	local items = self._phalanx2:GetItems()
	for k, v in ipairs(items) do
		if currentMobao.id == v.data.id then
            if self.initmobao then 
                v.itemLogic:SetToggle()
            else
                self.initmobao = true
                v.itemLogic:SetToggleActive()
            end			
			break
		end
	end
end

function NewTrumpPanel:ChangePanel(to)
	for i = 1, table.getCount(self._panels) do
		if i == to then
			self._panels[i]:SetEnable(true)
			self:SetBtnToggleActive(self._toggles[i], true);
		else
			self._panels[i]:SetEnable(false)
			self:SetBtnToggleActive(self._toggles[i], false);
		end
	end
	self._panenIndex = to
    if self._panenIndex ~= 3 then
        self._phalanxInfo2.gameObject:SetActive(false)
        self._phalanxInfo.gameObject:SetActive(true)
    else
        self._phalanxInfo.gameObject:SetActive(false)
        self._phalanxInfo2.gameObject:SetActive(true)
    end
	self:UpdateTrumpSubPanel()    
end

function NewTrumpPanel:SetBtnToggleActive(btn, bool)
	local toggle = UIUtil.GetComponent(btn, "UIToggle");
	toggle.value = bool;
end

function NewTrumpPanel:UpdateTrumpSubPanel()
	self:UpdateState()
	if(self._panels[self._panenIndex]) then
		self._panels[self._panenIndex]:UpdatePanel()
	end
end

function NewTrumpPanel:UpdateTrumpSelectRefineInfo()
	self._panels[2]:UpdateRefineInfo()
end

function NewTrumpPanel:UpdateState()
	self._tipTrump.gameObject:SetActive(NewTrumpManager.CanTrumpShowTip())
	self._tipRefine.gameObject:SetActive(NewTrumpManager.CanTrumpRefineShowTip())
	
end

function NewTrumpPanel:PlayUIEffect(index)
	if(self._sucUIEffect) then
		self._sucUIEffect:Play()
	end
	if(self._panels[2]) then
		self._panels[2]:PlayRefineUIEffect(index)
	end
end

