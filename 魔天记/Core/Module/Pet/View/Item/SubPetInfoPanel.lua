require "Core.Module.Common.UIComponent"
require "Core.Module.Pet.View.Item.SubPetAddExpPanel"
require "Core.Module.Pet.View.Item.PetAddExpItem"
require "Core.Info.BaseAdvanceAttrInfo";

local PetSkillGroupItem = require "Core.Module.Pet.View.Item.PetSkillGroupItem"
local BaseNextPropertyItem = require "Core.Module.Common.BaseNextPropertyItem"
local PetFashionEffect = require "Core.Module.Pet.View.Item.PetFashionEffect"
require "Core.Module.Common.BasePropertyItem"


SubPetInfoPanel = class("SubPetInfoPanel", UIComponent);

function SubPetInfoPanel:New()
	self = {};
	setmetatable(self, {__index = SubPetInfoPanel});
	return self
end

function SubPetInfoPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function SubPetInfoPanel:_InitReference()
	-- self._txtRank = UIUtil.GetChildByName(self._transform, "UILabel", "txtRanklevel")
	self._txtName = UIUtil.GetChildByName(self._transform, "UILabel", "txtName")
	self._txtLevel = UIUtil.GetChildByName(self._transform, "UILabel", "txtLevel")
	self._txtExp = UIUtil.GetChildByName(self._transform, "UILabel", "slider_exp/txtExp")
	self._slider = UIUtil.GetChildByName(self._transform, "UISlider", "slider_exp")
	
	local effectBg = UIUtil.GetChildByName(self._transform, "UITexture", "imgRole")
	local effectParent = UIUtil.GetChildByName(self._transform, "effectParent")
	
	self._effect = UIEffect:New()		
	self._effect:Init(effectParent, effectBg, 4, "ui_partner_update")
	
	self._levelEffect = PetFashionEffect:New()	
	self._levelEffect:Init(effectParent, effectBg, 0, "",-1)
	
	self._roleParent = UIUtil.GetChildByName(self._transform, "imgRole/heroCamera/trsRoleParent")
	-- self._txtPower = UIUtil.GetChildByName(self._transform, "UILabel", "txtPower")
	
	
	self._curPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "propertyPhalanx")
	self._curPropertyPhalanx = Phalanx:New()
	self._curPropertyPhalanx:Init(self._curPropertyPhalanxInfo, BasePropertyItem)
	
	self._nextPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "nextpropertyPhalanx")
	self._nextPropertyPhalanx = Phalanx:New()
	self._nextPropertyPhalanx:Init(self._nextPropertyPhalanxInfo, BaseNextPropertyItem)
	
	self._expPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "itemPhalanx")
	self._expPhalanx = Phalanx:New()
	self._expPhalanx:Init(self._expPhalanxInfo, PetAddExpItem)
	
	local skillParent = UIUtil.GetChildByName(self._transform, "skillParent")
	self._skillGroup = PetSkillGroupItem:New()
	self._skillGroup:Init(skillParent)	
	
	self._attr = BaseAdvanceAttrInfo:New()
end

function SubPetInfoPanel:_InitListener()
	
end


-- function SubPetInfoPanel:_OnClickBtnAddExp()
-- 	SequenceManager.TriggerEvent(SequenceEventType.Guide.PET_LVUP_PANEL_SHOW);
-- end
-- function SubPetInfoPanel:_OnClickBtnFight()
-- 	PetProxy.SetPetStatus(self._currentPet.id, 1)
-- 	SequenceManager.TriggerEvent(SequenceEventType.Guide.PET_FIGHT);
-- end
-- function SubPetInfoPanel:_OnClickBtnRest()
-- 	PetProxy.SetPetStatus(self._currentPet.id, 0)
-- end
-- function SubPetInfoPanel:_OnClickBtnExplain()
-- 	ModuleManager.SendNotification(PetNotes.OPEN_PETEXPLAINPANEL)
-- end
-- function SubPetInfoPanel:_OnClickBtnRandAptitude()
-- 	ModuleManager.SendNotification(PetNotes.OPEN_PETRANDAPTITUDEPANEL)
-- end
function SubPetInfoPanel:_Dispose()
	self:_DisposeReference();
	
	self._nextPropertyPhalanx:Dispose()
	self._nextPropertyPhalanx = nil
	self._curPropertyPhalanx:Dispose()
	self._curPropertyPhalanx = nil
	self._expPhalanx:Dispose()
	self._expPhalanx = nil
	
	self._effect:Dispose()
	self._effect = nil
	
	self._skillGroup:Dispose()
	self._skillGroup = nil
	if(self._uiPetAnimationModel) then
		self._uiPetAnimationModel:Dispose()
		self._uiPetAnimationModel = nil
	end
	
	if(self._levelEffect) then
		self._levelEffect:Dispose()
		self._levelEffect = nil
	end
	
