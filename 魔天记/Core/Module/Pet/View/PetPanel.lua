require "Core.Module.Common.Panel"
require "Core.Module.Common.UIEffect"
require "Core.Module.Pet.PetNotes"
require "Core.Module.Pet.View.Item.SubPetInfoPanel"
require "Core.Module.Pet.View.Item.SubPetAdvancePanel"
-- require "Core.Module.Pet.View.Item.SubPetSkillPanel"
-- require "Core.Module.Pet.View.Item.SubPetFormationPanel"
-- require "Core.Module.Pet.View.Item.PetItem"
-- require "Core.Module.Pet.View.Item.FormationPetItem"
-- local PetInfoPanel = require "Core.Module.Pet.View.Item.PetInfoPanel"
-- local PetFormationPanel = require "Core.Module.Pet.View.Item.PetFormationPanel"
local SubPetFashionPanel = require "Core.Module.Pet.View.Item.SubPetFashionPanel"


PetPanel = class("PetPanel", Panel)

local rightPanelIndex = 1
function PetPanel:New()
	self = {};
	setmetatable(self, {__index = PetPanel});
	return self;
end

function PetPanel:_Init()
	PetManager.SortPet()
	-- PetManager.ResetCurrentPetId()
	-- PetManager.ResetSkillUpdateState()
	self:_InitReference();
	self:_InitListener();
	
	self._btnAdvanced.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.PetAdvance))
	self._btnFashion.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.PetFashion))
	
	-- self._btnSkill.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.PetSkill))
	self._rightPanels = {}
	self._rightPanels[1] = SubPetInfoPanel:New()
	self._rightPanels[1]:Init(self._trsInfo)
	self._rightPanels[2] = SubPetAdvancePanel:New()
	self._rightPanels[2]:Init(self._trsAdvanced)
	self._rightPanels[3] = SubPetFashionPanel:New()
	self._rightPanels[3]:Init(self._trsFashion)
	self._toggles = {self._toggleInfo, self._toggleAdvanced, self._toggleFashion}
	
end

function PetPanel:_InitReference()
	
	local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
	self._trsRoleParent = UIUtil.GetChildInComponents(trss, "trsRoleParent");
	self._trsInfo = UIUtil.GetChildInComponents(trss, "trsInfo");
	self._trsAdvanced = UIUtil.GetChildInComponents(trss, "trsAdvanced");
	self._trsFashion = UIUtil.GetChildInComponents(trss, "trsFashion");
	
	-- self._trsFormation = UIUtil.GetChildInComponents(trss, "trsFormation");	
	-- self._trsSkill = UIUtil.GetChildInComponents(trss, "trsSkill");
	-- self._leftParent1 = UIUtil.GetChildInComponents(trss, "leftParent1");	
	-- self._leftParent2 = UIUtil.GetChildInComponents(trss, "leftParent2");	
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
	self._btnInfo = UIUtil.GetChildInComponents(btns, "btnInfo");
	self._btnAdvanced = UIUtil.GetChildInComponents(btns, "btnAdvanced");
	self._btnFashion = UIUtil.GetChildInComponents(btns, "btnFashion")
	
	self._goInfoTip = UIUtil.GetChildByName(self._btnInfo, "tip").gameObject	
	self._goAdvancedTip = UIUtil.GetChildByName(self._btnAdvanced, "tip").gameObject
	self._goFashionTip = UIUtil.GetChildByName(self._btnFashion, "tip").gameObject
	-- self._btnFormation = UIUtil.GetChildInComponents(btns, "btnFormation");
	-- self._btnSkill = UIUtil.GetChildInComponents(btns, "btnSkill");
	-- self._goFormationTip = UIUtil.GetChildByName(self._btnFormation, "tip").gameObject
	-- self._goSkillTip = UIUtil.GetChildByName(self._btnSkill, "tip").gameObject
	self._toggleInfo = UIUtil.GetComponent(self._btnInfo, "UIToggle");
	self._toggleAdvanced = UIUtil.GetComponent(self._btnAdvanced, "UIToggle");
	self._toggleFashion = UIUtil.GetComponent(self._btnFashion, "UIToggle")
	-- self._toggleFormation = UIUtil.GetChildInComponents(toggles, "btnFormation");
	-- self._toggleSkill = UIUtil.GetChildInComponents(toggles, "btnSkill");
	-- self._petInfoPanel = PetInfoPanel:New(self._leftParent1)
	-- self._petFormationPanel = PetFormationPanel:New(self._leftParent2)
end

