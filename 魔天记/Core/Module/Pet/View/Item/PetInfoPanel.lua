require "Core.Module.Common.UIComponent"
require "Core.Module.Pet.View.Item.PetItem"
require "Core.Module.Common.UIAnimationModel"
require "Core.Role.ModelCreater.PetModelCreater"

local PetInfoPanel = class("PetInfoPanel", UIComponent);
local titleImgName = {"lianqi", "ningye", "huajing", "zhendan", "tianxiang", "tongxuan", "yongsheng"}

function PetInfoPanel:New(transform)
	self = {};
	setmetatable(self, {__index = PetInfoPanel});
	if(transform) then		
		self:Init(transform);
	end
	return self
end


function PetInfoPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function PetInfoPanel:_InitReference()	
	self._txtName = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtName");
	-- self._txtTitle = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTitle");
	self._txtPower = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtPower");
	self._imgRankTitle = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgRankTitle");
	
	self._roleParent = UIUtil.GetChildByName(self._gameObject, "imgRole/heroCamera/trsRoleParent");
	
	self._petPhalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "Panel/petPhalanx");
	self._petPhalanx = Phalanx:New();
	self._petPhalanx:Init(self._petPhalanxInfo, PetItem)
	
	self._uiUpEffectParent = UIUtil.GetChildByName(self._gameObject, "effectParent")
	self._bg1 = UIUtil.GetChildByName(self._gameObject, "UITexture", "imgRole")
	self._petUpEffect = UIEffect:New()
	self._petUpEffect:Init(self._uiUpEffectParent, self._bg1, 4, "ui_petadvance")
end

function PetInfoPanel:_InitListener()
end

function PetInfoPanel:_Dispose()
	self:_DisposeReference();
end

function PetInfoPanel:_DisposeReference()
	self._txtCombine = nil;
	self._txtName = nil;
	-- self._txtTitle = nil;
	self._txtPower = nil;
	self._imgRankTitle = nil;
	self._roleParent = nil;	
	if(self._uiPetAnimationModel ~= nil) then
		self._uiPetAnimationModel:Dispose()
		self._uiPetAnimationModel = nil
	end
	
	if(self._petUpEffect) then
		self._petUpEffect:Dispose()
		self._petUpEffect = nil
	end
end

function PetInfoPanel:UpdatePanel(currentPet)
	if((self._curPetdata == nil) or(currentPet and(self._curPetdata.id ~= currentPet.id))) then
		self._curPetdata = currentPet
		self._roleParent.localRotation = Quaternion.Euler(0, 180, 0)
	end
	
	if(currentPet == nil) then
		self._txtName.text = ""	
		-- self._txtTitle.text = ""
		self._txtPower.text = "0"
		self._imgRankTitle.spriteName = ""	
		self._petPhalanx:Build(20, 1, {})
		if(self._uiPetAnimationModel ~= nil) then
			self._uiPetAnimationModel:Dispose()
			self._uiPetAnimationModel = nil
		end
	else	
		self._txtName.text = currentPet.name
		self._txtName.color = ColorDataManager.GetColorByQuality(currentPet.quality)	
		-- self._txtTitle.text = LanguageMgr.Get("Pet/PetPanel/Rank" ..(currentPet.rank % 3))
		self._imgRankTitle.spriteName = "rank" .. currentPet.aptitude_lev 
		self._txtPower.text = currentPet:GetPower()
		
		if(self._uiPetAnimationModel == nil) then
			self._uiPetAnimationModel = UIAnimationModel:New(currentPet, self._roleParent, PetModelCreater)
		else
			self._uiPetAnimationModel:ChangeModel(currentPet, self._roleParent)
		end
		
		self._uiPetAnimationModel:Play(RoleActionName.stand)
		self._uiPetAnimationModel:SetRotation(Vector3.New(0, currentPet.towards, 0))
		self._uiPetAnimationModel:SetScale(currentPet.model_scale_rate)
	end
	
	self:UpdatePetList()
end

function PetInfoPanel:UpdatePetList()
	local localPetData = PetManager.GetAllPetData()
	if(localPetData ~= nil and table.getCount(localPetData) > 0) then
		self._petPhalanx:Build(table.getCount(localPetData), 1, localPetData)
	end
end


function PetInfoPanel:ShowUpEffect()
	self._petUpEffect:Play()
end

function PetInfoPanel:UpdatePetName(name)
	self._txtName.text = name
end

return PetInfoPanel 