end

function SubPetInfoPanel:_DisposeReference()
	-- self._sliderExp = nil
	-- UIUtil.GetComponent(self._imgBaseSkillIcon, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickImgIcon = nil;
	-- UIUtil.GetComponent(self._btnFight, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnFight = nil;
	-- UIUtil.GetComponent(self._btnRest, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnRest = nil;
	-- UIUtil.GetComponent(self._btnRandAptitude, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnRandAptitude = nil;
	-- UIUtil.GetComponent(self._goActivePet, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnActive = nil;
	-- self._goRandAptitudeTip = nil
end

--更新整个面板
function SubPetInfoPanel:UpdatePanel()	
	self:UpdateAddExpPanel()
	self:UpdateLevel()
	self:UpdateCurFashionData()	
end

--更新等级相关数据
function SubPetInfoPanel:UpdateLevel()
	self._currentPet = PetManager.GetCurrentPetdata()
	if(self._currentPet) then
		self:UpdateExp()
		self._txtLevel.text = GetLvDes(self._currentPet:GetLevel())		
		-- self._txtPower.text = self._currentPet:GetLevelPower()	
		local levelUpAttr = self._currentPet:GetPetLevelUpAttr()
		self._attr:Init(levelUpAttr)
		self._attr:Add(self._currentPet:GetPassiveAttr())
		
		local property = self._attr:GetPropertyAndDes()
		
		self._curPropertyPhalanx:Build(#property, 1, property)
		
		local nextConfig = PetManager.GetPetUpdateConfig(self._currentPet:GetLevel() + 1)
		if(nextConfig) then
			local attr = BaseAdvanceAttrInfo:New()
			attr:Init(nextConfig)
			attr:Sub(self._currentPet:GetPetLevelUpAttr())
			local nextproperty = attr:GetPropertyAndDes()
			self._nextPropertyPhalanx:Build(#nextproperty, 1, nextproperty)
		else
			self._nextPropertyPhalanx:Build(0, 0, {})
		end	
	end	
end

function SubPetInfoPanel:UpdateExp()
	local currentPet = PetManager.GetCurrentPetdata()
	self._slider.value = currentPet:GetExp() / currentPet:GetMaxExp()
	self._txtExp.text = currentPet:GetExp() .. "/" .. currentPet:GetMaxExp()
end

local blue = ColorDataManager.Get_blue()
local purple = ColorDataManager.Get_purple()
local gold = ColorDataManager.Get_golden()
local orange = ColorDataManager.Get_orange()
local red = ColorDataManager.Get_red()


--更新和外形相关数据
function SubPetInfoPanel:UpdateCurFashionData()
	local curPet = PetManager.GetCurrentPetdata()
	local petFashionData = curPet:GetPetFashionInfo()
	
	if(petFashionData) then	
		 
		self._levelEffect:SetByConfig(petFashionData:GetEffectConfig())
	 
		self._txtName.text = petFashionData:GetName()	
		self._txtName.color = ColorDataManager.GetColorByQuality(petFashionData:GetQuality())
		local allSkills =	petFashionData:GetAllAddSkills()
		self._skillGroup:UpdateItem(allSkills)
		
		if(self._uiPetAnimationModel == nil) then
			self._uiPetAnimationModel = UIAnimationModel:New(petFashionData, self._roleParent, PetModelCreater)
		else
			self._uiPetAnimationModel:ChangeModel(petFashionData, self._roleParent)
		end
		self._uiPetAnimationModel:SetScale(petFashionData:GetScale())
	end
end

function SubPetInfoPanel:UpdateAddExpPanel()
	self._expPhalanx:Build(1, 3, PetManager.PetAddExpItemId)
end

function SubPetInfoPanel:ShowUpdateLevelEffect()
	if(self._effect) then
		self._effect:Play()
	end
end 