function PetPanel:_InitListener()
	self:_AddBtnListen(self._btn_close.gameObject)
	self:_AddBtnListen(self._btnInfo.gameObject)
	self:_AddBtnListen(self._btnAdvanced.gameObject)
	self:_AddBtnListen(self._btnFashion.gameObject)
	
	
	
	-- self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	-- UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	-- self._onClickBtnInfo = function(go) self:_OnClickBtnInfo(self) end
	-- UIUtil.GetComponent(self._btnInfo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnInfo);
	-- self._onClickBtnAdvanced = function(go) self:_OnClickBtnAdvanced(self) end
	-- UIUtil.GetComponent(self._btnAdvanced, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAdvanced);
	-- self._onClickBtnFormation = function(go) self:_OnClickBtnFormation(self) end
	-- UIUtil.GetComponent(self._btnFormation, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFormation);
	-- self._onClickBtnSkill = function(go) self:_OnClickBtnSkill(self) end
	-- UIUtil.GetComponent(self._btnSkill, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSkill);
end

function PetPanel:_OnBtnsClick(go)
	if(go == self._btn_close.gameObject) then
		self:_OnClickBtn_close()
	elseif(go == self._btnInfo.gameObject) then
		self:_OnClickBtnInfo()
	elseif(go == self._btnAdvanced.gameObject) then
		self:_OnClickBtnAdvanced()
	elseif(go == self._btnFashion.gameObject) then
		self:_OnClickBtnFashion()
	end	
end



function PetPanel:_OnClickBtn_close()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(PetNotes.CLOSE_PETPANEL)
end

function PetPanel:_OnClickBtnInfo()
	-- self._leftPanelIndex = 1
	-- self._rightPanenlIndex = 1
	-- rightPanelIndex = 1
	self:ChangeRightPanel(1)
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PET_CHANGE_PANEL, 1)
end

function PetPanel:_OnClickBtnAdvanced()
	-- self._leftPanelIndex = 1
	-- self._rightPanenlIndex = 2
	-- rightPanelIndex = 2
	self:ChangeRightPanel(2)
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PET_CHANGE_PANEL, 2)
end

function PetPanel:_OnClickBtnFashion()
	self:ChangeRightPanel(3)
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PET_CHANGE_PANEL, 3)
end

-- function PetPanel:_OnClickBtnSkill()
-- 	-- self._leftPanelIndex = 1
-- 	self._rightPanenlIndex = 3
-- 	rightPanelIndex = 3
-- 	self:UpdatePetPanel()
-- 	SequenceManager.TriggerEvent(SequenceEventType.Guide.PET_CHANGE_PANEL, 3)
-- end
-- function PetPanel:_OnClickBtnFormation()
-- 	-- self._leftPanelIndex = 2
-- 	self._rightPanenlIndex = 4
-- 	rightPanelIndex = 4
-- 	self:UpdatePetPanel()
-- 	SequenceManager.TriggerEvent(SequenceEventType.Guide.PET_CHANGE_PANEL, 4)
-- end
function PetPanel:_Dispose()
	
	self:_DisposeListener();
	self:_DisposeReference();
	-- if(self._petInfoPanel) then
	-- 	self._petInfoPanel:Dispose()
	-- 	self._petInfoPanel = nil		
	-- end
	if(self._petFormationPanel) then
		self._petFormationPanel:Dispose()
		self._petFormationPanel = nil		
	end
	
	
end

