require "Core.Module.Common.Panel"
require "Core.Module.Skill.View.SkillUpgradePanel"
require "Core.Module.Skill.View.SkillSettingPanel"
require "Core.Module.Skill.View.SkillTalentPanel"
require "Core.Module.Skill.View.SkillTheurgyPanel"

SkillPanel = Panel:New();
local insert = table.insert


function SkillPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function SkillPanel:_InitReference()
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
	
	self._redPoint = {};
	self._toggles = {};
	self._btnSkill = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnSkill");
	self._toggles[1] = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnSkill");
	self._redPoint[1] = UIUtil.GetChildByName(self._btnSkill, "UISprite", "redPoint");
	
	self._btnSetting = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnSetting");
	self._toggles[2] = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnSetting");
	self._redPoint[2] = UIUtil.GetChildByName(self._btnSetting, "UISprite", "redPoint");
	
	-- self._btnTalent = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnTalent");
	-- self._toggles[3] = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnTalent");
	-- self._redPoint[3] = UIUtil.GetChildByName(self._btnTalent, "UISprite", "redPoint");
	self._btnTheurgy = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnTheurgy");
	self._toggles[4] = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btnTheurgy");
	self._redPoint[4] = UIUtil.GetChildByName(self._btnTheurgy, "UISprite", "redPoint");
	
	self._upgradePanel = UIUtil.GetChildByName(self._trsContent, "Transform", "panels/upgradePanel");
	self._settingPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "panels/settingPanel");
	self._talentPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "panels/talentPanel");
	self._theurgyPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "panels/theurgyPanel");
	self:_CreatePanel();
	self._btnTheurgy.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.Theurgy));
	--self:SetData(1);
	--self._btnPosture = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnPosture");
end

function SkillPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	self._onClickBtnSkill = function(go) self:_OnClickBtnSkill(self) end
	UIUtil.GetComponent(self._btnSkill, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSkill);
	self._onClickBtnSetting = function(go) self:_OnClickBtnSetting(self) end
	UIUtil.GetComponent(self._btnSetting, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSetting);
	-- self._onClickBtnTalent = function(go) self:_OnClickBtnTalent(self) end
	-- UIUtil.GetComponent(self._btnTalent, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTalent);
	self._onClickBtnTheurgy = function(go) self:_OnClickBtnTheurgy(self) end
	UIUtil.GetComponent(self._btnTheurgy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTheurgy);
	
	--self._onClickBtnPosture = function(go) self:_OnClickBtnPosture(self) end
	--UIUtil.GetComponent(self._btnPosture, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnPosture);
	MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, SkillPanel.SetUpgradeRedPoint, self);
	
	--?????????????????? ?????????????????????????????????????????????????????????????????????, ??????????????????????????????????????? ????????????.
	MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_UPGRADE, SkillPanel.SetUpgradeRedPoint, self);
	
	
	-- MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_TALENT_CHG, SkillPanel.SetTalentRedPoint, self);
end

function SkillPanel:_OnClickBtnClose()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(SkillNotes.CLOSE_SKILLPANEL);
end

function SkillPanel:_OnClickBtnSkill()
	self:SetData(1);
end

function SkillPanel:_OnClickBtnSetting()
	self:SetData(2);
end

function SkillPanel:_OnClickBtnTalent()
	-- self:SetData(3);
end

function SkillPanel:_OnClickBtnTheurgy()
	self:SetData(4);
end
--[[function SkillPanel:_OnClickBtnPosture()
    self:SetData(4);
end
]]
function SkillPanel:SetData(index)
	index = index or 1;
	if(self._index ~= index) then
		for i, v in pairs(self._panels) do
			if index == i then
				v:Enable();
				self._toggles[i].value = true
			else
				v:Disable();
				self._toggles[i].value = false
			end
		end		
		self._index = index;
		SequenceManager.TriggerEvent(SequenceEventType.Guide.SKILL_CHANGE_PANEL, index);		
	end
end

function SkillPanel:_CreatePanel()
	self._panels = {};
	local panel1 = SkillUpgradePanel.New();
	panel1:Init(self._upgradePanel);
	self._panels[1] =	panel1	
	-- insert(self._panels, panel1);
	local panel2 = SkillSettingPanel.New();
	panel2:Init(self._settingPanel);		
	self._panels[2] =	panel2
	
	-- insert(self._panels, panel2);
	-- local panel3 = SkillTalentPanel.New();
	-- panel3:Init(self._talentPanel);             
	-- insert(self._panels, panel3);
	local panel4 = SkillTheurgyPanel.New();
	panel4:Init(self._theurgyPanel);			
	-- insert(self._panels, panel4);	
	self._panels[4] =	panel4
	
end

function SkillPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function SkillPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	UIUtil.GetComponent(self._btnSkill, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnSkill = nil;
	UIUtil.GetComponent(self._btnSetting, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnSetting = nil;
	-- UIUtil.GetComponent(self._btnTalent, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnTalent = nil;
	UIUtil.GetComponent(self._btnTheurgy, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTheurgy = nil;
	
	--.GetComponent(self._btnPosture, "LuaUIEventListener"):RemoveDelegate("OnClick");
	--self._onClickBtnPosture = nil;
	MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, SkillPanel.SetUpgradeRedPoint);
	MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_UPGRADE, SkillPanel.SetUpgradeRedPoint);
	-- MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_TALENT_CHG, SkillPanel.SetTalentRedPoint);
end

function SkillPanel:_DisposeReference()
	self._btnClose = nil;
	self._btnSkill = nil;
	self._btnSetting = nil;
	self._btnTalent = nil;
	self._toggles = nil;
	--self._btnPosture = nil;
	for i, v in pairs(self._panels) do
		v:Dispose();
	end
end

function SkillPanel:_Opened()
	self:UpdateRedPoint();
end

function SkillPanel:UpdateRedPoint()
	for i, v in pairs(self._redPoint) do
		v.gameObject:SetActive(false);
	end
	self:SetUpgradeRedPoint();
	self:SetSettingRedPoint();
	-- self:SetTalentRedPoint();
end

function SkillPanel:SetUpgradeRedPoint()
	self._redPoint[1].gameObject:SetActive(SkillManager.GetUpgradeRedPoint());
end

function SkillPanel:SetSettingRedPoint()
	self._redPoint[2].gameObject:SetActive(SkillManager.GetSettingRedPoint());
end

function SkillPanel:SetTalentRedPoint()
	-- self._redPoint[3].gameObject:SetActive(false)--[[  ]];
end 