function PetPanel:_DisposeListener()
	-- UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtn_close = nil;
	-- UIUtil.GetComponent(self._btnInfo, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnInfo = nil;
	-- UIUtil.GetComponent(self._btnAdvanced, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnAdvanced = nil;
	-- UIUtil.GetComponent(self._btnFormation, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnFormation = nil;
	-- UIUtil.GetComponent(self._btnSkill, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnSkill = nil;
	-- UIUtil.GetComponent(self._btnMotifyName, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnMotifyName = nil;
end

function PetPanel:_DisposeReference()
	self._btn_close = nil;
	self._btnInfo = nil;
	self._btnFormation = nil;
	self._btnAdvanced = nil;
	-- self._btnSkill = nil;
	self._toggleInfo = nil
	self._toggleFormation = nil
	self._toggleAdvanced = nil
	self._toggleSkill = nil
	self._toggles = nil
	for k, v in ipairs(self._rightPanels) do
		v:Dispose()
	end
	self._rightPanels = nil
	self._curPetdata = nil
end

function PetPanel:OpenTab(idx)
	idx = idx or 1;
	if idx == 1 then
		self:_OnClickBtnInfo();
	elseif idx == 2 then
		self:_OnClickBtnAdvanced();
	elseif idx == 3 then
		self:_OnClickBtnFashion();
	end
end

-- function PetPanel:UpdateLefePanel1()
-- 	local currentPet = PetManager.GetCurrentPetdata()	
-- 	self._petInfoPanel:UpdatePanel(currentPet)	
-- end
-- function PetPanel:UpdateLefePanel2()
-- 	self._petFormationPanel:UpdatePanel()
-- end
-- function PetPanel:UpdateLefePanel()
-- 	if(self._leftPanelIndex == 1) then
-- 		SetUIEnable(self._leftParent1, true)
-- 		SetUIEnable(self._leftParent2, false)
-- 		self:UpdateLefePanel1()
-- 	else
-- 		SetUIEnable(self._leftParent1, false)
-- 		SetUIEnable(self._leftParent2, true)
-- 		self:UpdateLefePanel2()
-- 	end
-- end
-- function PetPanel:UpdatePetList()
-- 	self._petInfoPanel:UpdatePetList()
-- end
function PetPanel:ChangeRightPanel(to)
	for i, v in pairs(self._rightPanels) do
		if i == to then		
			self._rightPanels[i]:SetEnable(true)
		else
			self._rightPanels[i]:SetEnable(false)
		end
	end
	self._rightPanenlIndex = to
	rightPanelIndex = to
	if(self._toggles[self._rightPanenlIndex]) then
		self._toggles[self._rightPanenlIndex].value = true
	end
	
	self:UpdateTipState()
	self:UpdateRightPanel(self._rightPanenlIndex)
end

function PetPanel:UpdateRightPanel(panelIndex)
	if(self._rightPanels[panelIndex]) then
		self._rightPanels[panelIndex]:UpdatePanel();
	end
	if(self._rightPanels[2]) then
		self._rightPanels[2]:StopAdvanceTimer()
	end
	-- if panelIndex == 1 then
	-- 	self._rightPanels[1]:UpdatePanel();
	-- elseif panelIndex == 2 then
	-- 	self._rightPanels[2]:UpdatePanel();
	-- elseif panelIndex == 3 then
	-- 	self._rightPanels[3]:UpdatePanel();
	-- elseif panelIndex == 4 then
	-- 	self._rightPanels[4]:UpdatePanels();
	-- end
end

function PetPanel:UpdatePetPanel()	
	self:ChangeRightPanel(self._rightPanenlIndex)	
end

-- function PetPanel:UpdatePetName(name)
-- 	self._petInfoPanel:UpdatePetName(name)
-- end
-- function PetPanel:ChangeFormationPanel()
-- 	self._rightPanels[4]:ChangePanel(2)
-- end
function PetPanel:OpenUpdateLevelPanel()
	self._rightPanels[1]:_OnClickBtnAddExp()
end

function PetPanel:UpdateTipState()	
	self._goInfoTip:SetActive(PetManager.GetCanUseExpItem())
	self._goAdvancedTip:SetActive(PetManager.GetCanAdvance())
	self._goFashionTip:SetActive(PetManager.GetFashionMsg())			
end

function PetPanel:ShowUpEffect()
	
end

function PetPanel.GetRightPanelIndex()
	return rightPanelIndex
end

function PetPanel:UpdateAddExpPanel()
	if(self._rightPanels[1]) then
		self._rightPanels[1]:UpdateAddExpPanel()
	end
end

function PetPanel:UpdateExp()
	if(self._rightPanels[1]) then
		self._rightPanels[1]:UpdateExp()
		self._rightPanels[1]:UpdateAddExpPanel()		
	end
	self._goInfoTip:SetActive(PetManager.GetCanUseExpItem())
end

function PetPanel:UpdateLevel()
	if(self._rightPanels[1]) then
		self._rightPanels[1]:UpdateLevel()
		self._rightPanels[1]:UpdateAddExpPanel()		
	end
	self._goInfoTip:SetActive(PetManager.GetCanUseExpItem())
end

function PetPanel:UpdateFashionData(data)
	if(self._rightPanels[2]) then
		self._rightPanels[2]:UpdateFashionData(data) 	
	end
end

function PetPanel:UpdateAdvanceExp()
	if(self._rightPanels[2]) then
		self._rightPanels[2]:UpdateExp()
	end
	self._goAdvancedTip:SetActive(PetManager.GetCanAdvance())
	
end

function PetPanel:UpdateAdvanceLevel()
	if(self._rightPanels[2]) then
		self._rightPanels[2]:UpdateRank()
	end
	self._goAdvancedTip:SetActive(PetManager.GetCanAdvance())
	
end

function PetPanel:UpdatePetFashionPanel(data)
	if(self._rightPanels[3]) then
		self._rightPanels[3]:UpdatePetFashionPanel(data)
	end
end

function PetPanel:ShowUpdateLevelLabel(value)
	value = value or 0
	if(value > 0) then
		if(self._rightPanels[2]) then
			self._rightPanels[2]:ShowUpdateLevelLabel(value)
		end
	end
end

function PetPanel:ShowUpdateLevelEffect()
	if(self._rightPanels[1]) then
		self._rightPanels[1]:ShowUpdateLevelEffect()
	end
end

function PetPanel:ShowUpdateRankEffect()
	if(self._rightPanels[2]) then
		self._rightPanels[2]:ShowUpdateRankEffect()
	end
end

function PetPanel:ShowFashionEffect()
	if(self._rightPanels[3]) then
		self._rightPanels[3]:ShowFashionEffect()
	end
end 